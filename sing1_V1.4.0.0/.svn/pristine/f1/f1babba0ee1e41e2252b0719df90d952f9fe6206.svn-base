package cn.kuwo.sing.ui.activities;

import android.os.Bundle;
import android.view.KeyEvent;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.controller.SongSubListController;

public class SongSubListActivity extends BaseActivity {
	private final String TAG = "SongSubListActivity";
	private SongSubListController mController;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.song_list_layout);
		mController = new SongSubListController(this);
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			mController.resetAppParamsFromKwPlayer();
		}
		return super.onKeyDown(keyCode, event);
	}
	
	@Override
	protected void onDestroy() {
		KuwoLog.v(TAG, "onDestroy");
		super.onDestroy();
	}
}
