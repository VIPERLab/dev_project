package com.ifeng.commons.statistic.test;

import android.os.Bundle;
import android.os.Handler;

import com.ifeng.commons.statistic.Statistics;
import com.qad.app.BaseActivity;

public class TestActivity extends BaseActivity {

	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		Statistics.addRecord(Statistics.RECORD_PAGE_FOCUS, "start");
		
		int delay=(int)(Math.random()*1000*80+10*1000);
		showMessage("delay "+delay);
		new Handler().postDelayed(new Runnable(){
			@Override
			public void run() {
				finish();
				TestApp app=(TestApp) getApplication();
				app.startTest();
			}
		},delay);//10s~90s
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		showMessage("closed");
	}
}
