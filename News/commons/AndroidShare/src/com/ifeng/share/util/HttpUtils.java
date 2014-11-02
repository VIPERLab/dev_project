package com.ifeng.share.util;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.MalformedURLException;
import java.net.Proxy;
import java.net.URL;

import org.apache.http.client.ClientProtocolException;

public class HttpUtils {
	public static final int NET_DOWN_TIME = 3 * 1000;
	private final static int CONNECTION_TIMEOUT = 3 * 1000;
	public final static String USER_AGENT = "IFENG_Android_Share";
	public static InputStream getInputStream(String url)
			throws ClientProtocolException, IOException {
		try {
			HttpURLConnection httpURLConnection = getHttpURLConnection(url);
			InputStream inputStream = httpURLConnection.getInputStream();
			return inputStream;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	public static byte[] readInputStream(InputStream inStream) throws Exception{
		ByteArrayOutputStream outSteam = new ByteArrayOutputStream();
		byte[] buffer = new byte[1024];
		int len = 0;
		while( (len = inStream.read(buffer)) !=-1 ){
			outSteam.write(buffer, 0, len);
		}
		outSteam.close();
		inStream.close();
		return outSteam.toByteArray();
	}
	public static String getTextByUrl(String url){
		try {
			InputStream inputStream = getInputStream(url);
			return readInputStream(inputStream).toString();
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	public static String getTextByInputStream(InputStream inputStream){
		try {
			return readInputStream(inputStream).toString();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
	public static HttpURLConnection getHttpURLConnection(String url)
			throws MalformedURLException, IOException {
		URL httpUrl = new URL(url);
		HttpURLConnection connection = null;
		// fix bug #16028  三星Note 1在WIFI下这里也会得到保持的运营商代理信息如：host=10.0.0.172, port=80.
		// 删除这里代理设置，使用系统范围内代理设置
//		String host = android.net.Proxy.getDefaultHost();
//		int port = android.net.Proxy.getDefaultPort();
//		System.err.println("host="+host+", port="+port);
//		if (host != null && port != -1) {
//			Proxy proxy = new Proxy(java.net.Proxy.Type.HTTP,
//					new InetSocketAddress(host, port));
//			connection = (HttpURLConnection) httpUrl.openConnection(proxy);
//		}else {
			connection = (HttpURLConnection) httpUrl.openConnection();
//		}
		if (connection != null) {
			connection.setConnectTimeout(CONNECTION_TIMEOUT);
			connection.setReadTimeout(NET_DOWN_TIME);
			connection.setDoInput(true);
			connection.setUseCaches(false);
			connection.setRequestMethod("GET");
			connection.connect();
		}
		return connection;
	}
}
