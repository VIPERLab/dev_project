package com.qad.loader;

import android.view.View;

/**
 * 提供切换状态视图的能力
 * 
 * @author 13leaf
 * 
 */
public interface StateAble {
	
	public static final int STATE_LOADING = 1;
	public static final int STATE_NORMAL = 2;
	public static final int STATE_RETRY = 3;

	public int getCurrentState();

	public void showLoading();

	public void showNormal();

	public void showRetryView();

	/**
	 * 设置引发重试事件的视图
	 * 
	 * @param view
	 */
	public void setTargetView(View view);

	/**
	 * 设置重试监听
	 * 
	 * @param listener
	 */
	public void setOnRetryListener(RetryListener listener);
}
