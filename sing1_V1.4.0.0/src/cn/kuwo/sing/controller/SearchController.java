/**

 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.Stack;

import com.umeng.analytics.MobclickAgent;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AbsListView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.bean.SearchResult;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.business.MusicBusiness;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.db.MusicDao;
import cn.kuwo.sing.logic.DownloadLogic;
import cn.kuwo.sing.logic.MusicListLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.compatibility.ProgressButtonView;
import cn.kuwo.sing.util.DialogUtils;
import cn.kuwo.sing.util.lyric.Lyric;
import cn.kuwo.sing.widget.KuwoListView;
import cn.kuwo.sing.widget.KuwoListView.KuwoListViewListener;

/**
 * @Package cn.kuwo.sing.controller
 * 
 * @Date 2012-12-12, 下午4:44:59, 2012
 * 
 * @Author wangming
 * 
 */
public class SearchController extends BaseController {
	private final String TAG = "SearchController";
	private BaseActivity mActivity;
	private Button bt_search_back;
	private Button bt_search;
	private EditText et_search;
	private TextView tv_search_num_tips;
	private KuwoListView lv_search_list;
	private int currentPageNum = 0;
	private String lastContent;
	private DownloadLogic downloadLogic;
	private RelativeLayout rl_search_progress;
	public boolean tipFlag = true;// 决定是否要进行搜索词联想
	private boolean isBottom;
	private boolean isLoadMore;
	private List<Music> totalSearchResult = new ArrayList<Music>();
	private SearchResultAdapter mSearchResultAdapter;
	private String searchcontent;
	private Button clearBT;
	private RelativeLayout clearRL;
	private SearchHistoryAdapter historyAdapter;
	private ImageView search_clear;

	public SearchController(BaseActivity activity) {
		KuwoLog.d(TAG, "SearchController");
		mActivity = activity;
		if (Config.getPersistence().musicCancelMap == null) {
			Config.getPersistence().musicCancelMap = new HashMap<String, Boolean>();
			Config.savePersistence();
		}
		initView();
		downloadLogic = new DownloadLogic(mActivity);
		DownloadController downloadController = new DownloadController(mActivity, downloadLogic, progressUpdateHandler, refreshPBVStateHandler);
		downloadLogic.setOnDownloadListener(downloadController);
		downloadLogic.setOnManagerListener(downloadController);
	}

