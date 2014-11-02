package com.ifeng.news2.util;

import com.ifeng.news2.IfengNewsApp;
import com.qad.cache.MixedCacheManager;

public class ReadUtil {

	private static final String READ_SUFFIX = "_readed";
	private static MixedCacheManager cacheManager = IfengNewsApp.
			getMixedCacheManager();

	public static void markReaded(String key) {
		if (key != null) {
			cacheManager.saveCache(key + READ_SUFFIX, true);
		}
	}

	public static boolean isReaded(String key) {
		Boolean bool = (Boolean) cacheManager.getCache(key + READ_SUFFIX);
		return bool == null ? false : bool;
	}
}
