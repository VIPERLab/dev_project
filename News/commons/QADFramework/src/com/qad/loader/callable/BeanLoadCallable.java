package com.qad.loader.callable;

import java.io.IOException;
import java.io.Serializable;
import java.text.ParseException;

import android.text.TextUtils;

import com.qad.loader.BeanLoader;
import com.qad.loader.LoadCallable;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.net.HttpManager;

public class BeanLoadCallable<Result> extends LoadCallable<Result> {

//	private LoadListener<Result> LoadListener;

	@SuppressWarnings("unchecked")
	public BeanLoadCallable(LoadContext<?, ?, Result> context) {
		super(context);
//		if (context.getTarget() instanceof LoadListener) {
//			this.LoadListener = (LoadListener<Result>) context.getTarget();
//		}
	}

	@Override
	public Result call() throws IOException, ParseException {
		if (context.getParser() == null)
			throw new IllegalArgumentException("LoadContext: "
					+ context.getParam().toString()
					+ " is illegal, Parser cannot be null");

		Result r = null;
		switch (context.getFlag()) {
		case LoadContext.FLAG_CACHE_ONLY:
			r = loadCache();
			break;
		case LoadContext.FLAG_HTTP_ONLY:
			r = loadHTTP();
			break;
		case LoadContext.FLAG_HTTP_FIRST:
			try {
				r = loadHTTP();
				
			} catch (Exception e) {
				// 如果http请求失败，继续loadCache
//				r = loadCache(false);
			} finally {
			  /* 如果在catch中loadCache只有发生在异常情况下，如果没有发生异常，
			  返回的结果就为null 这时是不会loadCache就不会获取缓存内容所以作此修改 */
			  if (null == r) {
			    r = loadCache(false);
			  }
			}
			break;
		case LoadContext.FLAG_FILECACHE_FIRST:
			r = loadFileCache();
			if (r == null)
				r = loadHTTP();
			break;
		case LoadContext.FLAG_CACHE_FIRST:
		default:
			r = loadCache();
			if (r == null)
				r = loadHTTP();
			break;
		}
		context.setResult(r);
		if (null != context.getTarget() && context.getTarget() instanceof LoadListener) {
			((LoadListener<Result>) context.getTarget()).postExecut(context);
		}
//		if (LoadListener != null) {
//			LoadListener.postExecut(context);
//		}
		return context.getResult();
	}

	private Result loadHTTP() throws IOException, ParseException {
//		try {
			String param = context.getParam().toString();
			String s = HttpManager.getHttpText(param);
			if (TextUtils.isEmpty(s))
				return null;

			
			Result r = null;
			if ((r = parse(s)) != null) {
				context.setType(LoadContext.TYPE_HTTP);
				if(context.isAutoSaveCache()){
					BeanLoader.getMixedCacheManager().saveCache(param,
							(Serializable) r);
				}
			}
			return r;
//		} catch (Exception e) {
//			Log.d(getClass().getName(), e.getLocalizedMessage());
//			return null;
//		}
	}

	private Result loadCache(boolean loadExpired) {
		String param = context.getParam().toString();
		if (!loadExpired && BeanLoader.getMixedCacheManager().isExpired(param))
			return null;
		else
			return loadCache();
	}

	@SuppressWarnings("unchecked")
	private Result loadFileCache() {
		String param = context.getParam().toString();
		return (Result) BeanLoader.getMixedCacheManager().getFileCache(param);
	}

	private Result loadCache() {
//		try {
			String param = context.getParam().toString();
			@SuppressWarnings("unchecked")
			Result r = (Result) BeanLoader.getMixedCacheManager().getCache(
					param);
			if (r == null)
				return null;

			if (BeanLoader.getMixedCacheManager().isExpired(param)) {
				context.setIsAutoRefresh(true);
			}
			context.setType(LoadContext.TYPE_CACHE);
			return r;
//		} catch (Exception e) {
//			if (e != null)
//				Log.d(getClass().getName(), e.getLocalizedMessage());
//			return null;
//		}
	}

	/**
	 * Param 's' is <B>NOT</B> checked
	 * 
	 * @param s
	 * @return
	 * @throws ParseException 
	 */
	private Result parse(String s) throws ParseException {
//		try {
	    // for testing, 制造parse error
//        s = s.replace("}", "xx");
			return context.getParser().parse(s);
//		} catch (ParseException e) {
//			if (e != null)
//				Log.d(getClass().getName(), e.getLocalizedMessage());
//			return null;
//		}
	}
}