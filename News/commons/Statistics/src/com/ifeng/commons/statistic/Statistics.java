package com.ifeng.commons.statistic;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
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
import android.util.Log;

import com.qad.lang.Files;
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
	private static LinkedList<String> StaCache = new LinkedList<String>();
	private static Object lock = new Object();
	private static SimpleDateFormat dayformat = new SimpleDateFormat("yyyyMMdd");
	private static SimpleDateFormat timeformat = new SimpleDateFormat(
			"yyyy-MM-dd HH:mm:ss");
	public static final int Max = 8999;
	private final static String TAG = Statistics.class.getSimpleName();

	private String statUrl;
	private static String publishid;
	private String userkey;
	private String loginTime;
	boolean needNet;// 是否使用网络类型参数
	boolean needIp;// 是否需要ip
	SendInterceptor interceptor;
	private int sessionInterval = 45 * 1000; // 获取数据时间间隔，单位毫秒
	private static long persistanceTimeStamp = System.currentTimeMillis();
	private static final long AUTO_SAVE_SPAN = 5 * 1000;// 若发现上次持久时间戳据今超过间隔，则将自动存储
	public static final int MAX_GET_LENGTH = 1024;

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
		params.append("&ua=").append(Utils.getUserAgent(app));
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
		String imei = Utils.getIMEI(app);
		if (imei == null || imei.trim().length() == 0) {
			imei = Utils.getUUID(app.getSharedPreferences("uuid", Context.MODE_PRIVATE));
			params.append("&guserkey=").append(imei);
		} else
			params.append("&userkey=").append(imei);
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

	private HttpSender sender = new HttpSender();
	// never change this
	private static File datFile;
	private Context app;
	private StringBuilder params = new StringBuilder();

	private static Statistics instance;

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
			datFile = ctx.getFileStreamPath("ifeng_statitics.dat");
		ensureCache();
		app = ctx.getApplicationContext();
		userkey = Utils.getIMEI(ctx);
		/* @gm, handle exception if userkey is null*/
		if (userkey == null || userkey.trim().length() == 0) {
			userkey = Utils.getUUID(ctx.getSharedPreferences("uuid", Context.MODE_PRIVATE));
		}
		/* @gm, handle exception if userkey is null, end*/
		loginTime = Utils.getFirstLoginTime(ctx);
		sendMore();
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
	public static Statistics ready(Context context) {
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
		timer.cancel();
		sendMore();
	}

	/**
	 * 
	 * @return
	 */
	public List<String> getReadOnlyStatistics() {
		synchronized (lock) {
			return Collections.unmodifiableList(StaCache);// test use
		}
	}

	private void ensureCache() {
		synchronized (lock) {
			try {
				@SuppressWarnings("unchecked")
				LinkedList<String> cache = (LinkedList<String>) Files
						.deserializeObject(datFile);
				if (StaCache.size() == 0) {
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
	public void clearCache() {
		StaCache.clear();
		try {
			Files.serializeObject(datFile, StaCache);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 立即进行同步发送统计。
	 */
	public void send() {
		try {
			_send();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 
	 * @param txt发送内容
	 * @throws InterruptedException 
	 * @throws IOException
	 * @throws MalformedURLException
	 */
	private void _send() throws InterruptedException {
		synchronized (lock) {
			StringBuilder sb = new StringBuilder();
			LinkedList<String> queue = new LinkedList<String>();
			synchronized (StaCache) {
				if (StaCache.size() == 0) {
					StaCache.wait();
				}
				sb.append(makeSessionID());
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
			String requestParams = params.toString() + "&session="+ sb.toString();
			if (needIp)
				requestParams += "&ip=" + Utils.getLocalIpAddress();
			if (needNet)
				requestParams += "&net=" + Utils.getNetType(app);
			if (interceptor != null) {
				requestParams = interceptor.interceptSend(requestParams);
			}
			try {
				sender.send(statUrl, requestParams);
				for(String record:queue){
					StaCache.remove(record);
				}
			} catch (IOException e) {
				Log.e(TAG, "send:" + e.getMessage());
			} finally {
				try {
					Files.serializeObject(datFile, StaCache);
					persistanceTimeStamp = System.currentTimeMillis();
				} catch (IOException e) {
					Log.e(TAG, "persist:" + e.getMessage());
				}
			}
		}
	}

	private String encode(String string) {
		try {
			return URLEncoder.encode(string, "utf-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			return "";
		}
	}

	public static void setRequestMode(RequestMethod method) {
		// for test use
		instance.setRequestMethod(method);
	}

	public static void stopInterval() {
		instance.stop(true);
	}

	public void stop(boolean save) {
		if (save) {
			try {
				Files.serializeObject(datFile, StaCache);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		StaCache.clear();
		if (timer != null)
			timer.cancel();
		instance = null;// enable to rebuild
	}

	private Timer timer;

	/**
	 * 时间间隔发送多次请求记录
	 */
	private void sendMore() {
		timer = new Timer("StaticsTimer");
		task = new MySendingTask();
		timer.schedule(task, sessionInterval, sessionInterval);
	}

	class MySendingTask extends TimerTask {
		@Override
		public void run() {
			try {
				if (StaCache != null && !StaCache.isEmpty()) {
					_send();
				}
			} catch (Exception ex) {
				Log.d(TAG, ex.getMessage() + "");
			}
		}
	}

	/**
	 * 发送数据
	 */
	TimerTask task;

	/**
	 * 只发送一次请求记录
	 */
	public void sendOnce() {
		new Thread() {
			public void run() {
				try {
					_send();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}.start();
	}

	/**
	 * 增加一条记录
	 * 
	 * @param recordType
	 *            记录类型
	 * @param content
	 *            记录内容
	 */
	public static void addRecord(String recordType, String content) {
		synchronized (StaCache) {
			StaCache.add(makeRecord(recordType, content));
			StaCache.notifyAll();
		}
		if (System.currentTimeMillis() - persistanceTimeStamp > AUTO_SAVE_SPAN) {
			new Thread() {
				public void run() {
					synchronized (lock) {
						if (datFile == null)
							return;
						try {
							Files.serializeObject(datFile, StaCache);
							persistanceTimeStamp = System.currentTimeMillis();
							Log.d(TAG,
									"AutoPersistance cause addRecord timeout.");
						} catch (Exception e) {
							e.printStackTrace();
						} 
					}
				}
			}.start();
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
		sb.append(content);

		return sb.toString();
	}

	/**
	 * sessionID 定义： userkey+当前时间(格式“yyyymmddHHmmss”)+4位随机数
	 * 
	 * @return
	 */
	private String makeSessionID() {
		StringBuilder sb = new StringBuilder();
		sb.append(userkey);
		sb.append(getCurrentDay());
		sb.append(getFourRandomDigits());
		return sb.toString();
	}

	private static String getFourRandomDigits() {
		return "" + (int) (1000 + Math.random() * Max);
	}

	private static String getCurrentTime() {
		return timeformat.format(new Date());
	}

	private static String getCurrentDay() {
		return dayformat.format(new Date());
	}

	private static final String RECORD_START = "@";
	private static final String RECORD_DIV = "#";

	/**
	 * recordType
	 */
	// public static final String RECORD_PAGE = "PA";
	// 大焦点图
	public static final String RECORD_PAGE_FOCUS = "PAF";
	// 小焦点图
	public static final String RECORD_PAGE_HEADLINE = "PAH";
	// 普通新闻列表
	public static final String RECORD_PAGE_NORMAL = "PAC";
	// 统计频道
	public static final String RECORD_CHANNEL = "CH";
	// 统计图片
	public static final String RECORD_PICTURE = "PI";
	// 统计评论
	public static final String RECORD_COMMENT = "CM";
	// 统计新浪转发
	public static final String RECORD_SHARE_SINA = "SHS";
	// 统计快博转发
	public static final String RECORD_SHARE_KUAIBO = "SHK";
	// 统计收藏
	public static final String RECORD_COLLECT = "CL";
	// 统计广告
	public static final String RECORD_ADVERTISE = "AD";
	// 统计在线时长
	public static final String RECORD_DURATION = "DU";
	// 统计离线
	public static final String RECORD_OFFLINE = "OF";

	public static final String RECORD_OPENBOOK_START = "START";

	// 画报下载
	public static final String DOWN_MESSAGE = "DC";
	// 下载详细页
	public static final String DETAIL_MESSAGE = "DDC";
	// 列表页
	public static final String LIST_MESSAGE = "LDC";

}
