#include "NativeAACDecoder.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>
#include <stdarg.h>
#include <getopt.h>
#include "mp4ffint.h"
#include "log.h"
#include "s_tdec_int_file.h"
#include "pvmp4audiodecoder_api.h"
#include "e_tmp4audioobjecttype.h"

#define MAX_CHANNELS 2 /* make this higher to support files with
                          more channels */

/**
 * 缓冲区大小
 * 2304000 cpu ~70%
 * 230400  cpu ~35%
 * 115200  cpu ~33%
 * 57600   cpu ~33%
 * */
//#define MAX_BUFFER 768*50*6
//#define MAX_BUFFER 115200
#define MAX_BUFFER 10240 //10K
#define MIN_BUFFER 2048

/* FAAD file buffering routines */
typedef struct {
    long bytes_into_buffer;

    long file_offset;
	long size;
    unsigned char *buffer;
    unsigned char *ptr;
    unsigned char *end;
    int at_eof;
    FILE *infile;
} aac_buffer;

typedef struct AACDOpenCore {
    tPVMP4AudioDecoderExternal *pExt;
    void *pMem;
    unsigned long frameSamplesFactor;
    // bytes left
    unsigned long bytesleft;
} AACDOpenCore;

#define AAC_STATUS_SEEKING 1
#define AAC_STATUS_DECODING 2
#define AAC_STATUS_READY 0
#define AAC_STATUS_NONE -1


struct AACFileHandle
{
	FILE* file;//文件
	int size;//文件长度
	int bitrate;//比特率
	int samplerate;//抽样率
	float duration;//播放时长
	int channelNum;//声道数	
	int fileType;
	int status;
	int mp4file;
	int track;
	long sampleId;
	mp4ff_t *infile;
	mp4ff_callback_t *mp4cb;
	aac_buffer buffer;//aac缓存信息	
	AACDOpenCore *oc;
};


static int findFreeHandle();


static long get_aac_currentPosition(AACFileHandle* aacHandle);
static int aac_seekTo(AACFileHandle* aacHandle, jint ms);

static long calPos(AACFileHandle* aacHandle, int msec);
static int adts_parse(aac_buffer *b, int *bitrate, int *sr, int *channel_count, float *length);
static void advance_buffer(aac_buffer *b, int bytes);
static int fill_buffer(aac_buffer *b);
static void zero_buffer(aac_buffer *b);
static int refill_buffer(aac_buffer * b,int filepos);
static void seek_buffer(aac_buffer * b,int filepos);
static int get_audio_track(mp4ff_t *infile, tPVMP4AudioDecoderExternal * pExt,void * pMem);
static int get_audio_track(const mp4ff_t *f);

static long get_mp4_currentPosition(AACFileHandle* aacHandle);
static int mp4_seekTo(AACFileHandle* aacHandle, jint ms);
static uint32_t read_callback(void *user_data, void *buffer, uint32_t length);
static uint32_t seek_callback(void *user_data, uint64_t position);

static int open_opencore_aac_file(FILE* fileHandle, AACFileHandle* aacHandle);
static int read_opencore_aac_samples(JNIEnv *env, AACFileHandle* aacHandle, jshortArray buffer, jint size);
static void aacd_opencore_destroy( void *ext );
static int open_opencore_mp4_file(FILE* fileHandle, AACFileHandle* aacHandle);
static int read_opencore_mp4_samples(JNIEnv *env, AACFileHandle* aacHandle, jshortArray buffer, jint size);


static void log(const char *format,...)
{
	va_list arg_ptr;
	va_start(arg_ptr, format);
	vprintf(format, arg_ptr);
	va_end(arg_ptr);
}

/** 所有AAC文件的句柄 **/
static AACFileHandle* aac_handles[10];

static void freeHandle(AACFileHandle* aacHandle)
{
	
	if (aacHandle->file)
	{
		fclose(aacHandle->file);
		aacHandle->file = NULL;
	}

	if (aacHandle->buffer.buffer)
	{
		free(aacHandle->buffer.buffer);
		aacHandle->buffer.buffer = NULL;
	}

	if(aacHandle->mp4file)
	{	
		if (aacHandle->infile)
		{
			mp4ff_close(aacHandle->infile);
			aacHandle->infile = NULL;
		}

		if (aacHandle->mp4cb)
		{
			free(aacHandle->mp4cb);
			aacHandle->mp4cb = NULL;
		}
		
	}

	if (aacHandle->oc)
	{
		aacd_opencore_destroy(aacHandle->oc);
	}

}

static void closeAACHandle(int index)
{
	if (index < 0 || index >= 10 || aac_handles[index] == NULL)
	{
		return;
	}

	AACFileHandle* aacHandle = aac_handles[index];
	freeHandle(aacHandle);
	delete aac_handles[index];
	aac_handles[index] = NULL;
}

static int calc_valid_frame_position(FILE *fileHandle)
{
	unsigned char header[8];
	int mp4file = 0;
	fread(header, 1, 8, fileHandle);
	rewind(fileHandle);
	if (header[4] == 'f' && header[5] == 't' && header[6] == 'y' && header[7] == 'p')
		mp4file = 1;

	if (!mp4file)
		return 0;

	/* initialise the callback structure */
	mp4ff_callback_t *mp4cb = (mp4ff_callback_t *)malloc(sizeof(mp4ff_callback_t));
	if(mp4cb == NULL){
		return -1;
	}

	mp4cb->read = read_callback;
	mp4cb->seek = seek_callback;
	mp4cb->user_data = fileHandle;

	mp4ff_t *infile = mp4ff_open_read(mp4cb);

	if (!infile){
		//error
		free(mp4cb);
		return -1;
	}

	int track = get_audio_track(infile);
	if (track == -1) 
	{
		free(mp4cb);
		mp4ff_close(infile);
		return -1;
	}

	long samples = mp4ff_num_samples(infile, track);
	if (samples <= 2)
	{
		free(mp4cb);
		mp4ff_close(infile);
		return -1;
	}

	int curpos = -1;
	int count = 2;
	int first= mp4ff_sample_to_offset(infile, track, 1);
	int offset = first ;
	if (samples > 100)
		samples = 100;


	while(count < samples)
	{
		curpos = mp4ff_sample_to_offset(infile, track, count);
		if ( curpos <= offset )
		{
			offset = -1;
			break;
		}
		offset = curpos;
		count ++;
	}

	if (offset >  0)
		offset = first;
	free(mp4cb);
	mp4ff_close(infile);	
	return offset;	
}

