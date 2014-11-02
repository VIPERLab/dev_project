package com.ifeng.news2.plutus.core.model.callable;

import java.util.Map;

import android.util.Log;

import com.google.myjson.Gson;
import com.ifeng.news2.plutus.core.Constants;
import com.ifeng.news2.plutus.core.PlutusCoreManager;
import com.ifeng.news2.plutus.core.model.bean.PlutusBean;
import com.ifeng.news2.plutus.core.model.cache.PlutusCorePersistantCache;
import com.ifeng.news2.plutus.core.utils.HttpUtil;

/**
 * Callable to load an advertisement data specified by given position
 * in {@link PlutusAdPositionCallable#PlutusAdPositionCallable(Map)}
 * 
 * @author gao_miao
 *
 */
class PlutusAdPositionCallable extends PlutusCoreCallable<PlutusBean> {

	private String adUrl = null;
	private String adPosition = null;
	PlutusCorePersistantCache<PlutusBean> mBeanCache = null;
	PlutusCorePersistantCache<byte[]> mResCache = null;
	
	/**
	 * Constructor, note that AdPosition will be in form of
	 * <br><B>host&adids=adposition&suffix</B>
	 * @param params
	 */
	public PlutusAdPositionCallable(Map<String, String> params) {
		super(params);
		adPosition = params.get(Constants.KEY_POSITION);
		adUrl = PlutusCoreManager.getUrl() + "adids=" + adPosition + "&" + params.get(Constants.KEY_SUFFIX);
		mBeanCache = new PlutusCorePersistantCache<PlutusBean>();
		mResCache = new PlutusCorePersistantCache<byte[]>();
	}

	@Override
	public PlutusBean call() throws Exception {
		PlutusBean bean = mBeanCache.get(adPosition);
//		Log.w("Sdebug", "PlutusAdPositionCallable call: " + position);
		// 为减少广告接口的访问，当没有广告内容时也在超时时才再访问广告接口
		if (null != bean
			&& System.currentTimeMillis() - mBeanCache.lastModified(adPosition) < bean.getCacheTime() * 1000) {
			if (bean.getAdMaterials().size() > 0)
				return bean;
			else 
				return null;
		}

		Log.d("Sdebug", "PlutusAdPositionCallable:call: " + adUrl);
		byte[] buffer = HttpUtil.get(adUrl);
		if (null == buffer) {
			return null;
		}
		bean = new Gson().fromJson(new String(buffer, "utf-8"), PlutusBean.class);
		if (null != bean) {
			mBeanCache.put(adPosition, bean);
			if (bean.getAdMaterials().size() > 0) {
				return bean;
			}
		}
		
		return null;
	}
}
