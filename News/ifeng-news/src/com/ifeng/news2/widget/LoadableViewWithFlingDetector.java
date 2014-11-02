package com.ifeng.news2.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import com.qad.util.IfengGestureDetector;
import com.qad.util.OnFlingListener;
import com.qad.view.PageListView;

/**
 * LoadableViewWrapper的包装类，增加了滑动监听
 * @author chenxi
 *
 */
public class LoadableViewWithFlingDetector extends LoadableViewWrapper {

	private IfengGestureDetector detector ;
	
	public LoadableViewWithFlingDetector(Context context, View normalView,
			View retryView, View loadingView) {
		super(context, normalView, retryView, loadingView);
	}

	public LoadableViewWithFlingDetector(Context context, View normalView) {
		super(context, normalView);
	}

	public LoadableViewWithFlingDetector(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	
	/**
	 * 设置滑动监听
	 */
	public void setOnFlingListener(OnFlingListener listener){
		if(getWrappedView() instanceof ChannelList) {
			((ChannelList)getWrappedView()).setOnFlingListener(listener);
		}
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
