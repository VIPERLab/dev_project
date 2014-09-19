/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.business;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import android.text.TextUtils;
import android.util.Xml;
import android.widget.Toast;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.UserHomeData;
import cn.kuwo.sing.util.DefaultAsyncHttpResponseHandler;
import cn.kuwo.sing.util.UserHomeDataResponseHandler;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.RequestParams;

/**
 * @Package cn.kuwo.sing.business
 *
 * @Date 2013-12-24, 下午5:18:56
 *
 * @Author wangming
 *
 */
public class UserHomeBusiness {
	private static final String HTTP_URL_MY_HOME = "http://changba.kuwo.cn/kge/mobile/User";
//	private static final String HTTP_URL_DELETE_KGE = "http://changba.kuwo.cn/kge/mobile/DelKge";
	private static final String HTTP_URL_DELETE_KGE = "http://60.28.200.79/kge/mobile/DelKge";
	private static final String HTTP_URL_ATTENTATION = "http://changba.kuwo.cn/kge/mobile/userAction";
	
	private static UserHomeData parseUserHomeData(String content) {
		UserHomeData data = null;
		List<Kge> kgeList = null;
		Kge kge = null;
		if(TextUtils.isEmpty(content))
			return null;
		try {
			InputStream is = new ByteArrayInputStream(content.getBytes());
			XmlPullParser parser = Xml.newPullParser();
			parser.setInput(is, "UTF-8");
			int eventType = parser.getEventType();
			while(eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:
					data = new UserHomeData();
					break;
				case XmlPullParser.START_TAG:
					String tag = parser.getName();
					if(tag.equalsIgnoreCase("uid")) {
						data.uid = parser.nextText();
					}else if(tag.equalsIgnoreCase("uname")) {
						data.uname = parser.nextText();
					}else if(tag.equalsIgnoreCase("birth_city")) {
						data.birth_city = parser.nextText();
					}else if(tag.equalsIgnoreCase("resident_city")) {
						data.resident_city = parser.nextText();
					}else if(tag.equalsIgnoreCase("age")) {
						data.age = parser.nextText();
					}else if(tag.equalsIgnoreCase("fans")) {
						data.fans = Integer.parseInt(parser.nextText());
					}else if(tag.equalsIgnoreCase("fav")) {
						data.fav = Integer.parseInt(parser.nextText());
					}else if(tag.equalsIgnoreCase("hascare")) {
						data.hascare = Integer.parseInt(parser.nextText());
					}else if(tag.equalsIgnoreCase("total_pn")) {
						data.total_pn = Integer.parseInt(parser.nextText());
					}else if(tag.equalsIgnoreCase("userpic")) {
						data.userpic = parser.nextText();
					}else if(tag.equalsIgnoreCase("kge_list")) {
						kgeList = new ArrayList<Kge>();
					}else if(tag.equalsIgnoreCase("kge")) {
						kge = new Kge();
					}else if(tag.equalsIgnoreCase("id")) {
						kge.id = parser.nextText();
					}else if(tag.equalsIgnoreCase("title")) {
						kge.title = parser.nextText();;
					}else if(tag.equalsIgnoreCase("time")) {
						kge.time = parser.nextText();
					}else if(tag.equalsIgnoreCase("view")) {
						kge.view = Integer.parseInt(parser.nextText());
					}else if(tag.equalsIgnoreCase("comment")) {
						kge.comment = Integer.parseInt(parser.nextText());
					}else if(tag.equalsIgnoreCase("flower")) {
						kge.flower = Integer.parseInt(parser.nextText());
					}else if(tag.equalsIgnoreCase("src")) {
						kge.src = parser.nextText();
					}else if(tag.equalsIgnoreCase("sid")) {
						kge.sid = Integer.parseInt(parser.nextText());
					}
					break;
				case XmlPullParser.END_TAG:
					String endTag = parser.getName();
					if(endTag.equalsIgnoreCase("kge")) {
						kgeList.add(kge);
						kge = null;
					}else if(endTag.equalsIgnoreCase("kge_list")) {
						data.kgeList = kgeList;
					}
					break;

				default:
					break;
				}
				eventType = parser.next();
			}
			is.close();
		} catch (XmlPullParserException e) {
			e.printStackTrace();
		    data = null;
		} catch (IOException e) {
			e.printStackTrace();
			data = null;
		}
		
