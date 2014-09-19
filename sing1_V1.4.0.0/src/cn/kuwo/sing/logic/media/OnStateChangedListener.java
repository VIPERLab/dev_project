package cn.kuwo.sing.logic.media;


public interface OnStateChangedListener {
	public enum MediaState {
//		Prepared,
		Active,
		Pause,
		Stop,
		Complete
	}
	
	void onStateChanged(MediaState state);
}
