/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import java.util.ArrayList;
import java.util.List;

import android.content.Intent;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.UserHomeData;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.business.UserHomeBusiness;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.ui.adapter.UserKgeListAdapter;
import cn.kuwo.sing.util.UserHomeDataResponseHandler;

import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshBase.Mode;
import com.handmark.pulltorefresh.library.PullToRefreshBase.OnRefreshListener;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.nostra13.universalimageloader.core.ImageLoader;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2013-12-26, 下午12:14:33
 *
 * @Author wangming
 *
 */
public class OtherHomeActivity extends BaseActivity {
	private static final String LOG_TAG = "OtherHomeActivity";
	private static final String HTTP_URL_ATTENTATION = "http://changba.kuwo.cn/kge/webmobile/an/user_list.html?type=getfav";
	private static final String HTTP_URL_FANS = "http://changba.kuwo.cn/kge/webmobile/an/user_list.html?type=getfans";
	private String mTitle;
	private String mId;
	private TextView tvOtherHomeTitle;
	private Button btOtherHomeBack;
	private PullToRefreshListView lvOtherHome;
	private List<Kge> mKgeList = new ArrayList<Kge>();
	private RelativeLayout rlOtherHomeNoNetwork;
	private ImageView ivOtherHomeNoNetwork;
	private RelativeLayout rlOtherHomeProgress;
	private String mUserPicUrl;
	private UserKgeListAdapter mAdapter;
	private int mCurrentPageNumber = 1; //从1开始
	private int mTotalPage = -1;
	private int mHasCare = 0;
	private LinearLayout llUserHomeDeletePrompt;
	private FrameLayout flOtherHome;
	
