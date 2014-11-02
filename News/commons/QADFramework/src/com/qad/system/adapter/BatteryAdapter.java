package com.qad.system.adapter;

import android.os.BatteryManager;

import com.qad.system.listener.BatteryListener;

public class BatteryAdapter implements BatteryListener {

	// init fields
	private int percent = 50;
	private int status = BatteryManager.BATTERY_STATUS_UNKNOWN;
	
	public BatteryAdapter() {
		
	}
	
	@Override
	public void onBatteryPercentChanged(int percent) {
		if (percent >= 0 && percent <=100)
			this.percent = percent;
	}

	@Override
	public void onBetteryStatusChanged(int status) {
		if (status >= BatteryManager.BATTERY_STATUS_UNKNOWN
				&& status <= BatteryManager.BATTERY_STATUS_FULL)
			this.status = status;
	}

	public final int getBatteryPercent() {
		return percent;
	}
	
	public final int getBatteryStatus() {
		return status;
	}
}
