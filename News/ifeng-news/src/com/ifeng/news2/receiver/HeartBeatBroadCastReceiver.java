package com.ifeng.news2.receiver;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import com.ifeng.news2.commons.statistic.Statistics;
import com.ifeng.news2.util.StatisticUtil;


public class HeartBeatBroadCastReceiver extends BroadcastReceiver {

	private static final String REQUEST_ACTION = "com.ifeng.news2.action.HEART_BEAT";
	private static final int REQUEST_CODE = 0xfedcba << 1;
	private long lastTime = 0;
	private long interval = 2 * 60 * 60 * 1000L;

	// TODO Fix interval
	@Override
	public void onReceive(Context context, Intent intent) {
		SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(context);
		lastTime = sp.getLong("lastTime", 0);
//		long interval = 2 * 60 * 1000L;
		EmptyIntent emptyIntent = new EmptyIntent(REQUEST_ACTION);
		PendingIntent pendingIntent = PendingIntent.getBroadcast(context, REQUEST_CODE, emptyIntent, 
				PendingIntent.FLAG_NO_CREATE);
		
		if (pendingIntent == null){
			pendingIntent = PendingIntent.getBroadcast(context, REQUEST_CODE, emptyIntent, 
					PendingIntent.FLAG_UPDATE_CURRENT);
		}
		
		try {
			long currentTime = System.currentTimeMillis();
			if((currentTime - lastTime) > 0 &&  (currentTime - lastTime) < interval){
				return;
			}
			String timeStamp = String.valueOf(currentTime);
			if (timeStamp.length() > 4)
				timeStamp = timeStamp.substring(0, timeStamp.length() - 3);
//			Statistics.addRecord("HB", timeStamp);
			StatisticUtil.addRecord(StatisticUtil.StatisticRecordAction.hb, "tm="+timeStamp);
			sp.edit().putLong("lastTime", currentTime).commit();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
		alarmManager.set(AlarmManager.RTC_WAKEUP, System.currentTimeMillis() + interval, pendingIntent);
	}

	private class EmptyIntent extends Intent {
		
		public EmptyIntent(String action) {
			super(action);
		}

		@Override
		public boolean filterEquals(Intent other) {
			if (other.getAction().equals(getAction()))
				return true;
			else return false;
		}
	}
	
}
