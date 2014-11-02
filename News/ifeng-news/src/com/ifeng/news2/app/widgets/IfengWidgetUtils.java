package com.ifeng.news2.app.widgets;

import java.util.Iterator;
import java.util.List;

import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.widget.RemoteViews;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.bean.ListUnits;
import com.ifeng.news2.util.ParamsManager;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;

/**
 * widget的工具类
 * @author chenxi
 *
 */
public class IfengWidgetUtils {

	/**
	 * 设置widget的每个按钮的action
	 * @param context
	 * @param remoteViews
	 * @param appWidgetBtnIds
	 * @param appWidgetActions
	 * @param paramClass
	 */
	public static void setWidgetView(Context context, RemoteViews remoteViews,
			int[] appWidgetBtnIds, String[] appWidgetActions, Class paramClass) {
		// TODO Auto-generated method stub
		ComponentName localComponentName = new ComponentName(context,
				paramClass);
		for (int i = 0; i < appWidgetActions.length; i++) {
			Intent localIntent = new Intent(appWidgetActions[i]);
			localIntent.setComponent(localComponentName);
			PendingIntent localPendingIntent = PendingIntent.getService(
					context, 0, localIntent, PendingIntent.FLAG_UPDATE_CURRENT);

			remoteViews.setOnClickPendingIntent(appWidgetBtnIds[i],
					localPendingIntent);
		}
	}

	/**
	 * 设置widget的具体几个按钮的action
	 * @param context
	 * @param remoteViews
	 * @param appWidgetBtnIds
	 * @param appWidgetActions
	 * @param paramClass
	 */
	public static void setWidgetView(Context context, RemoteViews remoteViews,
			String[] appWidgetActions, Class paramClass) {
		// TODO Auto-generated method stub
		ComponentName localComponentName = new ComponentName(context,
				paramClass);

		Intent localIntent1 = new Intent(appWidgetActions[0]);
		localIntent1.setComponent(localComponentName);
		remoteViews.setOnClickPendingIntent(R.id.pre_btn,
				PendingIntent.getService(context, 0, localIntent1, 0));

		Intent localIntent2 = new Intent(appWidgetActions[1]);
		localIntent2.setComponent(localComponentName);
		remoteViews.setOnClickPendingIntent(R.id.next_btn,
				PendingIntent.getService(context, 0, localIntent2, 0));
		Intent localIntent3 = new Intent(appWidgetActions[2]);

		localIntent3.setComponent(localComponentName);
		remoteViews.setOnClickPendingIntent(R.id.widget_refresh_btn,
				PendingIntent.getService(context, 0, localIntent3, 0));
	}

	/**
	 * 获取widget所需要的数据
	 * @param context
	 * @param target
	 */
	public static void getWidgetDatas(Context context,
			LoadListener<ListUnits> target,String dataUrl) {
		String param = null;

		param = ParamsManager.addParams(context,dataUrl);

		IfengNewsApp.getBeanLoader().startLoading(
				new LoadContext<String, LoadListener<ListUnits>, ListUnits>(
						param, target, ListUnits.class, Parsers
								.newListUnitsParser(),
						LoadContext.FLAG_HTTP_FIRST, true));

	}

	/**
	 * 过滤数据
	 * @param items
	 */
	public static void filerInvalidItems(List<ListItem> items) {
		Iterator<ListItem> iterator = items.iterator();
		while (iterator.hasNext()) {
			String title = iterator.next().getTitle();
			
			if (TextUtils.isEmpty(title)) {
				iterator.remove();
			}
		}
	}

}
