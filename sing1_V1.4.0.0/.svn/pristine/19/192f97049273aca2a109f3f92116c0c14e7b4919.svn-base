package cn.kuwo.sing.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.media.AudioRecord;
import android.os.Handler;
import android.os.Message;
import android.view.Gravity;
import android.view.SurfaceView;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.ImageSwitcher;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.ViewSwitcher.ViewFactory;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.TimeUtils;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.business.AudioBaseBusiness;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.business.RecordBusiness;
import cn.kuwo.sing.business.ReviewBusiness;
import cn.kuwo.sing.context.App;
import cn.kuwo.sing.logic.SquareActivityLogic;
import cn.kuwo.sing.logic.media.OnDataProcessListener;
import cn.kuwo.sing.logic.media.OnPositionChangedListener;
import cn.kuwo.sing.logic.media.OnStateChangedListener;
import cn.kuwo.sing.ui.activities.SingActivity;
import cn.kuwo.sing.util.BitmapTools;
import cn.kuwo.sing.util.DialogUtils;

import com.umeng.analytics.MobclickAgent;

public class SingController extends BaseController {

	private final String TAG = "SingController";

	private SingActivity mActivity;
	private LyricController ctlLyric;
	private TextView sing_name_singer;
	private TextView sing_recorded_time;
	private TextView sing_total_time;
	private Button sing_play_pause_btn;
	private SurfaceView sing_video;
//	private View layout_scene;
	private ImageSwitcher sing_scene;
	private AudioBaseBusiness bAudioBase;
	private Music music;
	private String mode;
	private String action;
	private Button sing_original_btn;
	private Button sing_finish_btn;
	private RelativeLayout sing_layout_score;
	private View sing_waves_view;
	private TextView sing_record_status;
	private View sing_free_view;
	private TextView sing_free_view_text;
	private SeekBar seekbar;
	private int totalScores=0;
	/* 当前播放的图片位置 */
	private int mImageIndex = 0;
	private List<Bitmap> mBitmapList;
	/* 定时器 */
	private Timer switchTimer;
	private int defaultImg = R.drawable.sing_scene_temp;
	private int hrbSquareImage = R.drawable.hrb_image;

	public boolean modeDialogShowed = false, originalDialogShowed = false;
//	public boolean isRecordPause = false;
	private String fromSquareActivity;
	private boolean recorderAvailable = true;
	
