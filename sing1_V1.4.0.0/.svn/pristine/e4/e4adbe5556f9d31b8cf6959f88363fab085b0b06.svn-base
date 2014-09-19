package cn.kuwo.sing.ui.activities;

import java.io.IOException;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.widget.Toast;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.LoginController;
import cn.kuwo.sing.logic.UserLogic;

/**
 * 登陆页面
 */
public class LoginActivity extends BaseActivity {

	private final String TAG = "LoginActivity";
	private LoginController mController;
	private ProgressDialog loginPd;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.login_activity);
		mController = new LoginController(this);
		KuwoLog.i(TAG, "onCreate");
	}
	
	private Handler loginHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				if(loginPd != null) {
					loginPd.dismiss();
					loginPd = null;
				}
				int result = msg.arg1;
				Intent data = new Intent();
				String nickname= Config.getPersistence().user.nickname;
				data.putExtra("nickname", nickname);
				if(result == 0) {
					Intent intent = new Intent();
					intent.setAction("cn.kuwo.sing.user.change");
					sendBroadcast(intent);
					Toast.makeText(LoginActivity.this, "登录成功", 0).show();
					setResult(Constants.LOGIN_SUCCESS_RESULT, data);
					finish();
				}else {
					Toast.makeText(LoginActivity.this, "登录失败", 0).show();
				}
				break;

			default:
				break;
			}
			super.handleMessage(msg);
		}
		
	};
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case Constants.THIRD_LOGIN_REQUEST:
			if(resultCode == Constants.THIRD_LOGIN_SUCCESS_RESULT) {
				setResult(Constants.LOGIN_SUCCESS_RESULT, data);
				finish();
			}else if(resultCode == Constants.LOGIN_FAIL_RESULT) {
			}
			break;
		case 54:
			setResult(55);
			finish();
			break;
		case Constants.REGISTER_REQUEST:
			if(resultCode == Constants.REGISTER_SUCCESS_RESULT) {
				//注册成功后，进行自动登录
				KuwoLog.i(TAG, "注册成功后，进行自动登录,注册成功后，进行自动登录");
				final UserLogic userLogic = new UserLogic();
					final String uname = Config.getPersistence().user.uname;
					final String pwd = Config.getPersistence().user.psw;
					if(loginPd == null) {
						loginPd = new ProgressDialog(LoginActivity.this);
						loginPd.setProgressStyle(ProgressDialog.STYLE_SPINNER);
						loginPd.setCancelable(false);
						loginPd.setCanceledOnTouchOutside(false);
						loginPd.setMessage("正在登录中");
					}
					loginPd.show();
					new Thread(new Runnable() {
						
						@Override
						public void run() {
							int result = -1;
							try {
								result = userLogic.login(uname, pwd);
							} catch (IOException e) {
								e.printStackTrace();
							}
							Message msg = loginHandler.obtainMessage();
							msg.what = 0;
							msg.arg1 = result;
							loginHandler.sendMessage(msg);
						}
					}).start();
			}
			break;
		
		default:
			break;
		}
	}
}
