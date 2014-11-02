package com.ifeng.news2;


import android.annotation.TargetApi;
import android.app.Activity;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnErrorListener;
import android.media.MediaPlayer.OnPreparedListener;
import android.net.Uri;
import android.os.Build;
import android.os.Process;
import android.preference.PreferenceManager;
import android.util.DisplayMetrics;
import android.util.Log;
import com.google.myjson.Gson;
import com.ifeng.ipush.client.Ipush;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.id;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.bean.DocUnit;
import com.ifeng.news2.bean.SlideItem;
import com.ifeng.news2.commons.statistic.Statistics;
import com.ifeng.news2.commons.upgrade.UpgradeNotify;
import com.ifeng.news2.exception.SendErrorReportService;
import com.ifeng.news2.plutus.android.PlutusAndroidManager;
import com.ifeng.news2.plutus.android.PlutusAndroidManager.PlutusAndroidListener;
import com.ifeng.news2.plutus.android.view.ExposureHandler;
import com.ifeng.news2.plutus.core.Constants;
import com.ifeng.news2.plutus.core.Constants.ERROR;
import com.ifeng.news2.plutus.core.model.bean.AdMaterial;
import com.ifeng.news2.plutus.core.model.bean.PlutusBean;
import com.ifeng.news2.push.PushUtils;
import com.ifeng.news2.util.ConfigManager;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.share.config.ShareConfig;
import com.qad.app.BaseApplication;
import com.qad.cache.MixedCacheManager;
import com.qad.cache.ResourceCacheManager;
import com.qad.inject.PreferenceInjector;
import com.qad.loader.BeanLoader;
import com.qad.loader.ImageLoader;
import com.qad.loader.Settings;
import com.qad.net.ApnManager;
import com.qad.system.PhoneManager;
import com.qad.util.LogHandler;
import com.qad.util.Utils;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.tencent.tauth.Tencent;
import im.yixin.sdk.api.YXAPIFactory;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@UpgradeNotify(updateTitle = "正在下载最新安装包", layout_update = layout.notify_download, drawable_start_icon = drawable.icon_ifeng_down_start, drawable_update_icon = drawable.icon_ifeng_download, drawable_success_icon = drawable.icon, drawable_fail_icon = drawable.icon, id_progressbar = id.offline_down_pb, id_title = id.offline_down_title, id_percent = id.offline_down_percent)
public class IfengNewsApp extends BaseApplication {

	private static final String TAG = "IfengNewsApp";
	public boolean isPlayed = false;//是否播放过测试视频
	private static BeanLoader beanLoader;
	private ArrayList<SlideItem> slideItems;
	private ArrayList<DocUnit> currentDocUnits;
	private DisplayMetrics display;
	public static long lockTime = 0;
	public static boolean shouldRestart = true;
	public static boolean backFromPushOrWidget = false;
	
	private SharedPreferences sp;
	private MediaPlayer player;
	// 标识是否发送过了end统计，以解决bug #17927
	public static boolean isEndStatisticSent = true;
	// 标识是否在主进程，以区分widget和external进程
	public static boolean isMainProcess = true;
	
