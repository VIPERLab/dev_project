package cn.kuwo.sing.controller;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.os.AsyncTask;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.logic.service.UserService;
import cn.kuwo.sing.ui.activities.AboutActivity;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.LoginActivity;
import cn.kuwo.sing.ui.activities.ShareSettingActivity;
import cn.kuwo.sing.util.DialogUtils;

import com.umeng.fb.UMFeedbackService;
import com.umeng.fb.util.FeedBackListener;

/**
 * 设置页面控制层
 */
public class SettingController extends BaseController {

	private final String TAG = "SettingController";

	private BaseActivity mActivity;

	private TextView tvLoginStatusTip;

	private TextView tvLoginStatus;
	private TextView tv_setting_share;
	private ProgressDialog logoutPd = null;
	
	public SettingController(BaseActivity activity) {

		KuwoLog.v(TAG, "SettingController()");

		mActivity = activity;

		initView();
		
		UMFeedbackService.setFeedBackListener(listener); 
		UMFeedbackService.setGoBackButtonVisible();
	}

	/**
	 * 初始化控件
	 */
	private void initView() {

		tvLoginStatus = (TextView) mActivity.findViewById(R.id.setting_login_status);
		tvLoginStatus.setOnClickListener(mOnClickListener);
		
		// 显示当前用户
		tvLoginStatusTip = (TextView) mActivity.findViewById(R.id.setting_login_status_tip);
		tvLoginStatusTip.setText("未登录");
		tvLoginStatusTip.setOnClickListener(mOnClickListener);
		
		tv_setting_share = (TextView) mActivity.findViewById(R.id.tv_setting_share);
		tv_setting_share.setOnClickListener(mOnClickListener);

		TextView tvAbout = (TextView) mActivity.findViewById(R.id.setting_about);
		tvAbout.setOnClickListener(mOnClickListener);

		TextView tvFeedback = (TextView) mActivity.findViewById(R.id.setting_feedback);
		tvFeedback.setOnClickListener(mOnClickListener);
		
		// 显示当前版本号

		
		if(null != Config.getPersistence() && Config.getPersistence().isLogin) {
			try {
				if(Config.getPersistence().user!= null) {
					String uname = null;
					if (Config.getPersistence().user.nickname != null ) {
						uname = URLDecoder.decode(Config.getPersistence().user.nickname, "utf-8");
					} else 
						uname = URLDecoder.decode(Config.getPersistence().user.uname, "utf-8");
					changeLoginState(uname, R.string.logout_title);
				}
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
		}
		
		
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
			case R.id.setting_login_status_tip:
				loginProcess();
				break;
			case R.id.setting_login_status:// 登陆注册
				loginProcess();
				break;
			case R.id.tv_setting_share: //分享设置
				if(!Config.getPersistence().isLogin) { //如果没有登录，请先登录再进行分享设置
					DialogUtils.alert(mActivity, new OnClickListener() {

						@Override
						public void onClick(DialogInterface dialog, int which) {
							switch (which) {
							case -1:
								//确定
								Intent loginIntent = new Intent(mActivity, LoginActivity.class);
								mActivity.startActivityForResult(loginIntent, Constants.LOGIN_REQUEST);
								break;
							case -2:
								// 取消
								dialog.dismiss();
								break;
							default:
								break;
							}
						}
					}, R.string.logout_dialog_title, R.string.dialog_ok,
							-1, R.string.dialog_cancel, R.string.share_setting_dialog_content);
				}else {
					Intent shareIntent = new Intent(mActivity, ShareSettingActivity.class);
					mActivity.startActivity(shareIntent);
				}
				break;
		
			case R.id.setting_about:// 关于酷我K歌
				Intent aboutIntent = new Intent(mActivity, AboutActivity.class);
				mActivity.startActivity(aboutIntent);
				mActivity.overridePendingTransition(R.anim.sing_push_right_in, R.anim.sing_push_left_out);
				break;
			case R.id.setting_feedback:// 意见反馈
				 //Intent feedbackintent = new Intent(mActivity, FeedbackActivity.class);
				 //mActivity.startActivity(feedbackintent);
				 //mActivity.overridePendingTransition(R.anim.sing_push_right_in, R.anim.sing_push_left_out);
				
				UMFeedbackService.openUmengFeedbackSDK(mActivity);
				break;

			}
		}

