package com.ifeng.share.sina;

import android.app.Activity;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.ifeng.share.R;
import com.ifeng.share.action.ShareManager;
import com.ifeng.share.bean.CallbackAction;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.config.ShareConfig;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.util.NetworkState;
import com.ifeng.share.util.WindowPrompt;
import com.weibo.net.AccessToken;
import com.weibo.net.Utility;
import com.weibo.net.Weibo;
import com.weibo.net.WeiboParameters;
import com.weibo.sdk.android.WeiboAuthListener;
import com.weibo.sdk.android.WeiboDialogError;
import com.weibo.sdk.android.WeiboException;
import com.weibo.sdk.android.sso.SsoHandler;

public class WeiboHelper {
	private Activity _context;
	private String _message;
	private String shareImgUrl;
	private Boolean weiboState = false;
	private SsoHandler mSsoHandler;
	private WindowPrompt windowPrompt;

	public WeiboHelper(Activity ctx) {
		_context = ctx;
		Weibo.getInstance().setAccessToken(SinaManager.initAccessToken(ctx));
		windowPrompt = WindowPrompt.getInstance(ctx);
	}

	public WeiboHelper(Activity ctx,String shareImgUrl) {
		_context = ctx;
		this.shareImgUrl = shareImgUrl;
	}

	public void setShareImageUrl(String shareImgUrl){
		this.shareImgUrl = shareImgUrl;
	}


	private void setMessage(String message) {
		_message = message;
	}

	public boolean updateStatus() {
		String access_token = getToken(ShareManager.SINA);
		Boolean isSuccess = false;
		try {
			if(shareImgUrl == null || shareImgUrl.length() == 0){
				isSuccess=shareOnlyMessage(_message,access_token);
			}else{
				isSuccess=shareMessageWithPic(access_token,shareImgUrl,_message);
			}
			return isSuccess;
		}catch (Exception e) {
		    Log.w("WeiboHelper", 
		            e.getLocalizedMessage() == null ?
		                    "exception occurs when sharing to weibo" : e.getLocalizedMessage());
			return false;
		}
	}
	private Boolean shareOnlyMessage(String content, String access) throws Exception {
		Weibo weibo = Weibo.getInstance();
		WeiboParameters params = new WeiboParameters();
		params.add("access_token", access);
		params.add("status", content);
		String response=weibo.request(_context,SinaManager.SEND_MESSAGE_NO_IMAGE, params, Utility.HTTPMETHOD_POST,weibo.getAccessToken());
		if(response.contains("error_code")){
			return false;
		}
		return true;
	}

	private Boolean shareMessageWithPic(String access_token, String picUrl, String content) throws Exception {
		Weibo weibo = Weibo.getInstance();
		WeiboParameters bundle = new WeiboParameters();
		bundle.add("access_token", access_token);
		bundle.add("url", picUrl);
		bundle.add("status", content);
		String response=weibo.request(_context, SinaManager.SEND_MESSAGE_WITH_IMAGE, bundle, Utility.HTTPMETHOD_POST,weibo.getAccessToken());
		if(response.contains("error_code")){
			return false;
		}
		return true;
	}
	
	public Boolean getWeiboState() {
		return weiboState;
	}
	class updateStatusTask extends AsyncTask<String, Integer, String> {
		@Override
		protected void onPreExecute() {
			weiboState = false;
			showMessage("正在发送新浪微博···");
		}

