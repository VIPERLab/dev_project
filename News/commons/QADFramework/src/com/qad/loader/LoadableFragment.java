package com.qad.loader;

import java.io.Serializable;

import android.app.Activity;
import android.view.View;

import com.qad.app.BaseFragment;
import com.qad.render.RenderEngine;

public abstract class LoadableFragment<T extends Serializable> extends
		BaseFragment implements LoadListener<T>, RetryListener {
	
	public boolean canRender;
	/**
	 * 标识是否正在尝试重新加载，只在频道第一页加载失败时发生
	 */
	public boolean isDoingRetry = false;

	/**
	 * 获取泛型类型。泛型擦除导致的
	 * 
	 * @return
	 */
	public abstract Class<T> getGenericType();

	/**
	 * 获得状态切换机，如果存在，将与loader绑定。<br>
	 * 若没有状态机，则直接返回null
	 * 
	 * @return
	 */
	public abstract StateAble getStateAble();

	/**
	 * 获取加载器
	 * 
	 * @return
	 */
	public abstract BeanLoader getLoader();

	@Override
	public void onAttach(Activity activity) {
		super.onAttach(activity);
	}

	/**
	 * 渲染视图，子类根据需求可以重写它
	 * 
	 * @param data
	 */
	public void render(T data) {
		RenderEngine.render(getActivity().getWindow().getDecorView(), data);
	}
	
	public void doRender(){};

	/**
	 * 开始加载。与requestLoading不同，它包含了状态切换，因此务必尽量使用startLoading
	 */
	public void startLoading() {
		StateAble stateAble = getStateAble();
		if (stateAble != null) {
			stateAble.showLoading();
		}
	}

	@Override
	public void loadComplete(LoadContext<?, ?, T> context) {
	    isDoingRetry = false;
//		render(context.getResult());
		StateAble stateAble = getStateAble();
		if (stateAble != null)
			stateAble.showNormal();
	}
	
	@Override
	public void loadFail(LoadContext<?, ?, T> context) {
		if (context.getIsFirstLoaded()) {
			StateAble stateAble = getStateAble();
			if (stateAble != null)
				stateAble.showRetryView();
		}
	}
	
	@Override
	public void postExecut(LoadContext<?, ?, T> context) {
		if(context.getResult()!=null 
				&& !context.isAutoSaveCache()
				&& context.getType() == LoadContext.TYPE_HTTP){
			BeanLoader.getMixedCacheManager().saveCache(context.getParam().toString(),
					(Serializable) context.getResult());
		}
	}

	@Override
	public void onRetry(View view) {
	    isDoingRetry = true;
		startLoading();
	}
	
	@Override
	public void onDetach() {
		super.onDetach();
	}
}
