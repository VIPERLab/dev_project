package com.ifeng.commons.statistic.test;

import android.os.Bundle;
import android.os.Handler;
import android.os.Process;
import android.view.Menu;
import android.view.MenuItem;

import com.ifeng.commons.statistic.R.layout;
import com.ifeng.commons.statistic.SendInterceptor;
import com.ifeng.commons.statistic.Statistics;

import com.qad.app.BaseActivity;
import com.qad.util.HttpSender.RequestMethod;
import com.qad.util.Utils;
import com.qad.system.PhoneManager;

public class StatisticsActivity extends BaseActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(layout.main);
        PhoneManager.getInstance(this);
        
        Statistics.ready(this)
        	.setRequestUrl("http://stadig.ifeng.com/stat.js")
        	.setRequestMethod(RequestMethod.POST)
        	.appendDataType("test")
        	.appendNet()
        	.appendIp()
//        	.setSessionInterval(500)
        	.setSessionInterval(60*1000)
        	.appendMobileOS()
        	.appendPublishId("myTest")
        	.appendSoftVersion()
        	.appendSoftId("testApp")
        	.appendUserAgent()
        	.appendUserKey()
        	.appendParam("testParam", "testValue")
        	.setSendInterceptor(new SendInterceptor() {
        		int i=0;
				@Override
				public String interceptSend(String entity) {
					showMessage(entity);
					return entity+"&a="+(++i);
				}
			})
        	.start();
        
        
        handler.post(mockPV);
    }
    
    protected void onDestroy() {
    	super.onDestroy();
    	Process.killProcess(Process.myPid());
    }
    
    Handler handler=new Handler();
    int delayMillis=1500;
    Runnable mockPV=new Runnable() {
		@Override
		public void run() {
			Statistics.addRecord(Statistics.RECORD_PAGE_FOCUS, "TestPage");
			handler.postDelayed(mockPV, delayMillis);
			testLog("add PV");
		}
	};
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
    	menu.add(1, 1, 1, "当前网络");
    	menu.add(2, 2, 2, "当前ip地址");
    	menu.add(3,3,3,"屏幕大小");
    	menu.add(4,4,4,"关闭发送");
    	menu.add(5,5,5,"增加pv延迟");
    	return super.onCreateOptionsMenu(menu);
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	switch (item.getItemId()) {
		case 1:
			showMessage(Utils.getNetType(this));
			break;
		case 2:
			showMessage(Utils.getLocalIpAddress());
			break;
		case 3:
			showMessage(Utils.getScreenDescription(this));
			break;
		case 4:
			Statistics.stopInterval();
			break;
		case 5:
			delayMillis+=250;
			break;
		}
    	return super.onOptionsItemSelected(item);
    }
}