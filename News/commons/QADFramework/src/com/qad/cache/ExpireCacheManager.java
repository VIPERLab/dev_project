package com.qad.cache;


/**
 * Subclass of {@link BaseCacheManager}, dealing with cache expiration.<br>
 * Subclass of this should always check {@link #isExpired(Object, Long)} before returning a
 * cache object.<br>
 * and <b>NOTE THAT</b> this class has not realized {@link #saveCache(Object, Object)} or {@link #clearCache()},
 * subclass should inherite and implement its own method.
 * 
 * @param <Param>
 * @param <Result>
 */
public abstract class ExpireCacheManager<Param, Result> extends BaseCacheManager<Param, Result> {

	protected final long expirePeriod;
	
	/**
	 * Constructor with user specified {@link #expirePeriod}
	 * @param expirePeriod Period of expiration, in milliseconds
	 */
	protected ExpireCacheManager(long expirePeriod) {
		this.expirePeriod = expirePeriod;
	}

	/**
	 * Check if described cache is expired
	 * 
	 * @param param description to identify a specified cache
	 * @return True if cache is expired or false otherwise
	 */
	public boolean isExpired(Param param) {
		return isExpired(param, expirePeriod);
	}

	/**
	 * Check if described cache is expired with given time period
	 * 
	 * @param param Description to identify a specified cache
	 * @param expirePeriod Time period used to check expiration, in milliseconds
	 * @return True if cache is expired or false otherwise
	 */
	public abstract boolean isExpired(Param param, long expirePeriod);
}
