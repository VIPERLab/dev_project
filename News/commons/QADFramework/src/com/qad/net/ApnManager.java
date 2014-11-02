package com.qad.net;

import java.lang.ref.WeakReference;

import android.content.Context;
import android.database.Cursor;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;

import com.qad.system.PhoneManager;
import com.qad.system.listener.NetworkListener;

/**
 * 调用init初始化。 之后可以通过访问proxy_server和proxy_port来设置代理
 * 改用android.net.Proxy,但是发现在联想lehphone上面出现问题。暂时沿用ApnManager
 * 
 * @author 13leaf
 * 
 */
public class ApnManager implements NetworkListener {

	/**
	 * 抽象出三种网络类型：联通移动wap，电信wap，其他的都是net类型
	 * 其中wap是需要设置代理的移动、联通WAP：10.0.0.172:80，电信wap：代理：10.0.0.200:80
	 * @author guotd
	 *
	 */
	public static interface APNNet {

		String CMWAP = "cmwap";

		String CMNET = "cmnet";

		String WAP_3G = "3gwap";

		String NET_3G = "3gnet";

		String UNIWAP = "uniwap";

		String UNINET = "uninet";

		String CTNET = "ctnet";

		String CTWAP = "ctwap";
	}

	public final static String CMWAP_SERVER = "10.0.0.172";
	public final static String CTWAP_SERVER = "10.0.0.200";
	
	public static final    int TYPE_NET_WORK_DISABLED = 0;// 网络不可用
	public static final    int TYPE_CM_CU_WAP = 4;// 移动联通wap10.0.0.172    
	public static final    int TYPE_CT_WAP = 5;// 电信wap 10.0.0.200    
	public static final    int TYPE_OTHER_NET = 6;// 电信,移动,联通,wifi 等net网络    
	public static Uri PREFERRED_APN_URI = Uri.parse("content://telephony/carriers/preferapn");  
	public static boolean useProxy = false;
	
//	static boolean useProxy = false;
	static String proxy_server = CMWAP_SERVER;
	static int proxy_port = 80;
	
	/**
	 * 存储系统默认代理设置，比如WIFI下的代理，当用户切换到WIFI时
	 * 还原代理设置为默认代理
	 */
	static String defaultProxyServer = null;
	static String defaultProxyPort = null;

	private static ApnManager instance;
	WeakReference<Context> refContext;

	public static ApnManager getInstance(Context context) {
		if (instance == null) {
			instance = new ApnManager(context);
		}
		return instance;
	}

	private ApnManager(final Context context) {
	    defaultProxyServer = System.getProperty("http.proxyHost");
        defaultProxyPort = System.getProperty("http.proxyPort");
//        System.err.println("defaultProxyServer=" + defaultProxyServer);
//        System.err.println("defaultProxyPort=" + defaultProxyPort);
		init(context);
		refContext = new WeakReference<Context>(context);
	}

	private void init(Context context) {
		setProxyAccordingApn(context);
	}

	public static int getProxy_port() {
		return proxy_port;
	}

	public static String getProxy_server() {
		return proxy_server;
	}

