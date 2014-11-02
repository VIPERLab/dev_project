package com.ifeng.news2.util;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.activity.DetailActivity;
import com.ifeng.news2.activity.VideoDetailActivity;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.DocUnit;

/**
 * 启动activity管理
 * @author pjw
 *
 */
public class ActivityStartManager {
	/**
	 * 根据文章ID启动阅读页,文章不可切换
	 * @param context
	 * @param aid 文章id
	 */
	public static void startDetail(Context context, String aid) {
		ArrayList<String> ids = new ArrayList<String>();
		ids.add(String.format(Config.DETAIL_URL, aid));
		startDetail(context, 0, ids, Channel.NULL, "");
	}
	/**
	 * 根据文章ID集合 和 文章当前位置 启动阅读页,文章之间可切换
	 * @param context
	 * @param position 当前文章位置
	 * @param ids 文章ID集合
	 * @param channel
	 * @param action
	 */
	public static void startDetail(Context context, int position,
			ArrayList<String> ids, Channel channel, String action) {
		startDetail(context, position, ids, null, channel, action);
	}
	/**
	 * 根据已缓存文章 启动阅读页,文章之间可切换
	 * @param context
	 * @param position 当前文章位置
	 * @param ids 文章ID集合
	 * @param docUnits 已缓存文章对象集合
	 * @param channel
	 * @param actionType 启动文章Action来源
	 */
	public static void startDetail(Context context, int position,
			ArrayList<String> ids, ArrayList<DocUnit> docUnits,
			Channel channel, String actionType) {
		Intent intent = new Intent(context, DetailActivity.class);
		intent.setAction(actionType);
		intent.putExtra(ConstantManager.EXTRA_DETAIL_POSITION, position);
		intent.putExtra(ConstantManager.EXTRA_DETAIL_IDS, ids);
		if (ConstantManager.ACTION_FROM_APP.equals(actionType)) {
			IfengNewsApp app = (IfengNewsApp) context.getApplicationContext();
			app.setCurrentDocUnits(docUnits);
		} else if (docUnits != null) {
			intent.putExtra(ConstantManager.EXTRA_DOC_UNITS, docUnits);
		}
		intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
		((Activity)context).startActivity(intent);
		((Activity)context).overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
	}
	
	public static void startDetail(Context context, String id, String thumbnail,String introduction,
			Channel channel, String actionType){
		Intent intent = new Intent(context, DetailActivity.class);
		intent.setAction(actionType);
		intent.putExtra(ConstantManager.EXTRA_DETAIL_ID, id);
		intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
		//将列表缩略图URL传到详情页，用于收藏保存缩略图URL
		intent.putExtra(ConstantManager.THUMBNAIL_URL, thumbnail);
		//将列表描述信息系传导详情页，用于分享
		intent.putExtra(ConstantManager.EXTRA_INTRODUCTION, introduction);
		((Activity)context).startActivity(intent);
		((Activity)context).overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
	}
	
	
	public static void startDetailByAid(Context context, String aid){
		Intent intent = new Intent(context, DetailActivity.class);
		intent.putExtra(ConstantManager.EXTRA_DETAIL_ID, aid);
		intent.putExtra(ConstantManager.EXTRA_CHANNEL, Channel.NULL);
		intent.setAction(ConstantManager.ACTION_SPOER_LIVE);
		((Activity)context).startActivity(intent);
		((Activity)context).overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
	}
	/**
	 * 打开视频正文页
	 */
	public static void startDetail(Context context,String id,String title,Channel channel, String actionType){
		//视频正文页接口需要，返回id最后一位
		String lastOfId = id.substring(id.length()-1);
		Intent intent = new Intent(context, VideoDetailActivity.class);
		intent.setAction(actionType);
		intent.putExtra(ConstantManager.EXTRA_VIDEO_DETAIL_ID, id);
		intent.putExtra(ConstantManager.EXTRA_VIDEO_DETAIL_ID_LAST, lastOfId);
		intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
		intent.putExtra(ConstantManager.EXTRA_VIDEO_DETAIL_TITLE, title);
		((Activity)context).startActivity(intent);
		((Activity)context).overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
	}
	
}
