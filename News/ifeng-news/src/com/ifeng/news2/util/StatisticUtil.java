package com.ifeng.news2.util;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.preference.PreferenceManager;
import android.text.TextUtils;
import android.text.style.BulletSpan;
import android.util.Log;

import com.ifeng.news2.Config;
import com.ifeng.news2.commons.statistic.Statistics;
import com.qad.util.WToast;

/**
 * 统计信息代理类，监测统计信息的状态，校验统计类型等
 * 
 * @author Administrator
 * 
 */
public class StatisticUtil {

	// 根据最新的统计文档调整接口， 旧接口： http://stadig.ifeng.com/stat.js"，此接口在config.txt中可配置;
	public static String STATISTICS_URL = "http://stadig.ifeng.com/appsta.js"; 
	public static final String STATISTICS_DATA_TYPE = "newsapp";//"newsclient";
	public static final String STATISTICS_SOFT_ID = "ifengnews";
	public  static final long START_INTERVAL = 30000; // 30 seconds
	public static boolean isBack = false;//是否点击过后的返回
	public static String doc_id = "";//文章的id
	public static String type = "" ; //type类型
	
	public static enum StatisticRecordAction {
		page, // TODO: add comments here
		v,    // 观看视频统计
		in,   // 启动客户端
		ts,   // 转发、分享
		od,   // 离线下载
		pushaccess, //推送到达
		openpush,   //推送打开
		pushon,     //打开推送开关
		pushoff,    //关闭推送开关
		hb,          //心跳
		end,			//访问时长
		desktop,      //widget打开
		action		//功能使用
	}
	
	public static enum StatisticPageType {
		vote,//投票
		article, // 文章
		pic,  // 图片
		piclive, // 图文直播
		ch,   // 频道列表页
		topic,// 专题列表页
		sportslive, // 体育直播
		vlive, //视频直播间
		exclusive, // 独家二级频道
		store,	//收藏
		dispic,	//使用无图模式
		follow,	//跟帖
		reply,	//回复跟帖
		support,//支持跟帖
		share,	//跟帖分享
		video,   //视频频道正文页
		set, //设置页
		comment, //评论页
		other,//其他类型
		survey//调查
	}
	
	public static void addRecord(StatisticRecordAction action, String content) {
		// 有的统计content为空，比如od, pushon, pushoff
//		if(!TextUtils.isEmpty(content)){ 
			Statistics.addRecord(action.toString(), content);
//		}		
	}
	
	public static void addRecord(Context ctx, StatisticRecordAction action, String content) {
//		if(!TextUtils.isEmpty(content)){
		Statistics.addRecord(action.toString(), content);
//		}	
		if (Config.isDEGUG) {
			String message = action + ": " + content;
			//分享统计在子线程，不能弹出toast，导致分享不成功
//			new WToast(ctx).showMessage(message);
			Log.w("Sdebug", "统计：" + message);
		}
	}
	

	/**
	 * 记录统计信息
	 * 
	 * @param context
	 * @param recordType
	 * @param content
	 */
//	public static void addRecord(Context context, String recordType,
//			String content) {
//		try {
//			checkRecordType(recordType);
//		} catch (UndefinedRecordTypeException e) {
//			if (Config.isDEGUG) {
//				new WToast(context).showMessage(ERROR_REPORT);
//			}
//			return;
//		}
//		if(!TextUtils.isEmpty(content)){
//			Statistics.addRecord(recordType, content);
//		}		
//		if (Config.isDEGUG) {
//			String message = recordType + ": " + content;
//			WToast toast = new WToast(context);
//			toast.showMessage(message);
//		}
//	}
	
	/**
	 * 
	 * @param context
	 * @param recordType
	 * @param content
	 * @param category
	 */
//	public static void addRecord(Context context, String recordType,
//			String content,String category) {
//		try {
//			checkRecordType(recordType);
//		} catch (UndefinedRecordTypeException e) {
//			if (Config.isDEGUG) {
//				new WToast(context).showMessage(ERROR_REPORT);
//			}
//			return;
//		}
//		if(null != content&&category!=null){
//			Statistics.addRecord(recordType, content+"$"+category);
//		}		
//		if (Config.isDEGUG) {
//			String message = recordType + ": " + content+"$"+category;
//			WToast toast = new WToast(context);
//			toast.showMessage(message);
//		}
//	}
	
	/**
	 * 开启统计平台
	 * 
	 * @param context
	 */
	public static void beginRecord(Context context) {
		Statistics.ready(context).start();
//				.appendSoftId(STATISTICS_SOFT_ID)
//				.appendIp()
//				.appendMacAddress()
	}
	
	/**
	 * Check if this start action is triggered after last starting more than 30 seconds
	 * if yes return true and save current time to preference, otherwise return false
	 * @return
	 */
	public static boolean isValidStart(Context ctx) {
		
		long lastStartTime = PreferenceManager.getDefaultSharedPreferences(ctx).getLong("lastStartTime", 0);
		long currentTime = System.currentTimeMillis();
		
		// 如果当前时间小于上次启动时间，说明用户调整了手机时间，我们需要记录最新的时间，否则可能导致永远不能发送启动统计。
		if (currentTime < lastStartTime || currentTime - lastStartTime > START_INTERVAL) {
			PreferenceManager.getDefaultSharedPreferences(ctx).edit().putLong("lastStartTime", currentTime).commit();
			return true;
		}
		return false;
	}
	
}
