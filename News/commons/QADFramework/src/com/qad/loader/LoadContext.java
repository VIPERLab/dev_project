package com.qad.loader;

import java.lang.ref.WeakReference;

import android.content.Context;
import android.util.Log;

import com.qad.loader.callable.Parser;

/**
 * Context of loading task, containing load parameters 
 */
public class LoadContext<Param, Target, Result> {
	
	/**
	 * Flag indicates only cache should be loaded
	 */
	public static final int FLAG_CACHE_ONLY = 0x100;
	
	/**
	 *  Flag indicates only HTTP content should be loaded
	 */
	public static final int FLAG_HTTP_ONLY = 0x101;
	
	/**
	 * Flag indicates cache should be loaded first, load HTTP content
	 * if failed to load cache
	 */
	public static final int FLAG_CACHE_FIRST = 0x102;
	
	/**
	 * Flag indicates HTTP content should be loaded first, load cache
	 * if failed to load cache
	 */
	public static final int FLAG_HTTP_FIRST = 0x103;
	
	/**
	 * Flag indicates result is loaded from fileCache
	 */
	public static final int FLAG_FILECACHE_FIRST = 0x104;
	
	/**
	 * Flag indicates result is loaded from cache
	 */
	public static final int TYPE_CACHE = 0x200;
	
	/**
	 * Flag indicates result is loaded from HTTP
	 */
	public static final int TYPE_HTTP = 0x201;
	
	private Param param = null;
	private Target target = null;
	private WeakReference<Target> targetRef = null;
	private Result result = null;
	private Parser<Result> parser = null;
	private Class<?> clazz = null;
	private int flag;
	
	private boolean isAutoRefresh = false;
	private boolean isFirstLoaded = false;
	private boolean isAutoSaveCache;
	private int type = TYPE_CACHE;
	//重试次数
	private int tryTimes = 0;
	private Context appContext = null;
	
	// 标识这个context是不是为了幻灯下载图片
	private boolean is4Slide = false;

	public LoadContext(LoadContext<Param, Target, Result> o) {
		this.param = o.param;
		this.target = o.target;
//		this.targetRef = o.targetRef;
		this.result = o.result;
	}
	
	public LoadContext(Param param, Target target, Class<?> clazz, int flag, Context appContext) {
	    this(param, target, clazz, flag);
	    this.appContext = appContext;
	}

	public LoadContext(Param param, Target target, Class<?> clazz, int flag) {
		this(param, target, clazz, null, false, flag, true);
	}
	
	public LoadContext(Param param, Target target, Class<?> clazz, Parser<Result> parser, int flag) {
		this(param, target, clazz, parser, false, flag, true);
	}
	
	public LoadContext(Param param, Target target, Class<?> clazz, Parser<Result> parser, int flag, boolean isAutoSaveCache) {
		this(param, target, clazz, parser, false, flag, isAutoSaveCache);
	}
	
	public LoadContext(Param param, Target target, Class<?> clazz, Parser<Result> parser, boolean isFirstLoaded, int flag, boolean isAutoSaveCache) {
	    // 如果当param为null时抛异常，应用可能永远无法启动
	    // LoaderExecutor.execute()中判断param为空时会直接返回。
//		if (param == null)
//			throw new NullPointerException("Param can not be NULL");
		if (target == null)
			Log.d(getClass().getName(), "Target is NOT set for " + param);
		this.param = param;
		this.target = target;
//		this.targetRef = new WeakReference<Target>(target);
		this.clazz = clazz;
		this.parser = parser;
		this.isFirstLoaded = isFirstLoaded;
		this.flag = flag;
		this.isAutoSaveCache = isAutoSaveCache;
	}
	
	public Param getParam() {
		return param;
	}
	
	public void setParam(Param param) {
		this.param = param;
	}

	public Target getTarget() {
		return target;
//		if (null != targetRef) {
//			return targetRef.get();
//		}
//		return null;
	}
	
	public Result getResult() {
		return result;
	}
	
	public void setResult(Result result) {
		this.result = result;
	}
	
	public Class<?> getClazz() {
		return clazz;
	}
	
	public Parser<Result> getParser() {
		return parser;
	}

	public boolean getIsAutoRefresh() {
		return isAutoRefresh;
	}
	
	public void setIsAutoRefresh(boolean isAutoRefresh) {
		this.isAutoRefresh = isAutoRefresh;
	}

	public boolean getIsFirstLoaded() {
		return isFirstLoaded;
	}

	public void setFlag(int flag) {
		this.flag = flag;
	}
	
	public int getFlag() {
		return flag;
	}
	
	public int getType() {
		return type;
	}
	
	public void setType(int type) {
		this.type = type;
	}
	
	public boolean isAutoSaveCache() {
		return isAutoSaveCache;
	}

	public void setAutoSaveCache(boolean isAutoSaveCache) {
		this.isAutoSaveCache = isAutoSaveCache;
	}

	public int getTryTimes() {
		return tryTimes;
	}
	
	public void increaseTryTimes() {
		tryTimes++;
	}
	
	public Context getAppContext() {
	    return appContext;
	}
	
	public boolean is4Slide() {
		return is4Slide;
	}

	public void set4Slide(boolean is4Slide) {
		this.is4Slide = is4Slide;
	}

	@Override
	public int hashCode() {
		return param.hashCode();
	}

	@Override
	public String toString() {
		return "LoadContext [param = " + param + ", target = " + target + ", resul = " + result + "]";
	}
	
	@Override
	public boolean equals(Object o) {
		if (o == null) return false;
		if (!(o instanceof LoadContext)) return false;
		try {
			@SuppressWarnings("unchecked")
			LoadContext<Param, Target, Result> context = (LoadContext<Param, Target, Result>) o;
			return param.equals(context.param) && target.equals(context.target);
		} catch (ClassCastException e) {
			return false;
		}
	}
}
