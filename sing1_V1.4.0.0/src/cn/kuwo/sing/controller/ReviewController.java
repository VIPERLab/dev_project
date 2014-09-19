package cn.kuwo.sing.controller;

import java.lang.reflect.Field;

import com.umeng.analytics.MobclickAgent;

import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.text.InputFilter;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.TimeUtils;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.business.ReviewBusiness;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.db.KgeDao;
import cn.kuwo.sing.logic.AudioLogic;
import cn.kuwo.sing.logic.AudioLogic.ProcessListener;
import cn.kuwo.sing.logic.FileLogic;
import cn.kuwo.sing.logic.MtvLogic;
import cn.kuwo.sing.logic.media.OnPositionChangedListener;
import cn.kuwo.sing.logic.media.OnStateChangedListener;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.LoginActivity;
import cn.kuwo.sing.ui.activities.ShareActivity;
import cn.kuwo.sing.util.DialogUtils;

public class ReviewController {
	private final String TAG = "ReviewController";
	
	private BaseActivity mActivity;
	
	private SeekBar post_processed_seekbar;
	
	private SeekBar post_singer_volume_seekbar;
	
	private SeekBar post_music_volume_seekbar;
	
	private SeekBar post_sync_rejust_seekbar;
	
	private ImageView iv_sync_rejust_forward;
	
	private ImageView iv_sync_rejust_backward;
	
	/* 保存按钮 */
	private Button saveBtn;
	/* 上传按钮 */
//	private Button postBtn;
	/* 无按钮 */
	private Button rev0Btn;
	/* KTV按钮 */
	private Button rev1Btn;
	/* 大厅按钮 */
	private Button rev2Btn;
	/* 剧场按钮 */
	private Button rev3Btn;
	/* 广场按钮 */
	private Button rev4Btn;
	
	private MTVBusiness bMTV;
	private ReviewBusiness bReview;
	private Music music;
	private String mode;
	public Kge mKge;
	private ProgressDialog saveDialog;
	private String score;
	public long saveDate;
	private boolean isSaveTitle = false;
	private String fromSquareActivity;

	private Button post_processed_play_btn;

	private TextView tvPostProcessCurrentTime;

	private TextView tvPostProcessTotalTime;

	private TextView tvPostProcessedPlayStatus;
		
	public ReviewController(BaseActivity activity) {

		KuwoLog.v(TAG, "ReviewController()");

		mActivity = activity;
		bMTV = new MTVBusiness(mActivity);
		bReview = new ReviewBusiness();
		
		music = (Music) activity.getIntent().getExtras().getSerializable("music");
		mode = activity.getIntent().getExtras().getString("mode");
		fromSquareActivity = activity.getIntent().getStringExtra("fromSquareActivity");
		initView();
		
		bReview.setOnStateChanged(new OnStateChangedListener() {
			
			@Override
			public void onStateChanged(MediaState state) {
				if (state == MediaState.Active) {
					post_processed_play_btn.setBackgroundResource(R.drawable.bt_post_processed_pause_selector);
					tvPostProcessedPlayStatus.setText("暂停");
				}else {
					post_processed_play_btn.setBackgroundResource(R.drawable.bt_post_processed_play_selector);
					tvPostProcessedPlayStatus.setText("播放");
				}
				
				if (state == MediaState.Complete) {
					String rid = music == null ? null : music.getId();
					bReview.prepare(rid);
				}
			}
		});
		String rid = music == null ? null : music.getId();
		bReview.prepare(rid);
		
		bReview.getRawPlayer().setOnPositionChangedListener(new OnPositionChangedListener() {
			
			@Override
			public void onPositionChanged(long position) {
				post_processed_seekbar.setProgress((int)position);
				tvPostProcessCurrentTime.setText(TimeUtils.toString(position));
			}
		});
		
		post_processed_seekbar.setMax(bReview.getRawPlayer().getDuration());
		post_singer_volume_seekbar.setMax(100);
		post_singer_volume_seekbar.setProgress(50);
		post_music_volume_seekbar.setMax(100);
		post_music_volume_seekbar.setProgress(50);
		post_sync_rejust_seekbar.setMax(200);
		post_sync_rejust_seekbar.setProgress(100);
		
		tvPostProcessCurrentTime.setText("00:00");
		tvPostProcessTotalTime.setText(TimeUtils.toString(bReview.getRawPlayer().getDuration()));
		KuwoLog.i(TAG, "getDuration: " + bReview.getRawPlayer().getDuration());
		
		post_processed_seekbar.setOnSeekBarChangeListener(mOnSeekBarChangeListener);
		post_singer_volume_seekbar.setOnSeekBarChangeListener(mOnSeekBarChangeListener);
		post_music_volume_seekbar.setOnSeekBarChangeListener(mOnSeekBarChangeListener);
		post_sync_rejust_seekbar.setOnSeekBarChangeListener(mOnSeekBarChangeListener);
		
		iv_sync_rejust_backward.setOnClickListener(mOnClickListener);
		iv_sync_rejust_forward.setOnClickListener(mOnClickListener);
	}
	
