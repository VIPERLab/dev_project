package cn.kuwo.sing.controller;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.InputType;
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
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.User;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.logic.service.UserService;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.ThirdPartyLoginActivity;

/**
 * 注册页面控制层
 */
public class RegisterController extends BaseController {

	private final String TAG = "RegisterController";

	private BaseActivity mActivity;
	/* 账号输入框 */
	private EditText etAccount;
	/* 清空输入账号内容 */
	private ImageView imgAccountClear;
	/* 输入密码 */
	private  EditText etAccountpwd;
	/* 清空密码内容 */
	private ImageView imgPswClear;
	private ProgressDialog registerPd = null;
	
	public RegisterController(BaseActivity activity) {

		KuwoLog.v(TAG, "RegisterController()");
		mActivity = activity;
		initView();
	}

	/**
	 * 初始化控件
	 * 
	 * @param activity
	 */
	private void initView() {

		Button btnBack = (Button) mActivity.findViewById(R.id.register_back_btn);
		btnBack.setOnClickListener(mOnClickListener);

		imgAccountClear = (ImageView) mActivity.findViewById(R.id.register_account_clear);
		imgAccountClear.setOnClickListener(mOnClickListener);
		
		imgPswClear = (ImageView) mActivity.findViewById(R.id.register_psw_clear);
		imgPswClear.setOnClickListener(mOnClickListener);
		
		etAccount = (EditText) mActivity.findViewById(R.id.register_account_input);
		etAccount.addTextChangedListener(mTextWatcher);

		etAccountpwd = (EditText) mActivity.findViewById(R.id.register_psw_input);
		etAccountpwd.addTextChangedListener(mPswWatcher);
		etAccountpwd.setInputType(InputType.TYPE_CLASS_TEXT);
		
		CheckBox imgDisplayPsw = (CheckBox) mActivity.findViewById(R.id.register_display_psw_check);
		imgDisplayPsw.setChecked(true);
		imgDisplayPsw.setOnClickListener(mOnClickListener);

		Button btnRegister = (Button) mActivity.findViewById(R.id.register_btn);
		btnRegister.setOnClickListener(mOnClickListener);

		TextView tvUseSina = (TextView) mActivity.findViewById(R.id.register_use_sina);
		tvUseSina.setOnClickListener(mOnClickListener);

		TextView tvUseQQ = (TextView) mActivity.findViewById(R.id.register_use_qq);
		tvUseQQ.setOnClickListener(mOnClickListener);
		
		TextView register_use_renren = (TextView) mActivity.findViewById(R.id.register_use_renren);
		register_use_renren.setOnClickListener(mOnClickListener);
		
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
			case R.id.register_back_btn:// 返回按钮
				mActivity.finish();
				break;

			case R.id.register_account_clear:// 清除账号
				etAccount.setText("");
				break;

			case R.id.register_psw_clear:// 清除账号
				etAccountpwd.setText("");
				break;
				
			case R.id.register_display_psw_check:// 显示密码check
				int inputType = etAccountpwd.getInputType();
				if(inputType == 129) {
					etAccountpwd.setInputType(InputType.TYPE_CLASS_TEXT);
				}else if(inputType == InputType.TYPE_CLASS_TEXT) {
					etAccountpwd.setInputType(129);
				}
				etAccountpwd.setSelection(etAccountpwd.length());
				break;

			case R.id.register_btn:// 注册按钮
				InputMethodManager imm = (InputMethodManager)mActivity.getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(etAccountpwd.getWindowToken(), 0); 
				if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
					Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
					return;
				}
				if (!checkInfo())
					break;
				if(registerPd == null) {
					registerPd = new ProgressDialog(mActivity);
					registerPd.setProgressStyle(ProgressDialog.STYLE_SPINNER);
					registerPd.setCancelable(true);
					registerPd.setCanceledOnTouchOutside(false);
					registerPd.setMessage("正在注册中");
				}
				registerPd.show();
				new Thread(new Runnable() {
					
					@Override
					public void run() {
						int result = 0;
						String name = etAccount.getText().toString();
						String password = etAccountpwd.getText().toString();
						UserLogic userlogic = new UserLogic();
						try {
							result = userlogic.register(name, password);
						} catch (IOException e) {
							KuwoLog.printStackTrace(e);
						}
						Message msg = registerHandler.obtainMessage();
						msg.what = 0;
						msg.obj = result;
						registerHandler.sendMessage(msg);
					}
				}).start();
				break;
			case R.id.register_use_sina:// 用新浪注册
				Intent intentWeibo = new Intent(mActivity, ThirdPartyLoginActivity.class);
				intentWeibo.putExtra("flag", "login");
				intentWeibo.putExtra("type", "weibo");
				mActivity.startActivityForResult(intentWeibo, Constants.THIRD_LOGIN_REQUEST);
				break;

