package com.ifeng.news2.util;

import android.content.Context;

/**
 * 记录投票和调查结果的工具类
 * 
 * @author SunQuan:
 * @version 创建时间：2013-12-2 上午11:25:31 类说明
 */

public final class RecordUtil {
	
	//调查
	public static final int SURVEY = 0x001;
	//投票
	public static final int VOTE = 0x002;

	private RecordUtil() {
	}
	
	private static String getKeyByType(int type){
		String key = "";
		switch (type) {
		case SURVEY:
			key = "survey";
			break;
		case VOTE:
			key = "vote";
			break;

		default:
			break;
		}
		return key;
	}

	/**
	 * 是否已经投过票
	 * 
	 * @return
	 */
	public static boolean isRecorded(Context context, String id,int type) {
		String key = getKeyByType(type);
		return context.getSharedPreferences(key, Context.MODE_PRIVATE)
				.getBoolean(key + id, false);
	}

	/**
	 * 记录已经投过的票
	 * 
	 * @param context
	 * @param id
	 */
	public static void record(Context context, String id,int type) {
		String key = getKeyByType(type);
		context.getSharedPreferences(key, Context.MODE_PRIVATE).edit()
				.putBoolean(key + id, true).commit();
	}
}
