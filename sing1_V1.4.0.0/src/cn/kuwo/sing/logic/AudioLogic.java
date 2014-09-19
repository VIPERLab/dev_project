package cn.kuwo.sing.logic;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Queue;
import java.util.concurrent.LinkedBlockingQueue;

import android.media.AudioFormat;
import android.media.AudioTrack;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;
import cn.kuwo.base.codec.AACToM4A;
import cn.kuwo.base.codec.AudioCodecContext;
import cn.kuwo.base.codec.Decoder;
import cn.kuwo.base.codec.NativeAACEncoder;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.IOUtils;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.ui.compatibility.WaveView;

public class AudioLogic {
	private float fSingerVolumeRate = 1.0f;
	private float fMusicVolumeRate = 1.0f;
	private int iSyncTime = 0;
	
	private final static String TAG = "AudioLogic";
	
	private String getDecodePath(String musicPath) {
		return musicPath + ".wav";
	}
	private String getMixPath(String musicPath) {
		return musicPath + ".mix.wav";
	}
	
	public static int getMediaLength(String file) {
		Decoder decoder = null;
		if (file.toLowerCase().endsWith(".aac"))
			decoder = AudioCodecContext.findCodecByFormat("aac");
		else 
			decoder = AudioCodecContext.findCodecByFormat("mp3");
		
		decoder.load(file);
		
		int duration = decoder.getDuration();
		KuwoLog.d(TAG, "duration :"+duration);
		decoder.release();
		
		return duration;
	}
	
	public static int getWavSize(int duration) {
		return duration * Constants.RECORDER_SAMPLE_RATE *  Constants.RECORDER_CHANNEL_COUNT * Constants.RECORDER_BPP / 8;
	}
	
	private boolean decode(String musicPath, String decodePath, long decodeCount) throws IOException {
		
		if (TextUtils.isEmpty(musicPath))
			return true;
		
		// 删除已存在文件
		File file = new File(decodePath);
		if (file != null)
			file.delete();
		
		Decoder decoder = null;
		
        int bufferSize = AudioTrack.getMinBufferSize(Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_CONFIG, 
                AudioFormat.ENCODING_PCM_16BIT) << 1;
        short[] accSamples = new short[bufferSize] ;
        
		// 准备解码伴奏
		if (Constants.ACCOMPANIMENT_FORMAT.equals(".aac"))
			decoder = AudioCodecContext.findCodecByFormat("aac");
		else 
			decoder = AudioCodecContext.findCodecByFormat("mp3");
			
		int a = decoder.load(musicPath);
		KuwoLog.i(TAG, String.format("decoder load file :%s    Samplerate: %d", (a == 0 ? "True": "False"), decoder.getSamplerate()));
		if (a != 0 )
			return false;
		
		// 升采样Buffer
		byte[] pcmBuffer = null;
		if (decoder.getSamplerate() != Constants.RECORDER_SAMPLE_RATE) {
			
		   double rate = Constants.RECORDER_SAMPLE_RATE / (double)decoder.getSamplerate();
		   int pcmBufferSize = rate > 1 ? (int)(bufferSize * rate + 100) : bufferSize;
		   pcmBufferSize *= 2;
		   pcmBuffer = new byte[pcmBufferSize] ;
		}
		
		FileOutputStream fos = new FileOutputStream(decodePath);
		int progress = 0;
		while(!decoder.isFinished() && progress < decodeCount) {
			// decode
			int count = 0;
			KuwoLog.v(TAG, "decode start");
			count = decoder.readSamples(accSamples);
			KuwoLog.v(TAG, "decodeCount=" + count);
			
			for (int i=0; i<accSamples.length; i++){
				short temp =  (short) (accSamples[i]*fMusicVolumeRate);
				if (temp>32767){
					temp = 32767;
				}else if(temp<-32768){
					temp = -32768;
				}
				accSamples[i] = temp;
			}
			
			// save
			if (decoder.getSamplerate() != Constants.RECORDER_SAMPLE_RATE) {
				// pcm
				int pcmCount = pcmResampleProcess(accSamples, count, pcmBuffer, decoder.getSamplerate(), Constants.RECORDER_SAMPLE_RATE);
				progress += pcmCount*2;
				KuwoLog.v(TAG, "pcmCount=" + pcmCount);
				
				if (pcmCount > 0)
					fos.write(pcmBuffer, 0 , pcmCount*2); 
			} else {
				byte[] tempBuffer = IOUtils.convertToBytes(accSamples, 0, count);
				progress += tempBuffer.length;
				fos.write(tempBuffer, 0 , tempBuffer.length); 
				KuwoLog.v(TAG, "tempBuffer Length=" + tempBuffer.length);
			}
			
			onProcess(1, progress, (int)decodeCount);
		}
		
		decoder.release();
		
		fos.flush();
		fos.close();
		
		return true;
	}
	
