package cn.kuwo.sing.ui.activities;

import java.io.IOException;
import java.util.HashMap;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.controller.LocalNoticeController;
import cn.kuwo.sing.logic.service.UserService;

public class LocalNoticeActivity  extends BaseActivity{
	private final String TAG = "LocalNoticeActivity";
	private LocalNoticeController mLocalNoticeController;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.local_notice_activity);
		mLocalNoticeController = new LocalNoticeController(this);
	}
	
	@Override
	protected void onRestart() {
		KuwoLog.i(TAG, "onRestart");
		super.onRestart();
	}
	
	@Override
	protected void onResume() {
		KuwoLog.i(TAG, "onResume");
		mLocalNoticeController.loadUrl();
		//请求消息数目
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				//登录ok，获取消息数目
				UserService userService = new UserService();
				try {
					HashMap<String, String> params = userService.getNotReadNoticeNum();
					if(params != null && params.get("result") != null) {
						if(params.get("result").equals("ok")) {
							String numStr = params.get("total");
							KuwoLog.i(TAG, "noticeNum="+numStr);
							Config.getPersistence().user.noticeNumber = Integer.parseInt(numStr);
							Config.savePersistence();
						}else if(params.get("result").equals("err")) {
							KuwoLog.i(TAG, "get notice err: "+params.get("msg"));
						}
					}else {
						KuwoLog.e(TAG, "params is null");
					}
				} catch (IOException e) {
					KuwoLog.printStackTrace(e);
				}
			}
		}).start();
		super.onResume();
	}
	
	private Handler messageHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				
				break;

			default:
				break;
			}
		}
		
	};

}
