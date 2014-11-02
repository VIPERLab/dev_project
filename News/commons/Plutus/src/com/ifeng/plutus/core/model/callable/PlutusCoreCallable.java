package com.ifeng.plutus.core.model.callable;

import java.util.Map;
import java.util.concurrent.Callable;

import com.ifeng.plutus.core.Constants;

public abstract class PlutusCoreCallable<Result> implements Callable<Result>{
	
	public PlutusCoreCallable(Map<String, String> params) {
	}
	
	@Override
	public abstract Result call() throws Exception;
	
	/**
	 * Return a responsable callable object according to select
	 * @param map Map with select args
	 * @return callable objet or null if corresponding object does not exist
	 */
	public static PlutusCoreCallable<?> getCallable(Map<String, String> map) {
		if (map == null || !map.containsKey(Constants.SELECT))
			return null;
		
		PlutusCoreCallable<?> callable = null;
		String select = map.get(Constants.SELECT);
		if (Constants.SELE_PRELOAD.equals(select)) 				callable = new PlutusPreLoadCallable(map);
		else if (Constants.SELE_ADPOSITION.equals(select))	callable = new PlutusAdPositionCallable(map);
		else if (Constants.SELE_THUMB.equals(select)) 			callable = new PlutusResCallable(map);
		else if (Constants.SELE_EXPOSURE.equals(select)) 	callable = new PlutusExposureCallable(map);
		
		return callable;
	}

}
