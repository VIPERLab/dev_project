package com.ifeng.news2.fragment;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AbsListView.LayoutParams;
import android.widget.AdapterView.OnItemClickListener;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengListLoadableFragment;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.activity.SplashActivity;
import com.ifeng.news2.adapter.VideoChannelAdapter;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.VideoListItem;
import com.ifeng.news2.bean.VideoListUnit;
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
import com.qad.app.BaseBroadcastReceiver;
import com.qad.app.BaseFragmentActivity;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.StateAble;
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
public class VideoChannelFragment extends IfengListLoadableFragment<VideoListUnit>
		implements OnItemClickListener, ListViewListener {
	
    public static final String ACTION_NEXT_PAGE = "action.com.ifeng.news.next_page";
    private Map<String, PlutusBean> plutus = null;
	private boolean isAddRecord = false;
	private boolean hasHeadView = true;
	private Channel channel;
	private ChannelList list;
	private HeadImage headImage;
	private VideoChannelAdapter adapter;
	private LoadableViewWrapper wrapper;
	private VideoListUnit unit = new VideoListUnit();
	private ArrayList<VideoListItem> headImageUnit = new ArrayList<VideoListItem>();
	private Handler handler = new Handler(Looper.getMainLooper());
	private ArrayList<VideoListItem> totalListItems = new ArrayList<VideoListItem>();
	private boolean isCreated = false;
	//视频接口参数，上一页最后条目id
	private int lastPositionId = 0;
	private boolean loadOver = false;//是否加载完后台所有的数据
	public static final String EXTRA_CHANNEL = "extra.com.ifeng.news.channel";

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		adapter = new VideoChannelAdapter(getActivity(),
				ListDisplayStypeUtil.VIDEO_CHANNEL_FLAG);
		adapter.setItems(totalListItems);
		channel = (Channel) getArguments().get(EXTRA_CHANNEL);
		Log.e("tag", "channel.getChannelName()="+channel.getChannelName()+" ad = "+channel.getAdSite());
		list = new ChannelList(getActivity(), null, PageListView.AUTO_MODE);		
		wrapper = new LoadableViewWrapper(getActivity(), list);
		reset();		
		list.setTriggerMode(PageListView.AUTO_MODE);
		list.setOnItemClickListener(this);
		list.setListViewListener(this);
		initFontCount();
		wrapper.setOnRetryListener(this);
	}
	
	@Override
	public void onSaveInstanceState(Bundle outState) {
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
	}

	@Override
	public void onResume() {
		StatisticUtil.doc_id = channel.getStatistic();
		StatisticUtil.type = StatisticUtil.StatisticPageType.ch.toString() ; 
		super.onResume();
	}
	
	@Override
    public void onDestroy() {
        super.onDestroy();
        //android.os.Build.VERSION_CODES.HONEYCOMB = 11 , Android 3.0.
//        if (android.os.Build.VERSION.SDK_INT < 11) {
            // HONEYCOMB之前Bitmap实际的Pixel Data是分配在Native Memory中。
            // 首先需要调用reclyce()来表明Bitmap的Pixel Data占用的内存可回收
            // call bitmap.recycle to make the memory available for GC
//            for (int i = 0; i < list.getChildCount(); i++) {
//                Object tag = list.getChildAt(i).getTag(R.id.tag_holder);
//                if (null == tag) {
//                    continue;
//                }
                // set tag to null
//                list.getChildAt(i).setTag(R.id.tag_holder, null);
//                if (tag instanceof ChannelViewHolder) {
//                    ListDisplayStypeUtil.cleanupChannelViewHolder((ChannelViewHolder)tag);
//                }
//            }
//        } else {
            // 设置channellist的各个item的相应tag为null，否则GC不回收channellist会OOM
            for (int i = 0; i < list.getChildCount(); i++) {
                list.getChildAt(i).setTag(R.id.tag_holder, null);
            }
            list.cleanup();
//        }
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

	private class NextPageHandler extends BaseBroadcastReceiver {
		@Override
		public IntentFilter getIntentFilter() {
			IntentFilter filter = new IntentFilter();
			filter.addAction(ACTION_NEXT_PAGE);
			return filter;
		}

		@Override
		public void onReceive(Context context, Intent intent) {
			if (!getPager().next()) {
				Intent mIntent = new Intent();
				mIntent.setAction(ConstantManager.ACTION_ADD_NEXT_PAGE);
				mIntent.putExtra(ConstantManager.EXTRA_HAS_MORE, false);
				((BaseFragmentActivity) getActivity()).sendBroadcast(mIntent);
			}
		}
	}

	protected void initFontCount() {
		list.initFontCount(getActivity(), ((IfengNewsApp) getActivity()
				.getApplication()).getDisplay(getActivity()));
	}

	@Override
	public void reset() {
		super.reset();
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
	}

	@Override
	public Class<VideoListUnit> getGenericType() {
		return VideoListUnit.class;
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		if (view == list.getFooter())
			return;
		String docId = (String) view.getTag(R.id.tag_data);
		if(docId != null){
			//点击列表的item项增加当前频道统计
			if(!isAddRecord){
//				StatisticUtil.addRecord(HeadChannelFragment.this.getActivity(), StatisticUtil.CHANNEL, channel.getStatistic());
				StatisticUtil.addRecord(StatisticUtil.StatisticRecordAction.page
						, "id="+channel.getStatistic()+"$type=" + StatisticUtil.StatisticPageType.ch);
				NewsMasterFragmentActivity.isStatisticRecordTriggeredByOperation 
				= isAddRecord = true;
			}
			String title = (String) view.getTag(R.id.tag_title);
			ChannelList.goToReadPage(getActivity(), docId,title,channel,ConstantManager.ACTION_FROM_APP);
			final Object holder = view.getTag(R.id.tag_holder);
			// 将标题变灰，表示文章已阅读
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
		//}
	}

	public void loadOnline() {
		resetRefresh();
		String param = channel.getChannelSmallUrl();
		getLoader().startLoading(
				new LoadContext<String, LoadListener<VideoListUnit>, VideoListUnit>(
						param, VideoChannelFragment.this, VideoListUnit.class,
						Parsers.newVideoListUnitParser(), false,
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
	    String param = channel.getChannelSmallUrl();
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
		if(pageNo == 1){
			param = channel.getChannelSmallUrl();
		}else if(pageNo > 1){
			param = channel.getChannelSmallUrl()+"&positionId=" + lastPositionId;
		}	
		getLoader().startLoading(
				new LoadContext<String, LoadListener<VideoListUnit>, VideoListUnit>(
						param, this, VideoListUnit.class, Parsers
								.newVideoListUnitParser(), firstLoad, flag, false));
	}

	@Override
	public boolean loadPage(int pageNo, int pageSize) {
		if(!loadOver){//如果没有加载完
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
			doLoading(pageNo, (pageNo == 1 && !isDoingRetry) ? LoadContext.FLAG_CACHE_FIRST
					: LoadContext.FLAG_HTTP_FIRST);
		}
		return false;		
	}

	@Override
	public void loadComplete(final LoadContext<?, ?, VideoListUnit> context) {
			int page = 0;
			try {
				//视频所不同的uri格式：positionId
				if(Uri.parse(context.getParam().toString())
						.getQueryParameter("positionId") == null){
					page = 1;
					loadOver = false;
				}else{
					page = Integer.parseInt(Uri.parse(context.getParam().toString())
							.getQueryParameter("positionId"));
				}
			} catch (Exception e) {
				page = 1;
				e.printStackTrace();
			}
			unit = context.getResult();
			//获取当前页最后条目id, 供加载下一页使用
			int sizeTemp = unit.getBodyList().size();
			if(sizeTemp > 0)
				lastPositionId = unit.getBodyList().get(sizeTemp - 1).getId();
			//最后一页
			if(sizeTemp == 0){
				list.removeFooterView(list.getFooter());
				loadOver = true;
			}
			if (page == 1) {
				if (unit.getHeader().size() > 0) {
					if (!hasHeadView) {
						// 在android4.0以前的版本，在setAdapter之后调用addHeaderView会抛出throw new
						// IllegalStateException(
						// "Cannot add header view to list -- setAdapter has already been called.");
						if (android.os.Build.VERSION.SDK_INT >= 14) {
							list.addHeaderView(headImage);
						} 
					}
					hasHeadView = true;
					headImageUnit = unit.getHeader();
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
	public void loadFail(LoadContext<?, ?, VideoListUnit> context) {
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
//					buildData(headImageUnit);
//					headImage.render(headImageUnit, channel);
				}
			}
		}

//		private ListUnit buildData(ListUnit data) {
//			PlutusBean focusPlutus = plutus.get(channel.getAdSite());
//			AdMaterial material = null;
//
//			ArrayList<ListItem> listItems = data.getUnitListItems();
//			Iterator<ListItem> iterator = listItems.iterator();
//			while (iterator.hasNext()) {
//				ListItem item = iterator.next();
//				if ("ad".equals(item.getType()))
//					iterator.remove();
//			}
//			for (int i = 0; i < focusPlutus.getAdMaterials().size(); i++) {
//				material = focusPlutus.getAdMaterials().get(i);
//				if (material.getImageURL().length() == 0)
//					continue;
//				ListItem item = new ListItem();
//				item.setTitle(material.getText());
//				item.setThumbnail(material.getImageURL());
//				item.setId(material.getAdAction().getType() + "://"
//						+ material.getAdAction().getUrl());
//				item.setExtra(material.getAdId());
//				item.setType("ad");
//				try {
//					if (!data.getUnitListItems().contains(item)) {
//						// @gm, in case the index exceeded the boundary
//						if (material.getAdConditions().getIndex() > data.getUnitListItems().size()){
//						  if (1 == data.getUnitListItems().size()) {
//						    data.getUnitListItems()
//                            .add(data.getUnitListItems().size(), item);
//                          } else {
//                            data.getUnitListItems()
//                            .add(data.getUnitListItems().size() - 1, item);
//                          }
//						}
//						else
//							data.getUnitListItems()
//									.add(material.getAdConditions().getIndex(),
//											item);
//					}
//				} catch (Exception e) {
//					e.printStackTrace();
//				}
//			}
//			return data;
//		}

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
	@Override
	public void pullDownRefresh(boolean ignoreExpired) {
		if (!PhoneManager.getInstance(getActivity()).isConnectedNetwork())
			return;		
		if (channel == null) {
            return;
		}
		String param = channel.getChannelSmallUrl();
		if (!ignoreExpired
				&& !IfengNewsApp.getMixedCacheManager().isExpired(param))
			return;
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
	public void postExecut(LoadContext<?, ?, VideoListUnit> context) {
		if (context.getType() == LoadContext.TYPE_HTTP) {
			int page = 0;
			try {
				page = Integer.parseInt(Uri.parse(context.getParam().toString())
						.getQueryParameter("positionId"));
			} catch (Exception e) {
				page = 1;
				e.printStackTrace();
			}
			unit = context.getResult();			
			if(unit==null){
			    context.setResult(null);
				return;
			}			
			if (1 == page) { 
              //Only the first page has headImage Data.
			  filerInvalidHeadImageItems(unit.getHeader());
            }
			else if(page > 1){
            	filterDuplicate(unit.getBodyList(),totalListItems);
            }
			//过滤不正确的数据，如title为空&视频类型为live，则不显示该条数据  
			filerInvalidItems(unit.getBodyList());			
			//check the integrity of data
			// 如果频道第一页加载得到结果少于2条，则显示加载失败
			if ((unit.getRelate().equals("") && unit.getTitle().equals(""))|| page == 1 ? unit
					.getBodyList().size() < 2 : false) {
				context.setResult(null);
				return;
			}
			// 到这里说明load成功，并得到了正确的频道数据，缓存之
			super.postExecut(context);	
		}
	}
	
	private void filerInvalidHeadImageItems(List<VideoListItem> items) {
	    boolean isInvalidItemExisted = false;       
        if (null == items) {
          return;
        }    
        
        Iterator<VideoListItem> it = items.iterator();
        while (it.hasNext()) {
        	VideoListItem item = it.next();
        	if (null == item || TextUtils.isEmpty(item.getImage())) {
        		it.remove();
        	}
        }
        // fix bug #18909 【视频列表】列表焦点图数据控制策略
        // 视频焦点图最多保留3个
        if (items.size() > 3) {
        	for (int i = items.size() - 1; i > 2; i--) {
        		items.remove(i);
        	}
        }
    }
	
	private void filerInvalidItems(List<VideoListItem> items) {
		Iterator<VideoListItem> iterator = items.iterator();
		while (iterator.hasNext()) {
			VideoListItem temp = iterator.next();
			if (TextUtils.isEmpty(temp.getTitle()) || "live".equals(temp.getMemberType())) {
				iterator.remove();
			}
		}
	}
	
	protected void filterDuplicate(ArrayList<VideoListItem> resultItems, ArrayList<VideoListItem> totalItems) {
		List<String> documentIds = new ArrayList<String>();
		for (VideoListItem item : totalItems)
			documentIds.add(item.getMemberItem().getGuid());

		int i = 0;
		while (true) {
			if (i >= resultItems.size())
				break;
			if (documentIds.contains(resultItems.get(i).getMemberItem().getGuid()))
				resultItems.remove(i);
			else
				i++;
		}
	}

}

