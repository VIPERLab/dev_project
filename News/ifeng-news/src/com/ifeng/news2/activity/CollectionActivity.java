package com.ifeng.news2.activity;

import java.util.ArrayList;

import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.TextView;

import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.id;
import com.ifeng.news2.adapter.ChannelAdapter;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.db.CollectionDBManager;
import com.ifeng.news2.util.ActivityStartManager;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ListDisplayStypeUtil;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticPageType;
import com.ifeng.news2.util.StatisticUtil.StatisticRecordAction;
import com.ifeng.news2.util.WindowPrompt;
import com.ifeng.news2.widget.IfengBottom;
import com.ifeng.news2.widget.ListViewWithFlingDetector;
import com.qad.util.OnFlingListener;

public class CollectionActivity extends AppBaseActivity implements OnItemClickListener, OnTouchListener, OnClickListener,OnFlingListener{

	private float coordinateX = -1f; 
	private int screenWidth;
	private ListViewWithFlingDetector listView;
	private IfengBottom ifengBottom;
	private WindowPrompt windowPrompt;
	private ChannelAdapter adapter;
	boolean isFirstComeIn = true;
	private CollectionDBManager collectionManager;
//	private ArrayList<String> ids = new ArrayList<String>();
	private ArrayList<ListItem> listItems = new ArrayList<ListItem>();
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.favourite);
		initView();
		initDatas();
		initAdapter();
		beginStatistic();
	}
	
	private void beginStatistic() {
		// TODO Auto-generated method stub
		StatisticUtil.addRecord(this
				, StatisticUtil.StatisticRecordAction.page
				, "id=Collect"+"$ref=ys"+"$type=" + StatisticUtil.StatisticPageType.set);
	}
	
	@Override
	protected void onResume() {
		StatisticUtil.doc_id = "noid";
		StatisticUtil.type = StatisticUtil.StatisticPageType.set.toString() ;
		super.onResume();
		if (isFirstComeIn) {
			isFirstComeIn = false;
		} else {
			collectionManager.deteleCancelCollection();
			initDatas();
			initAdapter();
		}
	}
	
    private void initView(){
    	listView = (ListViewWithFlingDetector) findViewById(R.id.favourite_list);
		listView.setOnCreateContextMenuListener(this);
		listView.setEmptyView(findViewById(id.emptyView));	
		listView.setDivider(null);
		//设置滑动监听
		listView.setOnFlingListener(this);
		ifengBottom = (IfengBottom) findViewById(R.id.ifeng_bottom);
		//ifengBottom.onClickBack();
		ifengBottom.findViewById(R.id.back).setOnClickListener(this);
		windowPrompt = WindowPrompt.getInstance(this);
    }
    
    private void initDatas(){
    	screenWidth = getWindowManager().getDefaultDisplay().getWidth();
    	collectionManager = new CollectionDBManager(this);
    	listItems.clear();
    	listItems.addAll(collectionManager.getCollectionListData());
//    	setIds();
    }
	
//    private void setIds(){
//    	if (null == listItems) 
//			return;
//    	ids.clear();
//    	for (ListItem listItem : listItems) {
//    		if (CollectionDBManager.TYPE_DOC.equals(listItem.getType())) {
//				ids.add(listItem.getId());
//			} 
//		}
//    }
    
//    public int  getDocPositionByDocId(ListItem listItem){
//    	for (int i = 0; i < ids.size(); i++) {
//			if (null != ids.get(i) && ids.get(i).equals(listItem.getId())) 
//				return i;	
//		}
//		return -1;
//    }
    
    private void initAdapter(){
    	adapter = new ChannelAdapter(this, ListDisplayStypeUtil.CHANNEL_COLLECTION_FLAG);
		adapter.setItems(listItems);
		listView.setAdapter(adapter);
		adapter.notifyDataSetChanged();
		listView.setOnItemClickListener(this);
		listView.setOnTouchListener(this);
    }

	@Override
	public void onItemClick(AdapterView<?> arg0, View view, int position, long arg3) {
		ListItem listItem = listItems.get(position);
		if (screenWidth*4/5 < coordinateX) {
			String docId = listItem.getDocumentId();
			if (collectionManager
					.getCollectionStatusById(docId)) {
				((TextView)view.findViewById(R.id.title)).setTextColor(getResources().getColor(R.color.list_readed_text_color));
				view.findViewById(R.id.collection_button)
				.setBackgroundResource(drawable.list_collection);
				collectionManager.updateCollectionStatus(
						listItem.getDocumentId(), false);
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_collection ,R.string.toast_store_cancel_title,R.string.toast_store_cancel_content);
			} else {
				((TextView)view.findViewById(R.id.title)).setTextColor(0xff2b5470);
				view.findViewById(R.id.collection_button)
				.setBackgroundResource(drawable.list_collectioned);
				collectionManager.updateCollectionStatus(
						listItem.getDocumentId(), true);
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.toast_store_success_title,R.string.toast_store_success_content);
				//收藏统计
				StatisticUtil.addRecord(this, StatisticRecordAction.action, "type="+StatisticPageType.store);
			}
		} else {
			if (CollectionDBManager.TYPE_SLIDE.equals(listItem.getType())) {
				Extension extension = new Extension();
				extension.setType(listItem.getType());
				extension.setUrl(listItem.getId());
				Log.e("tag", "collection new  url = "+listItem.getId());
				IntentUtil.startActivityByExtension(this, extension);
			}else {
				//ActivityStartManager.startDetail(this,getDocPositionByDocId(listItem),ids,null,Channel.NULL,ConstantManager.ACTION_FROM_TOPIC2);
				ActivityStartManager.startDetail(this, listItem.getId(), listItem.getThumbnail(),listItem.getIntroduction(), Channel.NULL, ConstantManager.ACTION_FROM_COLLECTION);
			}
		}
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		collectionManager.deteleCollectionById(null);
		listItems.clear();
		listItems.addAll(collectionManager.getCollectionListData());
		adapter.setItems(listItems);
		listView.setAdapter(adapter);
		adapter.notifyDataSetChanged();
		return super.onOptionsItemSelected(item);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		menu.add("清空收藏");
		return true;
	}
	 
	@Override
	protected void onDestroy() {
		collectionManager.deteleCancelCollection();
		super.onDestroy();
	}

	@Override
	public boolean onTouch(View arg0, MotionEvent event) {
		coordinateX = event.getX();
		return false;
	}

	@Override
	public void onClick(View v) {
	    onBackPressed();
	}
	
	@Override
	public void onBackPressed() {
		StatisticUtil.isBack = true ; 
		ConstantManager.isSettingsShow = true ; 
	    finish();
	    overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
	}

	/**
	 * 设置滑动监听
	 */
	@Override
	public void onFling(int flingState) {
		// TODO Auto-generated method stub
		if (flingState == OnFlingListener.FLING_RIGHT) {
            onBackPressed();
		}
	}
	
//	public void go2Setting(){
//		Intent intent = new Intent(this, SettingActivity.class);
//		startActivity(intent);
//		finish();
//	}
    
    
}