	private void mix(byte[] wav, byte[] target) {

		for (int i = 0; i+1 < target.length && i+1 < wav.length; i+=2) {
			int temp = (int)wav[i+1] + (((int)wav[i])<<8) + (int)target[i+1] + (((int)target[i])<<8);
			
			if (temp > Short.MAX_VALUE) {
				target[i+1] = (byte)(Short.MAX_VALUE & 0x00FF);
				target[i] = (byte)(Short.MAX_VALUE & 0xFF00);
			}
			else if (temp < Short.MIN_VALUE) {
				target[i+1] = (byte)(Short.MIN_VALUE & 0x00FF);
				target[i] = (byte)(Short.MIN_VALUE & 0xFF00);
			}
			else {
				target[i+1] = (byte)(temp & 0x00FF);
				target[i] = (byte)(temp & 0xFF00);
			}
		}
	}
	
	private void mix(short[] wav, short[] target) {

		for (int i = 0; i < target.length && i < wav.length; i++) {
			int temp = (int)wav[i] + (int)target[i];
			if (temp > Short.MAX_VALUE)
				target[i] = Short.MAX_VALUE;
			else if (temp < Short.MIN_VALUE)
				target[i] = Short.MIN_VALUE;
			else 
				target[i] = (short)temp;
		}
	}
	
	// 以wav1的长度为准
	private boolean mix(String wav1, String wav2, String targetPath) throws IOException {
		
		FileInputStream fis1 = new FileInputStream(wav1);	//音乐
		FileInputStream fis2 = new FileInputStream(wav2);	//人声
		FileOutputStream fos = new FileOutputStream(targetPath);
		
		//首先做同步调节的处理
		int syncOffset = msToBytes(iSyncTime<0 ? -iSyncTime : iSyncTime, Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_COUNT);
		syncOffset = syncOffset%4==0 ? syncOffset : 4*(syncOffset/4);
		if (iSyncTime<0){	//人声提前，读取人声的偏移往后
			fis2.skip(syncOffset);
		}else if (iSyncTime>0){	//人声延后，人声前面填充一些无效的0数据
			byte[] bufferSyncMusic = new byte[syncOffset] ;
			int lengthMusic = fis1.read(bufferSyncMusic, 0, bufferSyncMusic.length);
			short[] shortBufferMusic = IOUtils.convertToShortArray(bufferSyncMusic, 0, lengthMusic);
			short[] shortBufferSinger = new short[syncOffset/2];
			
			mix(shortBufferMusic, shortBufferSinger);
			byte[] bufferMix = IOUtils.convertToBytes(shortBufferSinger, 0, shortBufferSinger.length);
			fos.write(bufferMix);
		}
		
		//再进行常规合成	
		byte[] buffer1 = new byte[1800*2] ;
		byte[] buffer2 = new byte[1800*2] ;
		int count = 0;
		int line = 0;
		while((line = fis1.read(buffer1, 0, buffer1.length)) > 0) {
			count += line;
			
			int nRes = fis2.read(buffer2, 0, line);
			if (nRes==-1){
				break;
			}else if (nRes<line){
				for (int i=nRes; i<buffer2.length; i++){
					buffer2[i] = 0;
				}
			}
			
			revProcess(Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_COUNT, buffer2);
			
			short[] buffer3 = IOUtils.convertToShortArray(buffer1, 0, line);
			short[] buffer4 = IOUtils.convertToShortArray(buffer2, 0, line);
			mix(buffer3, buffer4);
			
			byte[] buffer5 = IOUtils.convertToBytes(buffer4, 0, buffer4.length);
			fos.write(buffer5);
			
			onProcess(2, count, fis1.available() + count);
		}
		
		fos.flush();
		fos.close();
		fis1.close();
		fis2.close();
		return true;
	}

