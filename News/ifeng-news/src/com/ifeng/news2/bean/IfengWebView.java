package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.Map;

import android.annotation.TargetApi;
import android.content.Context;
import android.util.Log;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.webkit.WebView;

public class IfengWebView extends WebView implements Serializable {

	private static final long serialVersionUID = 5938447365539494405L;
	private ScaleGestureDetector detector;
	private boolean isDestroy = false;
	
	public IfengWebView(Context context) {
		super(context);
	}
	
	//ScaleGestureDetector是在android 8 以后才有的
	@TargetApi(8)
	public void setScaleGestureDetector(ScaleGestureDetector detector) {
		this.detector = detector;
	}
	
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		if(detector!=null){
			// fix crash exception: 
			// java.lang.ArrayIndexOutOfBoundsException#android.view.MotionEvent.getX(MotionEvent.java:950)	
			// android.view.ScaleGestureDetector.setContext(ScaleGestureDetector.java:345)	
			// android.view.ScaleGestureDetector.onTouchEvent(ScaleGestureDetector.java:292)
			// com.ifeng.news2.bean.IfengWebView.onTouchEvent(IfengWebView.java:29)
			try {
				detector.onTouchEvent(event);
			} catch (Exception e) {
				// just ignore
				return true;
			}
		}
		return super.onTouchEvent(event);
	}
	
	//webview调用destroy时会把mWebViewCore设置为空，造成loadUrl时候报空指针。添加isDestroy变量判断当前webview是否被销毁。
	@Override 
    public void destroy() { 
		isDestroy = true; 
        super.destroy(); 
    } 
    
    @Override
    public void loadUrl(String url) {
    	if(isDestroy){
    		Log.e("Debug", "webView has destroy");
    		return; 
    	}
    	super.loadUrl(url);
    }
}
