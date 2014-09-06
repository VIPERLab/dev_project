//
//  AudioFormatConvert.mm
//  KwSing
//
//  Created by 永杰 单 on 12-7-27.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "AudioFormatConvert.h"
#include "AutoLock.h"
#include "MessageManager.h"
#include "IMediaSaveProcessObserver.h"

static pthread_mutex_t S_STATE_LOCK;
static pthread_cond_t S_STATE_CHANGED;
static ThreadStates S_Thread_State;

//static UInt64 s_un_total_packs = 0;
//static UInt64 s_un_cur_packs = 0;

void ThreadStateInitalize(){
    int n_ret(0);
    assert([NSThread isMainThread]);
    
    n_ret = pthread_mutex_init(&S_STATE_LOCK, NULL);
    assert(0 == n_ret);
    
    n_ret = pthread_cond_init(&S_STATE_CHANGED, NULL);
    assert(0 == n_ret);
    S_Thread_State = STATE_THREAD_DONE;
}

void ThreadStateBeginInterruption(){
    assert([NSThread isMainThread]);
    
    int n_ret = pthread_mutex_lock(&S_STATE_LOCK);
    assert(0 == n_ret);
    
    if (STATE_THREAD_RUNNING == S_Thread_State) {
        S_Thread_State = STATE_THREAD_PAUSED;
    }
    
    n_ret = pthread_mutex_unlock(&S_STATE_LOCK);
    assert(0 == n_ret);
}

void ThreadStateEndInterruption(){
    assert([NSThread isMainThread]);
    
    int n_ret = pthread_mutex_lock(&S_STATE_LOCK);
    assert(0 == n_ret);
    
    if (STATE_THREAD_PAUSED) {
        S_Thread_State = STATE_THREAD_RUNNING;
        n_ret = pthread_cond_signal(&S_STATE_CHANGED);
        assert(0 == n_ret);
    }
    
    n_ret = pthread_mutex_unlock(&S_STATE_LOCK);
    assert(0 == n_ret);
}

void ThreadStateSetRunning(){
    int n_ret = pthread_mutex_lock(&S_STATE_LOCK);
    assert(0 == n_ret);
    
    assert(STATE_THREAD_DONE == S_Thread_State);
    S_Thread_State = STATE_THREAD_RUNNING;
    
    n_ret = pthread_mutex_unlock(&S_STATE_LOCK);
    assert(0 == n_ret);
}

Boolean IsThreadStatePaused(){
    Boolean b_thread_paused = false;
    
    int n_ret = pthread_mutex_lock(&S_STATE_LOCK);
    assert(0 == n_ret);
    
    assert(STATE_THREAD_DONE != S_Thread_State);
    
    while (STATE_THREAD_PAUSED == S_Thread_State) {
        n_ret = pthread_cond_wait(&S_STATE_CHANGED, &S_STATE_LOCK);
        assert(0 == n_ret);
        b_thread_paused = true;
    }
    
    assert(STATE_THREAD_RUNNING == S_Thread_State);
    
    n_ret = pthread_mutex_unlock(&S_STATE_LOCK);
    assert(0 == n_ret);
    
    return b_thread_paused;
}

void ThreadStateSetDone(){
    int n_ret = pthread_mutex_lock(&S_STATE_LOCK);
    assert(0 == n_ret);
    
    assert(STATE_THREAD_DONE != S_Thread_State);
    S_Thread_State = STATE_THREAD_DONE;
    
    n_ret = pthread_mutex_unlock(&S_STATE_LOCK);
    assert(0 == n_ret);
}

