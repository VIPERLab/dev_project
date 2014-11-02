package com.ifeng.share.tenqt;

import android.app.Activity;
import android.content.Context;
import android.net.Uri;
import android.os.AsyncTask;
import android.util.Log;
import android.widget.Toast;

import com.ifeng.aladdin.json.JSONException;
import com.ifeng.aladdin.json.JSONObject;
import com.ifeng.share.R;
import com.ifeng.share.action.ShareManager;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.config.ShareConfig;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.util.GetIpAddress;
import com.ifeng.share.util.WindowPrompt;
import com.tencent.weibo.api.TAPI;
import com.tencent.weibo.beans.OAuth;
import com.tencent.weibo.constants.OAuthConstants;
import com.tencent.weibo.oauthv2.OAuthV2;

public class TenqtManager {
	private static OAuthV2 oAuth2 = null;
	private boolean isTenqtState;
	private Activity context ; 
	private String imgUrl ; 
	private String content ; 
	private WindowPrompt windowPrompt;
	
	/**
	 * 设置分享信息
	 * 
	 * @param shareMessage
	 */
	public void setShareMessage(ShareMessage shareMessage) {
		setShareImageUrl(filterShareImageUrl(shareMessage.getShareImageUrl()));
		setContent(shareMessage.getContent());
	}
	
	public String filterShareImageUrl(String imageUrl){
		String filterImageUrl=null;
		if (imageUrl==null || imageUrl.length()==0) {
			return null;
		}
		try {
			Uri uri = Uri.parse(imageUrl);
			filterImageUrl = uri.getQueryParameter("url");
		} catch (Exception e) {
		}
		if (filterImageUrl==null) {
			filterImageUrl = imageUrl;
		}
		return filterImageUrl;
	}

	public void setShareImageUrl(String imgUrl) {
		this.imgUrl = imgUrl;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public TenqtManager(Activity ctx) {
		this.context = ctx ; 
		windowPrompt = WindowPrompt.getInstance(ctx);
	}

	/**
	 * 授权初始化oauth2
	 * 
	 * @return
	 */
	public static OAuthV2 initOAuthV2() {
		if (oAuth2 == null) {
			oAuth2 = new OAuthV2(ShareConfig.TENQT_URIREDIRECT_URI);
			oAuth2.setClientId(ShareConfig.TENQT_CONSUMER_KEY);
			oAuth2.setClientSecret(ShareConfig.TENQT_CONSUMER_SECRET);
		}
		return oAuth2;
	}

	/**
	 * 是否授权
	 * 
	 * @param context
	 * @return
	 */
	public Boolean isAuthorizeTenqt(Context context) {
		String token = getToken(context);
		String tokenSecret = getTokenSecret(context);
		if (token != null && tokenSecret != null) {
			return true;
		}
		return false;
	}

	public String getToken(Context context) {
		return TokenTools.getToken(context, ShareManager.TENQT);
	}

	public String getTokenSecret(Context context) {
		return TokenTools.getTokenSecret(context, ShareManager.TENQT);
	}

	public OAuthV2 getShareOAuth(Context context) {
		initOAuthV2();
		oAuth2.setAccessToken(getToken(context));
		oAuth2.setOpenid(TokenTools.getTenqtOpenId(context));
		oAuth2.setClientIP(TokenTools.getTenqtClientId(context));
		oAuth2.setClientId(ShareConfig.TENQT_CONSUMER_KEY);
		return oAuth2;
	}

	public Boolean isShareSuccess(String response) throws Exception {
		if (response == null || response.length() == 0) {
			return false;
		}
		JSONObject jsonObject = new JSONObject(response);
		int ret = jsonObject.getInt("ret");
		if (ret == 0) {
			return true;
		}
		return false;
	}

	public String parseUsername(String infor) {
		if (infor == null || infor.length() == 0) {
			return null;
		}
		String username = null;
		try {
			JSONObject jsonObject = new JSONObject(infor);
			JSONObject dataObject = jsonObject.getJSONObject("data");
			username = dataObject.getString("name");
		} catch (JSONException e) {
			return null;
		}
		return username;

	}
	
	public Boolean sendWeibo(){
		TAPI tapi = new TAPI(OAuthConstants.OAUTH_VERSION_2_A);
		String clientIp = GetIpAddress.getLocalIp();
		String response="";
		try {
			OAuthV2 shareOAuth = getShareOAuth(context);
			if(shareOAuth==null)return false;
			if (imgUrl==null || imgUrl.length()==0) {
				response=sendMessage(shareOAuth,tapi,clientIp);
			}else {
				response=sendMessageWithImage(shareOAuth,tapi,clientIp);
			}
			return isShareSuccess(response);
		} catch (Exception e) {
			return false;
		}
	}
	
	public String sendMessage(OAuth oAuth,TAPI tapi,String clientIp)throws Exception{
		String response=tapi.add(oAuth, "json", content, clientIp);
		return response;
	}
	public String sendMessageWithImage(OAuth oAuth,TAPI tapi,String clientIp)throws Exception{
		String response=tapi.addPic(oAuth, "json", content, clientIp,imgUrl);
		return response;
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
	

	// 分享到QQ空间
	public boolean updateStatus() {
		try {
			return sendWeibo();
		} catch (Exception e) {
			Log.w("TenQz",
					e.getLocalizedMessage() == null ? "exception occurs when sharing to tenqz"
							: e.getLocalizedMessage());
			return false;
		}
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
			isTenqtState = false;
			showMessage("正在分享至腾讯微博···");
		}

		@Override
		protected void onPostExecute(String result) {
			if (isTenqtState) {
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.share_success_title,R.string.share_success_to_tenqt);
			} else {
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.share_fail_title,R.string.share_fail_content);
			}
		}
		

		@Override
		protected String doInBackground(String... params) {
			isTenqtState = updateStatus();
			return null;
		}
	}
}
