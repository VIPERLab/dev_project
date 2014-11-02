package com.ifeng.plutus.core.model;

import java.util.Map;

import com.ifeng.plutus.core.Constants.ERROR;
import com.ifeng.plutus.core.PlutusCoreListener;
import com.ifeng.plutus.core.model.callable.PlutusCoreCallable;

/**
 * Proxy class which dispatch receiving works to callable in static way
 * @author gao_miao
 */
public class PlutusCoreProxy {

	 /**
	  * Dispatch works according to the given map
	  * @param map &emsp;Map containing the args to dispatch
	  * @param listener &emsp;PlutusCoreListener to callback when finished
	  * @throws IllegalArgumentException&emsp;If values of the map cannot be dispatched
	  */
	@SuppressWarnings("unchecked")
	public static <Result> void dispatch(Map<String, String> map, PlutusCoreListener<Result> listener) throws IllegalArgumentException {
		@SuppressWarnings("rawtypes")
		PlutusCoreCallable callable = PlutusCoreCallable.getCallable(map);

		if (callable == null) 
			fail(listener, ERROR.ERROR_SELECT_NOT_FOUND);
		else 
			PlutusCoreExecutor.getInstance().execute(callable, listener);
	}
	
	/**
	 * Dispatch works according to the given callable
	 * @param callable <br>&emsp;callable will be computed
	 * @param listener <br>&emsp;PlutusCoreListener to callback when finished
	 * @throws IllegalArgumentException
	 */
	public static <Result> void dispatch(PlutusCoreCallable<Result> callable, PlutusCoreListener<Result> listener) throws IllegalArgumentException {
		PlutusCoreExecutor.getInstance().execute(callable, listener);
	}
	
	 /**
	  * Dispatch works according to the given map
	  * @param map &emsp;Map containing the args to dispatch
	  * @return The calculation result
	 * @throws Exception 
	  */
	@SuppressWarnings("unchecked")
	public static <Result> Result dispatch(Map<String, String> map) throws Exception {
		if (map == null)
			throw new IllegalArgumentException("Cannot dispatch query without a map");
		PlutusCoreCallable<?> callable = PlutusCoreCallable.getCallable(map);
		if (callable != null)
			return (Result) callable.call();
		else throw new IllegalArgumentException("Cannot dispatch given argument select = " + map.get("select"));
	}	
	
	/**
	 * Dispatch works according to the given callable
	 * @param callable <br>&emsp;callable will be computed
	 * @return The calculation result
	 * @throws Exception 
	 */
	public static <Result> Result dispatch(PlutusCoreCallable<Result> callable) throws Exception{
		Result result = (Result) callable.call();
		return result;
	}
	
	private static <Result> void fail(PlutusCoreListener<Result> listener, ERROR error) {
		if (listener != null) listener.onPostFailed(error);
		else throw new IllegalArgumentException("value of key select is not valid");
	}

}
