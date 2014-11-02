package com.ifeng.share.config;

import android.content.Context;
import android.content.SharedPreferences;

import com.ifeng.share.action.ShareManager;
import com.ifeng.share.util.PushSharePreference;

/**
 * Token 工具类
 * @author PJW
 *
 */


public class TokenTools {
	//sina
	public static final String SINA_ACCESS_TOKEN = "sina_accessToken";
	public static final String SINA_ACCESS_TOKEN_SECRET = "sina_accessTokenSecret";
	public static final String SINA_USER_NAME = "sina_username";
	public static final String SINA_EXPIRES ="sina_expires";
	//tenqt
	public static final String TENQT_ACCESS_TOKEN = "tenq_accessToken";
	public static final String TENQT_ACCESS_OPENID = "tenq_openId";
	public static final String TENQT_ACCESS_CLIENTID = "tenq_clientId";
	public static final String TENQT_USER_NAME = "tenq_username";
	public static final String TENQT_CONSUMER_KEY = "tenq_oauth_consumer_key";
	public static final String TENQT_SIGNATURE_METHOD = "tenq_oauth_signature_method";
	public static final String TENQT_TIMESTAMP = "tenq_oauth_timestamp";
	public static final String TENQT_NONCE = "tenq_oauth_nonce";
	public static final String TENQT_VERSION = "tenq_oauth_version";
	public static final String TENQT_TOKEN = "tenq_oauth_token";
	public static final String TENQT_VERIFIER = "tenq_oauth_verifier";
	public static String TENQT_ACCESS_TOKEN_TIME = "tenq_accessToken";
	//ifeng
	public static final String IFENG_ACCESS_TOKEN = "ifeng_accessToken";
	public static final String IFENG_ACCESS_TOKEN_SECRET="ifeng_accessTokenSecret";
	public static final String IFENG_USER_NAME = "ifeng_username";
	//renren
	public static final String  RENREN_USER_NAME = "renren_username";
	private static final String RENREN_SDK_CONFIG = "renren_sdk_config";
	private static final String RENREN_SDK_CONFIG_PROP_USER_ID = "renren_sdk_config_prop_user_id";
	private static final String RENREN_SDK_CONFIG_PROP_ACCESS_TOKEN = "renren_sdk_config_prop_access_token";
	private static final String RENREN_SDK_CONFIG_PROP_SESSION_KEY = "renren_sdk_config_prop_session_key";
	private static final String RENREN_SDK_CONFIG_PROP_SESSION_SECRET = "renren_sdk_config_prop_session_secret";
	//kaixin
	private static final String KAIXIN_SDK_STORAGE = "kaixin_sdk_storage";
	private static final String KAIXIN_SDK_STORAGE_ACCESS_TOKEN = "kaixin_sdk_storage_access_token";
	//fetion
	public static final String FETION_ACCESS_TOKEN = "fetion_accessToken";
	public static final String FETION_ACCESS_TOKEN_SECRET = "fetion_accessTokenSecret";
	public static final String FETION_USER_NAME = "fetion_username";
	//tenqz
	public static final String TENQZ_ACCESS_TOKEN = "tenqz_access_token";
	public static final String TENQZ_OPENID = "tenqz_openid";
	public static final String TENQZ_USER_NAME ="tenqz_username";
	public static final String TENQZ_EXPIRES ="tenqz_expires";

