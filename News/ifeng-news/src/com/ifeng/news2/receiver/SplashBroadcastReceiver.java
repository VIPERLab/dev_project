package com.ifeng.news2.receiver;

import com.ifeng.news2.util.AlarmSplashServiceManager;
import com.ifeng.news2.util.SplashManager;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class SplashBroadcastReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent) {
		String action = intent.getAction();
		if (AlarmSplashServiceManager.CLEAN_SPLASH_IDS_ACTION.equals(action)) {
			new SplashManager().deleteSplashIds();
			AlarmSplashServiceManager.setCleanSplashImgAlarm(context);
		}
	}

}
