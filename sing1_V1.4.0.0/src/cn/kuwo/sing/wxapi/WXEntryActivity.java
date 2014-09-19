/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.wxapi;

import com.tencent.mm.sdk.openapi.BaseReq;
import com.tencent.mm.sdk.openapi.BaseResp;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.content.Intent;
import android.os.Bundle;
import android.view.Window;
import android.widget.Toast;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.ui.activities.BaseActivity;

/**
 * @Package cn.kuwo.sing.wxapi
 *
 * @Date 2013-6-14, 下午4:30:37
 *
 * @Author wangming
 *
 */
public class WXEntryActivity extends BaseActivity implements IWXAPIEventHandler{
	private IWXAPI mWXApi;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE); 		// 隐藏标题栏
		setContentView(R.layout.wx_entry_activity);
		regWX();
	}
	
	private void regWX() {
		//注册到微信
		mWXApi = WXAPIFactory.createWXAPI(this, Constants.WEIXIN_APP_ID, false);
		mWXApi.registerApp(Constants.WEIXIN_APP_ID);
		mWXApi.handleIntent(getIntent(), this);
	}
	
	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
        mWXApi.handleIntent(intent, this);
	}

	@Override
	public void onReq(BaseReq arg0) {
		
	}

	@Override
	public void onResp(BaseResp resp) {
		int result = 0;
		switch (resp.errCode) {
		case BaseResp.ErrCode.ERR_OK:
			result = R.string.errcode_success;
			break;
		case BaseResp.ErrCode.ERR_USER_CANCEL:
			result = R.string.errcode_cancel;
			break;
		case BaseResp.ErrCode.ERR_AUTH_DENIED:
			result = R.string.errcode_deny;
			break;
		default:
			result = R.string.errcode_unknown;
			break;
		}
		finish();
		Toast.makeText(getApplicationContext(), result, Toast.LENGTH_LONG).show();
	}
}
