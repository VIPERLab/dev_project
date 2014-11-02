package com.ifeng.news2.advertise;

import java.util.ArrayList;

import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.webkit.DownloadListener;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.ifeng.news2.Config;
import com.ifeng.news2.R;
import com.ifeng.news2.activity.AppBaseActivity;
import com.ifeng.news2.activity.PlayVideoActivity;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.service.DownLoadAppService;
import com.ifeng.news2.share.ShareAlertBig;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.FilterUtil;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.ShakeListener;
import com.ifeng.news2.util.ShakeListener.OnShakeListener;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.share.util.NetworkState;

public class AdDetailActivity extends AppBaseActivity  implements OnShakeListener {

    private static final long DELTA_TIME_MIN = 3000;
	private final static String ERR_URL = "http:\\www.ifeng.com";
	private RelativeLayout mContentView = null;
	private ArrayList<WebView> mWebViews = null;
	private WebView mWebView = null;
	private LinearLayout mLoadingView = null;
	private int mCurrentIndex = -1;
	
	private ShakeListener mShakeListener;
	
	//页面是否加载失败,默认是加载成功
	private boolean isPageLoadFail = false;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		String url = getIntent().getStringExtra("URL");
		String webUrl = FilterUtil.filterUrl(url);
		
		if(!TextUtils.isEmpty(webUrl)){
			if (ConstantManager.ACTION_FROM_TOPIC2.equals(getIntent().getAction())) {
				// 入口是专题
				if (!TextUtils.isEmpty(getIntent().getStringExtra(
						ConstantManager.EXTRA_GALAGERY))) {
					StatisticUtil.addRecord(getApplicationContext()
							, StatisticUtil.StatisticRecordAction.page
							, "id=topic_" + FilterUtil.filterUrl(webUrl)+"$ref=topic_"+getIntent().getStringExtra(
									ConstantManager.EXTRA_GALAGERY)+"$type=" + StatisticUtil.StatisticPageType.topic);
				}
			} else {
				// 入口是列表
				Channel channel = (Channel) getIntent().getParcelableExtra(
						ConstantManager.EXTRA_CHANNEL);
				if (null != channel) {
					StatisticUtil.addRecord(this
							, StatisticUtil.StatisticRecordAction.page
							, "id=topic_" + FilterUtil.filterUrl(webUrl) + "$ref="+channel.getStatistic()+"$type=" + StatisticUtil.StatisticPageType.topic);
				}
			}
			
		}
		Config.IS_FINSIH_PULL_SKIP = true;
		mContentView = (RelativeLayout) getLayoutInflater().inflate(
				R.layout.ad_view, null);
		setContentView(mContentView);
		/*
		 * e.g.
		 * 联想：manufacturer=LENOVO, model=Lenovo A288t
		 * 三星：manufacturer=samsung, model=Galaxy Nexus
		 */
//		String manufacturer = android.os.Build.MANUFACTURER;
//		String model = android.os.Build.MODEL;
		  
		//android.os.Build.VERSION_CODES.HONEYCOMB = 11 , Android 3.0.
		if (android.os.Build.VERSION.SDK_INT < 11) {

//          if (NetworkState.isActiveNetworkConnected(this)&&!NetworkState.isWifiNetworkConnected(this)) {
//              WebView.enablePlatformNotifications();
//          } else {
//              WebView.disablePlatformNotifications();
//          }
      }
		mWebView = (WebView) findViewById(R.id.web_view);
		mWebViews = new ArrayList<WebView>();
		mWebViews.add(mWebView);
		setCurrentWebViewIndex(0);
		mLoadingView = (LinearLayout) findViewById(R.id.loading);
		findViewById(R.id.ifeng_bottom).findViewById(R.id.back).setOnClickListener(mClickListener);
		initWebView(mWebView);
		mWebView.clearCache(true);
		mWebView.clearHistory();
		