	public void encode(String source, String targetPath) throws IOException {
		String temp = targetPath+".temp";
		// 删除已存在文件
		File fileTemp = new File(temp);
		fileTemp.delete();
		
		NativeAACEncoder encoder = new NativeAACEncoder();
		
		// bitrate, channels, sample rate, bits per sample, output file name
//		encoder.init(64000, 1, 16000, 16, output);
//		encoder.init(64000, 2, 44100, 16, output);
		encoder.init(Constants.RECORDER_BIT_RATE, Constants.RECORDER_CHANNEL_COUNT, Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_BPP, temp);

		byte[] buffer = new byte[1024*4] ; //该处buffer大小不要改变
		FileInputStream fis = new FileInputStream(source);
		
		int count = 0;
		int line = 0;
		while((line = fis.read(buffer)) > 0) {
			count += line;
			encoder.encode(buffer);
			onProcess(3, count, fis.available() + count);
		}
		
		fis.close();
		
		encoder.uninit();
		
		// M4A
		File file = new File(targetPath);
		file.delete();
        new AACToM4A().convert(AppContext.context, temp, targetPath);
        fileTemp.delete();
	}

	public int process(String musicPath, String recordPath, String targetPath) {
		
//		musicPath = "/sdcard/kwsing/accompaniment/505795.aac";
		String decodePath = targetPath + ".wav";
		String mixPath = targetPath + ".mix.wav";
		
		File recordFile = new File(recordPath);
		if (!recordFile.exists())
			return -1;
		
		if (!TextUtils.isEmpty(musicPath)) {
			try {
				if (!decode(musicPath, decodePath, recordFile.length() + 2000))
					return -2;
			} catch (Exception e) {
				KuwoLog.printStackTrace(e);
				return -2;
			}
			
			try {
				mix(decodePath, recordPath, mixPath);
			} catch (Exception e) {
				KuwoLog.printStackTrace(e);
				return -3;
			}
		}
		
		try {
			String encodeSource = TextUtils.isEmpty(musicPath)? recordPath : mixPath;
//			String encodeSource = TextUtils.isEmpty(musicPath)? processPath : mixPath;
			encode(encodeSource, targetPath);
		} catch (Exception e) {
			KuwoLog.printStackTrace(e);
			return -4;
		}
		
		// 处理中间文件
		new File(decodePath).delete();
		new File(mixPath).delete();
		
		onProcess(4, 1, 1);
		
		return 0;
	}
	
	public int process(final Kge kge) {
		FileLogic lFile = new FileLogic();
		String musicPath = lFile.getAccompanimentFile(kge.id);
		String recordPath = lFile.getRecordFile().getAbsolutePath();
		String targetPath = lFile.getKgeFile(kge);
		return process(musicPath, recordPath, targetPath);
	}
	
	public interface ProcessListener{
		void onProcess (int process, int current, int total);
	}
	private ProcessListener mProcessListener;
	public void setProcessListener(ProcessListener l) {
		mProcessListener = l;
	}
	protected void onProcess(int process, int current, int total) {
		if (mProcessListener != null)
			mProcessListener.onProcess(process, current, total);
	}
	
