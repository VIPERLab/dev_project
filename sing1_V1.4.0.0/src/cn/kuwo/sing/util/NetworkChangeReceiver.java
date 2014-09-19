package cn.kuwo.sing.util;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;
import android.widget.Toast;

public class NetworkChangeReceiver extends BroadcastReceiver {
	private static final String TAG = "NetworkChangeReceiver";
	private static int sLastNetworkType = -1;

	@Override
	public void onReceive(Context context, Intent intent) {
		String action = intent.getAction();
		Log.i(TAG, "网络状态改变action="+action+", sLastNetworkType="+sLastNetworkType);
		ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo activeInfo = cm.getActiveNetworkInfo();
		if(activeInfo != null && activeInfo.isAvailable()) {
			int networkType = activeInfo.getType();
			if(networkType != sLastNetworkType) {
				//说明网络切换了
				if(activeInfo.isConnected()) {
					String typeName = activeInfo.getTypeName();
					Log.i(TAG, "new connection was create, type="+typeName+",status="+activeInfo.getDetailedState());
				}
				sLastNetworkType = networkType;
			}
		}else {
			Log.i(TAG, "无网络连接");
			Toast.makeText(context, "连接失败,请检查您的网络", 0).show();
		}
	}

}
