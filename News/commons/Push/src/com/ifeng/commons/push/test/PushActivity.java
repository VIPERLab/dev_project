package com.ifeng.commons.push.test;

import android.content.ComponentName;
import android.content.Intent;
import android.os.Bundle;

import com.ifeng.commons.push.PushEntity;
import com.ifeng.commons.push.PushService;
import com.ifeng.commons.push.R;
import com.qad.app.BaseActivity;

public class PushActivity extends BaseActivity {
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
//        registerManagedReceiver(new TestReceiver());
        /*Intent intent=new Intent();
        intent.setClassName("com.ifeng.news2", "com.ifeng.news2.PushReceiver");
		intent.putExtra(PushService.EXTRA_PRODUCT, "IfengNews2_android_v2");
		PushEntity entity=new PushEntity();
		entity.setId("38552449");
		entity.setMsg("test1");
		intent.putExtra(PushService.EXTRA_ENTITY, entity);
		sendBroadcast(intent);
		
		intent=new Intent();
		intent.setClassName("com.ifeng.news2", "com.ifeng.news2.PushReceiver");
		intent.putExtra(PushService.EXTRA_PRODUCT, "IfengNews2_android_v2");
		entity=new PushEntity();
		entity.setId("38563550");
		entity.setMsg("test2");
		intent.putExtra(PushService.EXTRA_ENTITY, entity);
		sendBroadcast(intent);*/
		
		Intent intent=new Intent(this,PushService.class);
		intent.putExtra(PushService.EXTRA_PRODUCT, "IfengNews2_android_v2");
		startService(intent);
		
		Intent intent2=new Intent();
		ComponentName componentName=new ComponentName(this,TestReceiver.class);
		intent2.setComponent(componentName);
		intent2.setAction(PushService.ACTION_BASE+"IfengNews2_android_v2");
		sendBroadcast(intent2);
    }
}