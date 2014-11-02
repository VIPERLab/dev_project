package com.qad.util;

import java.util.HashMap;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.UUID;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.text.AndroidCharacter;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import com.qad.system.PhoneManager;

public class Utils {

	//LTE 网络类型
	private static final int NETWORK_TYPE_LTE = 0x0000000d ;
	//联通3G网络
	private static final int NETWORK_TYPE_HSPAP = 0x0000000f;	
	
	private static final int NETWORK_TYPE_EHRPD = 0x0000000e;// ~ 1-2 Mbps
	private static final int NETWORK_TYPE_EVDO_B = 0x0000000c;// ~ 5 Mbps
	
	public static String getLocalIpAddress() {

		try {
			for (Enumeration<NetworkInterface> en = NetworkInterface
					.getNetworkInterfaces(); en.hasMoreElements();) {
				NetworkInterface intf = en.nextElement();
				for (Enumeration<InetAddress> enumIpAddr = intf
						.getInetAddresses(); enumIpAddr.hasMoreElements();) {
					InetAddress inetAddress = enumIpAddr.nextElement();
					if (!inetAddress.isLoopbackAddress()) {
						return inetAddress.getHostAddress().toString()
								.replace('.', '_');
					}
				}
			}
		} catch (SocketException ex) {
			Log.d("TAG", ex.toString());
		}
		return "unknown_ip";
	}

