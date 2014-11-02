package com.ifeng.news2.activity;

import java.util.ArrayList;
import android.content.Context;
import android.database.DataSetObserver;
import android.os.Bundle;
import android.util.Patterns;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ExpandableListView.OnChildClickListener;
import android.widget.ExpandableListView.OnGroupCollapseListener;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengLoadableActivity;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.bean.ListUnit;
import com.ifeng.news2.bean.ListUnits;
import com.ifeng.news2.util.ActivityStartManager;
import com.ifeng.news2.util.CommentsManager;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.RestartManager;
import com.ifeng.news2.widget.LoadableViewWrapper;
import com.qad.loader.LoadContext;
import com.qad.loader.RetryListener;
import com.qad.loader.StateAble;
import com.umeng.analytics.MobclickAgent;

/**
 * This class holds the content of the topic, and both the title and the
 * introduction
 * 
 * @author gao_miao
 * 
 */
public class TopicListActivity extends IfengLoadableActivity<ListUnit> {
	private long startTime = 0;
	public final static String ACTION_VIEW_LIST = "action.com.ifeng.activity.TopicListActivity.ViewList";
	private String id = "";
	private String document_id = "";
	private String title = "";
	private String commentType = "";
	private String wwwUrl = "";
	private String intro = "";
	private String commentsUrl="";
	private ListUnits units = new ListUnits();
	private ArrayList<ListItem> mList = new ArrayList<ListItem>();
	private ArrayList<ArrayList<ListItem>> mAdapterList = null;
	private ExpandableListView mListView;
	private TopicHeaderView mHeaderView;
	private LoadableViewWrapper wrapper;
	private ImageButton mLeftButton = null;
	private ImageButton mRightButton = null;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		id = getIntent().getStringExtra("id");
		RelativeLayout content = (RelativeLayout) LayoutInflater.from(this)
				.inflate(layout.topic_list_main, null);
		mLeftButton = (ImageButton) content.findViewById(R.id.left_button);
		mRightButton = (ImageButton) content.findViewById(R.id.right_button);
		mLeftButton.setOnClickListener(titleOnClickListener);
		mHeaderView = new TopicHeaderView(this);
		mListView = (ExpandableListView) content.findViewById(R.id.topic_list);
		mListView.addHeaderView(mHeaderView);
		wrapper = new MyLoadableViewWrapper(this, content);
		wrapper.setOnRetryListener(new RetryListener() {
			
			@Override
			public void onRetry(View arg0) {
				startLoading();
			}
		});
		wrapper.setBackgroundResource(drawable.channellist_selector);
		setContentView(wrapper);
		startLoading();
	}

	@Override
	public StateAble getStateAble() {
		return wrapper;
	}

	@Override
	public void startLoading() {
		super.startLoading();
		getLoader().startLoading(
				new LoadContext<String, Object, ListUnit>(id, this, ListUnit.class, Parsers.newListUnitParser(), LoadContext.FLAG_CACHE_FIRST));
	}

	@Override
	public void loadComplete(LoadContext<?, ?, ListUnit> context) {
		super.loadComplete(context);
		ListUnit unit = (ListUnit) context.getResult();
		units.add(unit);
		intro = unit.getHead().getIntroductin();
		wwwUrl = unit.getHead().getWwwUrl();
		commentType = unit.getHead().getCommentType();
		commentsUrl = unit.getHead().getCommentsUrl();
		//
		document_id = unit.getHead().getDocumentId();
		title = unit.getHead().getTitle();
		mRightButton.setOnClickListener(titleOnClickListener);
		if (!Patterns.WEB_URL.matcher(wwwUrl).matches())
			mRightButton.setVisibility(View.INVISIBLE);
		else mRightButton.setVisibility(View.VISIBLE);
		initListView(unit);
	}

	private void initListView(final ListUnit unit) {
		mHeaderView.setupHeader();
		mList = unit.getUnitListItems();
		if(null == mList || 0 == mList.size()){
			IntentUtil.redirectHome(TopicListActivity.this);
			return;
		}
		generateList();
		mListView.setGroupIndicator(null);
		TopicExpandableListAdapter adapter = new TopicExpandableListAdapter();
		mListView.setAdapter(adapter);
		mListView.setOnChildClickListener(new OnChildClickListener() {

			@Override
			public boolean onChildClick(ExpandableListView parent, View v,
					int groupPosition, int childPosition, long id) {
				int position = getPosition(groupPosition, childPosition);
				ActivityStartManager.startDetail(TopicListActivity.this, position,
						unit.getIds(), unit.getDocUnits(), Config.CHANNELS[9],
						ConstantManager.ACTION_FROM_APP);
				return true;
			}
		});
		mListView.setOnGroupCollapseListener(new OnGroupCollapseListener() {
			
			@Override
			public void onGroupCollapse(int groupPosition) {
				mListView.expandGroup(groupPosition);
			}
		});
		for (int position = 1; position <= adapter.getGroupCount(); position++)
			mListView.expandGroup(position - 1);
	}

	// Construct a ArrayList<ArrayList<ListItem>> classified the news into
	// different groups, used for ExpanableListView
	private void generateList() {
		mAdapterList = new ArrayList<ArrayList<ListItem>>();
		String extra = null;
		ArrayList<ListItem> tmp = null;
		for (int i = 0; i < mList.size(); i++) {
			if (!mList.get(i).getExtra().equals(extra)) {
				if (tmp != null)
					mAdapterList.add(tmp);
				extra = mList.get(i).getExtra();
				tmp = new ArrayList<ListItem>();
			}
			tmp.add(mList.get(i));
		}
		mAdapterList.add(tmp);
	}

	// Get position according to the position of ArrayList<ArrayList<ListItem>>
	protected int getPosition(int groupPosition, int childPosition) {
		int position = 0;
		for (int i = 0; i <= groupPosition; i++) {
			if (i != groupPosition)
				position += mAdapterList.get(i).size();
			else
				position += childPosition;
		}
		return position;
	}

	@Override
	public Class<ListUnit> getGenericType() {
		return ListUnit.class;
	}

	/**
	 * Header view containing the title and introduction
	 * 
	 * @author gao_miao
	 * 
	 */
	private class TopicHeaderView extends LinearLayout {

		public TopicHeaderView(Context context) {
			super(context);
			setOrientation(VERTICAL);
			setBackgroundColor(0xfff7f7f7);
		}

		public void setupHeader() {
			removeAllViews();
			TextView titleView = new TextView(getContext());
			titleView.setLayoutParams(new LayoutParams(
					LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
			titleView.setPadding(15, 20, 0, 15);
			titleView.setTextSize(20);
			titleView.setTextColor(0xff262626);
			titleView.setText(title);
			addView(titleView);

			ImageView divider1 = new ImageView(getContext());
			divider1.setLayoutParams(new LayoutParams(
					LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
			divider1.setImageResource(R.drawable.divider);
			divider1.setPadding(10, 0, 10, 20);
			addView(divider1);

			TextView introView = new TextView(getContext());
			introView.setLayoutParams(new LayoutParams(
					LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
			introView.setTextSize(13);
			introView.setLineSpacing(2, 1);
			introView.setTextColor(0xffA6A6A6);
			introView.setMaxLines(7);
			introView.setText(intro);
			introView.setPadding(20, 0, 20, 0);
			addView(introView);

			ImageView divider2 = new ImageView(getContext());
			divider2.setLayoutParams(new LayoutParams(
					LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
			divider2.setImageResource(R.drawable.divider);
			divider2.setPadding(10, 20, 10, 13);
			addView(divider2);
		}

	}

	private class MyLoadableViewWrapper extends LoadableViewWrapper {

		public MyLoadableViewWrapper(Context context, View normalView) {
			super(context, normalView);
		}

		@Override
		protected View initLoadingView() {
			View v = LayoutInflater.from(getContext()).inflate(
					layout.topic_loading, null);
			((TextView) v.findViewById(R.id.textView1)).setText("正在载入，请稍候...");
			return v;
		}

		@Override
		protected View initRetryView() {
			View v = LayoutInflater.from(getContext()).inflate(
					layout.topic_loading, null);
			((TextView) v.findViewById(R.id.textView1)).setText("获取内容失败");
			((TextView) v.findViewById(R.id.textView2)).setText("点击重试");
			return v;
		}
	}

	/**
	 * Adapter of the content
	 * 
	 * @author gao_miao
	 * 
	 */
	private class TopicExpandableListAdapter implements ExpandableListAdapter {

		@Override
		public boolean areAllItemsEnabled() {
			return true;
		}

		@Override
		public Object getChild(int groupPosition, int childPosition) {
			return mAdapterList.get(groupPosition).get(childPosition);
		}

		@Override
		public long getChildId(int groupPosition, int childPosition) {
			return 0;
		}

		@Override
		public View getChildView(int groupPosition, int childPosition,
				boolean isLastChild, View convertView, ViewGroup parent) {
			View view = LayoutInflater.from(TopicListActivity.this).inflate(
					layout.widget_topic_list_item, null);
			TextView textView = (TextView) view.findViewById(R.id.title);
			textView.setText(mAdapterList.get(groupPosition).get(childPosition)
					.getTitle());
			return view;
		}

		@Override
		public int getChildrenCount(int groupPosition) {
			return mAdapterList.get(groupPosition).size();
		}

		@Override
		public long getCombinedChildId(long groupId, long childId) {
			return 0;
		}

		@Override
		public long getCombinedGroupId(long groupId) {
			return 0;
		}

		@Override
		public Object getGroup(int groupPosition) {
			return mAdapterList.get(groupPosition);
		}

		@Override
		public int getGroupCount() {
			return mAdapterList.size();
		}

		@Override
		public long getGroupId(int groupPosition) {
			return 0;
		}

		@Override
		public View getGroupView(int groupPosition, boolean isExpanded,
				View convertView, ViewGroup parent) {
			//  ignore it if there is no title for this group
			if (mAdapterList.get(groupPosition).get(0).getExtra().equals("")) {
				return new View(getApplicationContext());
			}
			View view = LayoutInflater.from(TopicListActivity.this).inflate(
					layout.widget_topic_list_divider, null);
			TextView textView = (TextView) view.findViewById(R.id.extra);
			textView.setText(mAdapterList.get(groupPosition).get(0).getExtra());
			return view;
		}

		@Override
		public boolean hasStableIds() {
			return false;
		}

		@Override
		public boolean isChildSelectable(int groupPosition, int childPosition) {
			return true;
		}

		@Override
		public boolean isEmpty() {
			return false;
		}

		@Override
		public void onGroupCollapsed(int groupPosition) {

		}

		@Override
		public void onGroupExpanded(int groupPosition) {

		}

		@Override
		public void registerDataSetObserver(DataSetObserver observer) {

		}

		@Override
		public void unregisterDataSetObserver(DataSetObserver observer) {

		}
	};

	private OnClickListener titleOnClickListener = new OnClickListener() {

		@Override
		public void onClick(View v) {
			if (v.equals(mLeftButton)) {
				if (getIntent() != null && getIntent().getBooleanExtra(IntentUtil.EXTRA_REDIRECT_HOME, false))
					IntentUtil.redirectHome(TopicListActivity.this);
				finish();
				overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);
			} else if (v.equals(mRightButton)) {
				CommentsActivity.redirect2Comments(TopicListActivity.this,commentsUrl,commentType, title, wwwUrl, document_id, true, true,ConstantManager.ACTION_FROM_TOPIC2);
			}
		}
	};
	
	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			if (getIntent() != null && getIntent().getBooleanExtra(IntentUtil.EXTRA_REDIRECT_HOME, false))
				IntentUtil.redirectHome(TopicListActivity.this);
			finish();
			overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);
			return true;
		}
		return super.onKeyUp(keyCode, event);
	}
	
	
	@Override
	protected void onBackgroundRunning() {
		super.onBackgroundRunning();
		startTime = System.currentTimeMillis();
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		if(Config.ADD_UMENG_STAT)MobclickAgent.onPause(this);
	}
	@Override
	protected void onResume() {
		RestartManager.checkRestart(this, startTime, RestartManager.LOCK);
		super.onResume();
		if(Config.ADD_UMENG_STAT)MobclickAgent.onResume(this);		
	}
	
		@Override
	protected void onForegroundRunning() {
		super.onForegroundRunning();
		RestartManager.checkRestart(this, startTime, RestartManager.HOME);
	}
		
		@Override
		protected void onDestroy() {
			super.onDestroy();
		}

		@Override
		public void postExecut(LoadContext<?, ?, ListUnit> arg0) {
			// TODO Auto-generated method stub
			
		}
}