static OSStatus DecodeDataProc(AudioConverterRef audio_converter, UInt32* un_num_data_packs, AudioBufferList* audio_data, AudioStreamPacketDescription** out_data_desc, void* in_usr_data){
    AudioFileIORef audio_file_io = (AudioFileIORef)in_usr_data;
    OSStatus err_status;
    UInt32 un_max_packs = audio_file_io->un_src_buf_size / audio_file_io->un_src_size_per_pack;
    if (un_max_packs < *un_num_data_packs) {
        *un_num_data_packs = un_max_packs;
    }
    
    UInt32 un_out_num_bytes = 0;
    err_status = AudioFileReadPackets(audio_file_io->souce_file_id, false, &un_out_num_bytes, audio_file_io->pack_format, audio_file_io->sn_src_file_pos, un_num_data_packs, audio_file_io->src_buf);
    
//    s_un_cur_packs += *un_num_data_packs;
//    if(s_un_total_packs > s_un_cur_packs && (0 == s_un_cur_packs % 100)){
//        SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveProgressChanged, 0.3 * s_un_cur_packs / s_un_total_packs);
//    }
    
    if (ERR_END_OF_FILE == err_status) {
        err_status = noErr;
    }
    if (err_status) {
        return err_status;
    }
    
    audio_file_io->sn_src_file_pos += *un_num_data_packs;
    audio_data->mBuffers[0].mData = audio_file_io->src_buf;
    audio_data->mBuffers[0].mDataByteSize = un_out_num_bytes;
    audio_data->mBuffers[0].mNumberChannels = audio_file_io->src_format.mChannelsPerFrame;
    
    if (out_data_desc) {
        if (audio_file_io->pack_format) {
            *out_data_desc = audio_file_io->pack_format;
        }else {
            *out_data_desc = NULL;
        }
    }
    
    return err_status;
}

static void ReadCookie(AudioFileID src_file_id, AudioConverterRef audio_converter){
    UInt32 un_cookie_size = 0;
    OSStatus ret_status = AudioFileGetPropertyInfo(src_file_id, kAudioFilePropertyMagicCookieData, &un_cookie_size, NULL);
    if ((noErr == ret_status) && (0 != un_cookie_size)) {
        char* str_cookie = new char[un_cookie_size];
        ret_status = AudioFileGetProperty(src_file_id, kAudioFilePropertyMagicCookieData, &un_cookie_size, str_cookie);
        if (noErr == ret_status) {
            AudioConverterSetProperty(audio_converter, kAudioConverterCompressionMagicCookie, un_cookie_size, str_cookie);
        }
        
        delete [] str_cookie;
        str_cookie = NULL;
    }
}

static void WriteCookie(AudioConverterRef audio_converter, AudioFileID dest_file_id){
    UInt32 un_cookie_size = 0;
    OSStatus ret_status = AudioConverterGetPropertyInfo(audio_converter, kAudioConverterDecompressionMagicCookie, &un_cookie_size, NULL);
    if (noErr == ret_status) {
        char* str_cookie = new char[un_cookie_size];
        ret_status = AudioConverterGetProperty(audio_converter, kAudioConverterDecompressionMagicCookie, &un_cookie_size, str_cookie);
        if (noErr == ret_status) {
            AudioFileSetProperty(dest_file_id, kAudioFilePropertyMagicCookieData, un_cookie_size, str_cookie);
        }
        
        delete [] str_cookie;
        str_cookie = NULL;
    }
}

static void WriteDestChannelLayout(AudioConverterRef audio_converter, AudioFileID src_file_id, AudioFileID dest_file_id){
    UInt32 un_layout_size(0);
    bool b_layout_from_converter(true);
    
    OSStatus ret_status = AudioConverterGetPropertyInfo(audio_converter, kAudioConverterOutputChannelLayout, &un_layout_size, NULL);
    if (ret_status || (0 == un_layout_size)) {
        ret_status = AudioFileGetProperty(src_file_id, kAudioFilePropertyChannelLayout, &un_layout_size, NULL);
        b_layout_from_converter = false;
    }
    if ((noErr == ret_status) && (0 != un_layout_size)) {
        char* str_layout = new char[un_layout_size];
        if (b_layout_from_converter) {
            ret_status = AudioConverterGetProperty(audio_converter, kAudioConverterOutputChannelLayout, &un_layout_size, str_layout);
        }else {
            ret_status = AudioFileGetProperty(dest_file_id, kAudioFilePropertyChannelLayout, &un_layout_size, str_layout);
        }
        
        if (noErr == ret_status) {
            AudioFileSetProperty(dest_file_id, kAudioFilePropertyChannelLayout, un_layout_size, str_layout);
        }
        
        delete[] str_layout;
        str_layout = NULL;
    }
}

