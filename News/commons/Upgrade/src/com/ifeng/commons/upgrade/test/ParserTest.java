package com.ifeng.commons.upgrade.test;

import com.ifeng.commons.upgrade.DefaultParser;
import com.ifeng.commons.upgrade.HandlerException;
import com.ifeng.commons.upgrade.UpgradeResult;
import com.ifeng.commons.upgrade.UpgradeType;
import com.ifeng.commons.upgrade.Version;
import com.ifeng.commons.upgrade.UpgradeResult.Status;

import junit.framework.TestCase;

public class ParserTest extends TestCase {

	public void testVersion() {
		// test construct
		Version version = new Version("1.545.6723");
		assertEquals(1, version.major);
		assertEquals(545, version.sub);
		assertEquals(6723, version.fix);
		//
		version = new Version("5.24");
		assertEquals(5, version.major);
		assertEquals(24, version.sub);
		assertEquals(0, version.fix);

		// test equals
		Version v1 = new Version("1.0.24");
		Version v2 = new Version("1.0.24");
		assertTrue(v1.equals(v2));
		v2.fix++;
		assertFalse(v1.equals(v2));

		// test compare
		v1 = new Version("1.0.24");
		v2 = new Version("1.0.0");
		assertTrue(v1.compareTo(v2) > 0);
		v2 = new Version("2.0.1");
		assertTrue(v2.compareTo(v1) > 0);
	}

	public void testJudge() throws HandlerException {
		String content = "{'ground':{'lastestVersion':'1.0.7','compatVersion':'1.0.0','forceUpgrade':['1.0.5','1.0.6'],'downloadUrl':'http:\\/\\/y1.ifengimg.com\\/98a1902122a4d751\\/2012\\/0413\\/rdn_4f8801ba4be67.apk'},'atomsphere':{'lastestVersion':'1.1.20','compatVersion':'1.0.18','forceUpgrade':['1.0.50'],'downloadUrl':'http:\\/appzip.3g.ifeng.com\\/appstore\\/ato1.0.18.zip'}}";
		DefaultParser parser = new DefaultParser();
		// ground 1.0.0-1.0.7 forceUpgrade:1.0.5,1.0.6
		// atmo 1.0.18-1.1.20 forceUpgrade:1.0.50

		// test equals compatVersion
		Version mockAppVersion = new Version("1.0.0");
		Version mockAtmoVersion = new Version("1.0.18");
		UpgradeResult result = parser.parse(content, mockAppVersion,
				mockAtmoVersion,true);
		assertTrue(result.getStatus(UpgradeType.Ground) == Status.AdviseUpgrade);
		assertTrue(result.getStatus(UpgradeType.Atmosphere) == Status.AdviseUpgrade);

		// assert Download Url
		assertEquals("http://y1.ifengimg.com/98a1902122a4d751/2012/0413/rdn_4f8801ba4be67.apk",
				result.getDownUrl(UpgradeType.Ground));
		assertEquals("http://appzip.3g.ifeng.com/appstore/ato1.0.18.zip",
				result.getDownUrl(UpgradeType.Atmosphere));

		// test less than compatVersion
		mockAppVersion.major--;
		mockAtmoVersion.major--;
		result = parser.parse(content, mockAppVersion, mockAppVersion,true);
		assertTrue(result.getStatus(UpgradeType.Ground) == Status.ForceUpgrade);
		assertTrue(result.getStatus(UpgradeType.Atmosphere) == Status.ForceUpgrade);

		// test forceUpgrade
		mockAppVersion = new Version("1.0.5");
		mockAtmoVersion = new Version("1.0.50");
		result = parser.parse(content, mockAppVersion, mockAtmoVersion,true);
		assertTrue(result.getStatus(UpgradeType.Ground) == Status.ForceUpgrade);
		assertTrue(result.getStatus(UpgradeType.Atmosphere) == Status.ForceUpgrade);

		mockAppVersion.fix++;
		result = parser.parse(content, mockAppVersion, mockAtmoVersion,true);
		assertTrue(result.getStatus(UpgradeType.Ground) == Status.ForceUpgrade);

		// test advise upgrade
		mockAppVersion = new Version("1.0.4");
		mockAtmoVersion = new Version("1.0.51");
		result = parser.parse(content, mockAppVersion, mockAtmoVersion,true);
		assertTrue(result.getStatus(UpgradeType.Ground) == Status.AdviseUpgrade);
		assertTrue(result.getStatus(UpgradeType.Atmosphere) == Status.AdviseUpgrade);

		// test no upgrade,which version is greater or equals online version
		mockAppVersion = new Version("1.0.7");
		mockAtmoVersion = new Version("1.1.20");
		result = parser.parse(content, mockAppVersion, mockAtmoVersion,true);
		assertTrue(result.getStatus(UpgradeType.Ground) == Status.NoUpgrade);
		assertTrue(result.getStatus(UpgradeType.Atmosphere) == Status.NoUpgrade);

		mockAppVersion.fix++;
		mockAtmoVersion.fix++;
		assertTrue(result.getStatus(UpgradeType.Ground) == Status.NoUpgrade);
		assertTrue(result.getStatus(UpgradeType.Atmosphere) == Status.NoUpgrade);

	}
}
