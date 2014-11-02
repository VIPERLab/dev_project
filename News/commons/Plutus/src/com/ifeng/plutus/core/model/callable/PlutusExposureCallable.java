package com.ifeng.plutus.core.model.callable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import com.google.myjson.Gson;
import com.ifeng.plutus.core.Constants;
import com.ifeng.plutus.core.PlutusCoreManager;
import com.ifeng.plutus.core.model.bean.AdExposure;
import com.ifeng.plutus.core.model.bean.AdExposures;
import com.ifeng.plutus.core.model.cache.PlutusCorePersistantCache;
import com.ifeng.plutus.core.utils.HttpUtil;

/**
 * Sending exposure data to server
 * @author gao_miao
 */
class PlutusExposureCallable extends PlutusCoreCallable<Boolean> {

	private static final String EXPO_CACHE_NAME = "Expo";
	private static final String URL_PREFFIX = "stat";
	
	private Map<String, String> params = null;
	private PlutusCorePersistantCache<AdExposures> mExpoCache = null;
	
	public PlutusExposureCallable(Map<String, String> params) {
		super(params);
		this.params = params;
		mExpoCache = new PlutusCorePersistantCache<AdExposures>();
	}

	@Override
	public Boolean call() {
		AdExposures cache = handleCache();
		AdExposures content = mapToAdExposures(params);
		if (cache != null && cache.getAdExposure().size() > 0) {
			content.getAdExposure().addAll(cache.getAdExposure());
			mExpoCache.deleteCache(EXPO_CACHE_NAME);
		}
		
		boolean success = postContent(content);
		if (!success) mExpoCache.put(EXPO_CACHE_NAME, content);
		
		return success;
	}

	private AdExposures handleCache() {
		if (mExpoCache.hasCache(EXPO_CACHE_NAME)) {
			return mExpoCache.get(EXPO_CACHE_NAME);
		}
		return null;
	}

	private AdExposures mapToAdExposures(Map<String, String> params) {
		AdExposures adExposures = new AdExposures();
		ArrayList<AdExposure> exposureList = new ArrayList<AdExposure>();
		String startTime = params.get("startTime");
		String endTime = params.get("endTime");
		
		Iterator<Entry<String, String>> it = params.entrySet().iterator();
		Entry<String, String> entry = null;
		while (it.hasNext()) {
			entry = it.next();
			if (entry.getKey().startsWith("adid")) {
				AdExposure exposure = new AdExposure();
				exposure.setAdId(entry.getKey().replace("adid", ""));
				exposure.setValue(entry.getValue());
				exposure.setStartTime(startTime);
				exposure.setEndTime(endTime);
				exposureList.add(exposure);
			}
		}
		adExposures.setAdExposure(exposureList);
		return adExposures;
	}
	
	private String toJsonString(AdExposures adExposures) {
		Gson gson = new Gson();
		return gson.toJson(adExposures);
	}
	
	private boolean postContent(AdExposures content) {
		boolean success = false;
		String url = params.containsKey(Constants.KEY_SUFFIX) ? 
				PlutusCoreManager.getStatisticUrl() + params.get(Constants.KEY_SUFFIX) :
				PlutusCoreManager.getStatisticUrl();
		Map<String, String> map = new HashMap<String, String>();
		map.put(URL_PREFFIX, toJsonString(content));
		try {
			success = HttpUtil.post(url, map);
		} catch (Exception e) {
			e.printStackTrace();
			success = false;
		}
		return success;
	}
}
