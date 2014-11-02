package com.ifeng.news2.receiver;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import com.ifeng.news2.IfengNewsApp;
import com.qad.app.BaseBroadcastReceiver;

public class ScreenOffReceiver extends BaseBroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent) {
		IfengNewsApp.lockTime = System.currentTimeMillis();
	}

	@Override
	public IntentFilter getIntentFilter() {
		IntentFilter filter = new IntentFilter();
		filter.addAction(Intent.ACTION_SCREEN_OFF); 
        filter.setPriority(Integer.MAX_VALUE); 
		return filter;
	}

}
