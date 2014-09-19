/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.CommonController;
import cn.kuwo.sing.controller.SquareActivityController;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2013-4-22, 下午3:06:09, 2013
 *
 * @Author wangming 
 *  
 * @Description 广场活动
 *
 */
public class SquareShowActivity extends BaseActivity {
	private static final String LOG_TAG = "SquareActivityActivity";
	private SquareActivityController mSquareActivityController;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(LOG_TAG, "SquareActivityActivity");
		setContentView(R.layout.square_activity_layout);
		mSquareActivityController = new SquareActivityController(this);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case Constants.SQUARE_ACTIVITY_LOGIN_REQUEST:
			if(resultCode == Constants.LOGIN_SUCCESS_RESULT) {
				mSquareActivityController.onRefreshPage();
			}else if(resultCode == Constants.LOGIN_FAIL_RESULT) {
				
			}else {
				KuwoLog.e(LOG_TAG, "登录结果码错误");
			}
			break;

		default:
			break;
		}
	}
}
