package com.qad.view.sliding;

import android.view.View;

/**
 * That is the bridge between a {@link SlidingMenu} and the child views that
 * backs the view. Frequently that view comes from a ViewGroup, but that is not
 * required. The ListView can display any views provided that it is wrapped in a
 * SlidingMenuAdapter.
 * {@link SlidingMenu}   {@link SlidingView} associated with this view.
 * 
 * @author sunquan
 */
public interface SlidingMenuAdapter {

	public View getCenterView();

	public View getLeftView();

	public View getRightView();

}
