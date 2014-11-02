package com.ifeng.plutus.core.model.callable;

import java.util.Map;

import com.ifeng.plutus.core.Constants;
import com.ifeng.plutus.core.model.cache.PlutusCorePersistantCache;
import com.ifeng.plutus.core.utils.HttpUtil;

/**
 * Class to load bitmap object specified by {@link PlutusResCallable#PlutusThumbCallable(Map)}
 * @author gao_miao
 *
 */
class PlutusResCallable extends PlutusCoreCallable<String> {
	
	private PlutusCorePersistantCache<String> mThumbCache = null;
	private Map<String, String> map = null;

	/**
	 * Constructor, note that bitmap url should be given in key of {@link PlutusCoreCallable#KEY_IMAGE}
	 * @param params
	 */
	public PlutusResCallable(Map<String, String> params) {
		super(params);
		this.map = params;
		mThumbCache = new PlutusCorePersistantCache<String>();
	}

	@Override
	public String call() throws Exception {
		String imgUrl = map.get(Constants.KEY_IMAGE);
		if (imgUrl == null) return null;
		String data = mThumbCache.get(imgUrl);
		if (data == null) {
			data = HttpUtil.get(imgUrl);
			if (data != null)
				mThumbCache.put(imgUrl, data);
		}
		
		return data;
	}

}
