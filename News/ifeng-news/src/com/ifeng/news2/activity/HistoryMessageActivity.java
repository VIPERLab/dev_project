package com.ifeng.news2.activity;

import java.util.ArrayList;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.LinearLayout;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengLoadableActivity;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.adapter.ChannelAdapter;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.HistoryMessageUnit;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.ListDisplayStypeUtil;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.RestartManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.widget.ChannelList;
import com.ifeng.news2.widget.IfengBottom;
import com.ifeng.news2.widget.IfengTop;
import com.ifeng.news2.widget.LoadableViewWithFlingDetector;
import com.ifeng.news2.widget.PageListViewWithHeader.ListViewListener;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.StateAble;
import com.qad.system.PhoneManager;
import com.qad.util.OnFlingListener;
import com.qad.view.PageListView;
import com.umeng.analytics.MobclickAgent;

@SuppressWarnings("unchecked")
public class HistoryMessageActivity extends
		IfengLoadableActivity<HistoryMessageUnit> implements
		OnItemClickListener, ListViewListener,OnFlingListener {

	private ChannelList list;
	private HistoryMessageUnit unit;
	private LoadableViewWithFlingDetector wrapper;
	private ArrayList<ListItem> items = new ArrayList<ListItem>();
	private long startTime = 0;
	private IfengBottom ifengBottom;
	private ChannelAdapter adapter;
	private IfengTop ifengTop;
	private Handler handler = new Handler(Looper.getMainLooper());

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);	
		init();
		setContentView();		
		beginStatistic();
	}
	
	private void beginStatistic() {
		// TODO Auto-generated method stub
		StatisticUtil.addRecord(this
				, StatisticUtil.StatisticRecordAction.page
				, "id=pushlist$ref=ys"+"$type=" + StatisticUtil.StatisticPageType.set);
	}

	private void init() {
		adapter = new ChannelAdapter(this, ListDisplayStypeUtil.CHANNEL_HISTORY);
		adapter.setItems(items);
		list = new ChannelList(this, null, PageListView.SINGLE_PAGE_MODE);
		list.setAdapter(adapter);
		list.setOnItemClickListener(this);
		list.setListViewListener(this);
		//设置滑动监听
		list.initFontCount(this,
				((IfengNewsApp) getApplication()).getDisplay(this));
		wrapper = new LoadableViewWithFlingDetector(this, list);
		wrapper.setOnRetryListener(this);		
		//设置滑动监听
		wrapper.setOnFlingListener(this);
	}

	private void setContentView() {
		setContentView(layout.history_message_view);
		LinearLayout historyWrapper = (LinearLayout) findViewById(R.id.history_wrapper);
		LayoutParams params = new LayoutParams(LayoutParams.FILL_PARENT,
				LayoutParams.FILL_PARENT);
		historyWrapper.addView(wrapper, params);
		ifengBottom = (IfengBottom) findViewById(R.id.ifeng_bottom);
		ifengBottom.onClickBack();
		ifengTop = (IfengTop) findViewById(R.id.top);
		ifengTop.setTextContent(getResources().getString(R.string.history));
		ifengTop.setImageContent(drawable.historymessage);
		startLoading();
	}

	@Override
	protected void onResume() {
		RestartManager.checkRestart(this, startTime, RestartManager.LOCK);
		StatisticUtil.doc_id = "noid";
		StatisticUtil.type = StatisticUtil.StatisticPageType.set.toString();
		super.onResume();
		list.refresh();
		if (Config.ADD_UMENG_STAT)
			MobclickAgent.onResume(this);
	}

	@Override
	protected void onPause() {
		super.onPause();
		MobclickAgent.onPause(this);
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		for (int i = 0; i < list.getChildCount(); i++) {
			list.getChildAt(i).setTag(R.id.tag_holder, null);
		}
		list.cleanup();
	}

	@Override
	public void loadComplete(LoadContext<?, ?, HistoryMessageUnit> context) {	
		unit = (HistoryMessageUnit) context.getResult();
		items.clear();
		items.addAll(unit.getBody().getItem());
		adapter.resetBeforeNewsPosition();
		super.loadComplete(context);
		list.setRefreshTime(Config.getCurrentTimeString());
		list.stopRefresh();
		if (context.getType() != LoadContext.TYPE_HTTP) {
			pullDownRefresh(context.getParam().toString(), true);
		}
	}
	
	protected void pullDownRefresh(String url, boolean ignoreExpired) {
		if (!PhoneManager.getInstance(this).isConnectedNetwork())
			return;
		if (!ignoreExpired
				&& !IfengNewsApp.getMixedCacheManager().isExpired(url)) {
			return;
		}
		Handler handler = new Handler(Looper.getMainLooper());
		handler.postDelayed(new Runnable() {

			@Override
			public void run() {
				if (list.startRefresh()) {
				  loadOnline();
                }
			}
		}, ignoreExpired ? Config.AUTO_PULL_TIME : Config.AUTO_PULL_TIME);
	}
	
	@Override
	public void render(HistoryMessageUnit data) {
		adapter.notifyDataSetChanged();
	}

	protected void loadOnline() {
		getLoader()
				.startLoading(
						new LoadContext<String, LoadListener<HistoryMessageUnit>, HistoryMessageUnit>(
								ParamsManager.addParams(this, Config.CHANNEL_ALERTS
										.getChannelUrl()) + "&pageindex=1",
								HistoryMessageActivity.this,
								HistoryMessageUnit.class, Parsers
										.newHistoryMessageUnitParser(), false,
								LoadContext.FLAG_HTTP_ONLY, false));
	}

	@Override
	public void loadFail(LoadContext<?, ?, HistoryMessageUnit> context) {
		super.loadFail(context);
		list.stopRefresh();
	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View view, int position,
			long id) {
		if (view == list.getFooter() || view == list.getHeaderView())
			return;
		if (view.getTag(R.id.tag_data) != null) {
			ArrayList<Extension> links = (ArrayList<Extension>) view
					.getTag(R.id.tag_data);
			String docId = null;
			if (links.size() > 0 && null != links.get(0)){
				docId = links.get(0).getDocumentId();
			} 		
			ChannelList.goToReadPage(HistoryMessageActivity.this, docId,
					Config.CHANNEL_ALERTS, ConstantManager.ACTION_PUSH_LIST,
					links);
		}
	}

	@Override
	public StateAble getStateAble() {
		return wrapper;
	}

	@Override
	public void onRefresh() {
		if (!IfengNewsApp.getMixedCacheManager().isExpired(
				ParamsManager.addParams(Config.CHANNEL_ALERTS.getChannelUrl()
						+ "&pageindex=1"), Config.PULL_TO_REFRESH_EXPIRED_TIME)) {
		    
		    handler.postDelayed(new Runnable() {

                @Override
                public void run() {
                    list.stopRefresh();
                }
            }, Config.FAKE_PULL_TIME);
			return;
		}
		loadOnline();
	}

	public void startLoading() {
		super.startLoading();
		getLoader()
				.startLoading(
						new LoadContext<String, LoadListener<HistoryMessageUnit>, HistoryMessageUnit>(
								ParamsManager.addParams(this, Config.CHANNEL_ALERTS
										.getChannelUrl()) + "&pageindex=1",
								this, HistoryMessageUnit.class, Parsers
										.newHistoryMessageUnitParser(),true,
								LoadContext.FLAG_CACHE_FIRST,false));
	}

	@Override
	public Class<HistoryMessageUnit> getGenericType() {
		return HistoryMessageUnit.class;
	}

	@Override
	protected void onForegroundRunning() {
		super.onForegroundRunning();
		pullDownRefresh(ParamsManager.addParams(this, Config.CHANNEL_ALERTS
										.getChannelUrl()) + "&pageindex=1", false);
	}

	@Override
	protected void onBackgroundRunning() {
		super.onBackgroundRunning();
		startTime = System.currentTimeMillis();
	}

	@Override
	public void postExecut(LoadContext<?, ?, HistoryMessageUnit> context) {		
		HistoryMessageUnit unit = context.getResult();
		if(unit==null || unit.getBody()==null){
			return;
		}
		
		//过滤不正确的数据，如title为空，则不显示该条数据
		filerInvalidItems(unit.getBody().getItem());
		if (unit.getBody().getItem().size() == 0) {
			context.setResult(null);
			return;
		}
		super.postExecut(context);
	}
	
	@Override
    public void onBackPressed() {
		StatisticUtil.isBack = true ; 
		ConstantManager.isSettingsShow = true ; 
        finish();
        overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
    }

	/**
	 * 设置滑动监听
	 */
	@Override
	public void onFling(int flingState) {
		if (flingState == OnFlingListener.FLING_RIGHT) {
            onBackPressed();
		}
	}

}
