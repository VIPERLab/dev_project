package com.ifeng.news2.widget;

import com.qad.util.IfengGestureDetector;
import com.qad.util.OnFlingListener;
import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.RelativeLayout;

/** 
 * 支持滑动的relativeLayout
 * 
 * @author SunQuan: 
 * @version 创建时间：2013-11-12 下午3:22:14 
 * 类说明 
 */

public class RelativeLayoutWithFlingDetector extends RelativeLayout {

	private IfengGestureDetector detector ;
	public RelativeLayoutWithFlingDetector(Context context, AttributeSet attrs,
			int defStyle) {
		super(context, attrs, defStyle);
		// TODO Auto-generated constructor stub
	}

	public RelativeLayoutWithFlingDetector(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
	}
	

	public RelativeLayoutWithFlingDetector(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
	}

	/**
	 * 设置滑动监听
	 */
	public void setOnFlingListener(OnFlingListener listener){
		setLongClickable(true);
		detector = IfengGestureDetector.getInsensitiveIfengGestureDetector(listener);
	}
	
	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {
	    if (null != detector&&detector.onTouchEvent(ev)) {
	        return true;
	    }
	    return super.onInterceptTouchEvent(ev);
	}
	
	@Override
	public boolean onTouchEvent(MotionEvent ev) {
		 if (null != detector&&detector.onTouchEvent(ev)) {
		        return true;
		 }
		 return super.onTouchEvent(ev);
	}
}
