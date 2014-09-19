package cn.kuwo.sing.controller;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.umeng.analytics.MobclickAgent;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.config.PreferencesManager;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.RegisterActivity;
import cn.kuwo.sing.ui.activities.ThirdPartyLoginActivity;
import de.greenrobot.event.EventBus;

/**
 * 登录页面控制层
 */
public class LoginController extends BaseController {

	private final String TAG = "LoginController";

	private BaseActivity mActivity;
	/* 账号输入框 */
	private EditText etAccount;
	/* 密码输入框 */
	private EditText etPsw;
	/* 清空输入账号内容 */
	private ImageView imgAccountClear;
	/* 清空输入密码内容 */
	private ImageView imgPswClear;
	private String mFlag;
	private CheckBox login_rem_psw_check;
	private ProgressDialog loginPd = null;
	private TextView login_use_renren;

	public LoginController(BaseActivity activity) {

		KuwoLog.v(TAG, "LoginController()");

		mActivity = activity;

		initView();
	}

	/**
	 * 初始化控件
	 * 
	 * @param activity
	 */
	private void initView() {

		Button btnBack = (Button) mActivity.findViewById(R.id.login_back_btn);
		btnBack.setOnClickListener(mOnClickListener);

		Button btnRegister = (Button) mActivity
				.findViewById(R.id.login_go_register_btn);
		btnRegister.setOnClickListener(mOnClickListener);

		imgAccountClear = (ImageView) mActivity
				.findViewById(R.id.login_account_clear);
		imgAccountClear.setOnClickListener(mOnClickListener);

		imgPswClear = (ImageView) mActivity.findViewById(R.id.login_psw_clear);
		imgPswClear.setOnClickListener(mOnClickListener);

		etAccount = (EditText) mActivity.findViewById(R.id.login_account_input);
		etAccount.addTextChangedListener(mTextWatcher);

		etPsw = (EditText) mActivity.findViewById(R.id.login_psw_input);
		etPsw.addTextChangedListener(mPswTextWatcher);
		
		login_rem_psw_check = (CheckBox) mActivity.findViewById(R.id.login_rem_psw_check);
		// 说明没有清空user
		if (Config.getPersistence().user != null) {
			if (Config.getPersistence().rememberUserInfo) {
				if (Config.getPersistence().user != null) {
					if(PreferencesManager.getBoolean("isThirdLogin")) {
						etAccount.setText("");
						etPsw.setText("");
					}else {
						String uname = Config.getPersistence().lastUname;
						String pwd = Config.getPersistence().lastPwd;
						etAccount.setText(uname);
						etPsw.setText(pwd);
					}
				}
			} else {
				if (Config.getPersistence().user != null) {
					if(PreferencesManager.getBoolean("isThirdLogin")) {
						etAccount.setText("");
					}else {
						String uname = Config.getPersistence().lastUname;
						etAccount.setText(uname);
					}
				}
			}
		}
		login_rem_psw_check.setChecked(true);
		Button btnLogin = (Button) mActivity.findViewById(R.id.login_btn);
		btnLogin.setOnClickListener(mOnClickListener);

		TextView tvRemPswCheck = (TextView) mActivity
				.findViewById(R.id.login_rem_psw);
		tvRemPswCheck.setOnClickListener(mOnClickListener);

		TextView tvUseSina = (TextView) mActivity
				.findViewById(R.id.login_use_sina);
		tvUseSina.setOnClickListener(mOnClickListener);

		TextView tvUseQQ = (TextView) mActivity.findViewById(R.id.login_use_qq);
		tvUseQQ.setOnClickListener(mOnClickListener);
		
		login_use_renren = (TextView) mActivity.findViewById(R.id.login_use_renren);
		login_use_renren.setOnClickListener(mOnClickListener);

		Intent intent = mActivity.getIntent();
		String flag = intent.getStringExtra("flag");
		if ("loginFromLocal".equals(flag)) {
			mFlag = flag;
		}
	}

	public String getLoginFlag() {
		return mFlag;
	}

	/*
	 * 点击事件
	 */
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			int id = v.getId();
			KuwoLog.v(TAG, "onClick " + id);