	OnSeekBarChangeListener mOnSeekBarChangeListener = new OnSeekBarChangeListener() {
		
		@Override
		public void onStopTrackingTouch(SeekBar seekBar) {
			switch (seekBar.getId()){
			case R.id.post_processed_seekbar:
				KuwoLog.i(TAG, "progress: " + seekBar.getProgress());
				bReview.seekTo(seekBar.getProgress());
				break;
			case R.id.post_singer_volume_seekbar:
				//处于中间的时候不调整，比率从0-2之间
				bReview.setSingerVolume(seekBar.getProgress()/50.0f);
				break;
			case R.id.post_music_volume_seekbar:
				//处于中间的时候不调整，比率从0-1之间
				bReview.setMusicVolume(seekBar.getProgress()/100.0f);
				break;
			case R.id.post_sync_rejust_seekbar:
				{
					int nSyncProgress = seekBar.getProgress();
					setSyncTime(nSyncProgress);
				}
				break;
			default:
				break;
			}
		}
		
		@Override
		public void onStartTrackingTouch(SeekBar seekBar) {
			switch (seekBar.getId()){
			case R.id.post_processed_seekbar:
				bReview.pause();
				break;
			default:
				break;
			}
		}
		
		@Override
		public void onProgressChanged(SeekBar seekBar, int progress,
				boolean fromUser) {
			
		}
	};
	
