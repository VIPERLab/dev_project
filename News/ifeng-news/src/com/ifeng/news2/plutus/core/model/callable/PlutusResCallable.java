package com.ifeng.news2.plutus.core.model.callable;

import java.util.Map;

import com.ifeng.news2.plutus.core.Constants;
import com.ifeng.news2.plutus.core.model.cache.PlutusCorePersistantCache;
import com.ifeng.news2.plutus.core.utils.HttpUtil;

/**
 * Class to load bitmap object specified by {@link PlutusResCallable#PlutusThumbCallable(Map)}
 * @author gao_miao
 *
 */
class PlutusResCallable extends PlutusCoreCallable<byte[]> {
	
	private PlutusCorePersistantCache<byte[]> mThumbCache = null;
	private Map<String, String> map = null;

	/**
	 * Constructor, note that bitmap url should be given in key of {@link PlutusCoreCallable#KEY_IMAGE}
	 * @param params
	 */
	public PlutusResCallable(Map<String, String> params) {
		super(params);
		this.map = params;
		mThumbCache = new PlutusCorePersistantCache<byte[]>();
	}

	@Override
	public byte[] call() throws Exception {
		String imgUrl = map.get(Constants.KEY_IMAGE);
		if (imgUrl == null) return null;
		
		byte[] data = mThumbCache.get(imgUrl);
		if (data == null) {
			data = HttpUtil.get(imgUrl);
			if (data != null)
				mThumbCache.put(imgUrl, data);
		}
		
		return data;
	}

}
