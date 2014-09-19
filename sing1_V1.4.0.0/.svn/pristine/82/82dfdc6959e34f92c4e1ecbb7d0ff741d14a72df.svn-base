package cn.kuwo.sing.ui.activities;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnLongClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.db.KgeDao;
import cn.kuwo.sing.util.DialogUtils;

public class RecordListActivity extends BaseActivity{
	static String TAG = "RecordListActivity";
	private ListView lv_song_record;
	private RecordListAdapter recordAdapter;
	private TextView tv_song_record_empty;
	private List<Kge> totalRecordList = new ArrayList<Kge>();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.record_list_activity);
		initView();
		
		loadRecordSongView();
	}
	
	private void initView(){
		lv_song_record = (ListView) findViewById(R.id.lv_song_record_list);
		tv_song_record_empty = (TextView) findViewById(R.id.tv_song_record_list_empty);
		Button bt_back = (Button) findViewById(R.id.bt_record_list_back);
		bt_back.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				finish();
			}
		});
		
		recordAdapter = new RecordListAdapter(totalRecordList);
	}
	
	public void loadRecordSongView() {
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				KgeDao kgeDao = new KgeDao(RecordListActivity.this);
				Message msg = recordSongHandler.obtainMessage();
				msg.what = 0;
				msg.obj = kgeDao.queryForAll();
				recordSongHandler.sendMessage(msg);
			}
		}).start();
	}
	
	private Handler recordSongHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				if(msg.obj != null) {
					List<Kge> result = (List<Kge>) msg.obj;
					totalRecordList.clear();
					if(result != null && result.size() != 0) {
						tv_song_record_empty.setVisibility(View.INVISIBLE);
						lv_song_record.setVisibility(View.VISIBLE);
						totalRecordList.addAll(result);
						recordAdapter.setRecordList(totalRecordList);
						lv_song_record.setAdapter(recordAdapter);
					}else {
						KuwoLog.i(TAG, "你还没有录歌哦！");
						lv_song_record.setVisibility(View.INVISIBLE);
						tv_song_record_empty.setVisibility(View.VISIBLE);
					}
				}
				break;
			default:
				break;
			}
		}
		
	};
	
	
	private class RecordListAdapter extends BaseAdapter {
		private List<Kge> mKgeList;
		private float firstX;
		private float lastX;
		private Button currentDeleteBT;
		private Button currentUploadBT;
		private Button currentShareBT;

		public RecordListAdapter(List<Kge> kgeList) {
			mKgeList = kgeList;
		}
		
		public void setRecordList(List<Kge> kgeList) {
			mKgeList = kgeList;
		}
		
		@Override
		public int getCount() {
			return mKgeList.size();
		}

		@Override
		public Object getItem(int position) {
			return mKgeList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}
		
		private void showDeleteDialog(final Kge kge, final int position) {
			AlertDialog.Builder builder = new AlertDialog.Builder(RecordListActivity.this);
			builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					String prefix = kge.id==null ? "" : kge.id;
					String kgeFileName = prefix+"_"+kge.date+".aac";
					deleteRecordKge(kgeFileName);
					mKgeList.remove(position);
					notifyDataSetChanged();
					if(mKgeList.size() == 0) {
						lv_song_record.setVisibility(View.INVISIBLE);
						tv_song_record_empty.setVisibility(View.VISIBLE);
					}else {
						tv_song_record_empty.setVisibility(View.INVISIBLE);
						lv_song_record.setVisibility(View.VISIBLE);
					}
				}
				
				private void deleteRecordKge(String kgeFileName) {
					File kgeFile = DirectoryManager.getFile(DirContext.RECORD, kgeFileName);
					if(kgeFile.exists()) {
						kgeFile.delete();
					}
					KgeDao kgeDao = new KgeDao(RecordListActivity.this);
					kgeDao.delete(kge.date);
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
		public View getView(final int position, View convertView, ViewGroup parent) {
			View view = null;
			RecordViewHolder viewHolder = null;
			if (convertView == null) {
				view = View.inflate(RecordListActivity.this, R.layout.record_list_item, null);
				viewHolder = new RecordViewHolder();
				viewHolder.kgeNameTV = (TextView) view.findViewById(R.id.tv_record_kge_name);
				viewHolder.kgeTimeTV = (TextView) view.findViewById(R.id.tv_record_kge_time);
				viewHolder.kgeDeleteBT = (Button) view.findViewById(R.id.bt_record_kge_delete);
				viewHolder.kgeUploadBT = (Button) view.findViewById(R.id.bt_record_kge_upload);
				viewHolder.kgeShareBT = (Button) view.findViewById(R.id.bt_record_kge_share);
				viewHolder.kgeScoreTV = (TextView) view.findViewById(R.id.tv_record_kge_score);
				view.setTag(viewHolder);
			} else {
				view = convertView;
				viewHolder = (RecordViewHolder) view.getTag();
			}
			
			final Kge kge = mKgeList.get(position);
			
			if(kge.score == null) {
				viewHolder.kgeScoreTV.setText("");
			}else {
				viewHolder.kgeScoreTV.setText(kge.score+"分");
			}
			if (TextUtils.isEmpty(kge.title)) {
				viewHolder.kgeNameTV.setText("自由清唱");
			} else {
				viewHolder.kgeNameTV.setText(kge.title);
			}
			SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			String date = formatter.format(new Date(kge.date));
			viewHolder.kgeTimeTV.setText(date);
			if(Config.getPersistence().isLogin && kge.hasUpload) {
				viewHolder.kgeUploadBT.setVisibility(View.INVISIBLE);
				viewHolder.kgeShareBT.setVisibility(View.VISIBLE);
			}else {
				viewHolder.kgeUploadBT.setVisibility(View.VISIBLE);
				viewHolder.kgeUploadBT.setTextColor(RecordListActivity.this.getResources().getColor(R.color.bt_song__list_upload));
			}
			
			view.setOnLongClickListener(new OnLongClickListener() {
				
				@Override
				public boolean onLongClick(View v) {
					showDeleteDialog(kge, position);
					return true;
				}
			});
			
			view.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					Intent intent = new Intent(RecordListActivity.this, PlayActivity.class);
					intent.putExtra("mFlag", "localPlay");
					intent.putExtra("kge", kge);
					RecordListActivity.this.startActivityForResult(intent, Constants.REQUEST_PLAY_LOCAL_KGE);
				}
			});
			/*view.setOnTouchListener(new OnTouchListener() {
				
				@Override
				public boolean onTouch(View v, MotionEvent event) {
					final RecordViewHolder vHolder = (RecordViewHolder) v.getTag();
					boolean deleteBtShowing = false;
					if(event.getAction() == MotionEvent.ACTION_DOWN) {
						firstX = event.getX();
						if(currentDeleteBT != null) {
							currentDeleteBT.setVisibility(View.GONE);
							deleteBtShowing = false;
						}
						if(kge.hasUpload) {
							if(currentShareBT != null) {
								currentShareBT.setVisibility(View.VISIBLE);
							}
						}else {
							if(currentUploadBT != null) {
								currentUploadBT.setVisibility(View.VISIBLE);
							}
						}
					}else if(event.getAction() == MotionEvent.ACTION_UP) {
						lastX = event.getX();
						if(vHolder.kgeDeleteBT != null) {
							if(Math.abs(firstX-lastX) > 75) {
								vHolder.kgeDeleteBT.setVisibility(View.VISIBLE);
								deleteBtShowing = true;
								vHolder.kgeUploadBT.setVisibility(View.GONE);
								vHolder.kgeShareBT.setVisibility(View.GONE);
								currentDeleteBT = vHolder.kgeDeleteBT;
								currentUploadBT = vHolder.kgeUploadBT;
								currentShareBT = vHolder.kgeShareBT;
							}else {
								if(!deleteBtShowing) {
									Intent intent = new Intent(mActivity, PlayActivity.class);
									intent.putExtra("mFlag", "localPlay");
									intent.putExtra("kge", kge);
									mActivity.startActivity(intent);
								}
							}
						}
					}
					return true;
				}
			});*/
			
			viewHolder.kgeDeleteBT.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					KuwoLog.i(TAG, "delete click");
					currentDeleteBT.setVisibility(View.GONE);
					String prefix = kge.id==null ? "" : kge.id;
					String kgeFileName = prefix+"_"+kge.date+".aac";
					deleteRecordKge(kgeFileName);
					mKgeList.remove(position);
					notifyDataSetChanged();
					if(mKgeList.size() == 0) {
						lv_song_record.setVisibility(View.INVISIBLE);
						tv_song_record_empty.setVisibility(View.VISIBLE);
					}else {
						tv_song_record_empty.setVisibility(View.INVISIBLE);
						lv_song_record.setVisibility(View.VISIBLE);
					}
				}
				
				private void deleteRecordKge(String kgeFileName) {
					File kgeFile = DirectoryManager.getFile(DirContext.RECORD, kgeFileName);
					if(kgeFile.exists()) {
						kgeFile.delete();
					}
					KgeDao kgeDao = new KgeDao(RecordListActivity.this);
					kgeDao.delete(kge.date);
				}
			});
			viewHolder.kgeUploadBT.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					KuwoLog.i(TAG, "upload click");
					if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
						if(Config.getPersistence().isLogin) {
							String kgeId = TextUtils.isEmpty(kge.id) ? "" : kge.id;
							String aacFileName = kgeId + "_" + kge.date + ".aac";
							String zipPath = null;
							if(kge.squareActivityName != null)
								zipPath = DirectoryManager.getFilePath(DirContext.SDCARD_HIDDEN, "my_picture"+kge.squareActivityName+".zip");
							else
								zipPath = DirectoryManager.getFilePath(DirContext.SDCARD_HIDDEN, "my_picturelastPictures.zip");
							String aacPath = DirectoryManager.getFilePath(DirContext.RECORD, aacFileName);
							Intent intent = new Intent(RecordListActivity.this, ShareActivity.class);
							intent.putExtra("mFlag", "uploadMySong");
							intent.putExtra("needSaveSong", false);
							intent.putExtra("uploadKgeId", kgeId);
							if(!TextUtils.isEmpty(kgeId)) {
								intent.putExtra("musicName", kge.title);
							}
							intent.putExtra("kgeDate", kge.date);
							intent.putExtra("zipPath", zipPath);
							intent.putExtra("aacPath", aacPath);
							intent.putExtra("uid", Config.getPersistence().user.uid);
							RecordListActivity.this.startActivityForResult(intent, Constants.REQUEST_UPLOAD);
						}else {
							showLoginDialog(R.string.login_dialog_tip);
						}
					}else {
						Toast.makeText(RecordListActivity.this, "网络不通，请稍后再试", 0).show();
					}
				}
			});
			viewHolder.kgeShareBT.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					KuwoLog.i(TAG, "share click");
					if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
						Intent intent = new Intent(RecordListActivity.this, ShareActivity.class);
						intent.putExtra("mFlag", "shareMySong");
						intent.putExtra("kid", kge.kid);//KID
						intent.putExtra("shareKgeId", kge.id);
						if(!TextUtils.isEmpty(kge.id)) {
							intent.putExtra("musicName", kge.title);
						}
						intent.putExtra("kgeDate", kge.date);
						intent.putExtra("uid", Config.getPersistence().user.uid);
						RecordListActivity.this.startActivity(intent);
					}else {
						Toast.makeText(RecordListActivity.this, "网络不通，请稍后再试", 0).show();
					}
				}
			});

			return view;
		}
	}
	
	static class RecordViewHolder {
		TextView kgeNameTV;
		TextView kgeTimeTV;
		TextView kgeScoreTV;
		Button kgeDeleteBT;
		Button kgeUploadBT;
		Button kgeShareBT;
	}
	
	private void showLoginDialog(int tip) {
		DialogUtils.alert(RecordListActivity.this, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//ok
					dialog.dismiss();
					Intent loginIntent = new Intent(RecordListActivity.this, LoginActivity.class);
					RecordListActivity.this.startActivity(loginIntent);
					break;
				case -2:
					//cancel
					dialog.dismiss();
					break;
				default:
					break;
				}
				
			}
		} , R.string.logout_dialog_title, R.string.dialog_ok, R.string.dialog_cancel, -1, tip);
	}
	
}
