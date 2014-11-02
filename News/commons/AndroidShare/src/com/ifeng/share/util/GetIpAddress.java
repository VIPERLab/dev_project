package com.ifeng.share.util;

import java.io.UnsupportedEncodingException;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.URLEncoder;
import java.util.Enumeration;

import android.util.Log;

public class GetIpAddress {
	
	/**
	 * 当无法得到IP地址时返回该结果
	 */
	public static String UNKNOWN_IP="unknown_ip";

	private static String getLocalIpAddress() {

		try {
			for (Enumeration<NetworkInterface> en = NetworkInterface
					.getNetworkInterfaces(); en.hasMoreElements();) {
				NetworkInterface intf = en.nextElement();
				for (Enumeration<InetAddress> enumIpAddr = intf
						.getInetAddresses(); enumIpAddr.hasMoreElements();) {
					InetAddress inetAddress = enumIpAddr.nextElement();
					if (!inetAddress.isLoopbackAddress()) {
						return inetAddress.getHostAddress().toString();
					}
				}
			}
		} catch (SocketException ex) {
			Log.d("TAG", ex.toString());
		}
		return UNKNOWN_IP;

	}
	 public static String getLocalIp(){
	    	String ip = GetIpAddress.getLocalIpAddress();
	    	if(ip!=null)
				try {
					ip=URLEncoder.encode(ip,"utf8");
				} catch (UnsupportedEncodingException e) {
					e.printStackTrace();
				}
	    	return GetIpAddress.UNKNOWN_IP;
	    }
}
