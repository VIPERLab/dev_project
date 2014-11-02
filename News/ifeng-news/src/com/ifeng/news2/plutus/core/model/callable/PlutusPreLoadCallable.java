package com.ifeng.news2.plutus.core.model.callable;

import java.util.Map;

import com.google.myjson.Gson;
import com.ifeng.news2.plutus.core.Constants;
import com.ifeng.news2.plutus.core.PlutusCoreManager;
import com.ifeng.news2.plutus.core.model.bean.AdResource;
import com.ifeng.news2.plutus.core.model.bean.PlutusBean;
import com.ifeng.news2.plutus.core.model.cache.PlutusCorePersistantCache;
import com.ifeng.news2.plutus.core.utils.HttpUtil;

/**
 * Preload advertisement datas (automatically including resources) given by select key in {@link PlutusPreLoadCallable#PlutusPreLoadCallable(Map)} 
 * @author gao_miao
 *
 */
class PlutusPreLoadCallable extends PlutusCoreCallable<Boolean> {

	private String positions = null;
	private String suffix = null;
	private PlutusCorePersistantCache<PlutusBean> mBeanCache = null;
	private PlutusCorePersistantCache<byte[]> mResCache = null;

	/**
	 * Constructor, note that positions should be given by 'position' key and using '&' to splite 
	 * @param params Map containing loading args
	 */
	public PlutusPreLoadCallable(Map<String, String> params) {
		super(params);
		mBeanCache = new PlutusCorePersistantCache<PlutusBean>();
		mResCache = new PlutusCorePersistantCache<byte[]>();
		positions = params.get(Constants.KEY_POSITION);
		suffix = params.get(Constants.KEY_SUFFIX);
	}

	@Override
	public Boolean call() throws Exception {
		String[] position = positions.split("&");
		for (String key : position) {
			byte[] buffer = HttpUtil.get(PlutusCoreManager.getUrl() + "adids=" + key + "&" + suffix);
			if (buffer == null) continue;
			PlutusBean bean = new Gson().fromJson(new String(buffer, "utf-8"), PlutusBean.class);
			if (bean != null && bean.getAdMaterials() != null && bean.getAdMaterials().size() > 0)
				mBeanCache.put(PlutusCoreManager.getUrl() + "&adids=" + key + suffix, bean);

			if (bean != null && bean.getAdResources() != null && bean.getAdResources().size() > 0) {
				for (AdResource resource : bean.getAdResources()) {
					if (PlutusBean.TYPE_IMG.equals(resource.getType()) && !mResCache.hasCache(resource.getUrl())) {
						byte[] bytes = HttpUtil.get(resource.getUrl());
						if (bytes != null)
							mResCache.put(resource.getUrl(), bytes);
					}
				}
			}
		}
		return true;
	}

}
