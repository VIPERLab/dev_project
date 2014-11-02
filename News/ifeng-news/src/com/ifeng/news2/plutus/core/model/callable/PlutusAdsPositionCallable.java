package com.ifeng.news2.plutus.core.model.callable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import android.util.Log;

import com.google.myjson.Gson;
import com.google.myjson.reflect.TypeToken;
import com.ifeng.news2.plutus.core.Constants;
import com.ifeng.news2.plutus.core.PlutusCoreManager;
import com.ifeng.news2.plutus.core.model.bean.PlutusBean;
import com.ifeng.news2.plutus.core.model.cache.PlutusCorePersistantCache;
import com.ifeng.news2.plutus.core.utils.HttpUtil;

/**
 * Callable to load an advertisement data specified by given position
 * in {@link PlutusAdsPositionCallable#PlutusAdPositionCallable(Map)}
 * 
 * @author gao_miao
 *
 */
class PlutusAdsPositionCallable extends PlutusCoreCallable<ArrayList<PlutusBean>> {

	private String adUrl = null;
	PlutusCorePersistantCache<ArrayList<PlutusBean>> mBeanListCache = null;
	PlutusCorePersistantCache<PlutusBean> mBeanCache = null;
	PlutusCorePersistantCache<byte[]> mResCache = null;
	private ArrayList<PlutusBean> plutusBeans = null ;
	private ArrayList<PlutusBean> tempList = new ArrayList<PlutusBean>();
	
	/**
	 * Constructor, note that AdPosition will be in form of
	 * <br><B>host&adids=adposition&suffix</B>
	 * @param params
	 */
	public PlutusAdsPositionCallable(Map<String, String> params) {
		super(params);
		adUrl = PlutusCoreManager.getUrl() + "adids=" + params.get(Constants.KEY_POSITION) + "&" + params.get(Constants.KEY_SUFFIX);
		mBeanListCache = new PlutusCorePersistantCache<ArrayList<PlutusBean>>();
		mBeanCache = new PlutusCorePersistantCache<PlutusBean>();
		mResCache = new PlutusCorePersistantCache<byte[]>();
	}

	@Override
	public ArrayList<PlutusBean> call() throws Exception {
		plutusBeans = mBeanListCache.get(adUrl);
		if(!tempList.isEmpty()) tempList.clear();
		if(plutusBeans != null && !plutusBeans.isEmpty()){
			for(PlutusBean bean : plutusBeans){
				if (bean != null && bean.getAdMaterials().size() > 0){
					if (System.currentTimeMillis() - mBeanListCache.lastModified(adUrl) < bean.getCacheTime() * 1000) {
						tempList.add(bean);
					}
				}
			}
			if(!tempList.isEmpty()) return tempList ; 
		}

		Log.d("Sdebug", "### PlutusAdsPositionCallable:call: " + adUrl);
		
		byte[] buffer = HttpUtil.get(adUrl);
		if (null == buffer) {
			return null;
		}
		plutusBeans = new Gson().fromJson(new String(buffer, "utf-8"), new TypeToken<ArrayList<PlutusBean>>(){}.getType());
		if(plutusBeans != null){
			mBeanListCache.put(adUrl, tempList);
			if(!tempList.isEmpty()) tempList.clear();
			for(PlutusBean bean : plutusBeans){
				if (null != bean) {
					mBeanCache.put(bean.getAdPositionId(), bean);
					if (bean.getAdMaterials().size() > 0) {
						tempList.add(bean);
					}
				}
			}
			return tempList;
		}
		
		return null;
	}
	
}
