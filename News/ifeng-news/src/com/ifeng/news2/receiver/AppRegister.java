package com.ifeng.news2.receiver;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.ifeng.news2.Config;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

public class AppRegister extends BroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent) {
		final IWXAPI api = WXAPIFactory.createWXAPI(context, Config.WX_APP_ID,false);

		// 将app注册到微信
		api.registerApp(Config.WX_APP_ID);
		
		Log.d("AppRegister", "register wt");
	}
}
