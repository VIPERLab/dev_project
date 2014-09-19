/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.LocalController;
import cn.kuwo.sing.controller.PostProcessedController;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2012-11-1, 下午12:24:18, 2012
 *
 * @Author wangming
 *
 */
public class LocalActivity extends BaseActivity {
	private final String TAG = "LocalActivity";
	private LocalController mLocalController;
	private LocalBroadcastReciver receiver;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.local_activity);
		mLocalController = new LocalController(this);
		receiver = new LocalBroadcastReciver();
		IntentFilter intentFilter = new IntentFilter();
	    intentFilter.addAction("cn.kuwo.sing.user.change");
	    registerReceiver(receiver, intentFilter);
	}
	
	private class LocalBroadcastReciver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			if(action.equals("cn.kuwo.sing.user.change")) {
				KuwoLog.i(TAG, "LocalBroadcastReciver receiver");
				if(!Config.getPersistence().isLogin) {
					mLocalController.loadNotLoginView();
				}else {
					mLocalController.loadLoginView();
				}
			}
		}
		
	}
	
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case Constants.LOGIN_REQUEST:
			if(resultCode == Constants.LOGIN_SUCCESS_RESULT) {
				mLocalController.loadLoginView();
			}
			break;
		case Constants.LOCAL_EDITINFO_REQUEST:
			mLocalController.reload();
			break;
		case PostProcessedController.CAPTURE_REQUESTCODE:	// 拍照回调
			if(data != null) {
				if (data.getExtras() != null) {
					Bitmap bitmap = (Bitmap) data.getExtras().get("data");
					mLocalController.addCapturePicture(bitmap);
				} else {
					Uri uri = data.getData();
					if(uri != null) {
						mLocalController.addMediaPicture(uri);
					}
				}
			}
			mLocalController.dimissImgSetDialog();
			break;
		case PostProcessedController.MEDIA_REQUESTCODE:		// 本地选取回调
			if(data != null) {
				Uri uri = data.getData();
				mLocalController.addMediaPicture(uri);
			}
			mLocalController.dimissImgSetDialog();
			break;
		}
		super.onActivityResult(requestCode, resultCode, data);
	}
	
	@Override
	protected void onResume() {
		KuwoLog.i(TAG, "onResume");
		if(Config.getPersistence().isLogin) {
			if(Config.getPersistence().user.noticeNumber != 0) {
				mLocalController.setNoticeViewVisible();
			}else {
				mLocalController.setNoticeViewInvisible();
			}
		}
		super.onResume();
	}
	
	@Override
	protected void onRestart() {
		KuwoLog.i(TAG, "onRestart");
		super.onRestart();
	}
	
	@Override
	protected void onDestroy() {
		unregisterReceiver(receiver);
		super.onDestroy();
	}
	
}
