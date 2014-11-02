package com.ifeng.news2.fragment;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.view.animation.AnimationUtils;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RemoteViews;
import android.widget.TextView;
import android.widget.Toast;

import com.ifeng.ipush.client.Ipush;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengLoadableFragment;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.R.id;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.activity.AccountBindActivity;
import com.ifeng.news2.activity.CollectionActivity;
import com.ifeng.news2.activity.FontSizeActivity;
import com.ifeng.news2.activity.HistoryMessageActivity;
import com.ifeng.news2.activity.WeatherActivity;
import com.ifeng.news2.bean.WeatherBean;
import com.ifeng.news2.bean.WeatherBeans;
import com.ifeng.news2.commons.upgrade.download.GroundReceiver;
import com.ifeng.news2.push.PushUtils;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.IfengAlertDialog;
import com.ifeng.news2.util.OfflineDownloadManager;
import com.ifeng.news2.util.OfflineDownloadManager.OffineManagerCallback;
import com.ifeng.news2.util.PhotoModeUtil;
import com.ifeng.news2.util.PhotoModeUtil.PhotoMode;
import com.ifeng.news2.util.SettingFileUtils;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticPageType;
import com.ifeng.news2.util.StatisticUtil.StatisticRecordAction;
import com.ifeng.news2.util.UpgradeProxy;
import com.ifeng.news2.util.UpgradeProxy.CheckListener;
import com.ifeng.news2.util.WindowPrompt;
import com.ifeng.news2.weather.WeatherManager;
import com.ifeng.news2.widget.GifView;
import com.ifeng.news2.widget.ScrollerViewWithFlingDetector;
import com.ifeng.share.util.NetworkState;
import com.qad.lang.util.Texts;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.util.NotificationBuilder;
import com.qad.util.OnFlingListener;
import com.qad.util.Utils;

