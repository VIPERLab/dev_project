package cn.kuwo.sing.ui.activities;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.controller.LocalMainController;

/**
 * 我的主页页面
 * 
 * @author wangming
 * 
 */
public class LocalMainActivity extends BaseActivity {

	private final String TAG = "LocalMainActivity";
	private LocalMainController localMainController;
	private LocalMainBroadcastReciver receiver;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.local_main_activity);

		localMainController = new LocalMainController(this);
		receiver = new LocalMainBroadcastReciver();
		IntentFilter intentFilter = new IntentFilter();
	    intentFilter.addAction("cn.kuwo.sing.user.change");
	    registerReceiver(receiver, intentFilter);
		KuwoLog.i(TAG, "onCreate");
	}
	
	private class LocalMainBroadcastReciver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			if(action.equals("cn.kuwo.sing.user.change")) {
				KuwoLog.i(TAG, "LocalBroadcastReciver receiver");
				if(Config.getPersistence().isLogin) {
					localMainController.reloadOtherHome();
				}
			}
		}
		
	}
	
	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		//刷新我的页面，防止切换帐号引发错误
		super.onRestart();
	}
	
	@Override
	protected void onResume() {
		KuwoLog.i(TAG, "onResume");
		super.onResume();
	}
	
	@Override
	protected void onDestroy() {
		unregisterReceiver(receiver);
		super.onDestroy();
	}
}
