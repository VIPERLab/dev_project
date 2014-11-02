package com.ifeng.share.activity;

import android.app.Activity;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.fetion.apis.android.DemonAndroid;
import com.fetion.apis.android.Response;
import com.ifeng.share.R;
import com.ifeng.share.action.ShareManager;
import com.ifeng.share.config.ShareConfig;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.fetion.FetionManager;
/**
 * 飞信登录、注册
 * @author PJW
 *
 */
public class FetionAuthoActivity extends Activity{
	private WebView oauthView;
	private DemonAndroid demonAndroid;
	private String oauthUrl;
	private ProgressBar mProgressBar;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.wappage);
		demonAndroid = DemonAndroid.getInstance();
		oauthUrl = getOauthUrl();
		initWebView();
	}
	public void showMessage(String message){
		Toast.makeText(FetionAuthoActivity.this, message, Toast.LENGTH_SHORT).show();
	}
	public void initWebView() {
		oauthView = (WebView)findViewById(R.id.wappage_view);
		mProgressBar = (ProgressBar)findViewById(R.id.wappage_process);
		oauthView.getSettings().setSupportZoom(true);
		oauthView.getSettings().setBuiltInZoomControls(true);
		oauthView.getSettings().setJavaScriptEnabled(true);
		oauthView.setWebViewClient(new EmbeddedWebViewClient());
		oauthView.setWebChromeClient(new WebChromeClient() {
			@Override
			public void onProgressChanged(WebView view, int progress) {
				mProgressBar.setProgress(progress);
			}
		});
		if (oauthUrl!=null && oauthUrl.length()>0) {
			oauthView.loadUrl(oauthUrl);
		}else {
			showMessage("登录失败");
			finish();
		}
	}
	private class EmbeddedWebViewClient extends WebViewClient {
		@Override
		public boolean shouldOverrideUrlLoading(WebView view, String url) {
			if (url.contains("code=")) {
				new updateAccessTokenTask(url).execute();
				return true;
			}
			view.loadUrl(url);
			return true;
		}

		private void onProgressFinished() {
			mProgressBar.setVisibility(View.GONE);
		}

		@Override
		public void onPageFinished(WebView wv, String url) {
			onProgressFinished();
		}

		@Override
		public void onPageStarted(WebView wv, String url, Bitmap favicon) {
			mProgressBar.setVisibility(View.VISIBLE);
		}

		@Override
		public void onReceivedError(WebView wv, int errorCode,
				String description, String failingUrl) {
			onProgressFinished();
		}
	}
	class updateAccessTokenTask extends AsyncTask<String, Integer, Response> {
		private String pageUrl;
		public updateAccessTokenTask(String pageUrl){
			this.pageUrl = pageUrl;
		}
		@Override
		protected void onPreExecute() {
			super.onPreExecute();
		}

		@Override
		protected void onPostExecute(Response result) {
			if (result!=null) {
				try {
					String returnCode= result.getReturnCode();
					String responseData=result.getResponseData().toString();
					String access_token = FetionManager.parseResponseData(responseData);
					if ("200".equals(returnCode) && access_token!=null && access_token.length()>0) {
						Log.i("share", "login access_token :"+access_token);
						FetionManager.restoreFriendsDatas(FetionAuthoActivity.this);
						TokenTools.saveToken(FetionAuthoActivity.this, ShareManager.FETION,access_token,ShareConfig.FETION_CLIENT_SECRET, "");
						FetionManager.isBind = true;
						showMessage("授权成功");
					}else {
						showMessage("授权失败");
					}
				} catch (Exception e) {
					e.printStackTrace();
					showMessage("授权失败");
				}
			}
			finish();
		}
		@Override
		protected Response doInBackground(String... params) {
			Response exchangeResponse = null;
			try {
				String code=Uri.parse(pageUrl).getQueryParameter("code");
				Log.i("share", "login code :"+code);
				exchangeResponse = demonAndroid.exchangeCredential(code, ShareConfig.FETION_CLIENT_ID, ShareConfig.FETION_CLIENT_SECRET, FetionManager.redirectURL, FetionManager.isCMWAP(FetionAuthoActivity.this));
			} catch (Exception e) {
				return null;
			}
			return exchangeResponse;
		}
	}
	/**
	 * 获取授权地址
	 * @return
	 */
	public String getOauthUrl() {
		String oauthUrl = "";
		try {
			oauthUrl = demonAndroid.getOauthURL(ShareConfig.FETION_CLIENT_ID,FetionManager.redirectURL);
		} catch (Exception e) {
			return "";
		}
		return oauthUrl;
	}

}