/*
 * 打开文件
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    native_get_valid_frame_position
 * Signature: (Ljava/lang/String;)I
 */

JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_native_1get_1valid_1frame_1position(JNIEnv *env, jclass cls, jstring file)
{
	const char* fileString = env->GetStringUTFChars(file, NULL);
	FILE* fileHandle = fopen( fileString, "rb" );
	int ret = -1;
	if (!fileHandle)
		goto get_valid_fail;

	ret = calc_valid_frame_position(fileHandle);
	fclose(fileHandle);
	
get_valid_fail:
	env->ReleaseStringUTFChars(file, fileString);
	return ret;
}


/*
 * 打开文件
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    openFile
 * Signature: (Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_openFile(JNIEnv *env, jobject obj, jstring file)
{
	int index = findFreeHandle( );
	if( index == -1 )
		return -1;
	//读取文件头，判断是否是MP4

	unsigned char header[8];
	AACFileHandle* aacHandle = NULL;
	int mp4file = 0;

	//取得文件全路径
	const char* fileString = env->GetStringUTFChars(file, NULL);

	FILE* fileHandle = fopen( fileString, "rb" );
	if (!fileHandle )
	{

		AACD_TRACE("open file %s failed\n", fileString);
		goto open_fail;
	}

	aacHandle = new AACFileHandle();
	if(aacHandle == NULL){
		goto open_fail;
	}
	memset(aacHandle, 0, sizeof(AACFileHandle));

	fread(header, 1, 8, fileHandle);
	rewind(fileHandle);
	if (header[4] == 'f' && header[5] == 't' && header[6] == 'y' && header[7] == 'p')
		mp4file = 1;
	
	AACD_TRACE("mp4file: %d\n", mp4file);

	aacHandle->mp4file = mp4file;
	if (!aacHandle->mp4file){
		AACD_TRACE("not mp4file");
		if(open_opencore_aac_file(fileHandle, aacHandle) < 0)	
		{
			fclose(fileHandle);
			freeHandle(aacHandle);
			goto open_fail;
		}

	}else{//mp4 aac
		AACD_TRACE("mp4file");

		if( open_opencore_mp4_file(fileHandle, aacHandle) < 0)	
		{
			fclose(fileHandle);
			freeHandle(aacHandle);
			goto open_fail;
		}
	}

	env->ReleaseStringUTFChars(file, fileString);
	aac_handles[index] = aacHandle;
	return index;

open_fail:
	env->ReleaseStringUTFChars(file, fileString);
	return -1;
}

/*
 * 取得声道数
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    getChannelNum
 * Signature: (I)I
 */
JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_getChannelNum(JNIEnv *env, jobject obj, jint handle)
{
	if(aac_handles[handle])
		return aac_handles[handle]->channelNum;
	return -1;
}

/*
 * 取得比特率，这个比特率在每帧都有可能是不同的
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    getBitrate
 * Signature: (I)I
 */
JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_getBitrate(JNIEnv *env, jobject obj, jint handle)
{
	if(aac_handles[handle])
		return aac_handles[handle]->bitrate;
	return -1;
}

/*
 * 取得采样率
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    getSamplerate
 * Signature: (I)I
 */
JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_getSamplerate(JNIEnv *env, jobject obj, jint handle)
{
	if(aac_handles[handle])
		return aac_handles[handle]->samplerate;
	return -1;
}

/*
 * 取得播放时长
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    getDuration
 * Signature: (I)I
 */
JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_getDuration(JNIEnv *env, jobject obj, jint handle)
{
	if(aac_handles[handle])
		return aac_handles[handle]->duration;
	return -1;
}

/*
 * 取得当前位置
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    getCurrentPosition
 * Signature: (I)I
 */
JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_getCurrentPosition(JNIEnv *env, jobject obj, jint handle)
{
	//播放位置
	AACFileHandle* aacHandle = aac_handles[handle];
	if(aacHandle == NULL)
		return -1;
	long curPos = 0;
	if(aacHandle->mp4file){
		curPos = get_mp4_currentPosition(aacHandle);
//		curPos = get_aac_currentPosition(aacHandle);
	}else{
		curPos = get_aac_currentPosition(aacHandle);
	}
	return curPos;
}

/*
 * 定位到
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    seekTo
 * Signature: (II)I
 */
JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_seekTo(JNIEnv *env, jobject obj, jint handle, jint ms)
{

	AACFileHandle* aacHandle = aac_handles[handle];
	if(aacHandle == NULL)
		return -1;	
	
	aacHandle->status = AAC_STATUS_SEEKING;
	int ret = 0;
	if (ms >= 0 && aacHandle->duration > 0)
	{
		AACD_TRACE("seek : %d", ms);
		if(aacHandle->mp4file){
			ret = mp4_seekTo(aacHandle, ms);
		}else{
			ret = aac_seekTo(aacHandle, ms);
		}
	}

	aacHandle->status = AAC_STATUS_READY;
	
	return ret;
}

/*
 * 取得每帧的采样率
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    getSamplePerFrame
 * Signature: (I)I
 */
JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_getSamplePerFrame(JNIEnv *env, jobject obj, jint handle)
{
	//代码目前没有使用到
	return -1;
}

/*
 * 读解码后的数据
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    readSamples
 * Signature: (ILjava/nio/FloatBuffer;I)I
 */
JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_readSamples__ILjava_nio_FloatBuffer_2I(JNIEnv *env, jobject obj, jint handle, jobject buffer, jint size)
{
	return -1;
}

/*
 * 读解码后的数据
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    readSamples
 * Signature: (ILjava/nio/ShortBuffer;I)I
 */
JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_readSamples__ILjava_nio_ShortBuffer_2I(JNIEnv *env, jobject obj, jint handle, jobject buffer, jint size)
{
	AACFileHandle* aacHandle = aac_handles[handle];
	if(aacHandle == NULL || aacHandle->status != AAC_STATUS_READY)
		return -1;	
	jshortArray outbuf = (jshortArray)env->GetDirectBufferAddress(buffer);
	aacHandle->status = AAC_STATUS_DECODING;
	int pos = 0;
	if(!aacHandle->mp4file){		
		pos = read_opencore_aac_samples(env, aacHandle, outbuf, size);
		
	}else{		
		pos = read_opencore_mp4_samples(env, aacHandle, outbuf, size);
	}
	
	aacHandle->status = AAC_STATUS_READY;
	return pos;
}

/*
 * 读解码后的数据
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    readSamples
 * Signature: (I[SI)I
 */
JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_readSamples__I_3SI(JNIEnv *env, jobject obj, jint handle, jshortArray buffer, jint size)
{
	//AACD_TRACE("Java_cn_kuwo_base_codec_NativeAACDecoder_readSamples__I_3SI");
	AACFileHandle* aacHandle = aac_handles[handle];
	if(aacHandle == NULL || aacHandle->status != AAC_STATUS_READY)
		return -1;	
	
	
	aacHandle->status = AAC_STATUS_DECODING;
	int pos = 0;
	if(!aacHandle->mp4file){		
		pos = read_opencore_aac_samples(env, aacHandle, buffer, size);
		
	}else{		
		pos = read_opencore_mp4_samples(env, aacHandle, buffer, size);
	}
	aacHandle->status = AAC_STATUS_READY;
	
	return pos;
}

/*
 * 关闭文件
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    closeFile
 * Signature: (I)V
 */
JNIEXPORT void JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_closeFile(JNIEnv *env, jobject obj, jint handle){
	closeAACHandle(handle);
}


/*
 * 指纹识别使用
 * Class:     cn_kuwo_hd_base_codec_NativeAACDecoder
 * Method:    downsampling
 * Signature: (ILjava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_downsampling(JNIEnv *env, jobject obj, jint handle, jstring file)
{
	//解码部分目前没有使用到
	return -1;
}

/**
 * 找到空闲的文件句柄
 */
static int findFreeHandle()
{
	for( int i = 0; i < 10; i++ )
	{
		if( aac_handles[i] == 0 )
			return i;
	}
	return -1;
}

static long get_aac_currentPosition(AACFileHandle* aacHandle){
	long curPos = (aacHandle->buffer.file_offset/aacHandle->bitrate);
	curPos = curPos *8;
	return curPos;
}

static int aac_seekTo(AACFileHandle* aacHandle, jint ms){
	if(aacHandle == NULL || ms <= 0)
		return -1;
	long btpos = calPos(aacHandle, ms);
	if(btpos < 0)
	{
		return -1;
	}
	
	int old_file_pos = aacHandle->buffer.file_offset;
	unsigned char tempbuf[MIN_BUFFER], *ptr = tempbuf;
	int filePos = (ms / (aacHandle->duration*1000)) * aacHandle->size;
	AACD_TRACE("source pos: %d", filePos);
	fseek(aacHandle->buffer.infile, filePos, SEEK_SET);

	int readsize = fread(tempbuf, 1, MIN_BUFFER, aacHandle->file);	
	int sync = 0;
	while( readsize >= 2 ) {
		if (!((ptr[0] == 0xFF)&&((ptr[1] & 0xF6) == 0xF0))) {
			ptr ++;
			readsize -- ;
		} else {
			sync = 1;
			break;
		}
	}

	// fail to seek adts sync
	if (!sync)
	{
		fseek(aacHandle->file, old_file_pos, SEEK_SET);
		return -1;
	} 

	filePos += ptr - tempbuf;
	AACD_TRACE("dest pos: %d", filePos);
	zero_buffer(&(aacHandle->buffer));
	fseek(aacHandle->file, filePos, SEEK_SET);	
	aacHandle->buffer.file_offset = filePos;	
	aacHandle->buffer.bytes_into_buffer = 0;
	aacHandle->buffer.at_eof = 0;
	fill_buffer(&(aacHandle->buffer));

	return 1;
}

static int adts_sample_rates[] = {96000,88200,64000,48000,44100,32000,24000,22050,16000,
		12000,11025,8000,7350,0,0,0};

static int  getSampleRate(int index)
{	
	if (index <= 15)
		return adts_sample_rates[index];

	return 0;
}


static int getSampleRateIndex(int samplerate) 
{
	for (int i= 0; i < 13; i++) 
		{
			if (adts_sample_rates[i] == samplerate)
				return i;
		}
	
	return 4;
}

static int adts_parse(aac_buffer *b, int *bitrate, int *sr, int *channel_count, float *length)
{
    int frames=0, frame_length;
    int t_framelength = 0;
    int samplerate;
    float frames_per_sec, bytes_per_frame = 0, channels;

    /* Read all frames to ensure correct time and bitrate */
    for (; ; )
    {
        if ( fill_buffer(b) <= 0)
			break;

		int sync = 0;
		while( b->bytes_into_buffer >= 2 ) {
			if (!((b->ptr[0] == 0xFF)&&((b->ptr[1] & 0xF6) == 0xF0))) {
				advance_buffer(b, 1);
			} else {
				sync = 1;
				break;
			}
		}

		if (!sync)
		{
			if (b->at_eof)
				break;
			
			continue;
		}

        if (b->bytes_into_buffer >= 7)
        {
			
            if (frames == 0) {
                samplerate = getSampleRate((b->ptr[2]&0x3c)>>2);
				channels = ((b->ptr[2] & 0x1) << 2) | ((b->ptr[3] & 0xc0) >> 6 );
            }

            frame_length = ((((unsigned int)b->ptr[3] & 0x3)) << 11)
                | (((unsigned int)b->ptr[4]) << 3) | (b->ptr[5] >> 5);            

			
            //AACD_TRACE("frame_length: %d, left_bytes: %d", frame_length, b->bytes_into_buffer);

            if (frame_length > b->bytes_into_buffer) {	
				if (b->at_eof)
					break;
                continue;
            }

			
			frames ++;
			t_framelength += frame_length;			
			
            advance_buffer(b, frame_length);
        }
    }

	if (sr)
		*sr = samplerate;

	if (channel_count)
		*channel_count = channels;
	
    frames_per_sec = (float)samplerate/1024.0f;
    if (frames != 0)
        bytes_per_frame = (float)t_framelength/(float)(frames*1000);
    
    *bitrate = (int)(8. * bytes_per_frame * frames_per_sec + 0.5);
    if (frames_per_sec != 0)
        *length = (float)frames/frames_per_sec;
    else
        *length = 1;

	AACD_TRACE("samplerate: %d, bitrate : %d, length : %f, frames: %d, total_bytes : %d ", samplerate,
			*bitrate, *length, frames,t_framelength);

    return 1;
}

static void advance_buffer(aac_buffer *b, int comsumed_bytes)
{
    b->file_offset += comsumed_bytes;
    b->ptr = b->ptr + comsumed_bytes;
    b->bytes_into_buffer -= comsumed_bytes;
	if (b->bytes_into_buffer < 0)
		b->bytes_into_buffer = 0;
}

