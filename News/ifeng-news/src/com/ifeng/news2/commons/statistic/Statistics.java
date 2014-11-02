package com.ifeng.news2.commons.statistic;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.Serializable;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.text.TextUtils;
import android.util.Log;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.util.StatisticUtil;
import com.qad.lang.Files;
import com.qad.system.PhoneManager;
import com.qad.util.HttpSender;
import com.qad.util.HttpSender.RequestMethod;
import com.qad.util.Utils;

/**
 * 统计
 * 
 * @author harp
 * 
 */
public class Statistics {
	private static final String RECORD_START = "@";
	private static final String RECORD_DIV = "#";
	private static List<String> StaCache = Collections.synchronizedList(new LinkedList<String>());
	private static LinkedList<String> queue = new LinkedList<String>();
//	private static Object lock = new Object();
	private static SimpleDateFormat dayformat = new SimpleDateFormat("yyyyMMdd");
	private static SimpleDateFormat timeformat = new SimpleDateFormat(
			"yyyy-MM-dd+HH:mm:ss");
//	private static final int Max = 8999;
	private final static String TAG = "Statistics";

	private String statUrl;
	private static String publishid;
//	private String userkey; // 不需要build sessionId字段，所以不再需要
	private String loginTime;
	boolean needNet;// 是否使用网络类型参数
	boolean needIp;// 是否需要ip
	SendInterceptor interceptor;
	private int sessionInterval = 45 * 1000; // 获取数据时间间隔，单位毫秒
//	private static long persistanceTimeStamp = System.currentTimeMillis();
//	private static final long AUTO_SAVE_SPAN = 5 * 1000;// 若发现上次持久时间戳据今超过间隔，则将自动存储
	private static int isUpdate = 0;
	private static final int MAX_GET_LENGTH = 1024;
	private Timer timer;
	private HttpSender sender = new HttpSender();
	// never change this
	private static File datFile;
	private Context app;
	private static StringBuilder params = new StringBuilder();

	private static Statistics instance;
	private static boolean sendComplete = false;

	/**
	 * 发送数据
	 */
	private TimerTask task;

	public Statistics setSessionInterval(int interval) {
		if (interval <= 0)
			throw new IllegalArgumentException();
		sessionInterval = interval;
		return this;
	}

	public Statistics appendMobileOS() {
		params.append("&mos=").append(Utils.getPlatform());
		return this;
	}
	
	/**
	 * Replace 'android_' part of {@link Utils#getPlatform()} using given prefix string
	 * @param prefix the customized string 
	 * @return Statistic object with label of the platform
	 */
	public Statistics appendMobileOS(String prefix) {
		params.append("&mos=").append(prefix).append(Utils.getPlatform());
		return this;
	}

	public Statistics appendSoftVersion() {
		params.append("&softversion=").append(Utils.getSoftwareVersion(app));
		// 取Config中的versoin是固定的不能随着打包版本变化，为适应测试需要还是去包的版本
//		params.append("&softversion=").append(Config.CURRENT_CONFIG_VERSION);
		return this;
	}

	public Statistics appendSoftId(String id) {
		params.append("&softid=").append(id);
		return this;
	}

	public Statistics appendDataType(String dataType) {
		params.append("&datatype=").append(dataType);
		return this;
	}

	public Statistics appendPublishId(String id) {
		publishid = id;
		params.append("&publishid=").append(id);
		return this;
	}

	public Statistics appendUserAgent() {
		// 为解决ua字段引起的解密验证失败的问题，android客户端在发送前将ua字段进行url encode
		params.append("&ua=").append(encode(Utils.getUserAgent(app)));
//		params.append("&ua=").append(encode("ifeng_测试机"));
		return this;
	}

	public Statistics appendNet() {
		needNet = true;// 如果设置，那么每次都会动态的获取网络类型并设置
		return this;
	}

	/**
	 * 使用imei作为userKey
	 * 
	 * @return
	 */
	public Statistics appendUserKey() {
		String userKey = null;
		if(Config.SPECIAL_USERKEY){
			userKey = Utils.getSpecialUserkey(app);
		} else{
			userKey = Utils.getIMEI(app);
		}
		if (TextUtils.isEmpty(userKey.trim())) {
			userKey = Utils.getUUID(app.getSharedPreferences("uuid", Context.MODE_PRIVATE));
			params.append("&userkey=").append(userKey);
		} else
			params.append("&userkey=").append(userKey);
		return this;
	}
	
