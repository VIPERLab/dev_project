package com.ifeng.news2.exception;



import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.MalformedURLException;
import java.net.Proxy;
import java.net.URL;

/**
 * 基础的HTTP连接类
 * 
 * @author: liuxin
 * @version: v1.0.0
 * @since: 2012-2-28
 */
public class MyHttpClient {

	private static final int CONNECTION_TIMEOUT = 10 * 1000;
	private static final int NET_DOWN_TIME = 10 * 1000;
	private static final int RETRY = 2;
	private static final int OK = 200;// OK: Success!
	private NetAttribute attr;
	private IMessageSender warnSender;
	private String url;
	public MyHttpClient(NetAttribute attr, IMessageSender warn) {
		this.attr = attr;
		this.warnSender = warn;
	}

	public MyHttpClient(NetAttribute attr) {
		this.attr = attr;
	}

	public MyHttpClient() {

	}

	public boolean doHttpGet(String url, IHandleHttpData dataHandler) {
		HttpURLConnection urlConnection = null;
		this.url = url;
		for (int retryCount = 0; retryCount <= RETRY; retryCount++) {
			try {
				urlConnection = getConnection(url);
				initURLConnection(urlConnection);
				if (urlConnection.getResponseCode() == OK) {
					dataHandler.handleHttpData(urlConnection);
					return true;
				}
			} catch (IOException e) {
				if (retryCount >= RETRY) {
					if (warnSender != null)
						warnSender.sendMessage(IMessageSender.REQUES_TIMEOUT_TOAST, null);
			
				} else{
					continue;
				}
			} catch (Exception e) {
				return false;
			} finally {
				if (urlConnection != null)
					urlConnection.disconnect();
			}
		}
		return false;
	}

	public boolean doHttpPost(String url, IHandleHttpData dataHandler) {
		HttpURLConnection urlConnection = null;
		this.url = url;
		for (int retryCount = 0; retryCount <= RETRY; retryCount++) {
			try {
				urlConnection = getConnection(url);
				initURLConnection(urlConnection);
				urlConnection.setRequestMethod("POST");
				urlConnection.setRequestProperty("Content-Type","application/x-www-form-urlencoded");
				urlConnection.setDoOutput(true);
				dataHandler.handleHttpData(urlConnection);
				int code = urlConnection.getResponseCode();
				if (code == OK) {
					return true;
				} 
			} catch (Exception e) {
			} finally {
				if (urlConnection != null)
					urlConnection.disconnect();
			}
		}
		return false;
	}
	private void initURLConnection(HttpURLConnection conn) {
		conn.setConnectTimeout(CONNECTION_TIMEOUT);
		conn.setReadTimeout(NET_DOWN_TIME);
		conn.setDoInput(true);
	}

	private HttpURLConnection getConnection(String url)
			throws MalformedURLException, IOException {
		HttpURLConnection conn = null;
		this.url = url;
		if (attr.isUseProxy()) {
			Proxy proxy = new Proxy(java.net.Proxy.Type.HTTP,
					new InetSocketAddress(attr.getProxyServer(),
							attr.getProxyPort()));
			conn = (HttpURLConnection) (new URL(url)).openConnection();
		} else {
			conn = (HttpURLConnection) (new URL(url)).openConnection();
		}
		return conn;
	}

	public String getConnUrl() {
		return url;
	}

}
