package com.ifeng.news2.fragment;

import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView.LayoutParams;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengListLoadableFragment;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.activity.SplashActivity;
import com.ifeng.news2.adapter.ChannelAdapter;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.bean.ListUnit;
import com.ifeng.news2.bean.ListUnits;
import com.ifeng.news2.plutus.android.PlutusAndroidManager;
import com.ifeng.news2.plutus.android.PlutusAndroidManager.PlutusAndroidListener;
import com.ifeng.news2.plutus.core.Constants.ERROR;
import com.ifeng.news2.plutus.core.model.bean.AdMaterial;
import com.ifeng.news2.plutus.core.model.bean.PlutusBean;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.ListDisplayStypeUtil;
import com.ifeng.news2.util.ListDisplayStypeUtil.ChannelViewHolder;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.widget.ChannelList;
import com.ifeng.news2.widget.HeadImage;
import com.ifeng.news2.widget.HeaderView;
import com.ifeng.news2.widget.LoadableViewWrapper;
import com.ifeng.news2.widget.PageListViewWithHeader.ListViewListener;
import com.qad.form.BasePageAdapter;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.StateAble;
import com.qad.loader.callable.Parser;
import com.qad.system.PhoneManager;
import com.qad.view.PageListView;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@SuppressWarnings("unchecked")
public class HeadChannelFragment extends IfengListLoadableFragment<ListUnits>
		implements OnItemClickListener, ListViewListener {
	
	public static final String EXTRA_CHANNEL = "extra.com.ifeng.news.channel";
	public static final String ACTION_NEXT_PAGE = "action.com.ifeng.news.next_page";
    private Map<String, PlutusBean> plutus = null;
	private boolean isAddRecord = false;
	private boolean hasHeadView = true;
	private Channel channel;
	private ChannelList list;
	private HeadImage headImage;
	private BasePageAdapter<ListItem> adapter;
	private LoadableViewWrapper wrapper;
	private ListUnits units = new ListUnits();
	private ListUnit headImageUnit = new ListUnit();
	private Handler handler = new Handler(Looper.getMainLooper());
	private ArrayList<ListItem> totalListItems = new ArrayList<ListItem>();
//	private boolean isCreated = false;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		channel = (Channel) getArguments().get(EXTRA_CHANNEL);
		Log.e("tag", "channel.getChannelName()="+channel.getChannelName()+" ad = "+channel.getAdSite());		
		reset();		
		DisplayMetrics metrics = new DisplayMetrics();
		getActivity().getWindowManager().getDefaultDisplay().getMetrics(metrics);
		
		Log.e("tag", "w = "+metrics.widthPixels+"  h = "+metrics.heightPixels);
	}
	
	@Override
	public void onSaveInstanceState(Bundle outState) {
//		outState.putParcelable("channel", channel);
		super.onSaveInstanceState(outState);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		if (wrapper.getParent() != null) {
			((ViewGroup) wrapper.getParent()).removeView(wrapper);
		}
		return wrapper;
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
//		((BaseFragmentActivity) getActivity())
//				.registerManagedReceiver(new NextPageHandler());
//		if (savedInstanceState != null) {
//			channel = savedInstanceState.getParcelable("channel");
//		}
//		if (!isCreated) {
//
//			isCreated = true;
//		}
	}

	@Override
	public void onResume() {
		StatisticUtil.doc_id =channel.getStatistic(); 
		StatisticUtil.type = StatisticUtil.StatisticPageType.ch.toString() ; 
		super.onResume();
//		if (list != null) {
//			list.refresh();
//		}
//		pullDownRefresh(false);
//		if (list != null)
//			list.refresh();
//		Handler handler = new Handler(Looper.getMainLooper());
//		handler.postDelayed(new Runnable() {
//			@Override
//			public void run() {
//				doRender();
//			}
//		}, Config.AUTO_PULL_TIME);
	}
	
	@Override
    public void onDestroy() {
        super.onDestroy();
//        Log.w("Sdebug", "onDestroy called for channel " + channel.getChannelName());
        //android.os.Build.VERSION_CODES.HONEYCOMB = 11 , Android 3.0.
//        if (android.os.Build.VERSION.SDK_INT < 11) {
            // HONEYCOMB之前Bitmap实际的Pixel Data是分配在Native Memory中。
            // 首先需要调用reclyce()来表明Bitmap的Pixel Data占用的内存可回收
            // call bitmap.recycle to make the memory available for GC
            for (int i = 0; i < list.getChildCount(); i++) {
//                Object tag = list.getChildAt(i).getTag(R.id.tag_holder);
                list.getChildAt(i).setTag(R.id.tag_holder, null);
                // 独家频道会设置下面这个tag，需要清除
//                list.getChildAt(i).setTag(R.id.tag_data, null);
//                if (null == tag) {
//                    continue;
//                }
                // set tag to null
//                list.getChildAt(i).setTag(R.id.tag_holder, null);
//                if (tag instanceof ChannelViewHolder) {
//                    ListDisplayStypeUtil.cleanupChannelViewHolder((ChannelViewHolder)tag);
//                }
            }
//        } else {
            // 设置channellist的各个item的相应tag为null，否则GC不回收channellist会OOM
//            for (int i = 0; i < list.getChildCount(); i++) {
//                list.getChildAt(i).setTag(R.id.tag_holder, null);
//            }
//        }
            list.cleanup();
    }
	
	private String getParams(int pageNo){
		String param = null;
		param = ParamsManager.addParams(getActivity(),
					channel.getChannelSmallUrl() + "&page=" + pageNo);
		return param;
	}
	
	private int getPage(String url) throws Exception {
		int page = 0;
		page = Integer.parseInt(Uri.parse(url).getQueryParameter("page"));
		return page;
	}
	
	private Parser<ListUnits> getParser() {
		
		return Parsers.newListUnitsParser();
	}

	private void startPlutus() {
		Log.e("Sdebug", "startPlutus");
		if (TextUtils.isEmpty(channel.getAdSite())) {
			return;
		}
		HashMap<String, String> focusSelection = new HashMap<String, String>();
		focusSelection.put("select", "adPosition");
		focusSelection.put("position", channel.getAdSite());
		PlutusAndroidManager.qureyAsync(focusSelection, plutusAndroidListener);
	}

	protected void initFontCount() {
		list.initFontCount(getActivity(), ((IfengNewsApp) getActivity()
				.getApplication()).getDisplay(getActivity()));
	}

	@Override
	public void reset() {
		super.reset();
		list = new ChannelList(getActivity(), null, PageListView.AUTO_MODE);	
		
		adapter = new ChannelAdapter(getActivity(),
					ListDisplayStypeUtil.HEAD_CHANNEL_FLAG);
		
		adapter.setItems(totalListItems);
		wrapper = new LoadableViewWrapper(getActivity(), list);
		
		headImage = new HeadImage(getActivity());
		list.addHeaderView(headImage);
		hasHeadView = true;
		headImage.setList(list);
		int screenWidth = getActivity().getWindowManager().getDefaultDisplay()
				.getWidth();
		int paddingHeight = 0;
		if(screenWidth < 720) {
			paddingHeight = 3;
		} else if(screenWidth >= 720 && screenWidth < 1080) {
			paddingHeight = 5;
		} else {
			paddingHeight = 12;
		}
		View view = new View(getActivity());
		view.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, paddingHeight));
		view.setBackgroundDrawable(getActivity().getResources().getDrawable(R.drawable.channellist_selector));
		list.addHeaderView(view);		
		list.setAdapter(adapter);
		list.bindPageManager(getPager());
		list.setTriggerMode(PageListView.AUTO_MODE);
		list.setOnItemClickListener(this);
		list.setListViewListener(this);
		initFontCount();
		wrapper.setOnRetryListener(this);
	}

	@Override
	public Class<ListUnits> getGenericType() {
		return ListUnits.class;
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		if (view == list.getFooter())
			return;
		// String sportUrl = "http://i.ifeng.com/newLiveClient.h?mt=5593";
		// Intent intent = new Intent();
		// intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		// intent.setClass(getActivity(), AdDetailActivity.class);
		// intent.putExtra("URL",sportUrl);
		// intent.setAction("FULL_SCREEN");
		// getActivity().startActivity(intent);
//		Intent intent = new Intent(getActivity(),SportMainActivity.class);
//		intent.putExtra("MATCH_ID", "5540");
//		startActivity(intent);
		if (view.getTag(R.id.tag_data) != null) {
			ArrayList<Extension> links = (ArrayList<Extension>) view.getTag(R.id.tag_data);
			String docId = null;
			if (links.size() > 0 && null != links.get(0)) 
				docId = links.get(0).getDocumentId();
			//点击列表的item项增加当前频道统计
			if(!isAddRecord){
//				StatisticUtil.addRecord(HeadChannelFragment.this.getActivity(), StatisticUtil.CHANNEL, channel.getStatistic());
				StatisticUtil.addRecord(StatisticUtil.StatisticRecordAction.page
						, "id="+channel.getStatistic()+"$type=" + StatisticUtil.StatisticPageType.ch);
				NewsMasterFragmentActivity.isStatisticRecordTriggeredByOperation 
					= isAddRecord = true;
			}
			ChannelList.goToReadPage(getActivity(), docId, channel,
					ConstantManager.ACTION_FROM_APP, links);
			// 将标题变灰，表示文章已阅读
			final Object holder = view.getTag(R.id.tag_holder);
            if (null != holder && holder instanceof ChannelViewHolder) {
                handler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                    	// 直接赋颜色值，不调用个头Resources()，因为某些手机上会报异常：java.lang.IllegalStateException: Fragment HeadChannelFragment{42143fa8} not attached to Activity
//                        ((ChannelViewHolder)holder).title.setTextColor(getResources().getColor(R.color.list_readed_text_color));
                    	try {
                    		((ChannelViewHolder)holder).title.setTextColor(0xff727272);
                    	} catch (Exception e) {
                        	// just ignore it, may encounter NullPointerException here
                        }
                    }
                }, Config.AUTO_PULL_TIME);
            }
		}
	}

	public void loadOnline() {
		resetRefresh();
		String param = null;
		param = getParams(1);
//		Log.w("Sdebug", "loadOnline for channel " + channel.getChannelName());
		getLoader().startLoading(
				new LoadContext<String, LoadListener<ListUnits>, ListUnits>(
						param, HeadChannelFragment.this, ListUnits.class,
						getParser(), false,
						LoadContext.FLAG_HTTP_ONLY, false));
	}

	public void resetDatas() {
		totalListItems.clear();
		adapter.notifyDataSetChanged();
	}

	@Override
	public void onRefresh() {
		//下拉刷新或者上拉加载更多增加当前频道统计
		if(!isAddRecord){
//			StatisticUtil.addRecord(HeadChannelFragment.this.getActivity(), StatisticUtil.CHANNEL, channel.getStatistic());
			StatisticUtil.addRecord(StatisticUtil.StatisticRecordAction.page
					, "id="+channel.getStatistic()+"$type=" + StatisticUtil.StatisticPageType.ch);
			NewsMasterFragmentActivity.isStatisticRecordTriggeredByOperation 
				= isAddRecord = true;
		}
	    String param =getParams(1);
	    
        if (!IfengNewsApp.getMixedCacheManager().isExpired(param, Config.PULL_TO_REFRESH_EXPIRED_TIME)) {
            handler.postDelayed(new Runnable() {

                @Override
                public void run() {
                    list.stopRefresh();
                    adapter.notifyDataSetChanged();
                }
            }, Config.FAKE_PULL_TIME);
            return;
        }
		loadOnline();
	}

	private void doLoading(int pageNo, int flag) {
		String param = null;
		param = getParams(pageNo);
		Log.i("Sdebug", channel.getChannelName() + ": " + param);
		getLoader().startLoading(
				new LoadContext<String, LoadListener<ListUnits>, ListUnits>(
						param, this, ListUnits.class,getParser(), firstLoad, flag, false));
	}

	@Override
	public boolean loadPage(int pageNo, int pageSize) {
		super.loadPage(pageNo, pageSize);
		//下拉刷新或者上拉加载更多增加当前频道统计
		if(pageNo > 1){
			if(!isAddRecord){
//				StatisticUtil.addRecord(HeadChannelFragment.this.getActivity(), StatisticUtil.CHANNEL, channel.getStatistic());
				StatisticUtil.addRecord(StatisticUtil.StatisticRecordAction.page
						, "id="+channel.getStatistic()+"$type=" + StatisticUtil.StatisticPageType.ch);
				NewsMasterFragmentActivity.isStatisticRecordTriggeredByOperation 
					= isAddRecord = true;
			}
		}
//		Log.w("Sdebug", "loadPage #" + pageNo + " for channel " + channel.getChannelName());
		doLoading(pageNo, (pageNo == 1 && !isDoingRetry) ? LoadContext.FLAG_CACHE_FIRST
				: LoadContext.FLAG_HTTP_FIRST);
		return false;
	}

	@Override
	public void loadComplete(final LoadContext<?, ?, ListUnits> context) {
		int page;
		try {
			page = getPage(context.getParam().toString());
		} catch (Exception e) {
			page = 1;
			e.printStackTrace();
		}
		
//		Log.w("Sdebug", "loadComplete page #" + page + ", for channel " + channel.getChannelName());
		units = context.getResult();

		if (page > 1) {
			filterDuplicates(units.get(0).getUnitListItems(),
					totalListItems);
		}
		
		
		if (page == 1) {
		  if (units.size() == 2 && units.get(1).getUnitListItems().size() > 0) {
				if (!hasHeadView) {
					// 在android4.0以前的版本，在setAdapter之后调用addHeaderView会抛出throw new
					// IllegalStateException(
					// "Cannot add header view to list -- setAdapter has already been called.");
					if (android.os.Build.VERSION.SDK_INT >= 14) {
						list.addHeaderView(headImage);
					} 
				}
		    hasHeadView = true;
		    headImageUnit = units.get(1);

		    

		    //			headImage.render(units);
		    headImage.render(headImageUnit, channel);

		    if (Config.ENABLE_ADVER) {
		      startPlutus();
		    }
		  } else {
		    if (hasHeadView) {
		      list.removeHeaderView(headImage);
            }
		    hasHeadView = false;
		  }
		  
		  list.resetListFooter(pageSum);
		  totalListItems.clear();
		  adapter.notifyDataSetChanged();
		  
		  list.setRefreshTime(Config.getCurrentTimeString());
		  list.stopRefresh();
		  resetRefresh();
		  
		  // 判断是否需要显示引导页
		  if (getActivity() instanceof NewsMasterFragmentActivity) {
		    ((NewsMasterFragmentActivity)getActivity()).onPageLoadComplete();
		  }
		}
		
		// 会把数据更新到ChannelAdapter
		
		super.loadComplete(context);
//		Intent intent = new Intent();
//		intent.setAction(ConstantManager.ACTION_ADD_NEXT_PAGE);
//		intent.putExtra(ConstantManager.EXTRA_ADD_OK, true);
//		intent.putExtra(ConstantManager.EXTRA_DETAIL_IDS, totalIds);
//		intent.putExtra(ConstantManager.EXTRA_DOC_UNITS, totalDocUnits);
//		intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
//		intent.putExtra(ConstantManager.EXTRA_HAS_MORE,
//				pager.getPageNo() < context.getResult().get(1).getPageSum());
//		((BaseFragmentActivity) getActivity()).sendBroadcast(intent);
		if ("頭條".equals(channel.getChannelName()) && SplashActivity.isSplashActivityCalled
				&& !(context.getType() == LoadContext.TYPE_HTTP)) {
//		    Log.w("Sdebug", "loadComplete pullDownRefresh called");
			SplashActivity.isSplashActivityCalled = false;
			pullDownRefresh(true);
		}
		
	}

	@Override
	public void doRender() {
		if (list != null) {
			if (list.getHeaderState() == HeaderView.STATE_REFRESHING) {
				list.stopRefresh();
			}
		}
		return;
	}

	@Override
	public void loadFail(LoadContext<?, ?, ListUnits> context) {
		super.loadFail(context);
		list.stopRefresh();
	}

	@Override
	public StateAble getStateAble() {
		return wrapper;
	}

	private PlutusAndroidListener<PlutusBean> plutusAndroidListener = new PlutusAndroidListener<PlutusBean>() {

		@Override
		public void onPostStart() {
		}

		@Override
		public void onPostComplete(PlutusBean result) {
			if (result == null || result.getAdMaterials() == null)
				return;
			ArrayList<AdMaterial> materials = result.getFilteredAdMaterial();
			if (materials.size() <= 0)
				return;

			if (plutus == null)
				plutus = new HashMap<String, PlutusBean>();
			plutus.put(result.getAdPositionId(), result);

			if (channel.getAdSite().equals(result.getAdPositionId())) {
				Collections.sort(materials, comparator);
				if (headImageUnit != null) {
					buildData(headImageUnit);
					headImage.render(headImageUnit, channel);
				}
			}
		}

		private ListUnit buildData(ListUnit data) {
			PlutusBean focusPlutus = plutus.get(channel.getAdSite());
			AdMaterial material = null;

			ArrayList<ListItem> listItems = data.getUnitListItems();
			Iterator<ListItem> iterator = listItems.iterator();
			while (iterator.hasNext()) {
				ListItem item = iterator.next();
				if ("ad".equals(item.getType()))
					iterator.remove();
			}
			for (int i = 0; i < focusPlutus.getAdMaterials().size(); i++) {
				material = focusPlutus.getAdMaterials().get(i);
				if (material.getImageURL().length() == 0)
					continue;
				ListItem item = new ListItem();
				item.setTitle(material.getText());
				item.setThumbnail(material.getImageURL());
				item.setId(material.getAdAction().getType() + "://"
						+ material.getAdAction().getUrl());
				item.setExtra(material.getAdId());
				item.setType("ad");
				try {
					if (!data.getUnitListItems().contains(item)) {
						// @gm, in case the index exceeded the boundary
						if (material.getAdConditions().getIndex() > data.getUnitListItems().size()){
						  if (1 == data.getUnitListItems().size()) {
						    data.getUnitListItems()
                            .add(data.getUnitListItems().size(), item);
                          } else {
                            data.getUnitListItems()
                            .add(data.getUnitListItems().size() - 1, item);
                          }
						}
						else
							data.getUnitListItems()
									.add(material.getAdConditions().getIndex(),
											item);
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			return data;
		}

		@Override
		public void onPostFailed(ERROR error) {
			Log.w("Sdebug", "HeadChannel.plutusAndroidListener onPostFailed: " + error.toString());
		}
	};

	private Comparator<AdMaterial> comparator = new Comparator<AdMaterial>() {

		@Override
		public int compare(AdMaterial lhs, AdMaterial rhs) {
			return lhs.getAdConditions().getIndex()
					- rhs.getAdConditions().getIndex();
		}
	};

	// @gm, end

	@Override
	public void pullDownRefresh(boolean ignoreExpired) {
		if (!PhoneManager.getInstance(getActivity()).isConnectedNetwork())
			return;
		
		if (channel == null) {
            return;
		}
		
//		Log.w("Sdebug", channel.getChannelName() + " pullDownRefresh called, ignoreExpired=" + ignoreExpired);
		
		String param = getParams(1);

		if (!ignoreExpired
				&& !IfengNewsApp.getMixedCacheManager().isExpired(param))
			return;

//		Handler handler = new Handler(Looper.getMainLooper());
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
	public void postExecut(LoadContext<?, ?, ListUnits> context) {
		if (context.getType() == LoadContext.TYPE_HTTP) {
			int page = 0;
			try {
				page = getPage(context.getParam().toString());
			} catch (Exception e) {
				page = 1;
				e.printStackTrace();
			}
			units = context.getResult();
			
			if(units==null || units.size() < 1){
			    context.setResult(null);
				return;
			}
			
			if (1 == page && units.size() == 2) {
              //Only the first page has headImage Data.
			  filerInvalidHeadImageItems(units.get(1).getUnitListItems());
			  
//			  if (units.get(1).getUnitListItems().size() == 0) {
//			    context.setResult(null);
//			    return;
//			  }
            }
			
			//过滤不正确的数据，如title为空，则不显示该条数据
			filerInvalidItems(units.get(0).getUnitListItems());
			
			//check the integrity of data
			// 如果频道第一页加载得到结果少于2条，则显示加载失败
			if (units.get(0).getUnitListItems().size() == 0 || page == 1 ? units
					.get(0).getUnitListItems().size() < 1 : false) {
				context.setResult(null);
				return;
			}
			
//			Log.w("Sdebug", "头条get items for page #" + page + " is " + units.get(1).getBody().size());
			// 到这里说明load成功，并得到了正确的频道数据，缓存之
			super.postExecut(context);
			
			
		}
		// 根据产品的最新需求，去掉正文的预加载功能
//		if (PhoneManager.getInstance(getActivity()).isConnectionFast()
//				&& !Config.FORCE_2G_MODE) {
//			loadDetail(context.getResult());
//		}

	}
	
	private void filerInvalidHeadImageItems(List<ListItem> items) {
	    boolean isInvalidItemExisted = false;
//        Iterator<ListItem> iterator = items.iterator();
//        while (iterator.hasNext()) {
//            if (TextUtils.isEmpty(iterator.next().getThumbnail())) {
////                iterator.remove();
//                iterator.
//                iterator.next().setThumbnail("");
//                isInvalidItemExisted = true;
//            }
//        }
        
        if (null == items) {
          return;
        }
        
        Iterator<ListItem> it = items.iterator();
        while (it.hasNext()) {
        	ListItem item = it.next();
        	if (null == item || TextUtils.isEmpty(item.getThumbnail())) {
        		it.remove();
        	}
        }
//        for (ListItem listItem : items) {
//          if (null == listItem) {
//            items.remove(listItem);
//            continue;
//          }
//          if (listItem.getThumbnail() == null) {
//            listItem.setThumbnail("");
//            isInvalidItemExisted = true;
//          }
//        }
//        
//        if (isInvalidItemExisted) {
//            // build detail message
//            StringBuilder sb = new StringBuilder();
//            for (ListItem item : items) {
//                sb.append(item.getThumbnail()).append(",");
//            }
            
//            LogHandler.addLogRecord(this.getClass().getSimpleName()
//                    , "filerInvalidHeadImageItems: Some thumbnails are empty for HeadImage"
//                    , "After filtering current head image items are： " + sb.toString().substring(0, sb.length()-1));
//        }
    }
	
	private void filerInvalidItems(List<ListItem> items) {
		Iterator<ListItem> iterator = items.iterator();
		while (iterator.hasNext()) {
			if (TextUtils.isEmpty(iterator.next().getTitle())) {
//			    LogHandler.addLogRecord(this.getClass().getSimpleName()
//	                    , "filerInvalidItems: Title is empty for item of HeadChannel"
//	                    , "NoDetailMessage");
				iterator.remove();
			}
		}
	}

}
