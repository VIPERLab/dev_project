/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Typeface;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.view.ViewPager;
import android.util.TypedValue;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.cache.CacheManager;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.MTV;
import cn.kuwo.sing.bean.SongUnit;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.MusicListLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.adapter.SquarePagerAdapter;
import cn.kuwo.sing.util.DensityUtils;
import cn.kuwo.sing.widget.KuwoListView;
import cn.kuwo.sing.widget.KuwoListView.KuwoListViewListener;
import cn.kuwo.sing.widget.PagerSlidingTabStrip;

import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageLoadingListener;
import com.nostra13.universalimageloader.core.assist.PauseOnScrollListener;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2012-10-31, 下午5:57:50, 2012
 *
 * @Author wangming
 *
 */
public class SquareController extends BaseController {
	private final String TAG = "SquareController";
	private BaseActivity mActivity;
	private TextView square_hot_songs;
	private TextView square_lattest_songs;
	private TextView square_famous;
	private FrameLayout fl_square_container;
	private FrameLayout subViewHot;
	private FrameLayout subViewNew;
	private FrameLayout subViewSuperStar;
	private RelativeLayout rl_square_hot_progress;
	private RelativeLayout rl_square_new_progress;
	private RelativeLayout rl_square_super_progress;
	private KuwoListView lv_square_hot;
	private KuwoListView lv_square_new;
	private KuwoListView lv_square_super;
	private boolean isHotLoadMore = false;
	private boolean isNewLoadMore = false;
	private boolean isSuperLoadMore = false;
	private boolean isHotRefresh = false;
	private boolean isNewRefresh = false;
	private boolean isSuperRefresh = false;
	private RelativeLayout rl_square_hot_no_network;
	private RelativeLayout rl_square_new_no_network;
	private RelativeLayout rl_square_super_no_network;
	public boolean isServerError = false;
	private HotAdapter hotAdapter;
	private NewAdapter newAdapter;
	private SuperAdapter superAdapter;
	private ImageView iv_square_hot_no_network;
	private ImageView iv_square_new_no_network;
	private ImageView iv_square_super_no_network;
	private boolean isHotFirstLoad = true;
	private boolean isNewFirstLoad = true;
	private boolean isSuperFirstLoad = true;
	private ImageLoader mImageLoader;
	
	private PagerSlidingTabStrip mTabs;
	private ViewPager mViewPager;
	
	public SquareController(BaseActivity activity, ImageLoader imageLoader) {
		KuwoLog.i(TAG, "SquareController");
		mActivity = activity;
		mImageLoader = imageLoader;
		initView();
	}

	private void initView() {
//		square_hot_songs = (TextView) mActivity.findViewById(R.id.square_hot_songs);
//		square_hot_songs.setOnClickListener(mOnClickListener);
//
//		square_lattest_songs = (TextView) mActivity.findViewById(R.id.square_lattest_songs);
//		square_lattest_songs.setOnClickListener(mOnClickListener);
//
//		square_famous = (TextView) mActivity.findViewById(R.id.square_famous);
//		square_famous.setOnClickListener(mOnClickListener);
//		
//		fl_square_container = (FrameLayout) mActivity.findViewById(R.id.fl_square_container);
		subViewHot = (FrameLayout) View.inflate(mActivity, R.layout.square_layout, null);
		subViewNew = (FrameLayout) View.inflate(mActivity, R.layout.square_layout, null);
		subViewSuperStar = (FrameLayout) View.inflate(mActivity, R.layout.square_layout, null);
		
		hotAdapter = new HotAdapter();
		newAdapter = new NewAdapter();
		superAdapter = new SuperAdapter();
		
		square_hot_songs.performClick();
	}

	
	public void showNoNetwork() {
		if(lv_square_hot != null && rl_square_hot_no_network != null) {
			lv_square_hot.setVisibility(View.INVISIBLE);
			rl_square_hot_no_network.setVisibility(View.VISIBLE);
			iv_square_hot_no_network.setImageResource(R.drawable.fail_network);
		}
		
		if(lv_square_new != null && rl_square_new_no_network != null) {
			lv_square_new.setVisibility(View.INVISIBLE);
			rl_square_new_no_network.setVisibility(View.VISIBLE);
			iv_square_new_no_network.setImageResource(R.drawable.fail_network);
		}
		
		if(lv_square_super != null && rl_square_super_no_network != null) {
			lv_square_super.setVisibility(View.INVISIBLE);
			rl_square_super_no_network.setVisibility(View.VISIBLE);
			iv_square_super_no_network.setImageResource(R.drawable.fail_network);
		}
	}
	
