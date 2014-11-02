package com.ifeng.news2.yxapi;

import com.ifeng.news2.Config;

import im.yixin.sdk.api.YXAPIBaseBroadcastReceiver;

/**
 * 注册易信接口
 * @author chenxi
 *
 */
public class YXAppRegister extends YXAPIBaseBroadcastReceiver {

	@Override
	protected String getAppId() {
		// TODO Auto-generated method stub
		return Config.YX_APP_ID;
	}
	
}
