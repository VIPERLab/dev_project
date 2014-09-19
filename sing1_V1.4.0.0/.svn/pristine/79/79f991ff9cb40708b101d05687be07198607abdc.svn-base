/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import com.nostra13.universalimageloader.core.ImageLoader;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.view.MenuItem;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.SongController;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2012-11-1, 下午12:23:02, 2012
 *
 *
 * @Author wangming
 *
 */
public class SongActivity extends BaseActivity {
	private final String TAG = "SongActivity";
	private SongController mSongController;
	private OrderChangeBroadcastReceiver receiver;
	private UserChangeBroadcastReciver user_receiver;
	private JumpToRecordedPageFromMainReceiver jumpToRecordedReceiver;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.song_activity);
		mSongController = new SongController(this, ImageLoader.getInstance());
//		receiver = new OrderChangeBroadcastReceiver();
//		user_receiver = new UserChangeBroadcastReciver();
//		IntentFilter filter = new IntentFilter();
//		filter.addAction("cn.kuwo.sing.order.change");
//		registerReceiver(receiver, filter);
//		IntentFilter userFilter = new IntentFilter();
//		userFilter.addAction("cn.kuwo.sing.user.change");
//		registerReceiver(user_receiver, userFilter);
//		jumpToRecordedReceiver = new JumpToRecordedPageFromMainReceiver();
//		IntentFilter jumpRecordFilter = new IntentFilter();
//		jumpRecordFilter.addAction("cn.kuwo.sing.jump.songpage.frommain");
//		registerReceiver(jumpToRecordedReceiver, jumpRecordFilter);
	}
	
	private class OrderChangeBroadcastReceiver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
//			String action = intent.getAction();
//			if(action != null && action.equals("cn.kuwo.sing.order.change")) {
//				mSongController.startLoadOrderSongThread();
//			}
		}
		
	}
	
	private class JumpToRecordedPageFromMainReceiver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			if(action != null && action.equals("cn.kuwo.sing.jump.songpage.frommain")) {
				//mSongController.jumpToRecordedPage();
			}
		}
	}
	
	private class UserChangeBroadcastReciver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			if(action != null && action.equals("cn.kuwo.sing.user.change")) {
				//mSongController.reloadRecordList();
			}
		}
		
	}

	@Override
	public void onBackPressed() {
		mSongController.clearDisplayedImages();
		super.onBackPressed();
	}

	@Override
	protected void onResume() {
		KuwoLog.i(TAG, "onResume");
		super.onResume();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case Constants.REQUEST_UPLOAD:
			if(resultCode == Constants.RESULT_UPLOAD_SUCCESS) {
				KuwoLog.i(TAG, "upload success, hasUpload=true");
				//mSongController.loadRecordSongView();
			}
			break;
		case Constants.REQUEST_PLAY_LOCAL_KGE:
			if(resultCode == Constants.RESULT_RELOAD_RECORDED_KGE) {
				KuwoLog.i(TAG, "RELOAD_RECORDED_KGE");
				//mSongController.loadRecordSongView();
			}
			break;

		default:
			break;
		}
	}
	
	@Override
	protected void onDestroy() {
		unregisterReceiver(receiver);
		unregisterReceiver(user_receiver);
		unregisterReceiver(jumpToRecordedReceiver);
		super.onDestroy();
	}
}