		private void loginProcess() {
			if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
				if(Config.getPersistence().isLogin) {
					DialogUtils.alert(mActivity, new OnClickListener() {

						@Override
						public void onClick(DialogInterface dialog, int which) {
							switch (which) {
							case -1:
								//确定
								new LogoutAsyncTask().execute();
								break;
							case -2:
								// 取消
								dialog.dismiss();
								break;

							default:
								break;
							}
						}
					}, R.string.logout_dialog_title, R.string.dialog_ok,
							-1, R.string.dialog_cancel,
							R.string.logout_dialog_content);
				}else {
					Intent loginIntent = new Intent(mActivity, LoginActivity.class);
					mActivity.startActivityForResult(loginIntent, Constants.LOGIN_REQUEST);
					mActivity.overridePendingTransition(R.anim.sing_push_right_in, R.anim.sing_push_left_out);
				}
			}else {
				Toast.makeText(mActivity, "没有网络连接！", 0).show();
			}
			
		}

	};
	
	class ShareAsyncTask extends AsyncTask<Void, Void, Void> {

		@Override
		protected Void doInBackground(Void... params) {
			UserService service = new UserService();
			service.shareByThird("qq", "酷我k歌，分享功能测试。hello", Config.getPersistence().user.uid, Config.getPersistence().user.sid);
			return null;
		}

		@Override
		protected void onPostExecute(Void result) {
			super.onPostExecute(result);
		}
		
	}
	
	class LogoutAsyncTask extends AsyncTask<Void, Void, Integer> {
		
		@Override
		protected void onPreExecute() {
			if(logoutPd == null) {
				logoutPd = new ProgressDialog(mActivity);
				logoutPd.setProgressStyle(ProgressDialog.STYLE_SPINNER);
				logoutPd.setCancelable(false);
				logoutPd.setCanceledOnTouchOutside(false);
				logoutPd.setMessage("正在注销中");
			}
			logoutPd.show();
			super.onPreExecute();
		}

		@Override
		protected Integer doInBackground(Void... params) {
			int result = -1;
			try {
				UserLogic userLogic = new UserLogic();
				result = userLogic.logout();
			} catch (IOException e) {
				KuwoLog.printStackTrace(e);
			}
			return result;
		}

		@Override
		protected void onPostExecute(Integer result) {
			if(logoutPd != null) {
				logoutPd.dismiss();
				logoutPd = null;
			}
			switch (result) {
			case 0:
				//注销成功
				Config.getPersistence().isLogin = false;//设置登录状态为false，即为"退出"状态
				Config.savePersistence();
				Intent intent = new Intent();
				intent.setAction("cn.kuwo.sing.user.change");
				mActivity.sendBroadcast(intent);
				Toast.makeText(mActivity, "注销成功", 0).show();
				tvLoginStatus.setText(R.string.setting_status);
				tvLoginStatusTip.setText(R.string.setting_not_login);
				break;
			case -1:
				//注销失败
				Toast.makeText(mActivity, "注销失败", 0).show();
				break;

			default:
				break;
			}
			super.onPostExecute(result);
		}
		
	}

	public void changeLoginState(String username, int loginState) {
		tvLoginStatus.setText(username);
		tvLoginStatusTip.setText(loginState);
	}

	private FeedBackListener listener = new FeedBackListener() {
		@Override
		public void onSubmitFB(Activity activity) {
			EditText phoneText = (EditText) activity.findViewById(R.id.feedback_phone);
			EditText qqText = (EditText) activity.findViewById(R.id.feedback_qq);
			Map<String, String> contactMap = new HashMap<String, String>();
			contactMap.put("phone", phoneText.getText().toString());
			contactMap.put("qq", qqText.getText().toString());
			UMFeedbackService.setContactMap(contactMap);
		}

		@Override
		public void onResetFB(Activity activity, Map<String, String> contactMap, Map<String, String> remarkMap) {
			// TODO Auto-generated method stub`
			// FB initialize itself,load other attribute
			// from local storage and set them
			EditText phoneText = (EditText) activity.findViewById(R.id.feedback_phone);
			EditText qqText = (EditText) activity.findViewById(R.id.feedback_qq);
			if (contactMap != null) {
				phoneText.setText(contactMap.get("phone"));
				qqText.setText(contactMap.get("qq"));
			}
		}
	};

}