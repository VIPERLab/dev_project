package cn.kuwo.sing.controller;

import java.io.IOException;
import java.io.Serializable;
import java.util.HashMap;

import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TabHost.TabSpec;
import android.widget.TextView;
import cn.kuwo.framework.config.PreferencesManager;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.User;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.ui.activities.DynamicActivity;
import cn.kuwo.sing.ui.activities.MainActivity;
import cn.kuwo.sing.ui.activities.MyActivity;
import cn.kuwo.sing.ui.activities.MyHomeActivity;
import cn.kuwo.sing.ui.activities.SettingActivity;
import cn.kuwo.sing.ui.activities.SongActivity;
import cn.kuwo.sing.ui.activities.SquareActivity;

public class MainController {

	private final String TAG = "MainController";
	
	public final String FRAME_SQUARE = "FrameSquare"; // 广场场景
	public final String FRAME_LIVE = "FrameLive"; // 直播间场景
	public final String FRAME_DYNAMIC = "FrameDynamic"; // 动态
	public final String FRAME_SING = "FrameSing"; // 点歌台场景
	public final String FRAME_LOCAL = "FrameMy"; // 我的场景
	public final String FRAME_SETTING = "FrameSetting"; // 设置场景

	private MainActivity mActivity;
	private ImageView squareBtn;
	private ImageView dynamicBtn;
	private ImageView songBtn;
	private ImageView myBtn;
	private ImageView settingBtn;
	private LinearLayout main_bottom_linlayout;
	private TextView msgTip;
	
	public MainController(MainActivity activity) {
		this.mActivity = activity;
		initView();
		
		final User user = Config.getPersistence().user;
		if(user != null) {
			KuwoLog.e(TAG, "User信息[即将自动登录]："+user.uid+",user.sid="+user.sid+","+user.uname+","+user.psw+",isRemeberInfo="+Config.getPersistence().rememberUserInfo+",isLogin="+Config.getPersistence().isLogin);
			if(Config.getPersistence().isLogin) {
				if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
					KuwoLog.i(TAG, "自动登录失败，没有网络！");
				}else {
					new Thread(new Runnable() {
						
						@Override
						public void run() {
							UserLogic userLogic = new UserLogic();
							int result = 10;
							try {
								result = userLogic.autoLogin(user.uid, user.sid);
								Message msg = autoLoginHandler.obtainMessage();
								msg.what = 0;
								msg.arg1 = result;
								autoLoginHandler.sendMessage(msg);
							} catch (IOException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
							
						}
					}).start();
				}
			}
		}
		setupFrame();
		String lastScreen = PreferencesManager.getString(Constants.LAST_SCREEN, FRAME_SQUARE);
		refreshBtnBg(lastScreen);
		KuwoLog.v(TAG, "lastScreen : " + lastScreen);
	}
	
	private Handler autoLoginHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				int result = msg.arg1;
				KuwoLog.i(TAG, "自动登录："+result);
				refreshLocalNoticeNumber();
				break;

