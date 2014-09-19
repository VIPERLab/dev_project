package cn.kuwo.sing.logic.media;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import org.apache.commons.io.FileUtils;

import android.media.AudioRecord;
import android.media.MediaRecorder.AudioSource;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.logic.media.OnStateChangedListener.MediaState;

public class AudioRecorder extends Recorder{
	private final String TAG = "AudioRecorder";
	
	private AudioRecord audioRecord;
	private Thread threadAudioRecord;	// 录音线程
	private int bufferSize;
	
    /**
     * 临时文件名称
     */
    private static final String AUDIO_RECORDER_TEMP_FILE = "record_temp.raw";
    
    @Override
    public int prepare() {
    	if (state == MediaState.Active)
    		return ERROR_IS_RECORDING;
    	
//    	bufferSize = (int)(0.010*44100*2*16);
    	bufferSize = AudioRecord.getMinBufferSize(Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_CONFIG, Constants.RECORDER_AUDIO_FORMAT);
        if (bufferSize == AudioRecord.ERROR_BAD_VALUE) {
        	KuwoLog.d(TAG, "AudioRecord.ERROR_BAD_VALUE");
        	return AudioRecord.ERROR_BAD_VALUE;
        }
        	
        // check if we can instantiate and have a success
        audioRecord = new AudioRecord(AudioSource.DEFAULT, Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_CONFIG, Constants.RECORDER_AUDIO_FORMAT, bufferSize);
        if (audioRecord.getState() != AudioRecord.STATE_INITIALIZED) {
        	KuwoLog.d(TAG, "AudioRecord.STATE_UNINITIALIZED");
        	return AudioRecord.STATE_UNINITIALIZED;
        }
    	
    	deleteTempFile();

    	return bufferSize;
    }

    /**
     * 开始或者继续录音
     * @return 返回MinBufferSize，小于0时表示错误。ERROR_IS_RECORDING, AudioRecord.ERROR等。
     */
    @Override
    public int start() {
    	if (state == MediaState.Active)
    		return ERROR_IS_RECORDING;
    	
    	if(audioRecord == null) {
    		KuwoLog.v(TAG, "audioRecord is null when start");
    		return -1;
    	}
    	
    	if (audioRecord.getState() == AudioRecord.STATE_UNINITIALIZED) {
    		KuwoLog.v(TAG, "audioRecord UNINITIALIZED");
    		onStateChanged(MediaState.Active, false);
    		return -1;
    	}
    	
    	threadAudioRecord = new Thread(new Runnable() {
			public void run() {
				writeAudioDataToFile();
			}
		});
    	threadAudioRecord.setName("ThreadAudioRecord");

    	audioRecord.startRecording();
    	onStateChanged(MediaState.Active, true);
    	threadAudioRecord.start();
    	
    	super.start();
    	return bufferSize;
    }
    
    @Override
    public void pause() {
    	if (state != MediaState.Active) {
    		onStateChanged(MediaState.Pause, false);
    		return;
    	}
    	
    	if(audioRecord == null) {
    		KuwoLog.v(TAG, "audioRecord is null when pause");
    		return;
    	}
    	
		KuwoLog.i(TAG, "pauseRecord");
		onStateChanged(MediaState.Pause, true);
		audioRecord.stop();
		threadAudioRecord = null;
    }
    
    @Override
    public void stop() {
    	KuwoLog.i(TAG, "stopRecord");

    	if (state == null || state == MediaState.Stop)
			return;
    	
    	if(audioRecord == null) {
    		KuwoLog.v(TAG, "audioRecord is null when stop");
    		return;
    	}

		onStateChanged(MediaState.Stop, true);
		release();
		
//		position = 0;
    }
    
    @Override
    public void release() {
    	if (audioRecord != null) {
//			audioRecord.stop();
			audioRecord.release();
			audioRecord = null;
    	}
		threadAudioRecord = null;
    }


