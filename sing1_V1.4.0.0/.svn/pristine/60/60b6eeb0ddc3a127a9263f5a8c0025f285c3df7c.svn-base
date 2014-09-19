package cn.kuwo.sing.context;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.Application;
import android.content.Context;
import android.graphics.Bitmap.CompressFormat;
import android.os.Build;
import cn.kuwo.framework.config.PreferencesManager;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.BaseLogger;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.util.DialogUtils;

import com.nostra13.universalimageloader.cache.disc.impl.UnlimitedDiscCache;
import com.nostra13.universalimageloader.cache.disc.naming.HashCodeFileNameGenerator;
import com.nostra13.universalimageloader.cache.memory.impl.UsingFreqLimitedMemoryCache;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.nostra13.universalimageloader.core.assist.QueueProcessingType;
import com.nostra13.universalimageloader.core.download.BaseImageDownloader;
import com.nostra13.universalimageloader.utils.StorageUtils;

public class App extends Application {
    private final static String TAG = "App";
    
    // 初始化文件系统是否失败
    public boolean mInitFSFailed = false;
    private List<Activity> activityList = new ArrayList<Activity>(); 
    public String ridFromKwPlayer = null;
    public String songNameFromKwPlayer = null;
    public String artistFromKwPlayer = null;
    public String sourceFromKwPlayer = null;
    public String albumFromKwPlayer = null;
    
	@Override
	public void onCreate() {
		super.onCreate();
		CrashHandler crashHandler = CrashHandler.getInstance();
		crashHandler.init(getApplicationContext());
		//Thread.currentThread().setUncaughtExceptionHandler(crashHandler);
		initImageLoader(getApplicationContext());
	}
	
	public static void initImageLoader(Context context) { 
		int memoryCacheSize;
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ECLAIR) {
			int memClass = ((ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE)).getMemoryClass();
			memoryCacheSize = (memClass / 8) * 1024 * 1024; // 1/8 of app memory limit 
		} else {
			memoryCacheSize = 2 * 1024 * 1024;
		}

		// This configuration tuning is custom. You can tune every option, you may tune some of them, 
		// or you can create default configuration by
		//  ImageLoaderConfiguration.createDefault(this);
		// method.
		File cacheDir = StorageUtils.getCacheDirectory(context);
//		File cacheDir = StorageUtils.getOwnCacheDirectory(context, DirectoryManager.getDirPath(DirContext.PICTURE));
		ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(context)
		        .memoryCacheExtraOptions(480, 800) // default = device screen dimensions
		        .discCacheExtraOptions(480, 800, CompressFormat.JPEG, 75)
		        .threadPoolSize(3) // default
		        .threadPriority(Thread.NORM_PRIORITY - 1) // default
		        .denyCacheImageMultipleSizesInMemory()
		        .offOutOfMemoryHandling()
		        .memoryCache(new UsingFreqLimitedMemoryCache(2 * 1024 * 1024)) // default
		        .memoryCacheSize(2 * 1024 * 1024)
		        .discCache(new UnlimitedDiscCache(cacheDir)) // default
		        .discCacheSize(50 * 1024 * 1024)
		        .discCacheFileCount(100)
		        .discCacheFileNameGenerator(new HashCodeFileNameGenerator()) // default
		        .imageDownloader(new BaseImageDownloader(context)) // default
		        .tasksProcessingOrder(QueueProcessingType.LIFO) // default
		        .defaultDisplayImageOptions(DisplayImageOptions.createSimple()) // default
		        .enableLogging()
		        .build();
		// Initialize ImageLoader with configuration.
		ImageLoader.getInstance().init(config);
	}
	
	/**
	 * add the activity to ArrayList.
	 * @param activity
	 */
	public void addActivity(Activity activity) {
		activityList.add(activity);
	}
	
	public Activity getActivity(Class<?> clazz) {
		if(clazz != null) {
			String clazzName = clazz.getName();
			for(Activity activity : activityList) {
				if(clazzName.equals(activity.getClass().getName())) {
					return activity;
				}
			}
		}
		return null;
	}
	
	/**
	 * remove the activity from ArrayList.
	 * @param activity
	 */
	public void removeActivity(Activity activity) {
		activityList.remove(activity);
	}
	
	/**
	 * finish the activity.
	 * @param activity
	 */
	public void finishActivity(Activity activity) {
		activityList.remove(activity);
		activity.finish();
	}
	
	
	/**
	 * finish all activities.
	 */
	public void exit() {
		for(Activity activity : activityList) {
			activityList.remove(activity);
			activity.finish();
		}
	}
	
	@Override
	public void onTerminate() {
		super.onTerminate();
		KuwoLog.d(TAG, "onTerminate");
	}

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        KuwoLog.w(TAG, "onLowMemory");
        ImageLoader.getInstance().clearMemoryCache();
        System.gc();
    }
    
    public void init() {
    	
		// 初始化目录结构
    	
		if (!mInitFSFailed)
			mInitFSFailed = !DirectoryManager.init(new DirContext(Constants.APP_NAME));

		// 设置日志级别
		KuwoLog.init(Constants.APP_NAME);
//		KuwoLog.debug(false);
		KuwoLog.debug(true);
		KuwoLog.trace(true);
		KuwoLog.getLogger().setLevel(BaseLogger.INFO);

		// 初始化上下文
		AppContext.init(this);
		
		// 初始化PreferencesManager
		PreferencesManager.init(this);
		
		DialogUtils.init(this);
		 
		if ( mInitFSFailed ) {
			KuwoLog.e(TAG, "init file system failed");
		}
    }

}
