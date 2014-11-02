package com.qad.util;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;

import android.text.TextUtils;

import com.qad.bean.LogMessageBean;
import com.qad.loader.Settings;

/**
 * @author liu_xiaoliang
 * 
 */
public class LogUtil {

	private static FileOutputStream fos = null;

	/**
	 * @param msg -- log message 
	 */
	public static synchronized void Log2File(String msg) {
		if (!Settings.localLogSwitch) 
			return;
		LogMessageBean logMessageBean = new LogMessageBean();
		logMessageBean.setMsg(msg);
		logMessageBean.setUrl("The LogUtil not set url~");
		Log2File(logMessageBean);
	}

	public static synchronized void Log2File(LogMessageBean logMsgBean) {
		if (!Settings.localLogSwitch) 
			return;
		String log = buildLogData(logMsgBean);
		try {
			File LogFile = new File(Settings.getInstance().getBaseCacheDir().getAbsolutePath(),"log.txt");
			if (null == fos) 
				fos = new FileOutputStream(LogFile, true);
			
			fos.write(log.getBytes("UTF-8"));
			fos.flush();
		} catch (Exception e) {
		}  
	}

	public static void closeFileStream() {
		if (fos != null){
			try {
				fos.close();
			} catch (IOException e) {
			}
		}
	}

	public static String buildLogData(LogMessageBean logMsgBean){
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		StringBuilder sb = new StringBuilder();
		sb.append("timestamp: ").append(formatter.format(System.currentTimeMillis()));
		
		if (!TextUtils.isEmpty(logMsgBean.getTag())) {
			sb.append(logMsgBean.getTag() ).append(" , ");
		} 
		
		if (!TextUtils.isEmpty(logMsgBean.getPosition())) {
			sb.append(logMsgBean.getPosition()+ " , ");
		}
		
		sb.append(" , url = ");

		if (!TextUtils.isEmpty(logMsgBean.getUrl())) 
			sb.append(logMsgBean.getUrl());
		else
			sb.append("\"\"");

		sb.append(" , \nLog msg: \n");
		sb.append(logMsgBean.getMsg()+"\n\n\n");

		return sb.toString();
	}
}
