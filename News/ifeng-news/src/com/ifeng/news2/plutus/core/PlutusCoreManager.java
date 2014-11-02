package com.ifeng.news2.plutus.core;

import java.net.InetSocketAddress;
import java.util.Map;

import com.ifeng.news2.plutus.core.model.PlutusCoreProxy;
import com.ifeng.news2.plutus.core.model.callable.PlutusCoreCallable;

/**
 * Manager for qurey, loading, caching, etc.<br>
 * Vocabulory:<br>
 *		 &emsp;adPositionId, &emsp;id of advertisement<br>
 *		 &emsp;filterType,&emsp;advertisement type to retrive<br>
 *		 &emsp;startTime,&emsp;start time for an advertisement<br>
 *		 &emsp;endTime,&emsp;end time for an advertisement
 * @author gao_miao
 *
 */
public class PlutusCoreManager {
	
	private static PlutusCoreManager instance = null;
	private int timeOutSecond = 5;
	private String url = null;
	private String statisticUrl = null;
	private String urlSuffix = null;
	private String cacheDir = null;
	private InetSocketAddress inetSocketAddress = null;
	
	private PlutusCoreManager(String urlSuffix) {
		if (urlSuffix == null)
			throw new IllegalArgumentException("urlSuffix cannot be NULL");
		else if (!urlSuffix.contains("uid") || !urlSuffix.contains("screen") 
				|| !urlSuffix.contains("proid") || !urlSuffix.contains("av") || !urlSuffix.contains("os")
				|| !urlSuffix.contains("gv") || !urlSuffix.contains("vt") || !urlSuffix.contains("df"))
			throw new IllegalArgumentException("suffix requires following arguments: " +
						"groundVersion, screenSize, productId, userId, os, atomVersion, vt, deviceFamily");

		// 传入的参数可能以?或&开头，若是应去掉
		this.urlSuffix = (urlSuffix.startsWith("&") || urlSuffix.startsWith("?")) ? urlSuffix.substring(1) : urlSuffix;
	}
	
	/**
	 * Retrive an instance of PlutusCoreManager
	 * @return Instance of PlutusCoreManager
	 */
	public final static PlutusCoreManager getInstance(String urlSuffix){
		if (instance == null)
			instance = new PlutusCoreManager(urlSuffix);
		
		return instance;
	}

	/**
	 * Qurey a specified object restricted by given selectionArgs asynchronously
	 * 
	 * @param selection statement of qurey, can be one of:<br>
	 *            &emsp;select=adPosition&adPositionId=3232&filterType=current<br>
	 *            &emsp;select=thumb&key=http://s2.mimg.ifeng.com/upload/day_121126/201211261625269018.jpg<br>
	 *            &emsp;select=config<br>
	 *            &emsp;select=preLoad<br>
	 *            &emsp;select=exposure&startTime=232332&endTime=343433443<br>
 	 *			<b>The contents to select:</b>
 	 *				<br> &emsp;adPosition &emsp; For a specified advertisement data
 	 *				<br> &emsp;config &emsp; Configurations
 	 *				<br> &emsp;preLoad &emsp; ist of advertisements, load the datas
 	 *				<br> &emsp;exposure &emsp; Send data of exposure</p>
	 *            
	 * @param listener The listener to notify
	 * 
	 * @throws IllegalArgumentException if selectionArgs is null or empty
	 */
	public <Result> void qureyAsync(Map<String, String> selection, PlutusCoreListener<Result> listener) throws IllegalArgumentException {
		if (!selection.containsKey(Constants.SELECT)) {
			if (listener != null)
				listener.onPostFailed(Constants.ERROR.ERROR_MISSING_ARG);
			else
				throw new IllegalArgumentException(selection + " is NOT a valid argument");
			return;
		}
		
		PlutusCoreProxy.dispatch(fillSuffix(selection), listener);
	}

	/**
	 * Submit a query with customized callable, the listener will be triggered after computing
	 * 
	 * @param callable
	 * &emsp;The customized callable to submit
	 * @param listener
	 * &emsp;The listener to notify
	 * @throws IllegalArgumentException
	 */
	public <Result> void qureyAsync(PlutusCoreCallable<Result> callable, PlutusCoreListener<Result> listener) throws IllegalArgumentException {
		PlutusCoreProxy.dispatch(callable, listener);
	}
	
	/**
	 * Qurey a specified object restricted by given selectionArgs synchronously
	 * 
	 * @param selection Please refer to {@link #qureyAsync(String, PlutusCoreListener)} 
	 * @return
	 * &emsp;The calculation result
	 * @throws Exception 
	 */
	public <Result> Result qurey(Map<String, String>  selection) throws Exception {
		if (!selection.containsKey(Constants.SELECT))
			throw new IllegalArgumentException(selection + " is NOT a valid argument");
		
		return PlutusCoreProxy.dispatch(fillSuffix(selection));
	}

	/**
	 * Submit a query with customized callable, the reult will be returned synchronously
	 * 
	 * @param callable
	 * &emsp;The customized callable to submit
	 * @return
	 * &emsp;The calculation result
	 * @throws Exception 
	 */
	public <Result> Result qurey(PlutusCoreCallable<Result> callable) throws Exception {
		return PlutusCoreProxy.dispatch(callable);
	}

	private Map<String, String> fillSuffix(Map<String, String> selection) {
		selection.put(Constants.KEY_SUFFIX, urlSuffix);
		return selection;
	}
	
	public static final String getUrl() {
		if (instance == null) return null;
		return new String(instance.url == null ? Constants.DEFAULT_URL : instance.url);
	}
	
	public static void setUrl(String url) {
		if (instance == null) return;
		instance.url = url;
	}
	
	public static final int getTimeOut() {
		if (instance == null) return 5;
		return instance.timeOutSecond;
	}
	
	public static void setTimeOut(int timeOutSecond) {
		if (instance == null) return;
		instance.timeOutSecond = timeOutSecond;
	}
	
	public static final InetSocketAddress getInetSocketAddress() {
		if (instance == null) return null;
		return instance.inetSocketAddress;
	}
	
	public static void setInetSocketAddress(InetSocketAddress inetSocketAddress) {
		if (instance == null) return;
		instance.inetSocketAddress = inetSocketAddress;
	}
	
	public static final String getCacheDir() {
		if (instance == null) return null;
		return instance.cacheDir == null ? 
				Constants.DEFAULT_CACHE_PATH : instance.cacheDir;
	}
	
	public static void setCacheDir(String cacheDir) {
		if (instance == null) return;
		instance.cacheDir = cacheDir;
	}

	public static String getStatisticUrl() {
		if (instance == null) return null;
		return instance.statisticUrl == null ? 
				Constants.DEFAULT_STATISTIC_URL : instance.statisticUrl;
	}
	
	public static void setStatisticUrl(String statisticUrl) {
		if (instance == null) return;
		instance.statisticUrl = statisticUrl;
	}
}
