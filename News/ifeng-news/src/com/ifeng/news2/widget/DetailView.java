package com.ifeng.news2.widget;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings.LayoutAlgorithm;
import android.webkit.WebSettings.PluginState;
import android.webkit.WebSettings.RenderPriority;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ViewSwitcher;
import com.ifeng.news2.R;
import com.ifeng.news2.bean.IfengWebView;
import com.qad.inject.ResourceInjector;
import com.qad.util.IfengGestureDetector;
import com.qad.util.OnFlingListener;
import com.qad.util.WLog;

/**
 * 单页组件
 * 
 * @author 13leaf
 * 
 */
public class DetailView extends ViewSwitcher {

	WLog logger = WLog.getMyLogger(DetailView.class);

	public Boolean isMovedDetail;

	private String fromSource = "from_app";

	private IfengWebView webView;

	private LoadableViewWrapper wrapper;

	private View onTouchListener;

	private GestureDetector detector;

	private OnFlingListener onFlingListener ;
//	
//	public static final int FLING_LEFT = 1;
//	
//	public static final int FLING_RIGHT = 2;

	private boolean isFling;
	
	private boolean intercept;

	public DetailView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public DetailView(Context context) {
		super(context);
		init();
	}

	private void init() {
		webView = new IfengWebView(getContext());
		webView.setBackgroundColor(getResources().getColor(R.color.ivory2));
		wrapper = new LoadableViewWrapper(getContext(),
				webView);
		addView(wrapper); 
		ResourceInjector.inject(getContext(), this);
		decorate();		
	}

	/**
	 * 装饰一些WebView和Animation的设置
	 */
	@SuppressLint("SetJavaScriptEnabled")
	private void decorate() {
		WebChromeClient chromeClient = new WrapWebChrome();
		WebViewClient client = new WrapWebClient();
		webView.getSettings().setAppCacheEnabled(false);
		webView.getSettings().setSupportZoom(false);
		webView.getSettings().setJavaScriptEnabled(true);
//		webView.getSettings().setPluginsEnabled(true);
		webView.getSettings().setPluginState(PluginState.ON);
		webView.getSettings().setLayoutAlgorithm(LayoutAlgorithm.SINGLE_COLUMN);
		webView.getSettings().setRenderPriority(RenderPriority.HIGH);
		webView.getSettings().setDomStorageEnabled(true);
		webView.getSettings().setSupportMultipleWindows(false);
		webView.getSettings().setBlockNetworkLoads(false);
		webView.getSettings().setBuiltInZoomControls(false);
		webView.setHorizontalScrollBarEnabled(false);
		webView.setVerticalScrollBarEnabled(true);
		webView.setWebViewClient(new WebViewClient());
		webView.setWebChromeClient(chromeClient);
		webView.setWebViewClient(client);
	}

	public void setOnRetryListener(OnClickListener listener) {
		if (listener == null)
			return;

		wrapper.setOnRetryListener(new RetryFilter(
				wrapper, listener));
	}

	/**
	 * @author 13leaf
	 * 
	 */
	private final class RetryFilter implements OnClickListener {
		LoadableViewWrapper wrapper;
		OnClickListener delegate;

		public RetryFilter(LoadableViewWrapper wrapper, OnClickListener listener) {
			this.wrapper = wrapper;
			delegate = listener;
		}

		@Override
		public void onClick(View v) {
			if (getCurrentView() == wrapper)// 保守一点点
			{
				if(!isFling){
					delegate.onClick(wrapper.getWrappedView());
				}else{
					isFling = false;
				}
			}
		}
	}
	
//	public interface OnFlingListener{
//		public void onFling(int flingState);
//	}
	
	public void setOnFlingListener(OnFlingListener listener){
		//调用setOnFlingListener(null)可以阻止DetailView拦截MotionEvent
		this.onFlingListener  = listener;
		if(listener != null){
			detector = IfengGestureDetector.getInsensitiveIfengGestureDetector(listener);
		}
		
	}
	
	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {  
		if(intercept){
			return true;
		}
	    if (null != detector && onFlingListener != null) {
	        detector.onTouchEvent(ev);
	    }
//		if(detector.onTouchEvent(ev)){
//			isFling = true;
//		}
		touchEventHook();
		return super.onInterceptTouchEvent(ev);
	}
	
	public void setOnTouchListener(View v) {
		onTouchListener = v;
	}
	
	private void touchEventHook() {
		if (null != onTouchListener && onTouchListener.getVisibility() == View.VISIBLE) {
			onTouchListener.clearFocus();
		}
	}

	class WrapWebClient extends WebViewClient {
		@Override
		public void onPageStarted(WebView view, String url, Bitmap favicon) {
		}

		public void onPageFinished(WebView view, String url) {
		}
	}

	class WrapWebChrome extends WebChromeClient {
		@Override
		public void onProgressChanged(WebView view, int newProgress) {
		}
	}

	public void destroy() {
	    if (null != wrapper && null != webView) {
	        wrapper.removeAllViews();
	        webView.removeAllViews();
	        webView.destroy();
	    }
	}
	
	public void setIntercept(boolean intercept){
		this.intercept = intercept;
	}

	public String getFromSource() {
		return fromSource;
	}

	public void setFromSource(String fromSource) {
		this.fromSource = fromSource;
	}

}