    public void writeWaveFileHeader(FileOutputStream fos, long totalAudioLen, 
    		long totalDataLen, long sampleRate, int channels, 
    		long byteRate) throws IOException
    {
	    byte[] header = new byte[44];
	    KuwoLog.i(TAG,"writeWaveFileHeader");
	    
	    header[0] = 'R';  // RIFF/WAVE header
	    header[1] = 'I';
	    header[2] = 'F';
	    header[3] = 'F';
	    header[4] = (byte) (totalDataLen & 0xff);
	    header[5] = (byte) ((totalDataLen >> 8) & 0xff);
	    header[6] = (byte) ((totalDataLen >> 16) & 0xff);
	    header[7] = (byte) ((totalDataLen >> 24) & 0xff);
	    header[8] = 'W';
	    header[9] = 'A';
	    header[10] = 'V';
	    header[11] = 'E';
	    header[12] = 'f';  // 'fmt ' chunk
	    header[13] = 'm';
	    header[14] = 't';
	    header[15] = ' ';
	    header[16] = 16;  // 4 bytes: size of 'fmt ' chunk
	    header[17] = 0;
	    header[18] = 0;
	    header[19] = 0;
	    header[20] = 1;  // format = 1
	    header[21] = 0;
	    header[22] = (byte) channels;
	    header[23] = 0;
	    header[24] = (byte) (sampleRate & 0xff);
	    header[25] = (byte) ((sampleRate >> 8) & 0xff);
	    header[26] = (byte) ((sampleRate >> 16) & 0xff);
	    header[27] = (byte) ((sampleRate >> 24) & 0xff);
	    header[28] = (byte) (byteRate & 0xff);
	    header[29] = (byte) ((byteRate >> 8) & 0xff);
	    header[30] = (byte) ((byteRate >> 16) & 0xff);
	    header[31] = (byte) ((byteRate >> 24) & 0xff);
	    header[32] = (byte) (2 * 16 / 8);  // block align
	    header[33] = 0;
	    header[34] = (byte) getBPP(AudioFormat.ENCODING_PCM_16BIT);  // bits per sample
	    header[35] = 0;
	    header[36] = 'd';
	    header[37] = 'a';
	    header[38] = 't';
	    header[39] = 'a';
	    header[40] = (byte) (totalAudioLen & 0xff);
	    header[41] = (byte) ((totalAudioLen >> 8) & 0xff);
	    header[42] = (byte) ((totalAudioLen >> 16) & 0xff);
	    header[43] = (byte) ((totalAudioLen >> 24) & 0xff);
	    
	    fos.write(header, 0, 44);
	}
    
    public int getBPP(int audioFormat){
    	switch (audioFormat) {
	    	case AudioFormat.ENCODING_PCM_16BIT : return 16;
	    	case AudioFormat.ENCODING_PCM_8BIT : return 8;
    	}
		return -1;
    }
    
    
    private final int QUEUE_SIZE = 5;
	private final Queue <Double> queue = new LinkedBlockingQueue <Double> (QUEUE_SIZE);
	
   // 计算每次的值
    public double computeSingle(byte[] bytes){
//    	KuwoLog.i(TAG, bytes[0] + " " + bytes[1] + " " + bytes[2] + " " + bytes[3] + " " + bytes[4] + " " + bytes[5] + " " + bytes[6] + " " + bytes[7]);
    	short[] data = IOUtils.convertToShortArray(bytes, 0, bytes.length);
    		
    	int lenth = data.length/2;
    	double temp_env = 0;
    	for(int i = 0; i < lenth; i +=2){
    		double frame_amp = 0;
    		for(int j = i; j < i+2; ++j){
    			frame_amp += data[i];
    		}
    		frame_amp /=2;
    		temp_env += frame_amp * frame_amp;
    	}
    	temp_env /= (lenth/2);
    	temp_env = ((temp_env > 1) ? Math.log10(temp_env) : 0.0) / 9;
    	temp_env = (temp_env < 0.5) ? 0.0 : ((temp_env - 0.5) * 2);
    	temp_env *= 100;
    	if(queue.size() >= QUEUE_SIZE){
    		queue.poll();
    	}
    	queue.offer(temp_env);
    	
    	return temp_env;
    }
    
    // 计算队列里的平均值(每句的值）
    public int computeMean(){
    	int ret = 0;

    	synchronized (queue) {
    		while(queue.size() > QUEUE_SIZE)
    			queue.poll();
    		
    		while(!queue.isEmpty()){
    			ret += queue.poll();
    			KuwoLog.d(TAG, "取值" + ret);
    		}
		} 
    	
    	int ave = ret / QUEUE_SIZE;
    	total = total + ave;
    	sentenceNum++;
    	 return ave;
    }
    
    private int total;
    private int sentenceNum=0;
    
    public int computTotal() {
    	if(sentenceNum == 0){
    		return 0;
    	}
		return total/sentenceNum;
	}
    public int judgeArrowColor(double envelope, double standard){
    	double x = Math.abs(envelope - standard);
    	int color = WaveView.WAVE_GREEN;
    	if(x > 60)
    		color = WaveView.WAVE_RED;
    	else if(x <= 60 && x >= 30)
    		color = WaveView.WAVE_YELLOW;
    	else if(x < 30)
    		color = WaveView.WAVE_GREEN;
    	return color;
    }
	
    private static boolean libLoaded = false;
	static {
		if (!libLoaded) {
			try {
				System.loadLibrary("kwrev");
				System.loadLibrary("kwscore");
				System.loadLibrary("kwpcm");
				System.loadLibrary("aac-encoder");
			} catch (UnsatisfiedLinkError  e) {
				e.printStackTrace();
			}
			libLoaded = true;
		}
	}

