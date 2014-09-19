/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.Map;

import javax.crypto.Mac;

import android.content.DialogInterface;
import android.content.Intent;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.SquareShow;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.context.App;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.LocalMainActivity;
import cn.kuwo.sing.ui.activities.LoginActivity;
import cn.kuwo.sing.ui.activities.SongSubListActivity;
import cn.kuwo.sing.ui.compatibility.KuwoWebView;
import cn.kuwo.sing.ui.compatibility.KuwoWebView.OnOrderListener;
import cn.kuwo.sing.util.DialogUtils;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2013-4-22, 下午3:08:10, 2013
 *
 * @Author wangming
 *
 */
public class SquareActivityController extends BaseController {
	private static final String LOG_TAG = "SquareActivityController";
	private BaseActivity mActivity;
	private TextView tv_square_activity_title;
	private String activityUrl;
	private String title;
	private KuwoWebView kwv_square_activity;
	private RelativeLayout rl_square_activity;
	private Button bt_square_activity_back;
	private Button bt_square_activity_goBack;
	private Button bt_square_activity_goForward;
	private Button bt_square_activity_refresh;
	private String lastOrder;
	private long lastOrderTime;
	private FrameLayout fl_square_activity;
	
	public SquareActivityController(BaseActivity activity) {
		KuwoLog.d(LOG_TAG, "SquareActivityController");
		mActivity = activity;
		initData();
		initView();
	}

	private void initData() {
		Intent intent = mActivity.getIntent();	
		activityUrl = intent.getStringExtra("activityUrl");
		title = intent.getStringExtra("title");
		KuwoLog.d(LOG_TAG, "activityUrl="+activityUrl);
	}

