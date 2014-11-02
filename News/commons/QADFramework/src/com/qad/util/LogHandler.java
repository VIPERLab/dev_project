package com.qad.util;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;

import android.content.Context;
import android.util.Log;

import com.qad.lang.Files;
import com.qad.system.PhoneManager;

/**
 * 这是处理向服务器发送在线log的工具类，目前的策略是抽样记录log，
 * 只有IMEI或UUID结尾时‘0’的设备才发送log
 * @author guotd
 *
 */
public class LogHandler {

    private static final String ONLINE_LOG_URL = "http://stadig.ifeng.com/apperr.js";
    private static final String CRASH_LOG_FILE_NAME = "ifeng_crash.txt";
//    private static final String SOFT_ID = "ifengnews";
//    private static final String DATA_TYPE = "newsclient";
    private static final int INTERVAL = 60 * 1000;//发送log的时间间隔，单位毫秒
    
    private Context context = null;
    
    // 基本参数
    private String basicParameter = null;
//    private String sessionId = null;
    
    // IMEI或UUID
//    private String userkey = null;
    // 渠道号，需要再初始化LogHandler后传入, 默认是测试渠道
    private String publishid = "test";
    
    /**
     * 图片下载成功次数
     */
    private AtomicLong successCount = null;
    
    /**
     * 图片下载失败次数
     */
    private AtomicLong failedCount = null;
    
    /**
     * 在两次发送日志间隙，是否发生了图片下载
     */
    private AtomicBoolean isCountChanged = null;
    
    /**
     * 判断本设备是否需要向服务器发送log的标识
     */
    private boolean isDeviceLoggable = false;
    private SimpleDateFormat dayformat = new SimpleDateFormat("yyyyMMdd");
    private static SimpleDateFormat timeformat = new SimpleDateFormat("yyyy-MM-dd+HH:mm:ss");
    
    private HttpSender httpSender = new HttpSender();
    private List<String> logs = new ArrayList<String>(100);
    Timer taskTimer = null;
    
    private static LogHandler instance = null;
    
    public static LogHandler initialize(Context c) {
        instance = new LogHandler(c);
        return instance;
    }
    
    public static LogHandler singleton() {
        if (null == instance) {
            throw new RuntimeException("LogHandler.initialize must be called before using the handler");
        }
        return instance;
    }
    
    private LogHandler(Context c) {
        context = c;
//        basicParameter = buildBasicParameter(); // 当设置渠道号时初始化
        // sessionId内会用到userkey, 所以getUserKey需要先调用
//        userkey = getUserKey();
//        sessionId = makeSessionID();
//        Log.w("Sdebug", "the userkey is " + userkey);
        // 为节省带宽，次用抽样取log的方法，只有设备的IMEI或UUID以'0'结尾的设备才发送log到服务器
//        if ('0' == userkey.charAt(userkey.length() - 1)) {
            isDeviceLoggable = true;
//            taskTimer = new Timer("LogTimer");
//            taskTimer.schedule(new LogSendTask(), INTERVAL, INTERVAL);
//        }
//        successCount = new AtomicLong(0L);
//        failedCount = new AtomicLong(0L);
//        isCountChanged = new AtomicBoolean(false);
    }
    
    /**
     * 构造基本参数
     * @return
     */
    private String buildBasicParameter() {
        StringBuilder sb = new StringBuilder();
        /**
         * 根据与统计同事的沟通，去掉不必要的基本参数
         */
//        sb.append("&datatype=").append(DATA_TYPE);
//        sb.append("&softid=").append(SOFT_ID);
        sb.append("&mos=").append(Utils.getPlatform());
        sb.append("&publishid=").append(publishid); // 加入渠道号，已区分消息是否为内部测试手机发送的信息，尤其是CRASH的信息需要区分
        sb.append("&ua=").append(Utils.getUserAgent(context));
        sb.append("&userkey=").append(Utils.getIMEI(context));
        sb.append("&softv=").append(Utils.getSoftwareVersion(context));
        sb.append("&net=").append(Utils.getDetailedNetType(context));
//        sb.append("&re=").append(Utils.getScreenDescription(context));
        
        return sb.toString();
    }
    
    public void setPublishId(String id) {
        if (null != id) {
            publishid = id;
        }
        basicParameter = buildBasicParameter();
    }
    
    
    /**
     * sessionID 定义： userkey+当前时间(格式“yyyymmddHHmmss”)+4位随机数
     * 
     * @return
     */
//    private String makeSessionID() {
//        StringBuilder sb = new StringBuilder();
//        sb.append(userkey);
//        sb.append(dayformat.format(new Date()));
//        sb.append(String.valueOf((int)(1000 + Math.random() * 8999))); // 获得4位随机数
//        return sb.toString();
//    }
    
//    private String getUserKey() {
//        String userkey = Utils.getIMEI(context);
//        if (userkey == null || userkey.trim().length() == 0) {
//            userkey = Utils.getUUID(context.getSharedPreferences("uuid", Context.MODE_PRIVATE));
//        }
//        return userkey;
//    }
    
