package com.ifeng.news2.sport_live.util;

import com.ifeng.news2.Config;
import com.ifeng.news2.advertise.AdDetailActivity;
import com.ifeng.news2.sport_live.PoisonousWordsActivity;
import com.ifeng.news2.sport_live.SportReportActivity;
import com.ifeng.news2.util.ConstantManager;

import android.content.Context;
import android.content.Intent;

/**
 * 体育直播页跳转页面工具类
 * 
 * @author SunQuan:
 * @version 创建时间：2013-7-30 下午2:55:49
 * 
 */

public class SportRedirectUtil {

	

	// 跳转到数据页
	public static final int GOTO_DATA_PAGE = 0x0000;
	// 跳转到战报页
	public static final int GOTO_REPORT_PAGE = 0x0001;
	// 跳转到毒舌页
	public static final int GOTO_POISONOUS_PAGE = 0x0002;

	/**
	 * 直播页跳转到其他页面
	 * 
	 * @param context
	 * @param type
	 *            跳转的目标页类型
	 * @param mt
	 *            比赛id
	 */
	public static void redirect(Context context, int type, String mt) {
		Intent intent = new Intent();
		switch (type) {
		case GOTO_DATA_PAGE:
			intent.setClass(context, AdDetailActivity.class);
			intent.putExtra("URL", Config.DATA_PAGE_URL + "?mt=" + mt + "&team=v");
			intent.setAction(ConstantManager.ACTION_SPOER_LIVE);
			break;
		case GOTO_REPORT_PAGE:
			intent.setClass(context, SportReportActivity.class);
			intent.putExtra("URL", Config.REPORT_PAGE_URL + "&mt=" + mt);
			break;
		case GOTO_POISONOUS_PAGE:
			intent.setClass(context, PoisonousWordsActivity.class);
			intent.putExtra("URL", Config.POISONOUS_URL + "&mt=" + mt);
			break;
		default:
			break;
		}
		context.startActivity(intent);
	}
}
