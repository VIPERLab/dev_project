/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.io.IOException;
import java.net.SocketException;
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
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.logic.MusicListLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.OrderListActivity;
import cn.kuwo.sing.ui.activities.RecordListActivity;
import cn.kuwo.sing.ui.activities.SearchActivity;
import cn.kuwo.sing.ui.activities.SingActivity;
import cn.kuwo.sing.ui.activities.SingerListActivity;
import cn.kuwo.sing.ui.activities.SongSubListActivity;
import cn.kuwo.sing.widget.HotBarGridView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageLoadingListener;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.assist.PauseOnScrollListener;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.SimpleBitmapDisplayer;
import com.umeng.analytics.MobclickAgent;

/**
 * @Package cn.kuwo.sing.controller 点歌台
 * 
 * @Date 2012-11-1, 下午12:23:22, 2012
 * 
 * @Author wangming
 * 
 */
public class SongController extends BaseController {
	private final String TAG = "SongController";
	private BaseActivity mActivity;
	private TextView et_song_search;
	private Button bt_free_sing;
	private Button bt_singer_list;
	private Button bt_order_list;
	private Button bt_record_list;
	private RelativeLayout rl_song;
	private HotBarGridView gv_song;
	private RelativeLayout rl_song_progress;
	private RelativeLayout rl_song_no_network;
	private DisplayImageOptions options;
	private ImageLoader mImageLoader;
	private ImageView iv_song_no_network;

	public SongController(BaseActivity activity, ImageLoader imageLoader) {
		KuwoLog.i(TAG, "SongController");
		mActivity = activity;
		mImageLoader = imageLoader;
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
	}

