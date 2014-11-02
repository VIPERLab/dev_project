package com.ifeng.share.sina;

import android.app.Activity;
import android.content.Intent;
import android.widget.Toast;

import com.ifeng.share.R;
import com.ifeng.share.action.ShareManager;
import com.ifeng.share.activity.EditShareActivity;
import com.ifeng.share.activity.SinaAuthoActivity;
import com.ifeng.share.bean.ShareInterface;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.config.ShareConfig;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.sina.WeiboHelper.BindListener;
import com.sina.weibo.sdk.WeiboSDK;
import com.sina.weibo.sdk.api.IWeiboAPI;
import com.sina.weibo.sdk.api.IWeiboDownloadListener;
import com.weibo.net.Utility;
import com.weibo.net.Weibo;
import com.weibo.net.WeiboParameters;

/*
 * 新浪分享入口
 */
public class ShareSina implements ShareInterface {
	private WeiboHelper weibo;
	private Activity activity;
	private static final String SINAWEIBO_PACKAGENAME = "com.sina.weibo";

	public ShareSina() {
	}

	@Override
	public Boolean share(ShareMessage shareMessage) {
		weibo.setShareImageUrl(shareMessage.getShareImageUrl());
		weibo.addNewMessage(ShareManager.SINA,
				SinaManager.filterMessage(shareMessage.getContent()));
		return weibo.getWeiboState();
	}

	@Override
	public void bind(Activity activity,BindListener bindListener) {
		init(activity);
		IWeiboAPI mWeiboShareAPI = WeiboSDK.createWeiboAPI(activity, Weibo.getAppKey());
		if (!mWeiboShareAPI.isWeiboAppInstalled() || !mWeiboShareAPI.isWeiboAppSupportAPI()) {
					Intent intent = new Intent(activity,SinaAuthoActivity.class);
					intent.putExtra("authUrl", concatUrl());
					activity.startActivity(intent);
					activity.overridePendingTransition(R.anim.in_from_right,
			                R.anim.out_to_left);
		} else {
			weibo.authorize(activity,bindListener);
		}
	}

	@Override
	public void unbind(Activity activity) {
		init(activity);
		TokenTools.removeToken(activity, ShareManager.SINA);
		ShareManager.deleteCookie(activity);
		Toast.makeText(activity, "已取消绑定新浪微博", Toast.LENGTH_SHORT).show();
	}

	@Override
	public Boolean isAuthorzine(Activity activity) {
		init(activity);
		if (weibo.getToken(ShareManager.SINA) != null
				&& !TokenTools
						.isLimitExpires(activity, TokenTools.SINA_EXPIRES)) {
			return true;
		}
		return false;
	}

	@Override
	public void shareSuccess() {

	}

	@Override
	public void shareFailure() {

	}

	public void init(Activity activity) {
		this.activity = activity;
		weibo = new WeiboHelper(activity);
	}

	/**
	 * 组合url
	 * 
	 * @return
	 */
	private String concatUrl() {
		// TODO Auto-generated method stub
		WeiboParameters parameters = new WeiboParameters();

		parameters.add("client_id", ShareConfig.SINA_CONSUMER_KEY);
		parameters.add("response_type", ShareConfig.SINA_RESPONSE_TYPE);
		parameters.add("redirect_uri", ShareConfig.SINA_REDIRECT_URI);
		parameters.add("display", ShareConfig.SINA_DISPLAY);

		return ShareConfig.SINA_AUTH_URL + "?" + Utility.encodeUrl(parameters);
	}


	public void showMessage(String message) {
		Toast.makeText(activity, message, Toast.LENGTH_SHORT).show();
	}

	@Override
	public void authCallback(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		weibo.authCallBack(requestCode, resultCode, data);
		
	}
}
