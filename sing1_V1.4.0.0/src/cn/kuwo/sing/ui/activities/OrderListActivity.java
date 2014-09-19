package cn.kuwo.sing.ui.activities;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnLongClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.business.MusicBusiness;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.DownloadController;
import cn.kuwo.sing.db.MusicDao;
import cn.kuwo.sing.logic.DownloadLogic;
import cn.kuwo.sing.ui.compatibility.ProgressButtonView;
import cn.kuwo.sing.util.DialogUtils;
import cn.kuwo.sing.util.lyric.Lyric;

public class OrderListActivity extends Activity {
	static String TAG = "OrderListActivity";
	private DownloadLogic downloadLogic;
	private OrderListAdapter orderAdapter = new OrderListAdapter();;
	private ListView lv_song_order;
	private TextView tv_song_order_empty;
	private List<Music> totalOrderList = new ArrayList<Music>();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		downloadLogic = new DownloadLogic(this);
		setContentView(R.layout.order_list_activity);
		initView();
		
		loadOrderSongView();
	}
	
	private void initView(){
		lv_song_order = (ListView) findViewById(R.id.lv_song_order_list);
		tv_song_order_empty = (TextView) findViewById(R.id.tv_song_order_list_empty);
		Button bt_back = (Button) findViewById(R.id.bt_order_list_back);
		bt_back.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				finish();
			}
		});
	}
	
	public void loadOrderSongView() {
		DownloadController downloadController = new DownloadController(this, downloadLogic, progressUpdateHandler, refreshPBVStateHandler);
		downloadLogic.setOnDownloadListener(downloadController);
		downloadLogic.setOnManagerListener(downloadController);

		new Thread(new Runnable() {
			
			@Override
			public void run() {
				MusicDao musicDao = new MusicDao(OrderListActivity.this);
				List<Music> orderList = musicDao.getMusicForAll();
				Message msg = orderSongHandler.obtainMessage();
				msg.what = 0;
				msg.obj = orderList;
				orderSongHandler.sendMessage(msg);
			}
		}).start();
	}
	
	private Handler orderSongHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				List<Music> result = (List<Music>) msg.obj;
				if(result == null)
					return;
				KuwoLog.i(TAG, "order list result.size==" + result.size());
				totalOrderList.clear();
				if (result.size() == 0) {
					lv_song_order.setVisibility(View.INVISIBLE);
					tv_song_order_empty.setVisibility(View.VISIBLE);
				}else {
					tv_song_order_empty.setVisibility(View.INVISIBLE);
					lv_song_order.setVisibility(View.VISIBLE);
					totalOrderList.addAll(result);
					orderAdapter.setOrderList(totalOrderList);
					lv_song_order.setAdapter(orderAdapter);
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
				ProgressButtonView pb = (ProgressButtonView) lv_song_order.findViewWithTag(musicId+"_progressView");
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
						pb.setTextColor(OrderListActivity.this.getResources().getColor(R.color.bt_song_list_progress));
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
				if(musicId_failed != null) {
					int progress = downloadLogic.computeDownloadedBytes(musicId_failed);
					ProgressButtonView pbv_failed = (ProgressButtonView) lv_song_order.findViewWithTag(musicId_failed+"_progressView");
					if(pbv_failed != null) {
						pbv_failed.setText("暂停"+progress+"%");
						pbv_failed.setTextColor(OrderListActivity.this.getResources().getColor(R.color.bt_song_list_progress));
						pbv_failed.setBackgroundResource(R.drawable.order_song_pressed);
					}
				}
				break;
			case Constants.DOWNLOAD_CANCEL: //(url获取失败或者主动取消)取消 onCancel
				String musicId_cancel = (String) msg.obj;
				if(musicId_cancel != null) {
					Toast.makeText(OrderListActivity.this, "地址获取失败", 0).show();
					startLoadOrderSongThread();
				}
				break;
			default:
				break;
			}
		}
		
	};
	
	public void startLoadOrderSongThread() {
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				MusicDao musicDao = new MusicDao(OrderListActivity.this);
				List<Music> orderList = musicDao.getMusicForAll();
				Message msg = orderSongHandler.obtainMessage();
				msg.what = 0;
				msg.obj = orderList;
				orderSongHandler.sendMessage(msg);
			}
		}).start();
	}
	
	class OrderListAdapter extends BaseAdapter {
		private List<Music> mOrderMusicList;
		private Button currentDeleteBT;

		public OrderListAdapter() {

		}
		
		public void setOrderList(List<Music> musicList) {
			mOrderMusicList = musicList;
		}
		
		@Override
		public int getCount() {
			return mOrderMusicList.size();
		}

		@Override
		public Object getItem(int position) {
			return mOrderMusicList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}
		
		private void showDeleteDialog(final Music music, final int position) {
			AlertDialog.Builder builder = new AlertDialog.Builder(OrderListActivity.this);
			builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					String musicId = music.getId();
					deleteOrderMusic(musicId);
					mOrderMusicList.remove(position);
					notifyDataSetChanged();
					if(mOrderMusicList.size() == 0) {
						lv_song_order.setVisibility(View.INVISIBLE);
						tv_song_order_empty.setVisibility(View.VISIBLE);
					}else {
						tv_song_order_empty.setVisibility(View.INVISIBLE);
						lv_song_order.setVisibility(View.VISIBLE);
					}
				}
				
				private void deleteOrderMusic(String musicId) {
					downloadLogic.cancelDownloadMusic(OrderListActivity.this, musicId);
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
		
		@Override
		public View getView(final int position, View convertView,
				ViewGroup parent) {
			View view;
			final ViewHolder viewHolder;
			if (convertView == null) {
				view = View.inflate(OrderListActivity.this, R.layout.song_list_item, null);
				viewHolder = new ViewHolder();
				viewHolder.songNameTV = (TextView) view.findViewById(R.id.tv_song_list_item_name);
				viewHolder.artistTV = (TextView) view.findViewById(R.id.tv_song_list_item_artist);
				viewHolder.progressView = (ProgressButtonView) view.findViewById(R.id.pbv_song_list_view_progress);
				viewHolder.deleteBT = (Button) view.findViewById(R.id.bt_order_list_delete);
				view.setTag(viewHolder);
			} else {
				view = convertView;
				viewHolder = (ViewHolder) view.getTag();
			}
			
			final Music music = mOrderMusicList.get(position);

			viewHolder.songNameTV.setText(music.getName());
			viewHolder.artistTV.setText(music.getArtist());
			viewHolder.progressView.setForeground(OrderListActivity.this.getResources().getDrawable(R.drawable.download_progress));
			viewHolder.progressView.setTag(music.getId() + "_progressView");
			viewHolder.progressView.setVisibility(View.VISIBLE);
			
			long total = music.getTotal();
			if(total == 0) {
				KuwoLog.i("DownloadStatus", "0%等待下载");
				viewHolder.progressView.setText("0%");
				viewHolder.progressView.setPercent(0);
				viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
				viewHolder.progressView.setTextColor(OrderListActivity.this.getResources().getColor(R.color.bt_song_list_progress)); //橙色
			}
			int downloadStatus = downloadLogic.getMusicDownloadStatus(OrderListActivity.this, music.getId());
			if(downloadStatus == Constants.DOWNLOAD_STATUS_ISDOWNLOADING) {
				KuwoLog.i("DownloadStatus", "正在下载中...");
				int progress = downloadLogic.computeProgress(music.getId());
				if(progress == -1) {
					//暂停状态
					MusicDao musicDao = new MusicDao(OrderListActivity.this);
					Music pauseMusic = musicDao.getMusic(music.getId());
					if(pauseMusic != null) {
						int pauseProgress = downloadLogic.computeDownloadedBytes(music.getId());
						viewHolder.progressView.setText("暂停"+pauseProgress+"%");
						viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
						viewHolder.progressView.setPercent(pauseProgress);	
						viewHolder.progressView.setTextColor(OrderListActivity.this.getResources().getColor(R.color.bt_song_list_progress));
					}
				}else {
					//下载进行中状态
					if(progress == 100) {
						viewHolder.progressView.setText("演唱");
						viewHolder.progressView.setTextColor(Color.WHITE); //白色
						viewHolder.progressView.setBackgroundResource(R.drawable.order_song_normal);
						viewHolder.progressView.setPercent(100);
					}else {
						viewHolder.progressView.setText(progress+"%");
						viewHolder.progressView.setTextColor(OrderListActivity.this.getResources().getColor(R.color.bt_song_list_progress)); //橙色
						viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
						viewHolder.progressView.setPercent(progress);
					}
				}
			}else if(downloadStatus == Constants.DOWNLOAD_STATUS_COMPLEMENT) {
				KuwoLog.i("DownloadStatus", "已下载");
				viewHolder.progressView.setText("演唱");
				viewHolder.progressView.setBackgroundResource(R.drawable.order_song_normal);
				viewHolder.progressView.setTextColor(Color.WHITE); //白色
				viewHolder.progressView.setPercent(100);
			}
			
			view.setOnLongClickListener(new OnLongClickListener() {
				
				@Override
				public boolean onLongClick(View v) {
					showDeleteDialog(music, position);
					return true;
				}
			});
			
						
			viewHolder.deleteBT.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					currentDeleteBT.setVisibility(View.GONE);
					String musicId = music.getId();
					deleteOrderMusic(musicId);
					mOrderMusicList.remove(position);
					notifyDataSetChanged();
					if(mOrderMusicList.size() == 0) {
						lv_song_order.setVisibility(View.INVISIBLE);
						tv_song_order_empty.setVisibility(View.VISIBLE);
					}else {
						tv_song_order_empty.setVisibility(View.INVISIBLE);
						lv_song_order.setVisibility(View.VISIBLE);
					}
				}

				private void deleteOrderMusic(String musicId) {
					downloadLogic.cancelDownloadMusic(OrderListActivity.this, musicId);
				}
			});

			viewHolder.progressView.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					
						int downloadedStatus = downloadLogic.getMusicDownloadStatus(OrderListActivity.this, music.getId());
						//未下载状态
						if(downloadedStatus == Constants.DOWNLOAD_STATUS_ISDOWNLOADING) {
							if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
								int progress = downloadLogic.computeProgress(music.getId());
								KuwoLog.i(TAG, "onClick is downloading==progress="+progress);
								if(progress == -1) {
									//暂停状态
									MusicDao musicDao = new MusicDao(OrderListActivity.this);
									Music pauseMusic = musicDao.getMusic(music.getId());
									if(pauseMusic != null) {
										long totalBytes = pauseMusic.getTotal();
										if(totalBytes == 0) {
											viewHolder.progressView.setText("0%");
											viewHolder.progressView.setTextColor(OrderListActivity.this.getResources().getColor(R.color.bt_song_list_progress)); //橙色
											viewHolder.progressView.setBackgroundResource(R.drawable.order_song_pressed);
											viewHolder.progressView.setPercent(0);
										}else {
											int currentProgress = downloadLogic.computeDownloadedBytes(music.getId());
											viewHolder.progressView.setText(currentProgress+"%");
											viewHolder.progressView.setTextColor(OrderListActivity.this.getResources().getColor(R.color.bt_song_list_progress));
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
											downloadLogic.addOriginalAndAccompTask(OrderListActivity.this, music);
											startDownloadLyricThread(music);
										}
									}else {
										//wifi下载
										downloadLogic.addOriginalAndAccompTask(OrderListActivity.this, music);
										startDownloadLyricThread(music);
									}
								}else {
									//正在下载中状态
									showCancelDownloadDialog(music.getId(), position);
								}
							}else {
								Toast.makeText(OrderListActivity.this, "网络不通，您可以演唱本地歌曲", 0).show();
							}
						//下载完状态
						}else if(downloadedStatus == Constants.DOWNLOAD_STATUS_COMPLEMENT) {
							MTVBusiness business = new MTVBusiness(OrderListActivity.this);
							business.singMtv(music, MTVBusiness.MODE_AUDIO, null);
						}else {
							KuwoLog.i(TAG, "");
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
		Button deleteBT;
	}
	
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
	
	private void showApnTipDialog(String tip, final Music music) {
		DialogUtils.alert(OrderListActivity.this, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//ok
					downloadLogic.addOriginalAndAccompTask(OrderListActivity.this, music);
					startDownloadLyricThread(music);
					dialog.dismiss();
					break;
				case -2:
					//cancel
					ProgressButtonView pbv = (ProgressButtonView) lv_song_order.findViewWithTag(music.getId()+"_progressView");
					if(pbv != null) {
						pbv.setText("点歌");
						pbv.setPercent(0);
						pbv.setTextColor(OrderListActivity.this.getResources().getColor(R.color.bt_song__list_order));
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
	
	
	private void showCancelDownloadDialog(final String musicId, final int position) {
		DialogUtils.alert(OrderListActivity.this, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//ok
					//取消下载
					KuwoLog.i(TAG, "dialog 取消的music id ="+musicId);
					downloadLogic.cancelDownloadMusic(OrderListActivity.this, musicId);
					totalOrderList.remove(position);
					orderAdapter.notifyDataSetChanged();
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
		}, R.string.logout_dialog_title, R.string.yes, -1,R.string.no, "是否要取消点歌吗？");
		
	}
	
}