	private Handler addSquareActivityPictureHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				switchTimer = new Timer();
				switchTimer.schedule(new TimerTask() {
					
					@Override
					public void run() {
						//如果录制没有暂停
						mImageChangeHandler.sendEmptyMessage(0);
					}
				}, 10, 5000);
				break;
			case -1:
				Bitmap bmp = BitmapFactory.decodeResource(mActivity.getResources(), defaultImg, BitmapTools.getBitmapOptions(320, 320));
				List<Bitmap> bitmapList = new ArrayList<Bitmap>();
				bitmapList.add(bmp);
				mBitmapList = bitmapList;
				switchTimer = new Timer();
				switchTimer.schedule(new TimerTask() {
					
					@Override
					public void run() {
						//如果录制没有暂停
						mImageChangeHandler.sendEmptyMessage(0);
					}
				}, 10, 5000);
				break;
			default:
				break;
			}
		}
		
	};

	public SingController(SingActivity activity) {

		KuwoLog.d(TAG, "SingController");
		mActivity = activity;
		MobclickAgent.onEvent(mActivity, "KS_RECORD_MUSIC", "1");

		ctlLyric = new LyricController(activity);

		music = (Music) activity.getIntent().getExtras().getSerializable("music");
		mode = activity.getIntent().getExtras().getString("mode");
		action = activity.getIntent().getExtras().getString("action");
		fromSquareActivity = activity.getIntent().getExtras().getString("fromSquareActivity");
		recorderAvailable = true;
		initView();
		
//		ProgressedBusiness pb = new ProgressedBusiness(mActivity);
//		mBitmapList = pb.getImgs(fromSquareActivity);
		if(fromSquareActivity == null) {
			Bitmap bmp = BitmapFactory.decodeResource(mActivity.getResources(), defaultImg, BitmapTools.getBitmapOptions(320, 320));
			List<Bitmap> bitmapList = new ArrayList<Bitmap>();
			bitmapList.add(bmp);
			mBitmapList = bitmapList;
			switchTimer = new Timer();
			switchTimer.schedule(new TimerTask() {
				
				@Override
				public void run() {
					//如果录制没有暂停
					mImageChangeHandler.sendEmptyMessage(0);
				}
			}, 10, 5000);
		}else {
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					//下载压缩包
					mBitmapList = SquareActivityLogic.getSquareActivityPictures(fromSquareActivity);
					if(mBitmapList == null) {
						Message msg = addSquareActivityPictureHandler.obtainMessage();
						try {
							boolean result = SquareActivityLogic.downloadMtvPictures(fromSquareActivity);
							if(result){
								msg.what = 0;
								mBitmapList = SquareActivityLogic.getSquareActivityPictures(fromSquareActivity);
							}else {
								msg.what = -1;
							}
						} catch (IOException e) {
							KuwoLog.e(TAG, e);
							msg.what = -1;
						}
						addSquareActivityPictureHandler.sendMessage(msg);
					}else {
						switchTimer = new Timer();
						switchTimer.schedule(new TimerTask() {
							
							@Override
							public void run() {
								//如果录制没有暂停
								mImageChangeHandler.sendEmptyMessage(0);
							}
						}, 10, 5000);
					}
					
				}
			}).start();
		}
		if(action.equals(MTVBusiness.ACTION_REVIEW)){
			sing_record_status.setText("正在播放");
			sing_free_view_text.setVisibility(View.INVISIBLE);
			sing_original_btn.setVisibility(View.INVISIBLE);
		}
		// 录制/回放
		if (action.equals(MTVBusiness.ACTION_RECORD))
			bAudioBase = new RecordBusiness(mode);
		else 
			bAudioBase = new ReviewBusiness();
		
		bAudioBase.setOnPositionChangedListener(new OnPositionChangedListener() {
			
			@Override
			public void onPositionChanged(long position) {
				ctlLyric.setPosition(position);
				sing_recorded_time.setText(TimeUtils.toString(position));
				
				// 改变进度条进度
				if ( !seekbar.isPressed()){
					seekbar.setProgress((int) position);
				}
				if((music ==null)&&(position>=300000)){
					if (music == null)
						bAudioBase.stop(null);
					else
						bAudioBase.stop(music.getId());
				}
			}
		});
		
		bAudioBase.setOnDataProcessListener(new OnDataProcessListener() {
			
			@Override
			public void onDataProcess(byte[] data) {
				ctlLyric.ProcessWaveDate(data);
			}
		});
		
		bAudioBase.setOnStateChanged(new OnStateChangedListener() {
			
			@Override
			public void onStateChanged(MediaState state) {
				KuwoLog.d(TAG, "===========state:"+state);
				if (state == MediaState.Complete || state == MediaState.Stop) {
					complete();
				}
				
				if (state == MediaState.Active) {
					sing_play_pause_btn.setBackgroundResource(R.drawable.sing_pause_btn_bg_selector);
					if (action.equals(MTVBusiness.ACTION_RECORD))
						sing_record_status.setText(mActivity.getString(R.string.sing_record_status));
					else 
						sing_record_status.setText(mActivity.getString(R.string.sing_review_status));
				}
				else {
					sing_play_pause_btn.setBackgroundResource(R.drawable.sing_play_btn_bg_selector);
					if (action.equals(MTVBusiness.ACTION_RECORD))
						sing_record_status.setText(mActivity.getString(R.string.sing_record_pause_status));
					else 
						sing_record_status.setText(mActivity.getString(R.string.sing_review_pause_status));
				}
			}
		});

		// 加载歌词
		if (music != null){
			ctlLyric.loadLyric(music.getId());
		}
		
		String rid = music == null ? null : music.getId();
		switch(bAudioBase.prepare(rid)) {
			case AudioRecord.STATE_UNINITIALIZED:
				recorderAvailable = false;
				DialogUtils.toast("录音设备被占用，可以继续演唱，但录音将无法保存。请重启手机以解决该问题", true);
				break;
			case AudioBaseBusiness.EXCEPTION_FILE_NOT_FOND: 
//				UIUtil.alert(mActivity, new OnClickListener() {
//					
//					@Override
//					public void onClick(DialogInterface dialog, int which) {
//						// 删除无效数据
//						DownloadLogic lDownload = new DownloadLogic(mActivity);
//						lDownload.delete(music);
//						mActivity.finish();
//					}
//				}, 0, R.string.app_sure_btn, -1, -1, "伴奏文件不存在"); 	// TODO @LIKANG 伴奏文件不存在
				return;
		}
		
		bAudioBase.setPreviewDisplay(sing_video.getHolder().getSurface());
		bAudioBase.start();
		
		// 总时间
		if ((music != null)||(action.equals(MTVBusiness.ACTION_REVIEW))){
			sing_total_time.setText("/" + TimeUtils.toString(bAudioBase.getDuration()));
			// 设置进度条最大值
			seekbar.setMax((int) bAudioBase.getDuration());
		}else {
			sing_total_time.setText("/05:00");
			// 设置进度条最大值
			seekbar.setMax(300000);
		}
		
		// 播放页暂停
		Intent intent = new Intent("cn.kuwo.sing.action.pause");
		intent.putExtra("id", mActivity.toString());
		mActivity.sendBroadcast(intent);
	}

	/**
	 * 初始化控件
	 * 
	 * @param activity
	 */
	private void initView() {
//		layout_scene = mActivity.findViewById(R.id.layout_scene);
		sing_name_singer = (TextView) mActivity.findViewById(R.id.sing_name_singer);
		sing_recorded_time = (TextView) mActivity.findViewById(R.id.sing_recorded_time);
		sing_total_time = (TextView) mActivity.findViewById(R.id.sing_total_time);
		sing_video = (SurfaceView) mActivity.findViewById(R.id.sing_video);
		sing_finish_btn = (Button)mActivity.findViewById(R.id.sing_finish_btn);
		sing_finish_btn.setOnClickListener(mOnClickListener);
		sing_layout_score = (RelativeLayout) mActivity.findViewById(R.id.sing_layout_score);
		sing_waves_view = mActivity.findViewById(R.id.sing_waves_view);
		seekbar = (SeekBar) mActivity.findViewById(R.id.sing_free_seekbar);
		sing_record_status = (TextView) mActivity.findViewById(R.id.sing_record_status);
		sing_free_view_text = (TextView) mActivity.findViewById(R.id.sing_free_view_text);
		sing_free_view = mActivity.findViewById(R.id.sing_free_view);
		
		// 原唱按钮
		sing_original_btn = (Button) mActivity.findViewById(R.id.sing_original_btn);
		sing_original_btn.setOnClickListener(mOnClickListener);
		// 返回按钮
		Button sing_back_btn = (Button) mActivity.findViewById(R.id.sing_back_btn);
		sing_back_btn.setOnClickListener(mOnClickListener);
		// 暂停播放按钮
		sing_play_pause_btn = (Button) mActivity.findViewById(R.id.sing_play_pause_btn);
		sing_play_pause_btn.setOnClickListener(mOnClickListener);
		
		// 场景图片切换
		sing_scene = (ImageSwitcher) mActivity.findViewById(R.id.sing_scene);
		sing_scene.getLayoutParams().height = AppContext.SCREEN_WIDTH;
		
		sing_scene.setFactory(new ViewFactory() {

			@Override
			public View makeView() {
				ImageView img = new ImageView(mActivity);
				ImageSwitcher.LayoutParams lp = new ImageSwitcher.LayoutParams(AppContext.SCREEN_WIDTH, AppContext.SCREEN_WIDTH);
				lp.gravity = Gravity.CENTER;
				img.setLayoutParams(lp);
				return img;
			}
		});
		
		sing_scene.setInAnimation(AnimationUtils.loadAnimation(mActivity, R.anim.lighter_in));
		sing_scene.setOutAnimation(AnimationUtils.loadAnimation(mActivity, R.anim.darker_out));

		// ====================弹窗设置=====================
	
		
		if (mode.equals(MTVBusiness.MODE_VEDIO)) {
			sing_video.setVisibility(View.VISIBLE);
			sing_scene.setVisibility(View.INVISIBLE);
		}
		
		// 设置标题
		StringBuilder title = new StringBuilder();
		if (music != null) {
			title.append(music.getName());
			if (music.getArtist() != null){
				title.append("-");
				title.append(music.getArtist());
			}
		} else {
			title.append("自由清唱"); // TODO @LIKANG
			sing_waves_view.setVisibility(View.GONE);
			sing_layout_score.setVisibility(View.GONE);
			sing_original_btn.setVisibility(View.GONE);
			sing_free_view.setVisibility(View.VISIBLE);
		}
		sing_name_singer.setText(title.toString());
	}

	private Handler mImageChangeHandler = new Handler() {
		
		@Override
		public void handleMessage(Message msg) {
			if (mImageIndex > mBitmapList.size()-1) {
				mImageIndex = 0;
			}
			sing_scene.setBackgroundDrawable(new BitmapDrawable(mBitmapList.get(mImageIndex)));
			mImageIndex++;
		}
		
		
	};

	/*
	 * 点击事件
	 */
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			int id = v.getId();
			KuwoLog.v(TAG, "onClick " + id);

			switch (id) {
			case R.id.sing_back_btn:// 返回按钮
				String str = (String) mActivity.getIntent().getExtras().getSerializable("action");
				KuwoLog.d(TAG, "str:"+str);
				if(str.equals(MTVBusiness.ACTION_REVIEW)){
					back();
				}else{
					showExitDialog(R.string.sing_exit_tip);
				}
				
				break;
			case R.id.sing_play_pause_btn:// 播放暂停按钮
				bAudioBase.toggle();
//				if(isRecordPause) {
//					isRecordPause = false; //播放
//				}else {
//					isRecordPause = true; //暂停
//				}
				break;
			
			case R.id.sing_cancle_btn:// 收回模式选择对话框
//				dimissModoSetDialog();
				break;
			case R.id.sing_finish_btn: //完成
				resetAppParamsFromKwPlayer();
				if(switchTimer != null) {
					switchTimer.cancel();
				}
				if (music == null)
					bAudioBase.stop(null);
				else
					bAudioBase.stop(music.getId());
				if(!recorderAvailable)  {
					showRecorderUnavailableDialog();
					break;
				}
				bAudioBase.release();
//				totalScores = ctlLyric.getTotalScore();
//				getRanking();
				break;
			case R.id.sing_original_btn:// 直接切换为原唱
//				popOriginalSetDialog();
				bAudioBase.switchPlayer();
				if("原唱".equals(sing_original_btn.getText().toString())) {
					sing_original_btn.setText("伴唱");
				}else {
					sing_original_btn.setText("原唱");
				}
				break;
			case R.id.sing_original_return_btn:// 收回原唱对话框
//				dimissOriginalSetDialog();
				break;
			case R.id.sing_audio_btn:
				new MTVBusiness(mActivity).singMtv(music, MTVBusiness.MODE_AUDIO,fromSquareActivity);
				mActivity.finish();
				break;
			case R.id.sing_vedio_btn:
				new MTVBusiness(mActivity).singMtv(music, MTVBusiness.MODE_VEDIO, fromSquareActivity);
				mActivity.finish();
				break;
			}
		}
	};
	
	private void showRecorderUnavailableDialog() {
		final AlertDialog dialog = new AlertDialog.Builder(mActivity).create();
		dialog.setTitle("提示");
		dialog.setMessage("录音设备被占用,不能录制");
		dialog.setButton("确定", new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface arg0, int arg1) {
				dialog.dismiss();
				back();
			}
		});
		dialog.show();
	}
	
	private void resetAppParamsFromKwPlayer() {
		App app = (App) mActivity.getApplication();
		app.albumFromKwPlayer = null;
		app.artistFromKwPlayer = null;
		app.ridFromKwPlayer = null;
		app.songNameFromKwPlayer = null;
		app.sourceFromKwPlayer = null;
	}
	
	public void showExitDialog(int tip) {
		DialogUtils.alert(mActivity, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//ok
//					mActivity.finish();
					dialog.dismiss();
					resetAppParamsFromKwPlayer();
					back();
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
	
	private void complete(){
		if (action.equals(MTVBusiness.ACTION_RECORD)&&music != null) {
			//当是录制并且不是清唱的时候
			totalScores = ctlLyric.getTotalScore();
			MTVBusiness bMTV = new MTVBusiness(mActivity);
			bMTV.processMtv(music, mode, totalScores+"", "获取中", fromSquareActivity);
			mActivity.finish();
//			getRanking();
		}
		else if(action.equals(MTVBusiness.ACTION_RECORD)&&music == null){
			//当是录制并且是清唱
			MTVBusiness bMTV = new MTVBusiness(mActivity);
			bMTV.processMtv(music, mode, "0", "0", fromSquareActivity);
			mActivity.finish();
		} else {
			mActivity.finish();
		}

		KuwoLog.d(TAG, "complete");
	}

	public void back() {
		if(switchTimer != null) {
			switchTimer.cancel();
		}
		mActivity.finish();
		bAudioBase.release();
	}
	
	private RelativeLayout sing_mode_select_dialog;

	private RelativeLayout sing_original_select_dialog;

	private RelativeLayout sing_inclick_bg;

	/**
	 * 弹出模式选择对话框
	 */
	public void popModoSetDialog() {

		sing_mode_select_dialog.setVisibility(View.VISIBLE);
		sing_inclick_bg.setVisibility(View.VISIBLE);
		setAnimation(sing_mode_select_dialog, DIALOG_BOTTOM_IN);
		modeDialogShowed = true;
		
		pause();
	}

	/**
	 * 收回模式选择对话框
	 */
	public void dimissModoSetDialog() {

		sing_mode_select_dialog.setVisibility(View.GONE);
		sing_inclick_bg.setVisibility(View.GONE);
		setAnimation(sing_mode_select_dialog, DIALOG_BOTTOM_OUT);
		modeDialogShowed = false;
	}

	/**
	 * 弹出原唱对话框
	 */
	public void popOriginalSetDialog() {

		sing_original_select_dialog.setVisibility(View.VISIBLE);
		sing_inclick_bg.setVisibility(View.VISIBLE);
		setAnimation(sing_original_select_dialog, DIALOG_BOTTOM_IN);
		originalDialogShowed = true;
		
		pause();
	}

	/**
	 * 收回原唱对话框
	 */
	public void dimissOriginalSetDialog() {

		sing_original_select_dialog.setVisibility(View.GONE);
		sing_inclick_bg.setVisibility(View.GONE);
		setAnimation(sing_original_select_dialog, DIALOG_BOTTOM_OUT);
		originalDialogShowed = false;
	}

	private final int DIALOG_BOTTOM_IN = 0, DIALOG_BOTTOM_OUT = 1;

	/**
	 * 设置动画
	 * 
	 * @param view
	 *            待设置的View
	 * @param type
	 *            动画类型
	 */
	private void setAnimation(View view, int type) {

		Animation inAnim = null;

		switch (type) {
		case DIALOG_BOTTOM_IN:
			inAnim = AnimationUtils.loadAnimation(mActivity,
					R.anim.sing_img_dialog_bottom_in);
			break;
		case DIALOG_BOTTOM_OUT:
			inAnim = AnimationUtils.loadAnimation(mActivity,
					R.anim.sing_img_dialog_bottom_out);
			break;
		}
		if (inAnim != null)
			view.startAnimation(inAnim);
	}
	
	public void pause() {
		bAudioBase.pause();
	}
	
}
