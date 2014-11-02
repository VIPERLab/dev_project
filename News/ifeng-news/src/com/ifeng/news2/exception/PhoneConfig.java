package com.ifeng.news2.exception;



import java.net.URLEncoder;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.telephony.TelephonyManager;

import com.ifeng.news2.Config;
import com.ifeng.news2.util.StatisticUtil;

public class PhoneConfig {
	private static String mos;
	private static String ua;
	private static String softversion;
	private static String userkey;
	private final static String USER_AGENT = "IFENGVIDEO5_Platform_Android";
	public static void phoneConfigInit(Context ctx) {
		mos = "android_" + android.os.Build.VERSION.SDK_INT;
		softversion = softwareVersionInit(ctx);
		userkey = imeiInit(ctx);
		ua = uAinit();
	}

	public static String getMos() {
		return mos;
	}

	public static String getUa() {
		return ua;
	}

	public static String getSoftversion() {
		return softversion;
	}

	/**
	 * 获取MD5加密的userkey
	 * 
	 * @return
	 */
	public static String getUserkey() {
		return md5s(userkey);
	}
	public static String md5s(String plainText) {
		String str = "";
		try {
			MessageDigest md = MessageDigest.getInstance("MD5");
			md.update(plainText.getBytes());
			byte b[] = md.digest();
			int i;
			StringBuffer buf = new StringBuffer("");
			for (int offset = 0; offset < b.length; offset++) {
				i = b[offset];
				if (i < 0) {
					i += 256;
				}
				if (i < 16) {
					buf.append("0");
				}
				buf.append(Integer.toHexString(i));
			}
			str = buf.toString();
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		return str;
	}
	private static String softwareVersionInit(Context ctx) {
		String version = "";
		try {
			PackageInfo packageInfo = ctx.getPackageManager().getPackageInfo(
					ctx.getPackageName(), 0);
			version = packageInfo.versionName;
		} catch (PackageManager.NameNotFoundException e) {
			e.printStackTrace();
		}
		return version;
	}

	private static String imeiInit(Context ctx) {
		String imei = "";
		TelephonyManager telephonyManager = (TelephonyManager) ctx
				.getSystemService(Context.TELEPHONY_SERVICE);
		if (telephonyManager != null)
			imei = telephonyManager.getDeviceId();
		if (imei == "" || imei == null)
			imei = "" + System.currentTimeMillis();
		return imei;
	}

	/**
	 * 获取系统ua
	 * 
	 * @return
	 */
	private static String uAinit() {
		String ua = null;
		try {
			ua = URLEncoder.encode(android.os.Build.MODEL + "_"
					+ android.os.Build.VERSION.RELEASE, "utf-8");
		} catch (Exception e) {
			ua = USER_AGENT;
		}
		return ua;
	}

	public static String getPhoneConfigCombineString(String net) {
		return "mos=" + mos + "&" + "softid=" + StatisticUtil.STATISTICS_SOFT_ID + "&" + "softversion="
				+ softversion + "&" + "publishid=" + Config.PUBLISH_ID + "&"
				+ "userkey=" + getUserkey() + "&" + "ua=" + ua + "&" + "net="
				+ net + "&datatype="+ StatisticUtil.STATISTICS_DATA_TYPE+"&city=Mars";
	}
}
