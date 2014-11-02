package com.qad.view.sliding;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.Scroller;

/**
 * It is a protected Class that is called by SlidingMenu for managing and
 * demonstrating the views.Using it out of the package is not Allowed.
 * {@link SlidingMenuAdapter} {@link SlidingMenu} associated with this view.
 * 
 * @author sunquan
 * 
 */
class SlidingView extends FrameLayout {

	private FrameLayout mContainer;
	private static final int SNAP_VELOCITY = 1000;
	private boolean mIsBeingDragged;
	private int mTouchSlop;
	private int mDisplayWidth;
	private float mLastMotionX;
	private float mLastMotionY;
	private View mLeftView;
	private View mRightView;
	private Scroller mScroller;
	private VelocityTracker mVelocityTracker;
	private int mMaximumVelocity;
	private ViewConfiguration configuration;

	public SlidingView(Context context) {
		super(context);
		init();
	}

	public SlidingView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public SlidingView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	@Override
	protected void onLayout(boolean changed, int l, int t, int r, int b) {
		final int width = r - l;
		final int height = b - t;
		mContainer.layout(0, 0, width, height);
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		mContainer.measure(widthMeasureSpec, heightMeasureSpec);
	}

	private void init() {
		mContainer = new FrameLayout(getContext());
		mScroller = new Scroller(getContext());
		configuration = ViewConfiguration.get(getContext());
		mTouchSlop = configuration.getScaledTouchSlop();
		mMaximumVelocity = configuration.getScaledMaximumFlingVelocity();
		WindowManager wm = (WindowManager) getContext().getSystemService(
				Context.WINDOW_SERVICE);
		mDisplayWidth = wm.getDefaultDisplay().getWidth();
		super.addView(mContainer);
	}

	public void setView(View v) {
		if (mContainer.getChildCount() > 0) {
			mContainer.removeAllViews();
		}
		mContainer.addView(v);
	}

	@Override
	public void scrollTo(int x, int y) {
		if (x < -getLeftViewWidth()) {
			x = -getLeftViewWidth();
		} else if (x > getRightViewWidth()) {
			x = getRightViewWidth();
		}
		super.scrollTo(x, y);
		postInvalidate();
	}

	@Override
	public void computeScroll() {
		if (!mScroller.isFinished() && mScroller.computeScrollOffset()) {
			int oldX = getScrollX();
			int oldY = getScrollY();
			int x = mScroller.getCurrX();
			int y = mScroller.getCurrY();
			if (oldX != x || oldY != y)
				scrollTo(x, y);
			postInvalidate();
		} else
			clearChildrenCache();
	}

	public boolean isShowRightView() {
		if (getScrollX() <= getRightViewWidth() && getScrollX() > 0) {
			return true;
		}
		return false;
	}

