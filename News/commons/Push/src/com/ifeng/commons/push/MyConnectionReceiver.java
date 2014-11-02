package com.ifeng.commons.push;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

public class MyConnectionReceiver extends BroadcastReceiver{
	
	@Override
	public void onReceive(Context context, Intent intent) {
		ConnectivityManager manager=
				(ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info=manager.getActiveNetworkInfo();
		if(info==null || !info.isConnected())
		{
			Utils.LogReceiver("StopServer cause offline");
			context.stopService(Utils.getPushIntent());
		}else {
			Utils.LogReceiver("Restart Server cause reconnect net");
			Utils.ensurePushService(context);
		}
	}
}