	public static String KIFENG_USERINFO = "k_ifeng_userInfo";
	public static String SHARE_RECEIVER_ACTION="com.ifeng.share.share_action";
	public static void saveToken(Context ctx, String type, String token, String tokenSecret,String userName){
		PushSharePreference p = new PushSharePreference(ctx);
		if (ShareManager.SINA.equals(type)) {
			p.saveStringValueToSharePreference(TokenTools.SINA_ACCESS_TOKEN, token);
			p.saveStringValueToSharePreference(TokenTools.SINA_ACCESS_TOKEN_SECRET, tokenSecret);
			p.saveStringValueToSharePreference(TokenTools.SINA_USER_NAME, userName);
		}/*else if(ShareManager.TENQT.equals(type)){
			p.saveStringValueToSharePreference(TokenTools.TENQT_ACCESS_TOKEN, token);
			p.saveStringValueToSharePreference(TokenTools.TENQT_ACCESS_TOKEN_SECRET, tokenSecret);
			p.saveStringValueToSharePreference(TokenTools.TENQT_USER_NAME, userName);
		}*/else if (ShareManager.IFENG.equals(type)) {
			p.saveStringValueToSharePreference(TokenTools.IFENG_ACCESS_TOKEN, token);
			p.saveStringValueToSharePreference(TokenTools.IFENG_ACCESS_TOKEN_SECRET, tokenSecret);
			p.saveStringValueToSharePreference(TokenTools.IFENG_USER_NAME, userName);
		}else if (ShareManager.FETION.equals(type)) {
			p.saveStringValueToSharePreference(TokenTools.FETION_ACCESS_TOKEN, token);
			p.saveStringValueToSharePreference(TokenTools.FETION_ACCESS_TOKEN_SECRET, tokenSecret);
			p.saveStringValueToSharePreference(TokenTools.FETION_USER_NAME, userName);
		}
	}
	
	/**
	 * 保存腾讯微博授权后的token等信息
	 * 
	 * @param ctx
	 * @param accessToken
	 * @param openid
	 * @param clientId
	 * @param userName
	 */
	public static void saveTenqtOauthMessage(Context ctx, String accessToken, String openid, String clientId,String userName){
		PushSharePreference p = new PushSharePreference(ctx);
		p.saveStringValueToSharePreference(TokenTools.TENQT_ACCESS_TOKEN, accessToken);
		p.saveStringValueToSharePreference(TokenTools.TENQT_ACCESS_OPENID, openid);
		p.saveStringValueToSharePreference(TokenTools.TENQT_USER_NAME, userName);
		
	}
	
	/**
	 * 保存QQ空间授权后的token等信息
	 * @param ctx
	 * @param accessToken
	 * @param openid
	 */
	public static void saveTenqzOauthMessage(Context ctx , String accessToken , String openid ){
		PushSharePreference p = new PushSharePreference(ctx);
		p.saveStringValueToSharePreference(TokenTools.TENQZ_ACCESS_TOKEN, accessToken);
		p.saveStringValueToSharePreference(TokenTools.TENQZ_OPENID, openid);
	}
	
