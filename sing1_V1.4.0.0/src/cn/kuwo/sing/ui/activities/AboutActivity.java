package cn.kuwo.sing.ui.activities;

import android.os.Bundle;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.controller.AboutController;

/**
 * 关于页面
 */
public class AboutActivity extends BaseActivity {

	private final String TAG = "AboutActivity";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.about_activity);
		AboutController aboutController = new AboutController(this);
		KuwoLog.i(TAG, "onCreate");
	}
}
