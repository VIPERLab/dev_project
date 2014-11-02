package com.ifeng.share.util;

import java.text.SimpleDateFormat;
import java.util.Date;

import android.content.Context;
import android.content.SharedPreferences;
import android.telephony.TelephonyManager;

public class PushSharePreference {

	private Context ctx;
	private String FileName = "share";

	public PushSharePreference(Context ctx) {
		this.ctx = ctx;
	}

	/**
	 * ������������������Userkey
	 * 
	 * @return
	 */
	public String getUserkey() {
		return this.getStringValueByKey("params_userkey");
	}

	public String getStringValueByKey(String key) {
		SharedPreferences sharePre = ctx.getSharedPreferences(FileName,
				Context.MODE_PRIVATE);
		return sharePre.getString(key, null);
	}

	/**
	 * ������������������Userid
	 * 
	 * @param ctx
	 * @return
	 */
	public String getUserid(Context ctx) {
		String uid = "";
		PushSharePreference preference = new PushSharePreference(ctx);
		uid = preference.getStringValueByKey("params_userid");
		if (uid == null || uid.length() < 10) {
			uid = getIMEI(ctx) + "_";
			Date d = new Date();
			SimpleDateFormat sf = new SimpleDateFormat("yyyyMMddHHmmss");
			uid += sf.format(d);
			uid += getRandomByString(6);

			preference.saveStringValueToSharePreference("params_userid", uid);
		}

		return uid;
	}

	public void saveStringValueToSharePreference(String key, String value) {
		SharedPreferences sharePre = ctx.getSharedPreferences(FileName,
				Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = sharePre.edit();
		editor.putString(key, value);
		editor.commit();
	}

	public String getRandomByString(int numlen) {
		String str = "";
		for (int i = 0; i < numlen; i++) {
			str += String.valueOf((int) (Math.random() * 10));
		}
		return str;
	}

	public String getIMEI(Context ctx) {
		String imei = "";
		TelephonyManager telephonyManager = (TelephonyManager) ctx
				.getSystemService(Context.TELEPHONY_SERVICE);
		if (telephonyManager != null)
			imei = telephonyManager.getDeviceId();
		if (imei == "")
			imei = "0";

		return imei;
	}

	/**
	 * Remove key from SharePreference
	 * 
	 * @param fileName
	 * @param key
	 */
	public void removeSharePreferences(String key) {
		SharedPreferences sharePre = ctx.getSharedPreferences(FileName,
				Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = sharePre.edit();
		editor.remove(key);
		editor.commit();
	}
}