	private PlutusAndroidListener<ArrayList<PlutusBean>> plutusAndroidListener = new PlutusAndroidListener<ArrayList<PlutusBean>>() {

        @Override
        public void onPostStart() {
        }

        @Override
        public void onPostComplete(ArrayList<PlutusBean> result) {
        	if(result != null && !result.isEmpty()){
        		for(PlutusBean bean : result){
        			if (bean != null && bean.getFilteredAdMaterial().size() > 0) {
            			final AdMaterial material = bean.getAdMaterials().get(0);
            			//文字链广告
            			if("10000001".equals(bean.getAdPositionId())) {
            				Config.TEXT_AD_ID01 = material.getAdId();
            				ExposureHandler.putInQueue(Config.TEXT_AD_ID01);
            				Config.TEXT_AD_DATA01 = new Gson().toJson(material);
            			}
            			// 新增正文文字链广告
            			else if("10000026".equals(bean.getAdPositionId())) {
            				Config.TEXT_AD_ID02 = material.getAdId();
            				ExposureHandler.putInQueue(Config.TEXT_AD_ID02);
            				Config.TEXT_AD_DATA02 = new Gson().toJson(material);
            			}
            			//正文底部banner广告
            			else if("10000021".equals(bean.getAdPositionId())) {
            				//下载banner广告图片
            				//将广告内容以json字符串形式存储
            				StringBuilder builder = new StringBuilder();
            				builder.append("{\"imgPath\":\"\",")      															
            				.append("\"imgUrl\":\"")
            				.append(material.getImageURL())
            				.append("\",\"type\":\"")       															  
            				.append(material.getAdAction().getType())
            				.append("\",\"url\":\"")
            				.append(material.getAdAction().getUrl())
            				.append("\"}");
            				Config.BANNER_DATA = builder.toString();
            				Config.BANNER_ADID = material.getAdId();
            				ExposureHandler.putInQueue(Config.BANNER_ADID);
    	        		}             
    	        	}
    	        }
        	}
        }

        @Override
        public void onPostFailed(ERROR error) {
        	Log.w("Sdebug", "IfengNewsApp.plutusAndroidListener onPostFailed: " + error.toString());
        }
    };
	

	@TargetApi(Build.VERSION_CODES.GINGERBREAD)
	@Override
	public void onCreate() {
//		Log.e("Sdebug", "IfengNews onCreate called");
		super.onCreate();
		
		Context ctx = getApplicationContext();

// 去掉消息盒子，删除不需要的代码
		// bug fix #15909 同一个点的统计日志被发送两遍
		// 原因是启动消息盒子进程时也会调用IfengNewsApp的初始化，导致在存在文件中的统计信息被发送两遍
		// TODO: 下版若去掉消息盒子，这部分代码应该删除
		int id = Process.myPid();
        

        ActivityManager actvityManager = (ActivityManager)ctx.getSystemService( ctx.ACTIVITY_SERVICE );
        List<RunningAppProcessInfo> procInfos = actvityManager.getRunningAppProcesses();

        for(RunningAppProcessInfo procInfo : procInfos) {
            if (id == procInfo.pid)
            {
            	if (procInfo.processName != null && 
            			(procInfo.processName.equals("com.ifeng.news2:external")
            			|| procInfo.processName.equals("com.ifeng.news2:widget"))) {
            		isMainProcess = false;
            		Log.i("Sdebug", "in external or widget process, process name is " + procInfo.processName);
            	}
            }
        }

		
		initConfig();
		regToYX();
		regToQQ();
		regToWX();
		
		// 注册广播，初始化代理设置
		PhoneManager.getInstance(this).registerSystemReceiver();
		PhoneManager.getInstance(this).addOnNetWorkChangeListener(
				ApnManager.getInstance(this));
		
//		if (isMainProcess) {// bug fix #15909 同一个点的统计日志被发送两遍
			// 统计相关初始化
			StatisticUtil.beginRecord(ctx);
//		}

		// 在线日志相关初始化, 初始化后传入渠道号，因为LogHandler在QAD包内不能直接获得渠道号
//		LogHandler.initialize(ctx).setPublishId(Config.PUBLISH_ID);
		
		//ensureDefaultPreference(xml.setting);
		if (isDebugMode()) {
//			Log.w("Sdebug", "debug mode!!!");
			if (Utils.hasGingerbread()) {
//				StrictMode.setThreadPolicy(new StrictMode.ThreadPolicy.Builder() 
//		        .detectAll() 
//		        .penaltyLog()
//		        .build());
//				
//				StrictMode.setVmPolicy(new StrictMode.VmPolicy.Builder()
//				.detectAll() 
//				.penaltyLog() 
//				.build());
			}
		}
		PreferenceInjector.inject(this, this);
		
		ConfigManager.initConfig(this); // 读取url配置
        ParamsManager.initParams(this); // 初始化默认参数
        
        // init adv
        if (isMainProcess) {
	        	initAdvInfo();
	        
	        
	        // init IPush
	//        if (!isPushProcess) {
	        	if(!Config.isDEGUG){
	        		Ipush.init(this, 2, false);
	//        		Ipush.initDebug(ctx, 2, false);
	        	}else{
	        		Ipush.initDebug(ctx, 2, false);
	        	}
	        	if (!PushUtils.isPushActivated(ctx)) {
	        		Ipush.stopService(ctx);
	        	} else if (PushUtils.isPushActivated(ctx)) {// && "PUSHSERVICE_STATE_STOPPED".equals(Ipush.getState(ctx))) {
	        		// 打开长连接
	        		Ipush.resumeService(ctx);
	        	}
	//        }
	        /*
	         * 设置长连接tag，以便未来按类别推送
	         * softv：软件版本，e.g. 4.0.5
	         * userkey: IMEI or MAC
	         * ua: 手机型号
	         * publishid: 渠道号
	         * mos: 操作系统版本
	         */
	        Ipush.setTags(ctx, Utils.getSoftwareVersion(ctx), Utils.getIMEI(ctx), Utils.getUserAgent(ctx), Config.PUBLISH_ID, Utils.getPlatform());
	        
	        initCatchRunException();
	        //播放测试视频
	        playTestVideo();
	        
        }
        // 将应用context传入ImageLoader
        ImageLoader.getInstance().setAppContext(this);
	}
	
