package cn.kuwo.sing.ui.activities;

import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;

/**
 * SD卡未挂载页面
 */
public class NoSdcardActivity extends BaseActivity {

	private final String TAG = "NoSdcardActivity";
	private boolean mKillProcess = true;

	private BroadcastReceiver mSdcardReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			if (Intent.ACTION_MEDIA_MOUNTED.equals(action)) {
				startActivity(new Intent(NoSdcardActivity.this, EntryActivity.class));
				mKillProcess = false;
				finish();
			}
		}
	};


	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.sdcard_watcher);

		KuwoLog.d(TAG, "onCreate");
	}

	@Override
	protected void onResume() {
		super.onResume();

		IntentFilter intentFilter = new IntentFilter(Intent.ACTION_MEDIA_MOUNTED);
		intentFilter.addAction(Intent.ACTION_MEDIA_MOUNTED);
		intentFilter.addDataScheme("file");
		registerReceiver(mSdcardReceiver, intentFilter);
	}

	@Override
	protected void onPause() {
		super.onPause();
		unregisterReceiver(mSdcardReceiver);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		if (mKillProcess)
			android.os.Process.killProcess(android.os.Process.myPid());
	}
}