static int fill_buffer(aac_buffer *b)
{	
	if (b->size == 0)
		return -1;

	if ( b->bytes_into_buffer > MIN_BUFFER || b->at_eof)
	{
		return b->bytes_into_buffer;
	}

	if ( b->bytes_into_buffer > 0 ) {		
		memmove(b->buffer, b->ptr,b->bytes_into_buffer*sizeof(unsigned char));
	}

	int bread = 0;
	bread = fread( b->buffer + b->bytes_into_buffer, 1, b->size- b->bytes_into_buffer, b->infile);
	AACD_TRACE("fread %d bytes from file, filepos: %d", bread,  b->file_offset);

	if (bread != (b->size - b->bytes_into_buffer))
		b->at_eof = 1;

	b->bytes_into_buffer += bread;
	b->ptr = b->buffer;
	b->end = b->ptr + b->bytes_into_buffer;

	return b->bytes_into_buffer;
}

static void zero_buffer(aac_buffer *b)
{
	if (!b)
	{
		return ;
	}
	b->bytes_into_buffer = 0;	

	if(b->buffer)
	{
		memset(b->buffer, 0, b->size);
		b->ptr = b->buffer;
		b->end = b->buffer;
	}

}

static int refill_buffer(aac_buffer *b, int filepos)
{
	zero_buffer(b);
	fseek(b->infile,filepos,SEEK_SET);
	b->file_offset = filepos;
	b->at_eof = 0;
	return fill_buffer(b);
}

static void seek_buffer(aac_buffer *b, int filepos)
{

	int bytes = filepos - b->file_offset;
	advance_buffer(b, bytes);
}

/**
 * 计算解码后的位置
 */
static long calPos(AACFileHandle* aacHandle, int msec)
{
	int filePos = -1;
	int totalTime = (int)(aacHandle->duration * 1000);
	if (msec > totalTime)
		msec = totalTime;
	long pos = -1;
	if(aacHandle->fileType == 2){
		int bitrate = aacHandle->bitrate;
		bitrate = (bitrate-0.5f)*1000.0f;
//		pos = ((msec-0.5)*bitrate *10)>>3;//mark
		pos = ((msec*bitrate*5)>>2) - ((bitrate*5)>>3);
	}else if(aacHandle->fileType == 1){//ADTS
		pos = (msec * aacHandle->bitrate)>>3;
	}else{	//RAW格式，不支持seek
		return -1;
	}
	return pos;
}

static int get_audio_track(const mp4ff_t *f)
{
	int i, rc;
    int numTracks = mp4ff_total_tracks(f);	
	
    for (i = 0; i < numTracks; i++)
    {
        if (mp4ff_get_track_type(f,i) == TRACK_AUDIO)
			return i;
		     
    }
    return -1;
}

static int get_audio_track(mp4ff_t *infile, tPVMP4AudioDecoderExternal * pExt,void * pMem)
{
    /* find AAC track */
    int i, rc;
    int numTracks = mp4ff_total_tracks(infile);	
	
    for (i = 0; i < numTracks; i++)
    {
        unsigned char *buff = NULL;
        uint32_t buff_size = 0; 

		mp4ff_get_decoder_config(infile, i, &buff, &buff_size);

		
		if (buff)
		{			
							
			pExt->pInputBuffer				= buff;
			pExt->inputBufferMaxLength		= buff_size;
			pExt->inputBufferCurrentLength	= buff_size;
			pExt->inputBufferUsedLength 	= 0;
			
			rc = PVMP4AudioDecoderConfig(pExt,pMem);
			free(buff);
			
			if (rc != SUCCESS )
				continue;
			return i;
		}
		     
    }
    return -1;
}

static long get_mp4_currentPosition(AACFileHandle* aacHandle)
{
	//加上对参数的检查
	long curPos = 0;
	curPos = aacHandle->duration*1000*aacHandle->sampleId/mp4ff_num_samples(aacHandle->infile, aacHandle->track);
	return curPos;
}

static int mp4_seekTo(AACFileHandle* aacHandle, jint ms){
	AACD_TRACE("mp4_seekTo");

	long samples =  mp4ff_num_samples(aacHandle->infile, aacHandle->track);	
	long sampleId = (long)(samples / aacHandle->duration * ms /1000) ;

	if (sampleId > samples )
		sampleId = samples;
	aacHandle->sampleId = sampleId;
	mp4ff_set_sample_position(aacHandle->infile, aacHandle->track, aacHandle->sampleId);
	zero_buffer(&(aacHandle->buffer));
	
	aacHandle->buffer.bytes_into_buffer = 0;
	aacHandle->buffer.at_eof = 0;
	
	return 0;
}

static uint32_t read_callback(void *user_data, void *buffer, uint32_t length)
{
    return fread(buffer, 1, length, (FILE*)user_data);
}

static uint32_t seek_callback(void *user_data, uint64_t position)
{
    return fseek((FILE*)user_data, position, SEEK_SET);
}
//=======================MP4音频处理相关方法  END=====================================



static int aacd_opencore_init(void **pext, int aacPlusEnabled)
{
	AACD_TRACE("aacd_opencore_init");

    AACDOpenCore *oc = (AACDOpenCore*) calloc( 1, sizeof(struct AACDOpenCore));

    tPVMP4AudioDecoderExternal *pExt = (tPVMP4AudioDecoderExternal*) calloc( 1, sizeof( tPVMP4AudioDecoderExternal ));
    oc->pMem = malloc( PVMP4AudioDecoderGetMemRequirements());	

    oc->pExt = pExt;

    pExt->desiredChannels           = 2;
    pExt->outputFormat              = OUTPUTFORMAT_16PCM_INTERLEAVED;
    pExt->repositionFlag            = false;
	if (aacPlusEnabled)
    	pExt->aacPlusEnabled            = TRUE;
	else
		pExt->aacPlusEnabled            = FALSE;

    Int err = PVMP4AudioDecoderInitLibrary(pExt, oc->pMem);

    if (err)
    {
        AACD_ERROR( "PVMP4AudioDecoderInitLibrary failed err=%d", err );

        free( pExt );
        free( oc->pMem );
        free( oc );

        oc = NULL;

        return -1;
    }

    (*pext) = oc;
    return 0;
}


static void aacd_opencore_destroy( void *ext )
{
    if ( !ext ) return;

	
    AACDOpenCore *oc = (AACDOpenCore*) ext;


    if (oc->pMem != NULL) free( oc->pMem );


	if (oc->pExt->pOutputBuffer != NULL) 
	{
		free(oc->pExt->pOutputBuffer);
		oc->pExt->pOutputBuffer = NULL;
	}


    if (oc->pExt != NULL) free( oc->pExt );


    free( oc );

}