	private void regToYX(){
		// 通过YXAPIFactory工厂，获取IYXAPI的实例,将该app注册到易信
		YXAPIFactory.createYXAPI(this, Config.YX_APP_ID).registerApp();
	}
	
	private void regToQQ(){
		Tencent.createInstance(ShareConfig.TENQQ_APPID, getApplicationContext());
	}
	
	private void regToWX(){
		WXAPIFactory.createWXAPI(this, Config.WX_APP_ID,false).registerApp(Config.WX_APP_ID);
	}

	/**
	 * 10000001--正文文字链广告
	 * 10000021--正文页banner广告
	 * 10000026--新增正文文字链广告
	 */
	private void initAdvInfo(){
	    if (Config.ENABLE_ADVER) {
//            HashMap<String, String> selection = new HashMap<String, String>();
//            selection.put("select", "preLoad");
//            selection.put("position", "10000001&10000021&10000026");
            PlutusAndroidManager.init(ParamsManager.addParams("").substring(1));
            if (Config.FOLDER_DATA.exists()) {
	            PlutusAndroidManager.setCacheDir(Config.FOLDER_DATA
	                    .getAbsolutePath());
            } else {
            	PlutusAndroidManager.setCacheDir(Config.APP_CACHE.getAbsolutePath());
            }
            PlutusAndroidManager
                    .setUrl("http://api.iad.ifeng.com/ClientAdversApi?");
//            PlutusAndroidManager.qureyAsync(selection, null);
            //正文文字链广告、正文页banner广告
            HashMap<String, String> map = new HashMap<String, String>();
            map.put(Constants.SELECT, Constants.SELE_ADPOSITIONS);
            map.put(Constants.KEY_POSITION, "10000001,10000026,10000021");
            PlutusAndroidManager.qureyAsync(map, plutusAndroidListener);  
            
            ExposureHandler.init();
        }
	}