	private void initView() {

		rl_song_progress = (RelativeLayout) mActivity.findViewById(R.id.rl_song_progress);

		// =========================点歌台==========================================================
		rl_song = (RelativeLayout) mActivity.findViewById(R.id.rl_song);
		et_song_search = (TextView) mActivity.findViewById(R.id.et_song_search);
		et_song_search.setOnClickListener(mOnClickListener);
		bt_free_sing = (Button) mActivity.findViewById(R.id.bt_free_sing);
		bt_free_sing.setOnClickListener(mOnClickListener);
		bt_singer_list = (Button) mActivity.findViewById(R.id.bt_singer_list);
		bt_singer_list.setOnClickListener(mOnClickListener);
		bt_order_list = (Button) mActivity.findViewById(R.id.bt_order_list);
		bt_order_list.setOnClickListener(mOnClickListener);
		bt_record_list = (Button) mActivity.findViewById(R.id.bt_record_list);
		bt_record_list.setOnClickListener(mOnClickListener);
		gv_song = (HotBarGridView) mActivity.findViewById(R.id.gv_song);
		gv_song.setOnScrollListener(new PauseOnScrollListener(mImageLoader, false, true));
		rl_song_no_network = (RelativeLayout) mActivity.findViewById(R.id.rl_song_no_network);
		iv_song_no_network = (ImageView) mActivity.findViewById(R.id.iv_song_no_network);
		rl_song_no_network.setVisibility(View.INVISIBLE);
		rl_song_no_network.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				loadSongView();
			}
		});
		
		loadSongView();
	}
	
	public void clearDisplayedImages() {
		AnimateFirstDisplayListener.displayedImages.clear();
	}
	
	private Handler hotMusicHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				final List<Music> result = (List<Music>) msg.obj;
				KuwoLog.i(TAG, "load music 列表线程。完成。。");
				rl_song_progress.setVisibility(View.INVISIBLE);
				if (result != null) {
					MobclickAgent.onEvent(mActivity, "KS_DOWN_SONGLIST","1");
					HotMusicAdapter adapter = new HotMusicAdapter(result, gv_song);
					gv_song.setAdapter(adapter);
					gv_song.setOnItemClickListener(new OnItemClickListener() {

						@Override
						public void onItemClick(AdapterView<?> parent, View view,
								int position, long id) {
							Music music = result.get(position);
							Intent loadSubIntent = new Intent(mActivity, SongSubListActivity.class);
							loadSubIntent.putExtra("flag", "subSongList");
							loadSubIntent.putExtra("subTitle", music.getName());
							loadSubIntent.putExtra("listID", music.getId());
							mActivity.startActivity(loadSubIntent);

						}
					});
				} else {
					MobclickAgent.onEvent(mActivity, "KS_DOWN_SONGLIST","0");
					Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
				}
				break;

			default:
				break;
			}
		}
		
	};

	public void loadSongView() {
//		songTV.setBackgroundResource(R.drawable.song_top_btn_pressed);
		rl_song.setVisibility(View.VISIBLE);
		gv_song.setVisibility(View.VISIBLE);
		rl_song_no_network.setVisibility(View.INVISIBLE);
		
		final List<Music> hotList = getHotListFromCache();
		if(hotList != null) {
			HotMusicAdapter adapter = new HotMusicAdapter(hotList, gv_song);
			gv_song.setAdapter(adapter);
			gv_song.setOnItemClickListener(new OnItemClickListener() {

				@Override
				public void onItemClick(AdapterView<?> parent, View view,
						int position, long id) {
					Music music = hotList.get(position);
					Intent loadSubIntent = new Intent(mActivity, SongSubListActivity.class);
					loadSubIntent.putExtra("flag", "subSongList");
					loadSubIntent.putExtra("subTitle", music.getName());
					loadSubIntent.putExtra("listID", music.getId());
					mActivity.startActivity(loadSubIntent);

				}
			});
		}else {
			if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
				gv_song.setVisibility(View.INVISIBLE);
				rl_song_no_network.setVisibility(View.VISIBLE);
			}
		}
	}
	
	private List<Music> getHotListFromCache() {
		List<Music> cacheList = null;
		MusicListLogic logic = new MusicListLogic();
		boolean result = logic.checkCacheHotList();
		if(result) {
			//缓存没有过期
			try {
				cacheList = logic.getCacheHotList();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}else {
			//缓存过期，或者没有缓存
			if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
				getHotListFromServer();
			}else {
				try {
					return logic.getCacheHotList();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return cacheList;
	}
	
	private void getHotListFromServer() {
		
		if(AppContext.getNetworkSensor() != null && AppContext.getNetworkSensor().hasAvailableNetwork()) {
			rl_song_progress.setVisibility(View.VISIBLE);
			
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					MusicListLogic musicListLogic = new MusicListLogic();
					Message msg = hotMusicHandler.obtainMessage();
					msg.what = 0;
					List<Music> result = null;
					try {
						result = musicListLogic.getHotList();
					} catch(SocketException e) {
						//show no data
						gv_song.setVisibility(View.INVISIBLE);
						rl_song_no_network.setVisibility(View.VISIBLE);
						iv_song_no_network.setImageResource(R.drawable.fail_fetchdata);
					} catch (IOException e) {
						e.printStackTrace();
					}
					msg.obj = result;
					hotMusicHandler.sendMessage(msg);
				}
			}).start();
		}else {
			gv_song.setVisibility(View.INVISIBLE);
			rl_song_no_network.setVisibility(View.VISIBLE);
		}
	}

	class HotMusicAdapter extends BaseAdapter {
		private List<Music> mHotMusicList;
		private ListView mHotSongLV;
		private GridView mHotSongGV;
		private Music music;
		private ImageLoadingListener animateFirstListener = new AnimateFirstDisplayListener();

		public HotMusicAdapter(List<Music> hotMusicList, ListView lv) {
			mHotMusicList = hotMusicList;
			mHotSongLV = lv;
		}

		public HotMusicAdapter(List<Music> hotMusicList, GridView gv) {
			mHotMusicList = hotMusicList;
			mHotSongGV = gv;
		}
		
		@Override
		public int getCount() {
			return mHotMusicList.size();
		}

		@Override
		public Object getItem(int position) {
			return mHotMusicList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View view = null;
			HotMusicViewHolder viewHolder = null;
			if (convertView == null) {
				view = View.inflate(mActivity, R.layout.song_hot_list_item,
						null);
				viewHolder = new HotMusicViewHolder();
				viewHolder.hotSongIV = (ImageView) view
						.findViewById(R.id.iv_song_list_item);
				viewHolder.hotSongNameTV = (TextView) view
						.findViewById(R.id.tv_song_list_item);
				view.setTag(viewHolder);
			} else {
				view = convertView;
				viewHolder = (HotMusicViewHolder) view.getTag();
			}
			music = mHotMusicList.get(position);
			viewHolder.hotSongNameTV.setText(music.getName());
			String imageUrl = music.getImg();
			mImageLoader.displayImage(imageUrl, viewHolder.hotSongIV, options, animateFirstListener);
			return view;
		}

	}

	static class HotMusicViewHolder {
		ImageView hotSongIV;
		TextView hotSongNameTV;
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
		
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			int id = v.getId();
			switchScene(id);
		}
	};

	private void switchScene(int id) {

		switch (id) {
		case R.id.et_song_search:
			Intent searchIntent = new Intent(mActivity, SearchActivity.class);
			mActivity.startActivity(searchIntent);
			break;
		case R.id.bt_song_search:
			// 搜索
//			songTV.setBackgroundResource(R.drawable.song_top_btn_pressed);
			break;
		case R.id.bt_free_sing:
			// 自由清唱
			Intent freeIntent = new Intent(mActivity, SingActivity.class);
			freeIntent.putExtra("mode", MTVBusiness.MODE_AUDIO);
			freeIntent.putExtra("action", MTVBusiness.ACTION_RECORD);
			mActivity.startActivity(freeIntent);
			break;
		case R.id.bt_order_list:
			Intent orderListIntent = new Intent(mActivity, OrderListActivity.class);
			mActivity.startActivity(orderListIntent);
			break;
		case R.id.bt_singer_list:
			// 歌手列表
			Intent singerListIntent = new Intent(mActivity, SingerListActivity.class);
			mActivity.startActivity(singerListIntent);
			break;
		case R.id.bt_record_list:
			Intent recordListIntent = new Intent(mActivity, RecordListActivity.class);
			mActivity.startActivity(recordListIntent);
			break;
		default:
			break;
		}
	}
}
