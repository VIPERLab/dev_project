package com.ifeng.commons.upgrade.test;

import android.content.Intent;
import android.test.ActivityUnitTestCase;

public class UpgradeActivityTest extends ActivityUnitTestCase<SplashActivity> {

	public UpgradeActivityTest() {
		super(SplashActivity.class);
	}
	
	SplashActivity activity;
	TestApp testApp;
	
	@Override
	protected void setUp() throws Exception {
		super.setUp();
		testApp=new TestApp();
		setApplication(testApp);
		
		startActivity(new Intent(), null, null);
		activity=getActivity();
	}
	
	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
	}
	
	public void testForceUpgrade()
	{
		testApp.setTestVersion("1.0.0");
		getInstrumentation().callActivityOnCreate(activity, null);
		getInstrumentation().waitForIdleSync();
	}
	
	public void testAdviseUpgrade()
	{
		testApp.setTestVersion("2.1.0");
		getInstrumentation().callActivityOnCreate(activity, null);
		getInstrumentation().waitForIdleSync();
	}
	
}
