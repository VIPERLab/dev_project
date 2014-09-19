package cn.kuwo.sing.business;

import java.io.File;

import android.view.Surface;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.IOUtils;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.AudioLogic;
import cn.kuwo.sing.logic.FileLogic;
import cn.kuwo.sing.logic.MusicLogic;
import cn.kuwo.sing.logic.media.OnDataProcessListener;
import cn.kuwo.sing.logic.media.OnPositionChangedListener;
import cn.kuwo.sing.logic.media.OnStateChangedListener;
import cn.kuwo.sing.logic.media.OnStateChangedListener.MediaState;
import cn.kuwo.sing.logic.media.RawPlayer;
import cn.kuwo.sing.logic.media.SystemPlayer;

public class ReviewBusiness implements AudioBaseBusiness {
	private final String TAG = "ReviewBusiness";

	private SystemPlayer mSystemPlayer;		//加载的伴唱
	private RawPlayer mRawPlayer;			//加载录制的人声
	private AudioLogic lAudio;
	
	private float fRawPlayerVolumeRate = 0.5f;
	private float fSystemPlayerVolumeRate = 0.5f;
	private int	iSyncTime = 0;
	
//	// 混音类型
//	public static final int SMALL_ROOM = 0;
//	public static final int MIDDLE_ROOM = 1;
//	public static final int BIG_ROOM = 2;
//	public static final int HALL = 3;
//	public static final int NO_ROOM = 4;
	
	public ReviewBusiness(){
		mRawPlayer = new RawPlayer();
		lAudio = new AudioLogic();
		lAudio.revInit();
		lAudio.revSet(1);
	}
	
	@Override
	public int prepare(String rid) {
		MusicLogic lMusic = new MusicLogic();
		
		if (rid != null) {
			mSystemPlayer = new SystemPlayer();
			mRawPlayer.setSystemPlayer(mSystemPlayer);
		}

		mRawPlayer.setOnDataProcessListener(lOnDataProcess);
		mRawPlayer.setOnStateChangedListener(lOnStateChanged);
				
		KuwoLog.d("rev", "set to small room");
		KuwoLog.d("rev", "parpare to play");
		
		// 加载伴奏
		if (mSystemPlayer != null && rid != null) {
			File mediaFile = lMusic.getAccompanyFile(rid);
			if (mediaFile == null || !mediaFile.exists()) {
				// 媒体文件不存在
				return -1;
			} else {
				mSystemPlayer.open(mediaFile.getAbsolutePath());
			}
		}
		
		// 加载演唱
		FileLogic lFile = new FileLogic();
		File singFile = lFile.getRecordFile();
		if (singFile == null || !singFile.exists())
			return -2;
		mRawPlayer.open(singFile.getAbsolutePath());
		
		return 1;
	}
	
	@Override
	public void start() {
		if (mSystemPlayer != null)
			mSystemPlayer.start();
		mRawPlayer.start();
	}

	@Override
	public void pause() {
		if (mSystemPlayer != null)
			mSystemPlayer.pause();
		mRawPlayer.pause();
	}

	@Override
	public void toggle() {
		if (mRawPlayer.state == MediaState.Active){
			pause();
		} else {
			start();
		}
	}
	
	@Override
	public void stop(String rid) {
		if (mSystemPlayer != null)
			mSystemPlayer.stop();
		mRawPlayer.stop();
	}
	
	@Override
	public long getDuration(){
		return mRawPlayer.getDuration();
	}

	public void seekTo(int progress) {
		if (mSystemPlayer != null)
			mSystemPlayer.seekTo(progress);
		mRawPlayer.seekTo(progress);
	}
	
	public RawPlayer getRawPlayer() {
		return mRawPlayer;
	}
	
	public void setRev(int rev) {
		lAudio.revSet(rev);
	}
	
	public float getRawPlayerVolume(){
		return fRawPlayerVolumeRate;
	}
	
	public float getSystemPlayerVolume(){
		return fSystemPlayerVolumeRate;
	}
	
	public int getSyncTime(){
		return iSyncTime;
	}

	private OnStateChangedListener lOnStateChanged = new OnStateChangedListener() {
		
		@Override
		public void onStateChanged(MediaState state) {
			if (state == MediaState.Complete) {
				if (mSystemPlayer != null)
					mSystemPlayer.stop();
			}
			if (mOnStateChangedListener != null)
				mOnStateChangedListener.onStateChanged(state);
		}
	};
	
	private OnDataProcessListener lOnDataProcess = new OnDataProcessListener() {
		
		@Override
		public void onDataProcess(byte[] data) {
			if (mOnDataProcessListener != null)
				mOnDataProcessListener.onDataProcess(data);
			
			synchronized (lAudio) {
				lAudio.revProcess(Constants.RECORDER_SAMPLE_RATE, Constants.RECORDER_CHANNEL_COUNT, data);
			}
		}
	};
		
	private OnDataProcessListener mOnDataProcessListener;
	private OnStateChangedListener mOnStateChangedListener;
	
	@Override
	public void setOnDataProcessListener(OnDataProcessListener listener) {
		mOnDataProcessListener = listener;
	}

	@Override
	public void setOnPositionChangedListener(OnPositionChangedListener listener) {
		mRawPlayer.setOnPositionChangedListener(listener);
	}

	@Override
	public void setOnStateChanged(OnStateChangedListener listener) {
		mOnStateChangedListener = listener;
	}

	@Override
	public void setPreviewDisplay(Surface surface) {
		
	}

	@Override
	public void switchPlayer() {
		
	}

	@Override
	public void release() {
		if (mSystemPlayer != null)
			mSystemPlayer.release();
		if (mRawPlayer != null)
			mRawPlayer.release();
	}

	@Override
	public void setSingerVolume(float fRate) {
		fRawPlayerVolumeRate = fRate;
		mRawPlayer.setSingerVolume(fRate);
	}

	@Override
	public void setMusicVolume(float fRate) {
		fSystemPlayerVolumeRate = fRate;
		mSystemPlayer.setVolume(fRate);
		mRawPlayer.setMusicVolume(fRate);
	}

	@Override
	public boolean setSync(int iTime) {
		if (mRawPlayer.setSyncTime(iTime)){
			iSyncTime = iTime;
			return true;
		}
		return false;
	}
}
