package com.ifeng.news2.sport_live.fragment;

import java.util.ArrayList;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.AdapterView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengListLoadableFragment;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.sport_live.SportMainActivity;
import com.ifeng.news2.sport_live.entity.SportCommentItem;
import com.ifeng.news2.sport_live.entity.SportCommentUnit;
import com.ifeng.news2.util.ParamsManager;
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

@SuppressWarnings("unchecked")
public class SportLiveCommentFragment extends
		IfengListLoadableFragment<SportCommentUnit> implements ListViewListener,OnItemClickListener,ScrollToTopListener {

	private String mt;
	private ChannelList list;
	private LoadableViewWrapper wrapper;
	private ArrayList<SportCommentItem> items = new ArrayList<SportCommentItem>();
	private ArrayList<SportCommentItem> tempItems = new ArrayList<SportCommentItem>();
	private Handler handler = new Handler(Looper.getMainLooper());
	private boolean hasContent = true;
	private Runnable updateRunable = new Runnable() {

		@Override
		public void run() {
			loadOnline(true);
			handler.postDelayed(this, SportMainActivity.REFRESH_TIME_INTERVAL);
		}
	};
	private SportCommentAdapter adapter;
	private View empView;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		mt = ((SportMainActivity)getActivity()).mt;
		init();
		reset();
	}

	private void init() {
		list = new ChannelList(getActivity(), null, PageListView.AUTO_MODE);
		adapter = new SportCommentAdapter(getActivity());		
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
		list.setListViewListener(this);
		list.setOnItemClickListener(this);
		list.setOnScrollTopListener(this);
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
	public void reset() {		
		super.reset();
		list.bindPageManager(getPager());
	}

	@Override
	public boolean loadPage(int pageNo, int pageSize) {
		if(hasContent){
			loadOnline(false);
		}
		return super.loadPage(pageNo, pageSize);
	}

	@Override
	public StateAble getStateAble() {
		return wrapper;
	}

	@Override
	public void onRefresh() {
		loadOnline(true);
	}

	private void loadOnline(boolean isFirstPage) {
		resetRefresh();
		String param = getCommentsUrl(isFirstPage);
		getLoader()
				.startLoading(
						new LoadContext<String, LoadListener<SportCommentUnit>, SportCommentUnit>(
								param, SportLiveCommentFragment.this,
								SportCommentItem.class, Parsers
										.newSportCommentUnitParser(), false,
								LoadContext.FLAG_HTTP_FIRST, true));
	}

	/**
	 * 获取直播评论url
	 * 
	 * @param isFirstPage
	 * @return
	 */
	private String getCommentsUrl(boolean isFirstPage) {
		String param;
		if (items.size() == 0) {
			param = ParamsManager.addParams(getActivity(),
					Config.SPORT_LIVE_COMMENT_URL
							+ "&requestType=chat_init&mt=" + mt);
		} else if (isFirstPage) {
			String id = tempItems.size() == 0 ? items.get(0).getId()
					: tempItems.get(0).getId();
			param = ParamsManager.addParams(getActivity(),
					Config.SPORT_LIVE_COMMENT_URL
							+ "&requestType=chat_new&lastId=" + id + "&mt="
							+ mt);
		} else {
			param = ParamsManager
					.addParams(getActivity(),
							Config.SPORT_LIVE_COMMENT_URL
									+ "&requestType=chat_old&firstId="
									+ items.get(items.size() - 1).getId()
									+ "&mt=" + mt);
		}
		return param;
	}

	@Override
	public void loadComplete(LoadContext<?, ?, SportCommentUnit> context) {
		//第一次请求数据
		if (!context.getParam().toString().contains("lastId")
				&& !context.getParam().toString().contains("firstId")) {
			handler.postDelayed(updateRunable,
					SportMainActivity.REFRESH_TIME_INTERVAL);
			items.clear();
			list.setRefreshTime(Config.getCurrentTimeString());
			list.stopRefresh();				
		}
		// 下拉刷新
		else if (context.getParam().toString().contains("lastId")) {
			tempItems.addAll(0, context.getResult().getBody());
			//因为列表在顶部定时刷新后不会调用onScrollStateChanged函数，所以手动调用scrollToTop刷新数据
			if(list.getFirstVisiblePosition()==0) {
				scrollToTop();
			}
			list.setRefreshTime(Config.getCurrentTimeString());
			list.stopRefresh();
			return;
		}
		//上拉翻页
		else if(context.getParam().toString().contains("firstId")&&context.getResult().getBody().size()==0){
			hasContent = false;
			if (items.size() >= list.visibleItemCount) {
				new WToast(getActivity()).showMessage(R.string.has_no_more);
			}
			list.removeFooterView(list.getFooter());
		}
		super.loadComplete(context);
	}
	
	@Override
	public void loadFail(LoadContext<?, ?, SportCommentUnit> context) {
		super.loadFail(context);
		if (!context.getParam().toString().contains("lastId")
				&& !context.getParam().toString().contains("firstId")) {
			handler.removeCallbacks(updateRunable);
		}
		list.stopRefresh();
	}
	
	@Override
	public void onRetry(View view) {
		super.onRetry(view);
		handler.postDelayed(updateRunable,
				SportMainActivity.REFRESH_TIME_INTERVAL);
	}
	
	@Override
	public void postExecut(LoadContext<?, ?, SportCommentUnit> context) {
		
		SportCommentUnit unit = context.getResult();
		if(unit == null) {
			return;
		}
		// check the integrity of data
		if(unit.getBody()==null||unit.getData()==null) {
			context.setResult(null);
		}
		else if (!context.getParam().toString().contains("firstId")
				&& !context.getParam().toString().contains("lastId")
				&& unit.getBody().size() == 0) {
			context.getResult().setBody(new ArrayList<SportCommentItem>());
		}
		super.postExecut(context);
	}

	@Override
	public Class<SportCommentUnit> getGenericType() {
		return SportCommentUnit.class;
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
	public void onDestroy() {
		handler.removeCallbacks(updateRunable);
		super.onDestroy();
	}

	/**
	 * 直播页评论列表adapter
	 *
	 */
	private final class SportCommentAdapter extends BasePageAdapter<SportCommentItem> {

		public SportCommentAdapter(Context ctx) {
			super(ctx);
		}

		@Override
		protected int getResource() {
			return R.layout.sport_live_comment;
		}

		@Override
		protected void renderConvertView(int position, View convertView) {
			final SportCommentItem item = items.get(position);
			CommentsViewHolder holder = (CommentsViewHolder) convertView
					.getTag();
			if (holder == null) {
				holder = CommentsViewHolder.create(convertView);
				convertView.setTag(holder);
			}
			String time =  item.getTime();
			if(!TextUtils.isEmpty(time)){
				holder.time.setText(time);
				holder.time.setVisibility(View.VISIBLE);
			}else{
				holder.time.setVisibility(View.INVISIBLE);
			}
			holder.nameView.setText(item.getUsername());
			if (item.getUserid().equals("0")) {
				holder.nameView.setTextColor(getResources().getColor(
						R.color.loading_fail_font));
			} else {
				holder.nameView.setTextColor(getResources().getColor(
						R.color.sport_live_blue));
			}
			holder.nameView.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					if (!item.getUserid().equals("0"))
						((SportMainActivity) getActivity()).speech(
								item.getUsername(), item.getUserid());
				}
			});

			if ("say".equals(item.getType())) {
				holder.to.setVisibility(View.GONE);
				holder.toNameView.setVisibility(View.GONE);
				holder.say.setVisibility(View.GONE);
			} else if ("reply".equals(item.getType())) {
				holder.to.setVisibility(View.VISIBLE);
				holder.toNameView.setVisibility(View.VISIBLE);
				holder.toNameView.setText(item.getTousername());
				holder.say.setVisibility(View.VISIBLE);
				holder.toNameView.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View v) {
						((SportMainActivity) getActivity()).speech(
								item.getTousername(), item.getTouserid());
					}
				});
			}
			holder.content.setText(item.getContent());
		}
	}
	
	 static class CommentsViewHolder{
		TextView nameView;
		TextView to;
		TextView toNameView;
		TextView say;
		TextView content;
		TextView time;
		
		public static CommentsViewHolder create(View convertView){
			CommentsViewHolder holder = new CommentsViewHolder();
			holder.nameView = (TextView) convertView.findViewById(R.id.name);
			holder.to = (TextView) convertView.findViewById(R.id.to);
			holder.toNameView = (TextView) convertView
					.findViewById(R.id.to_name);
			holder.say = (TextView) convertView.findViewById(R.id.say);
			holder.content = (TextView) convertView.findViewById(R.id.content);
			holder.time = (TextView) convertView.findViewById(R.id.time);
			return holder;
		}
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		((SportMainActivity)getActivity()).showBottomView();
	}

}