static void WritePackTableInfo(AudioConverterRef audio_converter, AudioFileID dest_file_id){
    UInt32 is_writable(0);
    UInt32 un_data_size(0);
    OSStatus ret_status = AudioFileGetPropertyInfo(dest_file_id, kAudioFilePropertyPacketTableInfo, &un_data_size, &is_writable);
    if ((noErr == ret_status) && is_writable) {
        AudioConverterPrimeInfo prime_info;
        un_data_size = sizeof(prime_info);
        
        ret_status = AudioConverterGetProperty(audio_converter, kAudioConverterPrimeInfo, &un_data_size, &prime_info);
        if (noErr == ret_status) {
            AudioFilePacketTableInfo pack_table_info;
            un_data_size = sizeof(pack_table_info);
            ret_status = AudioFileGetProperty(dest_file_id, kAudioFilePropertyPacketTableInfo, &un_data_size, &pack_table_info);
            if (noErr == ret_status) {
                UInt64 un_total_frames = pack_table_info.mNumberValidFrames + pack_table_info.mPrimingFrames + pack_table_info.mRemainderFrames;
                
                pack_table_info.mPrimingFrames = prime_info.leadingFrames;
                pack_table_info.mRemainderFrames = prime_info.trailingFrames;
                pack_table_info.mNumberValidFrames = un_total_frames - pack_table_info.mPrimingFrames - pack_table_info.mRemainderFrames;
                
                AudioFileSetProperty(dest_file_id, kAudioFilePropertyPacketTableInfo, sizeof(pack_table_info), &pack_table_info);
            }
        }
    }
}

bool CAudioFormatConvert::IsAACHardwareDecoderAvailable(){
    bool b_aac_decoder_available = false;
    UInt32 un_decoder_specify = kAudioFormatMPEG4AAC;
    UInt32 un_size = 0;
    
    OSStatus status_get_property = AudioFormatGetPropertyInfo(kAudioFormatProperty_Decoders, sizeof(un_decoder_specify), &un_decoder_specify, &un_size);
    if (status_get_property) {
        return false;
    }
    
    UInt32 un_num_decode_type = un_size / sizeof(AudioClassDescription);
    AudioClassDescription decode_desc[un_num_decode_type];
    
    status_get_property = AudioFormatGetProperty(kAudioFormatProperty_Decoders, sizeof(un_decoder_specify), &un_decoder_specify, &un_size, decode_desc);
    if (status_get_property) {
        return false;
    }
    
    for (UInt32 un_itr = 0; un_itr < un_num_decode_type; ++un_itr) {
        if ((kAudioFormatMPEG4AAC == decode_desc[un_itr].mSubType) && (kAppleHardwareAudioCodecManufacturer == decode_desc[un_itr].mManufacturer)) {
            b_aac_decoder_available = true;
        }
    }
    
    return b_aac_decoder_available;
}

bool CAudioFormatConvert::IsMP3HardwareDecoderAvailable(){
    bool b_mp3_decoder_available = false;
    UInt32 un_decoder_specify = kAudioFormatMPEGLayer3;
    UInt32 un_size = 0;
    
    OSStatus status_get_property = AudioFormatGetPropertyInfo(kAudioFormatProperty_Decoders, sizeof(un_decoder_specify), &un_decoder_specify, &un_size);
    if (status_get_property) {
        return false;
    }
    
    UInt32 un_num_decode_type = un_size / sizeof(AudioClassDescription);
    AudioClassDescription decode_desc[un_num_decode_type];
    
    status_get_property = AudioFormatGetProperty(kAudioFormatProperty_Decoders, sizeof(un_decoder_specify), &un_decoder_specify, &un_size, decode_desc);
    
    if (status_get_property) {
        return false;
    }
    
    for (UInt32 un_itr = 0; un_itr < un_num_decode_type; ++un_itr) {
        if ((kAudioFormatMPEGLayer3 == decode_desc[un_itr].mSubType) && (kAppleHardwareAudioCodecManufacturer == decode_desc[un_itr].mManufacturer)) {
            b_mp3_decoder_available = true;
        }
    }
    
    return b_mp3_decoder_available;
}

