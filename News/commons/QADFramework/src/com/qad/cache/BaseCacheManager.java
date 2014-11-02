package com.qad.cache;

import java.io.File;


/**
 * Base class to manage cached data
 * 
 * @param <Param>
 * @param <Result>
 */
public abstract class BaseCacheManager<Param,Result> {

	/**
	 * Called before {@link #getCache(Object)} to check load param and 
	 * setup env
	 * 
	 * @param param Param to check
	 * @return True if param is valid for loading, false otherwise
	 */
	protected boolean isValidParam(Param param) {
		return param != null;
	}
	
	/**
	 * Subclass's own loading behaviours should be implemented in this method
	 * 
	 * @param param Param used for loading
	 * @return Data object loaded
	 */
	public abstract Result getCache(Param param);

	/**
	 * Save a cache object
	 * @param param description to identify a specified cache 
	 * @param result Data object to save
	 * @return saved file if saving successfully, null otherwise
	 */
	public abstract File saveCache(Param param, Result result);
	
	/**
	 * Clear all cached data
	 */
	public abstract void clearCache();
	
	/**
	 * Get total size of cached data
	 * @return Total size of cached data
	 */
	public abstract long length();
	
}