        mWebView.loadUrl(addParams(url));
	}
	
	private boolean isStarted=false;
	
	@Override
	protected void onStart() {
	   super.onStart();
	   if (null == mShakeListener) {
	  
	      mShakeListener = new ShakeListener(AdDetailActivity.this);
	   }
	   mShakeListener.setOnShakeListener(this);
	}
	
	@Override
	protected void onResume() {
	  if(isStarted){
	    
	    mShakeListener.openShakeListen();
	  }
	    super.onResume();
	};
	
	@Override
	protected void onDestroy() {
	  if(null !=mWebView){
	    mWebView.destroy();
	  }
	  super.onDestroy();
	}
	
	
	@Override
	protected void onPause() {
	  if(null !=mShakeListener && isStarted){
	    mShakeListener.closeShakListen();
	  }
	super.onPause();
	}
	@Override
	protected void onStop() {
    	super.onStop();
	}
	
	
	
	/**
	 * 去掉底部bottom
	 */
	private void removeBottom(){
		findViewById(R.id.ifeng_bottom).setVisibility(View.GONE);
		findViewById(R.id.shadow).setVisibility(View.GONE);
	}
	
	
	private String addParams(String org){
		return ParamsManager.addParams(org);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		menu.add("刷新");
		return true;
	}
	
	@Override
	public boolean onMenuItemSelected(int featureId, MenuItem item) {
		if (item.getTitle().equals("刷新")) {
			String url = mWebViews.get(getCurrentWebViewIndex()).getUrl();
			mWebViews.get(getCurrentWebViewIndex()).loadUrl(url);
			return true;
		}
		return super.onMenuItemSelected(featureId, item);
	}
	
	private void setCurrentWebViewIndex(int index) {
		mCurrentIndex = index;
	}

	private int getCurrentWebViewIndex() {
		return mCurrentIndex;
	}

	private void initWebView(WebView webView) {
		initSettings(webView.getSettings());
		webView.setScrollbarFadingEnabled(false);
		webView.setHorizontalScrollBarEnabled(false);
		webView.setVerticalScrollBarEnabled(false);
		webView.addJavascriptInterface(jsInterface, "ground");
		webView.addJavascriptInterface(new ShakeJSInterface(), "shake");
		webView.setWebViewClient(new WebDetailClient());
		webView.setDownloadListener(mDownloadListener);
	}

	private void initSettings(WebSettings settings) {
		settings.setAppCacheEnabled(true);
		settings.setAllowFileAccess(true);
		settings.setAppCachePath(getApplicationContext().getCacheDir()
				.getAbsolutePath());
		settings.setSupportZoom(false);
		settings.setJavaScriptEnabled(true);
		settings.setDomStorageEnabled(true);
		settings.setBuiltInZoomControls(false);
		settings.setLoadWithOverviewMode(true);
		settings.setUseWideViewPort(true);
		settings.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.NORMAL);
	}

	@Override
	public void onBackPressed() {
		goBack();
	}

	/**
	 * Action 是"FULL_SCREEN"时（直播间）
	 * 硬件返回按钮调用JS的clientBack();
	 */
	
	private void goBack(){
		if(getIntent().getAction() != null &&
				getIntent().getAction().equals("FULL_SCREEN")){
			//如果页面加载失败，调用默认的goBackOrFinish();
			if(getPageLoadFailFlag())
				goBackOrFinish();
			else
				callJsBackMethod();
		}else{
			goBackOrFinish();
		}
			
	}
	
	private void callJsBackMethod(){
		mWebView.loadUrl("javascript:clientBack()");
	}
	
	private void goBackOrFinish() {
		StatisticUtil.isBack= true ; 
		WebView webView = mWebViews.get(getCurrentWebViewIndex());
		//如果是从体育直播间跳转到数据页，返回直接关闭当前activity
		if (ConstantManager.ACTION_SPOER_LIVE.equals(getIntent().getAction())
				|| ConstantManager.ACTION_FROM_APP.equals(getIntent()
						.getAction())) {
			//退出当前Activity
			finishWithAnimation();
			return;
		}
		if (webView != null && (webView.getVisibility() == View.VISIBLE)
				&& webView.canGoBack()) {
			webView.goBack();
		} else if (getCurrentWebViewIndex() > 0) {
			mContentView.removeView(webView);
			webView.destroy();
			mWebViews.remove(getCurrentWebViewIndex());
			setCurrentWebViewIndex(getCurrentWebViewIndex() - 1);
			mContentView.addView(mWebViews.get(getCurrentWebViewIndex()),
					LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
		} else {
			if (getIntent() != null&& getIntent().getBooleanExtra(IntentUtil.EXTRA_REDIRECT_HOME, false)){
				IntentUtil.redirectHome(AdDetailActivity.this);
				//退出当前Activity
				finishWithAnimation();
			}else{
			    // fix bug #14788
			    // 在联想A288T上，打开一个web专题，页面显示乱码
			    if ("LENOVO".equalsIgnoreCase(android.os.Build.MANUFACTURER)) {
			        mWebView.clearCache(true);
			    }
			    
			    // fix bug #17919 [推送]从推送中打开超连接返回后没有停留在推送正文页。 and #17920
//			    if (!NewsMasterFragmentActivity.isAppRunning) {
//		            IntentUtil.redirectHome(this);
//		        }
			  //退出当前Activity
			    finishWithAnimation();
//				overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);
			}
		}
	}
	
	//退出当前Activity，并且有动画
	private void finishWithAnimation(){
		//关闭当前Activity
		finish();
		//关闭Activity动画
		overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
	}

	/**
	 * 设置页面加载失败状态
	 * @param state  
	 * true: 加载失败
	 * false: 加载成功
	 * 在onReceiveError 里更新状态
	 */
	private void setPageLoadFail(boolean state){
		this.isPageLoadFail = state;
	}
	
	private boolean getPageLoadFailFlag(){
		return isPageLoadFail;
	}
	
	private Object jsInterface = new Object() {

		@SuppressWarnings("unused")
		public void dispatch(String type, String url, String category) {
			dispatch(type, url, category, ERR_URL, null);
		}

		public void dispatch(String type, String url, String category,
				String errUrl, String documentId) {
			runOnUiThread(new ClickRunnable(type, url, errUrl, documentId,category));
		}
		
		/**
		 * 2013/06/07  author: harp
		 * 体育直播间返回按钮
		 */
		public void back2Application(){
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					goBackOrFinish();
				}
			});
		}
		
		/**
		 * 体育直播间分享按钮
		 * @param title  标题
		 * @param shareUrl 分享地址
		 */
		public void shareLivePage(String title, String shareUrl){
			runOnUiThread(new ShareRunnable(title, shareUrl));
		}
		
		/**
		 * 加载完成后隐藏底部导航栏
		 */
		public void loadSucceed(){
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					removeBottom();
				}
			});
		}
	};
	
	
	
	
	private class WebDetailClient extends WebViewClient {

		@Override
		public void onPageStarted(WebView view, String url, Bitmap favicon) {
			super.onPageStarted(view, url, favicon);
			view.setVisibility(View.GONE);
			mLoadingView.setVisibility(View.VISIBLE);
			
		}

		@Override
		public void onPageFinished(WebView view, String url) {
			super.onPageFinished(view, url);
			view.setVisibility(View.VISIBLE);
			mLoadingView.setVisibility(View.GONE);
			
		}
		
		@Override
        public void onReceivedError(WebView view, int errorCode,
                String description, String failingUrl) { 
			Toast.makeText(AdDetailActivity.this, "页面加载出错啦！", Toast.LENGTH_LONG).show(); 
			setPageLoadFail(true);
		}
		
		@Override
		public boolean shouldOverrideUrlLoading(WebView view, String url) {
			// fix bug #17879 【超链接】老版本跳转到超链接之后，点击手凤页面的视频，无法播放
			if (url.endsWith(".mp4") || url.endsWith(".3gp")) {
//				PlayVideoActivity.playVideo(AdDetailActivity.this.getApplicationContext(), url, "");
				Intent intent =  new Intent(AdDetailActivity.this.getApplicationContext(),PlayVideoActivity.class);
				//fix bug 16219 
				intent.setFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION | Intent.FLAG_ACTIVITY_NEW_TASK);
				Bundle bundle = new Bundle();
				bundle.putString("path", url);
				intent.putExtras(bundle);
				AdDetailActivity.this.getApplicationContext().startActivity(intent);
                return true;
			} 
			return super.shouldOverrideUrlLoading(view, url);
		}
	}
	
	private class ShareRunnable implements Runnable{

		String shareUrl;
		String title;
		
		public ShareRunnable(String title, String shareUrl){
			this.title = title;
			this.shareUrl = shareUrl;
		}
		
		@Override
		public void run() {
			ShareAlertBig alert = new ShareAlertBig(AdDetailActivity.this,
					null, shareUrl, title,title, null, null, StatisticUtil.StatisticPageType.topic);
			alert.show(AdDetailActivity.this);
		}
		
	}

	private class ClickRunnable implements Runnable {

		String type;
		String url;
		String errUrl;
		String documentId;
		String category;

		public ClickRunnable(String type, String url, String errUrl,
				String documentId,String category) {
			this.type = type;
			this.url = url;
			this.errUrl = errUrl == null ? ERR_URL : errUrl;
			this.documentId = documentId;
			this.category = category;
		}

		@Override
		public void run() {
			if ("web".equals(type)) {
				WebView webView = new WebView(AdDetailActivity.this);
				mContentView.removeView(mWebViews.get(getCurrentWebViewIndex()));
				mContentView.addView(webView, LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
				setCurrentWebViewIndex(mWebViews.size());
				mWebViews.add(webView);
				initWebView(webView);
				webView.loadUrl(url);
			} else {
				Extension extension = new Extension();
				extension.setType(type);
				extension.setUrl(url);
				extension.setDocumentId(documentId);
				extension.setCategory(category);
				boolean success = false;
				if(url!=null&&!url.equals("")&&category!=null&&!category.equals("")){
					success =  IntentUtil.startActivityByExtension(
								AdDetailActivity.this, extension);
				}
					if (!success)
						mWebView.loadUrl(errUrl);
					return;
			}
		}
	}

	private OnClickListener mClickListener = new OnClickListener() {

		@Override
		public void onClick(View v) {
			goBackOrFinish();
		}
	};

	private DownloadListener mDownloadListener = new DownloadListener() {

		@Override
		public void onDownloadStart(String url, String userAgent,
				String contentDisposition, String mimetype, long contentLength) {
			//url = filterApkUrl(url);
			if (url.endsWith(".apk")) {
				Intent updateIntent = new Intent(AdDetailActivity.this,
						DownLoadAppService.class);
				updateIntent.putExtra("apkName", getAppName(url));
				updateIntent.putExtra("downloadUrl", url);
				AdDetailActivity.this.startService(updateIntent);
			}
		}

		private String getAppName(String url) {
			String appname = "temp";
			if (url != null && url.contains("/")) {
				String[] temps = url.split("/");
				appname = temps[temps.length - 1];
				appname = appname.replace(".apk", "");
			}
			return appname;
		}
	};
	
	@SuppressWarnings("unused")
	private String filterApkUrl(String url){
		if(url != null && url.contains("?")){
			String[] temps = url.split("\\?");
			return temps[0];
		}
		return url;
	}

	private long lastShakeTimeMills = 0, newShakeTimeMills = 0;
  @Override
  public void onShake() {
    // TODO Auto-generated method stub
    newShakeTimeMills = System.currentTimeMillis();
    long deltaTime = newShakeTimeMills - lastShakeTimeMills;
    if (deltaTime > DELTA_TIME_MIN) {
      if (null != mWebView) {
        mWebView.loadUrl("javascript:setShakeCallback()");
      }
      lastShakeTimeMills = newShakeTimeMills;
    } else {
      /**
       * 摇晃过于频繁.
       * */
    }
  }
  
  final class ShakeJSInterface {

    PackageManager pm;
    PackageInfo pi;

    ShakeJSInterface() {

      pm = AdDetailActivity.this.getPackageManager();
    }

    public String getAppVersion() {
      try {
        if (null == pi) {
          pi = pm.getPackageInfo(AdDetailActivity.this.getPackageName(), 0);
        }
      } catch (NameNotFoundException e) {
        e.printStackTrace();
        return "";
      }
      String appVersion = pi.versionName;
      return (null == appVersion) ? "" : appVersion;
    }

    public int getAndroidOSVersion() {
      return android.os.Build.VERSION.SDK_INT;
    }

    // 开启摇晃监听。
    public void shakeOn() {
      if (null == mShakeListener) {
        mShakeListener = new ShakeListener(AdDetailActivity.this);
      }
      mShakeListener.openShakeListen();
      isStarted=true;
    }

    // 关闭摇晃监听
    public void shakeOff() {

      if (null == mShakeListener) {
        isStarted=false;
        return;
      }
      isStarted=false;
      mShakeListener.closeShakListen();
    }

    // 监测是否支持摇晃监听服务
    public boolean isSupportShake() {

      if (null == mShakeListener) {
        mShakeListener = new ShakeListener(AdDetailActivity.this);
      }
      return mShakeListener.isShakeValue();
    }

  }
  
  
}
