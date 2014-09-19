package cn.kuwo.sing.ui.activities;

import android.os.Bundle;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.controller.RegisterController;

/**
 * 注册页面
 */
public class RegisterActivity extends BaseActivity {

	private final String TAG = "RegisterActivity";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.register_activity);
		RegisterController registerController = new RegisterController(this);
		KuwoLog.i(TAG, "onCreate");
	}
}
