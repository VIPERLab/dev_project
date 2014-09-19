/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.util.List;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.LiveRoom;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.logic.LiveLogic;
import cn.kuwo.sing.logic.service.LiveHttpService;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.LiveRoomActivity;
import cn.kuwo.sing.util.ImageUtils;
import cn.kuwo.sing.util.ImageAsyncTask.ImageAsyncTaskCallback;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2012-11-1, 下午12:22:25, 2012
 *
 * @Author wangming
 *
 */
public class LiveController extends BaseController {
	private final String TAG = "LiveController";
	private BaseActivity mActivity;
	private ListView lv_live_room;
	private List<LiveRoom> mResult;
	private LiveLogic logic;
	private int imageWidth;
	private int imageHeight;
	
	public LiveController(BaseActivity activity) {
		KuwoLog.i(TAG, "LiveController");
		mActivity = activity;
		imageWidth = mActivity.getWindowManager().getDefaultDisplay().getWidth()/4;
		imageHeight = mActivity.getWindowManager().getDefaultDisplay().getWidth()/4;
		initView();
		loadLiveRoom();
	}

	private void initView() {
		lv_live_room = (ListView) mActivity.findViewById(R.id.lv_live_room);
	}

	private void loadLiveRoom() {
		new LiveRoomLoader().execute();
	}
	
	class LiveRoomLoader extends AsyncTask<Void, Void, List<LiveRoom>> {

		@Override
		protected List<LiveRoom> doInBackground(Void... params) {
			logic = new LiveLogic();
			if(Config.getPersistence().user == null) {
				logic.login("", "");
			}else {
				logic.login(Config.getPersistence().user.uname, Config.getPersistence().user.psw);
			}
			return logic.getHall();
		}

		@Override
		protected void onPostExecute(List<LiveRoom> result) {
			if(result != null) {
				mResult = result;
				LiveRoomAdapter adapter = new LiveRoomAdapter(result);
				lv_live_room.setAdapter(adapter);
				lv_live_room.setOnItemClickListener(new OnItemClickListener() {

					@Override
					public void onItemClick(AdapterView<?> parent, View view,
							int position, long id) {
						Intent intent = new Intent(mActivity, LiveRoomActivity.class);
						intent.putExtra("roomId", mResult.get(position).getId());
						mActivity.startActivity(intent);
					}
				});
			}
			super.onPostExecute(result);
		}
	}
	
	class LiveRoomAdapter extends BaseAdapter {
		private List<LiveRoom> mRoomList;
		
		public LiveRoomAdapter(List<LiveRoom> roomList) {
			mRoomList = roomList;
		}
		
		@Override
		public int getCount() {
			return mRoomList.size();
		}

		@Override
		public Object getItem(int position) {
			return mRoomList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View view = null;
			ViewHolder viewHolder = null;
			if(convertView == null) {
				view = View.inflate(mActivity, R.layout.live_item, null);
				viewHolder = new ViewHolder();
				viewHolder.roomIV = (ImageView) view.findViewById(R.id.iv_live_room);
				viewHolder.roomNameTV = (TextView) view.findViewById(R.id.tv_live_room_name);
				viewHolder.roomDescTV = (TextView) view.findViewById(R.id.tv_live_room_desc);
				viewHolder.roomUserCountTV = (TextView) view.findViewById(R.id.tv_live_room_userCount);
				view.setTag(viewHolder);
			}else {
				view = convertView;
				viewHolder = (ViewHolder) view.getTag();
			}
			LiveRoom room = mRoomList.get(position);
			viewHolder.roomNameTV.setText(room.getName());
			viewHolder.roomDescTV.setText("[mm]纯美眉公社，最美的面孔");
			viewHolder.roomUserCountTV.setText(room.getOnlinecnt());
			String imageUrl = room.getPic();
			if(imageUrl == null) {
				viewHolder.roomIV.setImageResource(R.drawable.image_loading_small);
			}else {
				String imagePath = ImageUtils.makeImagePathFromUrl(imageUrl);
				Bitmap bitmap = ImageUtils.loadImageFromCache(new ImageCallback(), imagePath, imageUrl, imageWidth, imageHeight);
				if(bitmap == null) {
					viewHolder.roomIV.setImageResource(R.drawable.image_loading_small);
				}else {
					viewHolder.roomIV.setImageBitmap(bitmap);
				}
			}
			return view;
		}
		
		class ImageCallback implements ImageAsyncTaskCallback {

			@Override
			public void onPreImageLoad() {
				
			}

			@Override
			public void onPostImageLoad(Bitmap bitmap, String imagePath) {
				ImageView iv = (ImageView) lv_live_room.findViewWithTag(imagePath);
				if(iv != null) {
					iv.setImageBitmap(bitmap);
				}
			}
		}
	}
	
	static class ViewHolder {
		ImageView roomIV;
		TextView  roomNameTV;
		TextView roomDescTV;
		TextView roomUserCountTV;
	}
}