	/**
	 * 初始化控件
	 * 
	 * @param activity
	 */
	private void initView() {
		// =====================音频处理区域=========================
		// 重唱按钮
		Button post_processed_resing_btn = (Button) mActivity.findViewById(R.id.post_processed_resing_btn);
		post_processed_resing_btn.setOnClickListener(mOnClickListener);
		// 回放按钮
//		Button post_processed_replay_btn = (Button) mActivity.findViewById(R.id.post_processed_replay_btn);
//		post_processed_replay_btn.setOnClickListener(mOnClickListener);
		//播放
		post_processed_play_btn = (Button) mActivity.findViewById(R.id.post_processed_play_btn);
		post_processed_play_btn.setOnClickListener(mOnClickListener);
		tvPostProcessCurrentTime = (TextView)mActivity.findViewById(R.id.tvPostProcessCurrentTime);
		tvPostProcessTotalTime = (TextView)mActivity.findViewById(R.id.tvPostProcessTotalTime);
		tvPostProcessedPlayStatus = (TextView)mActivity.findViewById(R.id.tvPostProcessedPlayStatus);
		// 保存按钮
		saveBtn = (Button) mActivity.findViewById(R.id.post_processed_save_btn);
		saveBtn.setBackgroundResource(R.drawable.bt_save_normal);
		saveBtn.setOnClickListener(mOnClickListener);
		// 上传按钮
//		postBtn = (Button) mActivity.findViewById(R.id.post_processed_post_btn);
//		postBtn.setBackgroundResource(R.drawable.bt_upload_normal);
//		postBtn.setOnClickListener(mOnClickListener);
		
		// =====================设置区域=========================
//		post_processed_play_pause = (Button) mActivity.findViewById(R.id.post_processed_play_pause);
//		post_processed_play_pause.setOnClickListener(mOnClickListener);
		post_processed_seekbar = (SeekBar) mActivity.findViewById(R.id.post_processed_seekbar);
		
		post_singer_volume_seekbar = (SeekBar) mActivity.findViewById(R.id.post_singer_volume_seekbar);
		
		post_music_volume_seekbar = (SeekBar) mActivity.findViewById(R.id.post_music_volume_seekbar);
		
		post_sync_rejust_seekbar = (SeekBar) mActivity.findViewById(R.id.post_sync_rejust_seekbar);
		
		iv_sync_rejust_forward = (ImageView) mActivity.findViewById(R.id.iv_sync_rejust_forward);
		
		iv_sync_rejust_backward = (ImageView) mActivity.findViewById(R.id.iv_sync_rejust_backward);
		
		// "无"按钮
		rev0Btn = (Button) mActivity.findViewById(R.id.post_processed_0_btn);
		rev0Btn.setOnClickListener(mOnClickListener);
		// "小房间"按钮
		rev1Btn = (Button) mActivity.findViewById(R.id.post_processed_1_btn);
		rev1Btn.setOnClickListener(mOnClickListener);
		// "大房间"按钮
		rev2Btn = (Button) mActivity.findViewById(R.id.post_processed_2_btn);
		rev2Btn.setOnClickListener(mOnClickListener);
		// "小清新"按钮
		rev3Btn = (Button) mActivity.findViewById(R.id.post_processed_3_btn);
		rev3Btn.setOnClickListener(mOnClickListener);
		rev4Btn = (Button) mActivity.findViewById(R.id.post_processed_4_btn);
		rev4Btn.setOnClickListener(mOnClickListener);
		// 返回按钮
		Button post_processed_back_btn = (Button) mActivity.findViewById(R.id.post_processed_back_btn);
		post_processed_back_btn.setOnClickListener(mOnClickListener);
		if(music != null) {
			//非自由清唱
			score =  (String) mActivity.getIntent().getExtras().getSerializable("score");
		}else {
			//自由清唱
			score = null;
		}
	}
	/**
	 * 点击事件
	 */
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			switch (v.getId()) {
			case R.id.post_processed_back_btn:// 返回按钮
				KgeDao kgeDao1 = new KgeDao(mActivity);
				if(kgeDao1.getKge(saveDate) == null) {
					popSureExit();
				}else {
					close();
					mActivity.finish();
				}
				break;
			case R.id.iv_sync_rejust_forward:
				{
					int nProgress = post_sync_rejust_seekbar.getProgress();
					nProgress = nProgress - 20;
					if (nProgress<=0)
						nProgress =0 ;
					setSyncTime(nProgress);
				}
			break;
			case R.id.iv_sync_rejust_backward:
				{
					int nProgress = post_sync_rejust_seekbar.getProgress();
					nProgress = nProgress + 20;
					if (nProgress>=200)
						nProgress =0 ;
					setSyncTime(nProgress);
				}
				break;
			case R.id.post_processed_resing_btn:// 重唱按钮
				bMTV.singMtv(music, mode, fromSquareActivity);
				close();
				mActivity.finish();
				break;
//			case R.id.post_processed_replay_btn:// 回放按钮
//				
//				bMTV.reviewMtv(music, mode, fromSquareActivity);
//				bReview.pause();
//				break;
			case R.id.post_processed_save_btn:// 保存按钮
				KgeDao kgeDao2 = new KgeDao(mActivity);
				if(kgeDao2.getKge(saveDate) == null) {
					if(isSaveTitle) {
						processSaveKge(false); //不需要上传
					}else {
						saveKge(false);//不需要上传
					}
				}else {
					saveBtn.setBackgroundResource(R.drawable.bt_save_dark);
					saveBtn.setClickable(false);
				}
				break;
//			case R.id.post_processed_post_btn:// 上传按钮
//				if(Config.getPersistence().isLogin) {
//					if(posted) {
//						postBtn.setBackgroundResource(R.drawable.bt_upload_dark);
//						postBtn.setClickable(false);
//					}else { 
//						//先判断音频文件是否够60秒(record.raw)
//						FileLogic fileLogic = new FileLogic();
//						long rawLength = fileLogic.getRawFileLength();
//						if(rawLength < AudioLogic.getWavSize(60)) {
//							AlertDialog.Builder builder = new AlertDialog.Builder(mActivity);
//							builder.setTitle("提示");
//							builder.setMessage("作品不足60秒不能上传");
//							builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
//								
//								@Override
//								public void onClick(DialogInterface dialog, int which) {
//									dialog.dismiss();
//								}
//							});
//							builder.create();
//							builder.show();
//							return;
//						}
//						KgeDao kgeDao3 = new KgeDao(mActivity);
//						if(kgeDao3.getKge(saveDate) == null) {
//							//未保存
//							if(isSaveTitle) {
//								processSaveKge(true);
//							}else {
//								saveKge(true); //先保存名字，再保存kge对象，再上传
//							}
//						}else {
//							toUpload(false);
//						}
//					}
//				}else {
//					showLoginDialog(R.string.login_dialog_tip);
//				}
//				break;
//			case R.id.post_processed_play_pause:
//				bReview.toggle();
//				break;
			case R.id.post_processed_play_btn: //播放
				bReview.toggle();
				break;
			case R.id.post_processed_0_btn:// 无按钮
				refreshMixBtns(R.id.post_processed_0_btn);
				bReview.start();
				break;
			case R.id.post_processed_1_btn:// 小房间按钮
				refreshMixBtns(R.id.post_processed_1_btn);
				bReview.start();
				break;
			case R.id.post_processed_2_btn:// 大房间按钮
				refreshMixBtns(R.id.post_processed_2_btn);
				bReview.start();
				break;
			case R.id.post_processed_3_btn:
				refreshMixBtns(R.id.post_processed_3_btn);
				bReview.start();
				break;
			case R.id.post_processed_4_btn:
				refreshMixBtns(R.id.post_processed_4_btn);
				bReview.start();
				break;
			}
		}
	};
	
	private void toUpload(boolean needSaveSong) {
		Intent intent = new Intent(mActivity, ShareActivity.class);
		intent.putExtra("fromSquareActivity", fromSquareActivity); //bangId
		intent.putExtra("mFlag", "uploadMySong");
		intent.putExtra("needSaveSong", needSaveSong);
		intent.putExtra("kge", mKge);
		String kgeId = TextUtils.isEmpty(mKge.id) ? "" : mKge.id;
		String aacFileName = kgeId + "_" + mKge.date + ".aac";
		String aacPath = DirectoryManager.getFilePath(DirContext.RECORD, aacFileName);
		String zipPath = null;
		if(fromSquareActivity != null)
			zipPath = DirectoryManager.getFilePath(DirContext.SDCARD_HIDDEN, "my_picture"+fromSquareActivity+".zip");
		else
			zipPath = DirectoryManager.getFilePath(DirContext.SDCARD_HIDDEN, "my_picturelastPictures.zip");
		intent.putExtra("uploadKgeId", kgeId);
		if(!TextUtils.isEmpty(kgeId)) {
			intent.putExtra("musicName", music.getName());
		}
		intent.putExtra("kgeDate", mKge.date);
		intent.putExtra("zipPath", zipPath);
		intent.putExtra("aacPath", aacPath);
		intent.putExtra("kid", mKge.kid);
		intent.putExtra("uid", Config.getPersistence().user.uid);
		mActivity.startActivityForResult(intent, Constants.REVIEW_UPLOAD_REQUEST);
	}
	
	/**
	 * 弹出是否退出录制对话框
	 */
	public void popSureExit() {
//		if()

		AlertDialog.Builder builder = new Builder(mActivity);
		builder.setMessage("是否放弃此次录制？");
		builder.setTitle("提示");

		builder.setPositiveButton("确认", new android.content.DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
				close();
				mActivity.finish();
			}
		});

		builder.setNegativeButton("取消", new android.content.DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});

		builder.create().show();
	}

	private void showLoginDialog(int tip) {
		DialogUtils.alert(mActivity, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//ok
					dialog.dismiss();
					Intent loginIntent = new Intent(mActivity, LoginActivity.class);
					mActivity.startActivity(loginIntent);
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
	
	/**
	 *  保存
	 */
	private void saveKge(final boolean needUpload) {
		mKge = new Kge();
		if (music != null) {
			mKge.id = music.getId();
			mKge.title = music.getName();
			mKge.squareActivityName = fromSquareActivity;
			processSaveKge(needUpload);
		} else {
			// 设置歌名
			mKge.id = null;
			mKge.title = "zyqc";
			View view = View.inflate(mActivity, R.layout.edit_text_for_dialog, null);
			final EditText kgeNameET = (EditText) view.findViewById(R.id.et_review_kge_name);
			kgeNameET.setFilters(new InputFilter[]{new InputFilter.LengthFilter(9)});
			AlertDialog.Builder builder = new AlertDialog.Builder(mActivity);
			builder.setView(view);
			builder.setTitle("为你的作品起个名字吧");
			builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {

				@Override
				public void onClick(DialogInterface dialog, int which) {
					String kgeTitle = kgeNameET.getText().toString();
					mKge.title = kgeTitle;
					isSaveTitle = true;
					processSaveKge(needUpload);
					dialog.dismiss();
				}
				
			});
			builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					mKge = null;
					isSaveTitle = false;
					dialog.dismiss();
				}
			});
			AlertDialog dialog = builder.create();
			dialog.setCanceledOnTouchOutside(false);
			dialog.setCancelable(false);
			dialog.show();
		}
		
		
	}
	
	private void processSaveKge(final boolean needUpload) {
		saveDate = System.currentTimeMillis();
		mKge.date = saveDate;
		if(Config.getPersistence().user != null) {
			mKge.author = Config.getPersistence().user.uname;
		}
		mKge.score = score;
		if(!needUpload) {
			//暂停播放
			bReview.pause();
			//如果不需要上传,在此合成录音
			saveDialog = new ProgressDialog(mActivity);
			saveDialog.setMessage("正在合成录音...");
			saveDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
			saveDialog.setCancelable(false);
			saveDialog.setCanceledOnTouchOutside(false);
			saveDialog.show();
			
            try {
            	 Class<?> clazz = ProgressDialog.class;
            	 TextView nullText = new TextView(mActivity);
            	 nullText.setText("");
            	 Field field = clazz.getDeclaredField("mProgressNumber");
            	 field.setAccessible(true);
            	 field.set(saveDialog, nullText);
			} catch (Exception e) {
				KuwoLog.printStackTrace(e);
			}
			
			// 保存Kge实体
			final AudioLogic lAudio = new AudioLogic();
			lAudio.setMusicVolume(bReview.getSystemPlayerVolume());
			lAudio.setSingerVolume(bReview.getSystemPlayerVolume());
			lAudio.setSyncTime(bReview.getSyncTime());
			lAudio.setProcessListener(new ProcessListener() {
				
				@Override
				public void onProcess(int process, int current, int total) {
					KuwoLog.v(TAG, "process: " + process +"      current: " + current + "      total:" + total);
					int p = (int)(((current-1)*25.0/total) + (process * 25.0));
					saveDialog.setProgress(p);
				}
			});
			new Thread(){
				public void run() {
					if (lAudio.process(mKge) == 0) {
						// 保存图片
						MtvLogic mtvLogic = new MtvLogic();
						if(!mtvLogic.savePictures(mKge, PostProcessedController.imgList, fromSquareActivity)){
							KuwoLog.i(TAG, "保存图片失败");
						}
						KgeDao kgeDao = new KgeDao(mActivity);
						kgeDao.insertKge(mKge);
						Message msg = saveFinishHandler.obtainMessage();
						msg.what = 0;
						saveFinishHandler.sendMessage(msg);
					}else {
						MobclickAgent.onEvent(mActivity, "KS_SAVE_MUSIC", "0");
					}
				};
			}.start();
		}else {
			//需要上传的，转到上传页面，合成录音并上传
			toUpload(needUpload);
		}
		
	}
	
	private Handler saveFinishHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				MobclickAgent.onEvent(mActivity, "KS_SAVE_MUSIC", "1");
				saveDialog.dismiss();
				saveBtn.setBackgroundResource(R.drawable.bt_save_dark);
				saveBtn.setClickable(false);
				Toast.makeText(mActivity, "保存完成", 0).show();
				//跳转到已录界面
				mActivity.finish();
				//发送一段广播，通知MainActivity做页面跳转
				Intent intent = new Intent();
				intent.setAction("cn.kuwo.sing.jump.recordedpage");
				mActivity.sendBroadcast(intent);
				break;

			default:
				break;
			}
		}
		
	};
	
	public void setSaveFinishedState() {
		saveBtn.setBackgroundResource(R.drawable.bt_save_dark);
		saveBtn.setClickable(false);
	}
	
	/* 小房间按钮 */

	/**
	 * 刷新混音按钮背景
	 * 
	 * @param type
	 */
	private void refreshMixBtns(int type) {
		rev0Btn.setBackgroundResource(R.drawable.bt_post_ktv_selector);
		rev1Btn.setBackgroundResource(R.drawable.bt_post_ktv_selector);
		rev2Btn.setBackgroundResource(R.drawable.bt_post_ktv_selector);
		rev3Btn.setBackgroundResource(R.drawable.bt_post_ktv_selector);
		rev4Btn.setBackgroundResource(R.drawable.bt_post_ktv_selector);

		switch (type) {
		case R.id.post_processed_0_btn:
			rev0Btn.setBackgroundResource(R.drawable.bt_post_stay_pressed);
			bReview.setRev(0);
			KuwoLog.d("rev", "set to no room");
			break;
		case R.id.post_processed_1_btn:
			rev1Btn.setBackgroundResource(R.drawable.bt_post_stay_pressed);
			bReview.setRev(1);
			KuwoLog.d("rev", "set to small room");
			break;
		case R.id.post_processed_2_btn:
			rev2Btn.setBackgroundResource(R.drawable.bt_post_stay_pressed);
			bReview.setRev(2);
			KuwoLog.d("rev", "set to middle room");
			break;
		case R.id.post_processed_3_btn:
			rev3Btn.setBackgroundResource(R.drawable.bt_post_stay_pressed);
			bReview.setRev(3);
			KuwoLog.d("rev", "set to big room");
			break;
		case R.id.post_processed_4_btn:
			rev4Btn.setBackgroundResource(R.drawable.bt_post_stay_pressed);
			bReview.setRev(4);
			KuwoLog.d("rev", "set to hall room");
			break;
		}
	}
	
	public void close() {
		String rid = music == null ? null : music.getId();
		bReview.stop(rid);
	}
	
	private void setSyncTime(int Progress){
		int nStep = Progress / 5;
		int syncTime = nStep;
		syncTime -= 20;
		syncTime *= 100;
		boolean seekResult = true;
		//seekResult = bReview.setSync(syncTime);				
		
		if (seekResult){
			if (syncTime<0){
				DialogUtils.toast("人声提前 "+(20-nStep)*100+" 毫秒", false);
			}else if (syncTime>0){
				DialogUtils.toast("人声延后 "+(nStep-20)*100+" 毫秒", false);
			}else{
				DialogUtils.toast("使用初始人声", false);
			}				
			post_sync_rejust_seekbar.setProgress(nStep*5);
		}else{
			DialogUtils.toast("无效的调节", false);
		}
		seekResult = bReview.setSync(-2000);
	}
}
