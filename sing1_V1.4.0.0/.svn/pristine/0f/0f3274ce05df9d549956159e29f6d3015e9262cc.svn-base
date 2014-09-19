/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.config.PreferencesManager;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.BitmapUtils;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.UserHomeData;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.business.UserHomeBusiness;
import cn.kuwo.sing.context.App;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.PostProcessedController;
import cn.kuwo.sing.logic.service.UserService;
import cn.kuwo.sing.ui.adapter.UserKgeListAdapter;
import cn.kuwo.sing.util.BitmapTools;
import cn.kuwo.sing.util.UserHomeDataResponseHandler;

import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshBase.Mode;
import com.handmark.pulltorefresh.library.PullToRefreshBase.OnRefreshListener;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2013-12-18, 下午3:07:10
 *
 * @Author wangming 
 * 
 * @Description 我的【本地化页面】
 *
 */
public class MyHomeActivity extends BaseActivity {
	private static final String LOG_TAG = "MyHomeActivity";
	private MyHomeUserChangeReciver mMyHomeUserChangeReciver;
	private RelativeLayout rlMyHomeLoginOrRegister;
	private LinearLayout main_bottom_linlayout;
	private ImageView ivMyHomeInclickBg;
	private RelativeLayout rlMyHomeImgDialog;
	private PullToRefreshListView lvMyHome;
	private RelativeLayout rlMyHomeLoading;
	private ImageView ivMyHomeLoginOrRegister;
	private ProgressDialog uploadPd;
	private List<Kge> mKgeList = new ArrayList<Kge>();
	private int mCurrentPageNumber = 1; //从1开始
	/* 动画效果 */
	private final int DIALOG_BOTTOM_IN = 6, DIALOG_BOTTOM_OUT = 7;
	// 添加图片对话框是否已经显示
	public boolean imgSetDialogShowed = false;
	private UserKgeListAdapter mAdapter;
	private String mUserPicUrl;
	private RelativeLayout rlMyHomeLoginView;
	private RelativeLayout rlMyHomeNoNetwork;
	private ImageView ivMyHomeNoNetwork;
	private int mTotalPage = -1;
	private LinearLayout llUserHomeDeletePrompt;
	private Button btMyHomeDeletePrompt;
	private FrameLayout flMyHome;
	
