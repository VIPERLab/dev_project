package com.ifeng.news2.plutus.core;

import com.ifeng.news2.plutus.core.Constants.ERROR;

/**
 * Listener called back durning execution 
 * @author gao_miao
 *
 * @param <Result> Expected returning object   
 */
public interface PlutusCoreListener<Result> {

	/**
	 * Callback on task about to start, runs in the calling thread 
	 */
	public void onPostStart();
	
	/**
	 * Callback on task finished successfully, runs in the calling thread 
	 * @param result Object returned by corresponding callable
	 */
	public void onPostComplete(Result result);
	
	/**
	 * Callback on task finished unsuccessfully, runs in the calling thead
	 * @param error Error type specified by {@link com.ifeng.news2.plutus.core.PlutusCoreManager.ERROR ERROR}
	 */
	public void onPostFailed(ERROR error);
	
}
