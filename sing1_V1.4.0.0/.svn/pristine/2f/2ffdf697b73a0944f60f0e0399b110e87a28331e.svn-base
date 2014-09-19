/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.MusicLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2012-12-19, 上午11:51:13, 2012
 *
 * @Author wangming
 *
 */
public class CommentSendController extends BaseController {
	private final String TAG = "CommentSendController";
	private BaseActivity mActivity;
	private EditText et_comment_send;
	private Button bt_comment_send_back;
	private Button bt_comment_send;
	private String kid;
	private String sid;
	private String toUid;
	private String toName;
	private ProgressDialog sendPd = null;
	
	public CommentSendController(BaseActivity activity) {
		KuwoLog.i(TAG, "CommentSendController");
		mActivity = activity;
		initView();
		kid = mActivity.getIntent().getStringExtra("kid");
		sid = mActivity.getIntent().getStringExtra("sid");
		KuwoLog.i(TAG, "sid="+sid);
		toUid = mActivity.getIntent().getStringExtra("toUid");
		toName = mActivity.getIntent().getStringExtra("toName");
		if(toUid.equals("")) {
			toUid = "";
		}else {
			et_comment_send.setText("回复" + toName + ":" );
			et_comment_send.setSelection(et_comment_send.length());
		}
			
	}

	private void initView() {
		et_comment_send = (EditText) mActivity.findViewById(R.id.et_comment_send);
		bt_comment_send = (Button) mActivity.findViewById(R.id.bt_comment_send);
		bt_comment_send.setOnClickListener(mOnClickListener);
		bt_comment_send_back = (Button) mActivity.findViewById(R.id.bt_comment_send_back);
		bt_comment_send_back.setOnClickListener(mOnClickListener);
	}
	
	class CommentSender extends AsyncTask<String, Void, String> {
		
		@Override
		protected void onPreExecute() {
			if(sendPd == null) {
				sendPd = new ProgressDialog(mActivity);
				sendPd.setProgressStyle(ProgressDialog.STYLE_SPINNER);
				sendPd.setCancelable(true);
				sendPd.setCanceledOnTouchOutside(false);
				sendPd.setMessage("正在发送中...");
			}
			sendPd.show();
			super.onPreExecute();
		}

		@Override
		protected String doInBackground(String... params) {
			String kid = params[0];
			String sid = params[1];
			String toUid = params[2];
			String content = params[3];
			MusicLogic logic = new MusicLogic();
			return logic.sendComment(kid, sid, toUid, content);
		}

		protected void onPostExecute(String result) {
			if(sendPd != null) {
				sendPd.dismiss();
				sendPd = null;
			}
			if(result.equals("1")) {
				Toast.makeText(mActivity, "发表成功,正在刷新列表", 0).show();
				Intent commentIntent = new Intent();
				commentIntent.setAction("cn.kuwo.sing.comment.update");
				mActivity.sendBroadcast(commentIntent);
				mActivity.setResult(Constants.COMMENT_SEND_SUCCESS_RESULT);
			}else {
				Toast.makeText(mActivity, "发表失败", 0).show();
				mActivity.setResult(Constants.COMMENT_SEND_FAIL_RESULT);
			}
			mActivity.finish();
			super.onPostExecute(result);
		}
		
	}
	
	private View.OnClickListener mOnClickListener = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			int id = v.getId();
			switch (id) {
			case R.id.bt_comment_send:
				String content = et_comment_send.getText().toString();
				if(TextUtils.isEmpty(content)) {
					Toast.makeText(mActivity, "内容不能为空！", 0).show();
				}else {
					if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
						new CommentSender().execute(kid, sid, toUid, content);
					}else {
						Toast.makeText(mActivity, "网络不通，请稍后再试试", 0).show();
					}
				}
				break;
			case R.id.bt_comment_send_back:
				mActivity.finish();
				break;

			default:
				break;
			}
		}
	};
}
