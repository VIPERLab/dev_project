package com.ifeng.news2.fragment;

import java.util.ArrayList;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengListLoadableFragment;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.id;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.bean.ReviewUnit;
import com.ifeng.news2.bean.ReviewUnits;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.widget.ChannelList;
import com.ifeng.news2.widget.LoadableViewWrapper;
import com.ifeng.news2.widget.PageListViewWithHeader.ListViewListener;
import com.qad.annotation.InjectExtras;
import com.qad.loader.ImageLoader.DefaultImageDisplayer;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.StateAble;
import com.qad.render.RenderEngine;
import com.qad.render.ViewFactory;
import com.qad.system.PhoneManager;
import com.qad.view.PageListView;

@SuppressWarnings("unchecked")
public class HotListFragment extends IfengListLoadableFragment<ReviewUnit>
		implements OnItemClickListener, ListViewListener {

	private ChannelList list;
	private ReviewUnits units = new ReviewUnits();
	private ReviewUnit unit;
	private LoadableViewWrapper wrapper;
	public static final String HOT_URL = "hot.channel.url";
	private ArrayList<ListItem> items = new ArrayList<ListItem>();
	@InjectExtras(name = HOT_URL, optional = true)
	private String currentPath;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		currentPath = getArguments().getString(HOT_URL);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		init();
		initFontCount();
		return wrapper;
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		doLoad(1, false, firstLoad);
		reset();
	}
	
	@Override
	public void onResume() {
		super.onResume();
		if (list != null) list.refresh();
	}

	protected void initFontCount() {
		list.initFontCount(getActivity(), ((IfengNewsApp) getActivity()
				.getApplication()).getDisplay(getActivity()));
	}

	@Override
	public void reset() {
		super.reset();
		RenderEngine.render(list, new HotViewFactory(),
				new ArrayList<ListItem>(), IfengNewsApp.getImageLoader(),
				new DefaultImageDisplayer(null));
		list.bindPageManager(getPager());
	}

	private static final class HotViewFactory implements ViewFactory {
		@Override
		public View createView(Context context, int position) {
			return LayoutInflater.from(context).inflate(
					com.ifeng.news2.R.layout.widget_hot_list_item, null);
		}

		@Override
		public void render(View view, Object data, int position) {/*
			ListItem item = (ListItem) data;
			ImageView listIcon = (ImageView) view.findViewById(id.listIcon);
			TextView comments = (TextView) view.findViewById(id.comments);
			IfengTextView introduction = (IfengTextView) view
					.findViewById(id.introduction);
			FrameLayout fl_thumbnail_wrapper = (FrameLayout) view
					.findViewById(id.thumbnail_wrapper);
			if (ChannelList.setListIcon(listIcon, comments,
					item.getLinks()))
				introduction.setFreeSpace(4);// 专题图标占用的空间 暂且认为占四个汉字的空间
			else {
				if (item.isHasVideo()) {
					listIcon.setBackgroundResource(drawable.video_icon);
					listIcon.setVisibility(View.VISIBLE);
					comments.setVisibility(View.GONE);
					introduction.setFreeSpace(3);
				} else {
					introduction.setFreeSpace(ChannelList.getCommentSpace(item
							.getCommentsAll()));
				}
			}

			if (item.getThumbnail() != null && item.getThumbnail().length() > 0) {
				fl_thumbnail_wrapper.setVisibility(View.VISIBLE);
				introduction.setTextWidth(ChannelList.picPx,
						ChannelList.leftPx, ChannelList.rightPx);
			} else {
				fl_thumbnail_wrapper.setVisibility(View.GONE);
				introduction.setTextWidth(0, ChannelList.leftPx,
						ChannelList.rightPx);
			}
		*/}

	}

	public void init() {
		list = new ChannelList(getActivity(), null, PageListView.MANUAL_MODE);
		list.setOnItemClickListener(this);
		list.setListViewListener(this);
		wrapper = new LoadableViewWrapper(getActivity(), list);
		wrapper.setOnRetryListener(this);
	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View view, int position,
			long id) {
		if (view == list.getFooter() || view == list.getHeaderView())
			return;
		int positionInBodyList = position - list.getHeaderViewsCount();
		ChannelList.goToReadPage(getActivity(), positionInBodyList,
				units.getIds(), units.getDocUnits(),
				Config.CHANNEL_ISSUE,
				ConstantManager.ACTION_FROM_APP,
				units.getExtensions().get(positionInBodyList));
	}

	@Override
	public StateAble getStateAble() {
		return wrapper;
	}

	@Override
	public void loadComplete(LoadContext<?, ?, ReviewUnit> context) {
		super.loadComplete(context);
		unit = (ReviewUnit) context.getResult();
		if (unit != null && isCleanDatas) {
			list.resetListFooter(pageSum);
			units.clear();
			items.clear();
			items.addAll(unit.getBody().getItem());
			RenderEngine.render(list, new HotViewFactory(), items, IfengNewsApp
					.getImageLoader(), new DefaultImageDisplayer(null));
		}
		units.add(unit);
		list.setRefreshTime(Config.getCurrentTimeString());
		list.stopRefresh();
		
		if (context.getIsFirstLoaded())
			pullDownRefresh(true);
	}

	@Override
	public boolean loadPage(int pageNo, int pageSize) {
		super.loadPage(pageNo, pageSize);
		doLoad(pageNo, false, firstLoad);
		return false;
	}

	@Override
	public void loadFail(LoadContext<?, ?, ReviewUnit> context) {
		super.loadFail(context);
		list.stopRefresh();
	}

	@Override
	public Class<ReviewUnit> getGenericType() {
		return ReviewUnit.class;
	}

	@Override
	public void onRefresh() {
		loadOnline();
	}

	public void loadOnline() {
		resetRefresh();	
		getLoader().startLoading(new LoadContext<String, LoadListener<ReviewUnit>, ReviewUnit>(
				currentPath + "&pageindex=1", HotListFragment.this,
				ReviewUnit.class, Parsers.newReviewUnitParser(),
				false, LoadContext.FLAG_HTTP_ONLY, true));
	}

	private void doLoad(int pageNo, Boolean isRefresh, Boolean fristLoad) {
		getLoader().startLoading(
				new LoadContext<String, LoadListener<ReviewUnit>, ReviewUnit>(
						currentPath + "&pageindex=" + pageNo, this,
						ReviewUnit.class, Parsers.newReviewUnitParser(),
						fristLoad, isRefresh ? LoadContext.FLAG_HTTP_FIRST : LoadContext.FLAG_CACHE_FIRST, true));
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
	}

	public ChannelList getList() {
		return list;
	}

	public ReviewUnits getUnits() {
		return units;
	}

	public LoadableViewWrapper getWrapper() {
		return wrapper;
	}

	@Override
	public void pullDownRefresh(boolean ignoreExpired) {
		if (!PhoneManager.getInstance(getActivity()).isConnectedNetwork()) return;
		
		if (!ignoreExpired && !IfengNewsApp.getMixedCacheManager().isExpired(currentPath + "&pageindex=1"))
			return;
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
	public void postExecut(LoadContext<?, ?, ReviewUnit> arg0) {
		// TODO Auto-generated method stub
		
	}

}
