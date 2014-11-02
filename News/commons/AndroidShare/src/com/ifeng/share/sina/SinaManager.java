package com.ifeng.share.sina;

import java.util.Date;

import org.json.JSONObject;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.ifeng.share.action.ShareManager;
import com.ifeng.share.config.TokenTools;
import com.weibo.net.AccessToken;
import com.weibo.net.Weibo;
import com.weibo.net.WeiboParameters;


public class SinaManager {
	public final static String USER_INFO = "https://open.weibo.cn/2/users/show.json";
	public final static String SEND_MESSAGE_NO_IMAGE="https://open.weibo.cn/2/statuses/update.json";
	public final static String SEND_MESSAGE_WITH_IMAGE="https://open.weibo.cn/2/statuses/upload_url_text.json";
	public static String filterMessage(String message){
		if (message==null || message.length()==0) {
			return message + '\n';
		}
		return message;
	}
	public static String getUsername(Context context,String uid,AccessToken accessToken){
		try {
			Weibo weibo = Weibo.getInstance();
			WeiboParameters params = new WeiboParameters();
			params.add("uid", uid);
			params.add("access_token", accessToken.getToken());
			String infoJson=weibo.request(context, USER_INFO, params, "GET", accessToken);
			if(infoJson==null ||infoJson.length()==0)return null;
			String username = parseJson(infoJson);
			return username;
		} catch (Exception e) {

		}
		return null;
	}
	public static String parseJson(String json) throws Exception{
		JSONObject jsonObject =new JSONObject(json);
		String username = jsonObject.getString("screen_name");
		return username;
	}
	public static long getExpiresTime(Context context){
		SharedPreferences shareTime = context.getSharedPreferences("expries",Context.MODE_PRIVATE);
		long time  = shareTime.getLong("expries", -1);
		return time;
	}
	public static Boolean isLimitExpires(Context context){
		Date currentDate = new Date();
		long saveExpires = getExpiresTime(context);
		long currentExpires = currentDate.getTime();
		if(saveExpires==-1 || currentExpires >= saveExpires ){
			return true;
		}
		return false;
	}
	public static void saveExpiresTime(Context context,long time){
		Date currentDate = new Date();
		long value=currentDate.getTime()+time*1000;
		Log.i("news", "expries:"+value);
		SharedPreferences shareTime = context.getSharedPreferences("expries",Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = shareTime.edit();
		editor.putLong("expries", value);
		editor.commit();
	}
	public static AccessToken initAccessToken(Context context){
		String token = TokenTools.getToken(context,ShareManager.SINA);
		AccessToken accessToken = new AccessToken(token, Weibo.getAppSecret());
		return accessToken;
	}
}
