package com.ifeng.plutus.core.model.cache;

/**
 * Abstract class of cache
 * @author gao_miao
 *
 * @param <Result> Gerneric type for the cache object 
 */
abstract class PlutusCoreCache<Result> {

	/**
	 * Get a cache object specified by the key
	 * @param key String to identify a cache file, should always be unique 
	 * @return The cache object of type result if saved
	 */
	public abstract Result get(String key);
	
	/**
	 * Put the cache loaded to a file object
	 * @param key String to identify a cache file, should always be unique
	 * @param result result to save
	 */
	public abstract void put(String key, Result result);
	
	/**
	 * Clear all cache
	 */
	public abstract void clear();
	
}
