package com.ifeng.news2;

import java.io.Serializable;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Toast;

import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.WindowPrompt;
import com.ifeng.news2.widget.LoadableViewWrapper;
import com.qad.loader.BeanLoader;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadableFragment;
import com.qad.loader.StateAble;
import com.qad.util.WToast;
import com.umeng.analytics.MobclickAgent;

public abstract class IfengLoadableFragment<T extends Serializable> extends
		LoadableFragment<T> {
	protected LoadableViewWrapper loadableViewWrapper;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	}
	

	public View getContentView(int layoutResID) {
		LayoutInflater inflater = getActivity().getLayoutInflater();
		View normalView = inflater.inflate(layoutResID, null);
		loadableViewWrapper = new LoadableViewWrapper(getActivity(), normalView);
		loadableViewWrapper.setOnRetryListener(this);
		return loadableViewWrapper;
	}

	@Override
	public void onResume() {
		super.onResume();
		if (Config.ADD_UMENG_STAT)
			MobclickAgent.onResume(getActivity());
		if(StatisticUtil.isBack){
			StatisticUtil.addRecord(this.getActivity()
					, StatisticUtil.StatisticRecordAction.page
					, "id="+StatisticUtil.doc_id+"$ref=back"+"$type=" + StatisticUtil.type);
			StatisticUtil.isBack = false;
		}
	}

	@Override
	public void onPause() {
		super.onPause();
		if (Config.ADD_UMENG_STAT)
			MobclickAgent.onPause(getActivity());
	}

	@Override
	public StateAble getStateAble() {
		return loadableViewWrapper;
	}

	@Override
	public BeanLoader getLoader() {
		return  IfengNewsApp.getBeanLoader();
	}

	@Override
	public void loadFail(LoadContext<?, ?, T> context) {
		super.loadFail(context);
		WindowPrompt.getInstance(getActivity()).showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
	}

	public void pullDownRefresh(boolean ignoreExpired) {
	}
	
	public boolean needRefresh(boolean ignoreExpired){
		return false;
	}
}