static int aacd_opencore_start(void *ext, aac_buffer *b)
{
	AACD_TRACE("aacd_opencore_start");

    AACDOpenCore *oc = (AACDOpenCore*) ext;
    tPVMP4AudioDecoderExternal *pExt = oc->pExt;
#ifdef AAC_PLUS
    int16_t *iOutputBuf = (int16_t*)calloc(4096, sizeof(int16_t));
#else
    int16_t *iOutputBuf = (int16_t*)calloc(2048, sizeof(int16_t));
#endif

	if (iOutputBuf == NULL )
		return -1;
	
    pExt->remainderBits             = 0;
    pExt->frameLength               = 0;

    // prepare the first samples buffer:
    pExt->pOutputBuffer             = iOutputBuf;

#ifdef AAC_PLUS
    pExt->pOutputBuffer_plus        = &iOutputBuf[2048];
#else
    pExt->pOutputBuffer_plus 		= NULL;
#endif

    int32_t status = -1;
    int frameDecoded = 0;
    

    /* pre-init search adts sync */
    while ( pExt->frameLength == 0) {
		pExt->pInputBuffer              = b->ptr;
		pExt->inputBufferMaxLength      = b->bytes_into_buffer;
		pExt->inputBufferCurrentLength  = b->bytes_into_buffer;
		pExt->inputBufferUsedLength     = 0;
		pExt->remainderBits             = 0;

	/*
        status = PVMP4AudioDecoderConfig(pExt, oc->pMem);
        AACD_DEBUG( "start() Status[0]: %d, used bytes: %d", status, pExt->inputBufferUsedLength);		

        if (status != MP4AUDEC_SUCCESS) {
	*/				
		    status = PVMP4AudioDecodeFrame(pExt, oc->pMem);
            AACD_DEBUG( "start() Status[1]: %d, used bytes: %d, remainderbits: %d", status, pExt->inputBufferUsedLength,
				pExt->remainderBits );
			advance_buffer(b, pExt->inputBufferUsedLength);
			
            if (MP4AUDEC_SUCCESS == status) {
                AACD_DEBUG( "start() frameLength: %d\n", pExt->frameLength);
                frameDecoded = 1;				
                break;
            }
			
     //   } 	       
		
        if ( b->bytes_into_buffer <= 64)
        {
        	break;
        }
        
    }

    if (!frameDecoded)
    {	
    	status = PVMP4AudioDecodeFrame(pExt, oc->pMem);
		if (status != MP4AUDEC_SUCCESS) 
		{		
			return -1;
		}	

		advance_buffer(b, pExt->inputBufferUsedLength);
    }	

    int streamType  = -1;

	AACD_DEBUG( "audio object type: %d, extended audio obejct type: %d", pExt->audioObjectType, pExt->extendedAudioObjectType);
	
    if ((pExt->audioObjectType == MP4AUDIO_AAC_LC) ||
            (pExt->audioObjectType == MP4AUDIO_LTP))
    {
        streamType = AAC;
    }
    else if (pExt->audioObjectType == MP4AUDIO_SBR)
    {
        streamType = AACPLUS;
    }
    else if (pExt->audioObjectType == MP4AUDIO_PS)
    {
        streamType = ENH_AACPLUS;
    }

    AACD_DEBUG( "streamType=%d", streamType );

    if ((AAC == streamType) && (2 == pExt->aacPlusUpsamplingFactor))
    {
        AACD_INFO( "DisableAacPlus" );
        PVMP4AudioDecoderDisableAacPlus(pExt, oc->pMem);
    }
	
    oc->frameSamplesFactor = pExt->desiredChannels;

    oc->bytesleft = 0;
	
    //if (2 == pExt->aacPlusUpsamplingFactor) oc->frameSamplesFactor *= 2;

	AACD_TRACE("frameSamplesFactor : %d", oc->frameSamplesFactor );
	
    return 0;
}


