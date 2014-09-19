package cn.kuwo.sing.ui.activities;

import android.app.Activity;
import android.os.Bundle;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.context.App;

import com.umeng.analytics.MobclickAgent;

import de.greenrobot.event.EventBus;

public class BaseActivity extends Activity {
	private final String TAG = "BaseActivity";
	private EventBus mEventBus;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		App mApp = (App) getApplication();
		mApp.init();
		mEventBus = EventBus.getDefault();
		mEventBus.register(this);
	}
	@Override
	protected void onPause() {
		super.onPause();
		MobclickAgent.onPause(this);
	}

	@Override
	protected void onResume() {
		super.onResume();
		MobclickAgent.onResume(this);
	}
	
	@Override
	protected void onStop() {
		super.onStop();
	}

	@Override
	protected void onDestroy() {
		mEventBus.unregister(this);
		super.onDestroy();
	}
	
	protected void onEvent(String event) {
	   if(event.equals("cn.kuow.sing.exit.commandFromKwPlayer")) {
		   KuwoLog.d(getClass().getSimpleName(), "EventBus onEvent('cn.kuow.sing.exit.commandFromKwPlayer')");
		   this.finish();
	   }
	}
}
