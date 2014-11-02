package com.ifeng.news2.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.ListView;

import com.qad.util.IfengGestureDetector;
import com.qad.util.OnFlingListener;

/**
 * ListView的包装类，增加了滑动监听
 * @author chenxi
 *
 */
public class ListViewWithFlingDetector extends ListView {

	private IfengGestureDetector detector ;
	
	public ListViewWithFlingDetector(Context context) {
		super(context);
	}

	public ListViewWithFlingDetector(Context context, AttributeSet attrs) {
		super(context, attrs);
	}
	
	public ListViewWithFlingDetector(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}
	
	/**
	 * 设置滑动监听
	 * @param listener
	 */
	public void setOnFlingListener(OnFlingListener listener){
		detector = IfengGestureDetector.getInsensitiveIfengGestureDetector(listener);
	}
	
	@Override
	public boolean onTouchEvent(MotionEvent ev) {
		 if (null != detector&&detector.onTouchEvent(ev)) {
		        return true;
		 }
		 return super.onTouchEvent(ev);
	}
	
}