			switch (id) {
			case R.id.login_back_btn:// 返回按钮
				mActivity.finish();
				break;

			case R.id.login_go_register_btn:// 注册按钮
				Intent registerIntent = new Intent(mActivity,
						RegisterActivity.class);
				mActivity.startActivityForResult(registerIntent,
						Constants.REGISTER_REQUEST);
				break;

			case R.id.login_account_input:// 账号输入
				break;

			case R.id.login_account_clear:// 清除账号按钮
				etAccount.setText("");
				break;

			case R.id.login_psw_clear:// 清除密码按钮
				etPsw.setText("");
				break;

			case R.id.login_psw_input:// 密码输入
				break;

			case R.id.login_rem_psw:// 记住密码
				break;

			case R.id.login_btn:// 登陆按钮
				InputMethodManager imm = (InputMethodManager) mActivity
						.getSystemService(Context.INPUT_METHOD_SERVICE);
				imm.hideSoftInputFromWindow(etPsw.getWindowToken(), 0);
				if (AppContext.getNetworkSensor() != null
						&& !AppContext.getNetworkSensor().hasAvailableNetwork()) {
					Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
					return;
				}
				if (!checkInfo())
					break;
				login(etAccount.getText().toString(), etPsw.getText()
						.toString());
				break;

			case R.id.login_use_sina:// 用新浪微博登陆
				Intent intentWeibo = new Intent(mActivity,
						ThirdPartyLoginActivity.class);
				intentWeibo.putExtra("flag", "login");
				intentWeibo.putExtra("type", "weibo");
				mActivity.startActivityForResult(intentWeibo,
						Constants.THIRD_LOGIN_REQUEST);
				break;

			case R.id.login_use_qq:// 用QQ登陆
				Intent intentQQ = new Intent(mActivity,
						ThirdPartyLoginActivity.class);
				intentQQ.putExtra("flag", "login");
				intentQQ.putExtra("type", "qq");
				mActivity.startActivityForResult(intentQQ,
						Constants.THIRD_LOGIN_REQUEST);
				break;
			case R.id.login_use_renren: //用人人登录
				Intent intentRenren = new Intent(mActivity, ThirdPartyLoginActivity.class);
				intentRenren.putExtra("flag", "login");
				intentRenren.putExtra("type", "renren");
				mActivity.startActivityForResult(intentRenren, Constants.THIRD_LOGIN_REQUEST);
			}
		}
	};

	public void login(String uname, String password) {
		new LoginAsyncTask().execute(uname, password);
	}

	class LoginAsyncTask extends AsyncTask<String, Void, Integer> {

		@Override
		protected void onPreExecute() {
			if (loginPd == null) {
				loginPd = new ProgressDialog(mActivity);
				loginPd.setProgressStyle(ProgressDialog.STYLE_SPINNER);
				loginPd.setCancelable(true);
				loginPd.setCanceledOnTouchOutside(false);
				loginPd.setMessage("正在登录中");
			}
			loginPd.show();
			super.onPreExecute();
		}

		@Override
		protected Integer doInBackground(String... params) {
			int result = 0;
			String username = params[0];
			String password = params[1];
			try {
				UserLogic userLogic = new UserLogic();
				result = userLogic.login(username, password);
			} catch (IOException e) {
				KuwoLog.printStackTrace(e);
			}
			return result;
		}

		@Override
		protected void onPostExecute(Integer result) {
			if (loginPd != null) {
				loginPd.dismiss();
				loginPd = null;
			}
			switch (result) {
			case UserLogic.OK:
				// 跳转到用户登陆后的页面
				MobclickAgent.onEvent(mActivity, "KS_USER_LOGIN", "1");
				if (Config.getPersistence().user == null)
					break;
				Toast.makeText(mActivity, "登录成功", 0).show();
				if (!login_rem_psw_check.isChecked()) {
					Config.getPersistence().rememberUserInfo = false;
				} else {
					Config.getPersistence().rememberUserInfo = true;
				}
				Config.savePersistence();
				Intent intent = new Intent();
				intent.setAction("cn.kuwo.sing.user.change");
				mActivity.sendBroadcast(intent);
				Intent resultIntent = new Intent();
				resultIntent.putExtra("nickname",
						Config.getPersistence().user.nickname);
				mActivity.setResult(Constants.LOGIN_SUCCESS_RESULT,
						resultIntent);
				mActivity.finish();
				break;
			case UserLogic.ERROR_BASE64_DECODE:
				// base64解码失败
				MobclickAgent.onEvent(mActivity, "KS_USER_LOGIN", "0");
				Toast.makeText(mActivity, "base64解码失败", 0).show();
				break;
			case UserLogic.ERROR_TRANS_CODE:
				// 转码失败
				MobclickAgent.onEvent(mActivity, "KS_USER_LOGIN", "0");
				Toast.makeText(mActivity, "转码失败", 0).show();
				break;
			case UserLogic.ERROR_UNAME_EMPTY:
				// 用户名为空
				Toast.makeText(mActivity, "用户名为空", 0).show();
				break;
			case UserLogic.ERROR_UNAME_UNEXIST:
				// 用户不存在
				MobclickAgent.onEvent(mActivity, "KS_USER_LOGIN", "0");
				Toast.makeText(mActivity, "用户不存在", 0).show();
				break;
			case UserLogic.ERROR_PWD_INVALID:
				// 密码不正确
				Toast.makeText(mActivity, "密码不正确", 0).show();
				break;
			case UserLogic.ERROR_PARAM_INVALID:
				// 参数不合法，参数不够
				MobclickAgent.onEvent(mActivity, "KS_USER_LOGIN", "0");
				Toast.makeText(mActivity, "参数不合法，参数不够", 0).show();
				break;
			case UserLogic.ERROR_SERVICE_ERROR:
				// 某些内部服务不正常，无法正常工作(连不上数据库或KSQL)
				MobclickAgent.onEvent(mActivity, "KS_USER_LOGIN", "0");
				Toast.makeText(mActivity, "参数不合法，参数不够", 0).show();
				break;
			}
			super.onPostExecute(result);
		}
	}

	/**
	 * 检查输入是否符合要求
	 */
	private boolean checkInfo() {

		String userID = etAccount.getText().toString();
		String psw = etPsw.getText().toString();

		if (strIsEmpty(userID)) {
			checkTip("请输入账号");
			return false;
		}

		if (strIsEmpty(psw)) {
			checkTip("请输入密码");
			return false;
		}

		// if (!strIsCorrect(userID) || userID.trim().length() < 2
		// || userID.trim().length() > 20) {
		// checkTip("请输入正确账号");
		// return false;
		// }

		if (psw.trim().length() < 6 || psw.trim().length() > 16) {
			checkTip("请输入6-16位密码");
			return false;
		}

		return true;
	}

	// private static final String check = "^([a-z0-9A-Z]+[-|\\.]?)";
	private static final String check = "^[^\\d][a-zA-Z0-9\\u4e00-\\u9fa5]+$";

	// private static final String check2 = "^\\d";

	public boolean strIsEmpty(String str) {
		if (null == str) {
			return true;
		}
		String tempStr = str.trim();

		if (TextUtils.isEmpty(tempStr)) {
			return true;
		}
		return false;
	}

	public boolean strIsCorrect(String str) {
		if (null == str) {
			return false;
		}

		Pattern regex = Pattern.compile(check);
		Matcher matcher = regex.matcher(str);
		if (matcher.matches()) {
			return true;
		}
		return false;
	}

	public void checkTip(String text) {

		AlertDialog.Builder dlgBuilder = new AlertDialog.Builder(mActivity);

		dlgBuilder.setTitle("提示");
		dlgBuilder.setMessage("" + text);
		dlgBuilder.setCancelable(true);
		dlgBuilder.setPositiveButton("确定", null);
		dlgBuilder.show();
	}

	private TextWatcher mTextWatcher = new TextWatcher() {

		@Override
		public void onTextChanged(CharSequence s, int start, int before,
				int count) {
			if (s.length() > 0) {
				clearBtnChanged(true);
			} else {
				clearBtnChanged(false);
			}
		}

		@Override
		public void beforeTextChanged(CharSequence s, int start, int count,
				int after) {
			if (s.length() > 0) {
				clearBtnChanged(true);
			} else {
				clearBtnChanged(false);
			}
		}

		@Override
		public void afterTextChanged(Editable s) {
			if (s.length() > 0) {
				clearBtnChanged(true);
			} else {
				clearBtnChanged(false);
			}
		}
	};

	private void clearBtnChanged(boolean isVisible) {
		if (isVisible) {
			imgAccountClear.setVisibility(View.VISIBLE);
			imgAccountClear.setClickable(true);
		} else {
			imgAccountClear.setVisibility(View.GONE);
			imgAccountClear.setClickable(false);
		}
	}

	private TextWatcher mPswTextWatcher = new TextWatcher() {

		@Override
		public void onTextChanged(CharSequence s, int start, int before,
				int count) {
			if (s.length() > 0) {
				clearPswBtnChanged(true);
			} else {
				clearPswBtnChanged(false);
			}
		}

		@Override
		public void beforeTextChanged(CharSequence s, int start, int count,
				int after) {
			if (s.length() > 0) {
				clearPswBtnChanged(true);
			} else {
				clearPswBtnChanged(false);
			}
		}

		@Override
		public void afterTextChanged(Editable s) {
			if (s.length() > 0) {
				clearPswBtnChanged(true);
			} else {
				clearPswBtnChanged(false);
			}
		}
	};

	private void clearPswBtnChanged(boolean isVisible) {
		if (isVisible) {
			imgPswClear.setVisibility(View.VISIBLE);
			imgPswClear.setClickable(true);
		} else {
			imgPswClear.setVisibility(View.GONE);
			imgPswClear.setClickable(false);
		}
	}

}
