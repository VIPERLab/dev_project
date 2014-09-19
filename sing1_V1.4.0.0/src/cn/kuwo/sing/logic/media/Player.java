package cn.kuwo.sing.logic.media;

import android.os.Handler;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.logic.media.OnStateChangedListener.MediaState;

public abstract class Player {
	private final String TAG = "Player";
	
	public MediaState state;
	public long position;
	
	public abstract int open(String path);
	
	public abstract int openAsync(String path);
	
	public abstract void start();
	
	public abstract void pause();
	
	public abstract void stop();
	
	public abstract void seekTo(int position);
	
	public abstract int getDuration();
	
	protected OnStateChangedListener onStateChangedListener;
	public void setOnStateChangedListener(OnStateChangedListener listener) {
		this.onStateChangedListener = listener;
	}
	
	protected OnPositionChangedListener onPositionChangedListener;
	public void setOnPositionChangedListener(OnPositionChangedListener listener) {
		this.onPositionChangedListener = listener;
	}
		
	protected Handler handler = new Handler();
	protected void onPositionChanged(final long position) {
		this.position = position;
		if (onPositionChangedListener != null)
			handler.post(new Runnable() {
				@Override
				public void run() {
					onPositionChangedListener.onPositionChanged(position);
				}
			});
	}
	
	protected void onStateChanged(final MediaState state) {
		this.state = state;
		if (onStateChangedListener != null)
			handler.post(new Runnable() {
				@Override
				public void run() {
					onStateChangedListener.onStateChanged(state);
				}
			});
		
		KuwoLog.d(TAG, "onStateChanged: " + state);
	}
}