    @Override
    public void save(String path) {
    	if(path == null)
    		return;
    	
    	if(audioRecord == null) {
    		KuwoLog.v(TAG, "audioRecord is null when save");
    		return;
    	}
    	
//		copyWaveFile(getTempFilename(), path);
    	File target = new File(path);
    	target.delete();
    	try {
			FileUtils.moveFile(getTempFile(), target);
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
		deleteTempFile();
//		onStateChanged(MediaState.Complete);
    }


    /**
     * 删除临时文件
     */
    private void deleteTempFile()
    {
    	KuwoLog.i(TAG,"delete");
    	File file = new File(getTempFilename());
    	file.delete();
    }
    
    private void writeAudioDataToFile() {
    	byte[] bs = new byte[bufferSize];
    	String fileName = getTempFilename();
    	FileOutputStream fos = null;
    	try {
			fos = new FileOutputStream(fileName, true);
		} catch (FileNotFoundException e) {
			KuwoLog.printStackTrace(e);
		}
    	if(fos == null)
    		return;
    	
		int line = 0;
		while(state == MediaState.Active) { 
			if (audioRecord == null)
				break;
			
			synchronized (audioRecord) {
				line = audioRecord.read(bs, 0, bufferSize);
			}
			
			if(line != AudioRecord.ERROR_INVALID_OPERATION) {
				try {
					// 保存录制的声音数据
					fos.write(bs);
					onDataProcess(bs);
					
				} catch (IOException e) {
					KuwoLog.printStackTrace(e);
				}
			}
		}
		
		try {
			fos.flush();
			fos.close();
			KuwoLog.i(TAG, "writeAudioDataToFile end");
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
    }

//    private long byteLengthToMs(int length) {
//    	AudioLogic lAudio = new AudioLogic();
//    	long bytesPs = audioRecord.getChannelCount() * audioRecord.getSampleRate() * lAudio.getBPP(audioRecord.getAudioFormat());
//		return length * 1000 / bytesPs;
//	}

	/**
     * 获取临时文件名称
     *
     * @return String
     */
    private String getTempFilename() {
    	return DirectoryManager.getFilePath(DirContext.RECORD, AUDIO_RECORDER_TEMP_FILE);
    }
    
    private File getTempFile() {
    	return DirectoryManager.getFile(DirContext.RECORD, AUDIO_RECORDER_TEMP_FILE);
    }
    
//    /**
//     * 复制文件
//     * 
//     * @param inFilename
//     * @param outFilename
//     */
//    private void copyWaveFile(String inFilename,String outFilename)
//    {
//    	
//    	KuwoLog.i(TAG, "copyWaveFile");
//    	FileInputStream fis = null;
//    	FileOutputStream fos = null;
//    	long totalAudioLen = 0;
//    	long totalDataLen = 0;
//    	long sampleRate = audioRecord.getSampleRate();
//        int channels = audioRecord.getChannelCount();
//    	
//        AudioLogic lAudio = new AudioLogic();
//        long byteRate = lAudio.getBPP(AudioFormat.ENCODING_PCM_16BIT ) * sampleRate * channels/8;
//        
//        byte[] data = new byte[bufferSize];
//        
//        try {
//			fis = new FileInputStream(inFilename);
//			fos = new FileOutputStream(outFilename);
//			
//			totalAudioLen = fis.getChannel().size();
//			
////			totalDataLen = totalAudioLen + 44;
////			writeWaveFileHeader(fos, totalAudioLen, totalDataLen, sampleRate, channels, byteRate);
//			
//			while(fis.read(data)!=-1) {
//				fos.write(data);
//			}
//			
//			fis.close();
//			fos.close();
//		} catch(FileNotFoundException e) {
//			KuwoLog.printStackTrace(e);
//		} catch (IOException e) {
//        	KuwoLog.printStackTrace(e);
//		}
//        KuwoLog.i(TAG, "complete copyWaveFile");
//    }
    
}
