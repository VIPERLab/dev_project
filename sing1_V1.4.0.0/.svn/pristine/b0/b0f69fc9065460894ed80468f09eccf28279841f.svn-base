package cn.kuwo.sing.ui.activities;

import com.nostra13.universalimageloader.core.ImageLoader;

import android.os.Bundle;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.controller.SingerListController;

public class SingerListActivity extends BaseActivity {
	private final String TAG = "SingerListActivity";
	private SingerListController mController;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.singer_list_activity);
		mController = new SingerListController(this, ImageLoader.getInstance());
	}
	
	@Override
	public void onBackPressed() {
		mController.clearDisplayedImages();
		super.onBackPressed();
	}
}
