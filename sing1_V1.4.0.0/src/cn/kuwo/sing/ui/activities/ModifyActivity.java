package cn.kuwo.sing.ui.activities;

import android.os.Bundle;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.controller.ModifyController;

/**
 * 修改资料页面
 * 
 * @author wangming
 * 
 */
public class ModifyActivity extends BaseActivity {

	private final String TAG = "ModifyActivity";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.modify_activity);
		ModifyController modifyController = new ModifyController(this);
		KuwoLog.i(TAG, "onCreate");
	}
}
