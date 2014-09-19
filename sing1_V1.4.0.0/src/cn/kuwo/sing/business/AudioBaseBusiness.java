package cn.kuwo.sing.business;

import android.view.Surface;
import cn.kuwo.sing.logic.media.OnDataProcessListener;
import cn.kuwo.sing.logic.media.OnPositionChangedListener;
import cn.kuwo.sing.logic.media.OnStateChangedListener;

public interface AudioBaseBusiness{

	public static int EXCEPTION_FILE_NOT_FOND = -1;
	
	public abstract int prepare(String rid);

	public abstract void start();

	public abstract void pause();

	public abstract void toggle();

	/**
	 * 
	 * @param rid
	 * 		null 表示不保存
	 */
	public abstract void stop(String rid);

	public abstract long getDuration();
	
	public abstract void switchPlayer();
	
	public abstract void setPreviewDisplay(Surface surface);
	
	public abstract void setOnDataProcessListener(OnDataProcessListener listener);

	public abstract void setOnPositionChangedListener(OnPositionChangedListener listener);

	public abstract void setOnStateChanged(OnStateChangedListener listener);
	
	public abstract void release();
	
	public abstract void setSingerVolume(float fRate);
	
	public abstract void setMusicVolume(float fRate);
	
	public abstract boolean setSync(int fTime);	//负数表示人声提前，正数表示人声滞后
	
}