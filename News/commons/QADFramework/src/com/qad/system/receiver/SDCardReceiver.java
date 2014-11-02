package com.qad.system.receiver;

import java.util.LinkedList;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import com.qad.app.BaseBroadcastReceiver;
import com.qad.system.listener.SDCardListener;

public class SDCardReceiver extends BaseBroadcastReceiver {

	private LinkedList<SDCardListener> listeners=new LinkedList<SDCardListener>();
	

	@Override
	public IntentFilter getIntentFilter() {
        IntentFilter intentFilter = new IntentFilter(Intent.ACTION_MEDIA_MOUNTED);   
        intentFilter.addAction(Intent.ACTION_MEDIA_SCANNER_STARTED);   
        intentFilter.addAction(Intent.ACTION_MEDIA_SCANNER_FINISHED);   
        intentFilter.addAction(Intent.ACTION_MEDIA_REMOVED);   
        intentFilter.addAction(Intent.ACTION_MEDIA_UNMOUNTED);   
        intentFilter.addAction(Intent.ACTION_MEDIA_BAD_REMOVAL);  
        intentFilter.addAction(Intent.ACTION_MEDIA_SHARED);
        intentFilter.addAction(Intent.ACTION_MEDIA_EJECT);
        intentFilter.addDataScheme("file"); 
		return intentFilter;
	}
	
	public void addOnSDCardListener(SDCardListener listener)
	{
		if(!listeners.contains(listener))
			listeners.add(listener);
	}
	
	public void removeOnSDCardListener(SDCardListener listener)
	{
		listeners.remove(listener);
	}

	/**
	 * 在P1000上连接USB模式发生的广播顺序为:
	 * Eject->Unmounted->Shared
	 * 移除USB模式时广播顺序为:
	 * UnMounted->Mounted->Scanner_Started->Scanner_Finished
	 * FIXME 移除USB模式时不应当相应UnMounted广播
	 */
	@Override
	public void onReceive(Context context, Intent intent) {
		String action=intent.getAction();
		if(action.equals(Intent.ACTION_MEDIA_SCANNER_FINISHED))
		{
			for(SDCardListener listener:listeners)
				listener.onSDCardMounted();
		}else if(action.equals(Intent.ACTION_MEDIA_SHARED) || action.equals(Intent.ACTION_MEDIA_REMOVED))
		{
			//被USB共享或者被拔出
			for(SDCardListener listener:listeners)
				listener.onSDCardRemoved();
		}
	}

}