	private class MyHomeUserChangeReciver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			if(action != null && action.equals("cn.kuwo.sing.user.change")) {
				if(Config.getPersistence().isLogin)
					loadLoginView();
				else
					loadNotLoginView();
			}
		}
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case Constants.LOGIN_REQUEST: //登录请求
			if(resultCode == Constants.LOGIN_SUCCESS_RESULT) //登录成功结果
				loadLoginView();
			break;
		case Constants.LOCAL_EDITINFO_REQUEST:
			if(resultCode == Constants.RESULT_RELOAD_MY_HOME_BASEINFO)
				reloadView();
			break;
		case PostProcessedController.CAPTURE_REQUESTCODE:	// 拍照回调
			if(data != null) {
				if (data.getExtras() != null) {
					Bitmap bitmap = (Bitmap) data.getExtras().get("data");
					addCapturePicture(bitmap);
				} else {
					Uri uri = data.getData();
					if(uri != null) {
						addMediaPicture(uri);
					}
				}
			}
			dimissImgSetDialog();
		case PostProcessedController.MEDIA_REQUESTCODE:		// 本地选取回调
			if(data != null) {
				Uri uri = data.getData();
				addMediaPicture(uri);
			}
			dimissImgSetDialog();
			break;
		default:
			break;
		}
		super.onActivityResult(requestCode, resultCode, data);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.my_home_layout);
		initData();
		initView();
		ObtainData();
	}
	
	@Override
	protected void onResume() {
		if(Config.getPersistence().isLogin) {
			if(Config.getPersistence().user.noticeNumber != 0) 
				setNoticeViewVisible();
			else 
				setNoticeViewInvisible();
		}
		super.onResume();
	}
	
	@Override
	protected void onDestroy() {
		unregisterReceiver(mMyHomeUserChangeReciver);
		super.onDestroy();
	}

	private void initData() {
		//注册用户改变的过滤器
		mMyHomeUserChangeReciver = new MyHomeUserChangeReciver();
		IntentFilter userChangeFilter = new IntentFilter();
		userChangeFilter.addAction("cn.kuwo.sing.user.change");
		registerReceiver(mMyHomeUserChangeReciver, userChangeFilter);
	}

	private void initView() {
		flMyHome = (FrameLayout) findViewById(R.id.flUserHome);
		flMyHome.setVisibility(View.INVISIBLE);
		btMyHomeDeletePrompt = (Button)findViewById(R.id.btMyHomeDeletePrompt);
		btMyHomeDeletePrompt.setOnClickListener(mOnClickListener);
		llUserHomeDeletePrompt = (LinearLayout)findViewById(R.id.llUserHomeDeletePrompt);
		llUserHomeDeletePrompt.setVisibility(View.INVISIBLE);
		ivMyHomeNoNetwork = (ImageView)findViewById(R.id.ivMyHomeNoNetwork);
		ivMyHomeNoNetwork.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				ObtainData();
			}
		});
		rlMyHomeNoNetwork = (RelativeLayout)findViewById(R.id.rlMyHomeNoNetwork);
		rlMyHomeNoNetwork.setVisibility(View.INVISIBLE);
		//登录或注册
		rlMyHomeLoginOrRegister = (RelativeLayout)findViewById(R.id.rlMyHomeLoginOrRegister);
		rlMyHomeLoginOrRegister.setOnClickListener(mOnClickListener);
		ivMyHomeLoginOrRegister = (ImageView)findViewById(R.id.ivMyHomeLoginOrRegister);
		ivMyHomeLoginOrRegister.setOnClickListener(mOnClickListener);
		
		lvMyHome = (PullToRefreshListView)findViewById(R.id.lvUserHome);
		lvMyHome.setMode(Mode.BOTH);
		lvMyHome.setOnRefreshListener(new OnRefreshListener<ListView>() {

			@Override
			public void onRefresh(PullToRefreshBase<ListView> refreshView) {
				Mode currentMode = lvMyHome.getCurrentMode();
				switch (currentMode) {
				case PULL_FROM_START:
					sendRequestByGet(new MyHomeDataHandler4Refresh());
					break;
				case PULL_FROM_END:
					if(mCurrentPageNumber < mTotalPage) {
						sendRequestByPost(new MyHomeDataHandler4LoadMore());
					}else { 
						lvMyHome.onRefreshComplete();
						Toast.makeText(MyHomeActivity.this, "已经翻到最后一页了", 0).show();
					}
					break;
				default:
					break;
				}
			}
		});
		lvMyHome.getRefreshableView().setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				if(position >= 2 && mKgeList != null) {
					Kge kge = mKgeList.get(position-2);
					MTVBusiness mb = new MTVBusiness(MyHomeActivity.this);
					mb.playMtv(kge.id);
				}
			}
		});
		lvMyHome.getRefreshableView().setOnItemLongClickListener(new OnItemLongClickListener() {

			@Override
			public boolean onItemLongClick(AdapterView<?> parent, View view,
					int position, long id) {
				if(position >= 2) {
					Kge kge = mKgeList.get(position-2);
					showDeleteDialog(kge, position-2);
				}
				return true;
			}
		});
		mAdapter = new UserKgeListAdapter(this);
		
		main_bottom_linlayout = (LinearLayout)findViewById(R.id.main_bottom_linlayout);
		
		ivMyHomeInclickBg = (ImageView)findViewById(R.id.ivMyHomeInclickBg);
		rlMyHomeImgDialog = (RelativeLayout)findViewById(R.id.rlMyHomeImgDialog);
		rlMyHomeLoading = (RelativeLayout)findViewById(R.id.rlMyHomeLoading);
		rlMyHomeLoading.setVisibility(View.INVISIBLE);
		
		rlMyHomeLoginView = (RelativeLayout)findViewById(R.id.rlMyHomeLoginView);
		
		// "拍照"按钮
		Button post_processed_capture_btn = (Button)findViewById(R.id.local_head_capture_btn);
		post_processed_capture_btn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
				startActivityForResult(intent, PostProcessedController.CAPTURE_REQUESTCODE);
			}
		});
		// "本地上传"按钮
		Button post_processed_local_btn = (Button)findViewById(R.id.local_head_local_btn);
		post_processed_local_btn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Intent intent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
				startActivityForResult(intent, PostProcessedController.MEDIA_REQUESTCODE);
			}
		});
		// "取消"按钮
		Button post_processed_cancle_btn = (Button)findViewById(R.id.local_head_cancle_btn);
		post_processed_cancle_btn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				dimissImgSetDialog();
			}
		});
	}
	
	private void showDeleteDialog(final Kge kge, final int position) {
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				String kid = kge.id;
				if(Config.getPersistence().user != null) {
					String uid = Config.getPersistence().user.uid;
					String loginId = Config.getPersistence().user.uid;
					String sid = Config.getPersistence().user.sid;
					UserHomeBusiness.deleteUserKge(kid, uid, loginId, sid, new DeleteDataHanlder(position));
				}
			}
		});
		builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		builder.setMessage("您确定要删除么？");
		AlertDialog dialog = builder.create();
		dialog.show();
	}
	
	private class DeleteDataHanlder extends UserHomeDataResponseHandler {
		private int mDeletePosition;
		
		public DeleteDataHanlder(int position) {
			mDeletePosition = position;
		}

		@Override
		public void onSuccess(UserHomeData data) {
			if("ok".equals(data.result)) {
				Toast.makeText(MyHomeActivity.this, "删除成功", 0).show();
				mKgeList.remove(mDeletePosition);
				mAdapter.removeKge(mDeletePosition);
				lvMyHome.setAdapter(mAdapter);
			}else {
				Toast.makeText(MyHomeActivity.this, "删除失败", 0).show();
			}
		}
		
		@Override
		public void onFailure(String errorStr) {
			super.onFailure(errorStr);
			if("org.apache.http.conn.ConnectTimeoutException".equals(errorStr))
				Toast.makeText(MyHomeActivity.this, "删除失败(连接超时)", 0).show();
			else 
				Toast.makeText(MyHomeActivity.this, "删除失败", 0).show();
		}
		
	}

	private void ObtainData() {
		if(!Config.getPersistence().isLogin) 
			loadNotLoginView();
		else 
			loadLoginView();
	}
	
	private void sendRequestByGet(UserHomeDataResponseHandler handler) {
		if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
			Toast.makeText(MyHomeActivity.this, "没有网络,请稍后再试", 0).show();
			lvMyHome.onRefreshComplete();
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
	
	private void sendRequestByPost(UserHomeDataResponseHandler handler) {
		if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
			Toast.makeText(MyHomeActivity.this, "没有网络,请稍后再试", 0).show();
			lvMyHome.onRefreshComplete();
			return;
		}
		//发送请求
		if(Config.getPersistence().user != null) {
			String id = Config.getPersistence().user.uid;
			String loginId = Config.getPersistence().user.uid;
			String sid = Config.getPersistence().user.sid;
			UserHomeBusiness.getUserHomeSongListByPost(id, loginId, sid, ++mCurrentPageNumber, 5, handler);
		}
	}
	
	private void loadLoginView() {
		rlMyHomeLoginOrRegister.setVisibility(View.INVISIBLE);
		if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
			rlMyHomeLoginView.setVisibility(View.INVISIBLE);
			rlMyHomeNoNetwork.setVisibility(View.VISIBLE);
			return;
		}
		rlMyHomeLoginView.setVisibility(View.VISIBLE);
		if(PreferencesManager.getBoolean("firstLoadMyHomePage", true)) {
			llUserHomeDeletePrompt.setVisibility(View.VISIBLE);
		}else {
			llUserHomeDeletePrompt.setVisibility(View.INVISIBLE);
		}
		sendRequestByGet(new MyHomeDataHanlder());
	}
	
	private static class AnimateFirstDisplayListener extends SimpleImageLoadingListener {

		static final List<String> displayedImages = Collections.synchronizedList(new LinkedList<String>());

		@Override
		public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
			if (loadedImage != null) {
				ImageView imageView = (ImageView) view;
				boolean firstDisplay = !displayedImages.contains(imageUri);
				if (firstDisplay) {
					FadeInBitmapDisplayer.animate(imageView, 500);
					displayedImages.add(imageUri);
				} else {
					imageView.setImageBitmap(loadedImage);
				}
			}
		}
	}
	
	private class MyHomeDataHandler4LoadMore extends UserHomeDataResponseHandler {
		@Override
		public void onSuccess(UserHomeData data) {
			KuwoLog.d(LOG_TAG, "data.uname="+data.uname);
			lvMyHome.onRefreshComplete();
			mKgeList.addAll(data.kgeList);
			mAdapter.setUserKgeList(data.kgeList);
			lvMyHome.setAdapter(mAdapter);
		}
		
		@Override
		public void onFailure(String errorStr) {
			super.onFailure(errorStr);
			lvMyHome.onRefreshComplete();
		}
	}
	
	private class MyHomeDataHandler4Refresh extends UserHomeDataResponseHandler {
		@Override
		public void onSuccess(UserHomeData data) {
			KuwoLog.d(LOG_TAG, "data.uname="+data.uname);
			lvMyHome.onRefreshComplete();
			mKgeList.clear();
			mAdapter.clearList();
			mKgeList.addAll(data.kgeList);
			mAdapter.setMsgInfo();
			mAdapter.setUserBaseInfo(data.uname, data.uid, data.age+"岁 来自:"+data.birth_city+" 现居:"+data.resident_city, 
					"粉丝（"+data.fans+")", "关注（"+data.fav+")", data.userpic);
			mAdapter.setUserKgeList(data.kgeList);
			lvMyHome.setAdapter(mAdapter);
		}
		
		@Override
		public void onFailure(String errorStr) {
			super.onFailure(errorStr);
			lvMyHome.onRefreshComplete();
		}
	}
	
	private class MyHomeDataHanlder extends UserHomeDataResponseHandler {

		@Override
		public void onSuccess(UserHomeData data) {
			KuwoLog.d(LOG_TAG, "data.uname="+data.uname);
			mTotalPage = data.total_pn;
			mKgeList.addAll(data.kgeList);
			mAdapter.setUserType(true, data.hascare, null);
			mAdapter.setUserBaseInfo(data.uname, data.uid, data.age+"岁 来自:"+data.birth_city+" 现居:"+data.resident_city, 
					"粉丝（"+data.fans+")", "关注（"+data.fav+")", data.userpic);
			mAdapter.setUserKgeList(data.kgeList);
			lvMyHome.setAdapter(mAdapter);
		}
		
		@Override
		public void onFailure(String errorStr) {
			super.onFailure(errorStr);
		}
		
		@Override
		public void onStart() {
			super.onStart();
			flMyHome.setVisibility(View.INVISIBLE);
			rlMyHomeLoading.setVisibility(View.VISIBLE);
		}
		
		@Override
		public void onFinish() {
			super.onFinish();
			rlMyHomeLoading.setVisibility(View.INVISIBLE);
			flMyHome.setVisibility(View.VISIBLE);
		}
		
	}
	
	private void loadNotLoginView() {
		flMyHome.setVisibility(View.INVISIBLE);
		rlMyHomeLoginView.setVisibility(View.INVISIBLE);
		rlMyHomeLoginOrRegister.setVisibility(View.VISIBLE);
		
	}
	
	private void reloadView() {
		sendRequestByGet(new MyHomeDataHandler4Refresh());
	}
	
	private void setTabWidgetState(int visibility) {
		App app = (App)getApplication();
		MainActivity mainActivity = (MainActivity) app.getActivity(MainActivity.class);
		mainActivity.setTabWidgetState(visibility);
	}
	
	/**
	 * 点击添加图片弹出选中对话框
	 */
	public void showImgSetDialog() {
		ivMyHomeInclickBg.setVisibility(View.VISIBLE);
		setTabWidgetState(View.GONE);
		rlMyHomeImgDialog.setVisibility(View.VISIBLE);
		setAnimation(rlMyHomeImgDialog, DIALOG_BOTTOM_IN);
		imgSetDialogShowed = true;
	}
	
	/**
	 * 添加图片后对话框消失
	 */
	public void dimissImgSetDialog() {
		Handler handler = new Handler();
		handler.postDelayed(new Runnable() {
			
			@Override
			public void run() {
				setTabWidgetState(View.VISIBLE);
			}
		}, 500);
		rlMyHomeImgDialog.setVisibility(View.GONE);
		ivMyHomeInclickBg.setVisibility(View.GONE);
		setAnimation(rlMyHomeImgDialog, DIALOG_BOTTOM_OUT);
		imgSetDialogShowed = false;
	}
	
	/**
	 * 设置动画
	 * 
	 * @param view
	 *            待设置的View
	 * @param type
	 *            动画类型
	 */
	private void setAnimation(View view, int type) {

		Animation inAnim = null;
		switch (type) {
		case DIALOG_BOTTOM_IN:
			inAnim = AnimationUtils.loadAnimation(this, R.anim.sing_img_dialog_bottom_in);
			break;
		case DIALOG_BOTTOM_OUT:
			inAnim = AnimationUtils.loadAnimation(this, R.anim.sing_img_dialog_bottom_out);
			break;
		}
		if (inAnim != null) {
			view.startAnimation(inAnim);
		}
	}
	
	/**
	 * 本地选取回调
	 */
	public void addMediaPicture(Uri selectedImage) {
		if(selectedImage == null)
			return;
		String picturePath = null;
		if (selectedImage.getScheme().equalsIgnoreCase("file")) {
			picturePath = selectedImage.getPath();
		} else {
			String[] filePathColumn = { MediaStore.Images.Media.DATA };
			Cursor cursor = this.getContentResolver().query(selectedImage, filePathColumn, null, null, null);
			if (cursor == null)
				return;
			
			cursor.moveToFirst();
			int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
			picturePath = cursor.getString(columnIndex);
			cursor.close();
		}
		
		// 原图片
		int outWidth = AppContext.SCREEN_WIDTH/4;
		int outHeight = AppContext.SCREEN_WIDTH/4;
		Bitmap bitmap = BitmapTools.readBitmapAutoSize(picturePath, outWidth, outHeight);
		addCapturePicture(bitmap);
	}
	
	private Handler uploadMyHeadHandler = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				String result = (String) msg.obj;
				KuwoLog.i(LOG_TAG, "uploadMyHead result="+result);
				if(result == null) {
					KuwoLog.i(LOG_TAG, "头像上传失败");
					Toast.makeText(MyHomeActivity.this, "头像上传失败", 0).show();
					uploadPd.dismiss();
					break;
				}
				try {
					JSONObject jsonObj = new JSONObject(result);
					String stat = jsonObj.getString("stat");
					KuwoLog.i(LOG_TAG, "stat="+stat);
					if(stat.equals("200")) {
						KuwoLog.i(LOG_TAG, "头像上传成功");
						uploadPd.dismiss();
						reloadView();
					}else {
						KuwoLog.i(LOG_TAG, "头像上传失败");
						uploadPd.dismiss();
					}
				} catch (JSONException e) {
					KuwoLog.printStackTrace(e);
				}
				break;

			default:
				break;
			}
		};
	};
	
	/**
	 * 拍照后回调
	 */
	public void addCapturePicture(Bitmap bitmap) {
		// 640*640缩放
		final Bitmap bmp = BitmapUtils.zoomBitmap(this, 0, bitmap, AppContext.SCREEN_WIDTH/4, AppContext.SCREEN_WIDTH/4);
		//发送图片到server
		uploadPd = new ProgressDialog(this);
		uploadPd.setCancelable(true);
		uploadPd.setCanceledOnTouchOutside(false);
		uploadPd.setMessage("正在上传中，请稍后");
		uploadPd.show();
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				UserService userService = new UserService();
				String result = userService.uploadMyHead(Config.getPersistence().user.uid, Config.getPersistence().user.sid, bitmap2IS(bmp));
				Message msg = uploadMyHeadHandler.obtainMessage();
				msg.what = 0;
				msg.obj = result;
				uploadMyHeadHandler.sendMessage(msg);
				
			}
		}).start();
		dimissImgSetDialog();
	}
	
	private InputStream bitmap2IS(Bitmap bm){  
    	if(bm == null) {
    		return null;
    	}
    	ByteArrayOutputStream baos = new ByteArrayOutputStream();  
        bm.compress(Bitmap.CompressFormat.PNG, 100, baos);  
        InputStream sbs = new ByteArrayInputStream(baos.toByteArray());    
        return sbs;  
    }  
	
	private void setNoticeViewVisible() {
		
	}
	
	private void setNoticeViewInvisible() {
		
	}
	
	public void onEvent(Message msg) {
		switch (msg.what) {
		case Constants.MSG_MY_HOME_PORTRAIT_CLICK:
			clickPortraitImageView();
			break;
		default:
			break;
		}
	}
	
	private void clickPortraitImageView() {
		if(imgSetDialogShowed) {
			//dismiss
			runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					dimissImgSetDialog();
				}
			});
		}else {
			//show
			runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					showImgSetDialog();
				}
			});
		}
	}
	
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			switch (v.getId()) {
			case R.id.ivMyHomeLoginOrRegister:
				Intent loginIntent = new Intent(MyHomeActivity.this, LoginActivity.class);
				startActivityForResult(loginIntent, Constants.LOGIN_REQUEST);
				break;
			case R.id.btMyHomeDeletePrompt:
				PreferencesManager.put("firstLoadMyHomePage", false).commit();
				llUserHomeDeletePrompt.setVisibility(View.INVISIBLE);
				break;
			default:
				break;
			}
		}
	};
}