	public Statistics appendIsUpdate() {
		params.append("&isupdate=").append(isUpdate);
		return this;
	}

	/**
	 * 添加mac地址,字段名 "macAddress"
	 * @return
	 */
	public Statistics appendMacAddress(){
		String mac = Utils.getMacAddress(app);
		params.append("&macAddress=").append(mac);
		return this;
	}
	
	/**
	 * 第一次使用时间
	 * @return
	 */
	public Statistics appendFirstUseTime(){
		params.append("&logintime=").append(loginTime);
		return this;
	}
	public Statistics appendParam(String key, String value) {
		params.append("&").append(key).append("=").append(value);
		return this;
	}

	/**
	 * 设置拦截器，可以在发送之前拦截并动态删改参数
	 * 
	 * @param interceptor
	 * @return
	 */
	public Statistics setSendInterceptor(SendInterceptor interceptor) {
		this.interceptor = interceptor;
		return this;
	}

	public Statistics appendIp() {
		needIp = true;
		return this;
	}

	
	/**
	 * 使用静态方法进行构造
	 * 
	 * @param ctx
	 * @throws Exception 
	 */
	private Statistics(Context ctx) {
		
		try {
			int permitted = ctx.getPackageManager().checkPermission(android.Manifest.permission.ACCESS_WIFI_STATE, ctx.getPackageName());
			if (permitted == PackageManager.PERMISSION_DENIED)
				throw new Exception("统计组件需要ACCESS_WIFI_STATE权限");
			permitted = ctx.getPackageManager().checkPermission(android.Manifest.permission.READ_PHONE_STATE, ctx.getPackageName());
			if (permitted == PackageManager.PERMISSION_DENIED)
				throw new Exception("统计组件需要READ_PHONE_STATE权限");
		} catch (Exception e) {
			e.printStackTrace();
			Log.e("Statistic", e.getMessage());
			return;
		}
		if (datFile == null)
			//版本不同，序列化文件相同，但是导致序列化对象不同，容易导致类型转换异常。
			datFile = ctx.getFileStreamPath("ifeng_statitics+"+Utils.getSoftwareVersion(ctx)+".dat");
		ensureCache();
		app = ctx.getApplicationContext();
//		userkey = Utils.getIMEI(ctx);
//		/* @gm, handle exception if userkey is null*/
//		if (userkey == null || userkey.trim().length() == 0) {
//			userkey = Utils.getUUID(ctx.getSharedPreferences("uuid", Context.MODE_PRIVATE));
//		}
		/* @gm, handle exception if userkey is null, end*/
		
		String isUpdateKey;
		try {
			isUpdateKey = "isUpdate_" + ctx.getPackageManager().getPackageInfo(ctx.getPackageName(), 0).versionCode;
		} catch (NameNotFoundException e) {
			// shouldn't get here
			e.printStackTrace();
			isUpdateKey = "isUpdate_";
		}
		if (!ctx.getSharedPreferences("FirstLogin", Context.MODE_PRIVATE).contains("firstLoginTime")) {
			// 新安装
			isUpdate = 0;
			ctx.getSharedPreferences("FirstLogin", Context.MODE_PRIVATE).edit().putInt(isUpdateKey, isUpdate).commit();
		} else if (!ctx.getSharedPreferences("FirstLogin", Context.MODE_PRIVATE).contains(isUpdateKey)) { // 已经有了相应的preference值，说明客户端是升级上来的
			// 升级
			isUpdate = 1;
			ctx.getSharedPreferences("FirstLogin", Context.MODE_PRIVATE).edit().putInt(isUpdateKey, isUpdate).commit();
		} else {
			isUpdate = ctx.getSharedPreferences("FirstLogin", Context.MODE_PRIVATE).getInt(isUpdateKey, 0);
		}
		
		loginTime = Utils.getFirstLoginTime(ctx);
//		sendMore();
		setRequestUrl(StatisticUtil.STATISTICS_URL).appendDataType(StatisticUtil.STATISTICS_DATA_TYPE).appendMobileOS()
		.appendSoftVersion().appendPublishId(Config.PUBLISH_ID)
		.appendUserKey().appendUserAgent()
		.appendNet().appendFirstUseTime()
		.appendIsUpdate();
	}