OSStatus CAudioFormatConvert::ConvertFormatToPCM(id infile_outfie, OSType output_format, Float64 f_out_sample_rate){
//    s_un_total_packs = 0;
//    s_un_cur_packs = 0;
    unsigned long un_convert_length(0);
    unsigned long un_convert_cur_pos(0);
    
    NSArray* arry_io_file_path = (NSArray*)infile_outfie;
    un_convert_length = [(NSString*)[arry_io_file_path objectAtIndex:2] intValue];
    
    AudioFileID src_file_id = 0;
    AudioFileID dest_file_id = 0;
    AudioConverterRef audio_converter = NULL;
    Boolean b_resume_from_interruption = true;
    
    AudioStreamBasicDescription src_format, dest_format;
    AudioFileIO audio_file_io = {};
    char* output_buf = NULL;
    AudioStreamPacketDescription* output_pack_desc = NULL;
    
    OSStatus ret_status = noErr;
    
    assert(![NSThread isMainThread]);
    
    ThreadStateSetRunning();
    
    AudioFileOpenURL((CFURLRef)[NSURL fileURLWithPath : (NSString*)[arry_io_file_path objectAtIndex:0]], kAudioFileReadPermission, 0, &src_file_id);
    assert(src_file_id);
    UInt32 un_format_size = sizeof(src_format);
    AudioFileGetProperty(src_file_id, kAudioFilePropertyDataFormat, &un_format_size, &src_format);
    dest_format.mSampleRate = (0 == f_out_sample_rate) ? src_format.mSampleRate : f_out_sample_rate;
    dest_format.mFormatID = output_format;
    dest_format.mChannelsPerFrame = src_format.mChannelsPerFrame;
    dest_format.mBitsPerChannel = 16;
    dest_format.mBytesPerPacket = 2 * dest_format.mChannelsPerFrame;
    dest_format.mBytesPerFrame = 2 * dest_format.mChannelsPerFrame;
    dest_format.mFramesPerPacket = 1;
    dest_format.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
    
    AudioConverterNew(&src_format, &dest_format, &audio_converter);
    
    ReadCookie(src_file_id, audio_converter);
    
    un_format_size = sizeof(src_format);
    AudioConverterGetProperty(audio_converter, kAudioConverterCurrentInputStreamDescription, &un_format_size, &src_format);
    un_format_size = sizeof(dest_format);
    AudioConverterGetProperty(audio_converter, kAudioConverterCurrentOutputStreamDescription, &un_format_size, &dest_format);
    
    UInt32 un_can_resume = 0;
    un_format_size = sizeof(un_can_resume);
    ret_status = AudioConverterGetProperty(audio_converter, kAudioConverterPropertyCanResumeFromInterruption, &un_format_size, &un_can_resume);
    if (noErr == ret_status) {
        if (0 == un_can_resume) {
            b_resume_from_interruption = false;
        }
    }else {
        ret_status = noErr;
    }
    
    AudioFileCreateWithURL((CFURLRef)[NSURL fileURLWithPath : (NSString*)[arry_io_file_path objectAtIndex:1]], kAudioFileWAVEType, &dest_format, kAudioFileFlags_EraseFile, &dest_file_id);
    
    audio_file_io.souce_file_id = src_file_id;
    audio_file_io.un_src_buf_size = 65536;
    audio_file_io.src_buf = new char[audio_file_io.un_src_buf_size];
    audio_file_io.sn_src_file_pos = 0;
    audio_file_io.src_format = src_format;
    
    if (0 == src_format.mBytesPerPacket) {
        un_format_size = sizeof(audio_file_io.un_src_size_per_pack);
        AudioFileGetProperty(src_file_id, kAudioFilePropertyPacketSizeUpperBound, &un_format_size, &audio_file_io.un_src_size_per_pack);
        audio_file_io.un_packs_per_read = audio_file_io.un_src_buf_size / audio_file_io.un_src_size_per_pack;
        audio_file_io.pack_format = new AudioStreamPacketDescription[audio_file_io.un_packs_per_read];
    }else {
        audio_file_io.un_src_size_per_pack = src_format.mBytesPerPacket;
        audio_file_io.un_packs_per_read = audio_file_io.un_src_buf_size / audio_file_io.un_src_size_per_pack;
        audio_file_io.pack_format = NULL;
    }
    
    UInt32 un_output_size_per_pack = dest_format.mBytesPerPacket;
    UInt32 un_out_buf_size = 65536;
    output_buf = new char[un_out_buf_size];
    
    if (0 == un_output_size_per_pack) {
        un_format_size = sizeof(un_output_size_per_pack);
        AudioConverterGetProperty(audio_converter, kAudioConverterPropertyMaximumOutputPacketSize, &un_format_size, &un_output_size_per_pack);
        output_pack_desc = new AudioStreamPacketDescription[un_out_buf_size / un_output_size_per_pack];
    }
    
    UInt32 un_num_output_packs = un_out_buf_size / un_output_size_per_pack;
    WriteCookie(audio_converter, dest_file_id);
    
    if (2 < src_format.mChannelsPerFrame) {
        WriteDestChannelLayout(audio_converter, src_file_id, dest_file_id);
    }
    
//    UInt32 un_para_size = sizeof(s_un_total_packs);
//    AudioFileGetProperty(src_file_id, kAudioFilePropertyAudioDataPacketCount, &un_para_size, &s_un_total_packs);
    
    UInt64 un_total_output_frames = 0;
    SInt64 sn_output_file_pos = 0;
    while (true) {
        AudioBufferList fill_buf_list;
        fill_buf_list.mNumberBuffers = 1;
        fill_buf_list.mBuffers[0].mNumberChannels = dest_format.mChannelsPerFrame;
        fill_buf_list.mBuffers[0].mDataByteSize = un_out_buf_size;
        fill_buf_list.mBuffers[0].mData = output_buf;
        
        Boolean b_interrupted = IsThreadStatePaused();
        if ((ret_status || b_interrupted) && (false == b_resume_from_interruption)) {
            ret_status = ERR_AUDIO_CONVERT_CAN_NOT_RESUME_FORM_INTERRUPTION;
            break;
        }
        
        UInt32 un_io_output_data_packs = un_num_output_packs;
        ret_status = AudioConverterFillComplexBuffer(audio_converter, DecodeDataProc, &audio_file_io, &un_io_output_data_packs, &fill_buf_list, output_pack_desc);
        
        if (!ret_status) {
            if (0 == un_io_output_data_packs) {
                ret_status = noErr;
                break;
            }
        }
        
        if (noErr == ret_status) {
            UInt32 un_in_num_bytes = fill_buf_list.mBuffers[0].mDataByteSize;
            AudioFileWritePackets(dest_file_id, false, un_in_num_bytes, output_pack_desc, sn_output_file_pos, &un_io_output_data_packs, output_buf);
            sn_output_file_pos += un_io_output_data_packs;
            un_convert_cur_pos += un_in_num_bytes;
            if (un_convert_cur_pos >= un_convert_length) {
                break;
            }
            SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveProgressChanged, 0.3 * un_convert_cur_pos / un_convert_length);
            if (0 != dest_format.mFramesPerPacket) {
                un_total_output_frames += (un_io_output_data_packs * dest_format.mFramesPerPacket);
            }else {
                for (UInt32 un_itr = 0; un_itr < un_io_output_data_packs; ++un_itr) {
                    un_total_output_frames += output_pack_desc[un_itr].mVariableFramesInPacket;//静态代码分析对这里的警告不用管，已确认没问题。//haiping
                }
            }
        }
    }
    
    if (noErr == ret_status) {
        if (0 == dest_format.mBitsPerChannel) {
            WritePackTableInfo(audio_converter, dest_file_id);
        }
        WriteCookie(audio_converter, dest_file_id);
    }
    
    if (NULL != audio_converter) {
        AudioConverterDispose(audio_converter);
    }
    if (dest_file_id) {
        AudioFileClose(dest_file_id);
    }
    if (src_file_id) {
        AudioFileClose(src_file_id);
    }
    
    if (audio_file_io.src_buf) {
        delete[] audio_file_io.src_buf;
        audio_file_io.src_buf = NULL;
    }
    if (audio_file_io.pack_format) {
        delete[] audio_file_io.pack_format;
        audio_file_io.pack_format = NULL;
    }
    if (output_buf) {
        delete[] output_buf;
        output_buf = NULL;
    }
    if (output_pack_desc) {
        delete [] output_pack_desc;
        output_pack_desc = NULL;
    }
    
    ThreadStateSetDone();
    
    return noErr;
}
