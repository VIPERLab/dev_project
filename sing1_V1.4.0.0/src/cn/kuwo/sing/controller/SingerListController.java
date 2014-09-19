package cn.kuwo.sing.controller;

import java.io.IOException;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.AsyncTask;
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
import android.widget.RelativeLayout;
import android.widget.TextView;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.logic.MusicListLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.HotSingerActivity;
import cn.kuwo.sing.ui.activities.SubSingerListActivity;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageLoadingListener;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.assist.PauseOnScrollListener;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.SimpleBitmapDisplayer;

public class SingerListController extends BaseController {
	private final String TAG = "SingerListController";
	private BaseActivity mActivity;
	private GridView gv_singer_list;
	private RelativeLayout rl_singer_list_progress;
	private int imageWidth;
	private int imageHeight;
	private DisplayImageOptions options;
	private ImageLoader mImageLoader;
	private RelativeLayout rl_singer_list_no_network;
	
	public SingerListController(BaseActivity activity, ImageLoader imageLoader) {
		KuwoLog.i(TAG, "SingerListController");
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
		imageWidth = mActivity.getWindowManager().getDefaultDisplay().getWidth()/4;
		imageHeight = mActivity.getWindowManager().getDefaultDisplay().getWidth()/4;
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
		Button bt_singer_list_back = (Button) mActivity.findViewById(R.id.bt_singer_list_back);
		rl_singer_list_progress = (RelativeLayout) mActivity.findViewById(R.id.rl_singer_list_progress);
		rl_singer_list_no_network = (RelativeLayout) mActivity.findViewById(R.id.rl_singer_list_no_network);
		rl_singer_list_no_network.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				loadSingerList();
			}
		});
		rl_singer_list_no_network.setVisibility(View.INVISIBLE);
		bt_singer_list_back.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				mActivity.finish();
			}
		});
		gv_singer_list = (GridView) mActivity.findViewById(R.id.gv_singer_list);
		gv_singer_list.setOnScrollListener(new PauseOnScrollListener(mImageLoader, true, true));
		loadSingerList();
	}

	private void loadSingerList() {
//		new SingerListLoader().execute(null);
		final List<Music> result = getSingerListFromCache();
		if(result != null) {
			rl_singer_list_no_network.setVisibility(View.INVISIBLE);
			rl_singer_list_progress.setVisibility(View.INVISIBLE);
			gv_singer_list.setVisibility(View.VISIBLE);
			SingerListAdapter adapter = new SingerListAdapter(result, gv_singer_list);
			gv_singer_list.setAdapter(adapter);
			gv_singer_list.setOnItemClickListener(new OnItemClickListener() {

				@Override
				public void onItemClick(AdapterView<?> parent, View view,
						int position, long id) {
					if(position == 0) {
						Intent hotSingerListIntent = new Intent(mActivity, HotSingerActivity.class);
						hotSingerListIntent.putExtra("singerTypeID", result.get(0).getId());
						mActivity.startActivity(hotSingerListIntent);
					}else {
						Intent subSingerListIntent = new Intent(mActivity, SubSingerListActivity.class);
						subSingerListIntent.putExtra("singerTypeID", result.get(position).getId());
						subSingerListIntent.putExtra("singerTypeName", result.get(position).getName());
						mActivity.startActivity(subSingerListIntent);
					}
				}
			});
		}else {
			if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
				if(rl_singer_list_no_network != null && gv_singer_list != null) {
					gv_singer_list.setVisibility(View.INVISIBLE);
					rl_singer_list_no_network.setVisibility(View.VISIBLE);
				}
			}
		}
	}
	
	private List<Music> getSingerListFromCache() {
		List<Music> singerList = null;
		MusicListLogic logic = new MusicListLogic();
		boolean result = logic.checkCacheSingerList();
		if(result) {
			//缓存可用
			try {
				singerList = logic.getCacheSingerList();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}else {
			//缓存不可用
			if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
				getSingerListFromServer();
			}else {
				try {
					return logic.getCacheSingerList();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return singerList;
	}
	
	private void getSingerListFromServer() {
		if(AppContext.getNetworkSensor() != null && AppContext.getNetworkSensor().hasAvailableNetwork()) {
			rl_singer_list_no_network.setVisibility(View.INVISIBLE);
			gv_singer_list.setVisibility(View.INVISIBLE);
			rl_singer_list_progress.setVisibility(View.VISIBLE);
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					List<Music> result = null;
					MusicListLogic logic = new MusicListLogic();
					try {
						result =  logic.getSingerList();
					} catch (IOException e) {
						e.printStackTrace();
					}
					Message msg = singerListHandler.obtainMessage();
					msg.what = 0;
					msg.obj = result;
					singerListHandler.sendMessage(msg);
				}
			}).start();
		}else {
			if(rl_singer_list_no_network != null && gv_singer_list != null) {
				gv_singer_list.setVisibility(View.INVISIBLE);
				rl_singer_list_no_network.setVisibility(View.VISIBLE);
			}
		}
	}
	
	private Handler singerListHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				final List<Music> result = (List<Music>) msg.obj;
				rl_singer_list_no_network.setVisibility(View.INVISIBLE);
				rl_singer_list_progress.setVisibility(View.INVISIBLE);
				gv_singer_list.setVisibility(View.VISIBLE);
				if(result != null) {
					SingerListAdapter adapter = new SingerListAdapter(result, gv_singer_list);
					gv_singer_list.setAdapter(adapter);
					gv_singer_list.setOnItemClickListener(new OnItemClickListener() {

						@Override
						public void onItemClick(AdapterView<?> parent, View view,
								int position, long id) {
							if(position == 0) {
								Intent hotSingerListIntent = new Intent(mActivity, HotSingerActivity.class);
								hotSingerListIntent.putExtra("singerTypeID", result.get(0).getId());
								mActivity.startActivity(hotSingerListIntent);
							}else {
								Intent subSingerListIntent = new Intent(mActivity, SubSingerListActivity.class);
								subSingerListIntent.putExtra("singerTypeID", result.get(position).getId());
								subSingerListIntent.putExtra("singerTypeName", result.get(position).getName());
								mActivity.startActivity(subSingerListIntent);
							}
						}
					});
				}
				break;

			default:
				break;
			}
		}
		
	};
	
	class SingerListLoader extends AsyncTask<Void, Void, List<Music>> {

		@Override
		protected void onPreExecute() {
			rl_singer_list_progress.setVisibility(View.VISIBLE);
			super.onPreExecute();
		}

		@Override
		protected List<Music> doInBackground(Void... params) {
			List<Music> result = null;
			MusicListLogic logic = new MusicListLogic();
			try {
				result =  logic.getSingerList();
			} catch (IOException e) {
				e.printStackTrace();
			}
			return result;
		}

		@Override
		protected void onPostExecute(final List<Music> result) {
			rl_singer_list_progress.setVisibility(View.INVISIBLE);
			if(result != null) {
				SingerListAdapter adapter = new SingerListAdapter(result, gv_singer_list);
				gv_singer_list.setAdapter(adapter);
				gv_singer_list.setOnItemClickListener(new OnItemClickListener() {

					@Override
					public void onItemClick(AdapterView<?> parent, View view,
							int position, long id) {
						if(position == 0) {
							Intent hotSingerListIntent = new Intent(mActivity, HotSingerActivity.class);
							hotSingerListIntent.putExtra("singerTypeID", result.get(0).getId());
							mActivity.startActivity(hotSingerListIntent);
						}else {
							Intent subSingerListIntent = new Intent(mActivity, SubSingerListActivity.class);
							subSingerListIntent.putExtra("singerTypeID", result.get(position).getId());
							subSingerListIntent.putExtra("singerTypeName", result.get(position).getName());
							mActivity.startActivity(subSingerListIntent);
						}
					}
				});
			}
			super.onPostExecute(result);
		}
	}
	
	class SingerListAdapter extends BaseAdapter {
		private List<Music> mSingerList;
		private GridView mGV;
		private ImageLoadingListener animateFirstListener = new AnimateFirstDisplayListener();
		
		public SingerListAdapter(List<Music> singerList, GridView gv) {
			mSingerList = singerList;
			mGV = gv;
		}

		@Override
		public int getCount() {
			return mSingerList.size();
		}

		@Override
		public Object getItem(int position) {
			return mSingerList.get(position);
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
				view = View.inflate(mActivity, R.layout.singer_list_item, null);
				viewHolder = new ViewHolder();
				viewHolder.singerTypeIV = (ImageView) view.findViewById(R.id.iv_singer);
				viewHolder.singerTypeTV = (TextView) view.findViewById(R.id.tv_singer_type);
				view.setTag(viewHolder);
			}else {
				view = convertView;
				viewHolder = (ViewHolder) view.getTag();
			}
			Music music = mSingerList.get(position);
			viewHolder.singerTypeTV.setText(music.getName());
			String imageUrl = music.getImg();
			mImageLoader.displayImage(imageUrl, viewHolder.singerTypeIV, options, animateFirstListener);
//			String imagePath = ImageUtils.makeImagePathFromUrl(imageUrl);
//			viewHolder.singerTypeIV.setTag(imagePath);
//			Bitmap bitmap = ImageUtils.loadImageFromCache(new ImageCallback(), imagePath, imageUrl, imageWidth, imageHeight);
//			if(bitmap == null) {
//				viewHolder.singerTypeIV.setImageResource(R.drawable.image_loading_small);
//			}else {
//				viewHolder.singerTypeIV.setImageBitmap(bitmap);
//			}
			return view;
		}
		
//		class ImageCallback implements ImageAsyncTaskCallback {
//
//			@Override
//			public void onPreImageLoad() {
//				
//			}
//
//			@Override
//			public void onPostImageLoad(Bitmap bitmap, String imagePath) {
//				ImageView iv = (ImageView) mGV.findViewWithTag(imagePath);
//				if(iv != null) {
//					iv.setImageBitmap(bitmap);
//				}
//			}
//			
//		}
	}
	
	static class ViewHolder {
		ImageView singerTypeIV;
		TextView singerTypeTV;
	}
}
