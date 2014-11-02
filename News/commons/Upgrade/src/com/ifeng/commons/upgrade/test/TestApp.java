package com.ifeng.commons.upgrade.test;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.test.mock.MockApplication;
import android.test.mock.MockPackageManager;

import com.ifeng.commons.upgrade.R.id;
import com.ifeng.commons.upgrade.R.layout;
import com.ifeng.commons.upgrade.UpgradeNotify;

@UpgradeNotify(
		layout_update=layout.upgrade_noti,
		id_progressbar=id.upgrade_down_pb,
		id_percent=id.upgrade_down_percent,
		id_title=id.upgrade_down_title
		)
public class TestApp extends MockApplication{

	private String testVersion="1.0.0";
	private TestPackageManager packageManager;
	
	class TestPackageManager extends MockPackageManager
	{
		@Override
		public PackageInfo getPackageInfo(String packageName, int flags)
				throws NameNotFoundException {
			PackageInfo info=new PackageInfo();
			info.versionName=testVersion;
			return info;
		}
	}
	
	public TestApp()
	{
		packageManager=new TestPackageManager();
	}
	
	public void setTestVersion(String version)
	{
		testVersion=version;
	}
	
	@Override
	public String getPackageName() {
		return "com.ifeng.commons.upgrade";
	}

	@Override
	public PackageManager getPackageManager() {
		return packageManager;
	}
}