	protected void onCreate(android.os.Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.other_home_layout);
		initData();
		initView();
		obtainData();
	}

	private void initData() {
		mTitle = getIntent().getStringExtra("title");
		mId = getIntent().getStringExtra("id");
	}

	private void initView() {
		flOtherHome = (FrameLayout)findViewById(R.id.flUserHome);
		flOtherHome.setVisibility(View.INVISIBLE);
		llUserHomeDeletePrompt = (LinearLayout)findViewById(R.id.llUserHomeDeletePrompt);
		llUserHomeDeletePrompt.setVisibility(View.INVISIBLE);
		rlOtherHomeProgress = (RelativeLayout)findViewById(R.id.rlOtherHomeProgress);
		rlOtherHomeProgress = (RelativeLayout)findViewById(R.id.rlOtherHomeProgress);
		rlOtherHomeProgress.setVisibility(View.INVISIBLE);
		rlOtherHomeNoNetwork = (RelativeLayout)findViewById(R.id.rlOtherHomeNoNetwork);
		rlOtherHomeNoNetwork.setVisibility(View.INVISIBLE);
		ivOtherHomeNoNetwork = (ImageView)findViewById(R.id.ivOtherHomeNoNetwork);
		ivOtherHomeNoNetwork.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				obtainData();
			}
		});
		tvOtherHomeTitle = (TextView)findViewById(R.id.tvOtherHomeTitle);
		tvOtherHomeTitle.setText(mTitle);
		btOtherHomeBack = (Button)findViewById(R.id.btOtherHomeBack);
		
		btOtherHomeBack.setOnClickListener(mOnClickListener);
		
		lvOtherHome = (PullToRefreshListView)findViewById(R.id.lvUserHome);
		lvOtherHome.setMode(Mode.BOTH);
		lvOtherHome.getRefreshableView().setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				if(mKgeList != null) {
					Kge kge = mKgeList.get(position-2);
					MTVBusiness mb = new MTVBusiness(OtherHomeActivity.this);
					mb.playMtv(kge.id);
				}
			}
		});
		lvOtherHome.setOnRefreshListener(new OnRefreshListener<ListView>() {

			@Override
			public void onRefresh(PullToRefreshBase<ListView> refreshView) {
				PullToRefreshBase.Mode currentMode = refreshView.getCurrentMode();
				switch (currentMode) {
				case PULL_FROM_START:
					sendRequestByGet(new OtherHomeDataHanlder4Refresh());
					break;
				case PULL_FROM_END:
					if(mCurrentPageNumber < mTotalPage) {
						sendRequestByPost(new OtherHomeDataHanlder4LoadMore());
					}else {
						lvOtherHome.onRefreshComplete();
						Toast.makeText(OtherHomeActivity.this, "已经翻到最后一页了", 0).show();
					}
					break;
				default:
					break;
				}
			}
		});
		
		mAdapter = new UserKgeListAdapter(this);
	}

	private void obtainData() {
		if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
			flOtherHome.setVisibility(View.INVISIBLE);
			rlOtherHomeNoNetwork.setVisibility(View.VISIBLE);
			return;
		}
		sendRequestByGet(new OtherHomeDataHanlder());
	};
	
	private class OtherHomeDataHanlder4LoadMore extends UserHomeDataResponseHandler {

		@Override
		public void onSuccess(UserHomeData data) {
			KuwoLog.d(LOG_TAG, "data.uname="+data.uname);
			lvOtherHome.onRefreshComplete();
			mKgeList.addAll(data.kgeList);
			mAdapter.setUserKgeList(data.kgeList);
			lvOtherHome.setAdapter(mAdapter);
		}
		
		@Override
		public void onFailure(String errorStr) {
			super.onFailure(errorStr);
			lvOtherHome.onRefreshComplete();
		}
	}
	
	private class OtherHomeDataHanlder4Refresh extends UserHomeDataResponseHandler {

		@Override
		public void onSuccess(UserHomeData data) {
			KuwoLog.d(LOG_TAG, "data.uname="+data.uname);
			lvOtherHome.onRefreshComplete();
			mKgeList.clear();
			mAdapter.clearList();
			mKgeList.addAll(data.kgeList);
			mHasCare = data.hascare;
			mAdapter.setUserType(false, data.hascare, mId);
			mAdapter.setUserBaseInfo(data.uname, data.uid, data.age+"岁 来自:"+data.birth_city+" 现居:"+data.resident_city, 
					"粉丝（"+data.fans+")", "关注（"+data.fav+")", data.userpic);
			mAdapter.setUserKgeList(data.kgeList);
			lvOtherHome.setAdapter(mAdapter);
		}
		
		@Override
		public void onFailure(String errorStr) {
			super.onFailure(errorStr);
			lvOtherHome.onRefreshComplete();
		}
	}
	
	private class OtherHomeDataHanlder extends UserHomeDataResponseHandler {

		@Override
		public void onSuccess(UserHomeData data) {
			KuwoLog.d(LOG_TAG, "data.uname="+data.uname);
			mTotalPage = data.total_pn;
			mKgeList.addAll(data.kgeList);
			mHasCare = data.hascare;
			mAdapter.setUserType(false, data.hascare, mId);
			mAdapter.setUserBaseInfo(data.uname, data.uid, data.age+"岁 来自:"+data.birth_city+" 现居:"+data.resident_city, 
					"粉丝（"+data.fans+")", "关注（"+data.fav+")", data.userpic);
			mAdapter.setUserKgeList(data.kgeList);
			lvOtherHome.setAdapter(mAdapter);
		}
		
		@Override
		public void onFailure(String errorStr) {
			super.onFailure(errorStr);
		}
		
		@Override
		public void onStart() {
			super.onStart();
			flOtherHome.setVisibility(View.INVISIBLE);
			rlOtherHomeProgress.setVisibility(View.VISIBLE);
		}
		
		@Override
		public void onFinish() {
			super.onFinish();
			rlOtherHomeProgress.setVisibility(View.INVISIBLE);
			flOtherHome.setVisibility(View.VISIBLE);
		}
		
	}
	
	private void sendRequestByGet(UserHomeDataResponseHandler handler) {
		if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
			Toast.makeText(OtherHomeActivity.this, "没有网络,请稍后再试", 0).show();
			lvOtherHome.onRefreshComplete();
			return;
		}
		//发送请求
		if(Config.getPersistence().user != null) {
			String loginId = Config.getPersistence().user.uid;
			String sid = Config.getPersistence().user.sid;
			UserHomeBusiness.getUserHomeDataByGet(mId, loginId, sid, handler);
		}
	}
	
	private void sendRequestByPost(UserHomeDataResponseHandler handler) {
		if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
			Toast.makeText(OtherHomeActivity.this, "没有网络,请稍后再试", 0).show();
			lvOtherHome.onRefreshComplete();
			return;
		}
		//发送请求
		if(Config.getPersistence().user != null) {
			String loginId = Config.getPersistence().user.uid;
			String sid = Config.getPersistence().user.sid;
			UserHomeBusiness.getUserHomeSongListByPost(mId, loginId, sid, ++mCurrentPageNumber, 5, handler);
		}
	}
	
	private class AttentationDataHanlder extends UserHomeDataResponseHandler {

		@Override
		public void onSuccess(UserHomeData data) {
			if("ok".equals(data.result)) 
				sendRequestByGet(new OtherHomeDataHanlder4Refresh());
			else 
				Toast.makeText(OtherHomeActivity.this, "操作失败", 0).show();
		}
		
		@Override
		public void onFailure(String errorStr) {
			super.onFailure(errorStr);
			if("org.apache.http.conn.ConnectTimeoutException".equals(errorStr))
				Toast.makeText(OtherHomeActivity.this, "操作失败(连接超时)", 0).show();
			else 
				Toast.makeText(OtherHomeActivity.this, "操作失败", 0).show();
		}
		
	}
	
	public void onEvent(Message msg) {
		switch (msg.what) {
		case Constants.MSG_OTHERE_HOME_ATTENTATION_BUTTON:
			clickAttentationButton();
			break;
		default:
			break;
		}
	}
	
	private void clickAttentationButton() {
		//关注
		if(Config.getPersistence().user != null) {
			String fid = Config.getPersistence().user.uid;
			String tid = mId;
			String sid = Config.getPersistence().user.sid;
			if(mHasCare == 1)
				UserHomeBusiness.attentationUser(fid, tid, sid, "del", new AttentationDataHanlder());
			else
				UserHomeBusiness.attentationUser(fid, tid, sid, "add", new AttentationDataHanlder());
		}
	}
	
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			switch (v.getId()) {
			case R.id.btOtherHomeBack:
				finish();
				break;

			default:
				break;
			}
		}
	};
}
