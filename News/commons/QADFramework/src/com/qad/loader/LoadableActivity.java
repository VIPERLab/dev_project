package com.qad.loader;

import java.io.Serializable;

import android.os.Bundle;
import android.view.View;

import com.qad.app.BaseFragmentActivity;
import com.qad.render.RenderEngine;
import com.qad.util.WToast;

/**
 * 子类必须实现startLoading方法。可调用Loader{@link AbstractLoader}去执行一个加载任务。<br>
 * 如想要让Loader与状态切换绑定。则只需要将包装的Stateable通过getStateAble()<br>
 * @author 13leaf
 *
 * @param <Result>
 */
public abstract class LoadableActivity<Result extends Serializable> extends BaseFragmentActivity implements LoadListener<Result>, RetryListener{
	
	protected boolean fristLoad = true;

	/**
	 * 获取泛型类型。泛型擦除导致的
	 * @return
	 */
	public abstract Class<Result> getGenericType();
	
	/**
	 * 获得状态切换机，如果存在，将与loader绑定。<br>
	 * 若没有状态机，则直接返回null
	 * @return
	 */
	public abstract StateAble getStateAble();
	
	/**
	 * 获取加载器
	 * @return
	 */
	public abstract BeanLoader getLoader();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
	}
	
	/**
	 * 开始加载。与requestLoading不同，它包含了状态切换，因此务必尽量使用startLoading
	 */
	public void startLoading(){
		StateAble stateAble=getStateAble();
		if(fristLoad&&stateAble!=null){
			stateAble.showLoading();
		}
	}
	
	/**
	 * 渲染视图，子类根据需求可以重写它
	 * @param data
	 */
	public void render(Result data){
		RenderEngine.render(getWindow().getDecorView(), data);
	}
	
	@Override
	public void loadComplete(LoadContext<?, ?, Result> context) {
		render(context.getResult());
		StateAble stateAble=getStateAble();
		if(fristLoad&&stateAble!=null)
			fristLoad = false;
			stateAble.showNormal();
	}
	
	@Override
	public void loadFail(LoadContext<?, ?, Result> context) {
		StateAble stateAble=getStateAble();
		if(fristLoad&&stateAble!=null) {
			stateAble.showRetryView();
		} else {
			new WToast(this).showMessage("加载失败");
		}
	}
	
	@Override
	public void onRetry(View view) {
		startLoading();
	}
	
	@Override
	public void postExecut(LoadContext<?, ?, Result> context) {
		if (context.getResult() != null && !context.isAutoSaveCache()
				&& context.getType() == LoadContext.TYPE_HTTP) {
			BeanLoader.getMixedCacheManager().saveCache(
					context.getParam().toString(),
					(Serializable) context.getResult());
		}
	}
	
}
