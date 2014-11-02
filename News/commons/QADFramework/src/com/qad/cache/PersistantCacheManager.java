package com.qad.cache;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.io.Serializable;

import android.text.TextUtils;
import android.util.Log;

import com.qad.lang.Files;
import com.qad.loader.Settings;
import com.qad.util.LogHandler;
import com.qad.util.MD5;

/**
 * Class managing caches on the file system, note that if expiration is not needed, 
 * negative value should be assigned to expriePeriod
 */
public class PersistantCacheManager extends ExpireCacheManager<String, Serializable> {

	private File cacheDir;
	private File backupDir;
	private static PersistantCacheManager instance = null;
	
	/**
	 * Retrive a singleton instance of PersistantCacheManager, refer to {@link #PersistantCacheManager(File, File, long)}
	 */
	public static PersistantCacheManager getInstance(long expirePeriod) {
		if (instance == null)
			instance = new PersistantCacheManager(expirePeriod);
		return instance;
	}

	/**
	 * Constructor with default parameters
	 * 
	 * @param cacheDir Default cache directory
	 * @param backupDir Backup cache directory (i.e. /data/data/$package_name/)
	 * @param expirePeriod Expire period for cache
	 */
	protected PersistantCacheManager(long expirePeriod) {
		super(expirePeriod);
		
		cacheDir = Settings.getInstance().getBaseCacheDir();
		backupDir = Settings.getInstance().getBaseBackupDir();
		
		if (cacheDir != null) {
			if (!cacheDir.exists()) cacheDir.mkdirs();
			this.cacheDir = new File(cacheDir, ".data"+Settings.getInstance().getPackageNum());
		}
		
		if (backupDir != null) { 
			if (!backupDir.exists()) backupDir.mkdirs();
			this.backupDir = new File(backupDir, ".data"+Settings.getInstance().getPackageNum());
		}
		
		setupDirs();
	}

	public void setupDirs() {
		if (null != cacheDir && !cacheDir.exists()) {
			cacheDir.mkdirs();
		}
		if (null != backupDir && !backupDir.exists()) {
			backupDir.mkdirs();
		}
	}
	
	@Override
	public boolean isExpired(String param, long expirePeriod) {
		return isFileExpired(param, expirePeriod);
	}
	
	@Override
	public File saveCache(String param, Serializable result) {
		if (!isValidParam(param)) return null;
		
		File file = getCacheFile(param);
		if (file == null) return null;
		try {
			Files.serializeObject(file.getAbsoluteFile(), (Serializable) result);
			return file;
		} catch (Exception e) {
		    // 这里handle所有exception，以避免crash，此处可能抛出IOException和FileNotFoundException
			// e.g. java.lang.RuntimeException:+java.io.FileNotFoundException:+/mnt/sdcard/ifeng/news/cache_temp/.data4.0.5/bda6862487c4247a:
			// +open+failed:+EROFS+(Read-only+file+system)#com.qad.lang.Lang.wrapThrow(Lang.java:85)	com.qad.lang.Streams.fileOut(Streams.java:443)	
			// com.qad.lang.Files.serializeObject(Files.java:944)	com.qad.cache.PersistantCacheManager.saveCache(PersistantCacheManager.java:81)
			
//		    LogHandler.addLogRecord("PersistantCacheManager"
//		            ,"IOException occurs while saving to file " + file.getName() + ", url is " + LogHandler.processURL(param)
//		            , "" + e.getMessage());
			if(file.exists()){
				file.delete();
			}
			return null;
//			LogMessageBean logMsgBean = new LogMessageBean();
//			logMsgBean.setTag("IfengNews");
//			logMsgBean.setPosition("PersistantCacheManager--saveCache");
//			logMsgBean.setUrl(param);
//			
//			if (e != null){
//				String exceptionStr = e.getLocalizedMessage();
//				logMsgBean.setMsg(exceptionStr);
//				Log.d(getClass().getName(), null == exceptionStr?"PersistantCacheManager -- saveCache is exception":exceptionStr);
//			}
//			
//			LogUtil.Log2File(logMsgBean);
		}
	}

	@Override
	public void clearCache() {
		Files.deleteDir(cacheDir);
		Files.deleteDir(backupDir);
		setupDirs();
	}

	@Override
	public long length() {
		long length = 0L;
		File[] files = Files.files(cacheDir, null);
		for (int i = 0; i < files.length; i++)
			length += files[i].length();
		
		files = Files.files(backupDir, null);
		for (int i = 0; i < files.length; i++)
			length += files[i].length();
		
		return length;
	}

	@Override
	public boolean isValidParam(String param) {
		return !TextUtils.isEmpty(param);
	}

	@Override
	public Serializable getCache(String param) {
		if (!isValidParam(param)) return null;
		
		File file = getCacheFile(param);
		if (file == null || !file.exists()) 
			return null;
		try {
			return Files.deserializeObject(file);
		} catch (Exception e) {
			Log.d(getClass().getName(), null == e.getLocalizedMessage()? "PersistantCacheManager -- getCache":e.getLocalizedMessage());
			return null;
		}
	}
	
	/**
	 * Check if the file cache is expired by the last modified time stamp
	 * @param param Param to identify a cache file
	 * @param expirePeriod Expire period, in millionsecond
	 * @return True if file expired, false otherwise
	 */
	private boolean isFileExpired(String param, long expirePeriod) {
		File file = getCacheFile(param);
//		Log.i("Sdebug", "isFileExpired, file " + file.getPath() + ", exist?" + file.exists());
		if (file != null && file.exists())
			if (expirePeriod < 0) return false;
			else return System.currentTimeMillis() - file.lastModified() > expirePeriod;
		return true;
	}
	
	/**
	 * Return cache file according to cache directory accessability
	 * 
	 * @param param Param used to identify a cache file
	 * @return Cache file object or null if cache directory is not accessable
	 */
	protected File getCacheFile(String param) {
		if (!isValidParam(param)) return null;
		
		String fileName = MD5.md5s(param);
		if (cacheDir != null && cacheDir.exists()) {
			return new File(cacheDir, fileName);
		} else if (backupDir != null && backupDir.exists()) {
			return new File(backupDir, fileName);
		} else
			return null;
	}
	
	public void updateSavedItemTime(String param) {
		
		File file = getCacheFile(param);
//		Log.i("Sdebug", "update time for file: " + file.getPath() + ", before time:"+ file.lastModified());
		if (file != null && file.exists()) {
			try {
				boolean res = file.setLastModified(System.currentTimeMillis());
				if (!res) {
					RandomAccessFile raf = new RandomAccessFile(file, "rw");
					long length = raf.length();
					raf.setLength(length + 1);
					raf.setLength(length);
					raf.close();
				}
//				Log.i("Sdebug", "update time for file: res=" + res + " "+ file.getPath() + ", after time:"+ file.lastModified());
			}	catch (Exception e) {
				// just ignore
			}
			
		}
	}
}
