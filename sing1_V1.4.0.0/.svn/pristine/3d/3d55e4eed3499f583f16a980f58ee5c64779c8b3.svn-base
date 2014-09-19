/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.io.IOException;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.logic.MusicListLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.SongSubListActivity;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageLoadingListener;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.assist.PauseOnScrollListener;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.SimpleBitmapDisplayer;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2012-11-29, 下午12:25:41, 2012
 *
 * @Author wangming
 *
 */
public class HotSingerController extends BaseController {
	private final String TAG = "HotSingerController";
	private BaseActivity mActivity;
	private Button bt_hot_songs_list_back;
	private ListView lv_hot_songs_list;
	private String mSingerTypeID;
	private RelativeLayout rl_hot_song_progress;
	private int imageWidth;
	private int imageHeight;
	private DisplayImageOptions options;
	private ImageLoader mImageLoader;
	private RelativeLayout rl_hot_song_layout_no_network;
	private ImageView iv_hot_song_layout_no_network;
	
	public HotSingerController(BaseActivity activity, ImageLoader imageLoader) {
		KuwoLog.i(TAG, "HotSingerController");
		mActivity = activity;
		mImageLoader = imageLoader;
		imageWidth = mActivity.getWindowManager().getDefaultDisplay().getWidth()/4;
		imageHeight = mActivity.getWindowManager().getDefaultDisplay().getWidth()/4;
		options = new DisplayImageOptions.Builder()
		.showStubImage(R.drawable.image_loading_small)
		.showImageForEmptyUri(R.drawable.image_loading_small)
		.showImageOnFail(R.drawable.image_loading_small)
		.cacheInMemory()
		.cacheOnDisc()
        .imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2) // default
        .bitmapConfig(Bitmap.Config.ARGB_8888) // default
		.displayer(new SimpleBitmapDisplayer())
		.build();
		initView();
		loadHotSinger();
	}
	
	public void clearDisplayedImages() {
		AnimateFirstDisplayListener.displayedImages.clear();
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

	private void initView() {
		bt_hot_songs_list_back = (Button) mActivity.findViewById(R.id.bt_hot_songs_list_back);
		bt_hot_songs_list_back.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				mActivity.finish();
			}
		});
		lv_hot_songs_list = (ListView) mActivity.findViewById(R.id.lv_hot_songs_list);
		lv_hot_songs_list.setOnScrollListener(new PauseOnScrollListener(mImageLoader, false, true));
		rl_hot_song_progress = (RelativeLayout) mActivity.findViewById(R.id.rl_hot_song_progress);
		rl_hot_song_progress.setVisibility(View.INVISIBLE);
		rl_hot_song_layout_no_network = (RelativeLayout) mActivity.findViewById(R.id.rl_hot_song_layout_no_network);
		rl_hot_song_layout_no_network.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				loadHotSinger();
			}
		});
		iv_hot_song_layout_no_network = (ImageView) mActivity.findViewById(R.id.iv_hot_song_layout_no_network);
		rl_hot_song_layout_no_network.setVisibility(View.INVISIBLE);
		
		Intent intent = mActivity.getIntent();
		mSingerTypeID = intent.getStringExtra("singerTypeID");
	}
	
	private void loadHotSinger() {
		final List<Music> result = getHotSingerSubListFromCache();
		if(result != null) {
			HotSingerAdapter adapter = new HotSingerAdapter(result);
			rl_hot_song_layout_no_network.setVisibility(View.INVISIBLE);
			lv_hot_songs_list.setVisibility(View.VISIBLE);
			lv_hot_songs_list.setAdapter(adapter);
			lv_hot_songs_list.setOnItemClickListener(new OnItemClickListener() {

				@Override
				public void onItemClick(AdapterView<?> parent, View view,
						int position, long id) {
					Intent subIntent = new Intent(mActivity, SongSubListActivity.class);
					subIntent.putExtra("flag", "singerSongList");
					subIntent.putExtra("listID", result.get(position).getId());
					subIntent.putExtra("subTitle", result.get(position).getName()+"("+result.get(position).getNum()+"首)");
					mActivity.startActivity(subIntent);
				}
			});
		}else {
			if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
				if(lv_hot_songs_list != null && rl_hot_song_layout_no_network != null) {
					lv_hot_songs_list.setVisibility(View.INVISIBLE);
					rl_hot_song_layout_no_network.setVisibility(View.VISIBLE);
					iv_hot_song_layout_no_network.setImageResource(R.drawable.fail_network);
				}
			}
		}
	}
	
	private List<Music> getHotSingerSubListFromCache() {
		List<Music> hotSingerSubList = null;
		MusicListLogic logic = new MusicListLogic();
		boolean result = logic.checkCacheHotSingerSubList(mSingerTypeID);
		if(result) {
			//缓存可用
			try {
				hotSingerSubList = logic.getCacheHotSingerSubList(mSingerTypeID);
				KuwoLog.i(TAG, "hot singer sub list"+hotSingerSubList);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}else {
			//缓存不可用
			if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
				getHotSingerSubListFromServer();
			}else {
				try {
					return logic.getCacheHotSingerSubList(mSingerTypeID);
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return hotSingerSubList;
	}
	
	private void getHotSingerSubListFromServer() {
		if(AppContext.getNetworkSensor()!= null && AppContext.getNetworkSensor().hasAvailableNetwork()) { 
			rl_hot_song_layout_no_network.setVisibility(View.INVISIBLE);
			rl_hot_song_progress.setVisibility(View.VISIBLE);
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					List<Music> result = null;
					MusicListLogic logic = new MusicListLogic();
					try {
						result =  logic.getHotSingerSubList(mSingerTypeID);
					} catch (IOException e) {
						e.printStackTrace();
					}
					Message msg = hotSingerHandler.obtainMessage();
					msg.what = 0;
					msg.obj = result;
					hotSingerHandler.sendMessage(msg);
				}
			}).start();
		}else {
			if(lv_hot_songs_list != null && rl_hot_song_layout_no_network != null) {
				lv_hot_songs_list.setVisibility(View.INVISIBLE);
				rl_hot_song_layout_no_network.setVisibility(View.VISIBLE);
				iv_hot_song_layout_no_network.setImageResource(R.drawable.fail_network);
			}
		}
	}
	
	private Handler hotSingerHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				rl_hot_song_progress.setVisibility(View.INVISIBLE);
				lv_hot_songs_list.setVisibility(View.VISIBLE);
				final List<Music> result = (List<Music>) msg.obj;
				if(result != null) {
					HotSingerAdapter adapter = new HotSingerAdapter(result);
					lv_hot_songs_list.setAdapter(adapter);
					lv_hot_songs_list.setOnItemClickListener(new OnItemClickListener() {

						@Override
						public void onItemClick(AdapterView<?> parent, View view,
								int position, long id) {
							Intent subIntent = new Intent(mActivity, SongSubListActivity.class);
							subIntent.putExtra("flag", "singerSongList");
							subIntent.putExtra("listID", result.get(position).getId());
							subIntent.putExtra("subTitle", result.get(position).getName()+"("+result.get(position).getNum()+"首)");
							mActivity.startActivity(subIntent);
						}
					});
				}
				break;

			default:
				break;
			}
		}
		
	};
	
	class HotSingerAdapter extends BaseAdapter {
		private List<Music> mHotSingerList;
		private ImageLoadingListener animateFirstListener = new AnimateFirstDisplayListener();
		
		public HotSingerAdapter(List<Music> result) {
			mHotSingerList = result;
		}
		@Override
		public int getCount() {
			return mHotSingerList.size();
		}

		@Override
		public Object getItem(int position) {
			return mHotSingerList.get(position);
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
				view = View.inflate(mActivity, R.layout.hot_singer_list_item, null);
				viewHolder = new ViewHolder();
				viewHolder.hotSingerIV = (ImageView) view.findViewById(R.id.iv_hot_singer_list_item);
				viewHolder.hotSingerNameTV = (TextView) view.findViewById(R.id.tv_hot_singer_name);
				viewHolder.hotSingerSongsCountTV = (TextView) view.findViewById(R.id.tv_hot_singer_songs_count);
				view.setTag(viewHolder);
			}else {
				view = convertView;
				viewHolder = (ViewHolder) view.getTag();
			}
			Music music = mHotSingerList.get(position);
			viewHolder.hotSingerNameTV.setText(music.getName());
			viewHolder.hotSingerSongsCountTV.setText(music.getNum()+"首");
			String imageUrl = music.getImg();
			mImageLoader.displayImage(imageUrl, viewHolder.hotSingerIV, options, animateFirstListener);
			return view;
		}
	}
	
	static class ViewHolder {
		ImageView hotSingerIV;
		TextView hotSingerNameTV;
		TextView hotSingerSongsCountTV;
	}
}