static int open_opencore_aac_file(FILE* fileHandle, AACFileHandle *aacHandle)
{
	
	AACD_TRACE("open_opencore_aac_file");
	if(fileHandle == NULL || aacHandle == NULL)
		return -1;

	float length = 0;
	int bread = 0, fileread = 0;
	aac_buffer b;
	int bitrate = 0;
	int samplerate = 0;

	memset(&b, 0, sizeof(aac_buffer));
	b.infile = fileHandle;
	aacHandle->file = fileHandle;
	//取得文件长度
	fseek(fileHandle, 0, SEEK_END);
	fileread = (int)ftell(fileHandle);
	aacHandle->size = fileread;
	fseek(fileHandle, 0, SEEK_SET);

	b.buffer = (unsigned char*)malloc(MAX_BUFFER);
	if(b.buffer == NULL)
		return -1;

	b.size = MAX_BUFFER;
	zero_buffer(&b);
	fill_buffer(&b);

	int tagsize = 0;
	if (!memcmp(b.buffer, "ID3", 3))
	{
		tagsize = (b.buffer[6] << 21) | (b.buffer[7] << 14) |
			(b.buffer[8] <<  7) | (b.buffer[9] <<  0);
		tagsize += 10;
		advance_buffer(&b, tagsize);
	}

	int header_type = 1;
	int channels = 1;
	int aacPlusEnabled = 1;
	if ( !memcmp(b.ptr, "ADIF", 4) )
	{
		AACD_TRACE("adif");
		int skip_size = (b.buffer[4] & 0x80) ? 9 : 0;
		int br = ((unsigned int)(b.buffer[4 + skip_size] & 0x0F)<<19) |
			((unsigned int)b.buffer[5 + skip_size]<<11) |
			((unsigned int)b.buffer[6 + skip_size]<<3) |
			((unsigned int)b.buffer[7 + skip_size] & 0xE0);

		length = (float)fileread;
		length = ((float)length*8.f)/(br) + 0.5f;

		bitrate = (int)((float)br/1000.0f + 0.5f);
		header_type = 2;
	} else {
		/* seek to first adts sync */		
		int sync = 0;
		while( b.bytes_into_buffer >= 2 ) {
			if (!((b.ptr[0] == 0xFF)&&((b.ptr[1] & 0xF6) == 0xF0))) {
				advance_buffer(&b, 1);
			} else {
				sync = 1;
				break;
			}
		}

		// fail to seek adts sync
		if (!sync)
		{
			free(b.buffer);
			return -1;
		} 

		long curfilepos = b.file_offset;
		AACD_TRACE("adts");
		adts_parse(&b, &bitrate, &samplerate, &channels, &length);
		header_type = 1;
		fseek(b.infile, curfilepos, SEEK_SET);		
		zero_buffer(&b);
		b.at_eof = 0;
		b.file_offset = curfilepos;
		fill_buffer(&b);

		AACD_TRACE("filepos: %d, b[0]: %d, b[1]: %d", (int)curfilepos, (int)b.ptr[0], (int)b.ptr[1]);

		if (samplerate <= 24000  )
		{
			aacPlusEnabled = 0;
		}
	}
	
	int32_t status = -1;
	/*
	int configlen = b.bytes_into_buffer;
	uint8_t audioObjectType;
	uint8_t samplingRateIndex = 0;	
	
	status = GetActualAacConfig(b.ptr,&audioObjectType,&configlen,&samplingRateIndex,(uint32_t*)&channels);

	if (status)
	{
		free(b.buffer);
		return -1;
	}

	samplerate = getSampleRate(samplingRateIndex);	

	*/




	status = aacd_opencore_init( (void **)(&aacHandle->oc), aacPlusEnabled );
	if(status)
	{
		free(b.buffer);
		return -1;
	}

	
	tPVMP4AudioDecoderExternal * pExt = aacHandle->oc->pExt;
	void *pMem = aacHandle->oc->pMem;

	status = aacd_opencore_start(aacHandle->oc, &b);
	if(status < 0)
	{
		free(b.buffer);		
		return -1;
	} 	

	samplerate = pExt->samplingRate;

	int upsamplingFactor = pExt->aacPlusUpsamplingFactor;	
	
	status = PVMP4SetAudioConfig(pExt,pMem,upsamplingFactor,samplerate,pExt->encodedChannels,
				(tMP4AudioObjectType)pExt->audioObjectType);
/*

#ifdef AAC_PLUS
    int16_t *iOutputBuf = (int16_t*)calloc(4096, sizeof(int16_t));
#else
    int16_t *iOutputBuf = (int16_t*)calloc(2048, sizeof(int16_t));
#endif
    pExt->remainderBits             = 0;
    pExt->frameLength               = 0;

    // prepare the first samples buffer:
    pExt->pOutputBuffer             = iOutputBuf;

#ifdef AAC_PLUS
    pExt->pOutputBuffer_plus        = &iOutputBuf[2048];
#else
    pExt->pOutputBuffer_plus 		= NULL;
#endif

	pExt->pInputBuffer              = b.ptr;
	pExt->inputBufferMaxLength      = b.bytes_into_buffer;
	pExt->inputBufferCurrentLength  = b.bytes_into_buffer;
	pExt->inputBufferUsedLength     = 0;
	pExt->remainderBits             = 0;	
	
	int upsamplingFactor = 1;	
	
	status = PVMP4SetAudioConfig(pExt,pMem,upsamplingFactor,samplerate,channels,(tMP4AudioObjectType)audioObjectType);
	
	aacHandle->oc->frameSamplesFactor = pExt->desiredChannels;
	if (2 == pExt->aacPlusUpsamplingFactor) 
		aacHandle->oc->frameSamplesFactor *= 2;
*/	
	aacHandle->channelNum = pExt->desiredChannels;
	aacHandle->buffer = b;	
	aacHandle->bitrate = bitrate;
	aacHandle->duration = length;
	aacHandle->fileType = header_type;
	aacHandle->samplerate = samplerate;
	aacHandle->status = AAC_STATUS_READY;

	AACD_TRACE("bitrate: %d ; duration : %f ; samplerate : %d ; channel : %d", bitrate, length,
			samplerate, pExt->encodedChannels);

	
	return 0;
}

