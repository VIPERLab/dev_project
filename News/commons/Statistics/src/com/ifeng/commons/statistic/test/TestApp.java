package com.ifeng.commons.statistic.test;

import java.io.File;
import java.io.FileWriter;
import java.util.Random;
import java.util.UUID;

import android.content.Intent;
import android.os.Environment;

import com.ifeng.commons.statistic.SendInterceptor;
import com.ifeng.commons.statistic.Statistics;
import com.qad.app.BaseApplication;
import com.qad.util.HttpSender.RequestMethod;

public class TestApp extends BaseApplication {

	private volatile String mUserKey=UUID.randomUUID().toString();
	private RequestMethod method;
	private Random random=new Random(System.currentTimeMillis());
	
	@Override
	public void onCreate() {
		super.onCreate();
        Statistics.ready(this)
    	.setRequestUrl("http://1.ifengmo.sinaapp.com/statistics/statistics.php")
    	.appendDataType("test")
    	.appendNet()
    	.appendIp()
    	.setSessionInterval(20*1000)
    	.appendMobileOS()
    	.setSendInterceptor(new SendInterceptor() {
    		File log=new File(Environment.getExternalStorageDirectory(),"test.log");
			@Override
			public String interceptSend(String entity) {
				String send=entity+"&userKey="+mUserKey+"&method="+method;
				try {
					if(!log.exists()){
						log.createNewFile();
					}
					FileWriter writer=new FileWriter(log, true);
					writer.append(send).append("\r\n").flush();
					writer.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
				showMessage(send);
				return send;
			}
		})
    	.start();
        
        
	}
	
	public void startTest()
	{
		method=random.nextBoolean()?RequestMethod.GET:RequestMethod.POST;
		mUserKey=UUID.randomUUID().toString();
		Statistics.setRequestMode(method);
		Intent intent=new Intent(this,TestActivity.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		startActivity(intent);
	}
}
