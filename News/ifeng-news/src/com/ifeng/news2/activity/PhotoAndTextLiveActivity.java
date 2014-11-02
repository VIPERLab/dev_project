package com.ifeng.news2.activity;

import com.ifeng.news2.util.IntentUtil;

import android.app.Activity;

import java.util.ArrayList;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.drawable.AnimationDrawable;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengListLoadableActivity;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.adapter.PhotoAndTextLiveAdapter;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.PhotoAndTextLiveItemBean;
import com.ifeng.news2.bean.PhotoAndTextLiveListUnit;
import com.ifeng.news2.bean.PhotoAndTextLiveTitleBean;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.IfengTextViewManager;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.widget.ChannelList;
import com.ifeng.news2.widget.GifView;
import com.ifeng.news2.widget.LoadableViewWithFlingDetector;
import com.ifeng.news2.widget.PhotoAndTextLiveTitleView;
import com.ifeng.news2.widget.IfengBottom;
import com.ifeng.news2.widget.PageListViewWithHeader.ListViewListener;
import com.qad.form.PageManager;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.StateAble;
import com.qad.system.PhoneManager;
import com.qad.system.listener.NetworkListener;
import com.qad.util.OnFlingListener;
import com.qad.util.WToast;
import com.qad.view.PageListView;
import com.qad.view.PageListView.ScrollToTopListener;

/**
 * 图文直播页
 * 
 * @author SunQuan:
 * @version 创建时间：2013-8-22 下午5:14:31 类说明
 */

