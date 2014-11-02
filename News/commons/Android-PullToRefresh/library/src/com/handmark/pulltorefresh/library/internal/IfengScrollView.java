package com.handmark.pulltorefresh.library.internal;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ScrollView;

import com.qad.util.IfengGestureDetector;
import com.qad.util.OnFlingListener;

public class IfengScrollView extends ScrollView {

	private View onTouchListener;
	private IfengGestureDetector detector = null;

	public IfengScrollView(Context context) {
		super(context);
	}

	public IfengScrollView(Context context, AttributeSet attrs) {
		super(context, attrs);
	} 

	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {
		if (null != onTouchListener && onTouchListener.getVisibility() == View.VISIBLE) {
			onTouchListener.clearFocus();
			return true;
		}
		if (null != detector) {
            detector.onTouchEvent(ev);
        }
		return super.onInterceptTouchEvent(ev);
	}
	
	@Override
	public boolean onTouchEvent(MotionEvent ev) {
	    if (null != detector) {
            detector.onTouchEvent(ev);
        }
	    return super.onTouchEvent(ev);
	}

	public void setOnTouchListener(View v) {
		onTouchListener = v;
	}
	
	public void setOnFlingListener(OnFlingListener listener) {
	    detector = new IfengGestureDetector(listener);
	}

}
