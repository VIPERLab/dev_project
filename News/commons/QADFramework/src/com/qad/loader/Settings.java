package com.qad.loader;

import java.io.File;

import android.os.Environment;

public class Settings {
	
	private int displayWidth = 480;
	private File baseCacheDir = new File(Environment.getExternalStorageDirectory(), "ifeng/news/cache_temp");
	private File baseBackupDir = new File("/data/data/com.ifeng.news2/cache");
	private String packageNum;
	private long expirePeriod = 5L * 60 * 1000L;

	private static Settings instance = null;
	//本地log开关release版本将此开关设置成false
	public static boolean localLogSwitch = false;
	public String getPackageNum() {
		return packageNum;
	}

	public void setPackageNum(String packageNum) {
		this.packageNum = packageNum;
	}

	private Settings() {
		
	}
	
	public static Settings getInstance() {
		if (instance == null)
			instance = new Settings();
		return instance;
	}
	
	public File getBaseCacheDir() {
		return baseCacheDir;
	}

	public void setBaseCacheDir(File baseCacheDir) {
		this.baseCacheDir = baseCacheDir;
	}

	public File getBaseBackupDir() {
		return baseBackupDir;
	}

	public void setBaseBackupDir(File baseBackupDir) {
		this.baseBackupDir = baseBackupDir;
	}

	public long getExpirePeriod() {
		return expirePeriod;
	}

	public void setExpirePeriod(long expirePeriod) {
		this.expirePeriod = expirePeriod;
	}

	public int getDisplayWidth() {
		return displayWidth;
	}

	public void setDisplayWidth(int displayWidth) {
		this.displayWidth = displayWidth;
	}
}
