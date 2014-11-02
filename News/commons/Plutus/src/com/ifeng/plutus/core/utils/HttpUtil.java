package com.ifeng.plutus.core.utils;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;

import android.util.Log;

import com.ifeng.plutus.core.PlutusCoreManager;
import com.qad.net.HttpManager;

public class HttpUtil {

	/**
	 * Load the given url and return the byte array readed
	 * @param url The url to load
	 * @return Byte array data readed from the stream
	 * @throws IOException 
	 * @throws  
	 * @throws Exception 
	 */
	public static String get(String url) throws Exception {
//		HttpClient httpClient = new DefaultHttpClient();
		String responseData = null;
//		Log.e("Sdebug", "Plutus.HttpUtil.get  url=" + url);
//		httpClient.getParams().setParameter("http.socket.timeout", PlutusCoreManager.getTimeOut() * 1000);
		try {
			responseData = HttpManager.getHttpText(url);
			return responseData;
		} catch(Exception e) {
			e.printStackTrace();
		} 
		return null;
	}
	
	public static boolean post(String url, Map<String, String> content) throws Exception {
		HttpClient httpClient = new DefaultHttpClient();
		HttpPost httpPost = new HttpPost(url);
		httpClient.getParams().setParameter("http.socket.timeout", PlutusCoreManager.getTimeOut() * 1000);
		
		Iterator<String> it = content.keySet().iterator();
		String key = null;
		List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(content.size());
		while (it.hasNext()) {
			key = it.next();
			nameValuePairs.add(new BasicNameValuePair(key, content.get(key)));
		}
		httpPost.setEntity(new UrlEncodedFormEntity(nameValuePairs));

		try {
			HttpResponse response = httpClient.execute(httpPost);
			if (response.getStatusLine().getStatusCode() == 200)
				return true;
		} finally {
			httpClient.getConnectionManager().shutdown();
		}
		return false;
	}
}
