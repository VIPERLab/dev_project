package com.ifeng.news2.fragment;

import java.util.ArrayList;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengLoadableFragment;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.bean.ListUnit;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ModuleLinksManager;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.widget.ChannelList;
import com.ifeng.news2.widget.LoadableViewWrapper;
import com.ifeng.news2.widget.PageListViewWithHeader.ListViewListener;
import com.ifeng.news2.widget.TopicFocusView;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.RetryListener;
import com.qad.loader.StateAble;
import com.qad.render.RenderEngine;
import com.qad.system.PhoneManager;
import com.qad.view.PageListView;

public class TopicFragment extends IfengLoadableFragment<ListUnit> implements
		OnItemClickListener, ListViewListener {
	private ArrayList<ListItem> items = new ArrayList<ListItem>();
	private ChannelList list;
	private LoadableViewWrapper wrapper;
	private TopicFocusView focusView;
	Channel channel;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		focusView = new TopicFocusView(getActivity());
		list = new ChannelList(getActivity(), null,PageListView.SINGLE_PAGE_MODE);	
		list.setOnItemClickListener(this);
		list.setListViewListener(this);
		list.addHeaderView(focusView);
		list.setPadding(0, -3, 0, 0);
		list.setDividerHeight(0);
		list.setDivider(getResources().getDrawable(R.drawable.topic_divider));
		list.setHeaderDividersEnabled(false);
		channel = Config.CHANNEL_TOPIC;
		wrapper = new LoadableViewWrapper(getActivity(), list);
		wrapper.setOnRetryListener(new RetryListener() {
			@Override
			public void onRetry(View arg0) {
				startLoading();
			}
		});
		loadCacheFrist();
		startLoading();
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		if(wrapper.getParent()!=null){
			((ViewGroup)wrapper.getParent()).removeView(wrapper);
		}
		return wrapper;
	}

	@Override
	public StateAble getStateAble() {
		return wrapper;
	}

	@Override
	public Class<ListUnit> getGenericType() {
		return ListUnit.class;
	}

	@Override
	public void startLoading() {
		super.startLoading();
		doLoading(false);
	}

	private void doLoading(boolean isRefresh) {
		getLoader().startLoading(
				new LoadContext<String, LoadListener<ListUnit>, ListUnit>(
						ParamsManager.addParams(channel.getChannelUrl()), this,
						ListUnit.class, Parsers.newListUnitParser(),
						!isRefresh, isRefresh ? LoadContext.FLAG_HTTP_FIRST : LoadContext.FLAG_CACHE_FIRST, true));

	}

	public void loadOnline() {
		getLoader().startLoading(
				new LoadContext<String, LoadListener<ListUnit>, ListUnit>(
						ParamsManager.addParams(channel.getChannelUrl()), TopicFragment.this,
						ListUnit.class, Parsers.newListUnitParser(),
						false, LoadContext.FLAG_HTTP_ONLY, true));
	}

	public void loadCacheFrist() {
		list.refresh();
		list.forceFinished();
		doLoading(false);
	}

	@Override
	public void loadComplete(LoadContext<?, ?, ListUnit> context) {
		super.loadComplete(context);
		list.setRefreshTime(Config.getCurrentTimeString());
		list.stopRefresh();
		if (context.getIsFirstLoaded())
			pullDownRefresh(true);
	}

	@Override
	public void loadFail(LoadContext<?, ?, ListUnit> context) {
		super.loadFail(context);
		list.stopRefresh();
	}

	@Override
	public void render(ListUnit data) {
		items = data.getUnitListItems();
		if(items!=null && items.size()>0){
			focusView.initFocusView(getActivity(), items.get(0));
			items.remove(0);
			RenderEngine.render(list, layout.widget_topic_item, items);
		}
	}

	@Override
	public void onItemClick(AdapterView<?> adapter, View view, int position,
			long arg3) {
		int count = list.getHeaderViewsCount();
		if (position < count)
			return;
		ArrayList<Extension> links = items.get(position - count).getLinks();
		if(links == null || links.size() == 0) return;
		Extension defaultExtension = ModuleLinksManager.getTopicLink(links);
		if(defaultExtension!=null) {
			IntentUtil.startActivityWithPos(getActivity(), defaultExtension,position);
		}
	}

	@Override
	public void onRefresh() {
		loadOnline();
	}
	
	public void loadTopicFocus(){
		doLoading(false);
	}
	
	public final ChannelList getList() {
		return list;
	}

	public final LoadableViewWrapper getWrapper() {
		return wrapper;
	}

	public final TopicFocusView getFocusView() {
		return focusView;
	}

	@Override
	public void pullDownRefresh(boolean ignoreExpired) {
		if (!PhoneManager.getInstance(getActivity()).isConnectedNetwork()) return;
		
		String param = ParamsManager.addParams(channel.getChannelUrl());
		if (!ignoreExpired && !IfengNewsApp.getMixedCacheManager().isExpired(param)) return;
		
		Handler handler = new Handler(Looper.getMainLooper());
		handler.postDelayed(new Runnable() {
			
			@Override
			public void run() {
				if (list.startRefresh()) {
				  loadOnline();
                }
			}
		}, ignoreExpired ? Config.AUTO_PULL_TIME : Config.AUTO_PULL_TIME * 3);
		
	}

	@Override
	public void postExecut(LoadContext<?, ?, ListUnit> arg0) {
		// TODO Auto-generated method stub
		
	}

}
