package com.ifeng.share.activity;


import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.graphics.Bitmap;
import android.net.http.SslError;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.webkit.SslErrorHandler;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.ifeng.share.R;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.tenqt.TenqtManager;
import com.ifeng.share.util.NetworkState;
import com.tencent.weibo.api.UserAPI;
import com.tencent.weibo.beans.OAuth;
import com.tencent.weibo.constants.OAuthConstants;
import com.tencent.weibo.oauthv2.OAuthV2;
import com.tencent.weibo.oauthv2.OAuthV2Client;
/**
 * 腾讯授权界面
 * @author PJW
 *
 */
public class TenqtAuthoActivity extends Activity {
	private WebView web;
	private String pageUrl;
	private ProgressDialog oauthDialog;
	private OAuthV2 oAuth;
	private RelativeLayout authCover;
	private boolean isShow = false;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.wappage);
		if(!NetworkState.isActiveNetworkConnected(this)){
			Toast.makeText(this, "无网络连接", Toast.LENGTH_SHORT).show();
			finish();
			return;
		}
		oAuth = TenqtManager.initOAuthV2();
		pageUrl = OAuthV2Client.generateImplicitGrantUrl(oAuth);
		initView();
	}

	private void initView() {
		authCover = (RelativeLayout) this.findViewById(R.id.authCover);
		web = (WebView) this.findViewById(R.id.wappage_view);
		web.getSettings().setSupportZoom(true);
		web.getSettings().setBuiltInZoomControls(true);
		web.getSettings().setJavaScriptEnabled(true);
		web.setWebViewClient(new EmbeddedWebViewClient());
		web.clearCache(true);
		web.requestFocus();
		web.loadUrl(pageUrl);
		onCreateDialog("请稍候...").show();
	}

	/**
	 * 按键监听
	 */
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK && null != web && web.canGoBack() ) {
			if(null != web && web.canGoBack() && authCover != null){
				onDialogFinished();
				finish();
				overridePendingTransition(0, R.anim.out_to_right);
			}else{
				return true;
			}
		}
		return super.onKeyDown(keyCode, event);
	}

	private class EmbeddedWebViewClient extends WebViewClient {
		@Override
		public boolean shouldOverrideUrlLoading(WebView view, String url) {
			Log.i("TenqtAuthoActivity", "shouldOverrideUrlLoading url=" + url);
			if (url.indexOf("access_token=") != -1 && !isShow) {
				accessTokenAction(view,url);
				return true;
			}
			view.loadUrl(url);
			return true;
		}

		@Override
		public void onPageFinished(WebView wv, String url) {
			Log.i("TenqtAuthoActivity", "onPageFinished url=" + url);
			onDialogFinished();
		}

		@Override
		public void onPageStarted(WebView view, String url, Bitmap favicon) {
			Log.i("TenqtAuthoActivity", "onPageStarted url=" + url);
			if (url.indexOf("access_token=") != -1 && !isShow) {
				accessTokenAction(view,url);
				return;
			}
			
		}

		@Override
		public void onReceivedError(WebView wv, int errorCode,
				String description, String failingUrl) {
			Log.i("TenqtAuthoActivity", "onReceivedError url=" + failingUrl);
			onDialogFinished();
		}
		public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
			Log.i("TenqtAuthoActivity", "onReceivedSslError url=" + view.getUrl()+ ", error=" + error.toString());
			if ((null != view.getUrl()) && (view.getUrl().startsWith("https://open.t.qq.com"))) {
				handler.proceed();// 接受证书
			} else {
				// 某些手机（如note1）会发生证书ssl错误，所以导致不能鉴权成功，针对这个问题有两个解决方案，一是用HTTP方式授权，二是忽略SSL错误
				// 为修改简单起见采用第二种方式。
				handler.proceed();// 接受证书  
//				handler.cancel(); // 默认的处理方式，WebView变成空白页
			}
		}
	}
	public void accessTokenAction(WebView view,String url){
		if (view != null) {
			int start=url.indexOf("access_token=");
			String responseData=url.substring(start);
			new UpdateAccessTokenTask(responseData).execute();
			/*view.destroyDrawingCache();
			view.destroy();
			view = null;*/
		}
	}
	class UpdateAccessTokenTask extends AsyncTask<String, Integer, String> {
		private boolean succecced = false;
		private String datas = null;
		public UpdateAccessTokenTask(String datas){
			this.datas = datas;
		}
		@Override
		protected void onPreExecute() {
//			onCreateDialog("请稍候...").show();
			super.onPreExecute();
		}

		@Override
		protected void onPostExecute(String result) {
			String str = "授权成功";
			if (!succecced) {
				str = "授权失败，请重试，如果连续失败请稍候再试";
			}
			onDialogFinished();
			Toast.makeText(TenqtAuthoActivity.this, str, Toast.LENGTH_LONG).show();
			TenqtAuthoActivity.this.finish();
		}
		@Override
		protected String doInBackground(String... params) {
			if(TextUtils.isEmpty(datas)) return null;
			try {
				succecced = OAuthV2Client.parseAccessTokenAndOpenId(datas, oAuth);
				if(succecced){
					String urername = getUserInfor(oAuth);//获取用户名信息
					TokenTools.saveTenqtOauthMessage(TenqtAuthoActivity.this, oAuth.getAccessToken(),oAuth.getOpenid(),oAuth.getClientId(),urername);
					isShow = true ; 
				}
			} catch (Exception e) {
				succecced = false;
			}
			return null;
		}
	}
	
	/**
	 * 创建Dialog
	 * @param msg
	 * @return
	 */
	private Dialog onCreateDialog(String msg) {
		if (oauthDialog == null && !isFinishing())
			oauthDialog = new ProgressDialog(this);
		oauthDialog.setCancelable(false);
		oauthDialog.setCanceledOnTouchOutside(false);
		oauthDialog.setIndeterminate(false);
		oauthDialog.setMessage(msg);
		return oauthDialog;
	}

	/**
	 * 隐藏Dialog
	 */
	private void onDialogFinished() {
		if (oauthDialog != null && oauthDialog.isShowing() && !isFinishing())
			oauthDialog.dismiss();
	}
	
	
	//获取用户名
	private String getUserInfor(OAuth oAuth){
		String username=null;
		try {
			UserAPI userAPI=new UserAPI(OAuthConstants.OAUTH_VERSION_2_A);
			username = new TenqtManager(this).parseUsername(userAPI.info(oAuth, "json"));
			userAPI.shutdownConnection();
		} catch (Exception e) {
		}
		if(TextUtils.isEmpty(username))username = "无法显示账户信息";
		return username;
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
