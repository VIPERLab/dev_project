package com.qad.loader;

import android.view.View;
import com.qad.form.PageEntity;
import com.qad.form.PageLoader;
import com.qad.form.PageManager;
import com.qad.loader.LoadContext;

public abstract class ListLoadableFragment<T extends PageEntity> extends
		LoadableFragment<T> implements PageLoader<T> {

	public boolean firstLoad = true;
	public int pageSum;
	@SuppressWarnings("rawtypes")
	public PageManager pager;
	public int loadNo;
	protected int pageSize = 20;
	public boolean isCleanDatas = false;

	@Override
	public void startLoading() {
		throw new UnsupportedOperationException();
	}

	public void render(T data) {
		throw new UnsupportedOperationException();
	}

	public void reset() {
		pageSum = 0;
		firstLoad = true;
		pager = null;
		loadNo = 0;
		pageSize = 20;
	}

	public void resetRefresh() {
		pageSize = 20;
		loadNo = 0;
		getPager().resetPageNo();
		isCleanDatas = true;
	}

	@Override
	public boolean loadPage(int pageNo, int pageSize) {
		if (firstLoad) {
			getStateAble().showLoading();
		}
		return false;
	}

	@SuppressWarnings("unchecked")
	@Override
	public void loadComplete(LoadContext<?, ?, T> context) {
		if (firstLoad) {
			firstLoad = false;
			getStateAble().showNormal();
			isDoingRetry = false;
		}
		PageEntity entity = (PageEntity) context.getResult();
		pageSum = entity.getPageSum();
		getPager().notifyPageLoad(LOAD_COMPLETE, ++loadNo, pageSum,
				entity.getData());
	}

	@SuppressWarnings("unchecked")
	@Override
	public void loadFail(LoadContext<?, ?, T> context) {
		// 仅当首页加载失败时才做状态切换
		if (firstLoad && getStateAble() != null) {
			getStateAble().showRetryView();
		}
		getPager().notifyPageLoad(LOAD_FAIL, loadNo, pageSum,
				context.getResult());
	}
	
	@Override
	public void postExecut(LoadContext<?, ?, T> context) {
		super.postExecut(context);
	}

	@Override
	public void onRetry(View view) {
	    isDoingRetry = true;
		loadPage(1, pageSize);
	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Override
	public PageManager getPager() {
		if (pager == null) {
			pager = new PageManager(this, pageSize);
		}
		return pager;
	}

}
