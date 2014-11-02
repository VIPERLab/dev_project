package com.ifeng.commons.upgrade.test;

import android.content.Context;
import android.content.Intent;
import android.net.wifi.WifiManager;
import android.test.ActivityUnitTestCase;
import android.test.suitebuilder.annotation.MediumTest;

import com.ifeng.commons.upgrade.R.id;
import com.ifeng.commons.upgrade.R.layout;
import com.ifeng.commons.upgrade.Upgrader;
import com.ifeng.commons.upgrade.download.GroundReceiver;

public class UpgraderTest extends ActivityUnitTestCase<SplashActivity> {

	public UpgraderTest() {
		super(SplashActivity.class);
	}

	Intent forwardIntent;
	SplashActivity activity;
	String upgradeUrl="http://i.ifeng.com/video_test?android=y";

	@Override
	protected void setUp() throws Exception {
		super.setUp();
		startActivity(new Intent(), null, null);
		activity = getActivity();
		forwardIntent = new Intent(activity, MainActivity.class);
	}

	public void testGroundReceiverCheck() {
		try {
			new GroundReceiver.Builder(activity).build();
			fail("need to set layout_upgrade");
		} catch (RuntimeException e) {
			System.out.println(e.getClass() + ":" + e.getMessage());
		}
		newGroundReceiver();
	}

	private GroundReceiver newGroundReceiver() {
		return new GroundReceiver.Builder(activity)
				.setUpdateLayout(layout.upgrade_noti)
				.setProgressBarId(id.upgrade_down_pb).build();
	}

	public void testUpgraderCheck() {
		GroundReceiver receiver = newGroundReceiver();
		try {
			Upgrader.ready(activity).setGroundReceiver(receiver).setForwardIntent(forwardIntent).upgrade();
			fail("need to set upgrade url!");
		} catch (RuntimeException e) {
			System.out.println(e.getClass() + ":" + e.getMessage());
		}
		try {
			Upgrader.ready(activity).setGroundReceiver(receiver).setUpgradeUrl(upgradeUrl).upgrade();
			fail("need to set forwarding intent!");
		} catch (RuntimeException e) {
			System.out.println(e.getClass() + ":" + e.getMessage());
		}
	}

	@MediumTest
	public void testUpgradeHandler() throws InterruptedException {
		GroundReceiver receiver=newGroundReceiver();
		
		Upgrader.ready(activity).setGroundReceiver(receiver).setForwardIntent(forwardIntent).setUpgradeUrl(upgradeUrl).upgrade();
		
		wasteTime();
		assertFalse(activity.isFinished());
		
		// test handler error
		WifiManager manager = (WifiManager) activity
				.getSystemService(Context.WIFI_SERVICE);
		manager.disconnect();
		wasteTime();
		Upgrader.ready(activity).setGroundReceiver(receiver).setForwardIntent(forwardIntent).setUpgradeUrl(upgradeUrl).upgrade();
		wasteTime();
		assertTrue(activity.isFinished());
		manager.reconnect();
	}

	private void wasteTime() {
		@SuppressWarnings("unused")
		int k=0;
		for(int i=0;i<9999;i++)
			for(int j=0;j<100;j++)
				k=i+j/9%2;
		
	}

}