	private String _init(Context ctx) {
		// 在连接WIFI的情况下teleManager.getNetworkOperatorName()也会返回运营商名字比如"CHN-CUGSM"，所以
		// 不能以此作为2G/3G的判断
		if (PhoneManager.getInstance(ctx).isConnectedWifi()) {
//			useProxy = false;
			unsetProxy();
			return "";
		}
		TelephonyManager teleManager = (TelephonyManager) ctx
				.getSystemService(Context.TELEPHONY_SERVICE);
		Log.d("tag", teleManager.getNetworkOperatorName() + "-----");
		if ("CHN-CUGSM".equals(teleManager.getNetworkOperatorName())
				&& TelephonyManager.NETWORK_TYPE_UMTS == teleManager
						.getNetworkType()) {
//			useProxy = true;
			setProxy();
			proxy_server = CMWAP_SERVER;
			return APNNet.WAP_3G;
		} else if ("CHN-CUGSM".equals(teleManager.getNetworkOperatorName())
				&& 15 /* TelephonyManager.NETWORK_TYPE_HSPAP */== teleManager
						.getNetworkType()) {
//			useProxy = true;
			setProxy();
			proxy_server = CMWAP_SERVER;
			return APNNet.WAP_3G;
		} else if ("China Unicom".equals(teleManager.getNetworkOperatorName())) {
			//MI2
//			useProxy = true;
			setProxy();
			proxy_server = CMWAP_SERVER;
			return APNNet.UNIWAP;
		} else if ("CHN-UNICOM".equals(teleManager.getNetworkOperatorName())) {
			//MX2
//			useProxy = true;
			setProxy();
			proxy_server = CMWAP_SERVER;
			return APNNet.UNIWAP;
		}else if ("中国联通".equals(teleManager.getNetworkOperatorName())) {
			//note1
//			useProxy = true;
			setProxy();
			proxy_server = CMWAP_SERVER;
			return APNNet.WAP_3G;
		} if ("中国移动".equals(teleManager.getNetworkOperatorName())) {
			//note1
//			useProxy = true;
			setProxy();
			proxy_server = CMWAP_SERVER;
			return APNNet.CMWAP;
		} else {
//			useProxy = false;
			unsetProxy();
			return "";
		}
		/*
		 * Uri PREFERRED_APN_URI = Uri
		 * .parse("content://telephony/carriers/preferapn"); Cursor cursor =
		 * ctx.getContentResolver().query(PREFERRED_APN_URI, new String[] {
		 * "_id", "apn", "type" }, null, null, null);
		 * 
		 * if (cursor == null || !cursor.moveToFirst()) { useProxy = false;
		 * return null; }
		 * 
		 * String apn = new StringBuilder(cursor.getString(1)).toString();
		 * cursor.close(); if ("".equals(apn) || apn == null) { useProxy =
		 * false; return null; } else { apn = apn.toLowerCase(); if
		 * (apn.startsWith(APNNet.CMNET)) { useProxy = false; return
		 * APNNet.CMNET; } else if (apn.startsWith(APNNet.CMWAP)) { useProxy =
		 * true; proxy_server = CMWAP_SERVER; return APNNet.CMWAP; } else if
		 * (apn.startsWith(APNNet.GNET_3)) { useProxy = false; return
		 * APNNet.GNET_3; } else if (apn.startsWith(APNNet.GWAP_3)) { useProxy =
		 * true; proxy_server = CMWAP_SERVER; return APNNet.GWAP_3; } else if
		 * (apn.startsWith(APNNet.UNINET)) { useProxy = false; return
		 * APNNet.UNINET; } else if (apn.startsWith(APNNet.UNIWAP)) { useProxy =
		 * true; proxy_server = CMWAP_SERVER; return APNNet.UNIWAP; } else if
		 * (apn.startsWith(APNNet.CTNET)) { useProxy = false; return
		 * APNNet.CTNET; } else if (apn.startsWith(APNNet.CTWAP)) { useProxy =
		 * true; proxy_server = CTWAP_SERVER; return APNNet.CTWAP; } else {
		 * useProxy = false; return ""; } }
		 */
	}

	@Override
	public void onWifiConnected(NetworkInfo networkInfo) {
//		useProxy = false;
		unsetProxy();
	}

	@Override
	public void onMobileConnected(NetworkInfo networkInfo) {
//		Context context = refContext.get();
//		if (context != null)
//			init(context);
		setProxyAccordingApn(refContext.get());
	}

	@Override
	public void onDisconnected(NetworkInfo networkInfo) {

	}
	
	
	public void setProxyAccordingApn(Context ctx) {
		// 根据APN设置相应代理
		if (null != ctx) {
			int res = checkApnType(ctx);
			switch(res) {
			case TYPE_NET_WORK_DISABLED:
				// do nothing;
				break;
			case TYPE_CM_CU_WAP:
				proxy_server = CMWAP_SERVER;
				setProxy();
				useProxy = true;
				break;

			case TYPE_CT_WAP:
				proxy_server = CTWAP_SERVER;
				setProxy();
				useProxy = true;
				break;

			default: // TYPE_OTHER_NET
			unsetProxy();
			useProxy = false;
			}
		}
	}
	
