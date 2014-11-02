package com.ifeng.plutus.core.model.callable;

import java.util.Map;

import com.google.myjson.Gson;
import com.ifeng.plutus.core.Constants;
import com.ifeng.plutus.core.PlutusCoreManager;
import com.ifeng.plutus.core.model.bean.PlutusBean;
import com.ifeng.plutus.core.model.cache.PlutusCorePersistantCache;
import com.ifeng.plutus.core.utils.HttpUtil;

/**
 * Callable to load an advertisement data specified by given position
 * in {@link PlutusAdPositionCallable#PlutusAdPositionCallable(Map)}
 * 
 * @author gao_miao
 *
 */
class PlutusAdPositionCallable extends PlutusCoreCallable<PlutusBean> {

	private String position = null;
	PlutusCorePersistantCache<PlutusBean> mBeanCache = null;
	PlutusCorePersistantCache<byte[]> mResCache = null;
	
	/**
	 * Constructor, note that AdPosition will be in form of
	 * <br><B>host&adids=adposition&suffix</B>
	 * @param params
	 */
	public PlutusAdPositionCallable(Map<String, String> params) {
		super(params);
		position = PlutusCoreManager.getUrl() + "&adids=" + params.get(Constants.KEY_POSITION) + "&" + params.get(Constants.KEY_SUFFIX);
		mBeanCache = new PlutusCorePersistantCache<PlutusBean>();
		mResCache = new PlutusCorePersistantCache<byte[]>();
	}

	@Override
	public PlutusBean call() throws Exception {
		PlutusBean bean = mBeanCache.get(position);
		if (bean != null && bean.getAdMaterials().size() > 0)
			if (System.currentTimeMillis() - mBeanCache.lastModified(position) < bean.getCacheTime() * 1000) {
				return bean;
			}

		bean = new Gson().fromJson(HttpUtil.get(position), PlutusBean.class);
		if (bean != null && bean.getAdMaterials().size() > 0) {
			mBeanCache.put(position, bean);
			return bean;
		}
		
		return null;
	}
}
