package cn.kuwo.sing.controller;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Field;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.umeng.analytics.MobclickAgent;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.Intent;
import android.graphics.Color;
import android.os.Handler;
import android.os.Message;
import android.os.Process;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.config.PreferencesManager;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.download.DownloadManager;
import cn.kuwo.framework.download.DownloadStat;
import cn.kuwo.framework.download.DownloadTask;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.bean.SquareShow;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.business.MusicBusiness;
import cn.kuwo.sing.context.App;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.db.MusicDao;
import cn.kuwo.sing.logic.DownloadLogic;
import cn.kuwo.sing.logic.MusicListLogic;
import cn.kuwo.sing.logic.MusicLogic;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.MainActivity;
import cn.kuwo.sing.ui.activities.SingActivity;
import cn.kuwo.sing.ui.compatibility.ProgressButtonView;
import cn.kuwo.sing.util.DialogUtils;
import cn.kuwo.sing.util.lyric.Lyric;
import cn.kuwo.sing.widget.KuwoListView;
import cn.kuwo.sing.widget.KuwoListView.KuwoListViewListener;

/**
 * 	歌曲列表
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2012-12-5, 上午9:54:07, 2012
 *
 * @Author wangming
 *
 */
public class SongSubListController extends BaseController implements KuwoListViewListener {
	private final String TAG = "SongSubListController";
	private BaseActivity mActivity;
	private Button bt_song_list_back;
	private TextView tv_song_list_title;
	private KuwoListView lv_song_list;
	private int currentPageNum = 0;
	private SubListAdapter mAdapter;
	private String listID;
	private boolean isRefresh = false;
	private boolean isLoadMore = false;
	private boolean isBottom = false;
	private String mFlag = null;
	private String mFromSquareActivity = null;
	private DownloadLogic downloadLogic;
	private RelativeLayout rl_song_list_progress;
	private RelativeLayout rl_song_list_no_network;
	private ImageView iv_song_list_no_network;
	private ProgressDialog pd;
	private boolean downloadFinished = false; 
	private DownloadLogic  downloadLogic2;
	
	public SongSubListController(BaseActivity activity) {
		KuwoLog.i(TAG, "SongSubListController");
		mActivity = activity;
		if(Config.getPersistence().musicCancelMap == null) {
			Config.getPersistence().musicCancelMap = new HashMap<String, Boolean>();
			Config.savePersistence();
		}
		initView();
		downloadLogic = new DownloadLogic(mActivity);
		DownloadController downloadController = new DownloadController(mActivity, downloadLogic, progressUpdateHandler, refreshPBVStateHandler);
		downloadLogic.setOnDownloadListener(downloadController);
		downloadLogic.setOnManagerListener(downloadController);
		loadSubList(0, 20);
	}
	
