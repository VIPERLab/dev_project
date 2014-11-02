package com.ifeng.news2.commons.upgrade;

import org.json.JSONArray;
import org.json.JSONException;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;

public class Utils {

	/**
	 * 获取应用版本号
	 * 
	 * @param ctx
	 * @return
	 */
	public static Version getSoftwareVersion(Context ctx) {
		String version = "";
		try {
			PackageInfo packageInfo = ctx.getPackageManager().getPackageInfo(
					ctx.getPackageName(), 0);
			version = packageInfo.versionName;
		} catch (PackageManager.NameNotFoundException e) {
			e.printStackTrace();
		}

		return new Version(version);
	}

	public static String getAppLabel(Context context) {
		return context.getResources().getString(
				context.getApplicationInfo().labelRes);
	}

	public static String[] json2String(JSONArray arr) throws JSONException {
		String[] strings = new String[arr.length()];
		for (int i = 0; i < strings.length; i++)
			strings[i] = arr.getString(i);
		return strings;
	}
}
