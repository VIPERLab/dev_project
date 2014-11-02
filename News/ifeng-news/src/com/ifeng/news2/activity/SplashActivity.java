package com.ifeng.news2.activity;

import android.app.Activity;

import java.io.File;

import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.Parcelable;
import android.preference.PreferenceManager;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.ItemCover;
import com.ifeng.news2.bean.SplashCoverUnits;
import com.ifeng.news2.bean.StoryMessage;
import com.ifeng.news2.commons.upgrade.Upgrader;
import com.ifeng.news2.commons.upgrade.Version;
import com.ifeng.news2.commons.upgrade.download.Callback;
import com.ifeng.news2.fragment.NewsMasterFragmentActivity;
import com.ifeng.news2.service.SplashService;
import com.ifeng.news2.util.AlarmSplashServiceManager;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.ReviewManager;
import com.ifeng.news2.util.SplashManager;
import com.ifeng.news2.util.SplashUpgradeHandler;
import com.ifeng.news2.util.SplashUpgradeHandler.UpgradeListener;
import com.ifeng.news2.util.StatisticUtil;
import com.qad.io.Zipper;
import com.qad.loader.Settings;
import com.qad.util.WToast;
import com.umeng.analytics.MobclickAgent;

public class SplashActivity extends AppBaseActivity implements OnTouchListener,
		OnClickListener {

	/**
	 * 标识SplashActivity是否被初始化，以判断应用是新启动还是由后台恢复到前台
	 */
	public static boolean isSplashActivityCalled = false;

	private final static int SKIPKEY = 1;
	// 启动动画图片
	private ImageView splash_picture;
	// 启动画面简介
	private TextView splash_tv_induction;
	// 启动动画跳过按钮
	private RelativeLayout splash_skip;
	// 事件处理按钮
	private Button event_bt;
	// 手指按下时的横坐标
	private float startX = 0.0f;
	// 手指按起是的横坐标
	private float endX = 0.0f;
	// 手机屏幕宽度
	private float screenWidth = 0.0f;
	//
	private boolean firstComeIn = true;
	private StoryMessage mStoryImgMge = null;
	private DisplayMetrics metric = null;
	private SplashManager mSplashManager = null;
	private Extension mStoryExtension = null;
	private Intent mIntent = null;
	private boolean isAutoForward = true;
	private boolean isEnd = false;
	private long startTime = 0;
	private long autoSendTime = 0;
	private Handler mainHandler = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case SKIPKEY:
				if (isAutoForward && !Config.IS_FINSIH_PULL_SKIP) {
					goToNewPage();
				}
				break;
			}
		}
	};

	private UpgradeListener mListener = new UpgradeListener() {

		@Override
		public void onReceiveUpgrade() {
			isAutoForward = false;
		}

		@Override
		public void onReceiveFinish() {
			isNeedForward();
		}

		@Override
		public void onReceiveError() {
			isNeedForward();
		}
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		/*DisplayMetrics outMetrics = new DisplayMetrics();
		getWindowManager().getDefaultDisplay().getMetrics(outMetrics);
		Config.SCREEN_WIDTH =  outMetrics.widthPixels;*/

		isSplashActivityCalled = true;
		if (StatisticUtil.isValidStart(this)) {
			StatisticUtil.addRecord(this, StatisticUtil.StatisticRecordAction.in, "type=direct");
		}
		// AbstractWeibo.initSDK(this);
		beginHeartBeatStatistic();
		Config.IS_FINSIH_PULL_SKIP = false;
		mIntent = new Intent();
		mIntent.setClass(this, NewsMasterFragmentActivity.class);
		// ConfigManager.initConfig(this); // 读取url配置
		// ParamsManager.initParams(this); // 初始化默认参数

		init();
		// checkUpgrade();
		startUpdateSplashService();
		MobclickAgent.onError(this); // 友盟错误报告
//		StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.START,
//				new SimpleDateFormat("yyyy-MM-dd hh:mm").format(new Date()));
		// // @gm, for PlutusSDK
		// if (Config.ENABLE_ADVER) {
		// HashMap<String, String> selection = new HashMap<String, String>();
		// selection.put("select", "preLoad");
		// selection.put("position", "10000001&10000003");
		// PlutusAndroidManager.init(ParamsManager.addParams(""));
		// PlutusAndroidManager.setCacheDir(Config.FOLDER_DATA
		// .getAbsolutePath());
		// PlutusAndroidManager
		// .setUrl("http://api.3g.ifeng.com/ClientAdverApi?");
		// PlutusAndroidManager.qureyAsync(selection, null);
		// HashMap<String, String> map = new HashMap<String, String>();
		// map.put(Constants.SELECT, Constants.SELE_ADPOSITION);
		// map.put(Constants.KEY_POSITION, "10000001");
		// PlutusAndroidManager.qureyAsync(map, plutusAndroidListener);
		// ExposureHandler.init();
		// }
		// // @gm, for PlutusSDK end
		
		// 检测并删除旧数据，以避免存储空间用完从而导致无法看到正文内图片
		new Thread() {
			@Override
			public void run() {
				try {
					Log.i("Sdebug", "Cleanup thread running!!!");
					File baseCache = IfengNewsApp.getBeanLoader().getSettings().getBaseCacheDir();
					if (null != baseCache && baseCache.exists()) {
						long currentTime = System.currentTimeMillis();
						File resDir = new File(baseCache, ".res");
						String[] filesStr = resDir.list();
						Log.i("Sdebug", "length of filesStr " + filesStr.length);
						if (filesStr.length > 5000) {
							// 直接删除一半数据
							try {
								for (int i=0; i < filesStr.length/2; i++) {
									try {
//										Log.e("Sdebug", "Cleanup thread delete !!!" + filesStr[i]);
										new File(resDir, filesStr[i]).delete();
									} catch (Exception e2) {
										Log.e("Sdebug", "Cleanup thread Exception!!!", e2);
										continue;
									}
								}
							} catch (Exception e1) {
								Log.e("Sdebug", "Cleanup thread Exception!!!", e1);
							}
						} else {
							
							for (int i=0; i < filesStr.length; i++) {
								try {
//									Log.e("Sdebug", "Cleanup thread delete !!!" + filesStr[i]);
									File file = new File(resDir, filesStr[i]);
									if (currentTime - file.lastModified() > 1000L * 60 * 60 * 24 * 30) {
										file.delete();
									}
								} catch (Exception e2) {
									Log.e("Sdebug", "Cleanup thread Exception!!!", e2);
									continue;
								}
							}
						}
						
						File beanCacheDir = new File(baseCache, ".data"+Settings.getInstance().getPackageNum());
						String[] beanFilesStr = beanCacheDir.list();
//						File[] files = new File[beanFilesStr.length];
						for (int i=0; i< beanFilesStr.length; i++) {
							File file = new File(beanCacheDir, beanFilesStr[i]);
							try {
								if (currentTime - file.lastModified() > 1000L * 60 * 60 * 24 * 30) {
									file.delete();
								}
							} catch (Exception e2) {
								Log.e("Sdebug", "Cleanup thread Exception!!!", e2);
								continue;
							}
						}
					}
				} catch(Exception e) {
					// just ignore
					Log.e("Sdebug", "Cleanup thread Exception!!!", e);
				}
				Log.i("Sdebug", "Cleanup thread done!!!");
			};
		}.start();
		
		// 添加快捷方式，如果没有安装快捷方式的话
		addShortcut();
	}
	
	
	
	private void addShortcut(){
		 boolean isShortCutInstalled = PreferenceManager.getDefaultSharedPreferences(this).getBoolean("isShortCutInstalled", false);
				 
		 if (!isShortCutInstalled) {
			 //创建快捷方式
			 Intent shortcutIntent = new Intent(Intent.ACTION_MAIN);
			 shortcutIntent.setClassName(this, this.getClass().getName());
			 shortcutIntent.addCategory(Intent.CATEGORY_LAUNCHER);
			 Intent intent = new Intent("com.android.launcher.action.INSTALL_SHORTCUT");
			 intent.putExtra("duplicate", false); //不允许重复创建 
			 intent.putExtra(Intent.EXTRA_SHORTCUT_INTENT, shortcutIntent);
			 intent.putExtra(Intent.EXTRA_SHORTCUT_NAME, getString(R.string.app_name));
			 Parcelable iconResource = Intent.ShortcutIconResource.fromContext(this,  R.drawable.icon);
			 intent.putExtra(Intent.EXTRA_SHORTCUT_ICON_RESOURCE, iconResource);
			 sendBroadcast(intent);
//			 new WToast(this).showMessage("已创建“凤凰新闻”快捷方式");
			 PreferenceManager.getDefaultSharedPreferences(this).edit().putBoolean("isShortCutInstalled", true).commit();
		 }
	}
	
 
	@Override
	protected void onResume() {
		super.onResume();
		// 通过splash页启动时不会调用父类AppBaseActivity的onForegroundRunning方法，
		// 所以在这里记录进入应用的时间戳
		// 记录进入应用的时间，用于使用时长统计
		PreferenceManager.getDefaultSharedPreferences(this).edit().putLong("entryTime", System.currentTimeMillis()).commit();
		IfengNewsApp.isEndStatisticSent = false;
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		mainHandler.removeMessages(SKIPKEY);
		// 回收封面故事图片
		if (null != mStoryImgMge && null != mStoryImgMge.getSplashBitmap()) {
			mStoryImgMge.getSplashBitmap().recycle();
		}
	}



	public void checkUpgrade() {
		if (!Config.isUpgrader)
			return;
		isAutoForward = false;
		final File targetDir = getFileStreamPath("");
		Version atmoVersion = new Version(Config.CURRENT_CONFIG_VERSION);
		Log.i("news", "current config version = "
				+ Config.CURRENT_CONFIG_VERSION);
		SplashUpgradeHandler handler = new SplashUpgradeHandler(mIntent, this,
				"当前应用需要更新版本后才能使用,是否升级?", "发现有新的版本,是否升级?",
				Config.TARGET_PLUGIN_ZIP, new Callback() {
					@Override
					public void onDownloadDone(boolean success, Context context) {
						if (!success) {
							isNeedForward();
							return;
						}
						Log.i("news", "download pluin.zip seccess");
						new Thread() {
							public void run() {
								try {
									Zipper.unzip(Config.TARGET_PLUGIN_ZIP,
											targetDir.getAbsolutePath());
									isNeedForward();
								} catch (Exception e) {
									Log.i("news", "unzip plugin error");
								}
							}
						}.start();
					}
				});
		handler.setListener(mListener);
		Upgrader.ready(this).setCustomUpgradeHandler(handler)
				.setUpgradeUrl(ParamsManager.addParams(Config.APP_UPGRADE_URL))
				.setAtmoVersion(atmoVersion).setForwardIntent(mIntent)
				.setAtmoTargetPath(Config.TARGET_PLUGIN_ZIP).setStrict(false)
				.upgrade();
	}

	private void startUpdateSplashService() {
		Intent intent = new Intent();
		intent.setClass(this, SplashService.class);
		startService(intent);
	}

	private void init() {
//		if (MBoxAgent.isPushActivated(this)) {
//			startPush();
//		}		
		mSplashManager = new SplashManager();
		startTime = System.currentTimeMillis();
		SplashCoverUnits mUnits = null;
		try {
			mUnits = mSplashManager.getSplashUnits();
		} catch (Exception e) {
			mUnits = null;
		} finally {
			mStoryImgMge = mSplashManager.getStoryMessage(mUnits);
			if (null != mStoryImgMge)
				initStoryUI();
			else
				initDefaultUI();
		}
		AlarmSplashServiceManager.setCleanSplashImgAlarm(SplashActivity.this);
	}
	
	/**
	 * 开启激活统计
	 */
	private void beginHeartBeatStatistic(){
		Intent intent = new Intent();
		intent.setAction("com.ifeng.news2.action.HEART_BEAT");
		sendBroadcast(intent);
	}