    private synchronized void internalAddLogRecord(String log) {
        logs.add(log);
        
    }
    
//    public synchronized static void increaseFailedCount() {
//    	LogHandler.singleton().failedCount.incrementAndGet();
//    	LogHandler.singleton().isCountChanged.set(true);
//    }
    
//    public synchronized static void increaseSuccessCount() {
//    	LogHandler.singleton().successCount.incrementAndGet();
//    	LogHandler.singleton().isCountChanged.set(true);
//    }
    
    /**
     * Recored 结构：currentTime # recordType # location # message # detailMessage #
     * @param message 日志消息
     */
//    public static void addLogRecord(String message) {
//        // 默认是error类型的消息
//        addLogRecord(message, "No detail message");
//    }
    
    /**
     * Recored 结构：currentTime # recordType # location # message # detailMessage #
     * @param message 日志消息
     * @param detailMessage 详细消息
     */
//    public static void addLogRecord(String message, String detailMessage) {
//        // 默认是error类型的消息
//        addLogRecord("NoSpecifiedLocation", message, detailMessage);
//    }
    
    /**
     * Recored 结构：currentTime # recordType # location # message # detailMessage #
     * @param location 日志发生的代码位置
     * @param message 日志消息
     * @param detailMessage 详细消息
     */
//    public static void addLogRecord(String location, String message, String detailMessage) {
//        // 默认是error类型的消息
//        addLogRecord("Error", location, message, detailMessage);
//    }
    
    /**
     * Recored 结构：currentTime # recordType # location # message # detailMessage #
     * @param recordType 记录类型： Error, Warning, Information, Debug
     * @param location 日志发生的代码位置
     * @param message 日志消息
     * @param detailMessage 详细消息
     */
//    public static void addLogRecord(String recordType, String location, String message, String detailMessage) {
//        addLogRecord(timeformat.format(new Date()), recordType, location, message, detailMessage);
//    }
    
    /**
     * Recored 结构：currentTime # recordType # location # message # detailMessage #
     * @param timestamp 记录产生时间(格式“yyyy-MM-dd HH:mm:ss”)
     * @param recordType 记录类型： Error, Warning, Information, Debug
     * @param location 日志发生的代码位置
     * @param message 日志消息
     * @param detailMessage 详细消息
     */
//    public static void addLogRecord(String timestamp, String recordType, String location
//            , String message, String detailMessage) {
//        if (LogHandler.singleton().isDeviceLoggable) {
//            // build log record -- start
//            StringBuilder sb = new StringBuilder();
//            sb.append("@");
//            sb.append(timestamp);
//            sb.append("#").append(recordType);
//            sb.append("#").append(location);
//            sb.append("#").append(message);
//            sb.append("#").append(detailMessage);
//            // build log record -- end
//            LogHandler.singleton().internalAddLogRecord(sb.toString());
//        }
//    }
    
    public static String buildLogRecord(String location, String message, String detailMessage) {
        StringBuilder sb = new StringBuilder();
        sb.append("@");
        sb.append(timeformat.format(new Date()));
        sb.append("#").append("CRASH");
        sb.append("#").append(location);
        sb.append("#").append(message);
        sb.append("#").append(detailMessage);
        return sb.toString();
    }
    
    /**
     * 得到stacktrace的字符串
     * @param e
     * @return
     */
    public static String stackTraceToString(Throwable throwable) {
    	StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw, true);
        throwable.printStackTrace(pw);
        return sw.getBuffer().toString().replaceAll("\n", "\t");// 因为\n会造成日志在服务器被截断，因为服务器按行取日志
    }
    
    /**
     * 处理url中的特殊字符，以便将其作为参数用GET方法传递到server
     * @param url
     * @return
     */
    public static String processURL(String url) {
        return url.replace("=", "%3D").replace("&", "%26");
    }
    
//    public static String buildCountInfoString() {
//    	StringBuilder sb = new StringBuilder();
//    	sb.append("@");
//        sb.append(timeformat.format(new Date()));
//        sb.append("#").append("Information");
//        sb.append("#").append("COUNT");
//        sb.append("#").append("Success: " + LogHandler.singleton().successCount.get());
//        sb.append("#").append("Failed: " + LogHandler.singleton().failedCount.get());
//        LogHandler.singleton().isCountChanged.set(false);
//        LogHandler.singleton().successCount.set(0l);
//        LogHandler.singleton().failedCount.set(0l);
//    	return sb.toString();
//    }
    