	private void initView() {
		fl_square_activity = (FrameLayout) mActivity.findViewById(R.id.fl_square_activity);
		bt_square_activity_back = (Button) mActivity.findViewById(R.id.bt_square_activity_back);
		bt_square_activity_back.setOnClickListener(mOnClickListener);
		bt_square_activity_goBack = (Button) mActivity.findViewById(R.id.bt_square_activity_goBack);
		bt_square_activity_goBack.setOnClickListener(mOnClickListener);
		bt_square_activity_goForward = (Button) mActivity.findViewById(R.id.bt_square_activity_goForward);
		bt_square_activity_goForward.setOnClickListener(mOnClickListener);
		bt_square_activity_refresh = (Button) mActivity.findViewById(R.id.bt_square_activity_refresh);
		bt_square_activity_refresh.setOnClickListener(mOnClickListener);
		rl_square_activity = (RelativeLayout) mActivity.findViewById(R.id.rl_square_activity);
		tv_square_activity_title = (TextView) mActivity.findViewById(R.id.tv_square_activity_title);
		tv_square_activity_title.setText(title);
		kwv_square_activity = (KuwoWebView) mActivity.findViewById(R.id.kwv_square_activity);
		kwv_square_activity.setOnOrderListener(mOnOrderListener);
		kwv_square_activity.setDownloadListener(mActivity);
		kwv_square_activity.loadUrl(activityUrl);
	}
	
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			switch (v.getId()) {
			case R.id.bt_square_activity_back:
				resetAppParamsFromKwPlayer();
				fl_square_activity.removeView(kwv_square_activity);
				kwv_square_activity.removeAllViews();
				kwv_square_activity.setFocusable(true);
				kwv_square_activity.clearHistory();
				kwv_square_activity.destory();
				mActivity.finish();
				break;
			case R.id.bt_square_activity_goBack:
				kwv_square_activity.goBack();
				break;
			case R.id.bt_square_activity_goForward:
				kwv_square_activity.goForward();
				break;
			case R.id.bt_square_activity_refresh:
				kwv_square_activity.reload();
				break;

			default:
				break;
			}
			
		}
	};
	
	private void resetAppParamsFromKwPlayer() {
		App app = (App) mActivity.getApplication();
		app.albumFromKwPlayer = null;
		app.artistFromKwPlayer = null;
		app.ridFromKwPlayer = null;
		app.songNameFromKwPlayer = null;
		app.sourceFromKwPlayer = null;
	}
	
	public void onRefreshPage() {
		String uid = null;
		String sid = null;
		String uname = null;
		String headUrl = null;
		if(Config.getPersistence().user != null ){
			uid = Config.getPersistence().user.uid;
			sid = Config.getPersistence().user.sid;
			uname = Config.getPersistence().user.uname;
			headUrl = Config.getPersistence().user.headUrl;
		}
		String functionStr = "onRefreshPage('id="+uid+"&loginid="+uid+"&sid="+sid+"&uname="+uname+"&head="+headUrl+"')";
		kwv_square_activity.js(functionStr);
	}
	
	private KuwoWebView.OnOrderListener mOnOrderListener = new KuwoWebView.OnOrderListener() {
		
		@Override
		public void onPageStart() {
			rl_square_activity.setVisibility(View.VISIBLE);
		}
		
		@Override
		public void onPageFinished() {
			
		}
		
		@Override
		public void onOrder(String order, Map<String, String> params) {
			KuwoLog.d(LOG_TAG, "square log: order="+order);
			if (order.equals(lastOrder) && (System.currentTimeMillis()-lastOrderTime)<1500 )
				return;
			lastOrder = order;
			lastOrderTime = System.currentTimeMillis();
			if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
				Toast.makeText(mActivity, "网络未连接，请稍后再试", 0).show();
				return;
			}
			if(order.equalsIgnoreCase("NewPage")) {
				String type = params.get("type");
				String url = params.get("url");
				String title = params.get("title");
				try {
					url = URLDecoder.decode(url, "utf-8");
					title = URLDecoder.decode(title, "utf-8");
				} catch (UnsupportedEncodingException e) {
					e.printStackTrace();
				}
				String uid = url.substring(url.lastIndexOf('=')+1);
				String uname = title.substring(0, title.length()-3);
				Intent singerIntent = new Intent(mActivity, LocalMainActivity.class);
				singerIntent.putExtra("flag", "otherHome");
				singerIntent.putExtra("uid", uid);
				singerIntent.putExtra("uname", uname);
				mActivity.startActivity(singerIntent);
			}else if(order.equalsIgnoreCase("playsong")) {
				MTVBusiness mb = new MTVBusiness(mActivity);
				mb.playMtv(params.get("rid"));
			}else if(order.equalsIgnoreCase("showNeedLogin")) { 
				showLoginDialog(R.string.login_dialog_tip);
			}else if(order.equals("JumpToKSongPage") || order.equals("JumpToKSong")) {
				String listId = params.get("id");
				String listName = params.get("name");
				if(TextUtils.isEmpty(listId) || TextUtils.isEmpty(listName)) {
					mActivity.finish();
					//发送一段广播，通知MainActivity做页面跳转
					Intent intent = new Intent();
					intent.setAction("cn.kuwo.sing.jump.songpage");
					mActivity.sendBroadcast(intent);
				}else {
					Intent loadSubIntent = new Intent(mActivity, SongSubListActivity.class);
					loadSubIntent.putExtra("flag", "subSongList");
					Map<String, SquareShow> activityMap = Config.getPersistence().squareActivityMap;
					if(activityMap != null && activityMap.containsKey(listId)) {
						loadSubIntent.putExtra("fromSquareActivity", listId);
					}
					if(!TextUtils.isEmpty(listId)) {
						loadSubIntent.putExtra("listID", listId);
					}
					if(!TextUtils.isEmpty(listName)) {
						loadSubIntent.putExtra("subTitle", URLDecoder.decode(listName));
					}
					mActivity.startActivity(loadSubIntent);
				}
			}
		}
		
		@Override
		public void onNoServerLoading() {
			rl_square_activity.setVisibility(View.INVISIBLE);
		}
	};
	
	private void showLoginDialog(int tip) {
		DialogUtils.alert(mActivity, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//ok
					dialog.dismiss();
					Intent loginIntent = new Intent(mActivity, LoginActivity.class);
					mActivity.startActivityForResult(loginIntent, Constants.SQUARE_ACTIVITY_LOGIN_REQUEST);
					break;
				case -2:
					//cancel
					dialog.dismiss();
					break;
				default:
					break;
				}
				
			}
		} , R.string.logout_dialog_title, R.string.dialog_ok, R.string.dialog_cancel, -1, tip);
	}
}
