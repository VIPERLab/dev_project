/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.DynamicController;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2012-12-27, 上午10:27:59, 2012
 *
 * @Author wangming
 *
 */
public class DynamicActivity extends BaseActivity {
	private final String TAG = "DynamicActivity";
	private DynamicController mDynamicController;
	private DynamicBroadcastReceiver receiver;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.dynamic_layout);
		mDynamicController = new DynamicController(this);
		receiver = new DynamicBroadcastReceiver();
		IntentFilter intentFilter = new IntentFilter();
	    intentFilter.addAction("cn.kuwo.sing.user.change");
	    registerReceiver(receiver, intentFilter);
	}
	
	private class DynamicBroadcastReceiver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			if(action.equals("cn.kuwo.sing.user.change")) {
				KuwoLog.i(TAG, "DynamicBroadcastReciver  receive");
				if(!Config.getPersistence().isLogin) {
					mDynamicController.loadNotLoginView();
				}else {
					mDynamicController.loadLoginView();
				}
			}
		}
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case Constants.LOGIN_REQUEST:
			if(resultCode == Constants.LOGIN_SUCCESS_RESULT) {
				mDynamicController.loadLoginView();
			}
			break;
		default:
			break;
		}
	}
	
	@Override
	protected void onDestroy() {
		unregisterReceiver(receiver);
		super.onDestroy();
	}
	
}