	public native void revInit();

	/**
	 * 对一段wav添加混音效果，输出的wav数据也放在samples 指向的buffer里。
	 * 
	 * @param samp_freq
	 *            采样率
	 * @param sf
	 *            PCM类型，传固定值 1
	 * @param nchannels
	 *            声道数
	 * @param samples
	 *            wav数组
	 * @param samplesSize
	 *            wav数据 short值的个数
	 */
	public native void revProcess(int samp_freq,  int nchannels, byte[] samples);
	
	
	//public void revProcess(int samp_freq, int nchannels, byte[] samples){
	//	revProcess(samp_freq, 1, nchannels, samples, samples.length/2);
	//}

	/**
	 * 设置混音效果
	 * 
	 * @param rSize
	 *            房间大小
	 */
	public native void revSet(int rSize);

	/**
	 * 析构全局变量
	 */
	public native void revRelease();
	

	private boolean hasStarted = false;
	/************************************************************************/
	/* 
	 初始化Score对象时调用
	prarm:
		nRecWavSampleRate:录制音频的采样率
		nChannel：录制音频的声道数
		dEnvMax: 原唱包络归一化所用的值
	*/
	/************************************************************************/
	public native void scoreInit(int nRecWavSampleRate, int nChannel, double dbEnvRate);

	/************************************************************************/
	/*
	说明：有新的wav数据到达时调用
	param：
		pWavData:数据
		nLen:short数组长度
	有新的自唱wav数据到达，要求参数：44100hz，2 channel， 16位采样位数
	44.1K采样，双声道，16位采样深度，1秒钟数据=44100*2*sizeof(short);
	*/
	/************************************************************************/
	
	public native void scoreOnWavNewDataComing(short[] pWavData);
	public void scoreOnWavComing(short[] pWavData){
		if (!hasStarted)
			return;
		KuwoLog.i(TAG, "scoreOnWavNewDataComing length:" + pWavData.length);
		scoreOnWavNewDataComing(pWavData);
	}
	
	/************************************************************************/
	/*
	说明：一句歌开始唱的时候调用
	param：
		pdbSpec:该句频谱数组
		pdbEnv：该句包络数组
		nSpecLen:数组长度
		nEnvLen: 数组长度
	*/
	/************************************************************************/
	
	public native void scoreSentenceStart(double[] pdbSpec, double[] pdbEnv);
	public void scoreStart(double[] pdbSpec, double[] pdbEnv){
		KuwoLog.v(TAG, "scoreStart pdbSpec length:" + pdbSpec.length +"    pdbEnv length:" + pdbEnv.length);
		hasStarted = true;
		scoreSentenceStart(pdbSpec, pdbEnv);
	}

	/************************************************************************/
	/*
	说明：一句歌结束的时候调用
	返回值：
		得分
	*/
	/************************************************************************/
	public native int scoreSentenceEnd();
	public int scoreEnd(){
		hasStarted = false;
		return scoreSentenceEnd();
	}
	
	public native int pcmResampleProcess(short[] pSrcBuffer, int nSrcBufferLen, byte[] pDesBuffer, int n_src_sample_rate, int n_dest_sample_rate);
//	JNIEXPORT jint JNICALL Java_cn_kuwo_sing_logic_AudioLogic_pcmResampleProcess
//	  (JNIEnv * env, jobject job,
//			  jshortArray pSrcBuffer, int nSrcBufferLen,
//			  jshortArray pDesBuffer,
//			  jint n_src_sample_rate, jint n_dest_sample_rate);
	public void setSingerVolume(float fRawPlayerVolumeRate) {
		fSingerVolumeRate = fRawPlayerVolumeRate;
	}
	
	public void setMusicVolume(float fSystemPlayerVolumeRate){
		fMusicVolumeRate = fSystemPlayerVolumeRate;
	}
	
	public void setSyncTime(int time){
		iSyncTime = time;
	}
	
	/**
     * Converts milliseconds to bytes of buffer.
     * @param ms the time in milliseconds
     * @return the size of the buffer in bytes
     */
    private int msToBytes( int ms, int sampleRate, int channels ) {
        return (int)(((long) ms) * sampleRate * channels / 500);
    }
	
}
