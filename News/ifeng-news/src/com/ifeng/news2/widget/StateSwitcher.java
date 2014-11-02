package com.ifeng.news2.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AndroidRuntimeException;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ViewAnimator;

import com.ifeng.news2.R.styleable;
import com.qad.lang.Lang;
import com.qad.loader.RetryListener;
import com.qad.loader.StateAble;

/**
 * 包含了状态转换机。通过showLoading/Normal/Retry的方法来更改视图显示。<br>
 * loading,Retry视图可以通过覆盖本类的initXXX的方法来重载样式。
 * 也可以直接在xml资源文件中指定retryLayout和loadingLayou<br>
 * 视图默认从loading模式开始
 * 
 * @author wangfeng
 */
public class StateSwitcher extends ViewAnimator implements StateAble {

	public final static int STATE_LOADING = 0;

	public final static int STATE_NORMAL = 1;

	public final static int STATE_RETRY = 2;

	private int currentState = STATE_LOADING;

	protected View loadingView;

	protected View normalView;

	protected View retryView;

	protected View retryTrigger;
	
	protected LayoutParams layoutParams = new LayoutParams(
			LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);

	public StateSwitcher(Context context, AttributeSet attrs) {
		super(context, attrs);

		TypedArray a = context.obtainStyledAttributes(attrs, styleable.StateSwitcher);
		int retryRes = a.getResourceId(styleable.StateSwitcher_retryLayout, -1);
		if (retryRes != -1)
			retryView = LayoutInflater.from(context).inflate(retryRes, null);
		int loadingRes = a.getResourceId(styleable.StateSwitcher_loadingLayout, -1);
		if (loadingRes != -1) {
			loadingView = LayoutInflater.from(context).inflate(loadingRes, null);
		}
		a.recycle();
		View tempNormal = initNormalView();
		if (tempNormal != null) addView(tempNormal);
	}

	/**
	 * @param context
	 * @param normalView
	 * @param retryView
	 *            可空,但必须重写initRetryView
	 * @param loadingView
	 *            可空,但必须重写initLoadingView
	 */
	public StateSwitcher(Context context, View normalView, View retryView,
			View loadingView) {
		super(context);
		this.retryView = retryView;
		this.loadingView = loadingView;
		addView(normalView);
		init();
	}

	public int getCurrentState() {
		return currentState;
	}

	@Override
	protected void onFinishInflate() {
		super.onFinishInflate();
		init();
	}

	private void init() {
		if (getChildCount() != 1) {
			throw new AndroidRuntimeException("StateSwitcher can only have one child! " + getChildCount());
		}
		// prepare views
		normalView = getChildAt(0);
		removeViewAt(0);
		if (loadingView == null)
			loadingView = initLoadingView();
		if (retryView == null)
			retryView = initRetryView();
		if (loadingView == null || retryView == null)
			throw new AndroidRuntimeException("Invalidate loadingView or retryView.");
		addView(loadingView, STATE_LOADING, layoutParams);
		addView(normalView, STATE_NORMAL, layoutParams);
		addView(retryView, STATE_RETRY, layoutParams);
		retryTrigger = retryView;
	}

	/**
	 * 子类覆写此处自定义需要的样式
	 * 
	 * @return
	 */
	protected View initLoadingView() {
		Lang.noImplement();
		return null;
	}

	/**
	 * 子类覆写此处自定义需要的样式
	 * 
	 * @return
	 */
	protected View initRetryView() {
		Lang.noImplement();
		return null;
	}

	/**
	 * 子类覆写此处可以获得更加灵活的编程风格
	 * 
	 * @return
	 */
	protected View initNormalView() {
		return null;
	}

	public void showLoading() {
		currentState = STATE_LOADING;
		setDisplayedChild(currentState);
	}

	public void showNormal() {
		currentState = STATE_NORMAL;
		setDisplayedChild(currentState);
	}

	public void showRetryView() {
		currentState = STATE_RETRY;
		setDisplayedChild(currentState);
	}

	@Override
	public void setOnRetryListener(final RetryListener listener) {
		if (listener == null)
			return;
		retryTrigger.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				listener.onRetry(v);
			}
		});
	}

	@Override
	public void setTargetView(View view) {
		retryTrigger = view;
		if (retryTrigger == null)
			retryTrigger = retryView;
	}

}