	public void showNoData() {
		if(lv_square_hot != null && rl_square_hot_no_network != null) {
			lv_square_hot.setVisibility(View.INVISIBLE);
			rl_square_hot_no_network.setVisibility(View.VISIBLE);
			iv_square_hot_no_network.setImageResource(R.drawable.fail_fetchdata);
		}
		
		if(lv_square_new != null && rl_square_new_no_network != null) {
			lv_square_new.setVisibility(View.INVISIBLE);
			rl_square_new_no_network.setVisibility(View.VISIBLE);
			iv_square_new_no_network.setImageResource(R.drawable.fail_fetchdata);
		}
		
		if(lv_square_super != null && rl_square_super_no_network != null) {
			lv_square_super.setVisibility(View.INVISIBLE);
			rl_square_super_no_network.setVisibility(View.VISIBLE);
			iv_square_super_no_network.setImageResource(R.drawable.fail_fetchdata);
		}
	}
	
	private void loadHotView() {
		rl_square_hot_no_network = (RelativeLayout) subViewHot.findViewById(R.id.rl_square_layout_no_network);
		rl_square_hot_no_network.setVisibility(View.INVISIBLE);
		iv_square_hot_no_network = (ImageView) subViewHot.findViewById(R.id.iv_square_layout_no_network);
		rl_square_hot_no_network.setVisibility(View.INVISIBLE);
		rl_square_hot_no_network.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				isHotFirstLoad = true;
				loadHotView();
			}
		});
		rl_square_hot_progress = (RelativeLayout) subViewHot.findViewById(R.id.rl_square_progress);
		lv_square_hot = (KuwoListView) subViewHot.findViewById(R.id.lv_square_layout);
		fl_square_container.removeAllViews();
		fl_square_container.addView(subViewHot);
		lv_square_hot.setVisibility(View.VISIBLE);
		lv_square_hot.setPullLoadEnable(true);
		lv_square_hot.setPullRefreshEnable(true);
		lv_square_hot.setKuwoListViewListener(new KuwoListViewListener() {
			
			@Override
			public void onRefresh() {
				if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
					isHotRefresh = true;
					getHotDataFromServer(1);
				}else {
					Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
					onHotLoad();
				}
			}
			
			@Override
			public void onLoadMore() {
				if(MusicListLogic.hotCurrentPageNum == MusicListLogic.hotTotalPageNum) {
					Toast.makeText(mActivity, "亲，就这么多了", 0).show();
					lv_square_hot.setFooterNoData();
					return;
				}
				loadHotMore(MusicListLogic.hotCurrentPageNum+1);
			}
		});
        lv_square_hot.setOnScrollListener(new PauseOnScrollListener(mImageLoader, false, true));
        MusicListLogic logic = new MusicListLogic();
        String dataString = null;
        try {
			dataString = CacheManager.loadString("HotSongs"+1+"a"+Constants.SQUARE_LIST_PAGE_SIZE);
		} catch (IOException e) {
			e.printStackTrace();
		}
        KuwoLog.i(TAG, "缓存是否可用："+logic.checkCacheHotSongs(1, Constants.SQUARE_LIST_PAGE_SIZE));
        if(!AppContext.getNetworkSensor().hasAvailableNetwork() && dataString == null) {
        	lv_square_hot.setVisibility(View.INVISIBLE);
			rl_square_hot_no_network.setVisibility(View.VISIBLE);
			iv_square_hot_no_network.setImageResource(R.drawable.fail_network);
			return;
        }
        if(isHotFirstLoad) {
        	List<MTV> result = getHotDataFromCache(1);
        	if(result != null) {
        		if(isHotRefresh) {
        			if(!hotAdapter.mSongUnitList.isEmpty()) {
        				hotAdapter.mSongUnitList.clear();
        			}
        		}
        		KuwoLog.i(TAG, "hot list size="+result.size());
        		List<SongUnit> songUnitList = createSongUnitList(result, Constants.FLAG_HOT_MTV, mImageLoader);
        		hotAdapter.addSongUnitList(songUnitList);
        		if(!isHotLoadMore) {
        			lv_square_hot.setAdapter(hotAdapter);
        		}
        		onHotLoad();
        	}else {
        		if(!AppContext.getNetworkSensor().hasAvailableNetwork() && lv_square_hot != null && rl_square_hot_no_network != null) {
					lv_square_hot.setVisibility(View.INVISIBLE);
					rl_square_hot_no_network.setVisibility(View.VISIBLE);
					iv_square_hot_no_network.setImageResource(R.drawable.fail_network);
				}
        	}
        }
	}
	
	private List<MTV> getHotDataFromCache(int pageNum) {
		KuwoLog.i(TAG, "getHotDataFromCache");
		isHotFirstLoad = false;
		List<MTV> hotList = null;
		MusicListLogic logic = new MusicListLogic();
		try {
			hotList = logic.getCacheHotSongs(pageNum, Constants.SQUARE_LIST_PAGE_SIZE);
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
			if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
				Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
				onHotLoad();
			}
		}
		
		boolean result = logic.checkCacheHotSongs(pageNum, Constants.SQUARE_LIST_PAGE_SIZE);
		if(!result) {
			//缓存过期，或者没有
			KuwoLog.i(TAG, "get hot from server pageNum="+pageNum);
			if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
				getHotDataFromServer(pageNum);
			}
		}
		return hotList;
	}
	
	private void getHotDataFromServer(final int pageNum) {
		if(AppContext.getNetworkSensor()!= null && AppContext.getNetworkSensor().hasAvailableNetwork()) {
			if(isHotRefresh || isHotLoadMore) {
				rl_square_hot_progress.setVisibility(View.INVISIBLE);
			}else {
				if(rl_square_hot_progress != null) {
					rl_square_hot_progress.setVisibility(View.VISIBLE);
				}
			}
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					List<MTV> result = null;
					MusicListLogic musicListLogic = new MusicListLogic();
					Message msg = hotDataHandler.obtainMessage();
					msg.what = 0;
					try {
						result = musicListLogic.getHotSongs(pageNum, Constants.SQUARE_LIST_PAGE_SIZE);
					}catch (IOException e) {
						KuwoLog.printStackTrace(e);
						msg.what = 1;
					}
					msg.obj = result;
					hotDataHandler.sendMessage(msg);
				}
			}).start();
		}else {
			//无网络
			if(pageNum == 1) {
				isHotFirstLoad = true;
				if(lv_square_hot != null && rl_square_hot_no_network != null) {
					lv_square_hot.setVisibility(View.INVISIBLE);
					rl_square_hot_no_network.setVisibility(View.VISIBLE);
					iv_square_hot_no_network.setImageResource(R.drawable.fail_network);
				}
			}else {
				Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
				onHotLoad();
			}
		}
	}
	
	private void loadNewView() {
		rl_square_new_no_network = (RelativeLayout) subViewNew.findViewById(R.id.rl_square_layout_no_network);
		rl_square_new_no_network.setVisibility(View.INVISIBLE);
		iv_square_new_no_network = (ImageView) subViewNew.findViewById(R.id.iv_square_layout_no_network);
		rl_square_new_no_network.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				isNewFirstLoad = true;
				loadNewView();
			}
		});
		rl_square_new_progress = (RelativeLayout) subViewNew.findViewById(R.id.rl_square_progress);
		lv_square_new = (KuwoListView) subViewNew.findViewById(R.id.lv_square_layout);
		lv_square_new.setOnScrollListener(new PauseOnScrollListener(mImageLoader, true, true));
		lv_square_new.setVisibility(View.VISIBLE);
		lv_square_new.setPullLoadEnable(true);
		lv_square_new.setPullRefreshEnable(true);
		lv_square_new.setKuwoListViewListener(new KuwoListViewListener() {
			
			@Override
			public void onRefresh() {
				if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
					isNewRefresh = true;
					getNewDataFromServer(1);
				}else {
					Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
					onNewLoad();
				}
			}
			
			@Override
			public void onLoadMore() {
				if(MusicListLogic.newCurrentPageNum == MusicListLogic.newTotalPageNum) {
					Toast.makeText(mActivity, "亲，就这么多了", 0).show();
					lv_square_new.setFooterNoData();
					return;
				}
				loadNewMore(MusicListLogic.newCurrentPageNum+1);
			}
		});
	    fl_square_container.removeAllViews();
	    fl_square_container.addView(subViewNew);
        String dataString = null;
        try {
			dataString = CacheManager.loadString("NewSongs"+1+"a"+Constants.SQUARE_LIST_PAGE_SIZE);
		} catch (IOException e) {
			e.printStackTrace();
		}
        if(!AppContext.getNetworkSensor().hasAvailableNetwork() && dataString == null) {
        	lv_square_new.setVisibility(View.INVISIBLE);
			rl_square_new_no_network.setVisibility(View.VISIBLE);
			iv_square_new_no_network.setImageResource(R.drawable.fail_network);
			return;
        }
	   if(isNewFirstLoad) {
		   List<MTV> result =  getNewDataFromCache(1);
		   if(result != null) {
			   if(isNewRefresh) {
				   if(!newAdapter.mSongUnitList.isEmpty()) {
					   newAdapter.mSongUnitList.clear();
				   }
			   }
			   KuwoLog.i(TAG, "new list size="+result.size());
			   List<SongUnit> songUnitList = createSongUnitList(result, Constants.FLAG_NEW_MTV, mImageLoader);
			   newAdapter.addSongUnitList(songUnitList);
			   if(!isNewLoadMore) {
				   lv_square_new.setAdapter(newAdapter);
			   }
			   onNewLoad();
		   }else {
			   if(!AppContext.getNetworkSensor().hasAvailableNetwork() && lv_square_new != null && rl_square_new_no_network != null) {
					lv_square_new.setVisibility(View.INVISIBLE);
					rl_square_new_no_network.setVisibility(View.VISIBLE);
					iv_square_new_no_network.setImageResource(R.drawable.fail_network);
				}
		   }
	   }
	}
	
	private List<MTV> getNewDataFromCache(int pageNum) {
		isNewFirstLoad = false;
		List<MTV> newList = null;
		MusicListLogic logic = new MusicListLogic();
		try {
			newList = logic.getCacheNewSongs(pageNum, Constants.SQUARE_LIST_PAGE_SIZE);
		} catch (IOException e) {
			if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
				Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
				onNewLoad();
			}
		}
		boolean result = logic.checkCacheNewSongs(pageNum, Constants.SQUARE_LIST_PAGE_SIZE);
		if(!result) {
			//缓存没有，或者过期
			if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
				getNewDataFromServer(pageNum);
			}
		}
		return newList;
	}
	
	private void getNewDataFromServer(final int pageNum) {
		KuwoLog.i(TAG, "getNewDataFromServer");
		if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
			if(isNewLoadMore || isNewRefresh) {
				rl_square_new_progress.setVisibility(View.INVISIBLE);
			}else {
				if(rl_square_new_progress != null) {
					rl_square_new_progress.setVisibility(View.VISIBLE);
				}
			}
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					List<MTV> result = null;
					MusicListLogic musicListLogic = new MusicListLogic();
					Message msg = newDataHandler.obtainMessage();
					msg.what = 0;
					try {
						result = musicListLogic.getNewSongs(pageNum, Constants.SQUARE_LIST_PAGE_SIZE);
					}catch (IOException e) {
						KuwoLog.printStackTrace(e);
						msg.what = 1;
					}
					msg.obj = result;
					newDataHandler.sendMessage(msg);
				}
			}).start();
		}else {
			//无网络
			if(pageNum == 1) {
				isNewFirstLoad = true;
				if(lv_square_new != null && rl_square_new_no_network != null) {
					lv_square_new.setVisibility(View.INVISIBLE);
					rl_square_new_no_network.setVisibility(View.VISIBLE);
					iv_square_new_no_network.setImageResource(R.drawable.fail_network);
				}
			}else {
				Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
				onNewLoad();
			}
		}
	}
	
	private void loadSuperView() {
		rl_square_super_no_network = (RelativeLayout) subViewSuperStar.findViewById(R.id.rl_square_layout_no_network);
		rl_square_super_no_network.setVisibility(View.INVISIBLE);
		iv_square_super_no_network = (ImageView) subViewSuperStar.findViewById(R.id.iv_square_layout_no_network);
		rl_square_super_no_network.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				loadSuperView();
			}
		});
		rl_square_super_progress = (RelativeLayout) subViewSuperStar.findViewById(R.id.rl_square_progress);
		lv_square_super = (KuwoListView) subViewSuperStar.findViewById(R.id.lv_square_layout);
		lv_square_super.setOnScrollListener(new PauseOnScrollListener(mImageLoader, true, true));
		lv_square_super.setVisibility(View.VISIBLE);
		lv_square_super.setPullLoadEnable(true);
		lv_square_super.setPullRefreshEnable(true);
		lv_square_super.setKuwoListViewListener(new KuwoListViewListener() {
			
			@Override
			public void onRefresh() {
				if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
					isSuperRefresh = true;
					getSuperDataFromServer(1);
				}else {
					Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
					onSuperLoad();
				}
			}
			
			@Override
			public void onLoadMore() {
				if(MusicListLogic.superCurrentPageNum == MusicListLogic.superTotalPageNum) {
					Toast.makeText(mActivity, "亲，就这么多了", 0).show();
					lv_square_super.setFooterNoData();
					return;
				}
				loadSuperMore(MusicListLogic.superCurrentPageNum+1);
			}
		});
		fl_square_container.removeAllViews();
		fl_square_container.addView(subViewSuperStar);
		String dataString = null;
		try {
			dataString = CacheManager.loadString("SuperStars"+1+"a"+Constants.SQUARE_LIST_PAGE_SIZE);
		} catch (IOException e) {
			e.printStackTrace();
		}
        if(!AppContext.getNetworkSensor().hasAvailableNetwork() && dataString == null) {
        	lv_square_super.setVisibility(View.INVISIBLE);
			rl_square_super_no_network.setVisibility(View.VISIBLE);
			iv_square_super_no_network.setImageResource(R.drawable.fail_network);
			return;
        }
		if(isSuperFirstLoad) {
			List<MTV> result = getSuperDataFromCache(1);	
			if(result != null) {
				if(isSuperRefresh) {
					if(!superAdapter.mSongUnitList.isEmpty()) {
						superAdapter.mSongUnitList.clear();
					}
				}
				KuwoLog.i(TAG, "super list size="+result.size());
				List<SongUnit> songUnitList = createSongUnitList(result, Constants.FLAG_SUPER_STAR, mImageLoader);
				superAdapter.addSongUnitList(songUnitList);
				if(!isSuperLoadMore) {
					lv_square_super.setAdapter(superAdapter);
				}
				onSuperLoad();
			}else {
				if(!AppContext.getNetworkSensor().hasAvailableNetwork() && lv_square_super != null && rl_square_super_no_network != null) {
					lv_square_super.setVisibility(View.INVISIBLE);
					rl_square_super_no_network.setVisibility(View.VISIBLE);
					iv_square_super_no_network.setImageResource(R.drawable.fail_network);
				}
			}
		}
	}
	
	private List<MTV> getSuperDataFromCache(int pageNum) {
		isSuperFirstLoad = false;
		List<MTV> superList = null;
		MusicListLogic logic = new MusicListLogic();
		try {
			superList = logic.getCacheSuperStars(pageNum, Constants.SQUARE_LIST_PAGE_SIZE);
		} catch (IOException e) {
			if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
				Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
				onSuperLoad();
			}
		}
		boolean result = logic.checkCacheSuperStars(pageNum, Constants.SQUARE_LIST_PAGE_SIZE);
		if(!result) {
			if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
				getSuperDataFromServer(pageNum);
			}
		}
		return superList;
	}
	
	private void getSuperDataFromServer(final int pageNum) {
		if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
			if(isSuperRefresh || isSuperLoadMore) {
				rl_square_super_progress.setVisibility(View.INVISIBLE);
			}else {
				if(rl_square_super_progress != null) {
					rl_square_super_progress.setVisibility(View.VISIBLE);
				}
			}
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					List<MTV> result = null;
					MusicListLogic musicListLogic = new MusicListLogic();
					Message msg = superDataHandler.obtainMessage();
					msg.what = 0;
					try {
						result = musicListLogic.getSuperStars(pageNum, Constants.SQUARE_LIST_PAGE_SIZE);
					} catch (IOException e) {
						KuwoLog.printStackTrace(e);
						msg.what = 1;
					}
					msg.obj = result;
					superDataHandler.sendMessage(msg);
				}
			}).start();
		}else {
			if(pageNum == 1) {
				isSuperFirstLoad = true;
				if(lv_square_super != null && rl_square_super_no_network != null) {
					lv_square_super.setVisibility(View.INVISIBLE);
					rl_square_super_no_network.setVisibility(View.VISIBLE);
					iv_square_super_no_network.setImageResource(R.drawable.fail_network);
				}
			}else {
				Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
				onSuperLoad();
			}
		}
		
	}
	
	private void loadHotMore(int currentHotPageNum) {
		KuwoLog.i(TAG, "currentHotPageNum="+currentHotPageNum);
		isHotLoadMore = true;
		
		List<MTV> result = getHotDataFromCache(currentHotPageNum);
		if(result != null) {
			if(isHotRefresh) {
				if(!hotAdapter.mSongUnitList.isEmpty()) {
					if(result.size() != 0) {
						hotAdapter.mSongUnitList.clear();
					}
				}
			}
			List<SongUnit> songUnitList = createSongUnitList(result, Constants.FLAG_HOT_MTV, mImageLoader);
			hotAdapter.addSongUnitList(songUnitList);
			if(!isHotLoadMore) {
				lv_square_hot.setAdapter(hotAdapter);
			}
			onHotLoad();
		}
	}
	
	private void loadNewMore(int currentNewPageNum) {
		KuwoLog.i(TAG, "currentNewPageNum="+currentNewPageNum);
		isNewLoadMore = true;
		List<MTV> result = getNewDataFromCache(currentNewPageNum);
		if(result != null) {
			if(isNewRefresh) {
				if(!newAdapter.mSongUnitList.isEmpty()) {
					if(result.size() != 0) {
						newAdapter.mSongUnitList.clear();
					}
				}
			}
			KuwoLog.i(TAG, "new list size="+result.size());
			List<SongUnit> songUnitList = createSongUnitList(result, Constants.FLAG_NEW_MTV, mImageLoader);
			newAdapter.addSongUnitList(songUnitList);
			if(!isNewLoadMore) {
				lv_square_new.setAdapter(newAdapter);
			}
			onNewLoad();
		}
	}
	
	private void loadSuperMore(int currentSuperPageNum) {
		KuwoLog.i(TAG, "currentSuperPageNum="+currentSuperPageNum);
		isSuperLoadMore = true;
		List<MTV> result = getSuperDataFromCache(currentSuperPageNum);
		if(result != null) {
			if(isSuperRefresh) {
				if(!superAdapter.mSongUnitList.isEmpty()) {
					if(result.size() != 0) {
						superAdapter.mSongUnitList.clear();
					}
				}
			}
			KuwoLog.i(TAG, "super list size="+result.size());
			List<SongUnit> songUnitList = createSongUnitList(result, Constants.FLAG_SUPER_STAR, mImageLoader);
			superAdapter.addSongUnitList(songUnitList);
			if(!isSuperLoadMore) {
				lv_square_super.setAdapter(superAdapter);
			}
			onSuperLoad();
		}
	}
	
	//==================================================================================
	private Handler hotDataHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				List<MTV> result = (List<MTV>) msg.obj;
				if(result != null) {
					KuwoLog.i(TAG, "handleMessage【646】 hotList="+result);
					if(rl_square_hot_progress != null) {
						rl_square_hot_progress.setVisibility(View.INVISIBLE);
					}
					if(isHotRefresh) {
						if(!hotAdapter.mSongUnitList.isEmpty()) {
							if(result.size() != 0) {
								//有新数据
								hotAdapter.mSongUnitList.clear();
							}else {
								//没有新数据
								Toast.makeText(mActivity, "没有新数据", 0).show();
							}
						}
					}
					List<SongUnit> songUnitList = createSongUnitList(result, Constants.FLAG_HOT_MTV, mImageLoader);
					hotAdapter.addSongUnitList(songUnitList);
					if(!isHotLoadMore) {
						lv_square_hot.setAdapter(hotAdapter);
					}
					onHotLoad();
				}
				
				break;
			case 1:
				rl_square_hot_progress.setVisibility(View.INVISIBLE);
				if(lv_square_hot != null && rl_square_hot_no_network != null) {
					lv_square_hot.setVisibility(View.INVISIBLE);
					rl_square_hot_no_network.setVisibility(View.VISIBLE);
					iv_square_hot_no_network.setImageResource(R.drawable.fail_fetchdata);
				}
				break;

			default:
				break;
			}
		}
		
	};
	
	public void clearDisplayedImages() {
		AnimateFirstDisplayListener.displayedImages.clear();
	}
	
	private void onHotLoad() {
		lv_square_hot.stopRefresh();
		isHotRefresh = false;
		lv_square_hot.stopLoadMore();
		isHotLoadMore = false;
		SimpleDateFormat dateFormatter = new SimpleDateFormat("yy-MM-dd HH:mm:ss");
		String time = dateFormatter.format(new Date());
		lv_square_hot.setRefreshTime(time);
	}
	