			default:
				break;
			}
		}
		
	};
	
	public void refreshLocalNoticeNumber() {
		if(Config.getPersistence().isLogin) {
			if(Config.getPersistence().user.noticeNumber != 0) { //不为0，就显示消息数量
				msgTip.setVisibility(View.VISIBLE);
				msgTip.setText(Config.getPersistence().user.noticeNumber+"");
			}
		}else {
			msgTip.setVisibility(View.INVISIBLE);
		}
	}
	
	public void setTabWidgetState(int visibility) {
		main_bottom_linlayout.setVisibility(visibility);
		songBtn.setVisibility(visibility);
	}
	
	private void initView() {
		main_bottom_linlayout = (LinearLayout) mActivity.findViewById(R.id.main_bottom_linlayout);
		main_bottom_linlayout.setVisibility(View.VISIBLE);
		squareBtn = (ImageView) mActivity.findViewById(R.id.song_bottom_square_btn);
		squareBtn.setOnClickListener(mOnClickListener);

		dynamicBtn = (ImageView) mActivity.findViewById(R.id.song_bottom_dynamic_btn);
		dynamicBtn.setOnClickListener(mOnClickListener);

		songBtn = (ImageView) mActivity.findViewById(R.id.song_bottom_song_btn);
		songBtn.setOnClickListener(mOnClickListener);

		myBtn = (ImageView) mActivity.findViewById(R.id.song_bottom_my_btn);
		myBtn.setOnClickListener(mOnClickListener);

		settingBtn = (ImageView) mActivity.findViewById(R.id.song_bottom_setting_btn);
		settingBtn.setOnClickListener(mOnClickListener);
		
		msgTip = (TextView) mActivity.findViewById(R.id.song_msg_tip);
		msgTip.setVisibility(View.GONE);
	}
	

	/**
	 * 构筑场景Frame
	 */
	private void setupFrame() {
		addTab(FRAME_SQUARE, SquareActivity.class);
//		addTab(FRAME_SQUARE, SquareFragmentActivity.class);
//		addTab(FRAME_LIVE, LiveActivity.class);
		addTab(FRAME_DYNAMIC, DynamicActivity.class);
		addTab(FRAME_SING, SongActivity.class);
		addTab(FRAME_LOCAL, MyHomeActivity.class);
//		addTab(FRAME_LOCAL, LocalActivity.class);
		addTab(FRAME_SETTING, SettingActivity.class);
	}

	/**
	 * 添加Tab页
	 * 
	 * @param tag
	 *            页名
	 * @param intent
	 *            页对应的Activity类型
	 */
	private void addTab(String tag, Class<?> activity) {
		Intent intent = new Intent(mActivity, activity);
		TabSpec tabSpec = mActivity.getTabHost().newTabSpec(tag).setIndicator(tag).setContent(intent);
		mActivity.getTabHost().addTab(tabSpec);
	}
	
	/**
	 * 场景切换
	 * 
	 * @param tag
	 */
	public void switchFrame(String tag, HashMap<String, Serializable> params) {

		PreferencesManager.put(Constants.LAST_SCREEN, tag);
		
		mActivity.getTabHost().setCurrentTabByTag(tag);
		refreshBtnBg(tag);

		KuwoLog.v(TAG, "switchFrame,  " + tag);
	}

	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			int id = v.getId();
			KuwoLog.v(TAG, "onClick " + id);

			switch (id) {
			case R.id.song_bottom_square_btn: // 广场场景
				switchFrame(FRAME_SQUARE, null);
				break;
			case R.id.song_bottom_dynamic_btn: // 动态
				switchFrame(FRAME_DYNAMIC, null);
				break;
			case R.id.song_bottom_song_btn: // 点歌台场景
				switchFrame(FRAME_SING, null);
				break;
			case R.id.song_bottom_my_btn: // 我的场景
				msgTip.setVisibility(View.INVISIBLE);
				switchFrame(FRAME_LOCAL, null);
				break;
			case R.id.song_bottom_setting_btn: 
				switchFrame(FRAME_SETTING, null);
				break;
			}
		}
	};

	private void refreshBtnBg(String type) {

		if (type==null)
			return;
		
		squareBtn.setImageResource(R.drawable.song_bottom_square_btn_selector);
		dynamicBtn.setImageResource(R.drawable.song_bottom_dynamic_btn_selector);
		songBtn.setImageResource(R.drawable.song_bottom_song_btn_selector);
		myBtn.setImageResource(R.drawable.song_bottom_my_btn_selector);
		settingBtn.setImageResource(R.drawable.song_bottom_setting_btn_selector);

		if (type.equals(FRAME_SQUARE)) {
			squareBtn.setImageResource(R.drawable.song_bottom_square_btn_pressed);
		} else if (type.equals(FRAME_DYNAMIC)) {
			dynamicBtn.setImageResource(R.drawable.bt_dynamic_pressed);
		} else if (type.equals(FRAME_SING)) {
			songBtn.setImageResource(R.drawable.song_bottom_song_btn_pressed);
		} else if (type.equals(FRAME_LOCAL)) {
			myBtn.setImageResource(R.drawable.song_bottom_my_btn_pressed);
		} else if (type.equals(FRAME_SETTING)) {
			settingBtn.setImageResource(R.drawable.song_bottom_setting_btn_pressed);
		}
	}
}
