package com.ifeng.news2.fragment;

import java.util.ArrayList;
import android.content.Context;
import android.net.Uri;
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
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.widget.ChannelList;
import com.ifeng.news2.widget.LoadableViewWrapper;
import com.ifeng.news2.widget.PageListViewWithHeader.ListViewListener;
import com.qad.loader.ImageLoader.DefaultImageDisplayer;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.StateAble;
import com.qad.render.RenderEngine;
import com.qad.render.ViewFactory;
import com.qad.system.PhoneManager;
import com.qad.view.PageListView;

@SuppressWarnings("unchecked")
public class ReviewFragment extends IfengListLoadableFragment<ReviewUnit>
		implements OnItemClickListener, ListViewListener {

	private ChannelList list;
	private ReviewUnits units = new ReviewUnits();
	private ReviewUnit unit;
	private LoadableViewWrapper wrapper;
	private ArrayList<ListItem> items = new ArrayList<ListItem>();

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
		RenderEngine.render(list, new ReviewViewFactory(),
				new ArrayList<ListItem>(), IfengNewsApp.getImageLoader(),
				new DefaultImageDisplayer(null));
		list.bindPageManager(getPager());
	}

	private static final class ReviewViewFactory implements ViewFactory {
		@Override
		public View createView(Context context, int position) {
			return LayoutInflater.from(context).inflate(
					com.ifeng.news2.R.layout.widget_channel_list_item, null);
		}

		@Override
		public void render(View view, Object data, int position) {/*

			ListItem item = (ListItem) data;
			ImageView listIcon = (ImageView) view.findViewById(id.listIcon);
			TextView comments = (TextView) view.findViewById(id.comments);
			IfengTextView introduction = (IfengTextView) view.findViewById(id.introduction);
			FrameLayout fl_thumbnail_wrapper = (FrameLayout) view.findViewById(id.thumbnail_wrapper);

			if (ChannelList.setListIcon(listIcon, comments, item.getLinks()))
				introduction.setFreeSpace(4);// 专题图标占用的空间 暂且认为占四个汉字的空间
			else {
				if (item.isHasVideo()) {
					listIcon.setBackgroundResource(drawable.video_icon);
					listIcon.setVisibility(View.VISIBLE);
					comments.setVisibility(View.GONE);
					introduction.setFreeSpace(3);
				} else {
					introduction.setFreeSpace(ChannelList.getCommentSpace(item.getComments()));
				}
			}

			if (item.getThumbnail() != null && item.getThumbnail().length() > 0) {
				fl_thumbnail_wrapper.setVisibility(View.VISIBLE);
				introduction.setTextWidth(ChannelList.picPx, ChannelList.leftPx, ChannelList.rightPx);
			} else {
				fl_thumbnail_wrapper.setVisibility(View.GONE);
				introduction.setTextWidth(0, ChannelList.leftPx, ChannelList.rightPx);
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
//		ChannelList.goToReadPage(getActivity(), positionInBodyList,
//				units.getIds(), units.getDocUnits(),
//				Config.CHANNEL_COMMENTARY,
//				ConstantManager.ACTION_FROM_APP,
//				units.getExtensions().get(positionInBodyList));

	}

	@Override
	public StateAble getStateAble() {
		return wrapper;
	}

	@Override
	public void loadComplete(LoadContext<?, ?, ReviewUnit> context) {
		if (context.getResult() != null && getPager().getPageNo() > 1)
			filterDuplicates(context.getResult().getBody().getItem(), items);
		
		super.loadComplete(context);
		unit = (ReviewUnit) context.getResult();
		int page = 0;
		try {
			page = Integer.parseInt(Uri.parse(context.getParam().toString()).getQueryParameter("pageindex"));
		} catch (Exception e) {
			
		}
		if (unit != null && page == 1) {
			list.resetListFooter(pageSum);
			units.clear();
			items.clear();
			items.addAll(unit.getBody().getItem());
			RenderEngine.render(list, new ReviewViewFactory(), items,
					IfengNewsApp.getImageLoader(), new DefaultImageDisplayer(
							null));
			isCleanDatas = false;
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
		doLoad(pageNo, pageNo == 1 ? false : true, firstLoad);
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
	public void startLoading() {
		doLoad(getPager().getPageNo(), false, true);
	}
	
	@Override
	public void onRefresh() {
//		String url = Config.CHANNEL_COMMENTARY.getChannelUrl() + "&pageindex=1";
//		if (!IfengNewsApp.getMixedCacheManager().isExpired(url, 60 * 1000)) {
//			list.stopRefresh();
//			return;
//		}
//		loadOnline();
	}

	private void loadOnline() {
//		resetRefresh();
//		getLoader().startLoading(
//				new LoadContext<String, LoadListener<ReviewUnit>, ReviewUnit>(
//						ParamsManager.addParams(Config.CHANNEL_COMMENTARY.getChannelUrl()) + "&pageindex=1", 
//						ReviewFragment.this, ReviewUnit.class, Parsers.newReviewUnitParser(),
//						false, LoadContext.FLAG_HTTP_ONLY));
	}

	private void doLoad(int pageNo, boolean isRefresh, boolean fristLoad) {
//		getLoader().startLoading(
//				new LoadContext<String, LoadListener<ReviewUnit>, ReviewUnit>(
//						ParamsManager.addParams(Config.CHANNEL_COMMENTARY.getChannelUrl()) + "&pageindex=" + pageNo, this,
//						ReviewUnit.class, Parsers.newReviewUnitParser(),
//						fristLoad, isRefresh ? LoadContext.FLAG_HTTP_FIRST : LoadContext.FLAG_CACHE_FIRST));
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
//		if (!PhoneManager.getInstance(getActivity()).isConnectedNetwork()) return;
//		
//		String param = ParamsManager.addParams(Config.CHANNEL_COMMENTARY.getChannelUrl()) + "&pageindex=1";
//		if (!ignoreExpired && !IfengNewsApp.getMixedCacheManager().isExpired(param)) return;
//		
//		Handler handler = new Handler(Looper.getMainLooper());
//		handler.postDelayed(new Runnable() {
//			
//			@Override
//			public void run() {
//				list.startRefresh();
//				loadOnline();
//			}
//		}, ignoreExpired ? Config.AUTO_PULL_TIME : Config.AUTO_PULL_TIME * 3);
	}

	@Override
	public void postExecut(LoadContext<?, ?, ReviewUnit> arg0) {
		// TODO Auto-generated method stub
		
	}

}
