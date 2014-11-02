package com.ifeng.news2.exception;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.text.TextUtils;

import com.ifeng.news2.Config;
import com.qad.util.LogHandler;

public class SendErrorReportService extends Service {

	@Override
	public IBinder onBind(Intent intent) {
		return null;
	}

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		PhoneConfig.phoneConfigInit(this);
		final String data = intent.getStringExtra("data");
		new Thread(new Runnable() {

			@Override
			public void run() {
				if (!TextUtils.isEmpty(data)) {
//					new ExceptionReport(SendErrorReportService.this,
//							PhoneConfig.getUa(), PhoneConfig.getUserkey(),
//							PhoneConfig.getMos(), data,
//							PhoneConfig.getSoftversion(), new NetAttribute(
//									SendErrorReportService.this).getNetType(),
//							Config.PUBLISH_ID).sendAllReport();
				    LogHandler.initialize(SendErrorReportService.this.getApplicationContext()).setPublishId(Config.PUBLISH_ID);
				    LogHandler.singleton().cancelTimer();
				    LogHandler.singleton().sendLogDirectly(data);
				}
				stopService(new Intent(SendErrorReportService.this,SendErrorReportService.class));
			}

		}).start();
		return START_NOT_STICKY;
	}

}