	/**
	 * 将预备的统计参数转化成可读形式
	 * @return
	 */
	public static String buildInfo() {
		if (instance != null) {
			StringBuilder sb = new StringBuilder("基本信息:\n");
			sb = sb.append(instance.params.toString().replace("&", "\n"));
			return sb.toString();
		} else {
			return "";
		}
	}

	/**
	 * Construct an instance of statistic to log app records. <b><br>-----------NOTE:-------- <br>YOU SHOULD DECLEAR 
	 * <br>android.permission.ACCESS_WIFI_STATE and 
	 * <br>android.permission.READ_PHONE_STATE
	 * <br>in your AndroidManifest<br>-----------NOTE:--------</b>
	 * @param context The application context
	 * @return The instance of statistic
	 */
	public synchronized static Statistics ready(Context context) {
		if (instance == null) {
			instance = new Statistics(context);
		}
		return instance;
	}
	
	public static boolean isReady() {
		return instance == null;
	}

	/**
	 * 设置发送方法，默认使用get。可改使用post
	 * 
	 * @param method
	 * @return
	 */
	public Statistics setRequestMethod(RequestMethod method) {
		sender.setMethod(method);
		return this;
	}

	/**
	 * 设置统计主机地址
	 * 
	 * @param url
	 * @return
	 */
	public Statistics setRequestUrl(String url) {
		this.statUrl = url;
		return this;
	}

	public static String getPublishid() {
		return publishid;
	}

	/**
	 * 检验参数是否设置正确
	 */
	public void start() {
		// 检查必须资源
		if (statUrl == null)
			throw new NullPointerException();
		if (app == null)
			throw new NullPointerException();
		if (params.length() > 0)
			params.deleteCharAt(0);// 去除&首个
		// checkout if params has only one param
		if (params.length() > 0) {
			String[] pairs = params.toString().split("&");
			ArrayList<String> keys = new ArrayList<String>();
			for (String pair : pairs) {
				String key = pair.substring(0, pair.indexOf('='));
				if (keys.contains(key))
					throw new IllegalArgumentException(String.format(
							"Duplicate param %s", key));
				keys.add(key);
			}
			keys.clear();
			keys = null;
		}
		// 此处仅基于兼容性考虑
		if (null != timer) {
			timer.cancel();
		}
		sendMore(); // 开始timer task
	}

	/**
	 * 
	 * @return
	 */
//	public List<String> getReadOnlyStatistics() {
//		synchronized (lock) {
//			return Collections.unmodifiableList(StaCache);// test use
//		}
//	}