//    class LogSendTask extends TimerTask {
//
//        @Override
//        public void run() {
//        	// 如果没有网络，直接返回
//        	if(null != context && !PhoneManager.getInstance(context).isConnectedNetwork()) {
//        		return;
//        	}
//        	
//            List<String> logs4Sending = null;
//            // 为避免冲突给logs赋一个新的缓存空间
//            synchronized (LogHandler.singleton()) {
//                logs4Sending = LogHandler.singleton().logs;
//                logs = new ArrayList<String>(100);
//            }
//            StringBuilder sb = new StringBuilder();
//            if (logs4Sending.size() == 0 && isCountChanged.get()) {
//            	// no other logs, just sending successful & failed count info
//            	// 去掉sessionId，所以开头的@不需要了
//            	String requestParams = "session=" + encode(buildCountInfoString().substring(1)) + basicParameter;
//            	try {
//                    httpSender.send(ONLINE_LOG_URL, requestParams);
//                } catch (IOException e) {
//                    Log.w("LogHandler", "failed to send log to server, parameter: " + requestParams, e);
//                }
//            } else {
//	            for (String logRecord : logs4Sending) {
//	            	if (sb.length() + logRecord.length() > 1624) { // 1024 + 600, 保证加上基本参数后get request不超过2048
//	            		sb.append(buildCountInfoString());
//	            		// 去掉sessionId，所以开头的@不需要了
//	            		sb.deleteCharAt(0);
//	            		// 够一条记录的长度
//	                    String requestParams = "session=" + encode(sb.toString()) + basicParameter;
//	                    try {
//	                        httpSender.send(ONLINE_LOG_URL, requestParams);
//	                    } catch (IOException e) {
//	                        Log.w("LogHandler", "failed to send log to server, parameter: " + requestParams, e);
//	                    }
//	                    // 重新生成一个StringBuilder达到clean的目的，使前一个buffer可以被回收
//	                    sb = new StringBuilder();
//	            	} 
//	            	sb.append(logRecord);
//	            	
//	            }
//	            if (sb.length() > 0) {
//	            	sb.append(buildCountInfoString());
//	            	// 去掉sessionId，所以开头的@不需要了
//            		sb.deleteCharAt(0);
//	                // 发送log，这里log长度不足1624
//	                String requestParams = "session=" + encode(sb.toString()) + basicParameter;
//	                try {
//	                    httpSender.send(ONLINE_LOG_URL, requestParams);
//	                } catch (IOException e) {
//	                    Log.w("LogHandler", "failed to send log to server, parameter: " + requestParams, e);
//	                }
//	            }
//            }
//        }
//        
//    }
    
    /**
     * 用于发送crash报告, 不用等待timer，直接发送日志
     * @param logRecord
     */
    public void sendLogDirectly(String logRecord) {
    	Log.e("LogHandler", "Trying to send crash log: " + logRecord);
    	// 如果没有网络，直接返回
    	if(null != context && !PhoneManager.getInstance(context).isConnectedNetwork()) {
    		Log.w("LogHandler", "No network connection, can't send to log to server.");
    		serializeCrashLog(logRecord);
    		return;
    	}
    	// 去掉sessionId，所以开头的@不需要了
        String requestParams = "session=" + encode(logRecord.substring(1)) + basicParameter;
        try {
            httpSender.send(ONLINE_LOG_URL, requestParams);
        } catch (Exception e) {
            Log.w("LogHandler", "Failed to send log to server directly, parameter: " + requestParams, e);
            serializeCrashLog(logRecord);
        }
    }
    
    private void sendLog(String logRecord) throws IOException {
    	if(null != context && !PhoneManager.getInstance(context).isConnectedNetwork()) {
    		return;
    	}
    	// 去掉sessionId，所以开头的@不需要了
        String requestParams = "session=" + encode(logRecord.substring(1)) + basicParameter;
        httpSender.send(ONLINE_LOG_URL, requestParams);
    }
    
    private void serializeCrashLog(String log) {
    	File file = context.getFileStreamPath(CRASH_LOG_FILE_NAME);
    	try {
			Files.serializeObject(file, log);
			startTimer();
		} catch (IOException e) {
			Log.e("Sdebug", "Failed to serialize crash log to file " + file.getAbsolutePath(), e);
		}
    }
    
    private String encode(String string) {
		try {
			return URLEncoder.encode(string, "utf-8");
		} catch (UnsupportedEncodingException e) {
			Log.e("Sdebug", "Exception occurs while encoding", e);
			return string;
		}
	}
    
    private class SendingLogTimerTask extends TimerTask {
    	@Override
    	public void run() {
    		File file = context.getFileStreamPath(CRASH_LOG_FILE_NAME);
    		if (null != file && file.exists()) {
    			try {
					String log = (String)Files.deserializeObject(file);
					sendLog(log);
					file.delete();
				} catch (IOException e) {
					Log.e("Sdebug", "Exception occurs while sending serialized log", e);
//					cancelTimer();
				}
    		} else {
    			cancelTimer();
    		}
    	}
    }
    
    private void startTimer() {
    	if (null == taskTimer) {
    		taskTimer = new Timer("SendingCrashTimer");
    		taskTimer.schedule(new SendingLogTimerTask(), 10000, 60000);
    	}
    }
    
    public void cancelTimer() {
        if (null != taskTimer) {
            taskTimer.cancel();
            taskTimer = null;
        }
    }
    
}
