package com.ifeng.commons.upgrade.test;

import java.io.IOException;

import android.test.AndroidTestCase;

import com.ifeng.commons.upgrade.DefaultParser;
import com.ifeng.commons.upgrade.HandlerException;
import com.ifeng.commons.upgrade.UpgradeManager;
import com.ifeng.commons.upgrade.UpgradeResult;
import com.ifeng.commons.upgrade.UpgradeType;
import com.ifeng.commons.upgrade.Version;
import com.ifeng.commons.upgrade.UpgradeResult.Status;

public class UpgradeManagerTest extends AndroidTestCase {
	
	TestApp mockAppContext;
	
	@Override
	protected void setUp() throws Exception {
		super.setUp();
		mockAppContext=new TestApp();
		setContext(mockAppContext);
	}

	public void testCheckUpgrade() throws IOException, HandlerException {
		
		mockAppContext.setTestVersion("1.0.0");
		UpgradeManager manager = new UpgradeManager(getContext());
		UpgradeResult result = manager.checkUpgrade(
				"http://i.ifeng.com/video_test?android=y", new DefaultParser(),true);
		assertEquals(Status.ForceUpgrade, result.getStatus(UpgradeType.Ground));
		assertEquals(Status.NoUpgrade, result.getStatus(UpgradeType.Atmosphere));
		
		assertEquals("http://y1.ifengimg.com/98a1902122a4d751/2012/0413/rdn_4f8801ba4be67.apk", result.getDownUrl(UpgradeType.Ground));
		assertEquals("http://y1.ifengimg.com/98a1902122a4d751/2012/0310/rdn_4f5b3692dfc91.txt", result.getDownUrl(UpgradeType.Atmosphere));

		// try to use construct with atmo version
		mockAppContext.setTestVersion("2.1.0");
		Version mockAtmoVersion = new Version("1.0.0");
		manager = new UpgradeManager(getContext(), mockAtmoVersion);
		result = manager.checkUpgrade(
				"http://i.ifeng.com/video_test?android=y", new DefaultParser(),true);
		assertEquals(Status.AdviseUpgrade, result.getStatus(UpgradeType.Ground));
		assertEquals(Status.ForceUpgrade,
				result.getStatus(UpgradeType.Atmosphere));
		
	}
}
