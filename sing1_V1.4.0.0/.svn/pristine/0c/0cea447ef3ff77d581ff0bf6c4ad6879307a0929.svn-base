package cn.kuwo.sing.ui.activities;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.SettingController;

/**
 * 设置页面
 */
public class SettingActivity extends BaseActivity {

	private final String TAG = "SettingActivity";
	private SettingController mController;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.setting_activity);

		mController = new SettingController(this);
		KuwoLog.d(TAG, "onCreate");
	}
	
	@Override
	protected void onResume() {
		if(Config.getPersistence().isLogin) {
			try {
				String uname = null;
				if(Config.getPersistence().user.nickname == null)
					uname = "酷我新人";
				else
					uname = URLDecoder.decode(Config.getPersistence().user.nickname, "utf-8");
				mController.changeLoginState(uname, R.string.logout_title);
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
		}
		super.onResume();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case Constants.LOGIN_REQUEST:
			if(resultCode == Constants.LOGIN_SUCCESS_RESULT) {
				String nickname = data.getStringExtra("nickname");
				if(TextUtils.isEmpty(nickname))
					nickname = data.getStringExtra("uname");
				mController.changeLoginState(nickname, R.string.logout_title);
			}else if(resultCode == Constants.LOGIN_FAIL_RESULT) {
			}
			
			break;

		default:
			break;
		}
	}
}
