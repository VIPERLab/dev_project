package com.ifeng.news2.sport_live;

import java.util.ArrayList;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.ViewGroup.LayoutParams;
import android.widget.LinearLayout;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengLoadableActivity;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.adapter.SportLiveFactAdapter;
import com.ifeng.news2.sport_live.entity.SportFactItem;
import com.ifeng.news2.sport_live.entity.SportFactUnit;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.widget.ChannelList;
import com.ifeng.news2.widget.IfengBottom;
import com.ifeng.news2.widget.LoadableViewWrapper;
import com.ifeng.news2.widget.PageListViewWithHeader.ListViewListener;
import com.qad.form.BasePageAdapter;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.StateAble;
import com.qad.view.PageListView;

/**
 * 毒舌页
 * 
 * @author SunQuan:
 * @version 创建时间：2013-7-30 下午1:45:01
 * 
 */

public class PoisonousWordsActivity extends
		IfengLoadableActivity<SportFactUnit> implements ListViewListener {

	private ChannelList list;
	private String url;
	private ArrayList<SportFactItem> items;
	private SportFactUnit sportFactUnit;
	private BasePageAdapter<SportFactItem> adapter;
	private LoadableViewWrapper wrapper;
	private LinearLayout historyWrapper;
	private IfengBottom ifengBottom;
	private Handler handler = new Handler(Looper.getMainLooper());

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		init();
		setContentView();
	}

	private void init() {
		url = getIntent().getStringExtra("URL");
		items = new ArrayList<SportFactItem>();
		list = new ChannelList(this, null, PageListView.SINGLE_PAGE_MODE);
		adapter = new SportLiveFactAdapter(PoisonousWordsActivity.this,
				SportLiveFactAdapter.POISONOUS_TYPE);
		adapter.setItems(items);
		list.setAdapter(adapter);
		list.setListViewListener(this);
		wrapper = new LoadableViewWrapper(this, list);
		wrapper.setOnRetryListener(this);
	}

	private void setContentView() {
		setContentView(R.layout.sport_live_poisnoise);
		historyWrapper = (LinearLayout) findViewById(R.id.sport_live_poisonous_wrapper);
		LayoutParams params = new LayoutParams(LayoutParams.FILL_PARENT,
				LayoutParams.FILL_PARENT);
		historyWrapper.addView(wrapper, params);
		ifengBottom = (IfengBottom) findViewById(R.id.ifeng_bottom);
		ifengBottom.onClickBack();
		startLoading();
	}

	@Override
	public void startLoading() {
		super.startLoading();
		IfengNewsApp
				.getBeanLoader()
				.startLoading(
						new LoadContext<String, LoadListener<SportFactUnit>, SportFactUnit>(
								ParamsManager.addParams(url),
								PoisonousWordsActivity.this,
								SportFactUnit.class, Parsers
										.newSportLiveFactUnitParser(), true,
								LoadContext.FLAG_HTTP_FIRST, false));
	}
	
	private void loadData(){
		IfengNewsApp
		.getBeanLoader()
		.startLoading(
				new LoadContext<String, LoadListener<SportFactUnit>, SportFactUnit>(
						ParamsManager.addParams(url),
						PoisonousWordsActivity.this,
						SportFactUnit.class, Parsers
								.newSportLiveFactUnitParser(), false,
						LoadContext.FLAG_HTTP_FIRST, false));
	}

	@Override
	public void postExecut(LoadContext<?, ?, SportFactUnit> context) {
		sportFactUnit = context.getResult();
		if (sportFactUnit == null || sportFactUnit.getBody() == null) {
			context.setResult(null);
		}
	}

	@Override
	public void loadComplete(LoadContext<?, ?, SportFactUnit> context) {
		sportFactUnit = context.getResult();
		items.clear();
		items.addAll(sportFactUnit.getBody());
		super.loadComplete(context);
		list.setRefreshTime(Config.getCurrentTimeString());
		list.stopRefresh();
	}

	@Override
	public void loadFail(LoadContext<?, ?, SportFactUnit> context) {
		super.loadFail(context);
		list.stopRefresh();
	}

	@Override
	public void onRefresh() {
		String param = ParamsManager
				.addParams(this, Config.SPORT_LIVE_FACT_URL);

		if (!IfengNewsApp.getMixedCacheManager().isExpired(param, 60 * 1000)) {
			handler.postDelayed(new Runnable() {

				@Override
				public void run() {
					list.stopRefresh();
				}
			}, Config.FAKE_PULL_TIME);
			return;
		}
		loadData();
	}

	@Override
	public Class<SportFactUnit> getGenericType() {
		return SportFactUnit.class;
	}

	@Override
	public StateAble getStateAble() {
		return wrapper;
	}

}
