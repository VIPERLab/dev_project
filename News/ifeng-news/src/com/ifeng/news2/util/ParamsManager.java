package com.ifeng.news2.util;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.WindowManager;

import com.ifeng.news2.Config;
import com.qad.util.Utils;

public class ParamsManager {
	private static String params = "";
	private static final String vt = "5";
	private static String simpleParam;
	public ParamsManager(Context context){
	}
	public static void initParams(Context ctx){
		// uid和统计中userkey取法应保持一致
		params = "gv="+getGroundVersion(ctx)+"&av="+getAtomVersion()+"&uid="+Utils.getIMEI(ctx)+"&proid="+getProductId()+"&os="+getOS()+"&df="+getDeviceFamily()+"&vt="+getVT()+"&screen="+getScreenSize(ctx)
				+"&publishid="+Config.PUBLISH_ID;
		simpleParam = "gv="+getGroundVersion(ctx)+"&os="+getOS();
	}
	/**
	 * App的Ground层版本号
	 * @return
	 */
	private static String getGroundVersion(Context ctx){
		String version = "";
		try{ 
			PackageInfo packageInfo = ctx.getPackageManager().getPackageInfo(ctx.getPackageName(), 0); 
			version = packageInfo.versionName;         	
		}catch (Exception e){ 
		}
		return version;
	}
	/**
	 * 屏幕尺寸
	 * @return
	 */
	private static String getScreenSize(Context ctx){
//		Display display = activity.getWindowManager().getDefaultDisplay();
	    Display display = ((WindowManager) ctx.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
//	    int screenWidth = 0;
//	    int screenHeight = 0;
//	    if (android.os.Build.VERSION.SDK_INT < 13) {
//    		screenWidth = display.getWidth();
//    		screenHeight = display.getHeight();
//	    } else {
	        DisplayMetrics metrics = new DisplayMetrics();
	        display.getMetrics(metrics);
	        int screenWidth = metrics.widthPixels;
	        int screenHeight = metrics.heightPixels;
//	    }
		StringBuilder screenSize= new StringBuilder();
		screenSize.append(screenWidth).append('x').append(screenHeight);
		return screenSize.toString();
	}
	/**
	 * App的Atom层版本号
	 * @return
	 */
	private static String getAtomVersion(){
		return Config.CURRENT_CONFIG_VERSION;
	}

	/**
	 * 操作系统和版本号，例如 android_10
	 * @return
	 */
	private static String getOS(){
		return "android_"+android.os.Build.VERSION.SDK_INT;
	}
	
	/**TODO
	 * 设备类型：iphone|ipad|phone|pad 等 
	 * @return
	 */
	private static String getDeviceFamily(){
		return "androidphone";
	}
	/**
	 * 产品标识 
	 * @return
	 */
	private static String getProductId(){
		return StatisticUtil.STATISTICS_SOFT_ID;
	}
	/**
	 * IMCP要求的适配版本号，为保持一致，非IMCP接口也采用，默认为5
	 * @return
	 */
	private static String getVT(){
		return vt;
	}
	
	/**
	 * 添加默认参数
	 * @param url
	 * @return
	 */
	public static String addParams(String url){
		if(url==null)return null;
		if(url.contains("?")){
			url = url + "&" + params;
		}else{
			url = url + "?" + params;
		}
		return url;
	}
	/**
	 * 添加默认参数
	 * @param url
	 * @return
	 */
	public static String addParams(Context context,String url){
		if(url==null)return null;
		if(TextUtils.isEmpty(params))initParams(context);
		if(url.contains("?")){
			url = url + "&" + params;
		}else{
			url = url + "?" + params;
		}
		return url;
	}
	/**
	 * 批量下载文章专用Params，即能区分版本，也能让后台缓存请求数据。
	 * @param url
	 * @return
	 */
	public static String addSimpleParams(String url){
		if(url==null)return null;
		if(url.contains("?")){
			url = url + "&" + simpleParam;
		}else{
			url = url + "?" + simpleParam;
		}
		return url;
	}
}
