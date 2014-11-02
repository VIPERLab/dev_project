package com.qad.loader;

import com.qad.cache.MixedCacheManager;

public class BeanLoader implements Loader {
	
	private static LoaderExecutor executor = null;
	private static BeanLoader instance = new BeanLoader();
	
	public static BeanLoader getInstance() {
		return instance;
	}
	
	private BeanLoader() {
		executor = new LoaderExecutor(this.getClass().getSimpleName());
	}
	
	/**
	 * Retrive the MixedCacheManager object of LoaderImpl
	 * @return MixedCacheManager object of LoaderImpl
	 */
	public static final MixedCacheManager getMixedCacheManager() {
		
		return MixedCacheManager.getInstance();
	}
	
	public Settings getSettings() {
		return Settings.getInstance();
	} 
	
	@Override
	public <Result> void onPreLoad(LoadContext<?, ?, Result> context) {
		
	}

	@Override
	public <Result> void startLoading(LoadContext<?, ?, Result> context) {
		executor.execute(context, LoaderExecutor.EXECUTE_ORDER.FILO_ORDER);
	}

	@Override
	public <Result> void onPostLoad(LoadContext<?, ?, Result> context) {
		
	}

	@Override
	public <Result> boolean cancelLoading(LoadContext<?, ?, Result> context) {
		return false;
	}

	@Override
	public void destroy(boolean now) {
		
	}
}
