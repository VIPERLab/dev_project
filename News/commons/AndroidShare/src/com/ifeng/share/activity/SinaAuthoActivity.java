package com.ifeng.share.activity;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.http.SslError;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.SslErrorHandler;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.ifeng.share.R;
import com.ifeng.share.action.ShareManager;
import com.ifeng.share.config.ShareConfig;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.sina.SinaManager;
import com.ifeng.share.util.NetworkState;
import com.weibo.net.AccessToken;
import com.weibo.net.Utility;
import com.weibo.net.Weibo;

/**
 * 新浪微博授权界面
 * 
 * @author cx
 * 
 */
public class SinaAuthoActivity extends Activity {
	private WebView web;
	private String pageUrl;
	private ProgressDialog oauthDialog;
	private Activity ctx = null;
	private boolean succecced = true;
	private RelativeLayout authCover;
	private boolean isShow = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.wappage);

		if (!NetworkState.isActiveNetworkConnected(this)) {
			Toast.makeText(this, "无网络连接", Toast.LENGTH_SHORT).show();
			finish();
			return;
		}
		ctx = this;
		initData();
		initView();
	}

	/**
	 * 获取Intent数据
	 */
	private void initData() {
		// TODO Auto-generated method stub
		Intent intent = getIntent();
		String url = intent.getExtras().getString("authUrl");
		if (!TextUtils.isEmpty(url)) {
			pageUrl = url;
		}
	}

	/**
	 * 初始化View
	 */
	private void initView() {
		authCover = (RelativeLayout) this.findViewById(R.id.authCover);
		web = (WebView) this.findViewById(R.id.wappage_view);
		web.getSettings().setSupportZoom(true);
		web.getSettings().setBuiltInZoomControls(true);
		web.getSettings().setJavaScriptEnabled(true);
		web.setWebViewClient(new EmbeddedWebViewClient());
		web.clearCache(true);
		web.loadUrl(pageUrl);
		onCreateDialog("请稍候...").show();
	}
	
	
	private class EmbeddedWebViewClient extends WebViewClient {
		@Override
		public boolean shouldOverrideUrlLoading(WebView view, String url) {
			if (url.indexOf(ShareConfig.SINA_REDIRECT_URI_BACK) != -1 && !isShow) {
				accessTokenAction(view, url);
				return true ; 
			}
			view.loadUrl(url);
			return true;
		}

		@Override
		public void onPageFinished(WebView wv, String url) {
			if (url.indexOf(ShareConfig.SINA_REDIRECT_URI_BACK) != -1 && !isShow) {
				accessTokenAction(wv, url);
			}
			onDialogFinished();
		}

		@Override
		public void onPageStarted(WebView view, String url, Bitmap favicon) {
			if (url.indexOf(ShareConfig.SINA_REDIRECT_URI_BACK) != -1 && !isShow) {
				accessTokenAction(view, url);
			}
		}

		@Override
		public void onReceivedError(WebView wv, int errorCode,
				String description, String failingUrl) {
			onDialogFinished();
		}

		public void onReceivedSslError(WebView view, SslErrorHandler handler,
				SslError error) {

			handler.proceed();// 接受证书
		}

	}

	/**
	 * 获取token等信息
	 * 
	 * @param view
	 * @param url
	 */
	public void accessTokenAction(WebView view, String url) {
		if (view != null) {
			int start = url.indexOf("#");
			String responseData = url.substring(start + 1);
			new UpdateAccessTokenTask(responseData).execute();
			/*view.destroyDrawingCache();
			view.destroy();
			view = null;*/
		}
	}

	class UpdateAccessTokenTask extends AsyncTask<String, Integer, String> {

		private String datas = null;

		public UpdateAccessTokenTask(String datas) {
			this.datas = datas;
		}

		@Override
		protected void onPreExecute() {
			// showDialog(-1);
			onCreateDialog("请稍候...").show();
			super.onPreExecute();
		}

		@Override
		protected void onPostExecute(String result) {
			if (succecced) {
				showMessage("授权成功！");
			} else {
				showMessage("授权失败，请稍后重试！");
			}
			onDialogFinished();
			SinaAuthoActivity.this.finish();
		}

		@Override
		protected String doInBackground(String... params) {
			if (TextUtils.isEmpty(datas))
				return null;
			handleRedirectUrl(datas);
			return null;
		}
	}

	private Dialog onCreateDialog(String msg) {
		if (oauthDialog == null && !isFinishing())
			oauthDialog = new ProgressDialog(ctx);
		oauthDialog.setCancelable(false);
		oauthDialog.setCanceledOnTouchOutside(false);
		oauthDialog.setIndeterminate(false);
		oauthDialog.setMessage(msg);
		return oauthDialog;
	}

	private void onDialogFinished() {
		if (oauthDialog != null && oauthDialog.isShowing() && !isFinishing())
			oauthDialog.dismiss();
	}

	/**
	 * 解析Url
	 * 
	 * @param url
	 */
	private void handleRedirectUrl(String url) {
		Bundle values = Utility.decodeUrl(url);

		String error = values.getString("error");
		String error_code = values.getString("error_code");

		if (error != null && error_code != null) {
			succecced = false;
			return;

		}
		String token = values.getString("access_token");
		String uid = values.getString("uid");
		String expires_in = values.getString("expires_in");

		if (!TextUtils.isEmpty(expires_in) && !TextUtils.isEmpty(uid)
				&& !TextUtils.isEmpty(token)) {
			AccessToken accessToken = new AccessToken(token,
					Weibo.getAppSecret());
			accessToken.setExpiresIn(expires_in);
			Weibo.getInstance().setAccessToken(accessToken);
			// 保存过期时间
			TokenTools.saveExpiresTime(ctx, Long.valueOf(expires_in),
					TokenTools.SINA_EXPIRES);

			String username = SinaManager.getUsername(ctx, uid, accessToken);
			if (username == null || username.length() == 0) {
				username = "无法显示账号信息";
			}
			Log.i("joim", "username:"+username);
			// 保存token和openId
			TokenTools.saveToken(ctx, ShareManager.SINA, token,
					Weibo.getAppSecret(), username);
			succecced = true;
			isShow = true ; 
		} else {
			succecced = false;
		}

	}
	

	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
		onDialogFinished();
		finish();
		overridePendingTransition(0, R.anim.out_to_right);
	}
	
	public void showMessage(String message) {
		Toast.makeText(ctx, message, Toast.LENGTH_SHORT).show();
	}
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		if(web != null && authCover != null){
			authCover.removeView(web);
			web.removeAllViews();
			web.destroy();
		}
		super.onDestroy();
	}

}
