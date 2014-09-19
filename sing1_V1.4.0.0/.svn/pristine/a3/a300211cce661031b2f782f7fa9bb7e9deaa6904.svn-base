/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import android.os.Bundle;
import android.view.Window;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.controller.GuideController;


/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2012-10-31, 下午4:23:17, 2012
 *
 * @Author wangming
 *
 */
public class GuideActivity extends BaseActivity {
	private final String TAG = "GuideActivity";
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		KuwoLog.i(TAG, "onCreate");
		requestWindowFeature(Window.FEATURE_NO_TITLE);
//		getWindow().setFlags(WindowManager.LayoutParams. FLAG_FULLSCREEN, WindowManager.LayoutParams. FLAG_FULLSCREEN);
		setContentView(R.layout.guide_activity);
		GuideController guideController = new GuideController(this);
	}
}
