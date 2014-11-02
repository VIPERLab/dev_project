package com.ifeng.news2.app.widgets;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.view.View;
import android.widget.RemoteViews;

import com.ifeng.news2.R;
import com.ifeng.news2.util.StatisticUtil;

/**
 *  WidgetProvider 
 * @author chenxi
 *
 */
public abstract class IfengWidgetProvider extends AppWidgetProvider{

	private int[] appWidgetBtnIds = { R.id.pre_btn , R.id.next_btn, R.id.widget_refresh_btn };
	private static int count = 0 ; 
	
	@Override
	public void onDeleted(Context context, int[] appWidgetIds) {
		// TODO Auto-generated method stub
		
	}
	
	@Override
	public void onEnabled(Context context) {
		// TODO Auto-generated method stub
		//记录用户使用widget发送统计
		if(count == 0){
			StatisticUtil.addRecord(StatisticUtil.StatisticRecordAction.desktop, "op=add");
		}
		count++ ; 
	}
	
	@Override
	public void onReceive(Context context, Intent intent) {
		// TODO Auto-generated method stub
		super.onReceive(context, intent);
	}
	
	@Override
	public void onDisabled(Context context) {
		// TODO Auto-generated method stub
		context.stopService(new Intent(getWidgetServiceAction()));
		//记录用户删除widget发送统计
		if(count > 0 ){
			count-- ; 
			if(count == 0){
				StatisticUtil.addRecord(StatisticUtil.StatisticRecordAction.desktop, "op=del");
			}
		}else if (count < 0){
			count = 0 ;
		}
			
	}
	
	@Override
	public void onUpdate(Context context, AppWidgetManager appWidgetManager,
			int[] appWidgetIds) {
		// TODO Auto-generated method stub
		initWidgetView(context , appWidgetIds);
		context.startService(new Intent(getWidgetServiceAction()));
	}
	
	/**
	 * 初始化widget
	 * @param context
	 * @param appWidgetIds
	 */
	private void initWidgetView(Context context, int[] appWidgetIds) {
		// TODO Auto-generated method stub
		RemoteViews localRemoteViews = new RemoteViews(
				context.getPackageName(), getWidgetLayout());
		localRemoteViews.setViewVisibility(R.id.widget_bottom, View.INVISIBLE);
		localRemoteViews.setViewVisibility(R.id.widget_body_layout, View.INVISIBLE);
		localRemoteViews.setViewVisibility(R.id.widget_loadding, View.VISIBLE);
		
		IfengWidgetUtils.setWidgetView(context, localRemoteViews, this.appWidgetBtnIds, getWidgetActions(),
				getWidgetProviderClass());
		
		updateWidgetView(context, appWidgetIds, localRemoteViews);
		
	}
	
	/**
	 * 更新widget的View
	 * @param context
	 * @param appWidgetIds
	 * @param remoteViews
	 */
	private void updateWidgetView(Context context, int[] appWidgetIds,
			RemoteViews remoteViews) {
		AppWidgetManager appWidgetManager = AppWidgetManager
				.getInstance(context);
		if (appWidgetIds != null) {
			appWidgetManager.updateAppWidget(appWidgetIds,
					remoteViews);
			return;
		}
		
		appWidgetManager.updateAppWidget(new ComponentName(context, getWidgetProviderClass()), remoteViews);
	}
	
	
	
	//获取widget每个按钮触发的action
	public abstract String[] getWidgetActions();
	//获取widget的layout
	public abstract int getWidgetLayout();
	//获取widget所绑定的Provider类
	public abstract Class getWidgetProviderClass();
	//获取widgetservice所绑定的action
	public abstract String  getWidgetServiceAction();
}
