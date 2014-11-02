package com.qad.cache;

import java.io.File;
import java.io.Serializable;
import java.util.Collections;
import java.util.Map;
import java.util.WeakHashMap;

import com.qad.loader.Settings;

/**
 * Cache manager with both memory cache and file cache, will save file cache by calling methods 
 * implemented by super class
 */
public class MixedCacheManager extends PersistantCacheManager {
	private Map<String, Serializable> cacheMap = null;
	private Map<String, Long> cacheStamp = null;
	private static MixedCacheManager instance = null;
	
	/**
	 * Retrive a singleton instance of MixedCacheManager, refer to {@link #MixedCacheManager(File, File, long)}
	 */
	public static MixedCacheManager getInstance() {
		if (instance == null)
			instance = new MixedCacheManager();
		return instance;
	}
	
	/**
	 * Refer to {@link PersistantCacheManager#PersistanceCacheService(File, File, long)}
	 */
	private MixedCacheManager() {
		super(Settings.getInstance().getExpirePeriod());
		
		cacheMap = Collections.synchronizedMap(new WeakHashMap<String, Serializable>());
		cacheStamp = Collections.synchronizedMap(new WeakHashMap<String, Long>());
	}

	@Override
	public boolean isExpired(String param) {
		return this.isExpired(param, expirePeriod);
	}
	
	@Override
	public boolean isExpired(String param, long expirePeriod) {
		if (cacheMap != null && cacheMap.containsKey(param)) {
			if (cacheStamp != null && cacheStamp.get(param) != null) {
				if (expirePeriod < 0) return false;
				else return System.currentTimeMillis() - cacheStamp.get(param).longValue() > expirePeriod;
			}
		}
		return super.isExpired(param, expirePeriod);
	}

	@Override
	public File saveCache(String param, Serializable result) {
		
		cacheMap.put(param, result);
		cacheStamp.put(param, System.currentTimeMillis());
		
		return super.saveCache(param, result);
	}

	/**
	 * Note that calling this method will clear up file caches too, if that is not
	 * your purposation, call {@link #clearPrivateCache()} instead 
	 */
	@Override
	public void clearCache() {
		clearPrivateCache();
		super.clearCache();
	}
	
	/**
	 * Calling this method will clear up all memory caches, if you wish to clear file
	 * caches too, call {@link #clearCache()} instead
	 */
	public void clearPrivateCache() {
		if (cacheMap != null) cacheMap.clear();
		if (cacheStamp != null) cacheStamp.clear();
	}

	@Override
	public long length() {
		return super.length();
	}

	@Override
	public Serializable getCache(String param) {
		Serializable result = null;
		if (cacheMap != null) {
			result = cacheMap.get(param);
			if (result != null)
				return result;
		}
		return super.getCache(param);
	}
	
	public Serializable getFileCache(String param) {
		return super.getCache(param);
	}
	
	@Override
	public void updateSavedItemTime(String param) {
//		Log.i("Sdebug", "update time for link: " + param);
		cacheStamp.put(param, System.currentTimeMillis());
		super.updateSavedItemTime(param);
	}
}
