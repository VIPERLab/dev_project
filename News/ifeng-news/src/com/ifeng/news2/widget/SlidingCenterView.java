package com.ifeng.news2.widget;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewConfiguration;
import android.widget.FrameLayout;
import android.widget.Scroller;

/**
 * 凤凰新闻频道列表的容器，可以右滑出去
 * 
 * @author sunquan
 * 
 */
public class SlidingCenterView extends FrameLayout {

	private static final int SNAP_VELOCITY = 100;
	private boolean mIsBeingDragged;
	private int mTouchSlop;
	private float mLastMotionX;
	private float mLastMotionY;
	private VelocityTracker mVelocityTracker;
	private int mMaximumVelocity;
	private ViewConfiguration configuration;
	private FrameLayout mContainer;
	private View mLeftView;
	private Scroller mScroller;
	//右滑出去的阴影
	private Drawable mShadowDrawable;
	//阴影的宽度
	private int shadowWidth;
	
	private OnScrolledListener onScrolledListener;
	
	
	
	public OnScrolledListener getOnScrolledListener() {
		return onScrolledListener;
	}

	public void setOnScrolledListener(OnScrolledListener onScrolledListener) {
		this.onScrolledListener = onScrolledListener;
	}

	public void setShadowWidth(int shadowWidth) {
		this.shadowWidth = shadowWidth;
	}

	public void setmShadowDrawable(Drawable mShadowDrawable) {
		this.mShadowDrawable = mShadowDrawable;
	}

	public SlidingCenterView(Context context) {
		super(context);
		init();
	}

