package com.ifeng.commons.push.test;

import com.qad.app.BaseApplication;

public class PushApp extends BaseApplication{
//	private class TestReceiver extends BaseBroadcastReceiver
//	{
//		@Override
//		public IntentFilter getIntentFilter() {
//			IntentFilter filter=new IntentFilter();
//			filter.addAction(PushService.ACTION_BASE+"IfengNews2_android_v2");
//			return filter;
//		}
//
//		@Override
//		public void onReceive(Context context, Intent intent) {
//			showMessage("alive");
//		}
//	}
	
	@Override
	public void onCreate() {
		super.onCreate();
//		TestReceiver receiver=new TestReceiver();
//		registerReceiver(receiver, receiver.getIntentFilter());
	}
}
