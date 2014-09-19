/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.controller.LiveController;
import android.os.Bundle;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2012-11-1, 下午12:22:46, 2012
 *
 * @Author Administrator
 *
 */
public class LiveActivity extends BaseActivity {
	private final String TAG = "GameActivity";
	private LiveController mController;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.live_activity);
		mController = new LiveController(this);
	}
}