	public SlidingCenterView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public SlidingCenterView(Context context, AttributeSet attrs, int defStyle) {
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
	
	@Override
	protected void dispatchDraw(Canvas canvas) {		
		super.dispatchDraw(canvas);			
		if (mShadowDrawable == null) return;
		int left = getLeft() - shadowWidth;
		mShadowDrawable.setBounds(left, 0, left + shadowWidth, getHeight());
		//如果已经滑到了边界则让阴影消失
		if(isShowLeftView()) {
			mShadowDrawable.setBounds(0, 0, 0, 0);
		}
		mShadowDrawable.draw(canvas);		
	}

	private void init() {
		mContainer = new FrameLayout(getContext());
		mScroller = new Scroller(getContext());
		configuration = ViewConfiguration.get(getContext());
		mTouchSlop = configuration.getScaledTouchSlop();
		mMaximumVelocity = configuration.getScaledMaximumFlingVelocity();
		super.addView(mContainer);
	}

	public void setView(View v) {
		if (mContainer.getChildCount() > 0) {
			mContainer.removeAllViews();
		}
		mContainer.addView(v);
	}
	
	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {
		final int action = ev.getAction();
		final float x = ev.getX();
		final float y = ev.getY();
		switch (action) {
		case MotionEvent.ACTION_DOWN:
			mLastMotionX = x;
			mLastMotionY = y;
			mIsBeingDragged = false;

		case MotionEvent.ACTION_MOVE:
			final float xDiff = Math.abs(x - mLastMotionX);
			final float yDiff = Math.abs(y - mLastMotionY);
			//如果当前的viewpager已经滑到了左边界，并且有右滑的手势时，拦截事件，执行滑动
			if (NewsMasterViewPager.isLeftMargin && mLastMotionX < x && xDiff > mTouchSlop && xDiff > yDiff) {
				mIsBeingDragged = true;
			}
			break;
		}
		return mIsBeingDragged;
	}

	@Override
	public boolean onTouchEvent(MotionEvent ev) {
		if (mVelocityTracker == null)
			mVelocityTracker = VelocityTracker.obtain();
		mVelocityTracker.addMovement(ev);
		final int action = ev.getAction();
		final float x = ev.getX();
		final float y = ev.getY();
		switch (action) {
		case MotionEvent.ACTION_DOWN:
			mLastMotionX = x;
			mLastMotionY = y;
			mIsBeingDragged = false;
			//如果已经滑动到了右边界，并且点击左边视图时，不拦截
			if (getScrollX() == -getLeftViewWidth()
					&& mLastMotionX < getLeftViewWidth()) {
				return false;
			}			
			break;

		case MotionEvent.ACTION_MOVE:
			if (mIsBeingDragged) {
//				enableChildrenCache();
				final float deltaX = mLastMotionX - x;
				mLastMotionX = x;
				float oldScrollX = getScrollX();
				float scrollX = oldScrollX + deltaX;
				
				if (deltaX < 0 && oldScrollX < 0) { // left view
					final float leftBound = 0;
					final float rightBound = -getLeftViewWidth();
					//如果左边的view已经完全盖住，则停止滑动
					if (scrollX > leftBound)
						scrollX = leftBound;
					//如果左边的view已经完全显示出来，则停止滑动
					else if (scrollX < rightBound)
						scrollX = rightBound;

				} 	
				//执行滑动
				if (scrollX <= 0) {
						scrollTo((int) scrollX, getScrollY());
				} 
			}
			break;
		case MotionEvent.ACTION_CANCEL:
		case MotionEvent.ACTION_UP:
			if (mIsBeingDragged) {
				final VelocityTracker velocityTracker = mVelocityTracker;
				velocityTracker.computeCurrentVelocity(1000, mMaximumVelocity);
				int velocityX = (int) velocityTracker.getXVelocity();
				int oldScrollX = getScrollX();
				int dx = 0;
				//左边的view显示出来
				if (oldScrollX < 0) {
					//如果频道列表划出左边view大小的1/5或者x方向的加速度大于1000，则划出左边view
					if (oldScrollX < -getLeftViewWidth() / 5
							|| velocityX > SNAP_VELOCITY) {
						dx = -getLeftViewWidth() - oldScrollX;
					
					}
						
					//如果频道列表划回左边view大小的1/5或者x方向的加速度小于-1000，则划回频道列表
					else if (oldScrollX >= -getLeftViewWidth() / 5
							|| velocityX < -SNAP_VELOCITY)
						dx = -oldScrollX;
				} 
				//执行平滑操作
				smoothScrollTo(dx);
			}
			break;
		}
		//回收VelocityTracker
		if (mVelocityTracker != null) {
			mVelocityTracker.recycle();
			mVelocityTracker = null;
		}
		return true;
	}

	@Override
	public void scrollTo(int x, int y) {
		if (x < -getLeftViewWidth()) {
			x = -getLeftViewWidth();
		} 
		super.scrollTo(x, y);
		invalidate();
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
			invalidate();
		} 
	}

	/**
	 * 判断是否滑到了右边
	 * @return
	 */
	public boolean isShowLeftView() {
		if (getScrollX() == -getLeftViewWidth() && getScrollX() < 0) {
			return true;
		}
		return false;
	}

	/**
	 * 得到左边view的宽度
	 * @return
	 */
	private int getLeftViewWidth() {
		if (mLeftView == null) {
			return 0;
		}
		return mLeftView.getWidth();
	}

	/**
	 * 设置左边的view
	 * @param mMenuView
	 */
	public void setLeftView(View mMenuView) {
		this.mLeftView = mMenuView;
	}

	/**
	 * 平滑出左边view
	 */
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

	private void smoothScrollTo(int dx) {
		int duration = 600;
		int oldScrollX = getScrollX();
		mScroller.startScroll(oldScrollX, getScrollY(), dx, getScrollY(),
				duration);
		invalidate();
		if(onScrolledListener != null) {
			if(dx < 0) onScrolledListener.onViewSelected(OnScrolledListener.LEFT);
			else if(dx == mLeftView.getWidth()) onScrolledListener.onViewSelected(OnScrolledListener.RIGHT);
		}
	}
	
	public interface OnScrolledListener{
		public static final int LEFT = 0;
		public static final int RIGHT = 1;
		void onViewSelected(int direction);
	}
	
}
