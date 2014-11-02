package com.ifeng.news2.fragment;


import java.util.ArrayList;
import static com.ifeng.news2.fragment.HeadChannelFragment.EXTRA_CHANNEL;
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
import com.ifeng.news2.activity.SlideActivity;
import com.ifeng.news2.adapter.GalleryAdapter;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.GalleryUnit;
import com.ifeng.news2.bean.SlideBody;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.widget.ChannelList;
import com.ifeng.news2.widget.HeaderView;
import com.ifeng.news2.widget.LoadableViewWrapper;
import com.ifeng.news2.widget.PageListViewWithHeader.ListViewListener;
import com.qad.loader.BeanLoader;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.StateAble;
import com.qad.system.PhoneManager;
import com.qad.view.PageListView;

public class GalleryFragment extends IfengLoadableFragment<GalleryUnit>
		implements OnItemClickListener,ListViewListener {
	
	private ChannelList pageList;
	private GalleryUnit unit;
	private Channel channel;
	private ArrayList<SlideBody> datas = new ArrayList<SlideBody>();
	private boolean isReading = false;
	private boolean isAddRecord = false;
//	private boolean canRender = false;
	private GalleryAdapter adapter;
	private Handler handler = new Handler(Looper.getMainLooper());
	private String param;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		param = Config.GALLERY_COLUMN_URL;
		channel = (Channel) getArguments().get(EXTRA_CHANNEL);
		adapter = new GalleryAdapter(getActivity());
		adapter.setItems(datas);		
		pageList = new ChannelList(getActivity(), null,PageListView.SINGLE_PAGE_MODE);
		pageList.setAdapter(adapter);
		pageList.setDividerHeight(0);		
		loadableViewWrapper = new LoadableViewWrapper(getActivity(), pageList);
		loadableViewWrapper.setOnRetryListener(this);
		pageList.setOnItemClickListener(this);
		pageList.setListViewListener(this);
		startLoading();
//		isCreated = true;
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		if(loadableViewWrapper.getParent()!=null){
			((ViewGroup)loadableViewWrapper.getParent()).removeView(loadableViewWrapper);
		}
		return loadableViewWrapper;
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
	}
	
	@Override
	public void onResume() {
		StatisticUtil.doc_id = channel.getStatistic();
		StatisticUtil.type = StatisticUtil.StatisticPageType.ch.toString() ; 
		super.onResume();
//		pullDownRefresh(false);
//		Handler handler = new Handler(Looper.getMainLooper());
//		handler.postDelayed(new Runnable() {
//			@Override
//			public void run() {
//				doRender();
//			}
//		}, Config.AUTO_PULL_TIME);
	}

	@Override
	public void startLoading() {
		super.startLoading();
		getLoader()
				.startLoading(
						new LoadContext<String, LoadListener<GalleryUnit>, GalleryUnit>(
								param, this, GalleryUnit.class, Parsers
										.newGalleryUnitParser(), true,
								isDoingRetry ? LoadContext.FLAG_HTTP_FIRST
										: LoadContext.FLAG_CACHE_FIRST, false));
	}

	@Override
	public StateAble getStateAble() {
		return super.getStateAble();
	}

	@Override
	public Class<GalleryUnit> getGenericType() {
		return GalleryUnit.class;
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		int realPosition = position-pageList.getHeaderViewsCount();
		if (!isReading) {
			isReading = true;
			SlideActivity.startFromApp(getActivity(), unit.getGlobalPosition(realPosition));
			isReading = false;
		}
		//点击列表的item项增加当前频道统计
		if(!isAddRecord){
//			StatisticUtil.addRecord(GalleryFragment.this.getActivity(), StatisticUtil.CHANNEL, channel.getStatistic());
			StatisticUtil.addRecord(StatisticUtil.StatisticRecordAction.page
					, "id="+channel.getStatistic()+"$type=" + StatisticUtil.StatisticPageType.ch);
			NewsMasterFragmentActivity.isStatisticRecordTriggeredByOperation 
				= isAddRecord = true;
		}
	}

	@Override
	public void loadFail(LoadContext<?, ?, GalleryUnit> context) {
		super.loadFail(context);
		pageList.stopRefresh();
	}
	
	@Override
	public void loadComplete(LoadContext<?, ?, GalleryUnit> context) {
//		super.loadComplete(context);
		//之前调用super的loadComplete会调用RenderEngine的render导致视图的数据与adapter中数据分离，造成文不对题的现象，现在已经修改了QAD中的父类
		adapter.notifyDataSetChanged();
		super.loadComplete(context);
		pageList.setRefreshTime(Config.getCurrentTimeString());
		pageList.stopRefresh();
		
//		if (context.getIsFirstLoaded())
//			pullDownRefresh(false);
	}
	
	@Override
	public void doRender() {
			if(pageList!=null){
				if(pageList.getHeaderState()==HeaderView.STATE_NORMAL){
					pageList.stopRefresh();
				}
			}
			return;
	}

	private void loadOnline() {
		getLoader()
				.startLoading(
						new LoadContext<String, LoadListener<GalleryUnit>, GalleryUnit>(
								param, GalleryFragment.this, GalleryUnit.class,
								Parsers.newGalleryUnitParser(), false,
								LoadContext.FLAG_HTTP_ONLY, false));
	}

	@Override
	public void pullDownRefresh(boolean ignoreExpired) {
		if (!PhoneManager.getInstance(getActivity()).isConnectedNetwork())
			return;
		
		
		if (!ignoreExpired && !IfengNewsApp.getMixedCacheManager().isExpired(param))
			return;
		
//		Handler handler = new Handler(Looper.getMainLooper());
		handler.postDelayed(new Runnable() {
			
			@Override
			public void run() {
			    if (pageList.startRefresh()) {
			      loadOnline();
                }
			}
		}, ignoreExpired ? Config.AUTO_PULL_TIME : Config.AUTO_PULL_TIME);
	}

	@Override
	public void onRefresh() {
		//下拉刷新或者上拉加载更多增加当前频道统计
		if(!isAddRecord){
//			StatisticUtil.addRecord(GalleryFragment.this.getActivity(), StatisticUtil.CHANNEL, channel.getStatistic());
			StatisticUtil.addRecord(StatisticUtil.StatisticRecordAction.page
					, "id="+channel.getStatistic()+"$type=" + StatisticUtil.StatisticPageType.ch);
			NewsMasterFragmentActivity.isStatisticRecordTriggeredByOperation 
				= isAddRecord = true;
		}

        if (!IfengNewsApp.getMixedCacheManager().isExpired(param, Config.PULL_TO_REFRESH_EXPIRED_TIME)) {
            handler.postDelayed(new Runnable() {

                @Override
                public void run() {
                    pageList.stopRefresh();
                    adapter.notifyDataSetChanged();
                }
            }, Config.FAKE_PULL_TIME);
            return;
        }       
		loadOnline();
	}

	@Override
	public void postExecut(LoadContext<?, ?, GalleryUnit> ctx) {
		if(ctx.getResult()==null)return;
		if(ctx.getResult().getSlides()==null||ctx.getResult().getSlides().size()<10){
			ctx.setResult(null);
			return;
		}
		if(!ctx.isAutoSaveCache() && ctx.getType() == LoadContext.TYPE_HTTP) {
			BeanLoader.getMixedCacheManager().saveCache(ctx.getParam().toString()
					,ctx.getResult());
		}
		/**
		 * 调整数据更新位置。耗时操作在子线程执行，把对数据的赋值操作放在一起
		 */
		datas.clear();
		unit = ctx.getResult();
		datas.addAll(unit.getSlides());
		((IfengNewsApp) getActivity().getApplication()).setSlideItems(unit.getSlides2());
	}
	
}
