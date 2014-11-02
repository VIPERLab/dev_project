package com.ifeng.news2.exception;



import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.ifeng.news2.Config;
import com.ifeng.news2.util.ParamsManager;

/**
 * 崩溃日志发送类
 * @author: liuxin
 * @version: v1.0.0
 * @since: 2012-9-10
 */
public class ExceptionReport {
	public static final String SHAREDPREFERENCES_NAME = "mSharedPreferences";
	private static final String REPORT_SEPARATE = "#";
	private static final String DATA_SEPARATE = "&";

	private static final String UA = "PHONE_MODE"; // 设备型号 同统计ua
	private static final String USERKEY = "DEVICE_ID"; // DEVICE_ID 设备ID
														// 同统计userkey
	private static final String MOS = "ANDROID_VERSION";// ANDROID_VERSION
														// 系统版本 同统计mos
	private static final String DATE = "USER_CRASH_DATA";// USER_CRASH_DATA
															// 崩溃时间
															// 2012-03-07
															// 14:11:31
	private static final String STACK_TRACE = "STACK_TRACE";// STACK_TRACE
															// 崩溃堆栈信息
	private static final String SOFT_VERSION = "APP_VERSION_NAME";// APP_VERSION_NAME
																	// 产品版本
																	// 同统计softversion
	private static final String NET = "NET";// NET 网络 同统计net
	private static final String PUBLISH_ID = "PUBLISH_ID";// PUBLISH_ID 渠道
															// 同统计publishid

	private String data = "";
	private Context context;

	public ExceptionReport(Context appcontext, String ua, String userKey,
			String mos, String stack_trace, String softVersion, String net,
			String publishID) {
		this.context = appcontext;
		StringBuffer buffer = new StringBuffer();
		buffer.append("data=");
		buffer.append(UA + "=" + ua);
		buffer.append(DATA_SEPARATE + USERKEY + "=" + userKey);
		buffer.append(DATA_SEPARATE + MOS + "=" + mos);
		buffer.append(DATA_SEPARATE + DATE + "=" + (new SimpleDateFormat("yyyy-MM-dd hh:mm:SS").format(new Date()).toString()));
		buffer.append(DATA_SEPARATE + STACK_TRACE + "=" + stack_trace);
		buffer.append(DATA_SEPARATE + SOFT_VERSION + "=" + softVersion);
		buffer.append(DATA_SEPARATE + NET + "=" + net);
		buffer.append(DATA_SEPARATE + PUBLISH_ID + "=" + publishID);
		data = buffer.toString();
	}

	public void sendCurReport() {
		MyHttpClient http = new MyHttpClient(new NetAttribute(context));
		boolean result = http.doHttpPost(ParamsManager.addParams(Config.ERROR_REPORT_URL), new IHandleHttpData() {

			@Override
			public void handleHttpData(HttpURLConnection urlconn)
					throws IOException {
				BufferedOutputStream osw = null;
				try {
					data = URLEncoder.encode(data, "UTF-8");
				} catch (UnsupportedEncodingException e) {
					e.printStackTrace();
					return;
				}
				byte[] bytes = data.getBytes("UTF-8");
				urlconn.setRequestProperty("Content-Length",
						Integer.toString(bytes.length));
				osw = new BufferedOutputStream(urlconn.getOutputStream(),
						8 * 1024);
				osw.write(bytes);
				osw.flush();
				osw.close();
			}
		});
		if (!result){
			saveFailData(data);
		}
	}

	public void sendAllReport() {
		MyHttpClient http = new MyHttpClient(new NetAttribute(context));
		String[] datas = new String[getSaveData().length];
		System.arraycopy(getSaveData(), 0, datas, 0, datas.length);
		for (int i = 0; i < datas.length + 1; i++) {
			if (i > 0)
				data = datas[i - 1];
			else
				try {
					data = URLEncoder.encode(data, "UTF-8");
				} catch (UnsupportedEncodingException e) {
					e.printStackTrace();
					return;
				}
			boolean result = http.doHttpPost(ParamsManager.addParams(Config.ERROR_REPORT_URL), new IHandleHttpData() {

				@Override
				public void handleHttpData(HttpURLConnection urlconn)
						throws IOException {
					BufferedOutputStream osw = null;
					byte[] bytes = data.getBytes("UTF-8");
					urlconn.setRequestProperty("Content-Length",
							Integer.toString(bytes.length));
					osw = new BufferedOutputStream(urlconn.getOutputStream(),
							8 * 1024);
					osw.write(bytes);
					osw.flush();
					osw.close();
				}
			});
			Log.i("news", "ExceptionReport:"+data);
			if (i == 0) {
				if (!result)
					saveFailData(data);
			} else {
				if (result)
					deleteSuccessData(data);
			}
		}
	}

	private void saveFailData(String data) {
		SharedPreferences preference = context.getSharedPreferences(
				SHAREDPREFERENCES_NAME, 0);
		String datas = preference.getString("datas", "");
		if (datas.length() == 0)
			preference.edit().putString("datas", data).commit();
		else
			preference.edit().putString("datas", datas + REPORT_SEPARATE + data).commit();
	}

	private String[] getSaveData() {
		SharedPreferences preference = context.getSharedPreferences(
				SHAREDPREFERENCES_NAME, 0);
		String datas = preference.getString("datas", "");
		return datas.split(REPORT_SEPARATE);
	}

	private void deleteSuccessData(String data) {
		SharedPreferences preference = context.getSharedPreferences(
				SHAREDPREFERENCES_NAME, 0);
		String datas = preference.getString("datas", "");
		if (datas.contains(REPORT_SEPARATE + data))
			datas = datas.replace(REPORT_SEPARATE + data, "");
		else
			datas = datas.replace(data, "");
		preference.edit().putString("datas", datas).commit();
	}

}
