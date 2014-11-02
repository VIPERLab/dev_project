package com.ifeng.news2.exception;

import android.content.Context;
import android.database.Cursor;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;

/**
 * 网络情况类
 * 
 * @author: liuxin
 * @version: v1.0.0
 * @since: 2012-4-10
 */
public class NetAttribute {

	private Context context;
	private static final String ERROR_TYPE = "errorType";
	private static final String WIFI = "wifi";
	private static final String MOBILE = "mobile";
	private String apnName;
	private String proxyServer;
	private boolean isUseProxy = false;
	private static final int PROXY_PORT = 80;

	private static final String CMWAP = "cmwap";
	private static final String CMNET = "cmnet";
	private static final String GWAP_3 = "3gwap";
	private static final String GNET_3 = "3gnet";
	private static final String UNIWAP = "uniwap";
	private static final String UNINET = "uninet";
	private static final String CTNET = "ctnet";
	private static final String CTWAP = "ctwap";
	private static final String CTWAP_SPECIAL = "#777";

	private final static String CMWAP_SERVER = "10.0.0.127";
	private final static String CTWAP_SERVER = "10.0.0.200";

	public NetAttribute(Context context) {
		this.context = context;
		init();
	}

	private void init() {
		String netType = getNetType();
		netType.toLowerCase();
		if (netType.equals(MOBILE))
			apnName = getAPN(context);
		isUseProxy = initUseProxy();
		if (isUseProxy) {
			proxyServer = initProxyServer();
		}
	}

	private boolean initUseProxy() {
		if (apnName != null
				&& (apnName.contains(CMWAP) || apnName.contains(GWAP_3)
						|| apnName.contains(UNIWAP) || apnName.contains(CTWAP) || apnName
							.contains(CTWAP_SPECIAL)))
			return true;
		return false;
	}

	/**
	 * 是否用代理
	 * 
	 * @return
	 */
	public boolean isUseProxy() {
		return isUseProxy;
	}

	/**
	 * 代理服务器IP
	 * 
	 * @return
	 */
	public String getProxyServer() {
		return proxyServer;
	}

	/**
	 * 代理服务器端口
	 * 
	 * @return
	 */
	public int getProxyPort() {
		return PROXY_PORT;
	}

	/**
	 * 当前网络类型
	 * 
	 * @return MOBILE GPRS WIFI
	 */
	public String getNetType() {
		ConnectivityManager conn = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		if (conn == null)
			return ERROR_TYPE;
		NetworkInfo info = conn.getActiveNetworkInfo();
		if (info == null)
			return ERROR_TYPE;
		return info.getTypeName().toLowerCase();// MOBILE��GPRS��;WIFI
	}

	public boolean isMobile() {
		return getNetType().equals(MOBILE);
	}
	public boolean isNetworkAvailable() {
		ConnectivityManager mConnMgr = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo mWifi = mConnMgr
				.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		NetworkInfo mMobile = mConnMgr
				.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
		boolean flag = false;
		if ((mWifi != null)
				&& ((mWifi.isAvailable()) || (mMobile.isAvailable()))) {
			if ((mWifi.isConnected()) || (mMobile.isConnected())) {
				flag = true;
			}
		}
		return flag;
	}

	private String getAPN(Context ctx) {
		Uri PREFERRED_APN_URI = Uri
				.parse("content://telephony/carriers/preferapn");
		Cursor cursor = ctx.getContentResolver().query(PREFERRED_APN_URI,
				new String[] { "_id", "apn", "type" }, null, null, null);
		cursor.moveToFirst();
		if (!cursor.isAfterLast()) {
			String apn = cursor.getString(1);
			cursor.close();
			if ("".equals(apn) || null == apn)
				return "";
			else
				return apn = apn.toLowerCase();
		} else {
			cursor.close();
			return "";
		}
	}

	private String initProxyServer() {
		if (apnName.contains(CMWAP) || apnName.contains(GWAP_3)
				|| apnName.contains(UNIWAP))
			return CMWAP_SERVER;
		else
			return CTWAP_SERVER;
	}

}
