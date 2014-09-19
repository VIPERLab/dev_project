package cn.kuwo.sing.ui.activities;

import com.nostra13.universalimageloader.core.ImageLoader;

import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.controller.SubSingerListController;
import android.os.Bundle;

public class SubSingerListActivity extends BaseActivity {
	private final String TAG = "SubSingerListActivity";
	private SubSingerListController mController;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.sub_singer_activity);
		mController = new SubSingerListController(this, ImageLoader.getInstance());
	}
}
