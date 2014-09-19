package cn.kuwo.sing.controller;

import java.io.IOException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Stack;
import java.util.Timer;
import java.util.TimerTask;

import org.apache.commons.io.IOUtils;

import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnBufferingUpdateListener;
import android.media.MediaPlayer.OnPreparedListener;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.ImageSwitcher;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.BitmapUtils;
import cn.kuwo.framework.utils.TimeUtils;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.MTV;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.business.MusicBusiness;
import cn.kuwo.sing.business.ProgressedBusiness;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.logic.LyricLogic;
import cn.kuwo.sing.logic.MtvLogic;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.logic.media.OnPositionChangedListener;
import cn.kuwo.sing.logic.media.OnStateChangedListener;
import cn.kuwo.sing.logic.media.SystemPlayer;
import cn.kuwo.sing.logic.service.MusicService;
import cn.kuwo.sing.logic.service.UserService;
import cn.kuwo.sing.ui.activities.LocalMainActivity;
import cn.kuwo.sing.ui.activities.PlayActivity;
import cn.kuwo.sing.util.BitmapTools;
import cn.kuwo.sing.util.DialogUtils;
import cn.kuwo.sing.util.lyric.Lyric;
import cn.kuwo.sing.util.lyric.Sentence;

import com.tencent.mm.sdk.openapi.IWXAPI;
import com.umeng.analytics.MobclickAgent;

/**
 * 
 * @author wangming
 * 
 */
public class PlayController extends BaseController implements OnPositionChangedListener, OnBufferingUpdateListener, OnStateChangedListener {

	private final String TAG = "PlayController";

	private PlayActivity mActivity;
	public MTV mMTV;

	/** ----------播放区域-------------- */
	/* 播放器 */
	private static String mLastKid;
//	private static Stack<SystemPlayer> mLastPlayer;
	private SystemPlayer mPlayer;
	/* 背景图片列表 */
	private List<Bitmap> mBmpList = null;
	/* 歌词 */
	private Lyric mLrc;
	/* 定时器 */
	private Timer switchTimer;
	/* 当前播放的图片位置 */
	private int mImageIndex = 0;
	/* 控制区域是否已经显示 */
	private boolean playerShowed = true;

	/* 播放控制区域 */
	private RelativeLayout controllerRl;
	/* 背景图片区域 */
	private ImageSwitcher played_scene;
	/* 头像按钮 */
	private Button singerHead;
	/* 播放进度条 */
	private SeekBar seekbar;
	/* 已播放时间 */
	private TextView playedTime;
	/* 音频总时间 */
	private TextView totalTime;
	/* 开始暂停按钮 */
	private Button playPauseBtn;
	/* 歌曲题目+歌手名 */
	private TextView playTitle;
	/* 歌词显示区域 */
	private TextView lrcTv;
	/* 返回按钮 */
	private Button backBtn;
	
	private LinearLayout ll_lrc_play_controller;

	/* 是否播放完毕 */
	private boolean isFinished = false;
	
	private SurfaceView play_scene_vedio;
	
	private String kid;
	private int openMTVUrlResult = -2;
	public PlayInteractController mInteractController;
	private String mFlag;
	private Kge mLocalKge;

	public PlayController(PlayActivity activity, IWXAPI wxApi) {
		KuwoLog.d(TAG, "PlayController()");
		mActivity = activity;
		mFlag = mActivity.getIntent().getStringExtra("mFlag");
		if(mFlag.equals("localPlay")) {
			mLocalKge = (Kge) mActivity.getIntent().getSerializableExtra("kge");
		}else if(mFlag.equals("serverPlay")) {
			kid = mActivity.getIntent().getStringExtra("kid");
			mLastKid = kid;
			KuwoLog.d(TAG, "kid="+kid);
		}
		mInteractController = new PlayInteractController(mActivity, mFlag, wxApi);
		mInteractController.setKid(kid);
		switchTimer = new Timer();
		initView();
		initMTVInfo();
	}
	
	public void setUploadButtonDark() {
		mInteractController.setUploadButtonDark();
	}

