package com.qad.system.receiver;

import java.util.LinkedList;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import com.qad.app.BaseBroadcastReceiver;
import com.qad.system.listener.NetworkListener;

/**
 * FIXME Issue:当程序首次启动的时候,都将触发一次网络环境改变
 * @author 13leaf
 *
 */
public class NetworkReceiver extends BaseBroadcastReceiver {
	
	private LinkedList<NetworkListener> listeners=new LinkedList<NetworkListener>();
	
	/**
	 * FIXME 这里的注册也许会有缺陷，详情请见:
	 * Issue:经过p1000测试,在wifi断开网络连接的时候的确会有问题
	 * http://stackoverflow.com/questions/5276032/connectivity-action-intent-recieved-twice-when-wifi-connected?answertab=active#tab-top
	 */
	@Override
	public IntentFilter getIntentFilter() {
		IntentFilter intentFilter=new IntentFilter();
		intentFilter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
		return intentFilter;
	}
	
	public void addNetworkListener(NetworkListener listener)
	{
		if(!listeners.contains(listener))
			listeners.add(listener);
	}
	
	public void removeNetworkListener(NetworkListener listener)
	{
		listeners.remove(listener);
	}


	@Override
	public void onReceive(Context context, Intent intent) {
		NetworkInfo affectedNetworkInfo=
				intent.getParcelableExtra(ConnectivityManager.EXTRA_NETWORK_INFO);
		boolean disconnect=!affectedNetworkInfo.isConnected();
		if(disconnect){
			for(NetworkListener listener:listeners)
				listener.onDisconnected(affectedNetworkInfo);
		}else{
			if(affectedNetworkInfo.getType()==ConnectivityManager.TYPE_WIFI){
				for(NetworkListener listener:listeners)
					listener.onWifiConnected(affectedNetworkInfo);
			}else if(affectedNetworkInfo.getType()==ConnectivityManager.TYPE_MOBILE){
				for(NetworkListener listener:listeners)
					listener.onMobileConnected(affectedNetworkInfo);
			}
		}
	}
}
