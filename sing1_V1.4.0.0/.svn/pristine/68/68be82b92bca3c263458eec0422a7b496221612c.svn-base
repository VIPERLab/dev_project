package cn.kuwo.sing.logic.media;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.RandomAccessFile;

import org.apache.commons.io.FileUtils;

import android.media.AudioManager;
import android.media.AudioTrack;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.IOUtils;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.media.OnStateChangedListener.MediaState;

public class RawPlayer extends Player{
	private final String TAG = "RawPlayer";
	
	public AudioTrack audioTrack;
	private Thread threadAudioTrack;	// 播放线程
	private int playBufSize = 0;
	private String path;
	private int offset = 0;	// 数据流的偏移
	private int duration;
	private boolean startPlayingAccomp = false;
	private SystemPlayer mSystemPlayer;
	private int iSyncTime = 0;
	private boolean bSync = false;
	private float fSingerVolumeRate = 1.0f;
	private float fMusicVolumeRate = 0.5f;
	
	// TODO open 失败
	@Override
	public int open(String path) {
    	if (state != MediaState.Pause && state != MediaState.Complete) {
    		
    		this.path = path;
	    	if (playBufSize <= 0)
	    		playBufSize = AudioTrack.getMinBufferSize(Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_CONFIG, Constants.RECORDER_AUDIO_FORMAT) * 4;
			KuwoLog.i(TAG, String.format("start play %s, playBufSize:%d" ,path ,playBufSize));
	    	
			if (playBufSize < 0)
	    		return playBufSize;
			
			audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC, Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_CONFIG, Constants.RECORDER_AUDIO_FORMAT, playBufSize, AudioTrack.MODE_STREAM);
			offset = 0;
			int fileSize = (int) FileUtils.sizeOf(new File(path));
			duration = bytesToMs(fileSize, Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_COUNT);
			KuwoLog.i(TAG, "audioTrack.getSampleRate():" + audioTrack.getSampleRate() + "       audioTrack.getChannelCount():" + audioTrack.getChannelCount());
    	}

