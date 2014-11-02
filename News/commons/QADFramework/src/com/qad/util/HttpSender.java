package com.qad.util;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URLEncodedUtils;

import android.text.TextUtils;
import android.util.Log;

import com.qad.net.HttpManager;

public class HttpSender implements Sender {

	private String encodeType = "UTF-8";
	private RequestMethod method = RequestMethod.GET;

	public static enum RequestMethod {
		GET, POST
	}

	public void setEncode(String encode) {
		this.encodeType = encode;
	}

	public void setMethod(RequestMethod method) {
		this.method = method;
	}
	
	public RequestMethod getMethod() {
		return method;
	}
	
	@Override
	public void send(String url) throws IOException {
		if (TextUtils.isEmpty(url)) {
			return;
		}
//		Log.i("Sdebug", "HttpSender send: " + url);
		if (method == RequestMethod.GET)
			sendGet(url);
		else if (method == RequestMethod.POST)
			sendPost(url);
	}

	@Override
	public void send(String url, String content) throws IOException {
		if (url == null)
			return;
		if (content != null && content.trim().length() != 0) {
			if (url.indexOf('?') == -1) {
				url += "?" + content;
			} else {
				url += "&" + content;
			}
		}
//		Log.i("Sdebug", "HttpSender send: " + url);
		if (method == RequestMethod.GET)
			sendGet(url);
		else if (method == RequestMethod.POST)
			sendPost(url);
	}

	private void sendPost(String url) throws IOException {
		String hostUrl = "";
		if (url.indexOf('?') == -1)
			hostUrl = url;
		else {
			hostUrl = url.substring(0, url.indexOf('?'));
		}
		HttpPost post = new HttpPost(hostUrl);
		post.setEntity(new UrlEncodedFormEntity(URLEncodedUtils.parse(
				URI.create(url), encodeType)));
		HttpManager.executeHttpPost(post);
	}

	private void sendGet(String urlStr) throws IOException {
//		urlStr = encode(urlStr);
		try {
            new URI(urlStr);
        } catch (Exception e) { 
            //URISyntaxException and IllegalArgumentException
            // 检测url是否是有效的地址，如果不是直接返回
            Log.e("HttpSender", "Illegal url string: " + urlStr, e);
            return;
        }
		HttpManager.executeHttpGet(urlStr);
	}

	private static Pattern valuePattern = Pattern.compile("(.+?)=(.+?)(&|\\z)");

	private String encode(String s) {
		Matcher matcher = valuePattern.matcher(s);
		StringBuffer buffer = new StringBuffer(s.length());
		while (matcher.find()) {
			try {
				buffer.append(matcher.group(1))
						.append("=")
						.append(URLEncoder.encode(matcher.group(2), encodeType))
						.append(matcher.group(3));
			} catch (Exception e) {
				e.printStackTrace();
				matcher.appendReplacement(buffer, matcher.group());
			}
		}
//		matcher.appendTail(buffer);
		return buffer.toString();
	}
}