	private void initConfig() {
		Config.PUBLISH_ID = getString(R.string.publish_id);
		Config.ENABLE_ADVER = getString(R.string.enable_ad).equalsIgnoreCase(
				"true");
		Config.isUpgrader = getString(R.string.isopen_autoupdate)
				.equalsIgnoreCase("true");
		Config.ADD_UMENG_STAT = getString(R.string.ADD_UMENG_STAT)
				.equalsIgnoreCase("true");
		Config.SPECIAL_USERKEY = getString(R.string.special_userkey)
				.equalsIgnoreCase("true");
		Config.IMOCHA_AD = getString(R.string.imocha_ad).equalsIgnoreCase(
				"true");
		Config.isDEGUG = getString(R.string.isDEGUG).equalsIgnoreCase(
				"true");
		Config.enablePush = getString(R.string.enablePush).equalsIgnoreCase("true");
		Settings.getInstance().setPackageNum(Utils.getSoftwareVersion(this));
		
		sp = PreferenceManager.getDefaultSharedPreferences(this);
		isPlayed = sp.getBoolean(ConstantManager.IS_PLAYED_KEY, false);
		Config.isSupportHdPlay = sp.getBoolean(ConstantManager.IS_SUPPORT_HD_PLAY_KEY, false);
		
	}
	