	public int checkApnType(Context mContext) {
		try {    
			final ConnectivityManager connectivityManager = (ConnectivityManager) mContext    
					.getSystemService(Context.CONNECTIVITY_SERVICE);    
			final NetworkInfo mobNetInfoActivity = connectivityManager    
					.getActiveNetworkInfo();    
			if (mobNetInfoActivity == null || !mobNetInfoActivity.isAvailable()) {    
				// 注意一：    
				// NetworkInfo 为空或者不可以用的时候正常情况应该是当前没有可用网络，    
				// 但是有些电信机器，仍可以正常联网，    
				
				Log.i("Sdebug", "=====================>无网络");    
				return TYPE_NET_WORK_DISABLED;    
			} else {    

				// NetworkInfo不为null开始判断是网络类型    
				int netType = mobNetInfoActivity.getType();    
				if (netType == ConnectivityManager.TYPE_WIFI) {    
					// wifi net处理    
//					Log.i("Sdebug", "=====================>wifi网络");    
					return TYPE_OTHER_NET;    
				} else if (netType == ConnectivityManager.TYPE_MOBILE) {
					// ICE_CREAM_SANDWICH (SDK 14)以后Android不允许第三方应用获得WRITE_APN_SETTINGS权限，
					// 所以不能在4.0以上的系统中不能再使用读取APN数据库的方法
					if (android.os.Build.VERSION.SDK_INT < 14) {
						// 注意二：    
						// 判断是否电信wap:    
						//不要通过getExtraInfo获取接入点名称来判断类型，    
						// 因为通过目前电信多种机型测试发现接入点名称大都为#777或者null，    
						// 电信机器wap接入点中要比移动联通wap接入点多设置一个用户名和密码,    
						// 所以可以通过这个进行判断！    

						final Cursor c = mContext.getContentResolver().query(    
								PREFERRED_APN_URI, null, null, null, null);    
						if (c != null) {
							c.moveToFirst();    
							final String user = c.getString(c.getColumnIndex("user")); 
							final String name = c.getString(c.getColumnIndex("name")); 
							if (!TextUtils.isEmpty(user)) {
								Log.i("Sdebug", "=====================>代理："    
										+ c.getString(c.getColumnIndex("proxy")));    
								if (user.startsWith(APNNet.CTWAP)) {    
									Log.i("Sdebug", "=====================>电信wap网络");    
									return TYPE_CT_WAP;    
								}    
							}
							if (!TextUtils.isEmpty(name)) {
								if (name.equals(APNNet.CMWAP) || name.equals(APNNet.WAP_3G)    
										|| name.equals(APNNet.UNIWAP)) {
									Log.i("Sdebug", "=====================>移动联通wap网络");    
									return TYPE_CM_CU_WAP;  
								} else if (name.equals(APNNet.CTWAP)) {
									Log.i("Sdebug", "=====================>电信wap网络"); 
									return TYPE_CT_WAP;
								}
							}
						}    
						c.close();
					} 
					// 注意三：    
					// 判断是移动联通wap:    
					// 其实还有一种方法通过getString(c.getColumnIndex("proxy")获取代理ip    
					//来判断接入点，10.0.0.172就是移动联通wap，10.0.0.200就是电信wap，但在    
					//实际开发中并不是所有机器都能获取到接入点代理信息，例如魅族M9 （2.2）等...    
					// 所以采用getExtraInfo获取接入点名字进行判断    

					String netMode = mobNetInfoActivity.getExtraInfo();    
					Log.i("Sdebug", "netMode ================== " + netMode);    
					if (!TextUtils.isEmpty(netMode)) {    
						// 通过apn名称判断是否是联通和移动wap    
						netMode=netMode.toLowerCase();    
						if (netMode.equals(APNNet.CMWAP) || netMode.equals(APNNet.WAP_3G)    
								|| netMode.equals(APNNet.UNIWAP)) {    
							Log.i("Sdebug", "=====================>移动联通wap网络");    
							return TYPE_CM_CU_WAP;    
						} else {
							if (APNNet.CTWAP.equals(netMode)) {
								Log.i("Sdebug", "=====================>电信wap网络"); 
								return TYPE_CT_WAP;
							}
						}

					}    

				}    
			}    
		} catch (Exception ex) {    
			ex.printStackTrace();    
			return TYPE_OTHER_NET;    
		}    

		return TYPE_OTHER_NET; 
	}
	
	private void setProxy() {
		System.setProperty("http.proxyHost", proxy_server);
		System.setProperty("http.proxyPort", String.valueOf(proxy_port));
	}
	
	private void unsetProxy() {
		// 如果有默认代理，设置为系统默认代理，否则清除代理设置
		if (!TextUtils.isEmpty(ApnManager.defaultProxyServer)
		        && !TextUtils.isEmpty(ApnManager.defaultProxyPort)
		        && !ApnManager.defaultProxyServer.equals(CMWAP_SERVER)
		        && !ApnManager.defaultProxyServer.equals(CTWAP_SERVER)) {
		    System.setProperty("http.proxyHost", ApnManager.defaultProxyServer);
		    System.setProperty("http.proxyPort", ApnManager.defaultProxyPort);
		} else {
		    System.getProperties().remove("http.proxyHost");
	        System.getProperties().remove("http.proxyPort");
		}
	}
}
