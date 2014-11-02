package com.ifeng.share.tenqz;

import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.ifeng.share.R;
import com.ifeng.share.action.ShareManager;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.config.ShareConfig;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.util.NetworkState;
import com.ifeng.share.util.WindowPrompt;
import com.tencent.tauth.Constants;
import com.tencent.tauth.Tencent;

public class TenqzManager {


	public static Tencent sTencent = null;
	private Activity context;
	private boolean isQzState;
	private String shareImgUrl;
	private String content;
	private String from;
	private String url;
	private WindowPrompt windowPrompt;

	public TenqzManager(Activity ctx) {
		this.context = ctx;
		sTencent = initTencentQz(ctx);
		windowPrompt =  WindowPrompt.getInstance(ctx);
	}

	/**
	 * 初始化Tencent
	 * 
	 * @param context
	 */
	public Tencent initTencentQz(Context context) {
		if(sTencent == null)
			sTencent = Tencent.createInstance(ShareConfig.TENQQ_APPID, context);
		String token = TokenTools.getToken(context, ShareManager.TENQZ);
		String openId = TokenTools.getTenqzOpenId(context);
		long expiresTime = TokenTools.getExpiresTime(context,TokenTools.TENQZ_EXPIRES);

		sTencent.setOpenId(openId);
		sTencent.setAccessToken(token, String.valueOf(expiresTime));
		return sTencent;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public void setShareImageUrl(String shareImgUrl) {
		this.shareImgUrl = shareImgUrl;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public void setFrom(String from) {
		this.from = from;
	}

	/**
	 * 设置分享信息
	 * 
	 * @param shareMessage
	 */
	public void setShareMessage(ShareMessage shareMessage) {
		setShareImageUrl(shareMessage.getShareImageUrl());
		setFrom(shareMessage.getForm());
		setUrl(shareMessage.getUrl());
		setContent(shareMessage.getContent());
	}
	
	/**
	 * QQ空间取消授权
	 * 
	 * @param activity
	 */
	public void logoutQQ(Activity activity) {
		if (!NetworkState.isActiveNetworkConnected(activity)) {
			showMessage("网络连接错误");
			return;
		}
		if(sTencent != null) sTencent.logout(activity);
		TokenTools.clearExpiresTime(activity,TokenTools.TENQZ_EXPIRES);
		TokenTools.removeToken(activity, ShareManager.TENQZ);
		ShareManager.deleteCookie(activity);
	}

	/**
	 * 分享信息
	 */
	public void addNewMessage() {
		try {
			new updateStatusTask().execute();
			context.finish();
		} catch (Exception e) {
		}
	}

	/**
	 * 获取用户名
	 * 
	 * @return
	 */
	public String getUsername(String token, String openId) {
		try {
			 JSONObject infoJson = sTencent.request(
					Constants.GRAPH_SIMPLE_USER_INFO, null, Constants.HTTP_GET);
			if (infoJson == null || infoJson.length() == 0)
				return null;
			return parseUserName(infoJson);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 解析用户名Json
	 * 
	 * @param json
	 * @return
	 * @throws Exception
	 */
	public String parseUserName(JSONObject json) throws Exception {
		String username = json.getString("nickname");
		return username;
	}

	/**
	 * 解析分享返回码
	 * 
	 * @param json
	 * @return
	 * @throws Exception
	 */
	public int parseRequestCode(JSONObject json) throws Exception {
		int requestCode = json.getInt("ret");
		return requestCode;
	}

	/**
	 * 分享状态
	 * 
	 * @return
	 */
	public boolean isQzState() {
		return isQzState;
	}

	/**
	 * 判断session有效
	 * 
	 * @return
	 */
	public static boolean isSessionValid() {
		return sTencent.isSessionValid();
	}

	/**
	 * 判断用户是否授权
	 * 
	 * @param context
	 * @return
	 */
	public boolean isAuthorzine(Context context) {
		boolean isAuthorzine = false;
		
		isAuthorzine = !TokenTools.isLimitExpires(context,TokenTools.TENQZ_EXPIRES);
		isAuthorzine = TokenTools.getTenqzOpenId(context) == null ? false : true;
		isAuthorzine = TokenTools.getToken(context, ShareManager.TENQZ) == null ? false : true;
		isAuthorzine = isSessionValid();

		return isAuthorzine;

	}

	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (sTencent == null)
			return;

		sTencent.onActivityResult(requestCode, resultCode, data);
	}

	//分享到QQ空间
	public boolean updateStatus() {
		try {
			return shareMessage2Qz();
		} catch (Exception e) {
			Log.w("TenQz",
					e.getLocalizedMessage() == null ? "exception occurs when sharing to tenqz"
							: e.getLocalizedMessage());
			return false;
		}
	}

	/**
	 * 分享信息
	 * 
	 * @return
	 * @throws Exception
	 */
	private boolean shareMessage2Qz() throws Exception {
		Bundle parmas = new Bundle();
		parmas.putString("title", from);// 必须。feeds的标题，最长36个中文字，超出部分会被截断。
		parmas.putString("url", url);// 必须。分享所在网页资源的链接，点击后跳转至第三方网页，请以http://开头。
		parmas.putString("summary", content);// 所分享的网页资源的摘要内容，或者是网页的概要描述。最长80个中文字，超出部分会被截断。
		parmas.putString("images", shareImgUrl);// 所分享的网页资源的代表性图片链接"，请以http://开头，长度限制255字符。多张图片以竖线（|）分隔，目前只有第一张图片有效，图片规格100*100为佳。

		JSONObject json = sTencent.request(Constants.GRAPH_ADD_SHARE, parmas,
				Constants.HTTP_POST);
		int requestCode = parseRequestCode(json);
		if (requestCode != 0) {
			return false;
		}
		return true;
	}

	public void showMessage(String message) {
		Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
	}

	/**
	 * 分享线程
	 * 
	 * @author chenxix
	 * 
	 */
	class updateStatusTask extends AsyncTask<String, Integer, String> {
		@Override
		protected void onPreExecute() {
			isQzState = false;
			showMessage("正在分享至QQ空间···");
		}
		
		@Override
		protected void onPostExecute(String result) {
			if (isQzState) {
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.share_success_title,R.string.share_success_to_tenqz);
			} else {
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.share_fail_title,R.string.share_fail_content);
			}
		}
		
		@Override
		protected String doInBackground(String... params) {
			isQzState = updateStatus();
			return null;
		}
		
	}


}
