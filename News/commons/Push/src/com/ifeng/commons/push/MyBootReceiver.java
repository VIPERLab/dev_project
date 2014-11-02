package com.ifeng.commons.push;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class MyBootReceiver extends BroadcastReceiver{

	
	@Override
	public void onReceive(Context context, Intent intent) {
		Utils.LogReceiver("Start service by boot");
		Utils.ensurePushService(context);
	}
}
