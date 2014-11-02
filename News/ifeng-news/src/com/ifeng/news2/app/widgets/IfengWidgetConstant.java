package com.ifeng.news2.app.widgets;

import com.ifeng.news2.Config;

/**
 * Widget常量类
 * @author chenxi
 *
 */
public class IfengWidgetConstant {

	public static final String[] APP_WIDGET_ACTION_4X1 = {
			"com.ifeng.news2.activity.intent.action.APP_WIDGET_PREV_4_1",
			"com.ifeng.news2.activity.intent.action.APP_WIDGET_NEXT_4_1",
			"com.ifeng.news2.activity.intent.action.APP_WIDGET_REFRESH_4_1" };
	
	public static final String[] APP_WIDGET_ACTION_4X2 = {
			"com.ifeng.news2.activity.intent.action.APP_WIDGET_PREV_4_2",
			"com.ifeng.news2.activity.intent.action.APP_WIDGET_NEXT_4_2",
			"com.ifeng.news2.activity.intent.action.APP_WIDGET_REFRESH_4_2" };
	
	public static final String[] APP_WIDGET_ACTION_4X3 = {
			"com.ifeng.news2.activity.intent.action.APP_WIDGET_PREV_4_3",
			"com.ifeng.news2.activity.intent.action.APP_WIDGET_NEXT_4_3",
			"com.ifeng.news2.activity.intent.action.APP_WIDGET_REFRESH_4_3" };
	
	public static final String[] APP_WIDGET_ACTION_4X4 = {
			"com.ifeng.news2.activity.intent.action.APP_WIDGET_PREV_4_4",
			"com.ifeng.news2.activity.intent.action.APP_WIDGET_NEXT_4_4",
			"com.ifeng.news2.activity.intent.action.APP_WIDGET_REFRESH_4_4" };

	public static final String APP_WIDGET_SERVICE_4X1 = "com.ifeng.news2.app.widget.service.UPDATE_SERVICE_4_1";
	public static final String APP_WIDGET_SERVICE_4X2 = "com.ifeng.news2.app.widget.service.UPDATE_SERVICE_4_2";
	public static final String APP_WIDGET_SERVICE_4X3 = "com.ifeng.news2.app.widget.service.UPDATE_SERVICE_4_3";
	public static final String APP_WIDGET_SERVICE_4X4 = "com.ifeng.news2.app.widget.service.UPDATE_SERVICE_4_4";
	
	public static final String APP_WIDGET_DATA_URL = Config.CHANNELS[0].getChannelSmallUrl() + "&page=1";
	
}
