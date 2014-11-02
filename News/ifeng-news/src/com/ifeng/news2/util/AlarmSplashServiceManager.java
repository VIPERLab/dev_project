package com.ifeng.news2.util;

import java.util.Date;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.ifeng.news2.Config;
import com.ifeng.news2.receiver.SplashBroadcastReceiver;
import com.ifeng.news2.service.SplashService;



public class AlarmSplashServiceManager {
	
	public static AlarmManager manager = null;
	public static PendingIntent pendingIntent = null;
	public static String CLEAN_SPLASH_IDS_ACTION = "action.com.ifeng.news.util.CLEAN_SPLASH_IDS";
	
	public static void setUpAlarm(Context context) {
		Log.e("tag", "setUpAlarm");
		Intent pullIntent = new Intent();
		pullIntent.setClass(context, SplashService.class);
		pendingIntent = PendingIntent.getService(context, 0, 
				pullIntent, PendingIntent.FLAG_CANCEL_CURRENT);
		manager = (AlarmManager) context
				.getSystemService(Context.ALARM_SERVICE);
		manager.set(AlarmManager.RTC_WAKEUP,System.currentTimeMillis() + Config.START_INTERVAL_TIME, pendingIntent);
	}
	
	public static void stopAlarm(Context context) {
		Log.e("tag", "stop alarm");
		Intent pullIntent = new Intent();
		pullIntent.setClass(context, SplashService.class);
		pendingIntent = PendingIntent.getService(context, 0, 
				pullIntent, PendingIntent.FLAG_CANCEL_CURRENT);
		manager = (AlarmManager) context
				.getSystemService(Context.ALARM_SERVICE);
		manager.cancel(pendingIntent);
	}
	
	public static void setCleanSplashImgAlarm(Context context) {
		Intent pullIntent = new Intent(context, SplashBroadcastReceiver.class);
		pullIntent.setAction(CLEAN_SPLASH_IDS_ACTION);
		pendingIntent = PendingIntent.getBroadcast(context, 0, pullIntent, PendingIntent.FLAG_CANCEL_CURRENT);
		manager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
		long time = System.currentTimeMillis();   
		Date date = new Date(time); 
		int hours = 23 - date.getHours();
		int min = 60 - date.getMinutes();
		manager.setRepeating(AlarmManager.RTC_WAKEUP, time+30*60*1000/*hours*1000*60*60+min*1000*60*/, 1000*60*60*24L, pendingIntent);
	}
}

