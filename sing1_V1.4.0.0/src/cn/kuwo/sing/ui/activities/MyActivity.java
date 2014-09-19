/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.UserHomeData;
import cn.kuwo.sing.business.UserHomeBusiness;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.ui.adapter.UserSongsListAdapter;
import cn.kuwo.sing.util.UserHomeDataResponseHandler;
import cn.kuwo.sing.widget.PullScrollView;
import cn.kuwo.sing.widget.PullScrollView.OnTurnListener;

import com.nostra13.universalimageloader.core.ImageLoader;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2014-4-16, 上午11:20:14
 *
 * @Author wangming
 * 
 * @Description 我的页面[v1.4新版设计]
 *
 */
public class MyActivity extends FragmentActivity {
	private static final String LOG_TAG = MyActivity.class.getSimpleName();
	private ImageView ivMyPortrait;
	private TextView tvMyName;
	private TextView tvMyID;
	private TextView tvMyAge;
	private TextView tvMyBorthCity;
	private TextView tvMyResidentCity;
	private ListView lvMySongs;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		setContentView(R.layout.activity_my);
		
		initData();
		initView();
		obtainData();
	}
	
	private void obtainData() {
		sendRequestByGet(new MyHomeDataHanlder());
	}
	
	private static void setListViewHeightBasedOnChildren(ListView listView) {  
        ListAdapter listAdapter = listView.getAdapter();  
        if (listAdapter == null) {  
                // pre-condition  
                return;  
        }  
        int totalHeight = 0;  
        for (int i = 0; i < listAdapter.getCount(); i++) {  
                View listItem = listAdapter.getView(i, null, listView);  
                listItem.measure(0, 0);  
                totalHeight += listItem.getMeasuredHeight();  
        }  
        ViewGroup.LayoutParams params = listView.getLayoutParams();  
        params.height = totalHeight + (listView.getDividerHeight() * (listAdapter.getCount() - 1));  
        listView.setLayoutParams(params);  
}   
	
	private void sendRequestByGet(UserHomeDataResponseHandler handler) {
		if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
			Toast.makeText(this, "没有网络,请稍后再试", 0).show();
			return;
		}
		//发送请求
		if(Config.getPersistence().user != null) {
			String id = Config.getPersistence().user.uid;
			String loginId = Config.getPersistence().user.uid;
			String sid = Config.getPersistence().user.sid;
			UserHomeBusiness.getUserHomeDataByGet(id, loginId, sid, handler);
		}
	}
	
	private class MyHomeDataHanlder extends UserHomeDataResponseHandler {

		@Override
		public void onSuccess(UserHomeData data) {
//			setUserType(true, data.hascare, null);
//			setUserBaseInfo(data.uname, data.uid, data.age+"岁 来自:"+data.birth_city+" 现居:"+data.resident_city, 
//					"粉丝（"+data.fans+")", "关注（"+data.fav+")", data.userpic);
			//setUserPortrait(data.userpic);
			setUserProfile(data.uname, data.uid, data.age, data.birth_city, data.resident_city);
			UserSongsListAdapter adapter = new UserSongsListAdapter(MyActivity.this);
			adapter.setUserBaseInfo(data.userpic);
			adapter.setUserKgeList(data.kgeList);
			lvMySongs.setAdapter(adapter);
			setListViewHeightBasedOnChildren(lvMySongs);
		}
		
		@Override
		public void onFailure(String errorStr) {
			super.onFailure(errorStr);
		}
		
		@Override
		public void onStart() {
			super.onStart();
		}
		
		@Override
		public void onFinish() {
			super.onFinish();
		}
		
	}

	public void setUserPortrait(String uri) {
		ImageLoader.getInstance().displayImage(uri, ivMyPortrait);
	}
	
	public void setUserProfile(String name, String id, String age, String borthCity, String residentCity) {
		tvMyName.setText(name);
		tvMyID.setText(id);
		tvMyAge.setText(age);
		tvMyBorthCity.setText(borthCity);
		tvMyResidentCity.setText(residentCity);
	}

	private void initData() {
		
	}

	private void initView() {
		ImageView ivMyBackground = (ImageView)findViewById(R.id.ivMyBackground);
		PullScrollView pullScrollViewMy = (PullScrollView)findViewById(R.id.pullScrollViewMy);
		pullScrollViewMy.setOnTurnListener(new OnTurnListener() {
			
			@Override
			public void onTurn() {
				//TODO
			}
		});
		pullScrollViewMy.init(ivMyBackground);
		
		lvMySongs = (ListView)findViewById(R.id.lvMySongs);
		
		ivMyPortrait = (ImageView)findViewById(R.id.ivMyPortrait);
		tvMyName = (TextView)findViewById(R.id.tvMyName);
		tvMyID = (TextView)findViewById(R.id.tvMyID);
		tvMyAge = (TextView)findViewById(R.id.tvMyAge);
		tvMyBorthCity = (TextView)findViewById(R.id.tvMyBorthCity);
		tvMyResidentCity = (TextView)findViewById(R.id.tvMyResidentCity);
	}
}
