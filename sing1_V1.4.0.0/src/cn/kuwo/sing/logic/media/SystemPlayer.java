package cn.kuwo.sing.logic.media;

import java.io.IOException;

import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnBufferingUpdateListener;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnErrorListener;
import android.media.MediaPlayer.OnPreparedListener;
import android.view.SurfaceHolder;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.thread.LoopHandler;
import cn.kuwo.sing.logic.media.OnStateChangedListener.MediaState;

public class SystemPlayer extends  Player{
	
	private final String TAG = "SystemPlayer";
	private MediaPlayer player;
	private float fVolumeRate = 1.0f;
	
	public SystemPlayer() {
		player = new MediaPlayer();
	}
	
	@Override
	public int open(String path) {
		
		player.setOnCompletionListener(new OnCompletionListener() {
			@Override
			public void onCompletion(MediaPlayer mp) {
				onStateChanged(MediaState.Complete);
			}
		});
		player.setOnErrorListener(new OnErrorListener() {
			
			@Override
			public boolean onError(MediaPlayer mp, int what, int extra) {
				mPlayHandler.stop();
				mp.reset();
				return true;
			}
		});
		
		try {
			player.reset();
			player.setDataSource(path);
			player.prepare();
		} catch (IllegalArgumentException e) {
			KuwoLog.printStackTrace(e);
			return -1;
		} catch (IllegalStateException e) {
			KuwoLog.printStackTrace(e);
			return -2;
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
			return -3;
		}
		return 0;
	}
	
	@Override
	public int openAsync(String path) {
		
		player.setOnCompletionListener(new OnCompletionListener() {
			@Override
			public void onCompletion(MediaPlayer mp) {
				onStateChanged(MediaState.Complete);
			}
		});
		player.setOnErrorListener(new OnErrorListener() {
			
			@Override
			public boolean onError(MediaPlayer mp, int what, int extra) {
				mPlayHandler.stop();
				mp.reset();
				return true;
			}
		});
		
		try {
			player.reset();
			player.setDataSource(path);
			player.setAudioStreamType(AudioManager.STREAM_MUSIC);
			player.prepareAsync();
		} catch (IllegalArgumentException e) {
			KuwoLog.printStackTrace(e);
			return -1;
		} catch (IllegalStateException e) {
			KuwoLog.printStackTrace(e);
			return -2;
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
			return -3;
		}
		return 0;
	}


	@Override
	public void start() {
		if (player == null)
			return ;
		
		if (isPlaying())
			return;
		
		if (state == MediaState.Stop)
			return;
		
		player.start();
		onStateChanged(MediaState.Active);
		mPlayHandler.start(mPlayRunnable);
	
	}
	
	@Override
	public void pause() {
		if (player == null)
			return ;
		if (state != MediaState.Active)
			return;
		
		try {
			player.pause();
			onStateChanged(MediaState.Pause);
		} catch(IllegalStateException e){
			KuwoLog.printStackTrace(e);
		}
	}
	
	@Override
	public void stop() {
		if (player == null)
			return ;
		try {
			if (player.isPlaying())
				player.stop();
			player.reset();
			player.release();
		} catch(Exception e) {
			KuwoLog.printStackTrace(e);
		}
		onStateChanged(MediaState.Stop);
	}
	
	@Override
	public int getDuration(){
		return player.getDuration();
	}
	
	public int getPosition(){
		if (player != null)
			return player.getCurrentPosition();
		return 0;
	}
	
	public void setOnPreparedListener(OnPreparedListener listener){
		player.setOnPreparedListener(listener);
	}
	
	public void setOnBufferingUpdateListener(OnBufferingUpdateListener listener){
		player.setOnBufferingUpdateListener(listener);
	}

	public boolean isPlaying(){
		return state == MediaState.Active;
	}
	
	@Override
	public void seekTo(int msec) {
		if (player != null)
			player.seekTo(msec);
	}
	
	public void setVolumeToZero() {
		if (player != null)
			player.setVolume(0.0f, 0.0f);
	}
	
	public void setVolumeToOrig() {
		if (player != null){
			player.setVolume(fVolumeRate, fVolumeRate);
		}
	}
	
	public void setVolume(float fRate){
		if (player != null){
			fVolumeRate = fRate;
			if (player.isPlaying())
				player.setVolume(fRate, fRate);
		}
	}
	
	
	
	private LoopHandler mPlayHandler = new LoopHandler();
	private Runnable mPlayRunnable = new Runnable() {
		@Override
		public void run() {
			switch (state) {
			case Active:
				if (player != null)
					onPositionChanged(player.getCurrentPosition());
				break;
				
			case Pause:
			case Stop:
			case Complete:
				mPlayHandler.stop();
				break;

			default:
				break;
			}
		}
	};

	public void release() {
		if (player == null)
			return;
		player.release();
		player = null;
	}

	public void setDisplay(SurfaceHolder sh) {
		if (player != null)
			player.setDisplay(sh);
	}

}
