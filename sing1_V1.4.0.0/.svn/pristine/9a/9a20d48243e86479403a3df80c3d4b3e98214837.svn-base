package cn.kuwo.sing.logic.media;

import java.io.IOException;

import android.media.MediaRecorder;
import android.view.Surface;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.logic.media.OnStateChangedListener.MediaState;

public class VedioRecorder extends Recorder {
private final String TAG = "Recorder";
	
	private MediaRecorder recorder;  
	
	private static final String VEDIO_RECORDER_TEMP_FILE = "vedio_record_temp.3gp";
    
	@Override
	public int prepare() {
		
		recorder = new MediaRecorder();
		recorder.setAudioSource(MediaRecorder.AudioSource.MIC); //
//		recorder.setVideoSource(MediaRecorder.VideoSource.CAMERA);// 视频源
		recorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP); // 设置录制完成后视频的封装格式THREE_GPP为3gp.MPEG_4为mp4
		recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);

//		recorder.setVideoFrameRate(15);// 设置录制的视频帧率。必须放在设置编码和格式的后面，否则报错

//		recorder.setMaxDuration(0); // 存储之前设置，0表示无限制 时长，文件大小
//		recorder.setMaxFileSize(0);
		
//		// 设置视频录制的分辨率。必须放在设置编码和格式的后面，否则报错
//		recorder.setVideoSize(800, 480);
		
		// 直接本地存储
		recorder.setOutputFile(getTempFilename());
		
//		// 设置視頻/音频文件的编码：AAC/AMR_NB/AMR_MB/Default
//		// video: H.263, MP4-SP, or H.264
//		recorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264); // 设置录制的视频编码h263 h264 H264是H263的发展，除了263的优点外，还有更高的压缩比，有更好的图象质量，同样码流情况下，264能够产生更好的视觉效果。

		try {
			recorder.prepare();
		} catch (IllegalStateException e) {
			KuwoLog.printStackTrace(e);
			return -1;
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
			return -2;
		}

		return 0;
	}

    /**
     * 开始或者继续录音
     * @return 返回MinBufferSize，小于0时表示错误。ERROR_IS_RECORDING, AudioRecord.ERROR等。
     */
	@Override
    public int start() {
    	if (state == MediaState.Active)
    		return ERROR_IS_RECORDING;
    	
    	recorder.start();
    	onStateChanged(MediaState.Active, true);
    	
    	return 0;
    }
    
	@Override
    public void stop() {
       	if (state == null || state == MediaState.Stop)
    		return;
        	
        if(recorder == null) {
        	KuwoLog.v(TAG, "recorder is null when stop");
        	return;
        }
    	
    	onStateChanged(MediaState.Stop, true);	
    	if (recorder != null) {
            // 停止录制  
    		recorder.stop();  
            // 释放资源  
    		recorder.release();  
            recorder = null;  
        } 
    }
	
	/**
     * 获取临时文件名称
     *
     * @return String
     */
    private String getTempFilename() {
    	return DirectoryManager.getFilePath(DirContext.RECORD, VEDIO_RECORDER_TEMP_FILE);
    }
    
	@Override
	public void pause() {
		
	}

	@Override
	public void save(String path) {
		
	}
	
	// 预览
	@Override
	public void setPreviewDisplay(Surface surface){
		recorder.setPreviewDisplay(surface);
	}

	@Override
	public void release() {
	}
}