	/**
	 * 保存失效时间
	 * @param context
	 * @param time
	 */
	public static void saveExpiresTime(Context context, long time , String expiresType) {
		long value = System.currentTimeMillis() + time * 1000;
		SharedPreferences shareTime = context.getSharedPreferences(expiresType,
				Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = shareTime.edit();
		editor.putLong(expiresType, value);
		editor.commit();
	}
	
	/**
	 * 清除失效时间
	 * 
	 * @param context
	 */
	public static  void clearExpiresTime(Context context ,String expiresType) {
		SharedPreferences shareTime = context.getSharedPreferences(expiresType,
				Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = shareTime.edit();
		editor.clear();
		editor.commit();
	}
	
	/**
	 * 获取失效时间
	 * 
	 * @param context
	 * @return
	 */
	public static  long getExpiresTime(Context context , String expiresType) {
		SharedPreferences shareTime = context.getSharedPreferences(expiresType,
				Context.MODE_PRIVATE);
		long time = shareTime.getLong(expiresType, -1);
		return time;
	}
	
	/**
	 * 判断失效时间
	 * 
	 * @param context
	 * @return
	 */
	public static Boolean isLimitExpires(Context context , String expiresType) {
		long saveExpires = TokenTools.getExpiresTime(context,expiresType);
		if (saveExpires == -1) {
			return true;
		}
		return ((saveExpires - System.currentTimeMillis()) / 1000) <= 0 ? true
				: false;
	}
	
	/**
	 * 获取腾讯微博的openId
	 * @param ctx
	 * @return
	 */
	public static String getTenqtOpenId(Context ctx){
		PushSharePreference p = new PushSharePreference(ctx);
		return p.getStringValueByKey(TENQT_ACCESS_OPENID);
	}
	
	/**
	 * 获取腾讯微博的ClientId
	 * @param ctx
	 * @return
	 */
	public static String getTenqtClientId(Context ctx){
		PushSharePreference p = new PushSharePreference(ctx);
		return p.getStringValueByKey(TENQT_ACCESS_CLIENTID);
	}
	
	/**
	 * 获取QQ空间的openId
	 * @param ctx
	 * @return
	 */
	public static String getTenqzOpenId(Context ctx ){
		PushSharePreference p = new PushSharePreference(ctx);
		return p.getStringValueByKey(TENQZ_OPENID);
	}
	public static void saveValue(Context ctx, String name,String value){
		PushSharePreference p = new PushSharePreference(ctx);
		p.saveStringValueToSharePreference(name, value);
	}
	public static String getValue(Context ctx, String name){
		PushSharePreference p = new PushSharePreference(ctx);
		return p.getStringValueByKey(name);
	}
	public static void removeToken(Context ctx,String type){
		PushSharePreference p = new PushSharePreference(ctx);
		if (ShareManager.SINA.equals(type)) {
			p.removeSharePreferences(TokenTools.SINA_ACCESS_TOKEN);
			p.removeSharePreferences(TokenTools.SINA_ACCESS_TOKEN_SECRET);
			p.removeSharePreferences(TokenTools.SINA_USER_NAME);
		}else if(ShareManager.TENQT.equals(type)){
			p.removeSharePreferences(TokenTools.TENQT_ACCESS_TOKEN);
			p.removeSharePreferences(TokenTools.TENQT_ACCESS_OPENID);
			p.removeSharePreferences(TokenTools.TENQT_ACCESS_CLIENTID);
			p.removeSharePreferences(TokenTools.TENQT_USER_NAME);
		}else if (ShareManager.IFENG.equals(type)) {
			p.removeSharePreferences(TokenTools.IFENG_ACCESS_TOKEN);
			p.removeSharePreferences(TokenTools.IFENG_ACCESS_TOKEN_SECRET);
			p.removeSharePreferences(TokenTools.IFENG_USER_NAME);
		}else if (ShareManager.FETION.equals(type)) {
			p.removeSharePreferences(TokenTools.FETION_ACCESS_TOKEN);
			p.removeSharePreferences(TokenTools.FETION_ACCESS_TOKEN_SECRET);
			p.removeSharePreferences(TokenTools.FETION_USER_NAME);
		}else if (ShareManager.TENQZ.equals(type)){
			p.removeSharePreferences(TokenTools.TENQZ_ACCESS_TOKEN);
			p.removeSharePreferences(TokenTools.TENQZ_OPENID);
			p.removeSharePreferences(TokenTools.TENQZ_USER_NAME);
		}
	}

	public static String getToken(Context ctx, String type){
		PushSharePreference p = new PushSharePreference(ctx);
		if (ShareManager.SINA.equals(type)) {
			return p.getStringValueByKey(SINA_ACCESS_TOKEN);
		}else if(ShareManager.TENQT.equals(type)){
			return p.getStringValueByKey(TENQT_ACCESS_TOKEN);
		}else if(ShareManager.RENREN.equals(type)){
			return getRenRenToken(ctx);
		}else if (ShareManager.IFENG.equals(type)) {
			return p.getStringValueByKey(IFENG_ACCESS_TOKEN);
		}else if (ShareManager.FETION.equals(type)) {
			return p.getStringValueByKey(FETION_ACCESS_TOKEN);
		}else if (ShareManager.TENQZ.equals(type)) {
			return p.getStringValueByKey(TENQZ_ACCESS_TOKEN);
		}else{
			return null;
		}
	}
	public static String getRenRenToken(Context ctxt){
		SharedPreferences sp = ctxt.getSharedPreferences(RENREN_SDK_CONFIG,
				Context.MODE_PRIVATE);
		String accessToken = sp.getString(RENREN_SDK_CONFIG_PROP_ACCESS_TOKEN,
				null);
		if (accessToken == null) {
			return null;
		}
		return accessToken;
	}
	public static void removeRenRenToken(Context context){
		SharedPreferences sp = context.getSharedPreferences(RENREN_SDK_CONFIG,
				Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = sp.edit();
		editor.remove(RENREN_SDK_CONFIG_PROP_ACCESS_TOKEN);
		editor.remove(RENREN_SDK_CONFIG_PROP_SESSION_KEY);
		editor.remove(RENREN_SDK_CONFIG_PROP_SESSION_SECRET);
		editor.commit();
		removeRenrenUsername(context);
	}
	public static void removeRenrenUsername(Context context){
		PushSharePreference p = new PushSharePreference(context);
		p.removeSharePreferences(RENREN_USER_NAME);
	}
	public static long getRenrenUid(Context context){
		SharedPreferences sp = context.getSharedPreferences(RENREN_SDK_CONFIG,
				Context.MODE_PRIVATE);
		return sp.getLong(RENREN_SDK_CONFIG_PROP_USER_ID, 0);
	}
	public static String getKaixinToken(Context ctxt){
		SharedPreferences sp = ctxt.getSharedPreferences(KAIXIN_SDK_STORAGE,
				Context.MODE_PRIVATE);
		String accessToken = sp.getString(KAIXIN_SDK_STORAGE_ACCESS_TOKEN,
				null);
		if (accessToken == null) {
			return null;
		}
		return accessToken;
	}
	public static String getIfengToken(Context ctxt){
		SharedPreferences sp = ctxt.getSharedPreferences(KIFENG_USERINFO,
				Context.MODE_PRIVATE);
		String token = sp.getString("token", "");
		return token;
	}
	public static String getIfengTokenCecret(Context ctxt){
		SharedPreferences sp = ctxt.getSharedPreferences(KIFENG_USERINFO,
				Context.MODE_PRIVATE);
		String token_secret = sp.getString("token_secret", "");
		return token_secret;
	}

	public static String getTokenSecret(Context ctx, String type){
		PushSharePreference p = new PushSharePreference(ctx);
		if (ShareManager.SINA.equals(type)) {
			return p.getStringValueByKey(SINA_ACCESS_TOKEN_SECRET);
		}else if(ShareManager.TENQT.equals(type)){
			return p.getStringValueByKey(TENQT_ACCESS_OPENID);
		}else if (ShareManager.IFENG.equals(type)) {
			return p.getStringValueByKey(IFENG_ACCESS_TOKEN_SECRET);
		}else{
			return null;
		}
	}

	public static String getUserName(Context ctx,String type){
		PushSharePreference p = new PushSharePreference(ctx);
		if (ShareManager.SINA.equals(type)) {
			return p.getStringValueByKey(SINA_USER_NAME);
		}else if(ShareManager.TENQT.equals(type)){
			return p.getStringValueByKey(TENQT_USER_NAME);
		}else if(ShareManager.TENQZ.equals(type)){
			return p.getStringValueByKey(TENQZ_USER_NAME);
		}else if (ShareManager.IFENG.equals(type)) {
			return p.getStringValueByKey(IFENG_USER_NAME);
		}else if (ShareManager.RENREN.equals(type)) {
			return p.getStringValueByKey(RENREN_USER_NAME);
		}else if (ShareManager.FETION.equals(type)) {
			String fetionName=p.getStringValueByKey(RENREN_USER_NAME);
			if (fetionName==null || fetionName.length()==0) {
				return "飞信用户";
			}
			return fetionName;
		}else{
			return null;
		}
	}
	public static void setRenrenUserName(Context context,String name){
		PushSharePreference p = new PushSharePreference(context);
		p.saveStringValueToSharePreference(RENREN_USER_NAME, name);
	}
	public static int getIfengUserBid(Context ctxt){
		SharedPreferences sp = ctxt.getSharedPreferences(KIFENG_USERINFO,
				Context.MODE_PRIVATE);
		return sp.getInt("bid", 0);
	}
	public static int getIfengUid(Context ctxt){
		SharedPreferences sp = ctxt.getSharedPreferences(KIFENG_USERINFO,
				Context.MODE_PRIVATE);
		return sp.getInt("uid", 0);
	}
}