	private void playTestVideo() {
		// TODO Auto-generated method stub
		//判断是否播放过测试视频
		if(!isPlayed){
			new Thread(){
				@Override
				public void run() {
					// TODO Auto-generated method stub
					try {
						player = new MediaPlayer();
						//设置播放数据的Url
						player.setDataSource(IfengNewsApp.this, Uri.parse("android.resource://"+IfengNewsApp.this.getPackageName()+"/"+R.raw.test));
						player.prepareAsync();
						player.setOnPreparedListener(new OnPreparedListener() {
							
							@Override
							public void onPrepared(MediaPlayer arg0) {
								// TODO Auto-generated method stub
								Log.d(TAG, "player onPrepared ");
								player.start();
								
//								if(Config.isPlayTest){
//									Toast.makeText(getApplicationContext(), "测试视频已经播放", Toast.LENGTH_SHORT).show();
//								}
							}
						});
						player.setOnErrorListener(new OnErrorListener() {
							
							@Override
							public boolean onError(MediaPlayer arg0, int arg1, int arg2) {
								// TODO Auto-generated method stub
								Log.d(TAG, "player onError ");
								sp.edit().putBoolean(ConstantManager.IS_PLAYED_KEY, true).commit();
								sp.edit().putBoolean(ConstantManager.IS_SUPPORT_HD_PLAY_KEY, false).commit();
								isPlayed = true;
								Config.isSupportHdPlay = false;
//								if(Config.isPlayTest){
//									Toast.makeText(getApplicationContext(), "测试视频播放失败", Toast.LENGTH_SHORT).show();
//								}
								return true;
							}
						});
						player.setOnCompletionListener(new OnCompletionListener() {
							
							@Override
							public void onCompletion(MediaPlayer player) {
								// TODO Auto-generated method stub
								Log.d(TAG, "player onPrepared ");
								//fix bug 17359 
								if("Lenovo A288t".equalsIgnoreCase(Utils.getPhoneModel())){
									sp.edit().putBoolean(ConstantManager.IS_PLAYED_KEY, true).commit();
									sp.edit().putBoolean(ConstantManager.IS_SUPPORT_HD_PLAY_KEY, false).commit();
									isPlayed = true;
									Config.isSupportHdPlay = false;
								}else{
									sp.edit().putBoolean(ConstantManager.IS_PLAYED_KEY, true).commit();
									sp.edit().putBoolean(ConstantManager.IS_SUPPORT_HD_PLAY_KEY, true).commit();
									isPlayed = true;
									Config.isSupportHdPlay = true;
								}
//								if(Config.isPlayTest){
//									Toast.makeText(getApplicationContext(), "测试视频播放成功", Toast.LENGTH_SHORT).show();
//								}
								//释放MediaPlayer,避免内存泄露
								player.release();
							}
						});
						
					} catch (IllegalArgumentException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (SecurityException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (IllegalStateException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} 
				}
			}.start();
		}
	}
	
	/**
     * 捕获运行时异常
     */
    private void initCatchRunException() {
        getMainLooper().getThread().setUncaughtExceptionHandler(
                new Thread.UncaughtExceptionHandler() {
                    public void uncaughtException(Thread thread, Throwable ex) {
                        Intent intent = new Intent(IfengNewsApp.this.getApplicationContext(),
                                SendErrorReportService.class);
//                      intent.putExtra("data", ex.toString() + "\n"
//                              + getWholeExceptionMessage(ex));
                        intent.putExtra("data", LogHandler.buildLogRecord("IfengNewsApp.initCatchRunException"
                                , ex.toString()
                                , LogHandler.stackTraceToString(ex)));
                        startService(intent);
                        try {
                            Thread.getDefaultUncaughtExceptionHandler()
                                    .uncaughtException(thread, ex);
                        } catch (Exception e) {
                        }
                    }
                });
    }

//	public void stopPush() {
//		MBoxAgent.setPushActivated(this, false);
//	}

	public static ImageLoader getImageLoader() {
		return ImageLoader.getInstance();
	}

	public static BeanLoader getBeanLoader() {
		if (beanLoader == null) {
			beanLoader = initBeanLoader();
		}
		return beanLoader;
	}

	private static BeanLoader initBeanLoader() {
		beanLoader = BeanLoader.getInstance();
		getBeanLoader().getSettings().setBaseCacheDir(Config.FOLDER_CACHE);
		getBeanLoader().getSettings().setBaseBackupDir(Config.APP_CACHE);
		getBeanLoader().getSettings().setExpirePeriod(Config.EXPIRED_TIME);
		return beanLoader;
	}

	@Override
	public void onOpen() {
		if (isDebugMode())
			ensureTestSetting();
	}
	
	public void ensureTestSetting() {
		SharedPreferences preferences = PreferenceManager
				.getDefaultSharedPreferences(this);
		Config.ENALBE_PREFETCH = preferences.getBoolean("prefetch", false);
		Config.FORCE_2G_MODE = preferences.getBoolean("force2g", false);
		Config.FULL_EXIT = preferences.getBoolean("full_exit", true);
		Config.APP_UPGRADE_URL = preferences.getString("upgrade",
				Config.APP_UPGRADE_URL);
		Config.IMOCHA_AD = preferences.getBoolean("advertise", true);
		try {
			Config.EXPIRED_TIME = Long.parseLong(preferences.getString(
					"expire", "300")) * 1000;
		} catch (Exception e) {
			// ignore
			errorLog("expired_time set wrong:"
					+ preferences.getString("expire", "not set"));
		}
	}

	@Override
	public void onClose() {
//		Log.e("Sdebug", "IfengNews onClose called");
		recycleBroadcast();
//		LogUtil.closeFileStream();
		if (isMainProcess) {
			Statistics.saveRecord();
		}
		if (Config.FULL_EXIT) {
			Process.killProcess(Process.myPid());
		}
	}
	
	/**
	 * 取消广播注册
	 */
	private void recycleBroadcast() {
		PhoneManager.getInstance(this).destroy();
	}

	public void setSlideItems(ArrayList<SlideItem> slideItems) {
		this.slideItems = slideItems;
	}

	public ArrayList<SlideItem> getSlideItems() {
		if (slideItems == null) {
			slideItems = new ArrayList<SlideItem>();
			slideItems.add(new SlideItem());
		}
		return slideItems;
	}

	public void setCurrentDocUnits(ArrayList<DocUnit> currentDocUnits) {
		this.currentDocUnits = currentDocUnits;
	}

	public ArrayList<DocUnit> getCurrentDocUnits() {
		return currentDocUnits;
	}

	public DisplayMetrics getDisplay(Activity activity) {
		if (display == null) {
			display = new DisplayMetrics();
			activity.getWindowManager().getDefaultDisplay().getMetrics(display);
		}
		return display;
	}

	public static ResourceCacheManager getResourceCacheManager() {
		return ImageLoader.getResourceCacheManager();
	}

	public static MixedCacheManager getMixedCacheManager() {
		return BeanLoader.getMixedCacheManager();
	}
}