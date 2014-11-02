package com.ifeng.news2.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;

import com.ifeng.news2.R;


/**
 * 包装一个视图。进入时处于载入状态,载入完成后通过showNormal显示目标。如果载入失败则通过showRetryView显示失败重试界面。<br>
 * 可通过setOnRetryListener来监听当点击重试后的反应动作。
 * @author 13leaf
 *
 */
public class LoadableViewWrapper extends StateSwitcher {

	public LoadableViewWrapper(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public LoadableViewWrapper(Context context, View normalView) {
		super(context, normalView, null,null);
	}
	
	public LoadableViewWrapper(Context context, View normalView, View retryView, View loadingView) {
		super(context, normalView, retryView, loadingView);
	}
	
	@Override
	protected View initLoadingView() {
		return LayoutInflater.from(getContext()).inflate(R.layout.loading, null);
	}
	
	@Override
	protected View initRetryView() {
		return LayoutInflater.from(getContext()).inflate(R.layout.load_fail, null);
	}
	
	/**
	 * 返回被包装的视图
	 * @return
	 */
	public View getWrappedView()
	{
		return normalView;
	}
	
	public void setOnRetryListener(View.OnClickListener listener)
	{
		retryView.setOnClickListener(listener);
	}

}
