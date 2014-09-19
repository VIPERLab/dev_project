/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.ShareSettingController;
import cn.kuwo.sing.logic.UserLogic;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2012-12-20, 上午11:11:06, 2012
 *
 * @Author wangming
 *
 */
public class ShareSettingActivity extends BaseActivity {
	private final String TAG = "ShareSettingActivity";
	private ShareSettingController mShareSettingController;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.share_setting_layout);
		mShareSettingController = new ShareSettingController(this);
		if(Config.getPersistence().user.isBindWeibo) {
			try {
				String uname = URLDecoder.decode(Config.getPersistence().user.weiboName, "utf-8");
				mShareSettingController.changeWeiboBindState(uname, "注销");
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
		}
		if(Config.getPersistence().user.isBindQQ) {
			try {
				String uname = URLDecoder.decode(Config.getPersistence().user.qqName, "utf-8");
				mShareSettingController.changeQQBindState(uname, "注销");
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
		}
		if(Config.getPersistence().user.isBindRenren) {
			try {
				String uname = URLDecoder.decode(Config.getPersistence().user.renrenName, "utf-8");
				mShareSettingController.changeRenrenBindState(uname, "注销");
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
		}
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case Constants.SHARE_BOUND_REQUEST:
			if(data != null) {
				String resultFlag = data.getStringExtra("resultFlag");
				String thirdName = data.getStringExtra("thirdName");
				if(resultCode == Constants.SHARE_BOUND_SUCCESS_RESULT) {
					if(resultFlag.equals("weibo")) {
						mShareSettingController.changeWeiboBindState(thirdName, "注销");
					}else if(resultFlag.equals("qq")) {
						mShareSettingController.changeQQBindState(thirdName, "注销");
					}else if(resultFlag.equals("renren")) {
						mShareSettingController.changeRenrenBindState(thirdName, "注销");
					}
				}else if(resultCode == Constants.LOGIN_FAIL_RESULT) {
					Toast.makeText(this, "绑定失败"+resultFlag, 0).show();
				}
			}
			break;
		default:
			break;
		}
	}
}