//	class HotAdapter1 extends BaseAdapter {
//		private List<MTV> mMtvs;
//		private ImageLoadingListener animateFirstListener = new AnimateFirstDisplayListener();
//		
//		public HotAdapter() {
//		}
//		
//		public void add() {
//			
//		}
//
//		@Override
//		public int getCount() {
//			return mMtvs.size()/6 + 1;
//		}
//
//		@Override
//		public Object getItem(int position) {
//			return mMtvs.get(position*6);
//		}
//
//		@Override
//		public long getItemId(int position) {
//			return position;
//		}
//
//		@Override
//		public View getView(int position, View convertView, ViewGroup parent) {
//			
//			View v = 
//			
//			for (int i = position*6; i < (position+1)*6; i++) {
//				
//			}
//			
//			
//			mMtvs.get();
//			
//			SongUnit songUnit = mSongUnitList.get(position);
//			songUnit.displayImage(animateFirstListener);
//			return songUnit.getView();
//		}
//		
//	}

	
	class HotAdapter extends BaseAdapter {
		public List<SongUnit> mSongUnitList = new ArrayList<SongUnit>();
		private ImageLoadingListener animateFirstListener = new AnimateFirstDisplayListener();
		
		public void addSongUnitList(List<SongUnit> songUnitList) {
			mSongUnitList.addAll(songUnitList);
			notifyDataSetChanged();
		}

		@Override
		public int getCount() {
			return mSongUnitList.size();
		}

		@Override
		public Object getItem(int position) {
			return mSongUnitList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			SongUnit songUnit = mSongUnitList.get(position);
			songUnit.displayImage(animateFirstListener);
			return songUnit.getView();
		}
		
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
	
	private Handler newDataHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				List<MTV> result = (List<MTV>) msg.obj;
				if(result != null) {
					if(rl_square_new_progress != null) {
						rl_square_new_progress.setVisibility(View.INVISIBLE);
					}
					if(isNewRefresh) {
						if(!newAdapter.mSongUnitList.isEmpty()) {
							if(result.size() != 0) {
								newAdapter.mSongUnitList.clear();
							}else {
								Toast.makeText(mActivity, "没有新数据", 0).show();
							}
						}
					}
					List<SongUnit> songUnitList = createSongUnitList(result, Constants.FLAG_NEW_MTV, mImageLoader);
					newAdapter.addSongUnitList(songUnitList);
					if(!isNewLoadMore) {
						lv_square_new.setAdapter(newAdapter);
					}
					onNewLoad();
				}
				
				break;
			case 1:
				rl_square_new_progress.setVisibility(View.INVISIBLE);
				if(lv_square_new != null && rl_square_new_no_network != null) {
					lv_square_new.setVisibility(View.INVISIBLE);
					rl_square_new_no_network.setVisibility(View.VISIBLE);
					iv_square_new_no_network.setImageResource(R.drawable.fail_fetchdata);
				}
				break;

			default:
				break;
			}
		}
		
	};
	
	
	private void onNewLoad() {
		lv_square_new.stopRefresh();
		isNewRefresh = false;
		lv_square_new.stopLoadMore();
		isNewLoadMore = false;
		SimpleDateFormat dateFormatter = new SimpleDateFormat("yy-MM-dd HH:mm:ss");
		String time = dateFormatter.format(new Date());
		lv_square_new.setRefreshTime(time);
	}
	
	class NewAdapter extends BaseAdapter {
		public List<SongUnit> mSongUnitList = new ArrayList<SongUnit>();
		private ImageLoadingListener animateFirstListener = new AnimateFirstDisplayListener();
		
		public void addSongUnitList(List<SongUnit> songUnitList) {
			mSongUnitList.addAll(songUnitList);
			notifyDataSetChanged();
		}

		@Override
		public int getCount() {
			return mSongUnitList.size();
		}

		@Override
		public Object getItem(int position) {
			return mSongUnitList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			SongUnit songUnit =  mSongUnitList.get(position);
			songUnit.displayImage(animateFirstListener);
			return songUnit.getView();
		}
		
	}
	
	private Handler superDataHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				List<MTV> result = (List<MTV>) msg.obj;
				if(result != null) {
					if(rl_square_super_progress != null) {
						rl_square_super_progress.setVisibility(View.INVISIBLE);
					}
					if(isSuperRefresh) {
						if(!superAdapter.mSongUnitList.isEmpty()) {
							if(result.size() != 0) {
								superAdapter.mSongUnitList.clear();
							}else {
								Toast.makeText(mActivity, "没有新数据", 0).show();
							}
						}
					}
					List<SongUnit> songUnitList = createSongUnitList(result, Constants.FLAG_SUPER_STAR, mImageLoader);
					superAdapter.addSongUnitList(songUnitList);
					if(!isSuperLoadMore) {
						lv_square_super.setAdapter(superAdapter);
					}
					onSuperLoad();
				}
				break;
			case 1:
				rl_square_super_progress.setVisibility(View.INVISIBLE);
				if(lv_square_super != null && rl_square_super_no_network != null) {
					lv_square_super.setVisibility(View.INVISIBLE);
					rl_square_super_no_network.setVisibility(View.VISIBLE);
					iv_square_super_no_network.setImageResource(R.drawable.fail_fetchdata);
				}
				break;
			default:
				break;
			}
		}
		
	};
	
	private void onSuperLoad() {
		lv_square_super.stopRefresh();
		isSuperRefresh = false;
		lv_square_super.stopLoadMore();
		isSuperLoadMore = false;
		SimpleDateFormat dateFormatter = new SimpleDateFormat("yy-MM-dd HH:mm:ss");
		String time = dateFormatter.format(new Date());
		lv_square_super.setRefreshTime(time);
	}
	
	class SuperAdapter extends BaseAdapter {
		public List<SongUnit> mSongUnitList = new ArrayList<SongUnit>();
		private ImageLoadingListener animateFirstListener = new AnimateFirstDisplayListener();
		
		
		public void addSongUnitList(List<SongUnit> songUnitList) {
			mSongUnitList.addAll(songUnitList);
			notifyDataSetChanged();
		}

		@Override
		public int getCount() {
			return mSongUnitList.size();
		}

		@Override
		public Object getItem(int position) {
			return mSongUnitList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			SongUnit songUnit = mSongUnitList.get(position);
			songUnit.displayImage(animateFirstListener);
			return songUnit.getView();
		}
		
	}
	
	private List<SongUnit> createSongUnitList(List<MTV> result, int flag, ImageLoader imageLoader) {
		List<SongUnit> songUnitList = new ArrayList<SongUnit>();
		int songUnitCount = result.size()/6; //	30/6 = 5
		for(int i = 0; i <= songUnitCount-1; i++) { // 0--4
			List<MTV> mtvList = new ArrayList<MTV>();
			for(int j = 0; j <= 5; j++) {
				mtvList.add(result.get(i*6+j));
			}
			SongUnit songUnit = new SongUnit(mActivity, i, mtvList, flag, imageLoader);
			songUnitList.add(songUnit);
		}
		return songUnitList;
	}

	/*
	 * 点击事件
	 */
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			int id = v.getId();
			// 切换场景
			switchScene(id);
		}
	};
	
	private void switchScene(int id) {
		square_hot_songs.setBackgroundResource(R.drawable.song_top_new_songs_selector);
		square_famous.setBackgroundResource(R.drawable.song_top_rank_songs_selector);
		square_lattest_songs.setBackgroundResource(R.drawable.song_top_singer_songs_selector);
//
//		// 改变按钮背景
//		switch (id) {
//		case R.id.square_hot_songs: // 热门作品
//			square_hot_songs.setBackgroundResource(R.drawable.song_top_btn_pressed);
//			loadHotView();
//			break;
//		case R.id.square_lattest_songs: // 最新作品
//			square_lattest_songs.setBackgroundResource(R.drawable.song_top_btn_pressed);
//			loadNewView();
//			break;
//		case R.id.square_famous: // K歌达人
//			square_famous.setBackgroundResource(R.drawable.song_top_btn_pressed);
//			loadSuperView();
//			break;
//		}
	}
}
