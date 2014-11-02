package com.ifeng.news2.sport_live.fragment;

import java.util.ArrayList;
import android.app.Activity;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup.LayoutParams;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengListLoadableFragment;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.adapter.SportLiveFactAdapter;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.sport_live.SportMainActivity;
import com.ifeng.news2.sport_live.entity.SportFactItem;
import com.ifeng.news2.sport_live.entity.SportFactUnit;
import com.ifeng.news2.sport_live.util.SportFactViewHolder;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.ListDisplayStypeUtil;
import com.ifeng.news2.util.ListDisplayStypeUtil.ChannelViewHolder;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.widget.ChannelList;
import com.ifeng.news2.widget.LoadableViewWrapper;
import com.ifeng.news2.widget.PageListViewWithHeader.ListViewListener;
import com.qad.form.BasePageAdapter;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.StateAble;
import com.qad.util.WToast;
import com.qad.view.PageListView;
import com.qad.view.PageListView.ScrollToTopListener;

/**
 * @author liu_xiaoliang 体育直播主页面中间List模块
 */
@SuppressWarnings("unchecked")
public class SportLiveFactFragment extends
		IfengListLoadableFragment<SportFactUnit> implements
		OnItemClickListener, ListViewListener, OnTouchListener,
		ScrollToTopListener {

	private String mt = ""; // 体育频道
	private int topHeight = 0; // 体育头部+状态栏高度
	private int bottomHeight = 0; // 底部功能健高度
	private int replyModuleY = 0; // 回复按钮要显示的位置
	private boolean isShowReplyModule = false;
	private ChannelList list; // list
	private LoadableViewWrapper wrapper; // 壁纸 （成功显示数据，失败loadfail,点击正在加载）
	private BasePageAdapter<SportFactItem> adapter; // 体育直播list适配器
	private ArrayList<SportFactItem> items = new ArrayList<SportFactItem>();
	private ArrayList<SportFactItem> tempItems = new ArrayList<SportFactItem>();
	private Handler handler = new Handler(Looper.getMainLooper());
	private boolean hasContent = true;
	private Runnable updateRunable = new Runnable() {

		@Override
		public void run() {
			loadOnline(true);
			handler.postDelayed(this, SportMainActivity.REFRESH_TIME_INTERVAL);
		}
	};
	private View empView;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		mt = ((SportMainActivity) getActivity()).mt;
		// 初始化ChannelList
		init();
		// 重置以及load data
		reset();
	}

	private void init() {
		list = new ChannelList(getActivity(), null, PageListView.AUTO_MODE);
		list.setOnItemClickListener(this);
		list.setListViewListener(this);
		list.setOnTouchListener(this);
		list.setOnScrollTopListener(this);
		adapter = new SportLiveFactAdapter(getActivity());
		adapter.setItems(items);
		list.setAdapter(adapter);
		empView = LayoutInflater.from(getActivity()).inflate(R.layout.direct_seeding_empty_view, null);
		ViewGroup group = new RelativeLayout(getActivity());
		group.addView(list, new LayoutParams(
				LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
		group.addView(empView, new LayoutParams(
				LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
		wrapper = new LoadableViewWrapper(getActivity(), group);
		list.setEmptyView(empView);
		wrapper.setOnRetryListener(this);
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
	public void reset() {
		super.reset();
		list.bindPageManager(getPager());
	}

	@Override
	public StateAble getStateAble() {
		return wrapper;
	}

	@Override
	public boolean loadPage(int pageNo, int pageSize) {
		if (hasContent) {
			loadOnline(false);
		}
		return super.loadPage(pageNo, pageSize);
	}

	@Override
	public void loadComplete(LoadContext<?, ?, SportFactUnit> context) {
		// 体育直播打开统计
		record();
		// 第一次请求数据
		if (!context.getParam().toString().contains("lastId")
				&& !context.getParam().toString().contains("firstId")) {
			handler.postDelayed(updateRunable,
					SportMainActivity.REFRESH_TIME_INTERVAL);
			items.clear();
			list.setRefreshTime(Config.getCurrentTimeString());
			list.stopRefresh();
			if (context.getResult().getBody().size() > 0) {
				// 更新顶部视图比赛信息,只有在下拉刷新和初始化数据的时候才更新比赛信息
				((SportMainActivity) getActivity()).updateTitle(context.getResult()
						.getBody().get(0));
			}		
		}
		// 下拉刷新
		else if (context.getParam().toString().contains("lastId")) {
			// 更新顶部视图比赛信息,只有在下拉刷新和初始化数据的时候才更新比赛信息
			if (context.getResult().getBody().size() > 0) {
				((SportMainActivity) getActivity()).updateTitle(context
						.getResult().getBody().get(0));
			}
			tempItems.addAll(0, context.getResult().getBody());
			//因为列表在顶部定时刷新后不会调用onScrollStateChanged函数，所以手动调用scrollToTop刷新数据
			if(list.getFirstVisiblePosition()==0) {
				scrollToTop();
			}
			list.setRefreshTime(Config.getCurrentTimeString());
			list.stopRefresh();
			return;
		}
		// 上拉翻页
		else if (context.getParam().toString().contains("firstId")
				&& context.getResult().getBody().size() == 0) {
			hasContent = false;
			if (items.size() >= list.visibleItemCount) {
				new WToast(getActivity()).showMessage(R.string.has_no_more);
			}
			list.removeFooterView(list.getFooter());
		}
		// 会把数据更新到ChannelAdapter
		super.loadComplete(context);

	}

	@Override
	public void loadFail(LoadContext<?, ?, SportFactUnit> context) {
		super.loadFail(context);
		if (!context.getParam().toString().contains("lastId")
				&& !context.getParam().toString().contains("firstId")){
			handler.removeCallbacks(updateRunable);
		}		
		list.stopRefresh();
	}

	@Override
	public Class<SportFactUnit> getGenericType() {
		return SportFactUnit.class;
	}

	@Override
	public boolean onTouch(View v, MotionEvent event) {
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			if (isShowReplyModule) {
				replyModuleY = 0;
				isShowReplyModule = false;
			}
			break;
		case MotionEvent.ACTION_UP:
			replyModuleY = (int) event.getY();
			break;
		}
		return false;
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {

		((SportMainActivity) getActivity()).showBottomView();
		if (view == list.getFooter())
			return;

		SportFactViewHolder holder = (SportFactViewHolder) view.getTag();
		if (null != holder) {
			if (SportLiveFactAdapter.ICON_TYPE_HOST_BULE.equals(holder.item
					.getTitle_img())
					|| SportLiveFactAdapter.ICON_TYPE_HOST_YELLOW
							.equals(holder.item.getTitle_img())) {
				// 显示回复
				showReplyModule(view, holder);
			} else if (SportLiveFactAdapter.ICON_TYPE_DUSHE.equals(holder.item
					.getTitle_img())) {
				// 毒蛇页
				((SportMainActivity) getActivity()).goToPoisonousWordPage();
			}
		}

	}

	@Override
	public void onRefresh() {
		loadOnline(true);
	}

	@Override
	public void postExecut(LoadContext<?, ?, SportFactUnit> context) {
		// TODO 详细的数据监测未做
		SportFactUnit unit = context.getResult();
		if(unit == null) {
			return;
		}
		if(unit.getData()==null||unit.getBody()==null) {
			context.setResult(null);
		}
		else if (!context.getParam().toString().contains("lastId")
				&& !context.getParam().toString().contains("firstId")
				&& unit.getBody().size() == 0) {
			context.getResult().setBody(new ArrayList<SportFactItem>());		
		}
		// " load items for page #" + page + " : " + unit.getBody().size());
		// 到这里说明load成功，并得到了正确的频道数据，缓存之
		super.postExecut(context);
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		handler.removeCallbacks(updateRunable);
		// android.os.Build.VERSION_CODES.HONEYCOMB = 11 , Android 3.0.
		if (android.os.Build.VERSION.SDK_INT < 11) {
			// HONEYCOMB之前Bitmap实际的Pixel Data是分配在Native Memory中。
			// 首先需要调用reclyce()来表明Bitmap的Pixel Data占用的内存可回收
			// call bitmap.recycle to make the memory available for GC
			for (int i = 0; i < list.getChildCount(); i++) {
				Object tag = list.getChildAt(i).getTag(R.id.tag_holder);
				if (null == tag) {
					continue;
				}
				// set tag to null
				list.getChildAt(i).setTag(R.id.tag_holder, null);
//				if (tag instanceof ChannelViewHolder) {
//					ListDisplayStypeUtil
//							.cleanupChannelViewHolder((ChannelViewHolder) tag);
//				}
			}
		} else {
			// 设置channellist的各个item的相应tag为null，否则GC不回收channellist会OOM
			for (int i = 0; i < list.getChildCount(); i++) {
				list.getChildAt(i).setTag(R.id.tag_holder, null);
			}
		}
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
		// 启动定时器
		handler.postDelayed(updateRunable,
				SportMainActivity.REFRESH_TIME_INTERVAL);// 每2分钟执行一次
	}

	private void loadOnline(boolean isFirstPage) {
		resetRefresh();
		String param = getFactUrl(isFirstPage);
		getLoader()
				.startLoading(
						new LoadContext<String, LoadListener<SportFactUnit>, SportFactUnit>(
								param, SportLiveFactFragment.this,
								SportFactUnit.class, Parsers
										.newSportLiveFactUnitParser(),
								firstLoad, LoadContext.FLAG_HTTP_FIRST, true));
	}

	/**
	 * 获取直播赛况url
	 * 
	 * @param isFirstPage
	 * @return
	 */
	private String getFactUrl(boolean isFirstPage) {
		String param;
		if (items.size() == 0) {
			param = ParamsManager.addParams(getActivity(),
					Config.SPORT_LIVE_FACT_URL + "&requestType=live_init&mt="
							+ mt);
		} else if (isFirstPage) {
			String id = tempItems.size() == 0 ? items.get(0).getId()
					: tempItems.get(0).getId();
			param = ParamsManager.addParams(getActivity(),
					Config.SPORT_LIVE_FACT_URL + "&requestType=live_new&mt="
							+ mt + "&lastId=" + id);
		} else {
			param = ParamsManager.addParams(getActivity(),
					Config.SPORT_LIVE_FACT_URL + "&requestType=live_old&mt="
							+ mt + "&firstId="
							+ items.get(items.size() - 1).getId());
		}
		return param;
	}

	/**
	 * 统计直播信息
	 */
	private void record() {
		Activity ctx = getActivity();
		if (null != ctx) {
			if (ConstantManager.ACTION_FROM_TOPIC2.equals(ctx.getIntent()
					.getAction())) {
				// 入口是专题
				if (!TextUtils.isEmpty(ctx.getIntent().getStringExtra(
						ConstantManager.EXTRA_GALAGERY))) {
					StatisticUtil
							.addRecord(
									StatisticUtil.StatisticRecordAction.page,
									"id="
											+ mt
											+ "$ref=topic_"
											+ ctx.getIntent()
													.getStringExtra(
															ConstantManager.EXTRA_GALAGERY)
											+ "$type="
											+ StatisticUtil.StatisticPageType.sportslive);
				}
			} else {
				// 入口是列表
				Channel channel = (Channel) ctx.getIntent().getParcelableExtra(
						ConstantManager.EXTRA_CHANNEL);
				if (null != channel) {
					StatisticUtil
							.addRecord(
									StatisticUtil.StatisticRecordAction.page,
									"id="
											+ mt
											+ "$ref="
											+ channel.getStatistic()
											+ "$type="
											+ StatisticUtil.StatisticPageType.sportslive);
				}
			}
		}
	}
	
	@Override
	public void onResume() {
		// TODO Auto-generated method stub
		StatisticUtil.doc_id = mt ;
		StatisticUtil.type = StatisticUtil.StatisticPageType.sportslive.toString(); 
		super.onResume();
	}

	private void showReplyModule(View view, final SportFactViewHolder holder) {
		//
		isShowReplyModule = true;
		LayoutInflater inflater = LayoutInflater.from(getActivity());
		View replyModule = inflater.inflate(layout.sport_live_reply_module,
				null);
		ImageView replyButton = (ImageView) replyModule
				.findViewById(R.id.reply_button);

		DisplayMetrics metric = new DisplayMetrics();
		getActivity().getWindowManager().getDefaultDisplay().getMetrics(metric);

		final PopupWindow replyPopup = new PopupWindow(replyModule);
		replyPopup.setWidth(ViewGroup.LayoutParams.FILL_PARENT);
		replyPopup.setHeight(ViewGroup.LayoutParams.WRAP_CONTENT);
		replyPopup.setBackgroundDrawable(getResources().getDrawable(
				R.drawable.pop_bottom));
		replyPopup.setAnimationStyle(R.style.AnimationPreview);
		replyPopup.setFocusable(true);

		Rect rect = new Rect();
		Window win = getActivity().getWindow();
		win.getDecorView().getWindowVisibleDisplayFrame(rect);
		int statusBarHeight = rect.top;

		// 列表开始显示的高度 = 头部 + 状态栏高度
		topHeight = ((SportMainActivity) getActivity()).getTitleHeight()
				+ statusBarHeight;
		// 底部功能按钮条的高度
		bottomHeight = ((SportMainActivity) getActivity()).getBottomHeight();
		// 此时获取不到的高度，80是回复框背景图片的高度，所以回复框高度暂且使用高度为80
		int replyPopupHeight = 80;
		// 回复框开始显示的位置
		int showReplyPopupY = replyModuleY + topHeight;
		if (replyModuleY + /* replyPopup.getHeight() */replyPopupHeight
				+ topHeight > metric.heightPixels - bottomHeight) {
			showReplyPopupY -= /* replyPopup.getHeight() */replyPopupHeight;
		}

		replyPopup.showAtLocation(view,
				Gravity.CENTER_HORIZONTAL | Gravity.TOP, 0, showReplyPopupY);
		replyButton.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				((SportMainActivity) getActivity()).speech(
						holder.item.getLiver(), holder.item.getId());
				isShowReplyModule = false;
				replyPopup.dismiss();
			}
		});
	}

}
