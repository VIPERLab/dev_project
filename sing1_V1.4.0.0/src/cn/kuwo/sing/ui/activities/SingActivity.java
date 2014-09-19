/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import android.content.Context;
import android.os.Bundle;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.view.KeyEvent;
import android.view.WindowManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.controller.SingController;

/**
 * 录制
 * 
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2012-11-8, 上午9:28:22, 2012
 *
 * @Author wangming
 *
 */
public class SingActivity extends BaseActivity {
	private final String TAG = "SingActivity";
	private SingController singController;
	private WakeLock mWakeLock;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		setContentView(R.layout.sing_activity);
		singController = new SingController(this);
		PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
		mWakeLock = pm.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK | PowerManager.ON_AFTER_RELEASE, "SingActivity");
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			String str = (String)getIntent().getExtras().getSerializable("action");
			KuwoLog.d(TAG, "str:"+str);
			if(str.equals(MTVBusiness.ACTION_REVIEW)){
				singController.back();
			}else{
				singController.showExitDialog(R.string.sing_exit_tip);
			}
		}
		return super.onKeyDown(keyCode, event);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		mWakeLock.acquire();
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		singController.pause();
		if(mWakeLock != null) {
			mWakeLock.release();
		}
	}
}
