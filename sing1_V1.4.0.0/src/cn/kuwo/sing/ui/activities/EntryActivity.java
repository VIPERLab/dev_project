package cn.kuwo.sing.ui.activities;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.Window;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import cn.kuwo.framework.config.PreferencesManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.ShortcutUtils;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.App;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import de.greenrobot.event.EventBus;

/**
 * 入口Activity
 */
public class EntryActivity extends BaseActivity {
	/*
	 * 入口Activity负责启动场景的协调工作，
	 * 主要控制大场景的跳转
	 * 
	 * 逻辑如下：
	 * 如果应用没有启动过
	 * 初始化应用->验证是否初始化成功->初始化应用环境->场景切换
	 * 
	 * 启动过
	 * 直接进行场景切换
	 */
	
	private final String TAG = "EntryActivity";
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		KuwoLog.d(TAG, "onCreate");
		requestWindowFeature(Window.FEATURE_NO_TITLE);

		ImageView welcomeView = new ImageView(this);
		welcomeView.setBackgroundResource(R.drawable.welcome);
		welcomeView.setScaleType(ScaleType.FIT_XY);
		setContentView(welcomeView);
		
		super.onCreate(savedInstanceState);
		
		PreferencesManager.put("isAppRunning", true);
		
		// 创建Shortcut
		if (!Config.getPersistence().hasCreatedShortcut) {
			ShortcutUtils shortcut = new ShortcutUtils(this, R.string.app_name, R.drawable.logo, EntryActivity.class.getName());
			shortcut.createShortcut();
			Config.getPersistence().hasCreatedShortcut = true;
			Config.savePersistence();
		}
		
		Intent dataFromKuwoPlayer = getIntent();
		if(dataFromKuwoPlayer != null && "cn.kuwo.kwplayer.action.gokwsing".equalsIgnoreCase(dataFromKuwoPlayer.getAction())) {
			App app = (App) getApplication();
			app.ridFromKwPlayer = dataFromKuwoPlayer.getStringExtra("rid");
			app.songNameFromKwPlayer = dataFromKuwoPlayer.getStringExtra("songname");
			app.artistFromKwPlayer = dataFromKuwoPlayer.getStringExtra("artist");
			app.sourceFromKwPlayer = dataFromKuwoPlayer.getStringExtra("source");
			app.albumFromKwPlayer = dataFromKuwoPlayer.getStringExtra("album");
			//发送应用广播让其余的activity都finish掉
			EventBus.getDefault().post("cn.kuow.sing.exit.commandFromKwPlayer");
		}
		
		if(PreferencesManager.getBoolean("isAppRunning")) {
			switchScene();
			return;
		}
		PreferencesManager.put("isAppRunning", true).commit();
		
		new Handler().postDelayed(new Runnable() {
			
			@Override
			public void run() {
				switchScene();
			}
		}, 3000);
	}
	
	/**
	 * 场景切换
	 */
	private void switchScene() {
		Intent intent = null;
		App mApp = (App) getApplication();
		if (mApp.mInitFSFailed) {
        	// 文件系统初始化失败
			intent = new Intent(this, NoSdcardActivity.class);
        } else if(!PreferencesManager.getBoolean(Constants.PREFERENCES_HAS_ACTIVATED)) {
        	//第一次启动，显示用户向导页面
			intent = new Intent(this, GuideActivity.class);
			PreferencesManager.put(Constants.PREFERENCES_HAS_ACTIVATED, true).commit();
		} else {
			//不是第一次启动，显示程序主界面
			intent = new Intent(this, MainActivity.class);
		}
		startActivity(intent);
		finish();
	}
	
	@Override
	protected void onEvent(String event) {
		//不处理,空处理
	}
}