	private void initView() {
		bt_search_back = (Button) mActivity.findViewById(R.id.bt_search_back);
		bt_search_back.setOnClickListener(mOnClickListener);
		bt_search = (Button) mActivity.findViewById(R.id.bt_search);
		bt_search.setOnClickListener(mOnClickListener);
		et_search = (EditText) mActivity.findViewById(R.id.et_search);
		et_search.addTextChangedListener(mEditTextWatcher);
		search_clear = (ImageView) mActivity.findViewById(R.id.search_clear);
		search_clear.setVisibility(View.INVISIBLE);
		search_clear.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				et_search.setText("");
				tv_search_num_tips.setVisibility(View.GONE);
				lv_search_list.setVisibility(View.VISIBLE);
				loadSearchHistory();
			}
		});
		lv_search_list = (KuwoListView) mActivity.findViewById(R.id.lv_search_list);
		mSearchResultAdapter = new SearchResultAdapter(totalSearchResult);
		lv_search_list.setPullLoadEnable(true);
		lv_search_list.setPullRefreshEnable(false);
		lv_search_list.setKuwoListViewListener(new KuwoListViewListener() {

			@Override
			public void onRefresh() {

			}

			@Override
			public void onLoadMore() {
				if (isBottom) {
					lv_search_list.setNoDataStatus(true);
					lv_search_list.getFooterView().hide();
					return;
				}
				isLoadMore = true;
				loadSearchResult(++currentPageNum);
			}
		});
		lv_search_list.setOnScrollListener(new OnScrollListener() {

			@Override
			public void onScrollStateChanged(AbsListView view, int scrollState) {
				switch (scrollState) {
				case OnScrollListener.SCROLL_STATE_FLING:
					break;
				case OnScrollListener.SCROLL_STATE_TOUCH_SCROLL:
					// 隐藏键盘
					InputMethodManager imm = (InputMethodManager) mActivity.getSystemService(Context.INPUT_METHOD_SERVICE);
					imm.hideSoftInputFromWindow(et_search.getWindowToken(), 0);
					break;
				case OnScrollListener.SCROLL_STATE_IDLE:
					break;
				}
			}

			@Override
			public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {

			}
		});
		tv_search_num_tips = (TextView) mActivity.findViewById(R.id.tv_search_num_tips);
		tv_search_num_tips.setVisibility(View.GONE);
		rl_search_progress = (RelativeLayout) mActivity.findViewById(R.id.rl_search_progress);
		rl_search_progress.setVisibility(View.INVISIBLE);
		loadSearchHistory();
	}

	private void loadSearchHistory() {
		Stack<String> searchHistory = Config.getPersistence().searchHistory;
		if (searchHistory == null || searchHistory.size() == 0) {
			return;
		}
		List<String> searchList = new ArrayList<String>();
		for (String str : searchHistory) {
			System.out.println("searchHistory=" + searchHistory);
			searchList.add(str);
		}
		Collections.reverse(searchList);
		historyAdapter = new SearchHistoryAdapter(searchList);
		lv_search_list.setNoDataStatus(true);
		lv_search_list.getFooterView().hide();
		clearBT = new Button(mActivity);
		clearBT.setText("清空搜索历史");
		clearBT.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Config.getPersistence().searchHistory.removeAllElements();
				Config.savePersistence();
				historyAdapter.clearHistory();
				clearBT.setVisibility(View.GONE);
			}
		});
		if (clearRL != null) {
			lv_search_list.removeFooterView(clearRL);
		}
		clearRL = new RelativeLayout(mActivity);
		RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
		clearRL.addView(clearBT, params);
		lv_search_list.addFooterView(clearRL); // add footer view
		lv_search_list.setAdapter(historyAdapter);
	}

	private class SearchHistoryAdapter extends BaseAdapter {
		private List<String> mHistoryList;

		public SearchHistoryAdapter(List<String> searchHistory) {
			mHistoryList = searchHistory;
		}

		public void clearHistory() {
			if (mHistoryList != null) {
				mHistoryList.clear();
				notifyDataSetChanged();
			}
		}

		@Override
		public boolean isEnabled(int position) {
			return false;
		}

		@Override
		public int getCount() {
			return mHistoryList.size();
		}

		@Override
		public Object getItem(int position) {
			return mHistoryList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(final int position, View convertView, ViewGroup parent) {
			View view = null;
			HistoryViewHolder viewHolder = null;
			if (convertView == null) {
				view = View.inflate(mActivity, R.layout.search_history_item, null);
				viewHolder = new HistoryViewHolder();
				viewHolder.tv_search_history_song_name = (TextView) view.findViewById(R.id.tv_search_history_song_name);
				viewHolder.iv_search_history_song_delete = (ImageView) view.findViewById(R.id.iv_search_history_song_delete);
				view.setTag(viewHolder);
			} else {
				view = convertView;
				viewHolder = (HistoryViewHolder) view.getTag();
			}
			final String str = mHistoryList.get(position);
			viewHolder.tv_search_history_song_name.setText(str);
			viewHolder.tv_search_history_song_name.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					tipFlag = false;
					// 隐藏键盘
					InputMethodManager imm = (InputMethodManager) mActivity.getSystemService(Context.INPUT_METHOD_SERVICE);
					imm.hideSoftInputFromWindow(et_search.getWindowToken(), 0);
					et_search.setText(str);
					et_search.setSelection(str.length());
					totalSearchResult.clear();
					isBottom = false;
					currentPageNum = 0;
					startSearchResultThread(str, 0, 20);
					tipFlag = true;
				}
			});
			viewHolder.iv_search_history_song_delete.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					mHistoryList.remove(position);
					Config.getPersistence().searchHistory.remove(str);
					Config.savePersistence();
					notifyDataSetChanged();
					if (mHistoryList.size() == 0) {
						if (clearRL != null) {
							lv_search_list.removeFooterView(clearRL);
						}
					}
				}
			});
			return view;
		}
	}

	static class HistoryViewHolder {
		TextView tv_search_history_song_name;
		ImageView iv_search_history_song_delete;
	}

	private TextWatcher mEditTextWatcher = new TextWatcher() {

		@Override
		public void onTextChanged(CharSequence s, int start, int before, int count) {

		}

		@Override
		public void beforeTextChanged(CharSequence s, int start, int count, int after) {
		}

		@Override
		public void afterTextChanged(Editable s) {
			KuwoLog.i(TAG, "输入内容后：" + s.toString());
			if (s.toString().length() == 0) {
				search_clear.setVisibility(View.INVISIBLE);
				loadSearchHistory();
				return;
			} else {
				search_clear.setVisibility(View.VISIBLE);
			}
			if (tipFlag) {
				// 发送搜索请求
				lv_search_list.setVisibility(View.VISIBLE);
				tv_search_num_tips.setVisibility(View.GONE);
				loadSearchTip(s.toString());
			}

		}
	};

	private void loadSearchTip(String content) {
		if (content.equals(lastContent)) {
			return;
		}
		lastContent = content;
		startSearchTipThread(content);
	}

	private void loadSearchResult(int currentPageNum) {
		startSearchResultThread(et_search.getText().toString(), currentPageNum, 20);
	}

	private void startSearchTipThread(final String content) {
		// rl_search_progress.setVisibility(View.VISIBLE);
		new Thread(new Runnable() {

			@Override
			public void run() {
				MusicListLogic logic = new MusicListLogic();
				List<HashMap<String, String>> result = null;
				try {
					result = logic.getSearchTips(content);
				} catch (IOException e) {
					KuwoLog.printStackTrace(e);
				}
				Message msg = searchTipHandler.obtainMessage();
				msg.what = 0;
				msg.obj = result;
				searchTipHandler.sendMessage(msg);

			}
		}).start();

	}

	private Handler searchTipHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				final List<HashMap<String, String>> result = (List<HashMap<String, String>>) msg.obj;
				// rl_search_progress.setVisibility(View.INVISIBLE);
				if (result == null) {
					return;
				}
				KuwoLog.i(TAG, "search tip:" + result);
				SearchTipAdapter adapter = new SearchTipAdapter(result);
				lv_search_list.setAdapter(adapter);
				lv_search_list.setNoDataStatus(true);
				lv_search_list.getFooterView().hide();
				lv_search_list.removeFooterView(clearRL);
				lv_search_list.setOnTouchListener(new OnTouchListener() {

					@Override
					public boolean onTouch(View v, MotionEvent event) {
						// 隐藏键盘
						InputMethodManager imm = (InputMethodManager) mActivity.getSystemService(Context.INPUT_METHOD_SERVICE);
						imm.hideSoftInputFromWindow(et_search.getWindowToken(), 0);
						return false;
					}
				});
				lv_search_list.setOnItemClickListener(new OnItemClickListener() {

					@Override
					public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
						tipFlag = false;
						// 隐藏键盘
						InputMethodManager imm = (InputMethodManager) mActivity.getSystemService(Context.INPUT_METHOD_SERVICE);
						imm.hideSoftInputFromWindow(et_search.getWindowToken(), 0);

						HashMap<String, String> map = result.get(position - 1);
						String content = map.get("RELWORD");
						et_search.setText(content);
						et_search.setSelection(content.length());
						totalSearchResult.clear();
						searchcontent = content;
						if (AppContext.getNetworkSensor().hasAvailableNetwork()) {
							isBottom = false;
							currentPageNum = 0;
							if (Config.getPersistence().searchHistory == null) {
								Config.getPersistence().searchHistory = new Stack<String>();
								Config.savePersistence();
							}
							Config.getPersistence().searchHistory.remove(content);
							Config.getPersistence().searchHistory.push(content);
							while (Config.getPersistence().searchHistory.size() > 10) {
								Config.getPersistence().searchHistory.remove(0);
							}
							Config.savePersistence();
							startSearchResultThread(content, 0, 20);
						} else {
							Toast.makeText(mActivity, "网络不通请稍后再试", 0).show();
						}
						tipFlag = true;
					}
				});
				break;

			default:

				break;
			}
		}

	};

	class SearchTipAdapter extends BaseAdapter {
		private List<HashMap<String, String>> mMusicList;

		public SearchTipAdapter(List<HashMap<String, String>> musicList) {
			mMusicList = musicList;
		}

		@Override
		public int getCount() {
			return mMusicList.size();
		}

		@Override
		public Object getItem(int position) {
			return mMusicList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View view = null;
			TipViewHolder viewHolder = null;
			if (convertView == null) {
				view = View.inflate(mActivity, R.layout.search_tip_item, null);
				viewHolder = new TipViewHolder();
				viewHolder.songNameTV = (TextView) view.findViewById(R.id.tv_search_tip_song);
				view.setTag(viewHolder);
			} else {
				view = convertView;
				viewHolder = (TipViewHolder) view.getTag();
			}
			HashMap<String, String> map = mMusicList.get(position);
			viewHolder.songNameTV.setText(map.get("RELWORD"));
			return view;
		}

	}

	static class TipViewHolder {
		TextView songNameTV;
	}

	private Handler searchResultHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				SearchResult searchResult = (SearchResult) msg.obj;
				if (searchResult != null) {
					MobclickAgent.onEvent(mActivity, "KS_SEARCH_MUSIC", "1");
					List<Music> result = searchResult.musicList;
					rl_search_progress.setVisibility(View.INVISIBLE);
					lv_search_list.removeFooterView(clearRL);
					if (result == null)
						return;
					if (currentPageNum == 0 && result.size() == 0) {
						lv_search_list.setVisibility(View.INVISIBLE);
						tv_search_num_tips.setVisibility(View.VISIBLE);
						tv_search_num_tips.setText("很抱歉，没有找到与" + " \"" + searchcontent + "\" " + "相关的结果");
						onLoad();
						return;
					}
					if (result.size() < 20) {
						isBottom = true;
						lv_search_list.setNoDataStatus(true);
						lv_search_list.getFooterView().hide();
					} else {
						lv_search_list.getFooterView().show();
					}
					lv_search_list.setVisibility(View.VISIBLE);
					tv_search_num_tips.setVisibility(View.VISIBLE);
					tv_search_num_tips.setText("共找到" + "\"" + searchcontent + "\"" + "相关结果" + searchResult.resultNum + "条");
					totalSearchResult.addAll(result);
					totalSearchResult = removeDuplicateWithOrder(totalSearchResult);
					mSearchResultAdapter.setMusicList(totalSearchResult);
					if (isLoadMore) {
						mSearchResultAdapter.notifyDataSetChanged();
					} else {
						lv_search_list.setAdapter(mSearchResultAdapter);
					}
					onLoad();
				} else {
					if (!AppContext.getNetworkSensor().hasAvailableNetwork() && currentPageNum != 0) {
						Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
						onLoad();
					}else {
						MobclickAgent.onEvent(mActivity, "KS_SEARCH_MUSIC", "0");
					}
				}
				break;

			default:
				break;
			}
		}

	};

	private List removeDuplicateWithOrder(List<Music> list) {
		Set set = new HashSet();
		List<Music> newList = new ArrayList<Music>();
		for (Iterator<Music> iter = list.iterator(); iter.hasNext();) {
			Music element = iter.next();
			if (set.add(element))
				newList.add(element);
		}
		return newList;
	}

	private void onLoad() {
		lv_search_list.stopLoadMore();
		isLoadMore = false;
	}

	class SearchResultAdapter extends BaseAdapter {
		private List<Music> mMusicList;

		public SearchResultAdapter(List<Music> musicList) {
			mMusicList = musicList;
		}

		public void setMusicList(List<Music> musicList) {
			mMusicList = musicList;
		}

		@Override
		public int getCount() {
			return mMusicList.size();
		}

		@Override
		public boolean isEnabled(int position) {
			return false;
		}

		@Override
		public Object getItem(int position) {
			return mMusicList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View view = null;
			final ResultViewHolder viewHolder;
			if (convertView == null) {
				view = View.inflate(mActivity, R.layout.song_list_item, null);
				viewHolder = new ResultViewHolder();
				viewHolder.songNameTV = (TextView) view.findViewById(R.id.tv_song_list_item_name);
				viewHolder.artistTV = (TextView) view.findViewById(R.id.tv_song_list_item_artist);
				viewHolder.progressView = (ProgressButtonView) view.findViewById(R.id.pbv_song_list_view_progress);
				view.setTag(viewHolder);
			} else {
				view = convertView;
				viewHolder = (ResultViewHolder) view.getTag();
			}
			final Music music = mMusicList.get(position);

			viewHolder.songNameTV.setText(music.getName());
			viewHolder.artistTV.setText(music.getArtist());
			viewHolder.progressView.setForeground(mActivity.getResources().getDrawable(R.drawable.download_progress));
			viewHolder.progressView.setTag(music.getId() + "_progressView");

			int downloadStatus = downloadLogic.getMusicDownloadStatus(mActivity, music.getId());
			if (downloadStatus == Constants.DOWNLOAD_STATUS_UNDWONLOAD) {
				MusicDao musicDao = new MusicDao(mActivity);
				Music m = musicDao.getMusic(music.getId());
				if (m != null) {
					KuwoLog.i("DownloadStatus", "0%等待下载");
					viewHolder.progressView.setText("0%");
					viewHolder.progressView.setPercent(0);
					viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
					viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress)); // 橙色
				} else {
					KuwoLog.i("DownloadStatus", "未下载");
					viewHolder.progressView.setText("点歌");
					viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song__list_order)); // 蓝色
					viewHolder.progressView.setBackgroundResource(R.drawable.order_song_normal);
					viewHolder.progressView.setPercent(0);
				}
			} else if (downloadStatus == Constants.DOWNLOAD_STATUS_ISDOWNLOADING) {
				KuwoLog.i("DownloadStatus", "正在下载中...");
				int progress = downloadLogic.computeProgress(music.getId());
				if (progress == -1) {
					// 暂停状态
					MusicDao musicDao = new MusicDao(mActivity);
					Music pauseMusic = musicDao.getMusic(music.getId());
					if (pauseMusic != null) {
						int pauseProgress = downloadLogic.computeDownloadedBytes(music.getId());
						viewHolder.progressView.setText("暂停" + pauseProgress + "%");
						viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
						viewHolder.progressView.setPercent(pauseProgress);
						viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress));
					}
				} else {
					// 下载进行中状态
					if (progress == 100) {
						viewHolder.progressView.setText("演唱");
						viewHolder.progressView.setTextColor(Color.WHITE); // 白色
						viewHolder.progressView.setBackgroundResource(R.drawable.order_song_normal);
						viewHolder.progressView.setPercent(100);
					} else {
						viewHolder.progressView.setText(progress + "%");
						viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress)); // 橙色
						viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
						viewHolder.progressView.setPercent(progress);
					}
				}
			} else if (downloadStatus == Constants.DOWNLOAD_STATUS_COMPLEMENT) {
				KuwoLog.i("DownloadStatus", "已下载");
				viewHolder.progressView.setText("演唱");
				viewHolder.progressView.setTextColor(Color.WHITE); // 白色
				viewHolder.progressView.setBackgroundResource(R.drawable.order_song_normal);
				viewHolder.progressView.setPercent(100);
			}

			viewHolder.progressView.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					Intent orderChangeIntent = new Intent();
					orderChangeIntent.setAction("cn.kuwo.sing.order.change");
					mActivity.sendBroadcast(orderChangeIntent);
					int downloadedStatus = downloadLogic.getMusicDownloadStatus(mActivity, music.getId());
					if (AppContext.getNetworkSensor().hasAvailableNetwork()) {
						// 未下载状态
						if (downloadedStatus == Constants.DOWNLOAD_STATUS_UNDWONLOAD) {
							viewHolder.progressView.setText("0%");
							viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress)); // 橙色
							viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
							viewHolder.progressView.setPercent(0);
							if (AppContext.getNetworkSensor().isApnActive()) {
								if (!Constants.isSongMobileStateActivited) {
									Constants.isSongMobileStateActivited = true;
									showApnTipDialog("您当前使用的是2G/3G网络，点歌将产生一定的流量", music); // 点击确定，就会添加任务,否则变为点歌状态
								} else {
									downloadLogic.addOriginalAndAccompTask(mActivity, music);
									startDownloadLyricThread(music);
								}
							} else {
								downloadLogic.addOriginalAndAccompTask(mActivity, music); // 添加任务
								startDownloadLyricThread(music);
							}
							// 下载中状态
						} else if (downloadedStatus == Constants.DOWNLOAD_STATUS_ISDOWNLOADING) {
							int progress = downloadLogic.computeProgress(music.getId());
							KuwoLog.i(TAG, "onClick is downloading==progress=" + progress);
							if (progress == -1) {
								// 暂停状态
								MusicDao musicDao = new MusicDao(mActivity);
								Music pauseMusic = musicDao.getMusic(music.getId());
								if (pauseMusic != null) {
									long totalBytes = pauseMusic.getTotal();
									if (totalBytes == 0) {
										viewHolder.progressView.setText("0%");
										viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress)); // 橙色
										viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
										viewHolder.progressView.setPercent(0);
									} else {
										int currentProgress = downloadLogic.computeDownloadedBytes(music.getId());
										viewHolder.progressView.setText(currentProgress + "%");
										viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress));
										viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
										viewHolder.progressView.setPercent(currentProgress);
									}
								}
								if (AppContext.getNetworkSensor().isApnActive()) {
									// apn网络,继续下载
									if (!Constants.isSongMobileStateActivited) {
										Constants.isSongMobileStateActivited = true;
										showApnTipDialog("您当前使用的是2G/3G网络，点歌将产生一定的流量", music);
									} else {
										downloadLogic.addOriginalAndAccompTask(mActivity, music);
										startDownloadLyricThread(music);
									}
								} else {
									// wifi下载
									downloadLogic.addOriginalAndAccompTask(mActivity, music);
									startDownloadLyricThread(music);
								}
							} else {
								// 正在下载中状态
								showCancelDownloadDialog(music.getId());
							}
							// 下载完状态
						} else if (downloadedStatus == Constants.DOWNLOAD_STATUS_COMPLEMENT) {
							MTVBusiness business = new MTVBusiness(mActivity);
							business.singMtv(music, MTVBusiness.MODE_AUDIO, null);
						}
					} else {
						if(downloadedStatus == Constants.DOWNLOAD_STATUS_COMPLEMENT) {
							MTVBusiness business = new MTVBusiness(mActivity);
							business.singMtv(music, MTVBusiness.MODE_AUDIO, null);
						}else {
							Toast.makeText(mActivity, "网络不通，您可以演唱本地歌曲", 0).show();
						}
					}
				}
			});

			return view;
		}
	}

	static class ResultViewHolder {
		TextView songNameTV;
		TextView artistTV;
		TextView albumTV;
		ProgressButtonView progressView;
	}

	private void startDownloadLyricThread(final Music music) {
		new Thread(new Runnable() {

			@Override
			public void run() {
				MusicBusiness mb = new MusicBusiness();
				try {
					Lyric lyric = mb.getLyric(music.getId(), Lyric.LYRIC_TYPE_KDTX);
					KuwoLog.i(TAG, "lyric=" + lyric);
					Message msg = lyricHandler.obtainMessage();
					msg.what = 0;
					msg.obj = lyric;
					lyricHandler.sendMessage(msg);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}).start();
	}

	private Handler lyricHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				Lyric lyric = (Lyric) msg.obj;
				if (lyric != null) {
					KuwoLog.i(TAG, "lyric=" + lyric + ",下载成功！");
				}
				break;

			default:
				break;
			}
		}

	};

	private Handler progressUpdateHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case Constants.MESSAGE_DOWNLOAD_PROGRESS:
				String musicId = msg.getData().getString("musicId");
				int progress = msg.getData().getInt("progress");
				ProgressButtonView pb = (ProgressButtonView) lv_search_list.findViewWithTag(musicId + "_progressView");
				if (pb != null) {
					if (progress == 100) {
						pb.setPercent(100);
						pb.setText("演唱");
						pb.setTextColor(Color.WHITE);
						pb.setBackgroundResource(R.drawable.order_song_normal);
					} else {
						if (progress == -1) {
							break;
						}
						pb.setText(progress + "%");
						pb.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress));
						pb.setBackgroundResource(R.drawable.order_song_pressed);
						pb.setPercent(progress);
					}
				}
				break;
			default:
				break;
			}
		}
	};

	private Handler refreshPBVStateHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case Constants.DOWNLOAD_FAILED: // (断网引起)暂停 onFail
				String musicId_failed = (String) msg.obj;
				int progress = downloadLogic.computeDownloadedBytes(musicId_failed);
				ProgressButtonView pbv_failed = (ProgressButtonView) lv_search_list.findViewWithTag(musicId_failed + "_progressView");
				if (pbv_failed != null) {
					pbv_failed.setText("暂停" + progress + "%");
					pbv_failed.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress));
					pbv_failed.setBackgroundResource(R.drawable.order_song_pressed);
				}
				break;
			case Constants.DOWNLOAD_CANCEL: // 取消 onCancel
				String musicId_cancel = (String) msg.obj;
				ProgressButtonView pbv_cancel = (ProgressButtonView) lv_search_list.findViewWithTag(musicId_cancel + "_progressView");
				if (pbv_cancel != null) {
					pbv_cancel.setText("点歌");
					pbv_cancel.setPercent(0);
					pbv_cancel.setTextColor(mActivity.getResources().getColor(R.color.bt_song__list_order));
					pbv_cancel.setBackgroundResource(R.drawable.order_song_normal);
				}
				break;
			default:
				break;
			}
		}

	};

	private void showCancelDownloadDialog(final String musicId) {
		DialogUtils.alert(mActivity, new DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					// ok
					// 取消下载
					KuwoLog.i(TAG, "dialog 取消的music id =" + musicId);
					downloadLogic.cancelDownloadMusic(mActivity, musicId);
					ProgressButtonView pbv = (ProgressButtonView) lv_search_list.findViewWithTag(musicId + "_progressView");
					if (pbv != null) {
						pbv.setText("点歌");
						pbv.setPercent(0);
						pbv.setTextColor(mActivity.getResources().getColor(R.color.bt_song__list_order));
						pbv.setBackgroundResource(R.drawable.order_song_normal);
						mSearchResultAdapter.notifyDataSetChanged();
					}
					dialog.dismiss();
					break;
				case -2:
					// cancel
					dialog.dismiss();
					break;
				default:
					break;
				}
			}
		}, R.string.logout_dialog_title, R.string.yes, -1, R.string.no, "是否要取消点歌？");

	}

	private void showApnTipDialog(String tip, final Music music) {
		DialogUtils.alert(mActivity, new DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					// ok
					downloadLogic.addOriginalAndAccompTask(mActivity, music);
					startDownloadLyricThread(music);
					dialog.dismiss();
					break;
				case -2:
					// cancel
					ProgressButtonView pbv = (ProgressButtonView) lv_search_list.findViewWithTag(music.getId() + "_progressView");
					if (pbv != null) {
						pbv.setText("点歌");
						pbv.setPercent(0);
						pbv.setTextColor(mActivity.getResources().getColor(R.color.bt_song__list_order));
						pbv.setBackgroundResource(R.drawable.order_song_normal);
					}
					dialog.dismiss();
					break;
				default:
					break;
				}

			}
		}, R.string.logout_dialog_title, R.string.dialog_ok, -1, R.string.dialog_cancel, tip);
	}

	private void startSearchResultThread(final String content, final int pageNum, final int pageSize) {
		if (!isLoadMore) {
			rl_search_progress.setVisibility(View.VISIBLE);
		}
		new Thread(new Runnable() {

			@Override
			public void run() {
				searchcontent = et_search.getText().toString();
				MusicListLogic logic = new MusicListLogic();
				SearchResult result = null;
				try {
					result = logic.getSearchResult(content, pageNum, pageSize);
				} catch (IOException e) {
					KuwoLog.printStackTrace(e);
				}
				Message msg = searchResultHandler.obtainMessage();
				msg.what = 0;
				msg.obj = result;
				searchResultHandler.sendMessage(msg);
			}
		}).start();
	}

	private View.OnClickListener mOnClickListener = new OnClickListener() {

		@Override
		public void onClick(View v) {
			int id = v.getId();
			switch (id) {
			case R.id.bt_search_back:
				mActivity.finish();
				break;

			case R.id.bt_search:
				searchcontent = et_search.getText() + "";
				if (AppContext.getNetworkSensor().hasAvailableNetwork()) {
					if (et_search.getText().length() == 0) {
						Toast.makeText(mActivity, "请输入关键词！", 0).show();
					} else {
						// 隐藏键盘
						InputMethodManager imm = (InputMethodManager) mActivity.getSystemService(Context.INPUT_METHOD_SERVICE);
						imm.hideSoftInputFromWindow(et_search.getWindowToken(), 0);
						if (Config.getPersistence().searchHistory == null) {
							Config.getPersistence().searchHistory = new Stack<String>();
							Config.savePersistence();
						}
						Config.getPersistence().searchHistory.remove(searchcontent);
						Config.getPersistence().searchHistory.push(searchcontent);
						while (Config.getPersistence().searchHistory.size() > 10) {
							Config.getPersistence().searchHistory.remove(0);
						}
						Config.savePersistence();
						totalSearchResult.clear();
						isBottom = false;
						currentPageNum = 0;
						startSearchResultThread(et_search.getText().toString(), 0, 20);
						tipFlag = true;
					}
				} else {
					Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
				}
				break;

			default:
				break;
			}
		}
	};
}