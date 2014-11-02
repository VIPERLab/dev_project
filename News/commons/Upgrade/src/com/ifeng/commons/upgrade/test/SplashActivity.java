package com.ifeng.commons.upgrade.test;

import android.content.Intent;
import android.os.Bundle;

import com.ifeng.commons.upgrade.R;
import com.ifeng.commons.upgrade.R.id;
import com.ifeng.commons.upgrade.R.layout;
import com.ifeng.commons.upgrade.Upgrader;
import com.ifeng.commons.upgrade.download.GroundReceiver;
import com.qad.app.BaseActivity;

public class SplashActivity extends BaseActivity {
	/** Called when the activity is first created. */
	
	boolean finished;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.splash);

		GroundReceiver receiver=
				new GroundReceiver.Builder(this)
					.setUpdateLayout(layout.upgrade_noti)
					.setProgressBarId(id.upgrade_down_pb)
					.setPercentTextId(id.upgrade_down_percent)
					.setTitleTextId(id.upgrade_down_title)
					.build();
		Upgrader.ready(this).setUpgradeUrl(
				"http://i.ifeng.com/video_test?android=y")
				.setForwardIntent(new Intent(this,MainActivity.class))
				.setGroundReceiver(receiver)
				.upgrade();
	}
	
	public boolean isFinished() {
		return finished;
	}
	
	@Override
	public void finish() {
		super.finish();
		finished=true;
	}
}