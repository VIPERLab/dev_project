package com.qad.system.receiver;

import java.util.LinkedList;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;

import com.qad.app.BaseBroadcastReceiver;
import com.qad.system.listener.BatteryListener;

public class BatteryReceiver extends BaseBroadcastReceiver {

	private LinkedList<BatteryListener> listeners = new LinkedList<BatteryListener>();
	

	public void addBatteryListener(BatteryListener listener) {
		if (listeners.contains(listener))
			return;
		
		listeners.add(listener);
	}
	
	public void removeBatteryListener(BatteryListener listener) {
		try {
			listeners.remove(listener);
		} catch (UnsupportedOperationException e) {
			
		}
	}
	
	@Override
	public IntentFilter getIntentFilter() {
		IntentFilter filter = new IntentFilter();
		filter.addAction(Intent.ACTION_BATTERY_CHANGED);
		return filter;
	}

	@Override
	public void onReceive(Context context, Intent intent) {
		int scale = intent.getExtras().getInt(BatteryManager.EXTRA_SCALE);
		int level = intent.getExtras().getInt(BatteryManager.EXTRA_LEVEL);
		int status = intent.getExtras().getInt(BatteryManager.EXTRA_STATUS);
		for (BatteryListener listener : listeners) {
			listener.onBatteryPercentChanged(level * 100 / scale);
			listener.onBetteryStatusChanged(status);
		}
	}

}
