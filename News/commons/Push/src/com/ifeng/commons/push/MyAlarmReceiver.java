package com.ifeng.commons.push;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class MyAlarmReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent) {
		if (PushService.ACTION_SET.equals(intent.getAction())) {
			AlarmManager manager = (AlarmManager) context
					.getSystemService(Context.ALARM_SERVICE);
			Intent pullIntent = new Intent(intent);
			pullIntent.setClass(context, PushService.class);
			PendingIntent pendingIntent = PendingIntent.getService(context, 0, pullIntent, PendingIntent.FLAG_CANCEL_CURRENT);
			long timespan=intent.getLongExtra(PushService.EXTRA_TIMER, PushService.INTERVAL);
			manager.set(AlarmManager.RTC_WAKEUP, System.currentTimeMillis()
					+ timespan, pendingIntent);
			String product=pullIntent.getStringExtra(PushService.EXTRA_PRODUCT);
			Utils.LogReceiver("set alarm "+product+" "+timespan);
			Utils.getPerformanceSharedPreferences(context)
				.edit().putInt("set_"+product, Utils.getPerformanceSharedPreferences(context).getInt("set_"+product, 0)+1).commit();
		}
		Utils.ensurePushService(context);//
	}

}
