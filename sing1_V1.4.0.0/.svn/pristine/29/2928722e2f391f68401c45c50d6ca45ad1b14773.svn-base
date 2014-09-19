package cn.kuwo.sing.ui.compatibility;

import java.util.HashMap;
import java.util.Map;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.webkit.DownloadListener;
import android.webkit.JsResult;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings.ZoomDensity;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.User;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.util.DialogUtils;

@SuppressLint("SetJavaScriptEnabled")
public class KuwoWebView extends FrameLayout {
	
	private final String TAG = "KuwoWebView";
	private Context mContext;
	private WebView mWebView;
	private RelativeLayout mErrorRelativeLayout;
	private RelativeLayout mPdRL;
	private RelativeLayout mProgressDialog;
	private ImageView mErrorImageView;
	private final String PREFIX = "kwsing://";
	private String lastOrder;
	private long lastOrderTime;

	public KuwoWebView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		mContext = context;
		setBackgroundColor(Color.TRANSPARENT);
		init(context);
	}

	public KuwoWebView(Context context, AttributeSet attrs) {
		super(context, attrs);
		mContext = context;
		init(context);
	}

	public KuwoWebView(Context context) {
		super(context);
		mContext = context;
		init(context);
	}
	

	public interface OnOrderListener {
		void onOrder(String order, Map<String, String> params);
		void onPageStart();
		void onPageFinished();
		void onNoServerLoading();
	}
	
	private OnOrderListener mOnOrderListener;
	public void setOnOrderListener(OnOrderListener listener) {
		mOnOrderListener = listener;
	}
	
	protected void OnOrder(final String order, final Map<String, String> params){
		KuwoLog.d(TAG, "OnOrder order="+order);
		Handler handler = new Handler(Looper.getMainLooper());
		handler.post(new Runnable() {
			
			@Override
			public void run() {
				if (order.equalsIgnoreCase("showLoading")) {
					if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
						Toast.makeText(mContext, "网络未连接，请稍后再试", 0).show();
					}
					return ;
				}else if (order.equalsIgnoreCase("hideLoading")) {
					if(mOnOrderListener != null) {
						mOnOrderListener.onPageFinished();
					}
					return;
				}else if (order.equalsIgnoreCase("getUserID")) {
					if(!Config.getPersistence().isLogin) {
						String functionStr = "onGetUserID(null)";
						js(functionStr);
						return;
					}
					User user = Config.getPersistence().user;
					KuwoLog.i(TAG, "uid="+user.uid);
					KuwoLog.i(TAG, "uanme="+user.uname);
					KuwoLog.i(TAG, "sid="+user.sid);
					KuwoLog.i(TAG, "headUrl="+user.headUrl);
					String functionStr = "onGetUserID('id="+user.uid+"&loginid="+user.uid+"&sid="+user.sid+"&uname="+user.uname+"&head="+user.headUrl+"')";
					js(functionStr);
					return;
				} 
				if (mOnOrderListener != null && !TextUtils.isEmpty(order)) {
					KuwoLog.d(TAG, "mOnOrderListener.onOrder(order, params)----order="+order);
					mOnOrderListener.onOrder(order, params);
				}
			}
		});
	}
	
	private void init(Context context) {
		mWebView = new WebView(context);
		mWebView.setVerticalScrollBarEnabled(false);
		mWebView.setHorizontalScrollBarEnabled(false);
		mWebView.getSettings().setJavaScriptEnabled(true);
		mWebView.addJavascriptInterface(this, "WebView");
		mWebView.getSettings().setBuiltInZoomControls(true);
		mWebView.getSettings().setSupportZoom(true);
		mWebView.getSettings().setDefaultZoom(ZoomDensity.CLOSE);

		mWebView.setWebChromeClient(new WebChromeClient() {

			@Override
			public boolean onJsAlert(WebView view, String url, String message, final JsResult result) {
				AlertDialog.Builder b = new AlertDialog.Builder(
				KuwoWebView.this.getContext());
				b.setTitle("提示");
				KuwoLog.d(TAG, "js alert url="+url); 
				b.setMessage(message);
				b.setPositiveButton(android.R.string.ok,
						new AlertDialog.OnClickListener() {
							public void onClick(DialogInterface dialog,
									int which) {
								result.confirm();
							}
						});
				b.setCancelable(false);
				b.create();
				b.show();
				return true;
			}
		});


		// mErrorImageView
		mErrorImageView = new ImageView(context);
		
		// mErrorRelativeLayout
		mErrorRelativeLayout = new RelativeLayout(context);
		mErrorRelativeLayout.setLayoutParams(new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
		
		RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		params.addRule(RelativeLayout.CENTER_HORIZONTAL, RelativeLayout.TRUE);
		params.addRule(RelativeLayout.CENTER_VERTICAL, RelativeLayout.TRUE);		
		mErrorRelativeLayout.addView(mErrorImageView, params);
		
		mProgressDialog = DialogUtils.showCircleProgress(mContext);
		mPdRL = new RelativeLayout(context);
		mPdRL.setLayoutParams(new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
		RelativeLayout.LayoutParams pdParams = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		pdParams.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);
		mPdRL.addView(mProgressDialog, pdParams);
		
		hideLoading();
		hideErrorView();
		addView(mErrorRelativeLayout, 0);
		addView(mWebView, 1);
		addView(mPdRL, 2);
		
		mWebView.setWebViewClient(new WebViewClient(){
			
			@Override
			public void onPageStarted(WebView view, String url, Bitmap favicon) {
				if(AppContext.getNetworkSensor().hasAvailableNetwork() && mOnOrderListener != null) {
					KuwoLog.d(TAG, "onPageStarted");
					mOnOrderListener.onPageStart();
				}else {
					KuwoLog.i(TAG, "网络不通，请稍后再试 179");
					showErrorView(R.drawable.fail_network);
				}
			}
			
			@Override
			public void onPageFinished(WebView view, String url) {
				if(AppContext.getNetworkSensor().hasAvailableNetwork() && mOnOrderListener != null) {
					KuwoLog.d(TAG, "onPageFinished");
					mOnOrderListener.onNoServerLoading();
				}
			}
			
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				super.shouldOverrideUrlLoading(view, url);
				
				
				if (url.startsWith(PREFIX)) {
					KuwoLog.d(TAG, "shouldOverrideUrlLoading---"+url);
					
					// 分析命令 kwsing://showloading/?ation=loadingshow
					int end = url.indexOf("?");
					String order = url.substring(PREFIX.length(), end);
					order = order.replace("/", "");
					
					if (order.equals(lastOrder) && (System.currentTimeMillis()-lastOrderTime)<800 )
						return true;
					
					lastOrder = order;
					lastOrderTime = System.currentTimeMillis();
					
					// 分析参数
					HashMap<String, String> data = new HashMap<String, String>();
					String params = url.substring(url.indexOf("?")+1);
					String[] paramArray = params.split("&");
					for(String param : paramArray) {
						end = param.indexOf("=");
						if(end == -1) {
							break;
						}
						String key = param.substring(0, end);
						String value = param.substring(end+1);
						data.put(key, value);
					}
					
					OnOrder(order, data);
					return true;
				}
				
				return false;
			}
			
			@Override
			public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
				KuwoLog.i(TAG, "onReceivedError");
				
				if (!AppContext.getNetworkSensor().hasAvailableNetwork()){
					// 显示无网络提示
					KuwoLog.i(TAG, "网络不通，请稍后再试 238");
					showErrorView(R.drawable.fail_network);
				}else {
					//显示数据获取失败提示
					KuwoLog.i(TAG, "获取连接失败!");
					showErrorView(R.drawable.fail_fetchdata);
				}
			}
		});
		
		mErrorImageView.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				hideErrorView();
				mWebView.reload();
			}
		});
	}
	
	public void setDownloadListener(final Activity activity) {
		if(mWebView == null)
			return;
		mWebView.setDownloadListener(new DownloadListener() {
			
			@Override
			public void onDownloadStart(String url, String userAgent,
					String contentDisposition, String mimetype, long contentLength) {
				  	Uri uri = Uri.parse(url);
		            Intent intent = new Intent(Intent.ACTION_VIEW, uri);
		            activity.startActivity(intent);
			}
		});
	}
	
	public void removeAllViews() {
		mWebView.removeAllViews();
	}
	
	public void clearHistory() {
		mWebView.clearHistory();
	}
	
	public void setFocusable(boolean focus) {
		mWebView.setFocusable(true);
	}
	
	public void destory() {
		mWebView.destroy();
	}
	
	/**
	 * 后退
	 */
	public void goBack() {
		mWebView.goBack();
	}
	
	/**
	 * 前进
	 */
	public void goForward() {
		mWebView.goForward();
	}
	
	public void reload() {
		mWebView.reload();
	}
	
	public void loadUrl(String url) {
		mWebView.loadUrl(url);
		hideErrorView();
	}
	
	private void showErrorView(int errorImageRes) {
		mWebView.setVisibility(View.INVISIBLE);
		mPdRL.setVisibility(View.INVISIBLE);
		mErrorRelativeLayout.setVisibility(View.VISIBLE);
		mErrorImageView.setImageResource(errorImageRes);
	}

	private void hideErrorView() {
//		mWebView.clearView();
		mErrorRelativeLayout.setVisibility(View.INVISIBLE);
		mWebView.setVisibility(View.VISIBLE);
	}
	
	public void js(String fun){
		mWebView.loadUrl(String.format("javascript:%s;", fun));
	}
	
	private void showLoading() {
//		mWebView.setVisibility(View.INVISIBLE);
		mErrorRelativeLayout.setVisibility(View.INVISIBLE);
		mPdRL.setVisibility(View.VISIBLE);
	}
	
	private void hideLoading() {
//		mWebView.clearView();
		mPdRL.setVisibility(View.INVISIBLE);
		mWebView.setVisibility(View.VISIBLE);
	}
	
	public void order(String url) { //
		// 分析命令 kwsing://showloading/?ation=loadingshow kwsing://playSong
		KuwoLog.d(TAG, "order---"+url);
		int end = url.indexOf("?");
		String order = url.substring(PREFIX.length(), end);
		order = order.replace("/", "");
		if (order.equals(lastOrder) && (System.currentTimeMillis()-lastOrderTime)<800 )
			return;
		
		lastOrder = order;
		lastOrderTime = System.currentTimeMillis();
		
		// 分析参数
		HashMap<String, String> data = new HashMap<String, String>();
		String params = url.substring(url.indexOf("?")+1);
		String[] paramArray = params.split("&");
		for(String param : paramArray) {
			end = param.indexOf("=");
			if(end == -1) {
				break;
			}
			String key = param.substring(0, end);
			String value = param.substring(end+1);
			data.put(key, value);
		}
		OnOrder(order, data);
	}
    
}