static int open_opencore_mp4_file(FILE* fileHandle, AACFileHandle* aacHandle)
{
	AACD_TRACE("open_opencore_mp4_file");

	int track = 0;
	unsigned long samplerate = 0;
	unsigned char channels = 0;
	void *sample_buffer = NULL;

	mp4ff_t *infile = NULL;
	long sampleId = 0, numSamples = 0;

	aac_buffer aacBuf;
	
	/* for gapless decoding */
	unsigned int useAacLength = 1;
	unsigned int initial = 1;
	unsigned int framesize = 0;
	unsigned long timescale = 0;

	memset(&aacBuf, 0, sizeof(aacBuf));
	/* initialise the callback structure */
	mp4ff_callback_t *mp4cb = (mp4ff_callback_t *)malloc(sizeof(mp4ff_callback_t));
	if(mp4cb == NULL){
		return -1;
	}

	mp4cb->read = read_callback;
	mp4cb->seek = seek_callback;
	mp4cb->user_data = fileHandle;

	infile = mp4ff_open_read(mp4cb);

	if (!infile){
		//error
		free(mp4cb);
		return -1;
	}

	track = get_audio_track(infile);
	if (track == -1) 
	{
		free(mp4cb);
		mp4ff_close(infile);
		return -1;
	}	

	samplerate = mp4ff_get_sample_rate(infile, track);
	channels = mp4ff_get_channel_count(infile, track);

	timescale = mp4ff_time_scale(infile, track);
	float duration = (float)mp4ff_get_track_duration_use_offsets(infile,track);
	float seconds = duration / timescale;
	/*
	long samples = mp4ff_num_samples(infile, track);

	AACD_TRACE("samples: %d", samples);
	float seconds = (float)samples *(float)(framesize-1.0)/samplerate;
	*/
	uint32_t bitrate = mp4ff_get_avg_bitrate(infile, track) / 1000;
	int aacPlusEnabled = 1;
	if (samplerate <= 24000  )
	{
		aacPlusEnabled = 0;
	}

	int status = aacd_opencore_init( (void **)(&aacHandle->oc), aacPlusEnabled );
	if(status)
	{
		free(mp4cb);
		mp4ff_close(infile);
		return -1;
	}
	
	tPVMP4AudioDecoderExternal * pExt = aacHandle->oc->pExt;
	void *pMem = aacHandle->oc->pMem;



	do{
		unsigned char *buff = NULL;
    	uint32_t buff_size = 0; 
		int rc = -1;
		mp4ff_get_decoder_config(infile, track, &buff, &buff_size);

		if (buff)
		{			
							
			pExt->pInputBuffer				= buff;
			pExt->inputBufferMaxLength		= buff_size;
			pExt->inputBufferCurrentLength	= buff_size;
			pExt->inputBufferUsedLength 	= 0;
			
			rc = PVMP4AudioDecoderConfig(pExt,pMem);
			free(buff);					
		}

		if (rc != SUCCESS )
		{
			free(mp4cb);
			mp4ff_close(infile);
			return -1;
		}
	}while(0);
	
	int audiotype = mp4ff_get_audio_type(infile,track);
	AACD_TRACE("mp4ff audiotype: %d", audiotype);
	
	tDec_Int_File *  pVars = (tDec_Int_File *)aacHandle->oc->pMem;	
	AACD_TRACE("audiotype: %d  ExtendedAudioObjectType : %d", pVars->mc_info.audioObjectType, 
		pVars->mc_info.ExtendedAudioObjectType);

	if (pExt->samplingRate != samplerate ) 
	{
		
		AACD_TRACE("samplingRate is different");
		samplerate = pExt->samplingRate;
		//status = PVMP4SetAudioConfig(pExt,pMem,pVars->mc_info.upsamplingFactor,samplerate,pVars->mc_info.nch,
		//		(tMP4AudioObjectType)pVars->mc_info.ExtendedAudioObjectType);

		//AACD_TRACE("status: %d" , status);
		//pExt->samplingRate = samplerate;
		//pVars->mc_info.sampling_rate_idx = getSampleRateIndex(samplerate);
		//pVars->prog_config.sampling_rate_idx = getSampleRateIndex(samplerate);
	}	
	
	/*
	track = get_audio_track(infile, pExt, pMem);
	AACD_TRACE("track: %d\n", track);

	if (track == -1) 
	{
		free(mp4cb);
		mp4ff_close(infile);
		return -1;
	}
	*/
	
	
	unsigned char *pb = (unsigned char*)malloc(MAX_BUFFER);
	memset(pb, 0, MAX_BUFFER);

	aacBuf.infile = fileHandle;
	aacBuf.buffer = pb;
	aacBuf.size = MAX_BUFFER;
	
//	int upsamplingFactor = 1;
//	if (upsamplingFactor < pExt->aacPlusUpsamplingFactor)
//		upsamplingFactor = pExt->aacPlusUpsamplingFactor;

	
#ifdef AAC_PLUS
    int16_t *iOutputBuf = (int16_t*)calloc(4096, sizeof(int16_t));
#else
    int16_t *iOutputBuf = (int16_t*)calloc(2048, sizeof(int16_t));
#endif
    pExt->remainderBits             = 0;
    pExt->frameLength               = 0;

    // prepare the first samples buffer:
    pExt->pOutputBuffer             = iOutputBuf;

#ifdef AAC_PLUS
    pExt->pOutputBuffer_plus        = &iOutputBuf[2048];
#else
    pExt->pOutputBuffer_plus 		= NULL;
#endif

//	status = PVMP4SetAudioConfig(pExt,pMem,upsamplingFactor,samplerate,channels,(tMP4AudioObjectType)audiotype);

//	AACD_TRACE("status: %d", status);
//	if (status != SUCCESS)
//	{
//		free(mp4cb);
//		free(pb);
//		return -1;
//	}

	aacHandle->oc->frameSamplesFactor = aacHandle->oc->pExt->desiredChannels;

	aacHandle->oc->bytesleft = 0;

	AACD_TRACE("aacPlusUpsamplingFactor: %d, frameSamplesfactor: %d, aacPlusEnable: %d", pExt->aacPlusUpsamplingFactor,
		aacHandle->oc->frameSamplesFactor, pExt->aacPlusEnabled);
	framesize = pExt->frameLength;	

	
	
	aacHandle->bitrate = (int)(bitrate); //(int)(infile->track[0]->avgBitrate >> 10);
	aacHandle->duration = seconds;
	aacHandle->samplerate = samplerate;
	aacHandle->channelNum = pExt->desiredChannels;
	aacHandle->file = fileHandle;
	aacHandle->track = track;
	aacHandle->infile = infile;
	aacHandle->sampleId = 1;
	aacHandle->mp4cb = mp4cb;
	aacHandle->status = AAC_STATUS_READY;

	int32_t offset;
    offset = mp4ff_sample_to_offset(infile, track, 1);
	zero_buffer(&aacBuf);	
	fseek(fileHandle, offset, SEEK_SET);
	aacBuf.file_offset = offset;
	fill_buffer(&aacBuf);	
	aacHandle->buffer = aacBuf;	
	
	AACD_TRACE("bitrate: %d\n", aacHandle->bitrate);
	AACD_TRACE("duration: %f\n", aacHandle->duration);
	AACD_TRACE("samplerate: %d\n", aacHandle->samplerate);
	AACD_TRACE("channel: %d\n", pExt->encodedChannels);

	return 0;
}

enum {
	MP4AUDEC_SUCCESS_BREAK = 40
};

/*
static int write_audio_16bit(FILE *outfile, void *sample_buffer,
                             unsigned int samples)
{
	if (!outfile)
		return 0;
    int ret;
    unsigned int i;
    short *sample_buffer16 = (short*)sample_buffer;
    char *data =(char *) malloc(samples* 16 *sizeof(char)/8);
	
    for (i = 0; i < samples; i++)
    {
        data[i*2] = (char)(sample_buffer16[i] & 0xFF);
        data[i*2+1] = (char)((sample_buffer16[i] >> 8) & 0xFF);
    }

    ret = fwrite(data, samples, 2, outfile);

    if (data) free(data);

    return ret;
} */


static int aacd_opencore_decode( void *ext, aac_buffer *b, int16_t *out, int& offset, int maxsize)
{
    AACDOpenCore *oc = (AACDOpenCore*) ext;
    tPVMP4AudioDecoderExternal *pExt = oc->pExt;

    pExt->pInputBuffer              = b->ptr;
    pExt->inputBufferMaxLength      = b->bytes_into_buffer;
    pExt->inputBufferCurrentLength  = b->bytes_into_buffer;
    pExt->inputBufferUsedLength     = 0;

	int16_t *iOutbuf = pExt->pOutputBuffer;
    int32_t status = PVMP4AudioDecodeFrame( pExt, oc->pMem );
	int iframeLen = pExt->frameLength;
	
	if (status == MP4AUDEC_SUCCESS) 
	{


#ifdef AAC_PLUS
		if (2 == pExt->aacPlusUpsamplingFactor)
		{
			
			iframeLen *= 2;
			if (1 == pExt->desiredChannels) 
			{
				memcpy(&iOutbuf[1024], &iOutbuf[2048], (iframeLen * 2));
			}	
		}
#endif

		iframeLen *= oc->frameSamplesFactor;
		oc->bytesleft = 0;
		if ( (maxsize - offset)  < iframeLen ) 
		{
			memcpy(out + offset, iOutbuf, (maxsize - offset)  * sizeof(int16_t));
			oc->bytesleft = iframeLen - (maxsize - offset);
			memmove(iOutbuf, iOutbuf + (maxsize - offset), oc->bytesleft  * sizeof(int16_t));
			return MP4AUDEC_SUCCESS_BREAK;
		}		

		memcpy(out + offset, iOutbuf, iframeLen  * sizeof(int16_t));
		offset += iframeLen ;
	}

	
    return status;
}