		return 0;
	}
	
	public void setSystemPlayer(SystemPlayer player) {
		mSystemPlayer = player;
	}

	@Override
	public synchronized void start() {
    	if (state == MediaState.Active)
    		return;
    	
    	if (audioTrack == null)
			audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC, Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_CONFIG, Constants.RECORDER_AUDIO_FORMAT, playBufSize, AudioTrack.MODE_STREAM);

    	audioTrack.play();
    	if (iSyncTime!=0){
    		bSync = true;
    	}
    	
    	if (threadAudioTrack == null) {
	    	threadAudioTrack = new Thread(new Runnable() {
	    		@Override
	    		public void run() {
	    			//readAudioDataFromFile(path);
	    			readAudioDataFromFileEx(path);
	    		}
	    	});
		    threadAudioTrack.setName("ThreadAudioTrack");
    	}
    	threadAudioTrack.start();

    	onStateChanged(MediaState.Active);
	}
    
	@Override
    public void pause(){
		if (audioTrack == null)
			return;
    	if (state != MediaState.Active)
			return;
	
		audioTrack.pause();
		stopAudioTrackThread();
		
		KuwoLog.d(TAG, "pausePlay");
		onStateChanged(MediaState.Pause);
    }
    
	@Override
	public void stop(){
		KuwoLog.i(TAG, "stopPlay");
		if (audioTrack == null)
			return;
		
		if (state == null || state == MediaState.Stop)
			return;
		
		stopAudioTrackThread();
		audioTrack.flush();
		startPlayingAccomp = false;
		audioTrack.stop();
		audioTrack.release();
		audioTrack = null;
		onStateChanged(MediaState.Stop);
	}
	
	public void release() {
		if (audioTrack == null)
			return;
		
		audioTrack.release();
		audioTrack = null;
	}

	@Override
	public int getDuration() {
		return duration;
	}
	
	@Override
	public void seekTo(int ms) {
		if (audioTrack == null)
			return;
		
//		audioTrack.flush();
		ms = ms /100 * 100;
		offset = msToBytes(ms, Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_COUNT);
		stop();
		start();
	}
	
	protected OnDataProcessListener onDataProcessListener;
	public void setOnDataProcessListener(OnDataProcessListener listener) {
		this.onDataProcessListener = listener;
	}
	protected void onDataProcess(final byte[] data) {
		if (onDataProcessListener != null)
			//handler.post(new Runnable() {
				//@Override
			//	public void run() {
					onDataProcessListener.onDataProcess(data);
			//	}
			//});
	}
	
	private void stopAudioTrackThread() {
		threadAudioTrack = null;
	}
    
	byte[] tmpBuf = null;
	private void readAudioDataFromFile(String path) {
    	FileInputStream fis = null;
    	byte[] bs = new byte[playBufSize];

    	try {   
			fis = new FileInputStream(path);
			long skip = fis.skip(offset);
			KuwoLog.d(TAG, "=======skip:   "+skip);

			while(state == MediaState.Active) {
				KuwoLog.v(TAG, "======offset : "+offset);
				
				synchronized (bs) {
										
	    			int line = fis.read(bs, 0, playBufSize);
	    			
	    			if(line == -1) {
	    				// Complete
	    				offset = 0;
	    				onStateChanged(MediaState.Complete);
	    				
	    				break;
	    			}
//	    			fos1.write(bs, 0, line);
    			
    				tmpBuf = new byte[line];
    				System.arraycopy(bs, 0, tmpBuf, 0, line);
//    				fos2.write(tmpBuf, 0, tmpBuf.length);
    				onDataProcess(tmpBuf);
    				
    				// 将数据写入到AudioTrack中  
    				if (audioTrack == null || tmpBuf == null)
    					break;
    				
    				//audioTrack.write(tmpBuf, 0, tmpBuf.length);
    				audioTrack.write(tmpBuf, 0, tmpBuf.length);
    				
    				if(!startPlayingAccomp && mSystemPlayer != null){
    					mSystemPlayer.start();
    					mSystemPlayer.setVolume(0.5f);
    				}
    				startPlayingAccomp = true;
    				tmpBuf = null;
    				
    				offset += line;
    				position = bytesToMs(offset, Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_COUNT);
    				onPositionChanged(offset);
				}
			}
//			fis.close();
			KuwoLog.i(TAG, "ThreadAudioTrack close");
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		} finally {
			stopAudioTrackThread();
		}
	}
	
	
	private void readAudioDataFromFileEx(String path) {
		RandomAccessFile raf = null;
    	byte[] bs = new byte[playBufSize];
    	try {   
    		raf = new RandomAccessFile(new File(path), "r");
    		long nlength = raf.length();
    		int nSystemPlayerPos = 0;
			while(state == MediaState.Active) {
				synchronized (bs) {
					if (mSystemPlayer != null && mSystemPlayer.isPlaying()){
						nSystemPlayerPos = mSystemPlayer.getPosition();
					}
					if (bSync){						
						int baseOffset = msToBytes(nSystemPlayerPos, Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_COUNT);
						int syncOffset = msToBytes(iSyncTime<0 ? -iSyncTime : iSyncTime, Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_COUNT);

						int curOffset = baseOffset;
						if (iSyncTime<0)	//负数表示提前，所以偏移变大
							curOffset += syncOffset;
						else
							curOffset -= syncOffset;
						
						offset = curOffset%4==0 ? curOffset : 4*(curOffset/4+1);
						
						if (offset<0){
							Thread.sleep(50);
							continue;
						}else if (offset>=nlength){
							offset = 0;
		    				onStateChanged(MediaState.Complete);
		    				break;
						}
						
						raf.seek(offset);
						audioTrack.flush();
						bSync = false;
					}
					
	    			int line = raf.read(bs);
	    			if(line == -1) {// Complete
	    				offset = 0;
	    				onStateChanged(MediaState.Complete);
	    				break;
	    			}
    			
    				tmpBuf = new byte[line];
    				System.arraycopy(bs, 0, tmpBuf, 0, line);
//    				fos2.write(tmpBuf, 0, tmpBuf.length);
    				onDataProcess(tmpBuf);
    				
    				//调节自唱声音的音量
    				short[] shortBuffer = IOUtils.convertToShortArray(tmpBuf, 0, line);    				
    				if (fSingerVolumeRate != 1.0){
    					for (int i=0; i<line/2; i++){
        					int temp = (int)(shortBuffer[i] * fSingerVolumeRate);
        					if (temp>32767)
        						temp = 32767;
        					else if (temp<-32768)
        						temp = -32768;
        					
        					shortBuffer[i] = (short)(temp);
        				}
    				}
    				byte[] tmpBuf2 = IOUtils.convertToBytes(shortBuffer, 0, line/2);

    				// 将数据写入到AudioTrack中  
    				if (audioTrack == null || tmpBuf == null)
    					break;
    				
    				//audioTrack.write(tmpBuf, 0, tmpBuf.length);
    				audioTrack.write(tmpBuf2, 0, tmpBuf2.length);
    				
    				if(!startPlayingAccomp && mSystemPlayer != null){
    					mSystemPlayer.start();
    					mSystemPlayer.setVolume(fMusicVolumeRate);
    				}
    				startPlayingAccomp = true;
    				tmpBuf = null;
    				
    				offset += line;
//    				position = bytesToMs(offset, Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_COUNT);
    				onPositionChanged(nSystemPlayerPos);
    				
    				
				}
			}
//			fis.close();
			KuwoLog.i(TAG, "ThreadAudioTrack close");
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
			
		} catch (InterruptedException e) {
			e.printStackTrace();
		} finally {
			stopAudioTrackThread();
		}
	}

    /**
     * Converts bytes of buffer to milliseconds.
     * @param bytes the size of the buffer in bytes
     * @return the time in milliseconds
     */
    public static int bytesToMs( int bytes, int sampleRate, int channels ) {
        return (int)(500L * bytes / (sampleRate * channels));
    }
    
    /**
     * Converts milliseconds to bytes of buffer.
     * @param ms the time in milliseconds
     * @return the size of the buffer in bytes
     */
    public static int msToBytes( int ms, int sampleRate, int channels ) {
        return (int)(((long) ms) * sampleRate * channels / 500);
    }

	@Override
	public int openAsync(String path) {
		return open(path);
	}

	public boolean setSyncTime(int iTime) {
		//本次调整前必须等到上一次调整完才能操作
		if (bSync || mSystemPlayer == null || mSystemPlayer.getPosition()<iTime){
			return false;
		}
		iSyncTime = iTime;
		bSync = true;
		return true;
	}

	public void setSingerVolume(float fRate) {
		fSingerVolumeRate = fRate;
	}
	
	public void setMusicVolume(float fRate){
		fMusicVolumeRate = fRate;
	}
}
