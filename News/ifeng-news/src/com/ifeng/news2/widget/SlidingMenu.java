package com.ifeng.news2.widget;

import com.ifeng.news2.widget.SlidingCenterView.OnScrolledListener;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;

/**
 * 
 * @author sunquan
 * 
 */
public class SlidingMenu extends RelativeLayout {

	private SlidingCenterView mSlidingView;
	private View mLeftView;

	public SlidingMenu(Context context) {
		super(context);
	}

	public SlidingMenu(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public SlidingMenu(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	public void setAdapter(SlidingMenuAdapter adapter) {
		setLeftView(adapter.getLeftView());
		setCenterView(adapter.getCenterView(),adapter.getShadowDrawable());
		mSlidingView.setOnScrolledListener(adapter.getOnScrolledListener());
	}

	private void setLeftView(View view) {
		if (view == null) {
			return;
		}
		LayoutParams behindParams = new LayoutParams(LayoutParams.MATCH_PARENT,
				LayoutParams.MATCH_PARENT);
		addView(view, behindParams);
		mLeftView = view;
	}

	private void setCenterView(View view,Drawable shadowDrawble) {
		if (view == null) {
			throw new RuntimeException("The center view should not be null!");
		}
		LayoutParams aboveParams = new LayoutParams(LayoutParams.MATCH_PARENT,
				LayoutParams.MATCH_PARENT);
		mSlidingView = new SlidingCenterView(getContext());
		mSlidingView.setmShadowDrawable(shadowDrawble);
		mSlidingView.setShadowWidth(shadowDrawble.getMinimumWidth());
		addView(mSlidingView, aboveParams);
		mSlidingView.setView(view);
		mSlidingView.invalidate();
		mSlidingView.setLeftView(mLeftView);
	}

	/**
	 * showing the right view if the left view is not null and the left view is
	 * invisible hiding the right view if the left view is being showed
	 * 
	 */
	public void showLeftView() {
		mSlidingView.showLeftView();
	}


	/**
	 * judge if the left view is being showed
	 * 
	 * @return true if left view is being showed
	 */
	public boolean isShowLeftView() {
		return mSlidingView.isShowLeftView();
	}
	
	public interface SlidingMenuAdapter {

		public View getCenterView();

		public View getLeftView();

		public Drawable getShadowDrawable();
		
		public OnScrolledListener getOnScrolledListener();
	}

}
