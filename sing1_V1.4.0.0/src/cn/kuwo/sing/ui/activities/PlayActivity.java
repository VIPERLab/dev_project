package cn.kuwo.sing.ui.activities;

import com.tencent.mm.sdk.openapi.BaseReq;
import com.tencent.mm.sdk.openapi.BaseResp;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.view.KeyEvent;
import android.widget.Toast;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.PlayController;

/**
 * 播放他人作品页面
 */
public class PlayActivity extends BaseActivity {

	private final String TAG = "PlayActivity";
	private PlayController playController;
	private WakeLock mWakeLock;
	private PlayBroadcastReceiver playReceiver;
	private CommentBroadcastReceiver commentReceiver;
	private IWXAPI mWXApi;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.d(TAG, "onCreate");
		setContentView(R.layout.play_activity);
		commentReceiver = new CommentBroadcastReceiver();
		playReceiver = new PlayBroadcastReceiver();
		registerReceiver(commentReceiver, new IntentFilter("cn.kuwo.sing.comment.update"));
		
		IntentFilter filter = new IntentFilter();
		filter.addAction("cn.kuwo.sing.action.pause");
		filter.addAction(Intent.ACTION_CLOSE_SYSTEM_DIALOGS);
		registerReceiver(playReceiver, filter);
		
		
		PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
		mWakeLock = pm.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK | PowerManager.ON_AFTER_RELEASE, "PlayActivity");
		regWX();
		playController = new PlayController(this, mWXApi);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case Constants.REQUEST_UPLOAD:
			if(resultCode == Constants.RESULT_UPLOAD_SUCCESS) {
				KuwoLog.i(TAG, "upload success, hasUpload=true");
				playController.setUploadButtonDark();
			}
			break;

		default:
			break;
		}
	}
	
	private void regWX() {
		//注册到微信
		mWXApi = WXAPIFactory.createWXAPI(this, Constants.WEIXIN_APP_ID, false);
		mWXApi.registerApp(Constants.WEIXIN_APP_ID);
	}
	
	private class CommentBroadcastReceiver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			KuwoLog.i(TAG, "comment change!");
			if(playController.mMTV != null) {
				playController.mInteractController.addCommentCount();
			}
		}
		
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		mWakeLock.acquire();
		KuwoLog.d(TAG, "onResume");
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			if(playController.mInteractController.shareDialogShowing) {
				playController.mInteractController.dimissShareSelectDialog();
				return true;
			}
			// 停止播放
			playController.release();
			setResult(Constants.RESULT_RELOAD_RECORDED_KGE);
			finish();
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}

	@Override
	protected void onPause() {
		super.onPause();
		if(mWakeLock != null) {
			mWakeLock.release();
		}
	}
	
	@Override
	protected void onStop() {
		super.onStop();
	}
	
	@Override
	protected void onDestroy() {
		unregisterReceiver(commentReceiver);
		unregisterReceiver(playReceiver);
		playController.release();
		super.onDestroy();
	}
	
	public class PlayBroadcastReceiver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			String id = intent.getStringExtra("id");
			if (!PlayActivity.this.toString().equals(id)) {
				playController.viewPause();
				KuwoLog.d("PlayBroadcastReceiver", "onReceive");
			}
		}

	}
}