//	private void startPush() {
//		MBoxAgent.setPushActivated(this, true);
//	}

	private void initStoryUI() {
		setContentView(layout.splash);

		metric = new DisplayMetrics();
		getWindowManager().getDefaultDisplay().getMetrics(metric);
		screenWidth = (float) metric.widthPixels;

		event_bt = (Button) findViewById(R.id.event_bt);
		splash_tv_induction = (TextView) findViewById(R.id.splash_tv_induction);
		splash_picture = (ImageView) findViewById(R.id.splash_iv);
		splash_skip = (RelativeLayout) findViewById(R.id.splash_skip);

		splash_skip.setOnTouchListener(this);
		event_bt.setOnTouchListener(this);
		event_bt.setOnClickListener(this);

		updateStoryUI();
	}

	private void updateStoryUI() {

		ItemCover itemCover = mStoryImgMge.getItem();
		splash_picture.setImageBitmap(mStoryImgMge.getSplashBitmap());
		mStoryExtension = mSplashManager.getStoryExtension(itemCover);
		if (null != mStoryExtension) {
			String title = mStoryExtension.getTitle();
			if (TextUtils.isEmpty(title)) {
				title = "";
			}
			splash_tv_induction.setText(getIntroduction(title, screenWidth,
					metric));

			float validTime = mStoryExtension.getValidSeconds();

			if (validTime > 0) {
				autoSendTime = (long) validTime * 1000L;
				Message mesage = new Message();
				mesage.what = SKIPKEY;
				mainHandler.sendMessageDelayed(mesage, autoSendTime);
			}
		} else {
		}
	}

	private void initDefaultUI() {
		setContentView(layout.welcome_for_channel);
		Message mesage = new Message();
		mesage.what = SKIPKEY;
		mainHandler.sendMessageDelayed(mesage, Config.WELCOME_FORWARD_TIME);
	}

	@Override
	public boolean onTouch(View v, MotionEvent event) {
		int action = event.getAction();
		switch (action) {
		case (MotionEvent.ACTION_DOWN):
			startX = event.getX();
			if (v.getId() == R.id.splash_skip) {
				goToNewPage();
				return true;
			}
			break;
		case (MotionEvent.ACTION_MOVE):
			endX = event.getX();
			if ((startX - endX) > 50) {
				if (firstComeIn) {
					goToNewPage();
				}
				firstComeIn = false;
				return true;
			}
			break;
		}
		return false;
	}

	@Override
	public void onClick(View v) {
		if (!firstComeIn) {
			return;
		}
		ItemCover itemCover = mStoryImgMge.getItem();
		Extension linkExtension = null;
		try {
			linkExtension = itemCover.getLinks().get(0);
		} catch (Exception e) {
		}

		if (null == linkExtension) {
			Extension extension = new Extension();
			extension.setType("doc");
			extension.setDocumentId(itemCover.getDocumentId());
			goToNewPageOrFinish(extension);
		} else {
			// 1---代表可以跳转
			if ("1".equals(mStoryExtension.getIsLinkable())) {
				isAutoForward = false;
				goToNewPageOrFinish(linkExtension);
			}
		}
	}

	private void goToNewPageOrFinish(Extension defaultExtension) {
		if (!IntentUtil.startActivityByExtension(this, defaultExtension,
				IntentUtil.FLAG_REDIRECT_HOME)) {
			goToNewPage();
		} else {
		// 如果跳转成功就结束Splash页，否则在强制升级时会退不出应用
			tryFinish();
		}
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}

	public String getIntroduction(String intr, float screenWidth,
			DisplayMetrics metric) {
		if (TextUtils.isEmpty(intr))
			return "";
		String introduction = intr.trim();
		int font = ReviewManager.sp2px(
				Float.parseFloat(getResources().getString(
						R.string.splash_introduction_font)),
				metric.scaledDensity);
		int leftWidth = ReviewManager.sp2px(
				Float.parseFloat(getResources().getString(
						R.string.splash_introduction_leftWidth)),
				metric.density);
		int rightWidth = ReviewManager.sp2px(
				Float.parseFloat(getResources().getString(
						R.string.splash_introduction_rightWidth)),
				metric.density);

		ContentResolver cv = getContentResolver();
		float font_scale = 1f;
		try {
			font_scale = android.provider.Settings.System.getFloat(cv,
					android.provider.Settings.System.FONT_SCALE);
		} catch (Exception e) {
		}
		font *= font_scale;

		int count = (int) ((screenWidth - leftWidth - rightWidth) / font);
		int availableNum = count * 2 - count / 2;
		if (introduction.length() > availableNum)
			introduction = introduction.substring(0, availableNum - 2) + "…";

		return introduction;
	}

	public Extension getDefaultExtension(ItemCover itemCover) {
		if (itemCover == null)
			return null;
		for (Extension extension : itemCover.getExtensions()) {
			if ("1".equals(extension.getIsDefault())) {
				return extension;
			}
		}
		return null;
	}

	public Extension getStoryExtension(ItemCover itemCover) {
		if (itemCover == null)
			return null;
		for (Extension extension : itemCover.getExtensions()) {
			if ("story".equals(extension.getType())) {
				return extension;
			}
		}
		return null;
	}

	private void isNeedForward() {
		long intervalTime = System.currentTimeMillis() - startTime;
		if (isEnd)
			return;
		if (autoSendTime == 0) {// 第一次启动
			if (intervalTime >= Config.WELCOME_FORWARD_TIME
					&& !Config.IS_FINSIH_PULL_SKIP) {
				goToNewPage();
			} else {
				isAutoForward = true;
			}
		} else {
			if (intervalTime >= autoSendTime && !Config.IS_FINSIH_PULL_SKIP) {
				goToNewPage();
			} else {
				isAutoForward = true;
			}
		}
	}

	private void tryFinish() {
		if (!isFinishing()) {
			isAutoForward = false;
			isEnd = true;
			finish();
		}
	}

	private synchronized void goToNewPage() {
		// if (restart_tag != RestartManager.RESTAET_TAG) {
		if(isEnd){
			return;
		}
		startActivity(mIntent);
		overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
		// }
		tryFinish();
	}
}