public class SettingFragment extends Fragment implements OnClickListener,
		OnFlingListener, OffineManagerCallback {

	protected static final int CLEAR_SUCCESS = 0;

	protected static final int CLEAR_NONEED = 1;

	protected static final int FILE_CACULATE_COMPLETE = 2;
	
	private static final int OFFLINE_DOWNLOAD_COMPLETE = 3 ; 

	protected static final int OFFLINE_NOTIFICATION = 100;
	private View settingWrapper;
	public boolean enableUpgrade = true;
	
	// 是否正在清除缓存中
	private boolean isClearing = false;
	private View history;
	private View collection;
	private View offline;
	private CheckBox switchPush;
	private CheckBox switchNon_disturb;
	private CheckBox switchNo_photo;
	private View count_bind;
	private View font_size;
	private View clearCache;
	private TextView cacheInfo;
	private View feedback;
	private View checkEdition;
	private TextView currentEdition;
	private TextView checkTitle;
	private ImageView checkIcon;
	private GifView loadingGif;
	private View weatherLayout;
	private TextView weatherCity;
	private ImageView weatherIcon;
	private TextView weatherTemperature;
	private NewsMasterFragmentActivity context;
	private static boolean isRunningWeather = false;
	private static WeatherBean todayWeather;

	// 需要监听点击事件的控件
	private View[] clickViews;

	private SharedPreferences sharedPreferences;

	private TextView percentage;

//	private ProgressBar offlineBar;

	private ImageView cancel;

	private View offlineIng;

	private ProgressBar clearCachePb;

	private UpdateHandler handler;

	private ImageView settingButton;

	private ScrollerViewWithFlingDetector scroller;

	private TextView nonDisturb_msg;

//	private ImageView nonDisturb_img;

	private TextView offlingTitle;
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		settingWrapper = inflater.inflate(layout.new_setting, null);
		return settingWrapper;
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		// 初始化控件，给需要监听事件的控件设置监听
		initView();
		// 初始化天气信息
		initWeather();
		// 初始化设置信息
		initSettingInfo();
	}

	private void initView() {
		scroller = (ScrollerViewWithFlingDetector) findViewById(R.id.scrollerView);
		context = (NewsMasterFragmentActivity) getActivity();
		windowPrompt = WindowPrompt.getInstance(context);
		
		history = findViewById(R.id.history_model);
		collection = findViewById(R.id.collection_model);
		settingButton = (ImageView) findViewById(R.id.settingButton);

		offline = findViewById(R.id.offline_model);
		offlineIng = findViewById(R.id.offline_downLoad);
		offlineIng.setVisibility(View.GONE);
		percentage = (TextView) findViewById(R.id.percentage);
		offlingTitle = (TextView) findViewById(R.id.offling_txt);
		cancel = (ImageView) findViewById(R.id.cancel_offline);

	
		switchPush = (CheckBox) findViewById(R.id.switch_push);

		switchNon_disturb = (CheckBox) findViewById(R.id.switch_non_disturb);
		nonDisturb_msg = (TextView) findViewById(R.id.non_disturb_msg);
//		nonDisturb_img = (ImageView) findViewById(R.id.non_disturb_img);

		switchNo_photo = (CheckBox) findViewById(R.id.switch_no_photo);
		font_size = findViewById(R.id.font_size);
		count_bind = findViewById(R.id.bind);
		clearCache = findViewById(R.id.clear_cache);
		clearCachePb = (ProgressBar) findViewById(R.id.cache_pb);
		clearCachePb.setVisibility(View.GONE);
		cacheInfo = (TextView) findViewById(R.id.cache);
		feedback = findViewById(R.id.feedback);

		checkEdition = findViewById(R.id.check_edition);
		currentEdition = (TextView) findViewById(R.id.current_edition);
		checkIcon = (ImageView) findViewById(R.id.check_icon);
		loadingGif = (GifView) findViewById(R.id.loading_gif);
		checkTitle = (TextView) findViewById(R.id.check_title);

		weatherLayout = findViewById(id.weather_layout);
		weatherCity = (TextView) findViewById(id.weather_city);
		weatherIcon = (ImageView) findViewById(id.weather_icon);
		weatherTemperature = (TextView) findViewById(id.weather_temperature);

		clickViews = new View[] { history, collection, offline, switchPush,
				switchNon_disturb, switchNo_photo, weatherLayout, checkEdition,feedback, clearCache,
				count_bind, font_size,cancel, settingButton };
		setOnClickListener(clickViews);
		scroller.setOnFlingListener(this);
	}

	/**
	 * 找到视图内指定id的控件的简便方法
	 * 
	 * @param resId
	 * @return
	 */
	private View findViewById(int resId) {
		return settingWrapper.findViewById(resId);
	}

	/**
	 * 将控件设置监听
	 * 
	 * @param resIds
	 */
	private void setOnClickListener(View... views) {
		for (View view : views) {
			view.setOnClickListener(this);
		}
	}
	
	/**
	 * 设置按钮动画
	 */
	public void startSettingBtnAnim(){
		AlphaAnimation animation = (AlphaAnimation) AnimationUtils.loadAnimation(context, R.anim.setting_button_anim);
		settingButton.startAnimation(animation);
		if (checkTitle != null) {
		  checkTitle.setText(R.string.check_edition);
        }
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		// 跳转到天气页面
		case R.id.weather_layout:
			Intent intent = new Intent(context, WeatherActivity.class);
			startActivityForResult(intent, 0);
			context.overridePendingTransition(R.anim.in_from_right,
					R.anim.out_to_left);
			break;
		// 跳转到凤凰快讯页面
		case R.id.history_model:
			redirectTo(HistoryMessageActivity.class, null);
			break;
		// 跳转到收藏页面
		case R.id.collection_model:
			redirectTo(CollectionActivity.class, null);
			break;
		// 跳转到账号绑定页面
		case R.id.bind:
			redirectTo(AccountBindActivity.class, null);
			break;
		// 推送开关（打开/关闭）
		case R.id.switch_push:
			setPushSwitch();
			break;
		// 夜间免打扰开关（打开/关闭）
		case R.id.switch_non_disturb:
			setNondisturb();
			break;
		// 无图模式开关（打开/关闭）
		case R.id.switch_no_photo:
			setNoPhoto();
			break;
		// 跳转到字体大小页面
		case R.id.font_size:
			redirectTo(FontSizeActivity.class, null);
			break;		
		// 意见反馈
		case R.id.feedback:
			goToFeedback();
			break;
		// 检查新版本
		case R.id.check_edition:
		    if(GroundReceiver.UPGRADING){
		      Toast.makeText(getActivity(), "正在下载", Toast.LENGTH_SHORT).show();
		    } else {
		      checkUpgrade();
		    }
			break;
		// 离线下载
		case R.id.offline_model:
			startOfflineDownload();
			break;
		// 取消离线下载
		case R.id.cancel_offline:
			if (!OfflineDownloadManager.isInstanceDestoryed()) {
				OfflineDownloadManager.getInstance(this).cancelOffline();
			}
			break;
		// 清除缓存
		case R.id.clear_cache:
			clearCache();
			break;
		// 返回频道列表
		case R.id.settingButton:
			context.showLeftView();
			break;
		default:
			break;
		}
	}

	/**
	 * 清除缓存,并且更新进度条
	 */
	private void clearCache() {
		String size = cacheInfo.getText().toString();
		if (size.equals("计算中...")) {
			context.showMessage("计算中，请稍候");
		} else if (!isClearing && !size.equals("0KB")) {
			isClearing = true;
			clearCachePb.setVisibility(View.VISIBLE);
			new Thread(new Runnable() {
				@Override
				public void run() {
					// 只要有一个目录删除成功，就不提示删除失败。
					try {
						SettingFileUtils.deleteDirAndUpdateProgressBar(
								clearCachePb, Config.FOLDER_DATA,
								Config.APP_CACHE);
						// 清除内存缓存
						IfengNewsApp.getMixedCacheManager().clearPrivateCache();
						handler.sendEmptyMessage(CLEAR_SUCCESS);
					} catch (Exception e) {
						Log.w("Sdebug", "exception while cleaning the cache", e);
						handler.sendEmptyMessage(CLEAR_NONEED);
					} finally {
						IfengNewsApp.getMixedCacheManager().setupDirs();
						IfengNewsApp.getResourceCacheManager().setupDirs();
					}
				}
			}).start();
		}
	}

	private void startOfflineDownload() {
		if (!NetworkState.isActiveNetworkConnected(context)) {			
			windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
		} else if (NetworkState.isWifiNetworkConnected(context)) { // 只有WIFI下才直接离线
			executeOfflineDownload();
		} else if (NetworkState.isMobileNetworkConnected(context)) {
			IfengAlertDialog.CreateDialog(context, "离线下载", "检测到当前为移动网络,是否确认离线?", "确定", "取消", new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					executeOfflineDownload();
				}
			}, null);
		}
	}

	/**
	 * 开始离线下载
	 */
	private void executeOfflineDownload() {
		// 正在离线下载
		if (OfflineDownloadManager.isInstanceDestoryed()) {
			StatisticUtil.addRecord(context,
					StatisticUtil.StatisticRecordAction.od, null);
			OfflineDownloadManager.getInstance(SettingFragment.this)
					.startPrefetch();
		}
	}

	/**
	 * 下载完成后显示通知栏
	 */
	private void showNotification() {
		NotificationManager nm = (NotificationManager) context
				.getSystemService(Context.NOTIFICATION_SERVICE);
		Intent updateIntent = new Intent();
		updateIntent.setAction(Intent.ACTION_MAIN);
		updateIntent.setComponent(new ComponentName(context.getPackageName(),
				context.getClass().getName()));
		updateIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		updateIntent.addCategory(Intent.CATEGORY_LAUNCHER);
		PendingIntent updatePendingIntent = PendingIntent.getActivity(context,
				0, updateIntent, PendingIntent.FLAG_UPDATE_CURRENT);
		RemoteViews remoteView = new RemoteViews(context.getPackageName(),
				R.layout.offine_notification);
		remoteView.setOnClickPendingIntent(R.id.image, updatePendingIntent);
		Notification notification = new NotificationBuilder(context)
				.setContentTitle("凤凰新闻").setSmallIcon(R.drawable.offline_icon)
				.setAutoCancel(false).setContent(remoteView)
				.setTicker("凤凰新闻离线完成").setContentIntent(updatePendingIntent)
				.getNotification();
		notification.flags |= Notification.FLAG_AUTO_CANCEL;
		nm.notify(OFFLINE_NOTIFICATION, notification);
	}

	@Override
	public void onResume() {
		super.onResume();
		// 如果没有正在清除缓存中，则重新初始化缓存信息
		if (!isClearing) {
			initCacheInfo();
		}
		if(StatisticUtil.isBack && ConstantManager.isSettingsShow){
			StatisticUtil.addRecord(this.getActivity()
					, StatisticUtil.StatisticRecordAction.page
					, "id=ys$ref=back"+"$type=" + StatisticUtil.StatisticPageType.set);
			StatisticUtil.isBack = false;
			ConstantManager.isSettingsShow = false;
		}
	}

	/**
	 * 检查新版本
	 */
	private void checkUpgrade() {
	  /*if (!enableUpgrade) {
        return;
      }*/
	  loadingGif.setVisibility(View.VISIBLE);
	  checkIcon.setVisibility(View.GONE);
	  checkTitle.setText(R.string.check_editioning);
	  UpgradeProxy.createManualUpgradeProxy().checkUpgrade(context,
	    new CheckListener() {

	    @Override
	    public void noNeedUpgrade() { 
	      loadingGif.setVisibility(View.GONE);
          checkIcon.setVisibility(View.VISIBLE);
          checkTitle.setText(R.string.check_editioned);
//	      enableUpgrade = false;
//	      myHandler.sendEmptyMessageDelayed(1, 3000);
	    }

	    @Override
	    public void errorCheck() {
	      loadingGif.setVisibility(View.GONE);
	      checkIcon.setVisibility(View.VISIBLE);
	      checkTitle.setText(R.string.check_edition);
	      windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
	    }

	    @Override
	    public void needUpgrade() {
	      loadingGif.setVisibility(View.GONE);
	      checkIcon.setVisibility(View.VISIBLE);
	      checkTitle.setText(R.string.check_edition);
	    }

	  });
	}

	/*Handler myHandler = new Handler(new Handler.Callback() {

	  @Override
	  public boolean handleMessage(Message msg) {
	    try {
	      if (msg.what == 1) {
	        loadingGif.setVisibility(View.GONE);
	        checkIcon.setVisibility(View.VISIBLE);
	        checkTitle.setText(R.string.check_edition);
	        enableUpgrade = true;
	      }
        } catch (Exception e) {
        }
	    return false;
	  }
	});*/

	private WindowPrompt windowPrompt;
	
	/**
	 * 跳转到意见反馈界面
	 */
	private void goToFeedback() {
		IfengNewsApp.shouldRestart = false;
		Uri uri = Uri.parse("mailto:"
				+ getResources().getString(R.string.feed_back_email)
				+ "?subject=" + getResources().getString(R.string.feed_back)
				+ "&body=" + buildInfo());
		Intent intent = new Intent(Intent.ACTION_SENDTO, uri);
		if (context.getPackageManager().queryIntentActivities(intent, 0).size() <= 0) {
			context.showMessage("您没有可用的邮箱程序，暂时无法进行反馈");
		} else {
			startActivity(intent);
		}
	}

	/**
	 * 设置无图模式开关的打开关闭处理
	 */
	private void setNoPhoto() {
		if (!switchNo_photo.isChecked()) {
			PhotoModeUtil.setPhotoMode(context, PhotoMode.VISIBLE_PATTERN);
		} else {
			showNoPicDialog();
		}
		
	}
	
	/**
	 * 开启无图模式的dialog
	 */
	private void showNoPicDialog(){
		String title = "要开启无图模式么?";
		String message = "为了照顾流量不够的读者们，我们会自动在2G/3G网络下不显示图片。";
		String positive = "开启无图";
		String negative = "不需要";
		IfengAlertDialog.CreateDialog(context, title, message, positive, negative, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				PhotoModeUtil.setPhotoMode(context, PhotoMode.INVISIBLE_PATTERN);
				//无图模式使用统计
				StatisticUtil.addRecord(context, StatisticRecordAction.action, "type="+StatisticPageType.dispic);
			}
		}, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switchNo_photo.setChecked(false);
			}
		});
	}

	/**
	 * 设置夜间免打扰开关的打开关闭处理
	 */
	private void setNondisturb() {
		if (!switchNon_disturb.isChecked()) {
			save("non_disturbance", false);
		} else {
			save("non_disturbance", true);
		}
	}

	/**
	 * 屏蔽夜间免打扰模式开关
	 */
	private void disableNonDisturbSwitcher() {
		switchNon_disturb.setBackgroundResource(R.drawable.setting_disable_check_box);
		switchNon_disturb.setClickable(false);
		nonDisturb_msg.setTextColor(context.getResources().getColor(
				R.color.disable_text_color));
		nonDisturb_msg.getCompoundDrawables()[0].setAlpha(60);
	}

	/**
	 * 激活夜间免打扰模式开关
	 */
	private void enableNonDisturbSwitcher() { 
		switchNon_disturb.setBackgroundResource(R.drawable.setting_check_box);	
		switchNon_disturb.setClickable(true);
		nonDisturb_msg.setTextColor(context.getResources().getColor(
				R.color.setting_title_color));
		nonDisturb_msg.getCompoundDrawables()[0].setAlpha(255);
	}

	/**
	 * 设置推送开关的打开关闭处理
	 */
	private void setPushSwitch() {
		if (!switchPush.isChecked()) {
			String title = "确定关闭推送么?";
			String message = "专业编辑每天为您搜集全球最新资讯，热门视频，热辣评论。";
			String positive = "关闭推送";
			String negative = "取消";			
			IfengAlertDialog.CreateDialog(context, title, message, positive, negative, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					// 屏蔽夜间免打扰开关
					disableNonDisturbSwitcher();

					PushUtils.setPushActivated(context, false);
					Ipush.stopService(context);
					StatisticUtil
							.addRecord(
									StatisticUtil.StatisticRecordAction.pushoff,
									null);
				}
			}, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					switchPush.setChecked(true);
				}
			});
		} else {
			// 开启夜间免打扰模式开关
			enableNonDisturbSwitcher();
			PushUtils.setPushActivated(context, true);
			Ipush.resumeService(context);
			StatisticUtil.addRecord(StatisticUtil.StatisticRecordAction.pushon,
					null);
		}
	}

	/**
	 * 跳转到指定的其他页面
	 * 
	 * @param targetClass
	 */
	private void redirectTo(Class<? extends Activity> targetClass, Bundle bundle) {
		Intent intent = new Intent(context, targetClass);
		if (bundle != null) {
			intent.putExtras(bundle);
		}
		context.startActivity(intent);
		context.overridePendingTransition(R.anim.in_from_right,
				R.anim.out_to_left);
	}

	/**
	 * 初始化天气信息
	 */
	private void initWeather() {
		if (!isRunningWeather) {
			loadWeatherInfo();
		}
	}

	/**
	 * 初始化设置信息
	 */
	private void initSettingInfo() {
		handler = new UpdateHandler();
		sharedPreferences = PreferenceManager
				.getDefaultSharedPreferences(context);
		// 初始化当前版本信息
		initCurrentEdition();
		// 初始化用户保存的配置
		initSetting();
		// 初始化缓存大小信息
		// initCacheInfo();
	}

	/**
	 * 重置无图模式
	 */
	public void resetNophotoMode() {
		boolean isOpen = checkSaved("loadImage2") ? false : true;
		switchNo_photo.setChecked(isOpen);
	}

	/**
	 * 初始化用户保存的配置
	 */
	private void initSetting() {
		// 初始化夜间免打扰开关
		boolean isOpen = checkSaved("non_disturbance");
		switchNon_disturb.setChecked(isOpen);
		// 初始化推送开关
		isOpen = PushUtils.isPushActivated(context);
		switchPush.setChecked(isOpen);
		if (isOpen) {
			enableNonDisturbSwitcher();
		} else {
			disableNonDisturbSwitcher();
		}

		// 初始化无图模式开关
		isOpen = checkSaved("loadImage2") ? false : true;
		switchNo_photo.setChecked(isOpen);

	}

	private String buildInfo() {
		return "系统:" + Utils.getPlatform() + "\n" + "渠道:" + Config.PUBLISH_ID
				+ "\n" + "版本:" + Utils.getSoftwareVersion(context) + "\n"
				+ "机型:" + Utils.getUserAgent(context) + "\n";
	}

	/**
	 * 初始化当前版本信息
	 */
	private void initCurrentEdition() {
		StringBuilder softwareVersion = new StringBuilder();
		softwareVersion.append(
				getResources().getString(R.string.current_edition)).append(
				Utils.getSoftwareVersion(context));
		currentEdition.setText(softwareVersion.toString());
	}

	/**
	 * 根据key判断用户是否设置
	 * 
	 * @param key
	 * @return
	 */
	private boolean checkSaved(String key) {
		return sharedPreferences.getBoolean(key, true);
	}

	/**
	 * 保存设置
	 * 
	 * @param key
	 * @param save
	 */
	private void save(String key, boolean save) {
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putBoolean(key, save);
		editor.commit();
	}

	/**
	 * 界面右滑返回头条页
	 * 
	 * @param flingState
	 */
	@Override
	public void onFling(int flingState) {
		if (flingState == FLING_LEFT) {
			context.showLeftView();
		}
	}

	@SuppressLint("HandlerLeak")
	private class UpdateHandler extends Handler {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case CLEAR_SUCCESS:
				isClearing = false;
				cacheInfo.setText("0KB");
				if (clearCachePb.getVisibility() == View.VISIBLE) {
					clearCachePb.setVisibility(View.GONE);
				}
				break;
			case CLEAR_NONEED:
				isClearing = false;
				context.showMessage("所删除的文件不存在");
				if (clearCachePb.getVisibility() == View.VISIBLE) {
					clearCachePb.setVisibility(View.GONE);
				}
				break;
			case FILE_CACULATE_COMPLETE:
				String result = (String) msg.obj;
				cacheInfo.setText(result);
				break;
			case OFFLINE_DOWNLOAD_COMPLETE:
				resetOfflineView();
				showNotification();
				break;
			default:
				break;
			}
			super.handleMessage(msg);
		}
	}

	private void loadWeatherInfo() {
		isRunningWeather = true;
		// fix bug #18123 【启动】联想S820在2G网络下，启动时黑屏很长时间。
		// 不应在主线程进行网络操作
		new Thread() {
			public void run() {
				String city = WeatherManager.getChooseCity(context);
				if (!TextUtils.isEmpty(city)) {
					IfengNewsApp
							.getBeanLoader()
							.startLoading(
									new LoadContext<String, LoadListener<WeatherBeans>, WeatherBeans>(
											WeatherManager
													.getWeatherDetailUrl(city),
											new LoadListener<WeatherBeans>() {

												@Override
												public void postExecut(
														LoadContext<?, ?, WeatherBeans> context) {
													isRunningWeather = false;
													if (context.getResult() == null
															|| context
																	.getResult()
																	.size() < 7) {
														context.setResult(null);
													}
												}

												@Override
												public void loadComplete(
														LoadContext<?, ?, WeatherBeans> context) {
													todayWeather = context
															.getResult().get(0);
													updateTodayWeather(todayWeather);
												}

												@Override
												public void loadFail(
														LoadContext<?, ?, WeatherBeans> context) {
												}

											}, WeatherBeans.class, Parsers
													.newWeatherBeansParser(),
											LoadContext.FLAG_HTTP_FIRST, true));
				}
			};
		}.start();

	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode == 100) {
			WeatherBean result = (WeatherBean) data
					.getSerializableExtra("todayWeather");
			if (result != null && !isRunningWeather) {
				todayWeather = result;
				updateTodayWeather(todayWeather);
			}
		}
		super.onActivityResult(requestCode, resultCode, data);
	}

	private void updateTodayWeather(WeatherBean todayWeather) {
		if (todayWeather != null) {
			Drawable weatherDrawable = WeatherManager.getWeatherIndexDrawable(
					context, todayWeather);
			if (weatherDrawable != null) {
				String city = todayWeather.getCity_name();
				String temperature = WeatherManager
						.getTemperatureText(todayWeather);
				weatherIcon.setImageDrawable(weatherDrawable);
				if (!TextUtils.isEmpty(temperature)) {
					weatherTemperature.setVisibility(View.VISIBLE);
					weatherTemperature.setText(temperature);
				}
				if (!TextUtils.isEmpty(city)) {
					weatherCity.setVisibility(View.VISIBLE);
					weatherCity.setText(city);
				}
			}
		}
	}

	/**
	 * 初始化缓存大小信息
	 */
	private void initCacheInfo() {
		cacheInfo.setText("计算中");
		new Thread(new Runnable() {

			@Override
			public void run() {
				String size = Texts.formatSize(SettingFileUtils.getFileSize(
						Config.FOLDER_DATA, Config.APP_CACHE));
				Config.APP_CACHE.length();
				if (size.trim().equals("0.00B")) {
					size = "0KB";
				}
				Message message = new Message();
				message.what = FILE_CACULATE_COMPLETE;
				message.obj = size;
				handler.sendMessage(message);
			}
		}).start();
	}

	private void resetOfflineView() {
		percentage.setText("0%");
//		offlineBar.setProgress(0);
		offlineIng.setVisibility(View.GONE);
		offline.setVisibility(View.VISIBLE);
	}

	@Override
	public void updateProgress(int progress) {
		if (progress == 0) {
			offline.setVisibility(View.GONE);
			offlineIng.setVisibility(View.VISIBLE);
		}
//		offlineBar.setProgress(progress);
		offlingTitle.setText("正在载入...");
		percentage.setText(progress + "%");
	}

	@Override
	public void onComplete() {
		offlingTitle.setText("完成");
		percentage.setText("100%");
		handler.sendEmptyMessageDelayed(OFFLINE_DOWNLOAD_COMPLETE, 1000);
		
	}

	@Override
	public void onFail() {
		resetOfflineView();
		context.showMessage("离线新闻下载失败");
	}

	@Override
	public void onCancel() {
		context.showMessage("已取消下载离线新闻");
		resetOfflineView();
	}

}
