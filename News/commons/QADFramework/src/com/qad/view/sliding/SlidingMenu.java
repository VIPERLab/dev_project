package com.qad.view.sliding;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;

/**
 * A view that manages the states of the view, it could be used to sliding among
 * left view,right view and center view,left view and right view is not
 * necessary,they can be null if you do not want to show come from the
 * {@link SlidingMenuAdapter}   {@link SlidingView} associated with this view.
 * 
 * @author sunquan
 * 
 */
public class SlidingMenu extends RelativeLayout {

	private SlidingView mSlidingView;
	private View mLeftView;
	private View mRightView;

	public SlidingMenu(Context context) {
		super(context);
	}

	public SlidingMenu(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public SlidingMenu(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	/**
	 * Sets the data behind this SlidingMenu.
	 * 
	 * The adapter passed to this method wrapped by a {@link SlidingMenuAdapter}
	 * , depending on the SlidingMenu features currently in use. For instance,
	 * adding center view and/or left view will cause the adapter to be wrapped.
	 * 
	 * @param adapter
	 *            The SlidingMenuAdapter which is responsible for maintaining
	 *            the data backing this slidingMenu and for producing left
	 *            view,center view and right view to represent an item in that
	 *            data set.
	 * 
	 */
	public void setAdapter(SlidingMenuAdapter adapter) {
		setLeftView(adapter.getLeftView());
		setRightView(adapter.getRightView());
		setCenterView(adapter.getCenterView());
	}

	private void setLeftView(View view) {
		if (view == null) {
			return;
		}
		LayoutParams behindParams = new LayoutParams(LayoutParams.WRAP_CONTENT,
				LayoutParams.FILL_PARENT);
		addView(view, behindParams);
		mLeftView = view;
	}

	private void setRightView(View view) {
		if (view == null) {
			return;
		}
		LayoutParams behindParams = new LayoutParams(LayoutParams.WRAP_CONTENT,
				LayoutParams.FILL_PARENT);
		behindParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
		addView(view, behindParams);
		mRightView = view;
	}

	private void setCenterView(View view) {
		if (view == null) {
			throw new RuntimeException("The center view should not be null!");
		}
		LayoutParams aboveParams = new LayoutParams(LayoutParams.FILL_PARENT,
				LayoutParams.FILL_PARENT);
		mSlidingView = new SlidingView(getContext());
		addView(mSlidingView, aboveParams);
		mSlidingView.setView(view);
		mSlidingView.invalidate();
		mSlidingView.setLeftView(mLeftView);
		mSlidingView.setRightView(mRightView);
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
	 * showing the right view if the right view is not null and the right view
	 * is invisible hiding the right view if the right view is being showed
	 * 
	 */
	public void showRightView() {
		mSlidingView.showRightView();
	}

	/**
	 * judge if the left view is being showed
	 * 
	 * @return true if left view is being showed
	 */
	public boolean isShowLeftView() {
		return mSlidingView.isShowLeftView();
	}

	/**
	 * judge if the right view is being showed
	 * 
	 * @return true if right view is being showed
	 */
	public boolean isShowRightView() {
		return mSlidingView.isShowRightView();
	}
}