	private void initView() {
		bt_song_list_back = (Button) mActivity.findViewById(R.id.bt_song_list_back);
		bt_song_list_back.setOnClickListener(mOnClickListener);
		rl_song_list_progress = (RelativeLayout) mActivity.findViewById(R.id.rl_song_list_progress);
		tv_song_list_title = (TextView) mActivity.findViewById(R.id.tv_song_list_title);
		lv_song_list = (KuwoListView) mActivity.findViewById(R.id.lv_song_list);
		rl_song_list_no_network = (RelativeLayout) mActivity.findViewById(R.id.rl_song_list_no_network);
		rl_song_list_no_network.setVisibility(View.INVISIBLE);
		rl_song_list_no_network.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				rl_song_list_no_network.setVisibility(View.INVISIBLE);
				lv_song_list.setVisibility(View.VISIBLE);
				loadSubList(0, 20);
			}
		});
		iv_song_list_no_network = (ImageView) mActivity.findViewById(R.id.iv_song_list_no_network);
		lv_song_list.setPullLoadEnable(true);
		lv_song_list.setPullRefreshEnable(true);
		lv_song_list.setKuwoListViewListener(this);
		
		Intent intent = mActivity.getIntent();
		mFlag = intent.getStringExtra("flag");
		mFromSquareActivity = intent.getStringExtra("fromSquareActivity");
		listID = intent.getStringExtra("listID");
		String subTitle = intent.getStringExtra("subTitle");
		tv_song_list_title.setText(subTitle);
		mAdapter = new SubListAdapter();
		
		App app = (App) mActivity.getApplication();
		String rid = app.ridFromKwPlayer;
		String artist = app.artistFromKwPlayer;
		String title = app.songNameFromKwPlayer;
		if(mFromSquareActivity != null && !TextUtils.isEmpty(rid)) { 
			showDownloadSquareMusicDialog(rid, artist, title);
		}
	}
	
	private void showNoNetwork() {
		lv_song_list.setVisibility(View.INVISIBLE);
		rl_song_list_no_network.setVisibility(View.VISIBLE);
		iv_song_list_no_network.setImageResource(R.drawable.fail_network);
	}
	
	private void showNoData() {
		lv_song_list.setVisibility(View.INVISIBLE);
		rl_song_list_no_network.setVisibility(View.VISIBLE);
		iv_song_list_no_network.setImageResource(R.drawable.fail_fetchdata);
	}
	
	
	private void loadSubList(final int pageNum, final int size) {
		List<Music> result = getSubListFromCache(pageNum, size);
		if(result != null) {
			if(isRefresh) {
				if(!mAdapter.mSubList.isEmpty()) {
					mAdapter.mSubList.clear();
				}
			}
			
			if(result.size() < size) { 
				isBottom = true;
				lv_song_list.setNoDataStatus(true);
				lv_song_list.getFooterView().hide();
			}else {
				lv_song_list.getFooterView().show();
			}
			mAdapter.addMusicList(result);
			if(!isLoadMore) {
				lv_song_list.setAdapter(mAdapter);
			}
			onLoad();
		}else {
			if(!AppContext.getNetworkSensor().hasAvailableNetwork() && currentPageNum == 0) {
				showNoNetwork();
			}
		}
	}
	
	private void showDownloadSquareMusicDialog(String rid, String artist, String title) {
		MusicLogic musicLogic = new MusicLogic();
    	File originalFile = musicLogic.getOriginalFile(rid);
		File accomFile = musicLogic.getAccompanyFile(rid);
		final Music music = new Music();
		music.setId(rid);
		music.setArtist(artist);
		music.setName(title);
		if(originalFile == null || accomFile == null) {
			downloadMusicResource(music);
		}else {
			showDownloadedDialog(music);
		}
	}
	
	private void showDownloadedDialog(final Music music) {
		AlertDialog.Builder builder = new AlertDialog.Builder(mActivity);
		builder.setMessage(music.getName()+"【"+music.getArtist()+"】 资源已存在，现在就去演唱？");
		builder.setNegativeButton("演唱", new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				MTVBusiness business = new MTVBusiness(mActivity);
				business.singMtv(music, MTVBusiness.MODE_AUDIO, mFromSquareActivity);
				dialog.dismiss();
			}
		});
		builder.create().show();
	}
	private void downloadMusicResource(final Music music) {
		downloadFinished = false;
		Config.getPersistence().musicCancelMap.put(music.getId(), false);
		Config.savePersistence();
		pd = new ProgressDialog(mActivity);
		pd.setMessage(music.getName()+"	 "+music.getArtist());
		pd.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
		pd.setButton(DialogInterface.BUTTON_NEGATIVE, "取消", new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				if(downloadFinished) {
					dialog.dismiss();
					MTVBusiness business = new MTVBusiness(mActivity);
					business.singMtv(music, MTVBusiness.MODE_AUDIO, mFromSquareActivity);
				}else {
					//换首歌[取消任务]
					Config.getPersistence().musicCancelMap.put(music.getId(), true);
					Config.savePersistence();
					if(downloadLogic != null) {
						downloadLogic.cancelDownloadMusic(mActivity, music.getId());
					}
					dialog.dismiss();
				}
			}
		});
		pd.setOnCancelListener(new OnCancelListener() {
			
			@Override
			public void onCancel(DialogInterface dialog) {
				resetAppParamsFromKwPlayer();
			}
		});
		pd.setCancelable(true);
		pd.setCanceledOnTouchOutside(false);
		pd.show();
		try {
		       	 Class<?> clazz = ProgressDialog.class;
		       	 TextView nullText = new TextView(mActivity);
		       	 nullText.setText("");
		       	 Field field = clazz.getDeclaredField("mProgressNumber");
		       	 field.setAccessible(true);
				 field.set(pd, nullText);
			} catch (Exception e) {
				KuwoLog.printStackTrace(e);
			}
		
		//下载伴奏文件
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				String[] result = new String[2];
				MusicLogic logic = new MusicLogic();
				result[0] = logic.getMusicUrl(music.getId());
				result[1] = logic.getAccompanimentUrl(music.getId());
				Message msg = downloadMusicHandler2.obtainMessage();
				msg.what = 0;
				msg.obj = result;
				msg.getData().putSerializable("music", music);
				downloadMusicHandler2.sendMessage(msg);
			}
			
		}).start();
	}
	
	public void resetAppParamsFromKwPlayer() {
		App app = (App) mActivity.getApplication();
		app.albumFromKwPlayer = null;
		app.artistFromKwPlayer = null;
		app.ridFromKwPlayer = null;
		app.songNameFromKwPlayer = null;
		app.sourceFromKwPlayer = null;
	}
	
	private Handler downloadMusicHandler2 = new Handler() {
		
		@Override
		public void handleMessage(Message msg) {
			switch(msg.what) {
			case 0:
				KuwoLog.i(TAG, "【获取音乐伴奏防盗链地址成功！】");
				String[] result = (String[])msg.obj;
				KuwoLog.i(TAG, "result[0]="+result[0]);
				KuwoLog.i(TAG, "result[1]="+result[1]);
				final Music currentMusic = (Music) msg.getData().getSerializable("music");
				downloadLogic2 = new DownloadLogic(false, mActivity);
				new Thread(new Runnable() {
					
					@Override
					public void run() {
						MusicBusiness mb = new MusicBusiness();
						try {
							Lyric lyric = mb.getLyric(currentMusic.getId(), Lyric.LYRIC_TYPE_KDTX); //
							KuwoLog.i(TAG, "lyric="+lyric);
							Message msg = lyricHandler2.obtainMessage();
							msg.what = 0;
							msg.obj = lyric;
							lyricHandler2.sendMessage(msg);
						} catch (Exception e) {
							e.printStackTrace();
						}
					}
				}).start();
				if(currentMusic != null) {
					downloadLogic2.downloadShakelightAndAccompaniment(mActivity, currentMusic, result[0], result[1], Config.getPersistence().musicCancelMap.get(currentMusic.getId()));
				}
				downloadLogic2.setOnDownloadListener(new DownloadManager.OnDownloadListener() {
					
					@Override
					public void onProcess(DownloadManager dm, DownloadTask task,
							DownloadStat ds) {
						String taskId = task.getId();
						String musicId = taskId.substring(0, taskId.indexOf('_'));
						int progress = downloadLogic2.computeProgress(musicId);
  						KuwoLog.i(TAG, "download accomp and music progress:"+progress);
						downloadLogic2.publishProgress(progressUpdateHandler2, musicId, progress);
					}
				});
				
				break;
			default:
				break;
			}
		}
		
	};
	
	
	private Handler progressUpdateHandler2 = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case Constants.MESSAGE_DOWNLOAD_PROGRESS: 
				int progress = msg.getData().getInt("progress");
				if(progress == 100) {
					KuwoLog.i(TAG, "下载完成！");
					Toast.makeText(mActivity, "下载完成！", Toast.LENGTH_SHORT).show();
					pd.getButton(DialogInterface.BUTTON_NEGATIVE).setText("演唱");
					downloadFinished = true;
					pd.setProgress(100);
					return;
				}
				pd.setProgress(progress);
				break;
			default:
				break;
			}
		}
		
	};
	
	private Handler lyricHandler2 = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				Lyric lyric = (Lyric) msg.obj;
				if(lyric != null) {
					KuwoLog.i(TAG, "lyric="+lyric+",下载成功！");
				}
				break;

			default:
				break;
			}
		}
		
	};
	
	private List<Music> getSubListFromCache(int pageNum, int size) {
		List<Music> subList = null;
		MusicListLogic logic = new MusicListLogic();
		try {
			subList = logic.getCacheSubList(listID, pageNum, size);
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
			if(!AppContext.getNetworkSensor().hasAvailableNetwork() && currentPageNum != 0) {
				Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
				onLoad();
			}
		}
		boolean result = logic.checkCacheSubList(listID, pageNum, size);
		if(!result) {
			//缓存没有或者过期
			if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
				getSubListFromServer(pageNum, size);
			}
		}
		return subList;
	}
	
	private void getSubListFromServer(final int pageNum, final int size) {
		if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
			if(isRefresh || isLoadMore) {
				rl_song_list_progress.setVisibility(View.INVISIBLE);
			}else {
				rl_song_list_progress.setVisibility(View.VISIBLE);
			}
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					List<Music> musicList = null;
					Message msg = subListHandler.obtainMessage();
					msg.what = 0;
					if("singerSongList".equals(mFlag)) {
						MusicListLogic logic = new MusicListLogic();
						try {
							musicList = logic.getSingersongList(listID, pageNum, size);
						}catch (IOException e) {
							KuwoLog.printStackTrace(e);
							msg.what = 1;
						}
					}else if("subSongList".equals(mFlag)) {
						MusicListLogic logic = new MusicListLogic();
						try {
							musicList = logic.getSubList(listID, pageNum, size);
						} catch (IOException e) {
							KuwoLog.printStackTrace(e);
							msg.what = 1;
						}
					}
					msg.obj = musicList;
					subListHandler.sendMessage(msg);
				}
			}).start();
		}else {
			if(pageNum == 0) {
				showNoNetwork();
			}else {
				Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
				onLoad();
			}
		}
	}
	
	private Handler subListHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				List<Music> result = (List<Music>) msg.obj;
				if(result != null) {
					rl_song_list_progress.setVisibility(View.INVISIBLE);
					if(isRefresh) {
						if(!mAdapter.mSubList.isEmpty()) {
							mAdapter.mSubList.clear();
						}
					}
					
					if(result.size() < 20) {
						isBottom = true;
						lv_song_list.setNoDataStatus(true);
						lv_song_list.getFooterView().hide();
					}else {
						lv_song_list.getFooterView().show();
					}
					mAdapter.addMusicList(result);
					if(!isLoadMore) {
						lv_song_list.setAdapter(mAdapter);
					}
				}
				onLoad();
				break;
			case 1:
				showNoData();
				break;

			default:
				break;
			}
		}
		
	};
	
	private void onLoad() {
		lv_song_list.stopRefresh();
		isRefresh = false;
		lv_song_list.stopLoadMore();
		isLoadMore = false;
		SimpleDateFormat dateFormatter = new SimpleDateFormat("yy-MM-dd HH:mm:ss");
		String time = dateFormatter.format(new Date());
		lv_song_list.setRefreshTime(time);
	}
	
	@Override
	public void onRefresh() {
		isRefresh = true;
		isBottom = false;
		lv_song_list.setNoDataStatus(false);
		currentPageNum = 0;
		loadSubList(0, 20);
	}

	@Override
	public void onLoadMore() {
		if(isBottom) {
			Toast.makeText(mActivity, "亲，就这么多了", 0).show();
			lv_song_list.setFooterNoData();
			return;
		}
		isLoadMore = true;
		loadSubList(++currentPageNum, 20);
		KuwoLog.i(TAG, "currentPageNum==="+currentPageNum);
	}
	
	class SubListAdapter extends BaseAdapter {
		public List<Music> mSubList = new ArrayList<Music>();
		
		public void addMusicList(List<Music> otherList) {
			mSubList.addAll(otherList);
			notifyDataSetChanged();
		}
		
		@Override
		public boolean isEnabled(int position) {
			return false;
		}

		@Override
		public int getCount() {
			return mSubList.size();
		}
		
		@Override
		public Object getItem(int position) {
			return mSubList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}
		
		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View view = null;
			final ViewHolder viewHolder;
			if(convertView == null) {
				view = View.inflate(mActivity, R.layout.song_list_item, null);
				viewHolder = new ViewHolder();
				viewHolder.songNameTV = (TextView) view.findViewById(R.id.tv_song_list_item_name);
				viewHolder.artistTV = (TextView) view.findViewById(R.id.tv_song_list_item_artist);
				viewHolder.progressView = (ProgressButtonView) view.findViewById(R.id.pbv_song_list_view_progress);
				view.setTag(viewHolder);
			}else {
				view = convertView;
				viewHolder = (ViewHolder) view.getTag();
			}
			
			final Music music = mSubList.get(position);
			
			viewHolder.songNameTV.setText(music.getName());
			viewHolder.artistTV.setText(music.getArtist());
			viewHolder.progressView.setForeground(mActivity.getResources().getDrawable(R.drawable.download_progress));
			viewHolder.progressView.setTag(music.getId()+"_progressView");
			
			int downloadStatus = downloadLogic.getMusicDownloadStatus(mActivity, music.getId());
			if(downloadStatus == Constants.DOWNLOAD_STATUS_UNDWONLOAD) {
				MusicDao musicDao = new MusicDao(mActivity);
				Music m = musicDao.getMusic(music.getId());
				if(m != null) {
					KuwoLog.i("DownloadStatus", "0%等待下载");
					viewHolder.progressView.setText("0%");
					viewHolder.progressView.setPercent(0);
					viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
					viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress)); //橙色
				}else {
					KuwoLog.i("DownloadStatus", "未下载");
					viewHolder.progressView.setText("点歌");
					viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song__list_order)); //蓝色
					viewHolder.progressView.setBackgroundResource(R.drawable.order_song_normal);
					viewHolder.progressView.setPercent(0);
				}
			}else if(downloadStatus == Constants.DOWNLOAD_STATUS_ISDOWNLOADING) {
				KuwoLog.i("DownloadStatus", "正在下载中...");
				int progress = downloadLogic.computeProgress(music.getId());
				if(progress == -1) {
					//暂停状态
					MusicDao musicDao = new MusicDao(mActivity);
					Music pauseMusic = musicDao.getMusic(music.getId());
					if(pauseMusic != null) {
						int pauseProgress = downloadLogic.computeDownloadedBytes(music.getId());
						viewHolder.progressView.setText("暂停"+pauseProgress+"%");
						viewHolder.progressView.setPercent(pauseProgress);	
						viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
						viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress));
					}
				}else {
					//下载进行中状态
					if(progress == 100) {
						viewHolder.progressView.setText("演唱");
						viewHolder.progressView.setTextColor(Color.WHITE); //白色
						viewHolder.progressView.setPercent(100);
					}else {
						viewHolder.progressView.setText(progress+"%");
						viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress)); //橙色
						viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
						viewHolder.progressView.setPercent(progress);
					}
				}
			}else if(downloadStatus == Constants.DOWNLOAD_STATUS_COMPLEMENT) {
				KuwoLog.i("DownloadStatus", "已下载");
				viewHolder.progressView.setText("演唱");
				viewHolder.progressView.setTextColor(Color.WHITE); //白色
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
						//未下载状态
						if(downloadedStatus == Constants.DOWNLOAD_STATUS_UNDWONLOAD) {
							if(AppContext.getNetworkSensor().hasAvailableNetwork()) { 
								viewHolder.progressView.setText("0%");
								viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress)); //橙色
								viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
								viewHolder.progressView.setPercent(0);
								if(AppContext.getNetworkSensor().isApnActive()){
									if(!Constants.isSongMobileStateActivited) {
										Constants.isSongMobileStateActivited = true;
										showApnTipDialog("您当前使用的是2G/3G网络，点歌将产生一定的流量", music); //点击确定，就会添加任务,否则变为点歌状态
									}else {
										downloadLogic.addOriginalAndAccompTask(mActivity, music);
										startDownloadLyricThread(music);
									}
								}else {
									downloadLogic.addOriginalAndAccompTask(mActivity, music); //添加任务
									startDownloadLyricThread(music);
								}
							}else {
								Toast.makeText(mActivity, "网络不通，您可以演唱本地歌曲", 0).show();
							}
						//下载中状态
						}else if(downloadedStatus == Constants.DOWNLOAD_STATUS_ISDOWNLOADING) {
							if(AppContext.getNetworkSensor().hasAvailableNetwork()) { 
								int progress = downloadLogic.computeProgress(music.getId());
								KuwoLog.i(TAG, "onClick is downloading==progress="+progress);
								if(progress == -1) {
									//================暂停状态============
									MusicDao musicDao = new MusicDao(mActivity);
									Music pauseMusic = musicDao.getMusic(music.getId());
									if(pauseMusic != null) {
										long totalBytes = pauseMusic.getTotal();
										if(totalBytes == 0) {
											viewHolder.progressView.setText("0%");
											viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress)); //橙色
											viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
											viewHolder.progressView.setPercent(0);
										}else {
											int currentProgress = downloadLogic.computeDownloadedBytes(music.getId());
											viewHolder.progressView.setText(currentProgress+"%");
											viewHolder.progressView.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress));
											viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
											viewHolder.progressView.setPercent(currentProgress);	
										}
									}
									if(AppContext.getNetworkSensor().isApnActive()){
										//apn网络,继续下载
										if(!Constants.isSongMobileStateActivited) {
											Constants.isSongMobileStateActivited = true;
											showApnTipDialog("您当前使用的是2G/3G网络，点歌将产生一定的流量", music);	
										}else {
											downloadLogic.addOriginalAndAccompTask(mActivity, music);
											startDownloadLyricThread(music);
										}
									}else {
										//wifi下载
										downloadLogic.addOriginalAndAccompTask(mActivity, music);
										startDownloadLyricThread(music);
									}
								}else {
									//============正在下载中状态================
									showCancelDownloadDialog(music.getId());
								}
							}else {
								Toast.makeText(mActivity, "网络不通，您可以演唱本地歌曲", 0).show();
							}
						//下载完状态
						}else if(downloadedStatus == Constants.DOWNLOAD_STATUS_COMPLEMENT) {
							final Map<String, SquareShow> activityMap = Config.getPersistence().squareActivityMap;
							if(mFromSquareActivity == null && activityMap != null && activityMap.containsKey(listID) && activityMap.get(listID).type.equals("HRB")) { 
								new Thread(new Runnable() {
									
									@Override
									public void run() {
										UserLogic userLogic = new UserLogic();
										Integer result = userLogic.checkUserIsPartInSquareActivity("HRB");
										Message msg = checkUserIsPartInHandler.obtainMessage();
										if(result == null) {
											msg.what = -1;
											msg.obj = music;
										}else {
											msg.what = 0;
											msg.arg1 = result;
											msg.obj = music;
										}
										checkUserIsPartInHandler.sendMessage(msg);
									}
								}).start();
							}else if(mFromSquareActivity == null && activityMap != null && activityMap.containsKey(listID) ) {
								MTVBusiness business = new MTVBusiness(mActivity);
								business.singMtv(music, MTVBusiness.MODE_AUDIO, Config.getPersistence().squareActivityMap.get(listID).bangId);
							}else {
								MTVBusiness business = new MTVBusiness(mActivity);
								business.singMtv(music, MTVBusiness.MODE_AUDIO, mFromSquareActivity);
							}
						}
				}
			});
			
			return view;
		}
	}
	
	static class ViewHolder {
		TextView songNameTV;
		TextView artistTV;
		ProgressButtonView progressView;
	}
	
	private Handler checkUserIsPartInHandler = new Handler() {
		
		public void handleMessage(Message msg) {
			Music music = (Music) msg.obj;
			switch (msg.what) {
			case 0:
				int result = msg.arg1;
				if(result == 0) {
					//没有参赛
					MTVBusiness business = new MTVBusiness(mActivity);
					business.singMtv(music, MTVBusiness.MODE_AUDIO, null);
				}else if(result == 1) {
					//已经参赛
					MTVBusiness business = new MTVBusiness(mActivity);
					business.singMtv(music, MTVBusiness.MODE_AUDIO, Config.getPersistence().squareActivityMap.get(listID).bangId);
				}else {
					KuwoLog.e(TAG, "服务端参数错误");
				}
				break;
			case -1:
				KuwoLog.e(TAG, "服务端数据获取失败");
				//没有参赛
				MTVBusiness business = new MTVBusiness(mActivity);
				business.singMtv(music, MTVBusiness.MODE_AUDIO, null);
				break;

			default:
				break;
			}
		};
	};
	
	private void startDownloadLyricThread(final Music music) {
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				MusicBusiness mb = new MusicBusiness();
				try {
					Lyric lyric = mb.getLyric(music.getId(), Lyric.LYRIC_TYPE_KDTX);
					KuwoLog.i(TAG, "lyric="+lyric);
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
				if(lyric != null) {
					KuwoLog.i(TAG, "lyric="+lyric+",下载成功！");
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
				ProgressButtonView pb = (ProgressButtonView) lv_song_list.findViewWithTag(musicId+"_progressView");
				if(pb != null) {
					if(progress == 100) {
						pb.setPercent(100);
						pb.setText("演唱");
						pb.setTextColor(Color.WHITE);
						pb.setBackgroundResource(R.drawable.order_song_normal);
					}else {
						if(progress == -1) {
							break;
						}
						pb.setText(progress+"%");
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
			case Constants.DOWNLOAD_FAILED: //(断网引起)暂停 onFail
				String musicId_failed = (String) msg.obj;
				int progress = downloadLogic.computeDownloadedBytes(musicId_failed);
				ProgressButtonView pbv_failed = (ProgressButtonView) lv_song_list.findViewWithTag(musicId_failed+"_progressView");
				if(pbv_failed != null) {
					pbv_failed.setText("暂停"+progress+"%");
					pbv_failed.setTextColor(mActivity.getResources().getColor(R.color.bt_song_list_progress));
					pbv_failed.setBackgroundResource(R.drawable.order_song_pressed);
				}
				break;
			case Constants.DOWNLOAD_CANCEL: //(url获取失败或者主动取消)取消 onCancel
				String musicId_cancel = (String) msg.obj;
				ProgressButtonView pbv_cancel = (ProgressButtonView) lv_song_list.findViewWithTag(musicId_cancel+"_progressView");
				if(pbv_cancel != null) {
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
					//ok
					//取消下载
					KuwoLog.i(TAG, "dialog 取消的music id ="+musicId);
					downloadLogic.cancelDownloadMusic(mActivity, musicId);
					ProgressButtonView pbv = (ProgressButtonView) lv_song_list.findViewWithTag(musicId+"_progressView");
					if(pbv != null) {
						pbv.setText("点歌");
						pbv.setPercent(0);
						pbv.setTextColor(mActivity.getResources().getColor(R.color.bt_song__list_order));
						pbv.setBackgroundResource(R.drawable.order_song_normal);
						mAdapter.notifyDataSetChanged();
					}
					dialog.dismiss();
					break;
				case -2:
					//cancel
					dialog.dismiss();
					break;
				default:
					break;
				}
			}
		}, R.string.logout_dialog_title, R.string.yes, -1,R.string.no, "是否要取消点歌？");
		
	}
	
	private void showApnTipDialog(String tip, final Music music) {
		DialogUtils.alert(mActivity, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//ok
					downloadLogic.addOriginalAndAccompTask(mActivity, music);
					startDownloadLyricThread(music);
					dialog.dismiss();
					break;
				case -2:
					//cancel
					ProgressButtonView pbv = (ProgressButtonView) lv_song_list.findViewWithTag(music.getId()+"_progressView");
					if(pbv != null) {
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
		} , R.string.logout_dialog_title, R.string.dialog_ok, -1, R.string.dialog_cancel, tip);
	}
	
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			int id = v.getId();
			switch (id) {
			case R.id.bt_song_list_back:
				mActivity.finish();
				break;

			default:
				break;
			}
		}
	};
}