	/**
	 * 获取应用版本号
	 * 
	 * @param ctx
	 * @return
	 */
	public static String getSoftwareVersion(Context ctx) {
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

	/**
	 * 
	 * @param ctx
	 * @return
	 */
	public static String getUserAgent(Context ctx) {
		// 按统计组的要求将空格转换为_
		return android.os.Build.MODEL.replaceAll(" ", "_").toLowerCase();// + "_" + android.os.Build.VERSION.RELEASE;
	}
	

	/**
	 * 设备的型号
	 * @return
	 */
	public static String getPhoneModel(){
		return android.os.Build.MODEL ;
	}

	/**
	 * android_${VERSION.SDK_INT}
	 * 
	 * @return
	 */
	public static String getPlatform() {
	  String version = AndroidVersionComparisonTable.getInstante().getAndroidVersion();
	  if (null == version) 
	    return "android_" + android.os.Build.VERSION.RELEASE;
      else 
        return "android_" + version;
	}
	
	/**
	 * replace 'android_' part of {@link Utils#getPlatform()} using given prefix string
	 * 
	 * @param prefix the customized string 
	 * @return the platform
	 */
	public static String getPlatform(String prefix) {
		return prefix + android.os.Build.VERSION.SDK;
	}

	/**
	 * 获取IMEI，算法如下：
	 * 1。 通过TelephonyManager.getDeviceId()获取唯一标识，若果唯一标示为空或长度小于8（如：#， 0， 1， null, Unknown等）
	 * 		，或为一些已知的会重复的号码则继续往下，否则返回唯一号。特殊号码包括：
	 * 		00000000
	 * 		00000000000000
	 *  	000000000000000
	 *   	111111111111111
	 *     	004999010640000
	 *    	352751019523267
	 *   	353867052181927
	 *   	358673013795895
	 *   	353163056681595
	 *   	352273017386340
	 *   	353627055437761
	 *   	351869058577423
	 *   	
	 * 2. 通过WifiManager.getConnectionInfo().getMacAddress()取MAC地址作为唯一标识，若取得的是一些已知的会重复地址
	 * 		则继续往下，否则返回MAC作为唯一号。特殊地址包括：00:00:00:00:00:00
	 * 3. 通过生成随机UUID作为唯一标识
	 * 
	 * @param ctx
	 * @return
	 */
	public static String getIMEI(Context ctx) {
		String imei = null;
		TelephonyManager telephonyManager = (TelephonyManager) ctx
				.getSystemService(Context.TELEPHONY_SERVICE);
		WifiManager wifiManager = (WifiManager) ctx.getSystemService(Context.WIFI_SERVICE);
		if (null != telephonyManager) {
			imei = telephonyManager.getDeviceId();
		}
		
		// get mac adress in case getDeviceId failed or get invalid id
		if (TextUtils.isEmpty(imei)
				|| imei.length() < 8
				|| isStringWithSameChar(imei)
				|| "004999010640000".equals(imei)
				|| "352751019523267".equals(imei)
				|| "353867052181927".equals(imei)
				|| "358673013795895".equals(imei)
				|| "353163056681595".equals(imei)
				|| "352273017386340".equals(imei)
				|| "353627055437761".equals(imei)
				|| "351869058577423".equals(imei)
				) {
			if (null != wifiManager) {
				imei = wifiManager.getConnectionInfo().getMacAddress();
				if (TextUtils.isEmpty(imei)
						|| !isValidMacAddress(imei)
						|| "00:00:00:00:00:00".equals(imei)) {
					// generate random UUID
					imei = getUUID(ctx.getSharedPreferences("uuid", Context.MODE_PRIVATE));
				}
			} else {
				// generate random UUID
				imei = getUUID(ctx.getSharedPreferences("uuid", Context.MODE_PRIVATE));
			}
			
//			String key = "device_uuid";
//			SharedPreferences sharedPreferences = ctx.getSharedPreferences("uuid", Context.MODE_PRIVATE);
//			String uuid = sharedPreferences.getString(key, null);
//			if (uuid == null) {
//				if (!TextUtils.isEmpty(mac) && isValidMacAddress(mac)) {
//					uuid = new UUID(mac.hashCode(), UUID.randomUUID().hashCode()).toString();
//				} else {
//					uuid = UUID.randomUUID().toString();
//				}
//				sharedPreferences.edit().putString(key, uuid).commit();
//			}
//			return uuid;
		}

		return imei;
	}
	
	/**
	 * 判断字符串是否由相同的字符组成，比如“000000000000000”
	 * @param str
	 * @return
	 */
	public static boolean isStringWithSameChar(String str) {
		if (null == str || str.length() < 2) {
			return true;
		}
		return str.replace(str.substring(0,1), "").length() == 0;
	}
	
	/**
	 * 判断传入的字符串是否为有效地MAC地址，如00:01:36:D5:E0:D2 或 00-01-36-D5-E0-D2
	 * @param str
	 * @return
	 */
	public static boolean isValidMacAddress(String str) {
		return null!=str && str.matches("([\\da-fA-F]{2}(?:\\:|-|$)){6}");
	}
	
	/**
	 * 针对三无手机的userkey获取
	 * @param ctx
	 * @return
	 */
	public static String getSpecialUserkey(Context ctx) {
		String imei = null;
		WifiManager wifiManager = (WifiManager) ctx.getSystemService(Context.WIFI_SERVICE);
		if (wifiManager != null)
			imei = wifiManager.getConnectionInfo().getMacAddress();
		if(TextUtils.isEmpty(imei)||!isValidMacAddress(imei)||"00:00:00:00:00:00".equals(imei)){
			imei = getUUID(ctx.getSharedPreferences("uuid", Context.MODE_PRIVATE));
		}
		return imei;
	}
	
	/**
	 * 取mac地址
	 * 不到，默认“0”
	 * @return
	 */
	public static String getMacAddress(Context ctx){
		String mac = "0";
		WifiManager wifiManager = (WifiManager) ctx.getSystemService(Context.WIFI_SERVICE);
		if (wifiManager != null)
			mac = wifiManager.getConnectionInfo().getMacAddress();
		if(null != mac)
			mac = mac.replace(":", "");
		return mac;
	}
	
	/**
	 * @gm, retrive or generate a device uuid if IMEI is not available， e.g. 9a6c33a4-96b0-46b3-aead-e6e62b1a043e
	 * @param sharedPreferences SharedPreferences which stores the value
	 * @return The UUID for this device
	 */
	public static String getUUID(SharedPreferences sharedPreferences) {
		String key = "device_uuid";
		String uuid = sharedPreferences.getString(key, null);
		if (TextUtils.isEmpty(uuid)) {
			uuid = UUID.randomUUID().toString();
			sharedPreferences.edit().putString(key, uuid).commit();
		}
//		if (uuid == null) return "000000";
		return uuid;
	}

	/**
	 * 第一次使用时间
	 * @return
	 */
	public static String getFirstLoginTime(Context context){
		try {
			SharedPreferences loginShare = context.getSharedPreferences("FirstLogin", Context.MODE_PRIVATE);
			String time = loginShare.getString("firstLoginTime", null);
			if(TextUtils.isEmpty(time)){
				time = String.valueOf(System.currentTimeMillis()/1000);
				Editor editor = loginShare.edit();
				editor.putString("firstLoginTime", time);
				editor.commit();
			}
			return time;
		} catch (Exception e) {
		}
		return "";
	}
	/**
	 * 获取屏幕描述
	 * 
	 * @return
	 */
	public static String getScreenDescription(Context context) {
		DisplayMetrics metrics = context.getResources().getDisplayMetrics();
		return metrics.widthPixels + "x" + metrics.heightPixels;
	}

	/**
	 * 获取网络类型,默认WIFI
	 * 
	 * @param ctx
	 * @return
	 */
	public static String getNetType(Context ctx) {
		// 按统计要求，所有网络制式标识用小写字母
		PhoneManager phoneManager=PhoneManager.getInstance(ctx);
		if(phoneManager.isConnectedWifi()){
			return "wifi";
		}
		else if(phoneManager.isConnectedMobileNet()){
			String nettype = "unknown";
			TelephonyManager manager=(TelephonyManager) ctx.getSystemService(Context.TELEPHONY_SERVICE);
			int type=manager.getNetworkType();
			Log.d("TAG", "NetworkType "+type);
			switch (type) {
			case TelephonyManager.NETWORK_TYPE_UNKNOWN:
				nettype="unknown";
				break;
			//修改网络制式：以下归类为2G网络
			case TelephonyManager.NETWORK_TYPE_1xRTT:
				//移动2G
			case TelephonyManager.NETWORK_TYPE_GPRS:
				//联通2G
			case TelephonyManager.NETWORK_TYPE_EDGE:
				//电信2G
			case TelephonyManager.NETWORK_TYPE_CDMA:
				
			case TelephonyManager.NETWORK_TYPE_IDEN:// ~25 kbps
				nettype="2g";
				break;
			//修改网络制式：以下归类为3G网络
				//联通3G
			case TelephonyManager.NETWORK_TYPE_UMTS:
				//联通3G
			case TelephonyManager.NETWORK_TYPE_HSDPA:
			case TelephonyManager.NETWORK_TYPE_HSUPA:
			case TelephonyManager.NETWORK_TYPE_HSPA:
				//联通3G 网络类型，由于TelephonyManager.NETWORK_TYPE_HSPAP 最低的api要求 lever 为11
			case NETWORK_TYPE_HSPAP:
				//电信3G
			case TelephonyManager.NETWORK_TYPE_EVDO_0:
			case TelephonyManager.NETWORK_TYPE_EVDO_A:
				
			case NETWORK_TYPE_EHRPD: // ~ 1-2 Mbps
			case NETWORK_TYPE_EVDO_B:// ~ 5 Mbps
				nettype="3g";
				break;
			//LTE 网络类型，由于TelephonyManager.NETWORK_TYPE_LTE 最低的api要求 lever 为11
			case NETWORK_TYPE_LTE:
				nettype="lte";
				break;
				//				case TelephonyManager.NETWORK_TYPE_EVDO_B:
				//				nettype="NETWORK_TYPE_EVDO_B";
				//				break;
				//			case TelephonyManager.NETWORK_TYPE_1xRTT:
				//				nettype="NETWORK_TYPE_1xRTT";
				//				break;
				//				case TelephonyManager.NETWORK_TYPE_IDEN:
				//				nettype="NETWORK_TYPE_IDEN";
				//				break;
				//				case TelephonyManager.NETWORK_TYPE_LTE:
				//				nettype="NETWORK_TYPE_LTE";
				//				break;
				//				case TelephonyManager.NETWORK_TYPE_EHRPD:
				//				nettype="NETWORK_TYPE_EHRPD";
				//				break;
				//				case TelephonyManager.NETWORK_TYPE_HSPAP:
				//				nettype="NETWORK_TYPE_HSPAP";
				//				break;
			default :
				Log.d("TAG", "NetworkType default type="+type);
				nettype="unknown";
				break;
			}
			return nettype;
		}else {
			return "offline";
		}

	}
	
	/**
	 * 返回具体的网络类型，不是分类的2g、3g等，用于在线日志中，以便能更好地发现问题、重现问题
	 * 
	 * @param ctx
	 * @return
	 */
	public static String getDetailedNetType(Context ctx) {
		PhoneManager phoneManager=PhoneManager.getInstance(ctx);
		if(phoneManager.isConnectedWifi()){
			return "WIFI";
		}
		else if(phoneManager.isConnectedMobileNet()){
			String nettype = "UNKNOWN";
			TelephonyManager manager=(TelephonyManager) ctx.getSystemService(Context.TELEPHONY_SERVICE);
			int type=manager.getNetworkType();
			Log.d("TAG", "NetworkType "+type);
			switch (type) {
			case TelephonyManager.NETWORK_TYPE_UNKNOWN:
				nettype="UNKNOWN";
				break;
			//修改网络制式：以下归类为2G网络
			case TelephonyManager.NETWORK_TYPE_1xRTT:
				nettype="1xRTT";
				break;
				//移动2G
			case TelephonyManager.NETWORK_TYPE_GPRS:
				nettype="GPRS";
				break;
				//联通2G
			case TelephonyManager.NETWORK_TYPE_EDGE:
				nettype="EDGE";
				break;
				//电信2G
			case TelephonyManager.NETWORK_TYPE_CDMA:
				nettype="CDMA";
				break;
				
			case TelephonyManager.NETWORK_TYPE_IDEN:// ~25 kbps
				nettype="IDEN";
				break;
			//修改网络制式：以下归类为3G网络
				//联通3G
			case TelephonyManager.NETWORK_TYPE_UMTS:
				nettype="UMTS";
				break;
				//联通3G
			case TelephonyManager.NETWORK_TYPE_HSDPA:
				nettype="HSDPA";
				break;
			case TelephonyManager.NETWORK_TYPE_HSUPA:
				nettype="HSUPA";
				break;
			case TelephonyManager.NETWORK_TYPE_HSPA:
				nettype="HSPA";
				break;
				//联通3G 网络类型，由于TelephonyManager.NETWORK_TYPE_HSPAP 最低的api要求 lever 为11
			case NETWORK_TYPE_HSPAP:
				nettype="HSPAP";
				break;
				//电信3G
			case TelephonyManager.NETWORK_TYPE_EVDO_0:
				nettype="EVDO_0";
				break;
			case TelephonyManager.NETWORK_TYPE_EVDO_A:
				nettype="EVDO_A";
				break;
			case NETWORK_TYPE_EHRPD: // ~ 1-2 Mbps
				nettype="EHRPD";
				break;
			case NETWORK_TYPE_EVDO_B:// ~ 5 Mbps
				nettype="EVDO_B";
				break;
			//LTE 网络类型，由于TelephonyManager.NETWORK_TYPE_LTE 最低的api要求 lever 为11
			case NETWORK_TYPE_LTE:
				nettype="LTE";
				break;
				//				case TelephonyManager.NETWORK_TYPE_EVDO_B:
				//				nettype="NETWORK_TYPE_EVDO_B";
				//				break;
				//			case TelephonyManager.NETWORK_TYPE_1xRTT:
				//				nettype="NETWORK_TYPE_1xRTT";
				//				break;
				//				case TelephonyManager.NETWORK_TYPE_IDEN:
				//				nettype="NETWORK_TYPE_IDEN";
				//				break;
				//				case TelephonyManager.NETWORK_TYPE_LTE:
				//				nettype="NETWORK_TYPE_LTE";
				//				break;
				//				case TelephonyManager.NETWORK_TYPE_EHRPD:
				//				nettype="NETWORK_TYPE_EHRPD";
				//				break;
				//				case TelephonyManager.NETWORK_TYPE_HSPAP:
				//				nettype="NETWORK_TYPE_HSPAP";
				//				break;
			default :
				nettype="UNKNOWN";
				break;
			}
			return nettype;
		}else {
			return "OFFLINE";
		}

	}
	
	public static boolean hasGingerbread() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD;
    }

    public static boolean hasHoneycomb() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB;
    }
    
    public static boolean hasHoneycombMR1() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR1;
    }

    public static boolean hasJellyBean() {
        return Build.VERSION.SDK_INT >= 16;//Build.VERSION_CODES.JELLY_BEAN;
    }

    public static boolean hasKitKat() {
        return Build.VERSION.SDK_INT >= 19;//Build.VERSION_CODES.KITKAT;
    }
}