	private void initView() {
		controllerRl = (RelativeLayout) mActivity.findViewById(R.id.play_controller_rl);
		controllerRl.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if(event.getAction() == MotionEvent.ACTION_DOWN) {
					return true; //消费掉这个事件，中断传递
				}
				return false;
			}
		});
		play_scene_vedio = (SurfaceView)mActivity.findViewById(R.id.play_scene_vedio);
		play_scene_vedio.setOnClickListener(mOnClickListener);
		played_scene = (ImageSwitcher)mActivity.findViewById(R.id.play_scene);
		played_scene.setOnClickListener(mOnClickListener);
		ll_lrc_play_controller = (LinearLayout) mActivity.findViewById(R.id.ll_lrc_play_controller);
		// 演唱者头像
		singerHead = (Button) mActivity.findViewById(R.id.play_singer_photo);
		singerHead.setBackgroundDrawable(mActivity.getResources().getDrawable(R.drawable.secretm));
		singerHead.setOnClickListener(mOnClickListener);
		// 进度条
		seekbar = (SeekBar) mActivity.findViewById(R.id.player_seekbar);
		seekbar.setOnClickListener(mOnClickListener);
		seekbar.setOnSeekBarChangeListener(seekbarListener);
		// 已播放时间
		playedTime = (TextView) mActivity.findViewById(R.id.play_played_time);
		// 总时间
		totalTime = (TextView) mActivity.findViewById(R.id.play_total_time);
		// 播放暂停按钮
		playPauseBtn = (Button) mActivity.findViewById(R.id.play_play_pause);
		playPauseBtn.setEnabled(false);
		playPauseBtn.setOnClickListener(mOnClickListener);
		// 标题
		playTitle = (TextView) mActivity.findViewById(R.id.play_name);
		// 歌词
		lrcTv = (TextView) mActivity.findViewById(R.id.play_lrc);
		// 返回按钮
		backBtn = (Button) mActivity.findViewById(R.id.play_back_btn);
		backBtn.setOnClickListener(mOnClickListener);
	}
	
	private Handler mtvHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				KuwoLog.i(TAG, "【获取MTV成功！】");
				mMTV = (MTV)msg.obj;
				if(mMTV != null) {
					KuwoLog.i(TAG, "mtv.kid="+mMTV.kid);
					KuwoLog.i(TAG, "mtv.uid="+mMTV.uid);
					KuwoLog.i(TAG, "mtv.title="+mMTV.title);
					KuwoLog.i(TAG, "mtv.url="+mMTV.url);
					KuwoLog.i(TAG, "mtv.rid="+mMTV.rid);
					KuwoLog.i(TAG, "mtv.zip="+mMTV.zip);
					KuwoLog.i(TAG, "mtv.flower="+mMTV.flower);
					KuwoLog.i(TAG, "mtv.comment="+mMTV.comment);
					KuwoLog.i(TAG, "mtv.uname="+mMTV.uname);
					KuwoLog.i(TAG, "mtv.care="+mMTV.care);
					KuwoLog.i(TAG, "mtv.userpic="+mMTV.userpic);
					KuwoLog.i(TAG, "mtv.sid="+mMTV.sid);
					KuwoLog.i(TAG, "mtv.artist="+mMTV.artist);
					
					
//					mMTV.url = "http://k.kuwo.cn/test2/1.mp4";

					String title = String.format("%s - %s", mMTV.title, mMTV.uname);
					playTitle.setText(title);
					mInteractController.setMTV(mMTV);
					if(mFlag.equals("serverPlay")) {
						mInteractController.setAttentionText(mMTV.care);
						mInteractController.setFlowerText(mMTV.flower);
						mInteractController.setCommentText(mMTV.comment);
						initInteract(mMTV.uid); //初始化互动数据
						initFlowers(mMTV.kid);
					}
					initBitmapAndLrc(mMTV); //加载图片和歌词资源
					initPlayer();
				}else {
					playTitle.setText("获取标题失败！");
					mActivity.finish();
				}
				break;

			default:
				break;
			}
		}
		
	};
	
	public void showApnTipDialog(String tip) {
		DialogUtils.alert(mActivity, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//ok
					startMTVInfoThread();
					dialog.dismiss();
					break;
				case -2:
					//cancel
					dialog.dismiss();
					mActivity.finish();
					break;
				default:
					break;
				}
				
			}
		} , R.string.logout_dialog_title, R.string.dialog_ok, -1, R.string.dialog_cancel, tip);
	}
	
	private Thread initMTVInfoThread;
	private void initMTVInfo() {
		if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
			if(AppContext.getNetworkSensor().isApnActive()) {
//				showApnTipDialog("您当前使用的是2G/3G网络，将产生一定的流量");
				if(!Constants.isSquarePlayMobileStateActivited) {
					Toast.makeText(mActivity, "您当前使用的是2G/3G网络，播放作品将产生一定的流量", 0).show();
					Constants.isSquarePlayMobileStateActivited = true;
				}
			}
			
			startMTVInfoThread();
		}else {
			KuwoLog.i(TAG, "没有网络");
			if(mFlag.equals("localPlay")) {
				startMTVInfoThread();
			}
		}
	}
	
	private void startMTVInfoThread() {
		//获取MTV实体
		initMTVInfoThread = new Thread(new Runnable() {
			
			@Override
			public void run() {
				try {
					Message msg = mtvHandler.obtainMessage();
					msg.what = 0;
					if(mFlag.equals("serverPlay")) {
						MusicService musicService = new MusicService();
						msg.obj = musicService.getMtv(kid);
					}else if(mFlag.equals("localPlay")) {
						MTV mtv = new MTV();
						String uname = null;
						if(Config.getPersistence().user == null) {
							uname = "";
						}else {
							uname = Config.getPersistence().user.nickname;
						}
						mtv.uname = uname;
						mtv.title = mLocalKge.title;
						mtv.rid = mLocalKge.id;
//						mtv.userpic = mLocalKge.headPic; //暂不设置头像
						String kgeId = TextUtils.isEmpty(mLocalKge.id) ? "" : mLocalKge.id;
						String aacFileName = kgeId + "_" + mLocalKge.date + ".aac";
						String zipPath = null;
						if(mLocalKge.squareActivityName != null) 
							zipPath = DirectoryManager.getFilePath(DirContext.SDCARD_HIDDEN, "my_picture"+mLocalKge.squareActivityName+".zip");
						else 
							zipPath = DirectoryManager.getFilePath(DirContext.SDCARD_HIDDEN, "my_picturelastPictures.zip");
						String aacPath = DirectoryManager.getFilePath(DirContext.RECORD, aacFileName);
						mtv.url = aacPath;
						mtv.zip = zipPath;
						msg.obj = mtv;
					}
					mtvHandler.sendMessage(msg);
				} catch (IOException e) {
					playTitle.setText("网络连接失败");
					KuwoLog.printStackTrace(e);
				} catch (Exception e) {
					KuwoLog.printStackTrace(e);
				}
			}
		});
		initMTVInfoThread.start();
	}
	
	private Handler flowerHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				KuwoLog.i(TAG, "【获取关注成功！】");
				int flag = msg.arg1;
				KuwoLog.d(TAG, flag+" ::::::::::");
				PlayInteractController.flowerNum = flag;
				break;

			default:
				break;
			}
		}
		
	};
	private Handler attentionHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				KuwoLog.i(TAG, "【获取关注成功！】");
				int flag = msg.arg1;
				switch (flag) {
				case UserService.ATTENTION:
					//已关注
					mInteractController.setAttentionState();
					break;
				case UserService.NOATTENTION:
					//未关注
					mInteractController.setNOAttentionState();
					break;
				case UserService.PARAM_ERR:
					//参数错误
					break;
				case UserService.NO_LOGIN:
					//未登录
//					Toast.makeText(mActivity, "未登录", Toast.LENGTH_SHORT).show();
					break;
				case UserService.SYSTEM_ERROR:
					//系统错误
					Toast.makeText(mActivity, "系统错误", Toast.LENGTH_SHORT).show();
					break;
				default:
					break;
				}
				break;

			default:
				break;
			}
		}
		
	};
	
	private void initInteract(final String uid) {
		//获取关注数量
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				Date currentTime = new Date();
				SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				KuwoLog.i(TAG, "[2.获取关注线程]:"+Thread.currentThread().getName()+","+formatter.format(currentTime));
				int flag = 0;
				try {
					UserLogic userLogic = new UserLogic();
					if(Config.getPersistence().isLogin) {
						flag = userLogic.checkAction(uid);
					}
				} catch (IOException e) {
					KuwoLog.printStackTrace(e);
				}
				Message msg = attentionHandler.obtainMessage();
				msg.what = 0;
				msg.arg1 = flag;
				attentionHandler.sendMessage(msg);
			}
		}).start();
	}
	
	private void initFlowers(final String tid) {
		if (TextUtils.isEmpty(tid))
			return;
		
		//获取剩余鲜花数目
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				Date currentTime = new Date();
				SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				KuwoLog.i(TAG, "[2.获取关注鲜花评论线程]:"+Thread.currentThread().getName()+","+formatter.format(currentTime));
				int flag = 0;
				try {
					UserLogic userLogic = new UserLogic();
					if(Config.getPersistence().isLogin) {
						flag = userLogic.getLeftFlowers();
					}
				} catch (IOException e) {
					KuwoLog.printStackTrace(e);
				}
				Message msg = flowerHandler.obtainMessage();
				msg.what = 0;
				msg.arg1 = flag;
				flowerHandler.sendMessage(msg);
			}
		}).start();
	}
	private Handler backgroundHandler = new Handler() {
		
		private Handler mImageChangeHandler = new Handler() {
			
			@Override
			public void handleMessage(Message msg) {
				if (mImageIndex >= mBmpList.size() - 1) {
					mImageIndex = 0;
				}
				played_scene.setBackgroundDrawable(new BitmapDrawable(mBmpList.get(mImageIndex)));
				mImageIndex++;
			}
		};
		
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				KuwoLog.i(TAG, "【获取轮播图片成功！】");
				mBmpList = (List<Bitmap>)msg.obj;
				if(mBmpList == null) {
					return;
				}
				if(mBmpList.size() != 0) {
					if (switchTimer!=null) {
						switchTimer.schedule(new TimerTask() {
							
							@Override
							public void run() {
								mImageChangeHandler.sendEmptyMessage(0);
							}
						}, 10, 5000);
					}
				}
				break;

			default:
				break;
			}
		};
	};
	
	private Handler headHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				KuwoLog.i(TAG, "【获取头像成功！】");
				Bitmap bitmap = (Bitmap)msg.obj;
				if(bitmap != null) {
					mInteractController.setHeadBitmap(bitmap);
					singerHead.setBackgroundDrawable(new BitmapDrawable(bitmap));
					singerHead.setOnClickListener(mOnClickListener);
				}else {
					KuwoLog.i(TAG, "获取头像失败！");
//					Toast.makeText(mActivity, "获取头像失败！", 0).show();
				}
				break;

			default:
				break;
			}
		}
		
	};
	
	private Handler lyricHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch(msg.what) {
			case 0:
				KuwoLog.i(TAG, "【获取歌词成功！】");
				Lyric lyric = (Lyric)msg.obj;
				mLrc = lyric;
				if(mLrc == null) {
//					lrcTv.setText("获取歌词失败");
				} else {
//					lrcTv.setText("");
				}
				break;
			default:
				break;
			}
		}
		
	};
	
	private void initBitmapAndLrc(final MTV mtv) {
		//轮播图片
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				Message msg = backgroundHandler.obtainMessage();
				msg.what = 0;
				List<Bitmap> bitmapList = null;
				try {
					MTVBusiness bMTV = new MTVBusiness(mActivity);
					if(mFlag.equals("localPlay")) {
						ProgressedBusiness pb = new ProgressedBusiness(mActivity);
						bitmapList = pb.getImgs(mLocalKge.squareActivityName);
					}else {
						bitmapList = bMTV.getMtvPictures(mtv);
					}
				} catch (Exception e) {
					KuwoLog.printStackTrace(e);
				}
				msg.obj = bitmapList;
				backgroundHandler.sendMessage(msg);
				
			}
		}).start();
		
		//获取头像
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				Date currentTime = new Date();
				SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				KuwoLog.d(TAG, "[4.获取头像线程]:"+Thread.currentThread().getName()+","+formatter.format(currentTime));
				Bitmap bitmap = null;
				String url = mtv.userpic;
				try {
					byte[] data = IOUtils.toByteArray(new URL(url));
					bitmap =  BitmapFactory.decodeByteArray(data, 0, data.length, BitmapTools.getBitmapOptions(320, 320));
				} catch (Exception e) {
					KuwoLog.printStackTrace(e);
				}
				Message msg = headHandler.obtainMessage();
				msg.what = 0;
				msg.obj = bitmap;
				headHandler.sendMessage(msg);
			}
		}).start();
		
		if(mMTV.rid != null) {
			//加载歌词
			if(mFlag.equals("serverPlay")) {
				lrcTv.setText("正在缓冲...");
			}
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					Date currentTime = new Date();
					SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
					KuwoLog.d(TAG, "[5.获取歌词线程]:"+Thread.currentThread().getName()+","+formatter.format(currentTime));
					Lyric lyric = null;
					try {
						lyric = new MusicBusiness().getLyric(mtv.rid, Lyric.LYRIC_TYPE_KDTX);
					} catch (Exception e) {
						KuwoLog.printStackTrace(e);
					} 
					Message msg = lyricHandler.obtainMessage();
					msg.what = 0;
					msg.obj = lyric;
					lyricHandler.sendMessage(msg);
				}
				
			}).start();
		}
	}
	
	private Handler mtvUrlHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch(msg.what) {
			case 0:
				int result = msg.arg1;
				openMTVUrlResult = result;
				KuwoLog.i(TAG, "openMTVUrlResult="+openMTVUrlResult);
				if (result < 0) {
					// 打开失败
					KuwoLog.w(TAG, "打开媒体失败");
//					DialogUtils.toast("打开媒体失败");
					MobclickAgent.onEvent(mActivity, "KS_PLAY_MUSIC", "0");
					return;
				}
				
				if (mPlayer == null)
					return;
				
				mPlayer.setOnBufferingUpdateListener(PlayController.this);
				mPlayer.setOnPositionChangedListener(PlayController.this);
				mPlayer.setOnStateChangedListener(PlayController.this);
				mPlayer.setOnPreparedListener(new OnPreparedListener() {
					
					@Override
					public void onPrepared(MediaPlayer mp) {
						// 设置进度条最大值
						seekbar.setMax(mPlayer.getDuration());
						// 设置总时间长度
						totalTime.setText(TimeUtils.toString(mPlayer.getDuration()));
						playPauseBtn.setEnabled(true);
						
						if (needPause) {
							needPause = false;
							return;
						}
						
						if (!mFlag.equals("serverPlay") || mLastKid.equals(mMTV.kid)) {
							mPlayer.start();						
							mPlayer.seekTo((int)position);
							MobclickAgent.onEvent(mActivity, "KS_PLAY_MUSIC", "1");
						}
						
					}
				});
				
				break;
			default:
				break;
			}
		}
		
	};
	
	private void initPlayer() {
		if(mFlag.equals("serverPlay")) {
			if (mLastKid == null)
				return;
		}
		
		if (mPlayer != null) {
			mPlayer.release();
			mPlayer = null;
		}
			
//		if (mLastPlayer != null && !mLastPlayer.isEmpty())
//			mLastPlayer.peek().pause();
		
		Intent intent = new Intent("cn.kuwo.sing.action.pause");
		intent.putExtra("id", mActivity.toString());
		mActivity.sendBroadcast(intent);

		mPlayer = new SystemPlayer();
//		if (mLastPlayer == null)
//			mLastPlayer = new Stack<SystemPlayer>();
//		mLastPlayer.push(mPlayer);
		
		MtvLogic lMtv = new MtvLogic();
		if (lMtv.getMediaType(mMTV.url) == MtvLogic.MEDIA_TYPE_VEDIO) {
			play_scene_vedio.setVisibility(View.VISIBLE);
			played_scene.setVisibility(View.GONE);
			setSurface();

		}else if(lMtv.getMediaType(mMTV.url) == MtvLogic.MEDIA_TYPE_AUDIO) {
			play_scene_vedio.setVisibility(View.GONE);
			played_scene.setVisibility(View.VISIBLE);
		}
		
        new Thread(new Runnable() {

			@Override
			public void run() {
				int result = mPlayer.openAsync(mMTV.url);
				Message msg = mtvUrlHandler.obtainMessage();
				msg.what = 0;
				msg.arg1 = result;
				mtvUrlHandler.sendMessage(msg);
			}
        	
        }).start();

	}
	
	private SurfaceHolder surfaceHolder;
	private SurfaceHolderCallback callback;
	public void setSurface() {
		if (mMTV == null)
			return;
		
		MtvLogic lMtv = new MtvLogic();
		if (lMtv.getMediaType(mMTV.url) == MtvLogic.MEDIA_TYPE_VEDIO) {
			surfaceHolder = play_scene_vedio.getHolder();
			surfaceHolder.setFixedSize(320,240);
			surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
			
			if (callback == null)
				callback = new SurfaceHolderCallback();

			surfaceHolder.addCallback(callback);
		}
	}
	
	/**
	 * 退出页面时释放资源
	 */
	public void release() {

		if (switchTimer != null) {
			switchTimer.cancel();
			switchTimer.purge();
			switchTimer = null;
		}
		if (mPlayer != null) {
			mPlayer.stop();
			mPlayer = null;
//			mLastPlayer.pop();
		}
		
		mLastKid = null;
	}

	public boolean needPause = false; 	// 	按HOME键后 Player初始化完成需要暂停 
	/**
	 * 应用到后台运行时调用
	 */
	public void viewPause() {
//		if (mLastPlayer != null && !mLastPlayer.isEmpty() && mLastPlayer.peek().isPlaying()) {
//			mLastPlayer.peek().pause();
//		}
		if (mPlayer == null)
			return;
		
		needPause = true;
		mPlayer.pause();
	}
	
	/**
	 * 显示播放控制栏
	 */
	private void showPlayer() {
		controllerRl.setVisibility(View.VISIBLE);
		ll_lrc_play_controller.startAnimation(AnimationUtils.loadAnimation(mActivity, R.anim.player_bottom_in));
	}

	/**
	 * 隐藏播放控制栏
	 */
	private void hidePlayer() {
		ll_lrc_play_controller.startAnimation(AnimationUtils.loadAnimation(mActivity, R.anim.player_bottom_out));
		Handler handler = new Handler();
		handler.postDelayed(new Runnable() {
			
			@Override
			public void run() {
				controllerRl.setVisibility(View.GONE);
			}
		}, 600);
	}


	/**
	 * OnSeekBarChangeListener
	 */
	private OnSeekBarChangeListener seekbarListener = new OnSeekBarChangeListener() {
	
		@Override
		public void onStopTrackingTouch(SeekBar seekBar) {
			if (seekBar.getProgress() < seekBar.getSecondaryProgress() || mFlag.equals("localPlay")) {
				mPlayer.seekTo(seekBar.getProgress());
				mPlayer.start();
			}
		}
	
		@Override
		public void onStartTrackingTouch(SeekBar seekBar) {
		}
	
		@Override
		public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
		}
	};

	private boolean surfaceDestroyed = false;
	private long position;
	class SurfaceHolderCallback implements SurfaceHolder.Callback {
		@Override
		public void surfaceCreated(SurfaceHolder holder) {
			KuwoLog.d(TAG, "surfaceCreated");
			if (surfaceDestroyed) {
				position = mPlayer.position;
				initPlayer();
				
				surfaceDestroyed = false;
			}
			mPlayer.setDisplay(surfaceHolder);
		}
	
		@Override
		public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
		}
	
		@Override
		public void surfaceDestroyed(SurfaceHolder holder) {
			KuwoLog.d(TAG, "surfaceDestroyed");
			surfaceDestroyed = true;
		}
	}
	/*
	 * 播放缓冲监听
	 */
	@Override
	public void onBufferingUpdate(MediaPlayer mp, int percent) {
		int value = (int)(percent/100.0 * seekbar.getMax());
		seekbar.setSecondaryProgress(value);
//		KuwoLog.v(TAG, "onBufferingUpdate: " + percent);
	}
	/*
	 * 播放时间改变监听
	 */
	@Override
	public void onPositionChanged(long position) {
		// 改变已播放时间
		playedTime.setText(TimeUtils.toString(position));
		
		// 改变进度条进度
		if (mPlayer != null && !seekbar.isPressed())
			seekbar.setProgress((int) position);
		
		// 改变歌词
		if (mLrc != null) {
			LyricLogic mLrcLogic = new LyricLogic();
			Sentence sentence = mLrcLogic.findSentence(position, mLrc, LyricLogic.SENTENCE_RESULT_NEXT);
			if (sentence != null)
				lrcTv.setText(sentence.getContent());
		}
	}
	/*
	 * 播放完成监听
	 */
	@Override
	public void onStateChanged(MediaState state) {
		if (state == MediaState.Complete) {
			playedTime.setText("00:00");
			seekbar.setProgress(0);
//			initPlayer();
			if (mPlayer != null) {
				mPlayer.seekTo(0);
				mPlayer.pause();
			}
			// isFinished = true;
		} 
		
		if (state == MediaState.Active){
			playPauseBtn.setBackgroundResource(R.drawable.post_processed_pause_btn);
		} else {
			playPauseBtn.setBackgroundResource(R.drawable.post_processed_play_btn);
		}
		
	}
	
	/**
	 * 点击事件
	 */
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			int id = v.getId();
			switch (id) {
			case R.id.play_back_btn:// 返回按钮
				// 停止播放
				release();
				mActivity.setResult(Constants.RESULT_RELOAD_RECORDED_KGE);
				mActivity.finish();
				break;
			case R.id.play_scene:// 背景图片区域
				if (playerShowed) {// 播放控制区域已显示
					hidePlayer();
					playerShowed = false;
				} else {// 播放控制区域已隐藏
					showPlayer();
					playerShowed = true;
				}
				break;
			case R.id.play_scene_vedio:// 背景图片区域
				if (playerShowed) {// 播放控制区域已显示
					hidePlayer();
					playerShowed = false;
				} else {// 播放控制区域已隐藏
					showPlayer();
					playerShowed = true;
				}
				break;
			case R.id.play_singer_photo:// 头像按钮
				if(AppContext.getNetworkSensor().hasAvailableNetwork()) {
					// 进入用户主页
					if(mFlag.equals("serverPlay")) {
						Intent singerIntent = new Intent(mActivity, LocalMainActivity.class);
						if(mMTV != null) {
							if(Config.getPersistence().isLogin && mMTV.uid.equals(Config.getPersistence().user.uid)) {
								Toast.makeText(mActivity, "请从我的进入自己主页", 0).show();
								break;
							}
							singerIntent.putExtra("flag", "otherHome");
							singerIntent.putExtra("uid", mMTV.uid);
							singerIntent.putExtra("uname", mMTV.uname);
							mActivity.startActivity(singerIntent);
						}else {
							Toast.makeText(mActivity, "作品未加载完全", 0).show();
						}
					}else {
						Toast.makeText(mActivity, "本地作品播放", 0).show();
					}
				}else {
					Toast.makeText(mActivity, "网络不通，请稍后再试", 0).show();
				}
				break;
			case R.id.play_play_pause:// 开始暂停按钮
				if(mPlayer != null && openMTVUrlResult == 0) {
					if (isFinished) {// 已完成播放
						mPlayer.start();
						isFinished = false;
					} else {
						if (mPlayer.isPlaying()) {
							mPlayer.pause();
						} else {
							mPlayer.start();
						}
					}
				}
				break;
			}
		}
	};
}