		@Override
		protected void onPostExecute(String result) {
			if(weiboState){
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.share_success_title,R.string.share_success_to_sina);
			}else{
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.share_fail_title,R.string.share_fail_content);
			}
		}
		@Override
		protected String doInBackground(String... params) {
			weiboState=updateStatus();
			return null;
		}
	}
	/**
	 * 新浪微博 发送请求
	 * 
	 */
	public String getToken(String type) {
		return TokenTools.getToken(_context, type);
	}
	public String getTokenSecret(String type) {
		return TokenTools.getTokenSecret(_context, type);
	}
	
	public void authorize(Activity activity) {
		authorize(activity, null);
	}
	/**
	 * 新浪绑定
	 * @param activity
	 */
	public void authorize(Activity activity,BindListener bindListener) {
		if(!NetworkState.isActiveNetworkConnected(activity)){
			Toast.makeText(activity, "网络连接错误", Toast.LENGTH_SHORT).show();
			return;
		}
		/*try {
			Weibo weibo = Weibo.getInstance();
			weibo.setupConsumerConfig(Weibo.getAppKey(), Weibo.getAppSecret());
			weibo.setRedirectUrl("http://m.ifeng.com");// 此处回调页内容应该替换为与appkey对应的应用回调页
			weibo.authorize(_context,new AuthDialogListener());
		} catch (Exception e) {
			
		}*/
		mSsoHandler = new SsoHandler(activity, new com.weibo.sdk.android.Weibo()
			.getInstance(ShareConfig.SINA_CONSUMER_KEY,ShareConfig.SINA_REDIRECT_URI,ShareConfig.SINA_SCOPE));
		mSsoHandler.authorize(new AuthDialogListener(bindListener));
	}
	
	public void addNewMessage(String type, String message) {
		try {
			setMessage(message);
			new updateStatusTask().execute();
			_context.finish();
		} catch (Exception e) {
		}
	}

	public String parseUsername(String resStr, String queryString) {
		int fir = resStr.indexOf(queryString);
		fir += queryString.length();
		fir += 3;
		int sec = resStr.indexOf(",", fir);
		sec -= 1;
		String temp = resStr.substring(fir, sec);
		return temp;
	}
	
	class AuthDialogListener implements WeiboAuthListener {

		private BindListener bindListener;
		public AuthDialogListener() {
		}
		
		public AuthDialogListener(BindListener bindListener) {
			this.bindListener = bindListener;
		}
		@Override
		public void onComplete(Bundle values) {
			
			ShareMessage shareMessage=ShareManager.getShareMessage();
			CallbackAction bindCallback=shareMessage.getTargetShare().getCallback();

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
				TokenTools.saveExpiresTime(_context, Long.valueOf(expires_in),
						TokenTools.SINA_EXPIRES);

				String username = SinaManager.getUsername(_context, uid, accessToken);
				if (username == null || username.length() == 0) {
					username = "无法显示账号信息";
				}
				
				// 保存token和openId
				TokenTools.saveToken(_context, ShareManager.SINA, token,
						Weibo.getAppSecret(), username);
				
				if(bindCallback!=null){
					shareMessage.getTargetShare().getCallback().bindSuccess(_context);
					if(bindListener != null) {
						bindListener.success();
					}
				}
			} else{
				if(bindCallback!=null){
					shareMessage.getTargetShare().getCallback().bindFailure(_context);
					if(bindListener != null) {
						bindListener.success();
					}
				}
			}
			
		}
		@Override
		public void onCancel() {			
			showMessage("授权取消");
			if(bindListener != null) {
				bindListener.fail();
			}
		}

		@Override
		public void onError(WeiboDialogError arg0) {
			// TODO Auto-generated method stub
			showMessage("授权失败，请稍候重试！");
			if(bindListener != null) {
				bindListener.fail();
			}
		}

		@Override
		public void onWeiboException(WeiboException arg0) {
			// TODO Auto-generated method stub
			showMessage("授权失败，请稍候重试！");
			if(bindListener != null) {
				bindListener.fail();
			}
		}
	}
	public void showMessage(String message){
		Toast.makeText(_context, message, Toast.LENGTH_SHORT).show();
	}
	
	public void authCallBack(int requestCode, int resultCode, Intent data){
		if (mSsoHandler != null) {
			mSsoHandler.authorizeCallBack(requestCode, resultCode, data);
		}
	}
	
	public interface BindListener{
		void success();
		void fail();
	}
}

