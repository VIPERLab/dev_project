package com.qad.system;

import java.lang.ref.WeakReference;
import java.util.LinkedList;

import android.content.BroadcastReceiver;
import android.content.Context;

import com.qad.app.BaseBroadcastReceiver;
import com.qad.system.adapter.BatteryAdapter;
import com.qad.system.adapter.NetWorkAdapter;
import com.qad.system.adapter.SDCardAdapter;
import com.qad.system.listener.BatteryListener;
import com.qad.system.listener.NetworkListener;
import com.qad.system.listener.SDCardListener;
import com.qad.system.receiver.BatteryReceiver;
import com.qad.system.receiver.NetworkReceiver;
import com.qad.system.receiver.SDCardReceiver;

/**
 * 获取手机的状态信息。为避免内存泄露，不应该为context设置成员变量。<br>
 * 需要如下权限:
 * <ol>
 * <li>&lt;uses-permission android:name="android.permission.ACCESS_WIFI_STATE"
 * /></li>
 * <li>&lt;uses-permission android:name="android.permission.READ_PHONE_STATE" />
 * </li>
 * </ol>
 * 
 * @author 13leaf TODO 增加Executor对Activity进行阻塞式通知。避免因状态不正确导致出现问题
 */
public class PhoneManager {

	private SDCardReceiver sdCardReceiver;
	private SDCardAdapter sdCardAdapter = new SDCardAdapter();
	//
	private NetworkReceiver networkReceiver;
	private NetWorkAdapter netWorkAdapter;

	private BatteryReceiver batteryReceiver;
	private BatteryAdapter batteryAdapter = new BatteryAdapter();

	private WeakReference<Context> weakContext;

	private PhoneInfo info;

	private static PhoneManager instance;
	private LinkedList<BaseBroadcastReceiver> managedReceivers = new LinkedList<BaseBroadcastReceiver>();
	//

	public static synchronized PhoneManager getInstance(final Context context) {
		if (instance == null) {
			instance = new PhoneManager(context.getApplicationContext());// ensure for application context
		}
		return instance;
	}

	public static PhoneManager createInstance(final Context context) {
		return new PhoneManager(context);
	}	


	private PhoneManager(Context context) {
		weakContext = new WeakReference<Context>(context);		
		info = new PhoneInfo(context);
		sdCardReceiver = new SDCardReceiver();
		sdCardReceiver.addOnSDCardListener(sdCardAdapter);
		networkReceiver = new NetworkReceiver();
		netWorkAdapter = new NetWorkAdapter(context);
		networkReceiver.addNetworkListener(netWorkAdapter);
		batteryReceiver = new BatteryReceiver();
//		batteryReceiver.addBatteryListener(batteryAdapter);	
	}
	
	public void registerSystemReceiver(){
		Context context = weakContext.get();
		if(context!=null){				
			//registerManagedReceiver(batteryReceiver, context);
			registerManagedReceiver(networkReceiver, context);
			registerManagedReceiver(sdCardReceiver, context);
		}		
	}
	
	private void registerManagedReceiver(BaseBroadcastReceiver receiver,Context context) {
		if (receiver == null || managedReceivers.contains(receiver))
			return;
		managedReceivers.add(receiver);
		context.registerReceiver(receiver, receiver.getIntentFilter());
	}
	
	private void unregisterReceiver(BroadcastReceiver receiver,Context context) {
		int index = managedReceivers.indexOf(receiver);
		if (index != -1)
			context.unregisterReceiver(managedReceivers.remove(index));
	}

	@Override
	public boolean equals(Object o) {
		return super.equals(o);
	}

	@Override
	public int hashCode() {
		return super.hashCode();
	}

	@Override
	public String toString() {
		return super.toString();
	}

	public boolean isSDCardAvailiable() {
		return sdCardAdapter.isSDCardAvailiable();
	}

	public boolean isConnectedNetwork() {
		return netWorkAdapter.isConnectedNetwork();
	}

	public boolean isConnectedWifi() {
		return netWorkAdapter.isConnectedWifi();
	}

	public boolean isConnectedMobileNet() {
		return netWorkAdapter.isConnectedMobileNet();
	}

	public void addOnSDCardChangeListioner(SDCardListener listioner) {
		sdCardReceiver.addOnSDCardListener(listioner);
	}

	public void removeSDCardChangeListioner(SDCardListener listioner) {
		sdCardReceiver.removeOnSDCardListener(listioner);
	}

	public void addOnNetWorkChangeListener(NetworkListener listioner) {
		networkReceiver.addNetworkListener(listioner);
	}

	public void removeNetworkChangeListioner(NetworkListener listioner) {
		networkReceiver.removeNetworkListener(listioner);
	}

	public void addOnBatteryChangeListioner(BatteryListener listioner) {
		batteryReceiver.addBatteryListener(listioner);
	}

	public void removeBatteryChangeListioner(BatteryListener listioner) {
		batteryReceiver.removeBatteryListener(listioner);
	}

	/**
	 * 释放与该Context注册的Receiver资源
	 */
	public void destroy() {
		Context context = weakContext.get();
		if (context != null) {
			unregisterReceiver(sdCardReceiver,context);
			unregisterReceiver(networkReceiver,context);
			//unregisterReceiver(batteryReceiver,context);
		}
	}

	public String getImei() {
		return info.getImei();
	}

	public boolean isConnectionFast() {
		return netWorkAdapter.isConnectionFast();
	}

	public final int getBatteryPercent() {
		return batteryAdapter.getBatteryPercent();
	}

	public final int getBatteryStatus() {
		return batteryAdapter.getBatteryStatus();
	}
}
