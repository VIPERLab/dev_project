package cn.kuwo.sing.ui.activities;

import java.io.File;
import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.app.TabActivity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.Process;
import android.view.KeyEvent;
import android.view.Window;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.config.PreferencesManager;
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
import cn.kuwo.sing.controller.MainController;
import cn.kuwo.sing.logic.DownloadLogic;
import cn.kuwo.sing.logic.MusicLogic;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.util.lyric.Lyric;

import com.nostra13.universalimageloader.core.ImageLoader;
import com.umeng.analytics.MobclickAgent;
import com.umeng.fb.NotificationType;
import com.umeng.fb.UMFeedbackService;
import com.umeng.update.UmengUpdateAgent;

import de.greenrobot.event.EventBus;

/**
 * 主页面tabhost
 */
public class MainActivity extends TabActivity {

	private final String TAG = "MainActivity";
	private MainController mMainController;
	private static boolean hasFirstClick = false;
	private Timer exitTimer = new Timer();
	public boolean imgSetDialogShowed;
	private RelativeLayout inclickBg;
	private RelativeLayout addHeadPicDialog;
	private MainBroadcastReciver receiver;
	private ProgressDialog pd;
	private boolean downloadFinished = false; 
	private DownloadLogic  downloadLogic;
	private EventBus mEventBus;
	private JumpToSongPageBroadcastReceiver jumpReceiver;
	private JumpToRecordedPageBroadcastReceiver jumpRecordedReceiver;
	
	
	class ExitTimerTask extends TimerTask {

		@Override
		public void run() {
			 hasFirstClick = false;
		}
	}
	
	private class JumpToSongPageBroadcastReceiver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			KuwoLog.d(TAG, "action="+intent.getAction());
			mMainController.switchFrame("FrameSing", null);
		}
		
	}
	
	private class JumpToRecordedPageBroadcastReceiver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			KuwoLog.d(TAG, "action="+intent.getAction());
			mMainController.switchFrame("FrameSing", null);
			//发送广播跳转到recorded页面
			Intent jumpIntent = new Intent();
			jumpIntent.setAction("cn.kuwo.sing.jump.songpage.frommain");
			sendBroadcast(jumpIntent);
		}
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		KuwoLog.i(TAG, "onCreate");
		super.onCreate(savedInstanceState);
		MobclickAgent.onError(this);
		UMFeedbackService.enableNewReplyNotification(this, NotificationType.AlertDialog);
		UmengUpdateAgent.update(this);
