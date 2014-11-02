package com.ifeng.news2.plutus.core.utils;

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

import com.ifeng.news2.plutus.core.PlutusCoreManager;
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
	public static byte[] get(String url) throws Exception {
//		HttpClient httpClient = new DefaultHttpClient();
		HttpClient httpClient = HttpManager.getHttpClient();
//		Log.e("Sdebug", "Plutus.HttpUtil.get  url=" + url);
		HttpGet httpGet = new HttpGet(url);
//		httpClient.getParams().setParameter("http.socket.timeout", PlutusCoreManager.getTimeOut() * 1000);
		 ResponseHandler<byte[]> responseHandler = new ResponseHandler<byte[]>() {

			@Override
			public byte[] handleResponse(HttpResponse response) 
					throws ClientProtocolException, IOException {
				InputStream is = response.getEntity().getContent();
				ByteArrayOutputStream os = new ByteArrayOutputStream();
				byte[] buffer = new byte[2048];
				int count = -1;
				try {
					while ((count = is.read(buffer)) != -1) {
						os.write(buffer, 0, count);
						os.flush();
					}
					return os.toByteArray();
				} finally {
					if (os != null)
						os.close();
				}
			}
		};
		try {
			byte[] responseData = httpClient.execute(httpGet, responseHandler);
			return responseData;
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			httpClient.getConnectionManager().shutdown();
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
