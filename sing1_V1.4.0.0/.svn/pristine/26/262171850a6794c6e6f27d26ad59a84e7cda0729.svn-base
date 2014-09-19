/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.os.AsyncTask;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.ThirdPartyLoginActivity;
import cn.kuwo.sing.util.DialogUtils;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2012-12-20, 上午11:13:26, 2012
 *
 * @Author wangming
 *
 */
public class ShareSettingController extends BaseController {
	private final String TAG = "ShareSettingController";
	private BaseActivity mActivity;
	private Button bt_share_setting_back;
	private TextView tv_share_setting_sina;
	private TextView tv_share_setting_qq;
	private TextView tv_share_setting_renren;
	private TextView tv_share_setting__sina_status_tip;
	private TextView tv_share_setting_qq_status_tip;
	private TextView tv_share_setting_renren_status_tip;
	private ProgressDialog pd;
	
	public ShareSettingController(BaseActivity activity) {
		mActivity = activity;
		initView();
	}

	private void initView() {
		bt_share_setting_back = (Button) mActivity.findViewById(R.id.bt_share_setting_back);
		bt_share_setting_back.setOnClickListener(mOnClickListener);
		
		tv_share_setting_sina = (TextView) mActivity.findViewById(R.id.tv_share_setting_sina);
		tv_share_setting_sina.setOnClickListener(mOnClickListener);
		tv_share_setting__sina_status_tip = (TextView) mActivity.findViewById(R.id.tv_share_setting__sina_status_tip);
		tv_share_setting__sina_status_tip.setOnClickListener(mOnClickListener);
		
		tv_share_setting_qq = (TextView) mActivity.findViewById(R.id.tv_share_setting_qq);
		tv_share_setting_qq.setOnClickListener(mOnClickListener);
		tv_share_setting_qq_status_tip = (TextView) mActivity.findViewById(R.id.tv_share_setting_qq_status_tip);
		tv_share_setting_qq_status_tip.setOnClickListener(mOnClickListener);
		
		tv_share_setting_renren = (TextView) mActivity.findViewById(R.id.tv_share_setting_renren);
		tv_share_setting_renren.setOnClickListener(mOnClickListener);
		tv_share_setting_renren_status_tip = (TextView) mActivity.findViewById(R.id.tv_share_setting_renren_status_tip);
		tv_share_setting_renren_status_tip.setOnClickListener(mOnClickListener);
	}
	
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			int id = v.getId();
			switch (id) {
			case R.id.bt_share_setting_back:
				mActivity.finish();
				break;
			case R.id.tv_share_setting__sina_status_tip:
				weiboBindOrUnbind();
				break;
			case R.id.tv_share_setting_qq_status_tip:
				qqBindOrUnbind();
				break;
			case R.id.tv_share_setting_renren_status_tip:
				renrenBindOrUnbind();
				break;
			case R.id.tv_share_setting_sina:
				weiboBindOrUnbind();
				break;
			case R.id.tv_share_setting_qq:
				qqBindOrUnbind();
				break;
			case R.id.tv_share_setting_renren:
				renrenBindOrUnbind();
				break;
			default:
				break;
			}
		}
	};
	
	private void weiboBindOrUnbind() {
		if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
			if(Config.getPersistence().user.isBindWeibo) {
				alertUnbindTip("weibo");
			}else {
				Intent sinaLoginIntent = new Intent(mActivity, ThirdPartyLoginActivity.class);
				sinaLoginIntent.putExtra("flag", "bind");
				sinaLoginIntent.putExtra("type", "weibo");
				mActivity.startActivityForResult(sinaLoginIntent, Constants.SHARE_BOUND_REQUEST);
			}
		}else {
			Toast.makeText(mActivity, "没有网络连接！", 0).show();
		}
	}
	
	private void qqBindOrUnbind() {
		if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
			if(Config.getPersistence().user.isBindQQ) {
				alertUnbindTip("qq");
			}else {
				Intent qqLoginIntent = new Intent(mActivity, ThirdPartyLoginActivity.class);
				qqLoginIntent.putExtra("flag", "bind");
				qqLoginIntent.putExtra("type", "qq");
				mActivity.startActivityForResult(qqLoginIntent, Constants.SHARE_BOUND_REQUEST);
			}
		}else {
			Toast.makeText(mActivity, "没有网络连接！", 0).show();
		}
	}
	
	private void renrenBindOrUnbind() {
		if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
			if(Config.getPersistence().user.isBindRenren) {
				alertUnbindTip("renren");
			}else {
				Intent renrenLoginIntent = new Intent(mActivity, ThirdPartyLoginActivity.class);
				renrenLoginIntent.putExtra("flag", "bind");
				renrenLoginIntent.putExtra("type", "renren");
				mActivity.startActivityForResult(renrenLoginIntent, Constants.SHARE_BOUND_REQUEST);
			}
		}else {
			Toast.makeText(mActivity, "没有网络连接！", 0).show();
		}
	}
	
	private void alertUnbindTip(final String type) {
		DialogUtils.alert(mActivity, new OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//确定
					new UnBinddAsyncTask().execute(type);
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
				R.string.bind_dialog_content);
	}
	
	class UnBinddAsyncTask extends AsyncTask<String, Void, Integer> {
		private String mType;
		
		@Override
		protected void onPreExecute() {
			if(pd == null) {
				pd = new ProgressDialog(mActivity);
				pd.setProgressStyle(ProgressDialog.STYLE_SPINNER);
				pd.setCancelable(false);
				pd.setCanceledOnTouchOutside(false);
				pd.setMessage("正在解除绑定");
			}
			pd.show();
			super.onPreExecute();
		}

		@Override
		protected Integer doInBackground(String... params) {
			String type = params[0];
			mType = type;
			UserLogic logic = new UserLogic();
			String uid = Config.getPersistence().user.uid;
			String sid = Config.getPersistence().user.sid;
			return logic.unBindThirdAccount(uid, sid, type);
		}

		@Override
		protected void onPostExecute(Integer result) {
			if(pd != null) {
				pd.dismiss();
				pd = null;
			}
			if(result == 0) {
				Toast.makeText(mActivity, "解除绑定成功", 0).show();
				if(mType.equals("weibo")) {
					Config.getPersistence().user.isBindWeibo = false;
					for(int i = 0; i < Config.getPersistence().user.thirdInfoList.size(); i++){
						if(Config.getPersistence().user.thirdInfoList.get(i).third_type.equals("weibo"))
						{
							Config.getPersistence().user.thirdInfoList.remove(i);
							break;
						}
					}
					changeWeiboBindState("", "绑定");
				}else if(mType.equals("qq")) {
					Config.getPersistence().user.isBindQQ = false;
					for(int i = 0; i < Config.getPersistence().user.thirdInfoList.size(); i++){
						if(Config.getPersistence().user.thirdInfoList.get(i).third_type.equals("qq"))
						{
							Config.getPersistence().user.thirdInfoList.remove(i);
							break;
						}
					}
					changeQQBindState("", "绑定");
				}else if(mType.equals("renren")) {
					Config.getPersistence().user.isBindRenren = false;
					for(int i = 0; i < Config.getPersistence().user.thirdInfoList.size(); i++){
						if(Config.getPersistence().user.thirdInfoList.get(i).third_type.equals("renren"))
						{
							Config.getPersistence().user.thirdInfoList.remove(i);
							break;
						}
					}
					changeRenrenBindState("", "绑定");
				}
			}else if(result == -1) {
				Toast.makeText(mActivity, "解除失败", 0).show();
			}
			super.onPostExecute(result);
		}
	}
	
	public void changeWeiboBindState(String username, String boundState) {
		if(username.equals("")) {
			tv_share_setting_sina.setText("新浪微博 ");
		}else {
			tv_share_setting_sina.setText("新浪微博 ："+username);
		}
		tv_share_setting__sina_status_tip.setText(boundState);
	}
	
	public void changeQQBindState(String username, String boundState) {
		if(username.equals("")) {
			tv_share_setting_qq.setText("QQ空间");
		}else {
			tv_share_setting_qq.setText("QQ空间："+username);
		}
		tv_share_setting_qq_status_tip.setText(boundState);
	}
	
	public void changeRenrenBindState(String username, String boundState) {
		if(username.equals("")) {
			tv_share_setting_renren.setText("人人网");
		}else {
			tv_share_setting_renren.setText("人人网："+username);
		}
		tv_share_setting_renren_status_tip.setText(boundState);
	}
}
