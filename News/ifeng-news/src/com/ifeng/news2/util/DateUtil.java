package com.ifeng.news2.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import android.text.format.DateFormat;
import android.text.format.DateUtils;

/**
 * 日期处理的工具类
 * 
 * @author 13leaf
 */
public class DateUtil {

	public static final long ONE_MINUTE = 60 * 1000;

	public static final long ONE_HOUR = 60 * ONE_MINUTE;

	public static final long ONE_DAY = 24 * ONE_HOUR;

	private static final SimpleDateFormat parseFormat = new SimpleDateFormat(
			"yyyy-MM-dd HH:mm:ss");

	static {
		parseFormat.setTimeZone(TimeZone.getTimeZone("PRC"));// 使用东8区时区
	}

	public static Date now() {
		return new Date();
	}

	/**
	 * 
	 * @param serverTime
	 * @return
	 */
	public static String toBriefString(Date serverTime) {
		Date now = now();
		long timeSpan = now.getTime() - serverTime.getTime();
		if (timeSpan < 0)
			timeSpan = Integer.MAX_VALUE;

		if (timeSpan < ONE_HOUR) {
			return timeSpan / ONE_MINUTE + "分钟前";
		} else if (timeSpan < 4 * ONE_HOUR) {
			return timeSpan / ONE_HOUR + "小时前";
		} else if (DateUtils.isToday(serverTime.getTime())) {
			return "今天" + DateFormat.format("kk:mm", serverTime);
		} else {
			SimpleDateFormat simpleDateFormat = new SimpleDateFormat(
					"yyyy年MM月dd日");
			return simpleDateFormat.format(serverTime);
		}
	}

	/**
	 * 转化为本机日期相对服务器时间的相对间隔:<br>
	 * 策略如下:
	 * <ol>
	 * <li>与当前日期相比小于一小时间隔的显示在XX分钟前</li>
	 * <li>与当前日期相比小于4小时的间隔的显示在xx小时前</li>
	 * <li>在当前日期</li>
	 * <li>其它情况显示xx年xx月xx日</li>
	 * </ol>
	 * 
	 * @param time
	 *            时间的字符串形式,使用JDK的Date.parse进行解析。
	 * @return
	 */
	public static String toBriefString(String time) {
		if (time == null)
			return "";
		return toBriefString(parseServerTime(time));
	}

	/**
	 * 使用yyyy-MM-dd HH:mm:ss的format格式来进行解析<br>
	 * 使用服务器标准的东八区时区
	 * 
	 * @param dateString
	 * @return
	 */
	public static Date parseServerTime(String dateString) {
		try {
			return parseFormat.parse(dateString);
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	/**
	 * 使用yyyy-MM-dd HH:mm:ss的format格式来进行解析<br>
	 * 使用服务器标准的东八区时区
	 * 
	 * @param dateString
	 * @return
	 */
	public static long getTimeMillisFromServerTime(String dateString) {
		long currentTime = 0;
		Date date =  parseServerTime(dateString);
		if(date != null){
			currentTime = date.getTime();
		}
		return currentTime;
	}

	public static Date parse(String dateString, java.text.DateFormat formatter) {
		try {
			return formatter.parse(dateString);
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}

	/**
	 * 获取当前时间:System.currentTimeMillis()
	 * 
	 * @return
	 */
	public static String getCurrentTime() {
		try {
			String time = String.valueOf(System.currentTimeMillis());
			return time.substring(0, time.length() - 3);
		} catch (Exception e) {
			return "";
		}
	}

	/**
	 * 凤凰快讯列表日期处理函数
	 * @param time
	 * @return
	 */
	public static String getCurrentTime(String time) {
		String articleTime = "";
		try {
			long dropVaule = System.currentTimeMillis()
					- parseFormat.parse(time).getTime();
			if (dropVaule >= ONE_DAY) {
				int days = (int) (dropVaule / ONE_DAY);
				if (days <= 14) {
					articleTime = days + "天前";
				} else {
					articleTime = "很久以前";
				}
			} else if (dropVaule >= 0) {
				int hours = (int) (dropVaule / ONE_HOUR);
				articleTime = hours + "小时前";
			}
		} catch (ParseException e) {
			articleTime = "";
		}
		return articleTime;
	}
	
	public static boolean isToday(String time){
		boolean isToday = true;
		String articleTime = getCurrentTime(time);
		if (articleTime.endsWith("天前") || articleTime.endsWith("很久以前")) {
			isToday = false;
		}
		return isToday;
	}

	public static String getTimeOfList(String time){
		String articleTime = "";
		try {
			Date date = parseFormat.parse(time);
			SimpleDateFormat newParseFormat = new SimpleDateFormat(
					"yyyy/MM/dd");
			articleTime = newParseFormat.format(date);
		} catch (Exception e) {
			articleTime="";
		}
		return articleTime;
	}
	
	
	
	public static String getTimeForVote(long time){
		String articleTime = "";
		try {
			Date date = new Date(time);
			articleTime = new SimpleDateFormat(
					"yyyy/MM/dd").format(date);
		} catch (Exception e) {
			articleTime="";
		}
		return articleTime;
	}
	
	
	public static String getTimeForDirectSeeding(String time){
		String articleTime = "";
		try {
			Date date = parseFormat.parse(time);
			SimpleDateFormat newParseFormat = new SimpleDateFormat(
					"HH:mm");
			articleTime = newParseFormat.format(date);
		} catch (Exception e) {
			articleTime="";
		}
		return articleTime;
	}
	/**
	 * 视频列表 视频时长转化
	 */
	public static String parseDuration(int duration){
		long temp = duration * 1000; 
		SimpleDateFormat formater = new SimpleDateFormat("mm:ss");
		return formater.format(temp);
	}
	public static String formatDateTIme(String time){
	  String articleTime = "";
      try {
          Date date = parseFormat.parse(time);
          SimpleDateFormat newParseFormat = new SimpleDateFormat(
                  "yyyy/MM/dd  hh:mm");
          articleTime = newParseFormat.format(date);
      } catch (Exception e) {
          articleTime="";
      }
      return articleTime;
	}
	
}
