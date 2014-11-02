package com.ifeng.news2.receiver;

import java.io.File;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import com.ifeng.news2.Config;

public class OverwriteAppReceiver extends BroadcastReceiver{
	@Override
	public void onReceive(Context context, Intent intent) {   
		try {
			String packageName = intent.getDataString();
			if (packageName!=null && packageName.contains(context.getPackageName()) && intent.getAction().equals(Intent.ACTION_PACKAGE_REMOVED)) {

				File configFile=context.getFileStreamPath(Config.PLUGIN_NAME);
				if(configFile.exists()){
					configFile.delete();
				}
			}
		} catch (Exception e) {
		}
	}
}