//		VMRuntime.getRuntime().setTargetHeapUtilization(Constants.TARGET_HEAP_UTILIZATION); 
//		VMRuntime.getRuntime().setMinimumHeapSize(Constants.CWJ_HEAP_SIZE); //设置最小heap内存为6MB大小。当然对于内存吃紧来说还可以通过手动干涉GC去处理	
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.main_activity);
		App app = (App) getApplication();
		app.addActivity(this);
		mMainController = new MainController(this);
		receiver = new MainBroadcastReciver();
		IntentFilter intentFilter = new IntentFilter();
	    intentFilter.addAction("cn.kuwo.sing.user.change");
	    registerReceiver(receiver, intentFilter);
	    mEventBus = EventBus.getDefault();
		mEventBus.register(this);
		
		jumpReceiver = new JumpToSongPageBroadcastReceiver();
	    IntentFilter jumpFilter = new IntentFilter();
	    jumpFilter.addAction("cn.kuwo.sing.jump.songpage");
	    registerReceiver(jumpReceiver, jumpFilter);
	    
	    jumpRecordedReceiver = new JumpToRecordedPageBroadcastReceiver();
	    IntentFilter jumpRecordedFilter = new IntentFilter();
	    jumpRecordedFilter.addAction("cn.kuwo.sing.jump.recordedpage");
	    registerReceiver(jumpRecordedReceiver, jumpRecordedFilter);
	    
	    new Thread(new Runnable() {
			
			@Override
			public void run() {
				UserLogic userLogic = new UserLogic();
				Map<String, SquareShow> activityMap = userLogic.getSquareActivityMap();
				if(activityMap == null) {
					KuwoLog.d(TAG, "活动列表获取失败！");
				}else {
					Config.getPersistence().squareActivityMap = activityMap;
					Config.savePersistence();
				}
			}
		}).start();
	    
	    //接收kwplayer传递过来的uid，sid请求
	    String rid = app.ridFromKwPlayer;
	    String title = app.songNameFromKwPlayer;
	    String artist = app.artistFromKwPlayer;
	    String album = app.albumFromKwPlayer;
	    String source = app.sourceFromKwPlayer;
	    KuwoLog.e(TAG, "rid="+rid+",title="+title+",artist="+artist+",album="+album+",source="+source);
	    if("kuwo".equals(source) && rid != null) {
	    	MusicLogic musicLogic = new MusicLogic();
	    	File originalFile = musicLogic.getOriginalFile(rid);
			File accomFile = musicLogic.getAccompanyFile(rid);
			final Music music = new Music();
			music.setId(rid);
			music.setName(title);
			music.setArtist(artist);
			if(originalFile == null || accomFile == null) {
				downloadMusicResource(music);
			}else {
				showDownloadedDialog(music);
			}
	    }else if("HRB".equals(source)) {
	    	String uid = "";
			String sid = "";
			if(Config.getPersistence().isLogin) {
				if(Config.getPersistence().user != null ){
					uid = Config.getPersistence().user.uid;
					sid = Config.getPersistence().user.sid;
				}
			}
			Intent hrbIntent = new Intent(MainActivity.this, SquareShowActivity.class);
			String activityUrl = String.format(Constants.SQUARE_ACTIVITY_URL, uid, sid, "HRB", getAppVersionName(MainActivity.this));
			hrbIntent.putExtra("activityUrl", activityUrl);
			hrbIntent.putExtra("title", Constants.HRB_TITLE);
			startActivity(hrbIntent);
	    }
	}
	
	/**
	 * 返回当前程序版本名
	 * 
	 * @param context
	 * @return
	 */
	private String getAppVersionName(Context context) {
		String versionName = "";
		try {
			// ---get the package info---
			PackageManager pm = context.getPackageManager();
			PackageInfo pi = pm.getPackageInfo(context.getPackageName(), 0);
			versionName = pi.versionName;
			if (versionName == null || versionName.length() <= 0) {
				return "";
			}
		} catch (Exception e) {
			KuwoLog.printStackTrace(e);
		}
		return versionName;
	}
	
	private void showDownloadedDialog(final Music music) {
		AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
		builder.setMessage(music.getName()+"【"+music.getArtist()+"】 资源已存在，现在就去演唱？");
		builder.setPositiveButton("演唱", new OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
				MTVBusiness business = new MTVBusiness(MainActivity.this);
				business.singMtv(music, MTVBusiness.MODE_AUDIO, null);
			}
		});
		builder.setNegativeButton("取消", new OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		builder.create().show();
	}
	
	private void downloadMusicResource(final Music music) {
		downloadFinished = false;
		if(Config.getPersistence().musicCancelMap == null) {
			Config.getPersistence().musicCancelMap = new HashMap<String, Boolean>();
		}
		Config.getPersistence().musicCancelMap.put(music.getId(), false);
		Config.savePersistence();
		pd = new ProgressDialog(this);
		pd.setMessage(music.getName()+"	 "+music.getArtist());
		pd.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
		pd.setButton(DialogInterface.BUTTON_POSITIVE, "酷我音乐", new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				PreferencesManager.put("isAppRunning", false).commit();
				Process.killProcess(Process.myPid());
			}
		});
		pd.setButton(DialogInterface.BUTTON_NEGATIVE, "换首歌", new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				if(downloadFinished) {
					//马上演唱
					MTVBusiness business = new MTVBusiness(MainActivity.this);
					business.singMtv(music, MTVBusiness.MODE_AUDIO, null);
					dialog.dismiss();
				}else {
					dialog.dismiss();
				}
			}
		});
		pd.setCancelable(false);
		pd.setCanceledOnTouchOutside(false);
		pd.show();
		try {
		       	 Class<?> clazz = ProgressDialog.class;
		       	 TextView nullText = new TextView(MainActivity.this);
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
				Message msg = downloadMusicHandler.obtainMessage();
				msg.what = 0;
				msg.obj = result;
				msg.getData().putSerializable("music", music);
				downloadMusicHandler.sendMessage(msg);
			}
			
		}).start();
	}
	
	private Handler downloadMusicHandler = new Handler() {
		
		@Override
		public void handleMessage(Message msg) {
			switch(msg.what) {
			case 0:
				KuwoLog.i(TAG, "【获取音乐伴奏防盗链地址成功！】");
				String[] result = (String[])msg.obj;
				KuwoLog.i(TAG, "result[0]="+result[0]);
				KuwoLog.i(TAG, "result[1]="+result[1]);
				final Music currentMusic = (Music) msg.getData().getSerializable("music");
				downloadLogic = new DownloadLogic(false, MainActivity.this);
				new Thread(new Runnable() {
					
					@Override
					public void run() {
						MusicBusiness mb = new MusicBusiness();
						try {
							Lyric lyric = mb.getLyric(currentMusic.getId(), Lyric.LYRIC_TYPE_KDTX); //
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
				if(currentMusic != null) {
					downloadLogic.downloadShakelightAndAccompaniment(MainActivity.this, currentMusic, result[0], result[1], Config.getPersistence().musicCancelMap.get(currentMusic.getId()));
				}
				downloadLogic.setOnDownloadListener(new DownloadManager.OnDownloadListener() {
					
					@Override
					public void onProcess(DownloadManager dm, DownloadTask task,
							DownloadStat ds) {
						String taskId = task.getId();
						String musicId = taskId.substring(0, taskId.indexOf('_'));
						int progress = downloadLogic.computeProgress(musicId);
  						KuwoLog.i(TAG, "download accomp and music progress:"+progress);
						downloadLogic.publishProgress(progressUpdateHandler, musicId, progress);
					}
				});
				
				
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
				int progress = msg.getData().getInt("progress");
				if(progress == 100) {
					KuwoLog.i(TAG, "下载完成！");
					Toast.makeText(MainActivity.this, "下载完成！", Toast.LENGTH_SHORT).show();
					pd.getButton(DialogInterface.BUTTON_NEGATIVE).setText("马上演唱");
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
	
	private class MainBroadcastReciver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			if(action.equals("cn.kuwo.sing.user.change")) {
				KuwoLog.i(TAG, "MainBroadcastReciver receiver");
				//刷新消息数目
				mMainController.refreshLocalNoticeNumber();
			}
		}
	}
	
	public void setTabWidgetState(int visibility) {
		mMainController.setTabWidgetState(visibility);
	}
	
	@Override
	public boolean dispatchKeyEvent(KeyEvent event) {
		if(event.getAction() == KeyEvent.ACTION_DOWN && event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
			if(hasFirstClick) {
				PreferencesManager.put("isAppRunning", false).commit();
				Process.killProcess(Process.myPid());
			}else {
				Toast.makeText(this, "再按一次退出应用！", 0).show();
				hasFirstClick = true;
				exitTimer.schedule(new ExitTimerTask(), 2000); //2秒后重置标记
			}
			return true;
		}
		return super.dispatchKeyEvent(event);
	}
	
	@Override
	protected void onStart() {
		super.onStart();
		KuwoLog.v(TAG, "onStart");
	}

	@Override
	protected void onResume() {
		KuwoLog.v(TAG, "onResume");
		
		super.onResume();
	}
	
	@Override
	protected void onDestroy() {
		unregisterReceiver(receiver);
		unregisterReceiver(jumpReceiver);
		unregisterReceiver(jumpRecordedReceiver);
		ImageLoader.getInstance().stop();
		mEventBus.unregister(this);
		super.onDestroy();
	}
	
	protected void onEvent(String event) {
	   if(event.equals("cn.kuow.sing.exit.commandFromKwPlayer")) {
		   KuwoLog.d(getClass().getSimpleName(), "EventBus onEvent('cn.kuow.sing.exit.commandFromKwPlayer')");
		   PreferencesManager.put("isAppRunning", false).commit();
		   this.finish();
	   }
	}
}