		return data;
	}
	
	private static UserHomeData parseUserHomeCommonData(String content) {
		UserHomeData data = new UserHomeData();
		if(content == null)
			data = null;
		Map<String, String> entryMap = new HashMap<String, String>();
		String[] params = content.split("&");
		for(String param : params) {
			String[] entry = param.split("="); 
			entryMap.put(entry[0], entry[1]);
		}
		data.result = entryMap.get("result");
		return data;
	}
	
	public static void attentationUser(String fid, String tid, String sid, String act, final UserHomeDataResponseHandler handler) {
		AsyncHttpClient client = new AsyncHttpClient();
		RequestParams params = new RequestParams();
		params.put("fid", fid);
		params.put("tid", tid);
		params.put("sid", sid);
		params.put("type", "care");
		params.put("act", act);
		client.get(HTTP_URL_ATTENTATION, params, new DefaultAsyncHttpResponseHandler(handler) {

			@Override
			public void onSuccess(String content) {
				super.onSuccess(content);
				KuwoLog.e("business data :", content);
				UserHomeData data = parseUserHomeCommonData(content);
				if(data != null)
					handler.onSuccess(data);
			}

			@Override
			public void onFailure(Throwable error, String content) {
				super.onFailure(error, content);
				String errorStr = "org.apache.http.conn.ConnectTimeoutException";
				KuwoLog.e("business  error:", errorStr);
				handler.onFailure(errorStr);
			}
		});
	}
	
	//http://60.28.200.79/kge/mobile/DelKge?kid="+rid+"&"+userids+"&uid="+userinfo.uid+"&_="+gettime();
	public static void deleteUserKge(String kid, String uid, String loginId, String sid, final UserHomeDataResponseHandler handler) {
		AsyncHttpClient client = new AsyncHttpClient();
		RequestParams params = new RequestParams();
		params.put("kid", kid);
		params.put("uid", uid);
		params.put("loginid", loginId);
		params.put("sid", sid);
		params.put("_", System.currentTimeMillis()+"");
		client.get(HTTP_URL_DELETE_KGE, params, new DefaultAsyncHttpResponseHandler(handler) {

			@Override
			public void onSuccess(String content) {
				super.onSuccess(content);
				KuwoLog.e("business data :", content);
				UserHomeData data = parseUserHomeCommonData(content);
				if(data != null)
					handler.onSuccess(data);
			}

			@Override
			public void onFailure(Throwable error, String content) {
				super.onFailure(error, content);
				String errorStr = "org.apache.http.conn.ConnectTimeoutException";
				KuwoLog.e("business  error:", errorStr);
				handler.onFailure(errorStr);
			}
		});
	}
	public static void getUserHomeDataByGet(String id, String loginId, String sid, final UserHomeDataResponseHandler handler) {
		AsyncHttpClient client = new AsyncHttpClient();
		RequestParams params = new RequestParams();
		params.put("id", id);
		params.put("loginid", loginId);
		params.put("sid", sid);
		client.get(HTTP_URL_MY_HOME, params, new DefaultAsyncHttpResponseHandler(handler) {

			@Override
			public void onSuccess(String content) {
				super.onSuccess(content);
				KuwoLog.e("business data :", content);
				UserHomeData data = parseUserHomeData(content);
				if(data != null)
					handler.onSuccess(data);
			}

			@Override
			public void onFailure(Throwable error, String content) {
				super.onFailure(error, content);
				String errorStr = "";
				KuwoLog.e("business  error:", errorStr);
				handler.onFailure(errorStr);
			}
		});
	}
	
	
	public static void getUserHomeSongListByPost(String id, String loginId, String sid, int pageNumber, int pageSize, final UserHomeDataResponseHandler handler) {
		AsyncHttpClient client = new AsyncHttpClient();
		RequestParams params = new RequestParams();
		params.put("id", id);
		params.put("loginid", loginId);
		params.put("sid", sid);
		params.put("pn", String.valueOf(pageNumber));
		params.put("ps", String.valueOf(pageSize));
		client.post(HTTP_URL_MY_HOME, params, new DefaultAsyncHttpResponseHandler(handler) {

			@Override
			public void onSuccess(String content) {
				super.onSuccess(content);
				KuwoLog.e("business data :", content);
				UserHomeData data = parseUserHomeData(content);
				if(data != null)
					handler.onSuccess(data);
			}

			@Override
			public void onFailure(Throwable error, String content) {
				super.onFailure(error, content);
				KuwoLog.e("business data :", content);
			}
		});
	}
}