@SuppressWarnings("unchecked")
public class PhotoAndTextLiveActivity extends
		IfengListLoadableActivity<PhotoAndTextLiveListUnit> implements
		ListViewListener, ScrollToTopListener, OnFlingListener {
	
	public static final String INTENT_TYPE = "LR_ID";
	private static PhotoAndTextLiveAdapter adapter;
	private PhotoAndTextLiveListView list;
	private LoadableViewWithFlingDetector wrapper;
	private PhotoAndTextLiveTitleView headView;
	private ArrayList<PhotoAndTextLiveItemBean> items = new ArrayList<PhotoAndTextLiveItemBean>();
	private ArrayList<PhotoAndTextLiveItemBean> tempItems = new ArrayList<PhotoAndTextLiveItemBean>();
	private String lr_id = "";
	private boolean hasContent = true;
	// 列表是否加载失败
	private boolean isItemLoadFial = false;
	// 刷新时间间隔
	private static final int REFRESH_TIME_INTERVAL = 1000 * 60 * 2;
	private static Handler handler = new Handler(Looper.getMainLooper());

	private Runnable updateRunable = new Runnable() {

		@Override
		public void run() {
			loadOnline(true);
			handler.postDelayed(this, REFRESH_TIME_INTERVAL);
		}
	};
	private ViewGroup centerWrapper;
	private String titleUrl;
	private PhotoAndTextLiveNetWorkListener netWorkListener;
	private View empView;
	private LinearLayout titleView;
	private TextView category;
	private TextView name;
	private String action;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		init();
	}

	private void init() {
		lr_id = getIntent().getStringExtra(INTENT_TYPE) == null ? lr_id
				: getIntent().getStringExtra(INTENT_TYPE);
		action = getIntent().getAction();
		// lr_id = "7";
		titleUrl = new StringBuilder().append(Config.DIRECT_SEEDING_URL)
				.append("getlrinfo?lr_id=").append(lr_id).toString();
		adapter = new PhotoAndTextLiveAdapter(me);
		adapter.setItems(items);
		
		list = new PhotoAndTextLiveListView(this, null, PageListView.AUTO_MODE);
		headView = (PhotoAndTextLiveTitleView) LayoutInflater.from(me).inflate(R.layout.direct_seeding_bottom_title_layout, list, false);
		list.setPinnedHeaderView(headView);
		list.setAdapter(adapter);
		list.setOnScrollTopListener(this);
		list.setBackgroundDrawable(me.getResources().getDrawable(
				R.drawable.channellist_selector));
		list.setCacheColorHint(0);
		list.setListViewListener(this);
		empView = LayoutInflater.from(this).inflate(
				R.layout.direct_seeding_empty_view, null);
		ViewGroup group = new RelativeLayout(this);
		group.addView(list, new LayoutParams(LayoutParams.FILL_PARENT,
				LayoutParams.FILL_PARENT));
		group.addView(empView, new LayoutParams(LayoutParams.FILL_PARENT,
				LayoutParams.FILL_PARENT));
		list.setEmptyView(empView);
		wrapper = new LoadableViewWithFlingDetector(this, group);
		wrapper.setOnRetryListener(this);
		wrapper.setOnFlingListener(this);
		setContentView();
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		StatisticUtil.doc_id = lr_id ; 
		StatisticUtil.type = StatisticUtil.StatisticPageType.piclive.toString() ; 
		super.onResume();
	}
	
	/**
	 * 渲染视图
	 */
	private void setContentView() {
		setContentView(R.layout.direct_seeding_main);
		centerWrapper = ((ViewGroup) findViewById(R.id.center_wrapper));
		titleView = (LinearLayout) findViewById(R.id.head);
		category = (TextView) titleView.findViewById(R.id.direct_seeding_title_TV);
		name = (TextView) titleView.findViewById(R.id.direct_seeding_name_TV);
		centerWrapper.addView(wrapper, new LayoutParams(
				LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
//		((IfengBottom) findViewById(R.id.ifeng_bottom)).onClickBack();
		((IfengBottom) findViewById(R.id.ifeng_bottom)).getBack().setOnClickListener(new View.OnClickListener() {
          
          @Override
          public void onClick(View v) {
            onBackPressed();
          }
        });
		headView.setHandler(handler).setOnFlingListener(this);
		// 加载头部数据
		loadTitleData(titleUrl);
		netWorkListener = new PhotoAndTextLiveNetWorkListener();
		PhoneManager.getInstance(this).addOnNetWorkChangeListener(
				netWorkListener);
		reset();
	}
	
	@Override
	public void onBackPressed() {
	  super.onBackPressed();
	  StatisticUtil.isBack = true ; 
	  if (ConstantManager.ACTION_FROM_STORY.equals(action)) {
	    IntentUtil.redirectHome(this);
      } else {
        finish();
      }
      overridePendingTransition(0, R.anim.out_to_right);
	}

	private void loadTitleData(String url) {
		headView.setLoadState(PhotoAndTextLiveTitleView.IS_LOADING);
		getLoader()
				.startLoading(
						new LoadContext<String, LoadListener<PhotoAndTextLiveTitleBean>, PhotoAndTextLiveTitleBean>(
								ParamsManager.addParams(url),
								new LoadListener<PhotoAndTextLiveTitleBean>() {

									@Override
									public void postExecut(
											LoadContext<?, ?, PhotoAndTextLiveTitleBean> context) {
										if (context.getResult().getContent() == null) {
											context.setResult(null);
										} else if (!context.getResult()
												.getStatus().getCode()
												.equals("ok")) {
											context.setResult(null);
										}
									}

									@Override
									public void loadComplete(
											LoadContext<?, ?, PhotoAndTextLiveTitleBean> context) {
										PhotoAndTextLiveTitleBean result = context
												.getResult();
										headView
												.setLoadState(PhotoAndTextLiveTitleView.HAS_LOADED);
										if (headView.getVisibility() != View.VISIBLE) {
											headView.setVisibility(View.VISIBLE);
										}
										if(titleView.getVisibility() != View.VISIBLE){
											titleView.setVisibility(View.VISIBLE);
										}
										if (context.getType() == LoadContext.TYPE_HTTP) {
											headView.renderView(result, true);
										} else {
											// 渲染头信息视图
											headView.renderView(result, false);
										}
										renderTitle(result);

									}

									@Override
									public void loadFail(
											LoadContext<?, ?, PhotoAndTextLiveTitleBean> context) {
										headView.setLoadState(PhotoAndTextLiveTitleView.LOAD_FAIL);
										if (isItemLoadFial
												&& headView.getVisibility() == View.VISIBLE) {
											headView.setVisibility(View.GONE);
										}
										if(isItemLoadFial
												&& headView.getVisibility() == View.VISIBLE){
											titleView.setVisibility(View.GONE);
										}
									}
								}, PhotoAndTextLiveTitleBean.class, Parsers
										.newDirectSeedingTitleBean(),
								LoadContext.FLAG_HTTP_FIRST, true));
	}

	private void loadOnline(boolean isFirstPage) {
		resetRefresh();
		String param = getUrl(isFirstPage);
		getLoader()
				.startLoading(
						new LoadContext<String, LoadListener<PhotoAndTextLiveListUnit>, PhotoAndTextLiveListUnit>(
								param, PhotoAndTextLiveActivity.this,
								PhotoAndTextLiveListUnit.class, Parsers
										.newDirectSeedingListUnit(), false,
								LoadContext.FLAG_HTTP_FIRST, true));
	}

	// http://test.ichat.3g.ifeng.com/interface/getlchatbycid?lr_id=2&c_id=17&drc=1
	private String getUrl(boolean isFirstPage) {
		String param;
		// 第一次请求数据时，调用该接口
		if (items.size() == 0) {
			param = ParamsManager.addParams(me, Config.DIRECT_SEEDING_URL
					+ "getlchatbycid?lr_id=" + lr_id);
		}
		// 刷新界面时调用该接口
		else if (isFirstPage) {
			String id = tempItems.size() == 0 ? items.get(0).getId()
					: tempItems.get(0).getId();
			param = ParamsManager
					.addParams(me, Config.DIRECT_SEEDING_URL
							+ "getlchatbycid?lr_id=" + lr_id + "&c_id=" + id
							+ "&drc=0");
		}
		// 查看历史数据时，调用该接口
		else {
			param = ParamsManager
					.addParams(
							me,
							Config.DIRECT_SEEDING_URL + "getlchatbycid?lr_id="
									+ lr_id + "&c_id="
									+ items.get(items.size() - 1).getId() + "&drc=1");
		}
		return param;
	}

	@Override
	public void postExecut(LoadContext<?, ?, PhotoAndTextLiveListUnit> context) {
		PhotoAndTextLiveListUnit result = context.getResult();
		if (result == null) {
			return;
		}
		if (result.getHeader() != null && result.getHeader().getTotal() == 0) {
			result.setContent(new ArrayList<PhotoAndTextLiveItemBean>());
		} else if (result.getContent() == null || result.getStatus() == null) {
			context.setResult(null);
		}
		super.postExecut(context);
	}

	/**
	 * 统计内容
	 */
	private void record() {
		// 图文直播打开统计
		if (ConstantManager.ACTION_FROM_TOPIC2.equals(getIntent().getAction())) {
			// 入口是专题
			if (!TextUtils.isEmpty(getIntent().getStringExtra(
					ConstantManager.EXTRA_GALAGERY))) {
				StatisticUtil.addRecord(
						getApplicationContext(),
						StatisticUtil.StatisticRecordAction.page,
						"id="
								+ lr_id
								+ "$ref=topic_"
								+ getIntent().getStringExtra(
										ConstantManager.EXTRA_GALAGERY)
								+ "$type="
								+ StatisticUtil.StatisticPageType.piclive);
			}
		} else {
			// 入口是列表
			Channel channel = (Channel) getIntent().getParcelableExtra(
					ConstantManager.EXTRA_CHANNEL);
			if (null != channel) {
				StatisticUtil.addRecord(getApplicationContext(),
						StatisticUtil.StatisticRecordAction.page, "id=" + lr_id
								+ "$ref=" + channel.getStatistic() + "$type="
								+ StatisticUtil.StatisticPageType.piclive);
			}
		}

	}

	@Override
	public void loadComplete(LoadContext<?, ?, PhotoAndTextLiveListUnit> context) {
		record();

		if (isItemLoadFial) {
			isItemLoadFial = false;
		}

		if (headView.getVisibility() != View.VISIBLE) {
			headView.setVisibility(View.VISIBLE);
		}
		if(titleView.getVisibility() != View.VISIBLE){
			titleView.setVisibility(View.VISIBLE);
		}

		if (!context.getParam().toString().contains("drc=0")
				&& !context.getParam().toString().contains("drc=1")) {
			items.clear();
			list.setRefreshTime(Config.getCurrentTimeString());
			list.stopRefresh();
			// 启动定时器
			handler.postDelayed(updateRunable, REFRESH_TIME_INTERVAL);// 每2分钟执行一次

		} else if (context.getParam().toString().contains("drc=0")) {
			tempItems.addAll(0, context.getResult().getContent());
			//因为列表在顶部定时刷新后不会调用onScrollStateChanged函数，所以手动调用scrollToTop刷新数据
			if(list.getFirstVisiblePosition()==0) {
				scrollToTop();
			}
			list.setRefreshTime(Config.getCurrentTimeString());
			list.stopRefresh();
			return;
		} else if (context.getParam().toString().contains("drc=1")
				&& context.getResult().getContent().size() == 0) {
			hasContent = false;
			if (items.size() >= list.visibleItemCount) {
				new WToast(me).showMessage(R.string.has_no_more);
			}
			list.removeFooterView(list.getFooter());
		}

		super.loadComplete(context);
	}

	@Override
	public void loadFail(LoadContext<?, ?, PhotoAndTextLiveListUnit> context) {
		super.loadFail(context);
		if (!context.getParam().toString().contains("drc=0")
				&& !context.getParam().toString().contains("drc=1")) {
			handler.removeCallbacks(updateRunable);
		}
		list.stopRefresh();
		isItemLoadFial = true;
		if (headView.getLoadState() == PhotoAndTextLiveTitleView.LOAD_FAIL) {
			headView.setVisibility(View.GONE);
			titleView.setVisibility(View.GONE);
		}
	}

	@Override
	public boolean loadPage(int pageNo, int pageSize) {
		if (hasContent) {
			loadOnline(false);
		}
		return super.loadPage(pageNo, pageSize);
	}

	@Override
	public void reset() {
		super.reset();
		list.bindPageManager(getPager());
	}

	@Override
	public Class<PhotoAndTextLiveListUnit> getGenericType() {
		return PhotoAndTextLiveListUnit.class;
	}

	@Override
	public void onRefresh() {
		loadOnline(true);
	}

	@Override
	protected void onDestroy() {
		handler.removeCallbacks(updateRunable);
		PhoneManager.getInstance(this).removeNetworkChangeListioner(
				netWorkListener);
		super.onDestroy();
	}

	@Override
	public void finish() {
		super.finish();
		overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
	}

	@Override
	public StateAble getStateAble() {
		return wrapper;
	}

	@Override
	public void scrollToTop() {
		if (tempItems.size() > 0) {
			items.addAll(0, tempItems);
			adapter.notifyDataSetChanged();
			tempItems.clear();
		}
	}

	@Override
	public void onRetry(View view) {
		super.onRetry(view);
		// 重试时候重新加载直播顶部信息
		if (headView.getLoadState() == PhotoAndTextLiveTitleView.LOAD_FAIL) {
			loadTitleData(titleUrl);
		}
		// 启动定时器
		handler.postDelayed(updateRunable, REFRESH_TIME_INTERVAL);// 每2分钟执行一次
	}

	static class PhotoAndTextLiveListView extends ChannelList {
		
		private View mHeaderView;
		private int stateHeight;
		private int mHeaderViewWidth;
	    private int mHeaderViewHeight;
	    private GifViewRunnable runnable;
		
		public void setPinnedHeaderView(View view) {
	        mHeaderView = view;
	        if (mHeaderView != null) {
	        	setFadingEdgeLength(0);
		    }
		    requestLayout();
		}

		@Override
	    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
	        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
	        if (mHeaderView != null) {
	            measureChild(mHeaderView, widthMeasureSpec, heightMeasureSpec);
	            mHeaderViewWidth = mHeaderView.getMeasuredWidth();
	            mHeaderViewHeight = mHeaderView.getMeasuredHeight();
	            stateHeight = mHeaderView.findViewById(R.id.state_wrapper).getMeasuredHeight()+mHeaderView.findViewById(R.id.bottom_line).getMeasuredHeight()+IfengTextViewManager.dip2px(getContext(), 9);
	            setHeaderViewDefaultHeight(mHeaderViewHeight);
	        }
	    }
		
		public PhotoAndTextLiveListView(Context context,
				PageManager<?> pageManager, int flag) {
			super(context, pageManager, flag);
			setHeadViewhandler(new invokeHeadViewhandler() {
				@Override
				public void invokeHeadView(int height) {
					configureHeaderView(View.VISIBLE);
				}
			});
		}

		@Override
		protected View initLoadView() {
			return LayoutInflater.from(getContext()).inflate(
					R.layout.direct_seeding_load_fail, null);
		}
		
		@Override
	    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
	        super.onLayout(changed, left, top, right, bottom);
	        if (mHeaderView != null) {
	            configureHeaderView(View.VISIBLE);
	        }
	    }
		
		private void configureHeaderView(int visible) {
			if(mHeaderView==null)return;			
			View firstView = getHeaderView();
            if (firstView != null&& getFirstVisiblePosition()==0) {
                int bottom = firstView.getBottom();
                if(bottom <= stateHeight){
                	mHeaderView.layout(0, stateHeight-mHeaderViewHeight, mHeaderViewWidth, stateHeight);
                	return;
                }
                int headerHeight = mHeaderView.getHeight();
                int y;
                if (bottom < headerHeight) {
                    y = (bottom - headerHeight);
                } else {
                    y = 0;
                }
                mHeaderView.layout(0, y, mHeaderViewWidth, mHeaderViewHeight+y );
            }else{
            	mHeaderView.layout(0, stateHeight-mHeaderViewHeight, mHeaderViewWidth, stateHeight);
            }
            
		}
		

		@Override
		protected void dispatchDraw(Canvas canvas) {
		    super.dispatchDraw(canvas);
		    drawChild(canvas, mHeaderView, getDrawingTime());
		    if(runnable == null){
		    	GifView view = (GifView) mHeaderView.findViewById(R.id.direct_seeding_GV);
				((AnimationDrawable) view.getBackground()).start();
		    	runnable = new GifViewRunnable(this, canvas);
		    	handler.postDelayed(runnable, 250);
		    }
		}
		
		@Override
		protected void onDetachedFromWindow() {
			handler.removeCallbacks(runnable);
			super.onDetachedFromWindow();
		}
		
		private class GifViewRunnable implements Runnable {
			
			private Canvas canvas;
			private ViewGroup group;

			public GifViewRunnable(ViewGroup group, Canvas canvas) {
				this.group = group;
				this.canvas = canvas;
			}

			@Override
			public void run() {
				drawChild(canvas, mHeaderView, getDrawingTime());
				handler.postDelayed(this, 250);
				group.invalidate();
			}
		}
		
	}

	/**
	 * 网络状态监测 在连接网络的时候会重新请求头部数据
	 * 
	 * @author SunQuan
	 * 
	 */
	private final class PhotoAndTextLiveNetWorkListener implements
			NetworkListener {

		@Override
		public void onWifiConnected(NetworkInfo networkInfo) {
			loadTitleData(titleUrl);
		}

		@Override
		public void onMobileConnected(NetworkInfo networkInfo) {
			loadTitleData(titleUrl);
		}

		@Override
		public void onDisconnected(NetworkInfo networkInfo) {
		}

	}
	
	
	private void renderTitle(
			PhotoAndTextLiveTitleBean result) {
		name.setText(result.getContent().getName());
		category.setText(result.getContent().getLcat_name());
	}


	@Override
	public void onFling(int flingState) {
		if (flingState == OnFlingListener.FLING_RIGHT) {
			finish();
		}
	}

}
