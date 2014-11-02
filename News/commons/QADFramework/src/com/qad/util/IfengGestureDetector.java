package com.qad.util;

import android.view.GestureDetector;
import android.view.MotionEvent;

public class IfengGestureDetector extends GestureDetector {

	/**
	 * 得到敏感的手势滑动detector
	 * 
	 * @param onFlingListener
	 * @return
	 */
	public static IfengGestureDetector getSensitiveIfengGestureDetector(OnFlingListener onFlingListener){
		return new IfengGestureDetector(new SensitiveGestureListener(onFlingListener));
	}
	
	/**
	 * 得到不敏感的手势滑动detector
	 * 
	 * @param onFlingListener
	 * @return
	 */
	public static IfengGestureDetector getInsensitiveIfengGestureDetector(OnFlingListener onFlingListener){
		return new IfengGestureDetector(new InsensitiveGestureListener(onFlingListener));
	}
	
	@SuppressWarnings("deprecation")
	private IfengGestureDetector(OnGestureListener listener) {
		super(listener);
	}

	/**
	 * 不敏感的滑动手势
	 * 
	 * @author SunQuan
	 *
	 */
	private static final class InsensitiveGestureListener extends SimpleOnGestureListener{
		
		 private OnFlingListener onFlingListener;
		 public InsensitiveGestureListener(OnFlingListener onFlingListener){
			 this.onFlingListener = onFlingListener;
		 }
		 @Override
         public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
                 float velocityY) {
         	if(e1==null){
        		return false;
        	}
            if((e1.getX()-e2.getX()<-100&&Math.abs(e1.getY()-e2.getY())<100)&&velocityX > 300 && Math.abs(velocityY)<1600){
            	if(onFlingListener != null){
                    onFlingListener.onFling(OnFlingListener.FLING_RIGHT);
                    return true;
                }
            }else if((e1.getX()-e2.getX()>100&&Math.abs(e1.getY()-e2.getY())<100)&&velocityX < -300 && Math.abs(velocityY)<1600){
                onFlingListener.onFling(OnFlingListener.FLING_LEFT);
                return true;
            }
            return false;
		 }
	}
	 
	/**
	 * 敏感的手势滑动
	 * 
	 * @author SunQuan
	 *
	 */
	private static final class SensitiveGestureListener extends SimpleOnGestureListener{
		
		 private OnFlingListener onFlingListener;
		 public SensitiveGestureListener(OnFlingListener onFlingListener){
			 this.onFlingListener = onFlingListener;
		 }
		 @Override
        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
                float velocityY) {
			 if (e1 == null) {
					// 防止滑动事件起初被截断
					return false;
				}
				// 右滑：判断条件：1，x方向的位移小于-100 2，y方向的位移小于x方向的位移 3，x方向的加速度大于100
				// 4，x方向的加速度大于y方向的加速度
				if ((e1.getX() - e2.getX() < -100
						&& Math.abs(e1.getX() - e2.getX()) > Math.abs(e1.getY()
								- e2.getY())) ||(velocityX > 50
						&& Math.abs(velocityX) > Math.abs(velocityY))) {
					if (onFlingListener != null) {
						onFlingListener.onFling(OnFlingListener.FLING_RIGHT);
						return true;
					}
				}
				// 左滑：判断条件：1，x方向的位移大于100 2，y方向的位移小于x方向的位移 3，x方向的加速度大于100
				// 4，x方向的加速度大于y方向的加速度
				else if ((e1.getX() - e2.getX() > 100
						&& Math.abs(e1.getX() - e2.getX()) > Math.abs(e1.getY()
								- e2.getY())) || (velocityX < -50
						&& Math.abs(velocityX) > Math.abs(velocityY))) {
					onFlingListener.onFling(OnFlingListener.FLING_LEFT);
					return true;
				}
				return false;
			}
	} 
	
}
