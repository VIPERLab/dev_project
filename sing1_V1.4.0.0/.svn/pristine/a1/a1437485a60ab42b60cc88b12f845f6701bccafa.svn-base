package cn.kuwo.sing.business;

import java.io.File;

import android.view.Surface;

import cn.kuwo.sing.logic.FileLogic;
import cn.kuwo.sing.logic.MusicLogic;
import cn.kuwo.sing.logic.media.OnDataProcessListener;
import cn.kuwo.sing.logic.media.OnStateChangedListener;
import cn.kuwo.sing.logic.media.OnStateChangedListener.MediaState;
import cn.kuwo.sing.logic.media.OnPositionChangedListener;
import cn.kuwo.sing.logic.media.AudioRecorder;
import cn.kuwo.sing.logic.media.Recorder;
import cn.kuwo.sing.logic.media.SystemPlayer;
import cn.kuwo.sing.logic.media.VedioRecorder;

public class RecordBusiness implements AudioBaseBusiness {
	private final String TAG = "RecordBusiness";
	
	private SystemPlayer accomPlayer; //伴唱播放器
	private SystemPlayer originalPlayer; //原唱播放器
	private SystemPlayer currentPlayer;
	private Recorder recorder;
	private OnPositionChangedListener listener;
	
	public RecordBusiness(String mode) {
		if (mode.equals(MTVBusiness.MODE_AUDIO))
			recorder = new AudioRecorder();
		else
			recorder = new VedioRecorder();
	}
	
	@Override
	public int prepare(final String rid) {
		MusicLogic lMusic = new MusicLogic();
		
		// 准备播放器
		if (rid != null){
			accomPlayer = new SystemPlayer();
			originalPlayer = new SystemPlayer();
			
			// 加载伴奏
			File mediaFile = lMusic.getAccompanyFile(rid);
			File originaFile = lMusic.getOriginalFile(rid);
			if (mediaFile == null || originaFile == null) {
				return EXCEPTION_FILE_NOT_FOND;
			} else {
				int ret = accomPlayer.open(mediaFile.getAbsolutePath());
				int originalRet = originalPlayer.open(originaFile.getAbsolutePath());
				if (ret < 0 || originalRet < 0) {
					return ret; 
				}
				accomPlayer.start();
				accomPlayer.setOnPositionChangedListener(listener);
				originalPlayer.start();
				originalPlayer.setVolumeToZero();
			}
			
			accomPlayer.setOnStateChangedListener(new OnStateChangedListener() {
				@Override
				public void onStateChanged(MediaState state) {
					if (state == MediaState.Complete) {
						stop(rid);
					}
				}
				
			});
		}
		currentPlayer = accomPlayer;
		
		// 准备录音器
		// 使用固定参数录音
		return recorder.prepare();
	}

	@Override
	public void start() {
		if (accomPlayer != null) {
			accomPlayer.start();
		}
		if(originalPlayer != null) {
			originalPlayer.start();
		}
		recorder.start();
	}
	
	@Override
	public void pause() {
		if (accomPlayer != null) {
			accomPlayer.pause();
		}
		if(originalPlayer != null) {
			originalPlayer.pause();
		}
		recorder.pause();
	}
	
	@Override
	public void toggle() {
		if (accomPlayer.state == MediaState.Active){
			pause();
		} else {
			start();
		}
	}
	
	@Override
	public void switchPlayer() {
		if(currentPlayer == accomPlayer) {
			accomPlayer.setVolumeToZero();
			originalPlayer.setVolumeToOrig();
			currentPlayer = originalPlayer;
		}else {
			originalPlayer.setVolumeToZero();
			accomPlayer.setVolumeToOrig();
			currentPlayer = accomPlayer;
		}
	}
	
	@Override
	public long getDuration(){
		if (accomPlayer == null || originalPlayer == null)
			return -1;
		
		return accomPlayer.getDuration();
	}
	
	@Override
	public void stop(String rid) {
		if (accomPlayer != null) {
			accomPlayer.stop();
		}
		if(originalPlayer != null) {
			originalPlayer.stop();
		}
		
		FileLogic lFile = new FileLogic();
		File file = lFile.getRecordFile();
		recorder.save(file.getAbsolutePath());

		recorder.stop();
	}

	@Override
	public void setOnPositionChangedListener(OnPositionChangedListener listener) {
		this.listener = listener;
		recorder.setOnPositionChangedListener(listener);
	}

	@Override
	public void setOnDataProcessListener(OnDataProcessListener listener) {
		recorder.setOnDataProcessListener(listener);
	}
	
	@Override
	public void setOnStateChanged(OnStateChangedListener listener) {
		recorder.setOnStateChangedListener(listener);
	}

	@Override
	public void setPreviewDisplay(Surface surface) {
		recorder.setPreviewDisplay(surface);
	}

	@Override
	public void release() {
		if (accomPlayer != null)
			accomPlayer.release();
		if (originalPlayer != null)
			originalPlayer.release();
		recorder.release();
	}

	@Override
	public void setSingerVolume(float fRate) {
		
	}

	@Override
	public void setMusicVolume(float fRate) {
		
	}

	@Override
	public boolean setSync(int fTime) {
		return false;
	}
}