	private void ensureCache() {
		if (IfengNewsApp.isMainProcess) { // fix bug #18424 【统计】统计有重复现象  widget进程引起的统计重复发送
		// 此方法是统计初始化时调用，不会有线程冲突的问题，不需要同步
			try {
				@SuppressWarnings("unchecked")
				List<String> cache = (List<String>) Files
						.deserializeObject(datFile);
				if (StaCache.isEmpty() && !cache.isEmpty()) {
					StaCache = cache;
					Log.d(TAG, "Load from cache " + cache);
				}
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	/**
	 * 清除发送的缓存队列。
	 */
//	public void clearCache() {
//		StaCache.clear();
//		try {
//			Files.serializeObject(datFile, StaCache);
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//	}

	/**
	 * 立即进行同步发送统计。
	 */
//	public void send() {
//		try {
//			_send();
//		} catch (InterruptedException e) {
//			e.printStackTrace();
//		}
//	}

	/**
	 * 
	 * @param txt发送内容
	 * @throws InterruptedException 
	 * @throws IOException
	 * @throws MalformedURLException
	 */
	private void _send() throws InterruptedException {
//		synchronized (lock) { // 现在只有一个timer task会调用此方法，所以此处不需要同步，只需考虑staCache的同步
		sendComplete = false;

		StringBuilder sb = new StringBuilder();

		//				sb.append(makeSessionID());  // 根据最新的统计定义不需要sessionId参数
		synchronized (StaCache) {
			queue.clear();
			for (String record : StaCache) {
				sb.append(record);
				//liuxiaoliang begin
				/*queue.add(record);*/
				if (sender.getMethod() == RequestMethod.GET
						&& sb.length() > MAX_GET_LENGTH) {
					sb.delete(sb.length() - record.length(), sb.length());
					/*queue.removeLast();*/
					break;
				}
				queue.add(record);
				//liuxiaoliang end
			}
		}
		// 由于没有了sessionId字段，所以需要去掉第一个record的@符号
		sb.deleteCharAt(0);
		String requestParams = params.toString() + "&session="+ encode(sb.toString());
		if (needIp)
			requestParams += "&ip=" + Utils.getLocalIpAddress();
		if (needNet)
			requestParams += "&net=" + Utils.getNetType(app);
		if (interceptor != null) {
			requestParams = interceptor.interceptSend(requestParams);
		}
		try {
			requestParams = statUrl + "?" + requestParams;
//			Log.i("Sdebug", "Thread ID:" + Thread.currentThread().getId() + ",send: " + requestParams);
			String encryptedUrl = com.ifeng.signature.US.s(requestParams);
//			Log.w("Sdebug", "encryptedUrl= " + encryptedUrl);
			sender.send(encryptedUrl);
			sendComplete = true;
			synchronized (StaCache) {
				for(String record:queue){
					StaCache.remove(record);
				}
				queue.clear();
				// 若发送失败，不需要再存储一遍
				if (IfengNewsApp.isMainProcess) {
					try {
	
	//					Log.i("Sdebug", "Thread ID:" + Thread.currentThread().getId() + ", save to file: " + datFile.toString() + " ," + StaCache.toString());
						Files.serializeObject(datFile, (Serializable) StaCache);
	
					} catch (IOException e) {
						Log.e(TAG, "IOException occurs while persisting statistic data:" + e.getMessage(), e);
					}
				}
			}
		} catch (IOException e) {
			Log.e(TAG, "IOException occurs while sending statistic data:" + e.getMessage(), e);
		} finally {
			//				try {
			//					synchronized (StaCache) {
			//						Log.i("Sdebug", "Thread ID:" + Thread.currentThread().getId() + ", save to file: " + datFile.toString() + " ," + StaCache.toString());
			//						Files.serializeObject(datFile, (Serializable) StaCache);
			//					}
			////					persistanceTimeStamp = System.currentTimeMillis();
			//				} catch (IOException e) {
			//					Log.e(TAG, "IOException occurs while persisting statistic data:" + e.getMessage(), e);
			//				}
		}
		//		}
	}

	private String encode(String string) {
		try {
			return URLEncoder.encode(string, "utf-8");
		} catch (UnsupportedEncodingException e) {
			Log.e("Sdebug", "Exception occurs while encoding", e);
			return string;
		}
	}

	public static void setRequestMode(RequestMethod method) {
		// for test use
		instance.setRequestMethod(method);
	}

//	public static void stopInterval() {
//		instance.stop(true);
//	}
//
//	public void stop(boolean save) {
//		if (save) {
//			try {
//				Files.serializeObject(datFile, (Serializable) StaCache);
//			} catch (IOException e) {
//				e.printStackTrace();
//			}
//		}
//		StaCache.clear();
//		if (timer != null)
//			timer.cancel();
//		instance = null;// enable to rebuild
//	}

	

	/**
	 * 时间间隔发送多次请求记录
	 */
	private void sendMore() {
		timer = new Timer("StatisticTimer");
		task = new MySendingTask();
		timer.schedule(task, 5000, sessionInterval); // 应用启动5s后做第一次日志发送
	}

	class MySendingTask extends TimerTask {
		@Override
		public void run() {
			try {
				if (StaCache != null && !StaCache.isEmpty()) {
					// 如果没有网络，持久化统计数据后直接返回
			    	if(null != app && !PhoneManager.getInstance(app).isConnectedNetwork() && IfengNewsApp.isMainProcess) {
			    		Log.w("MySendingTask", "No network connection, can't send statistic data to server.");
			    		synchronized (StaCache) {
			    			Files.serializeObject(datFile, (Serializable) StaCache);
			    		}
			    		return;
			    	}
					_send();
				}
			} catch (Exception ex) {
				Log.w(TAG, ex.getMessage() + "", ex);
			}
		}
	}

	

	/**
	 * 只发送一次请求记录
	 */
//	public void sendOnce() {
//		new Thread() {
//			public void run() {
//				try {
//					_send();
//				} catch (Exception e) {
//					e.printStackTrace();
//				}
//			}
//		}.start();
//	}

	/**
	 * 增加一条记录
	 * 
	 * @param recordType
	 *            记录类型
	 * @param content
	 *            记录内容
	 */
	public static void addRecord(String recordType, String content) {
		String record = makeRecord(recordType, content);
		StaCache.add(record);
		if (IfengNewsApp.isMainProcess) {
			try {
				synchronized (StaCache) {
	//				Log.d(TAG, "start: " + System.currentTimeMillis());
					Files.serializeObject(datFile, (Serializable)StaCache);
	//				Log.d(TAG, "end: " + System.currentTimeMillis());
				}
			} catch (Exception e) {
				Log.e(TAG, "IOException occurs while persisting statistic data:" + e.getMessage(), e);
			} 
		}
		// 在每次触发统计信息发送时持久化相关数据就可以，每45秒发生一次
//		if (System.currentTimeMillis() - persistanceTimeStamp > AUTO_SAVE_SPAN) {
//			new Thread() {
//				public void run() {
//					synchronized (lock) {
//						if (datFile == null)
//							return;
//						try {
//							Files.serializeObject(datFile, (Serializable)StaCache);
//							persistanceTimeStamp = System.currentTimeMillis();
//							Log.d(TAG,
//									"AutoPersistance cause addRecord timeout.");
//						} catch (Exception e) {
//							e.printStackTrace();
//						} 
//					}
//				}
//			}.start();
//		}
	}
	
	/**
	 * 序列化存储统计日志
	 */
	public static void saveRecord() {
		try {
			synchronized(StaCache) {
				if (sendComplete) {
					for(String record:queue){
						StaCache.remove(record);
					}
					queue.clear();
				}
//				Log.i("Sdebug", "save to file: " + datFile.toString() + " ," + StaCache.toString());
				Files.serializeObject(datFile, (Serializable) StaCache);
			}
		} catch (IOException e) {
			Log.e(TAG, "IOException occurs while persisting statistic data:" + e.getMessage(), e);
		}
	}

	/**
	 * 
	 * 注 **record 记录定义: 记录开始符+currentTime＋分隔符+recordType＋分隔符+content 参数 描述 记录开始符 @
	 * 分隔符 # currentTime 当前时间，格式“HHmmss” recordType 记录类型 content 记录内容
	 * 
	 * 构造记录
	 * 
	 * @param recordType
	 * @param content
	 * @return
	 */

	/**
	 * 生成一条记录
	 * 
	 * @param recordType
	 *            Statics必须为有效的recordType
	 * @param content
	 * @return
	 */
	private static String makeRecord(String recordType, String content) {

		StringBuilder sb = new StringBuilder();
		sb.append(RECORD_START);
		// sb.append(CURRENT_TIME);
		sb.append(getCurrentTime());
		sb.append(RECORD_DIV);
		// sb.append(RECORD_TYPE);
		sb.append(recordType);
		sb.append(RECORD_DIV);
		// sb.append(CONTENT);
		if (!TextUtils.isEmpty(content)) {
			sb.append(content);
		} 
//		if (!TextUtils.isEmpty(content)) { // 统计每个动作是在什么网络下发生的
//			sb.append(content).append("$net=").append(Utils.getNetType(instance.app));
//		} else {
//			sb.append("net=").append(Utils.getNetType(instance.app));
//		}

		Log.w("Sdebug", "makeRecord: " + sb.toString());
		return sb.toString();
	}

	/**
	 * sessionID 定义： userkey+当前时间(格式“yyyymmddHHmmss”)+4位随机数
	 * 
	 * @return
	 */
//	private String makeSessionID() {
//		StringBuilder sb = new StringBuilder();
//		sb.append(userkey);
//		sb.append(getCurrentDay());
//		sb.append(getFourRandomDigits());
//		return sb.toString();
//	}

//	private static String getFourRandomDigits() {
//		return "" + (int) (1000 + Math.random() * Max);
//	}

	private static String getCurrentTime() {
		return timeformat.format(new Date());
	}

//	private static String getCurrentDay() {
//		return dayformat.format(new Date());
//	}



	
}
