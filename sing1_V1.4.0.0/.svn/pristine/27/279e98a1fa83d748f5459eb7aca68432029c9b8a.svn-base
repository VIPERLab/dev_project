package cn.kuwo.sing.logic.media;

import android.os.Handler;
import android.view.Surface;
import cn.kuwo.sing.logic.media.OnStateChangedListener.MediaState;

public abstract class Recorder {
	
	private long start;	// 启动毫秒值
	public long position;	// 运行毫秒值
	public MediaState state;
	
	/**
	 * 正在录音错误
	 */
	public static final int ERROR_IS_RECORDING = -100;
	protected Handler handler = new Handler();

	public abstract int prepare();

	/**
	 * 开始或者继续录音
	 * @return 返回MinBufferSize，小于0时表示错误。ERROR_IS_RECORDING, AudioRecord.ERROR等。
	 */
	public int start(){
		start = System.currentTimeMillis();
		return 0;
	}

	public abstract void pause();

	public abstract void stop();
	
	public abstract void release();

	/**
	 * 停止并保存录音
	 * @param path
	 */
	public void stop(String path) {
		save(path);
		stop();
	}

	public abstract void save(String path);
	
	protected OnDataProcessListener onDataProcessListener;
	protected OnPositionChangedListener onPositionChangedListener;
	protected OnStateChangedListener onStateChangedListener;

	public void setOnDataProcessListener(OnDataProcessListener listener) {
		this.onDataProcessListener = listener;
	}

	protected void onDataProcess(final byte[] data) {
		long cur = System.currentTimeMillis();
		position += cur - start;
		start = cur;
//		onPositionChanged();
	
		if (onDataProcessListener != null)
			handler.post(new Runnable() {
				@Override
				public void run() {
					onDataProcessListener.onDataProcess(data);
				}
			});
	}


	public void setOnPositionChangedListener(OnPositionChangedListener listener) {
		this.onPositionChangedListener = listener;
	}
	
	public void setOnStateChangedListener(OnStateChangedListener listener) {
		onStateChangedListener = listener;
	}

	protected void onPositionChanged() {
		if (onPositionChangedListener != null)
			handler.post(new Runnable() {
				@Override
				public void run() {
					onPositionChangedListener.onPositionChanged(position);
				}
			});
	}

	protected void onStateChanged(final MediaState state, boolean recorderAvailable) {
		if(recorderAvailable)
			this.state = state;
		if (onStateChangedListener != null)
			handler.post(new Runnable() {
				@Override
				public void run() {
					onStateChangedListener.onStateChanged(state);
				}
			});
	}

	public void setPreviewDisplay(Surface surface) {
		
	}

}