	public boolean isShowLeftView() {
		if (getScrollX() >= -getLeftViewWidth() && getScrollX() < 0) {
			return true;
		}
		return false;
	}

//	@Override
//	public boolean onInterceptTouchEvent(MotionEvent ev) {
//		final int action = ev.getAction();
//		final float x = ev.getX();
//		final float y = ev.getY();
//		switch (action) {
//		case MotionEvent.ACTION_DOWN:
//			mLastMotionX = x;
//			mLastMotionY = y;
//			mIsBeingDragged = false;
//			if (getScrollX() >= -getLeftViewWidth() && getScrollX() < 0
//					&& mLastMotionX > getLeftViewWidth() && mLeftView != null) {
//				showLeftView();
//				return true;
//			} else if (getScrollX() <= getRightViewWidth() && getScrollX() > 0
//					&& mLastMotionX < mDisplayWidth - getRightViewWidth()
//					&& mRightView != null) {
//				showRightView();
//				return true;
//			}
//
//		case MotionEvent.ACTION_MOVE:
//			final float xDiff = Math.abs(x - mLastMotionX);
//			final float yDiff = Math.abs(y - mLastMotionY);
//			if (xDiff > mTouchSlop && xDiff > yDiff) {
//				mIsBeingDragged = true;
//			}
//			break;
//		}
//		return mIsBeingDragged;
//	}

//	@Override
//	public boolean onTouchEvent(MotionEvent ev) {
//		if (mVelocityTracker == null)
//			mVelocityTracker = VelocityTracker.obtain();
//		mVelocityTracker.addMovement(ev);
//		final int action = ev.getAction();
//		final float x = ev.getX();
//		final float y = ev.getY();
//		switch (action) {
//		case MotionEvent.ACTION_DOWN:
//			mLastMotionX = x;
//			mLastMotionY = y;
//			mIsBeingDragged = false;
//			if (getScrollX() == -getLeftViewWidth()
//					&& mLastMotionX < getLeftViewWidth()) {
//				return false;
//			}
//			if (getScrollX() == getRightViewWidth()
//					&& mLastMotionX > mDisplayWidth - getRightViewWidth()) {
//				return false;
//			}
//			break;
//
//		case MotionEvent.ACTION_MOVE:
//			if (mIsBeingDragged) {
//				enableChildrenCache();
//				final float deltaX = mLastMotionX - x;
//				mLastMotionX = x;
//				float oldScrollX = getScrollX();
//				float scrollX = oldScrollX + deltaX;
//				if (deltaX < 0 && oldScrollX < 0) { // left view
//					final float leftBound = 0;
//					final float rightBound = -getLeftViewWidth();
//
//					if (scrollX > leftBound)
//						scrollX = leftBound;
//					else if (scrollX < rightBound)
//						scrollX = rightBound;
//
//				} else if (deltaX > 0 && oldScrollX > 0) { // right view
//					final float rightBound = (getChildCount() - 1) * getWidth()
//							+ getRightViewWidth();
//					final float leftBound = 0;
//					if (scrollX < leftBound)
//						scrollX = leftBound;
//					else if (scrollX > rightBound)
//						scrollX = rightBound;
//				}
//				if (mLeftView == null) {
//					if (scrollX >= 0) {
//						scrollTo((int) scrollX, getScrollY());
//					}
//				} else {
//					scrollTo((int) scrollX, getScrollY());
//				}
//			}
//			break;
//		case MotionEvent.ACTION_CANCEL:
//		case MotionEvent.ACTION_UP:
//			if (mIsBeingDragged) {
//				final VelocityTracker velocityTracker = mVelocityTracker;
//				velocityTracker.computeCurrentVelocity(1000, mMaximumVelocity);
//				int velocityX = (int) velocityTracker.getXVelocity();
//				int oldScrollX = getScrollX();
//				int dx = 0;
//				if (oldScrollX < 0) {
//					if (oldScrollX < -getLeftViewWidth() / 4
//							|| velocityX > SNAP_VELOCITY)
//						dx = -getLeftViewWidth() - oldScrollX;
//					else if (oldScrollX >= -getLeftViewWidth() / 4
//							|| velocityX < -SNAP_VELOCITY)
//						dx = -oldScrollX;
//				} else if (oldScrollX > 0) {
//					if (oldScrollX > getRightViewWidth() / 4
//							|| velocityX < -SNAP_VELOCITY)
//						dx = getRightViewWidth() - oldScrollX;
//					else if (oldScrollX <= getRightViewWidth() / 4
//							|| velocityX > SNAP_VELOCITY)
//						dx = -oldScrollX;
//				}
//				smoothScrollTo(dx);
//				clearChildrenCache();
//			}
//			break;
//		}
//		if (mVelocityTracker != null) {
//			mVelocityTracker.recycle();
//			mVelocityTracker = null;
//		}
//		return true;
//	}

	private int getLeftViewWidth() {
		if (mLeftView == null) {
			return 0;
		}
		return mLeftView.getWidth();
	}

	private int getRightViewWidth() {
		if (mRightView == null) {
			return 0;
		}
		return mRightView.getWidth();
	}

	public void setRightView(View mDetailView) {
		this.mRightView = mDetailView;
	}

	public void setLeftView(View mMenuView) {
		this.mLeftView = mMenuView;
	}

	public void showLeftView() {
		if (mLeftView != null) {
			int menuWidth = mLeftView.getWidth();
			int oldScrollX = getScrollX();
			if (oldScrollX == 0) {
				smoothScrollTo(-menuWidth);
			} else if (oldScrollX == -menuWidth) {
				smoothScrollTo(menuWidth);
			}
		}
	}

	public void showRightView() {
		if (mRightView != null) {
			int menuWidth = mRightView.getWidth();
			int oldScrollX = getScrollX();
			if (oldScrollX == 0) {
				smoothScrollTo(menuWidth);
			} else if (oldScrollX == menuWidth) {
				smoothScrollTo(-menuWidth);
			}
		}
	}

	private void smoothScrollTo(int dx) {
		int duration = 500;
		int oldScrollX = getScrollX();
		mScroller.startScroll(oldScrollX, getScrollY(), dx, getScrollY(),
				duration);
		invalidate();
	}

	private void enableChildrenCache() {
		final int count = getChildCount();
		for (int i = 0; i < count; i++) {
			final View layout = (View) getChildAt(i);
			layout.setDrawingCacheEnabled(true);
		}
	}

	private void clearChildrenCache() {
		final int count = getChildCount();
		for (int i = 0; i < count; i++) {
			final View layout = (View) getChildAt(i);
			layout.setDrawingCacheEnabled(false);
		}
	}
}
