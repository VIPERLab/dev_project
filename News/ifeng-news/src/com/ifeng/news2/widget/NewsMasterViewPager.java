package com.ifeng.news2.widget;

import android.content.Context;
import android.support.v4.view.ViewPager;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewConfiguration;

/** 
 * @author SunQuan: 
 * @version 创建时间：2013-11-12 上午11:33:15 
 * 类说明 
 */

public class NewsMasterViewPager extends ViewPager {

	public static boolean isLeftMargin = true;
	private float mLastMotionX;
	private float mLastMotionY;
	private int mTouchSlop;
	public NewsMasterViewPager(Context context) {
		super(context);
		init();
	}

	private void init() {
		mTouchSlop = ViewConfiguration.get(getContext()).getScaledTouchSlop();
	}

	public NewsMasterViewPager(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}
	

	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {
		final float x = ev.getX();
		final float y = ev.getY();
		switch (ev.getAction()) {
		case MotionEvent.ACTION_DOWN:
			mLastMotionX = x;
			mLastMotionY = y;
            //此句代码是为了通知他的父ViewPager现在进行的是本控件的操作，不要对我的操作进行干扰
            getParent().requestDisallowInterceptTouchEvent(true);
			break;
		case MotionEvent.ACTION_MOVE:
			final float xDiff = Math.abs(x - mLastMotionX);
			final float yDiff = Math.abs(y - mLastMotionY);
			//viewPager滑到了第一张并且继续向右滑动
			if (mLastMotionX < x&& xDiff > mTouchSlop && xDiff > yDiff && getCurrentItem() == 0) {
				getParent().requestDisallowInterceptTouchEvent(false);
			} 
			break;
		default:
			getParent().requestDisallowInterceptTouchEvent(false);
			break;
		}
		try {
			return super.onInterceptTouchEvent(ev);
		} catch (Exception e) {
			return false;
		}
		
	}
}