static int read_opencore_aac_samples(JNIEnv *env, AACFileHandle* aacHandle, jshortArray buffer, jint size)
{

	if(aacHandle == NULL || size <=0){
		return 0;
	}

	if(fill_buffer(&aacHandle->buffer) <= 0)
	{
		return 0;
	}

	int len = 0;
	tPVMP4AudioDecoderExternal *pExt = aacHandle->oc->pExt;
	jshort * target_out = env->GetShortArrayElements(buffer, NULL);
	jshort * target = target_out;
	if (aacHandle->oc->bytesleft > 0) {
		memcpy(target_out, pExt->pOutputBuffer, aacHandle->oc->bytesleft  * sizeof(int16_t));
		target += (aacHandle->oc->bytesleft);
		len = aacHandle->oc->bytesleft;
		size -= aacHandle->oc->bytesleft;
	}
	int times = 0;
	int pos = 0;
	int bytesconsumed = 0, status= MP4AUDEC_SUCCESS;
	aac_buffer *pInputBuffer = &(aacHandle->buffer);
	while( pos < size ){
		
		if (aacHandle->status == AAC_STATUS_SEEKING) 
			{times = 0; goto decode_aac_fail;}
		
		status = aacd_opencore_decode( aacHandle->oc, pInputBuffer, target, pos, size);				
		
		bytesconsumed =  pExt->inputBufferUsedLength;		
		
		if (status == MP4AUDEC_SUCCESS) {
			times++;			
			aacHandle->sampleId += 1;			
			advance_buffer(pInputBuffer, bytesconsumed);

		} 

		else if (status == MP4AUDEC_SUCCESS_BREAK) {
			times++;
			aacHandle->sampleId += 1;
			advance_buffer(pInputBuffer, bytesconsumed);
			break;
		}

		else if (bytesconsumed == 0) {
			break;
		}

		else if (bytesconsumed > 0){
			aacHandle->sampleId += 1;
			advance_buffer(pInputBuffer, bytesconsumed);
		}

		int ret = fill_buffer(pInputBuffer);
		if (ret <= 0)
			break;
		
	}
	
decode_aac_fail:	
	env->ReleaseShortArrayElements(buffer, target_out, 0);
	AACD_TRACE("times : %d, pos %d, size %d", times, pos, size);
	return (len + pos);

}

static int is_mp4_read_finished(AACFileHandle* aacHandle)
{
	int total_samples = mp4ff_num_samples(aacHandle->infile, aacHandle->track);
	return aacHandle->sampleId >= total_samples? 1: 0;
}

static int is_aac_read_finished(AACFileHandle* aacHandle)
{
	return feof(aacHandle->file) ? 1: 0;
}

JNIEXPORT jint JNICALL Java_cn_kuwo_base_codec_NativeAACDecoder_isReadFinished(JNIEnv *env, jobject obj, jint handle)
{
	 AACFileHandle* aacHandle = aac_handles[handle];
	 if (!aacHandle)
		return 1;

	if (aacHandle->mp4file)
		return is_mp4_read_finished(aacHandle);
	else 
		return is_aac_read_finished(aacHandle);
}


//FILE * fp = NULL;
static int read_opencore_mp4_samples(JNIEnv *env, AACFileHandle* aacHandle, jshortArray buffer, jint size)
{
	if(aacHandle == NULL || size <=0){
		return 0;
	}

	if(fill_buffer(&aacHandle->buffer) <= 0)
	{
		return 0;
	}
	
	int pos =0;
	int times = 0;	
	int bytesconsumed = 0, status= MP4AUDEC_SUCCESS;		
	aac_buffer *pInputBuff = &(aacHandle->buffer);
	
	int filepos = 0;
	int framesize = 0;	
	
	int len = 0;
	jshort * target_out = env->GetShortArrayElements(buffer, NULL);
	jshort * target = target_out;
	if (aacHandle->oc->bytesleft > 0) {
		memcpy(target_out, aacHandle->oc->pExt->pOutputBuffer, aacHandle->oc->bytesleft  * sizeof(int16_t));
		target += (aacHandle->oc->bytesleft);
		len = aacHandle->oc->bytesleft;
		size -= aacHandle->oc->bytesleft;
	}

	int total_samples = mp4ff_num_samples(aacHandle->infile, aacHandle->track);
	
	while (pos < size && aacHandle->sampleId < total_samples)
	{
		if (aacHandle->status == AAC_STATUS_SEEKING)
			{times = 0; goto decode_mp4_fail;}
		
		filepos = mp4ff_sample_to_offset(aacHandle->infile,aacHandle->track,aacHandle->sampleId);
		framesize = mp4ff_audio_frame_size(aacHandle->infile,aacHandle->track,aacHandle->sampleId);
		if (pInputBuff->file_offset > filepos || pInputBuff->ptr + (filepos - pInputBuff->file_offset) > pInputBuff->end )
		{
			if ( refill_buffer(pInputBuff,filepos) <= 0 )
			{
				break;
			}
			
		}
		
		seek_buffer(pInputBuff,filepos);

		if (pInputBuff->bytes_into_buffer == 0)
			break;
		
		status = aacd_opencore_decode( aacHandle->oc, pInputBuff, target, pos, size);
		
		//AACD_TRACE("aacd_opencore_decode error : %d", status);
				
		bytesconsumed =  aacHandle->oc->pExt->inputBufferUsedLength;
		
		if (status == MP4AUDEC_SUCCESS) {
			times++;			
			aacHandle->sampleId += 1;			
			advance_buffer(pInputBuff, bytesconsumed);
		} 

		else if (status == MP4AUDEC_SUCCESS_BREAK) {
			times++;
			aacHandle->sampleId += 1;
			advance_buffer(pInputBuff, bytesconsumed);
			break;
		}

		else if (bytesconsumed == 0) {
			break;
		}

		else if (bytesconsumed > 0){
			aacHandle->sampleId += 1;
			advance_buffer(pInputBuff, bytesconsumed);
		}
		
		
	}	

decode_mp4_fail:
	env->ReleaseShortArrayElements(buffer, target_out, 0);
	AACD_TRACE("times : %d, pos %d, size %d", times, pos, size);
	return (len + pos);
}