			case R.id.register_use_qq:// 用QQ注册
				Intent intentQQ = new Intent(mActivity, ThirdPartyLoginActivity.class);
				intentQQ.putExtra("flag", "login");
				intentQQ.putExtra("type", "qq");
				mActivity.startActivity(intentQQ);
				mActivity.startActivityForResult(intentQQ, Constants.THIRD_LOGIN_REQUEST);
				break;
			case R.id.register_use_renren:
				Intent intentRenren = new Intent(mActivity, ThirdPartyLoginActivity.class);
				intentRenren.putExtra("flag", "login");
				intentRenren.putExtra("type", "renren");
				mActivity.startActivity(intentRenren);
				mActivity.startActivityForResult(intentRenren, Constants.THIRD_LOGIN_REQUEST);
				break;
			}
		}
	};
	
	private Handler registerHandler = new Handler() {
		
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				int result = (Integer) msg.obj;
				if(registerPd != null) {
					registerPd.dismiss();
					registerPd = null;
				}
				switch(result){
				case UserService.SUCCESSFUL_REGISTRATION:
	 				//注册成功
					Toast.makeText(mActivity, "注册成功！", 0).show();
					mActivity.setResult(Constants.REGISTER_SUCCESS_RESULT);
					mActivity.finish();
					break;
				case UserService.REGISTERED:
					Toast.makeText(mActivity, "用户名已被注册！", 0).show();
					//用户名已被注册
					break;
				case UserService.OPERATE_FAILURE:
					Toast.makeText(mActivity, "注册失败！", 0).show();
					//操作失败
					break;
				case 0:
					break;
				}
				break;

			default:
				break;
			}
		};
	};
	
	private TextWatcher mTextWatcher = new TextWatcher() {

		@Override
		public void onTextChanged(CharSequence s, int start, int before, int count) {
			if (s.length() > 0) {
				clearBtnChanged(true);
			} else {
				clearBtnChanged(false);
			}
		}

		@Override
		public void beforeTextChanged(CharSequence s, int start, int count, int after) {
		}

		@Override
		public void afterTextChanged(Editable s) {
		}
	};

	private void clearBtnChanged(boolean isVisible) {
		if (isVisible) {
			imgAccountClear.setVisibility(View.VISIBLE);
		} else {
			imgAccountClear.setVisibility(View.GONE);
		}
	}
	

	private TextWatcher mPswWatcher = new TextWatcher() {

		@Override
		public void onTextChanged(CharSequence s, int start, int before, int count) {
			if (s.length() > 0) {
				clearPswBtnChanged(true);
			} else {
				clearPswBtnChanged(false);
			}
		}

		@Override
		public void beforeTextChanged(CharSequence s, int start, int count, int after) {
		}

		@Override
		public void afterTextChanged(Editable s) {
			try {
				String temp = s.toString();
				String tem = temp.substring(temp.length() - 1, temp.length());
				char[] temC = tem.toCharArray();
				int mid = temC[0];
				if (mid >= 48 && mid <= 57) {// 数字
					return;
				}
				if (mid >= 65 && mid <= 90) {// 大写字母
					return;
				}
				if (mid > 97 && mid <= 122) {// 小写字母
					return;
				}
				Toast.makeText(mActivity, "请输入字母数字作为密码", 0).show();
				s.delete(temp.length() - 1, temp.length());
			} catch (Exception e) {
				KuwoLog.e(TAG, e.toString());
			}
		}
	};

	private void clearPswBtnChanged(boolean isVisible) {
		if (isVisible) {
			imgPswClear.setVisibility(View.VISIBLE);
		} else {
			imgPswClear.setVisibility(View.GONE);
		}
	}
	/**
	 * 检查输入是否符合要求
	 */
	private boolean checkInfo() {

		String userID = etAccount.getText().toString();
		String psw = etAccountpwd.getText().toString();

		if (strIsEmpty(userID)) {
			checkTip("请输入账号");
			return false;
		}
		
		if (!strIsCorrect(userID) || userID.trim().length() < 2
				|| userID.trim().length() > 20) {
			checkTip("请输入2-20位字母/数字/汉字");
			return false;
		}

		if (strIsEmpty(psw)) {
			checkTip("请输入密码");
			return false;
		}


		if (psw.trim().length() < 6 || psw.trim().length() > 16) {
			checkTip("请输入6-16位密码");
			return false;
		}

		return true;
	}

	private static final String check = "^[^\\d][a-zA-Z0-9\\u4e00-\\u9fa5]+$";

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
}
