package cn.kuwo.sing.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.graphics.Typeface;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout.LayoutParams;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.SectionIndexer;
import android.widget.TextView;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.logic.MusicListLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.SongSubListActivity;
import cn.kuwo.sing.util.DensityUtils;
import cn.kuwo.sing.widget.Content;
import cn.kuwo.sing.widget.PinyinComparator;
import cn.kuwo.sing.widget.SideBar;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageLoadingListener;
import com.nostra13.universalimageloader.core.assist.PauseOnScrollListener;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.SimpleBitmapDisplayer;

public class SubSingerListController extends BaseController {
	private final String TAG = "SubSingerListController";
	private BaseActivity mActivity;
	private ListView lv_sub_singer;
	private SideBar sideBar;
	private TextView letterMiddleTV;
	private TextView sub_singer_list_title;
	private WindowManager mWindowManager;
	private List<Content> mContentList = new ArrayList<Content>();
	private Button bt_sub_singer_list_back;
	private RelativeLayout rl_sub_singer_progress;
	public static boolean isScrolling;
	private int imageWidth;
	private int imageHeight;
	private ImageLoader mImageLoader;
	private DisplayImageOptions options;
	private RelativeLayout rl_sub_singer_no_network;
	private String singerTypeID;
	
	public SubSingerListController(BaseActivity activity, ImageLoader imageLoader) {
		KuwoLog.i(TAG, "SubSingerListController");
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
		.displayer(new SimpleBitmapDisplayer())
		.build();
		initView();
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
		bt_sub_singer_list_back = (Button) mActivity.findViewById(R.id.bt_sub_singer_list_back);
		rl_sub_singer_progress = (RelativeLayout) mActivity.findViewById(R.id.rl_sub_singer_progress);
		rl_sub_singer_no_network = (RelativeLayout) mActivity.findViewById(R.id.rl_sub_singer_no_network);
		rl_sub_singer_no_network.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				loadSubSingerList(singerTypeID);
			}
		});
		rl_sub_singer_no_network.setVisibility(View.INVISIBLE);
		
		
		bt_sub_singer_list_back.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if(letterMiddleTV != null) {
					mWindowManager.removeView(letterMiddleTV);
				}
				mActivity.finish();
			}
		});
		lv_sub_singer = (ListView) mActivity.findViewById(R.id.lv_sub_singer);
		lv_sub_singer.setOnScrollListener(new PauseOnScrollListener(mImageLoader, false, true));
		sideBar = (SideBar) mActivity.findViewById(R.id.sideBar);
		letterMiddleTV = (TextView) LayoutInflater.from(mActivity).inflate(R.layout.sub_singer_list_letter_middle, null);
		letterMiddleTV.setVisibility(View.INVISIBLE);
		
		sub_singer_list_title = (TextView) mActivity.findViewById(R.id.tv_sub_singer_list_title);
		mWindowManager = (WindowManager) mActivity.getSystemService(Context.WINDOW_SERVICE);
		WindowManager.LayoutParams param = new WindowManager.LayoutParams( 
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT,
				WindowManager.LayoutParams.TYPE_APPLICATION,
				WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
				PixelFormat.TRANSLUCENT);
		mWindowManager.addView(letterMiddleTV, param);
		sideBar.setTextView(letterMiddleTV);
		sideBar.setVisibility(View.INVISIBLE);
		
		Intent intent = mActivity.getIntent();
		singerTypeID = intent.getStringExtra("singerTypeID");
		String singerTypeName = intent.getStringExtra("singerTypeName");
		sub_singer_list_title.setText(singerTypeName);
		loadSubSingerList(singerTypeID);
	}
	
	private void loadSubSingerList(final String singerTypeID) {
		HashMap<String, List<Music>> result = getSubSingerListFromCache(singerTypeID);
		if(result != null && result.size() != 0) {
			rl_sub_singer_no_network.setVisibility(View.INVISIBLE);
			lv_sub_singer.setVisibility(View.VISIBLE);
			sideBar.setVisibility(View.VISIBLE);
			for(Map.Entry<String, List<Music>> me : result.entrySet()) {
				String letter = me.getKey();
				KuwoLog.i(TAG, "key==="+letter);
				for(Music music : me.getValue()) {
					Content content = new Content(letter, music.getId(),  music.getName(), music.getNum(), music.getImg());
					mContentList.add(content);
				}
			}
			Collections.sort(mContentList, new PinyinComparator());
			SubSingerListAdapter adapter = new SubSingerListAdapter(mActivity, mImageLoader, options, mContentList, lv_sub_singer);
			lv_sub_singer.setAdapter(adapter);
			/**
			 * item click
			 */
			lv_sub_singer.setOnItemClickListener(new OnItemClickListener() {

				@Override
				public void onItemClick(AdapterView<?> parent, View view,
						int position, long id) {
					Intent subIntent = new Intent(mActivity, SongSubListActivity.class);
					subIntent.putExtra("flag", "singerSongList");
					subIntent.putExtra("listID", mContentList.get(position).getId());
					subIntent.putExtra("subTitle", mContentList.get(position).getName() +"（"+ mContentList.get(position).getSongsCount()+"首）");
					mActivity.startActivity(subIntent);
				}
			});
			sideBar.setListView(lv_sub_singer);
		}else {
			if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
				if(rl_sub_singer_no_network != null && lv_sub_singer != null && sideBar != null) {
					lv_sub_singer.setVisibility(View.INVISIBLE);
					sideBar.setVisibility(View.INVISIBLE);
					rl_sub_singer_no_network.setVisibility(View.VISIBLE);
				}
			}
		}
	}
	
	private HashMap<String, List<Music>> getSubSingerListFromCache(String singerTypeID) {
		HashMap<String, List<Music>> subSingerMap = null;
		MusicListLogic logic = new MusicListLogic();
		boolean result = logic.checkCacheSingerSubList(singerTypeID);
		if(result) {
			try {
				subSingerMap = logic.getCacheSingerSubList(singerTypeID);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}else {
			if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
				getSubSingerListFromServer(singerTypeID);
			}else {
				try {
					return logic.getCacheSingerSubList(singerTypeID);
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return subSingerMap;
	}
	
	private void getSubSingerListFromServer(final String singerTypeID) {
		if(AppContext.getNetworkSensor() != null && AppContext.getNetworkSensor().hasAvailableNetwork()) {
			sideBar.setVisibility(View.INVISIBLE);
			rl_sub_singer_no_network.setVisibility(View.INVISIBLE);
			rl_sub_singer_progress.setVisibility(View.VISIBLE);
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					HashMap<String, List<Music>> result = null;
					MusicListLogic logic = new MusicListLogic();
					try {
						result = logic.getSingerSubList(singerTypeID);
					} catch (IOException e) {
						e.printStackTrace();
					}
					Message msg = subSingerListHandler.obtainMessage();
					msg.what = 0;
					msg.obj = result;
					subSingerListHandler.sendMessage(msg);
				}
			}).start();
		}else {
			if(rl_sub_singer_no_network != null && lv_sub_singer != null && sideBar != null) {
				lv_sub_singer.setVisibility(View.INVISIBLE);
				sideBar.setVisibility(View.INVISIBLE);
				rl_sub_singer_no_network.setVisibility(View.VISIBLE);
			}
		}
	}
	
	private Handler subSingerListHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				HashMap<String, List<Music>> result = (HashMap<String, List<Music>>) msg.obj;
				if(result != null && result.size() != 0) {
					rl_sub_singer_no_network.setVisibility(View.INVISIBLE);
					lv_sub_singer.setVisibility(View.VISIBLE);
					sideBar.setVisibility(View.VISIBLE);
					rl_sub_singer_progress.setVisibility(View.INVISIBLE);
					for(Map.Entry<String, List<Music>> me : result.entrySet()) {
						String letter = me.getKey();
						KuwoLog.i(TAG, "key==="+letter);
						for(Music music : me.getValue()) {
							Content content = new Content(letter, music.getId(),  music.getName(), music.getNum(), music.getImg());
							mContentList.add(content);
						}
					}
					Collections.sort(mContentList, new PinyinComparator());
					SubSingerListAdapter adapter = new SubSingerListAdapter(mActivity, mImageLoader, options, mContentList, lv_sub_singer);
					lv_sub_singer.setAdapter(adapter);
					lv_sub_singer.setOnItemClickListener(new OnItemClickListener() {

						@Override
						public void onItemClick(AdapterView<?> parent, View view,
								int position, long id) {
							Intent subIntent = new Intent(mActivity, SongSubListActivity.class);
							subIntent.putExtra("flag", "singerSongList");
							subIntent.putExtra("listID", mContentList.get(position).getId());
							subIntent.putExtra("subTitle", mContentList.get(position).getName() +"（"+ mContentList.get(position).getSongsCount()+"首）");
							mActivity.startActivity(subIntent);
						}
					});
					sideBar.setListView(lv_sub_singer);
				}
				break;

			default:
				break;
			}
		}
		
	};
	
	class SubSingerListAdapter extends BaseAdapter implements SectionIndexer{
		private Activity mContext;
		private List<Content> mContentList;
		private ListView mListView;
		private int imageWidth;
		private int imageHeight;
		private ImageLoader mImageLoader;
		private DisplayImageOptions options;
		private ImageLoadingListener animateFirstListener = new AnimateFirstDisplayListener();
		
		public SubSingerListAdapter(Activity context,ImageLoader imageLoader, DisplayImageOptions opts, List<Content> contentList, ListView lv) {
			mContext = context;
			mImageLoader = imageLoader;
			options = opts;
			imageWidth = mContext.getWindowManager().getDefaultDisplay().getWidth()/4;
			imageHeight = mContext.getWindowManager().getDefaultDisplay().getWidth()/4;
			mContentList = contentList;
			mListView = lv;
		}
		
		@Override
		public int getCount() {
			return mContentList.size();
		}

		@Override
		public Object getItem(int position) {
			return mContentList.get(position);
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
				view = View.inflate(mContext, R.layout.sub_singer_list_item, null);
				viewHolder = new ViewHolder();
				viewHolder.singerCategoryTV = (TextView) view.findViewById(R.id.tv_sub_singer_catalog);
				viewHolder.singerIV = (ImageView) view.findViewById(R.id.iv_sub_singer_list_item);
				viewHolder.singerNameTV = (TextView) view.findViewById(R.id.tv_sub_singer_name);
				viewHolder.singerSongsCountTV = (TextView) view.findViewById(R.id.tv_sub_singer_songs_count);
				view.setTag(viewHolder);
			}else {
				view = convertView;
				viewHolder = (ViewHolder) view.getTag();
			}
			Content content = mContentList.get(position);
			if(position == 0) {
				viewHolder.singerCategoryTV.setVisibility(View.VISIBLE);
				viewHolder.singerCategoryTV.setText(content.getLetter());
				viewHolder.singerCategoryTV.setTextSize(DensityUtils.px2sp(mContext, DensityUtils.dip2px(mContext, 22)));
				viewHolder.singerCategoryTV.setTextColor(Color.WHITE);
				viewHolder.singerCategoryTV.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
			}else {
				String lastCatelog = mContentList.get(position-1).getLetter();
				if(content.getLetter().equals(lastCatelog)) {
					viewHolder.singerCategoryTV.setVisibility(View.GONE);
				}else {
					viewHolder.singerCategoryTV.setVisibility(View.VISIBLE);
					viewHolder.singerCategoryTV.setText(content.getLetter());
					viewHolder.singerCategoryTV.setTextSize(DensityUtils.px2sp(mContext, DensityUtils.dip2px(mContext, 16)));
					viewHolder.singerCategoryTV.setTextColor(Color.WHITE);
					viewHolder.singerCategoryTV.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
				}
			}
			viewHolder.singerNameTV.setText(content.getName());
			viewHolder.singerSongsCountTV.setText(content.getSongsCount()+"首");
			String imageUrl = content.getImageUrl();
			mImageLoader.displayImage(imageUrl, viewHolder.singerIV, options, animateFirstListener);
			return view;
		}
		
		@Override
		public Object[] getSections() {
			return null;
		}

		@Override
		public int getPositionForSection(int section) {
			Content mContent;
			String l;
			for (int i = 0; i < getCount(); i++) {
				mContent = (Content) mContentList.get(i);
				l = mContent.getLetter();
				char firstChar = l.toUpperCase().charAt(0);
				if (firstChar == section) {
					return i;
				}

			}
			mContent = null;
			l = null;
			return -1;
		}

		@Override
		public int getSectionForPosition(int position) {
			return 0;
		}
	}
	
	static class ViewHolder {
		TextView  singerCategoryTV;
		ImageView singerIV;
		TextView  singerNameTV;
		TextView  singerSongsCountTV;
	}

}
