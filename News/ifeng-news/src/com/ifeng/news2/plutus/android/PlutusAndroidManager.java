package com.ifeng.news2.plutus.android;

import java.net.InetSocketAddress;
import java.util.Map;

import android.os.Handler;
import android.os.Message;

import com.ifeng.news2.plutus.core.Constants.ERROR;
import com.ifeng.news2.plutus.core.PlutusCoreListener;
import com.ifeng.news2.plutus.core.PlutusCoreManager;

public class PlutusAndroidManager {
	
	public static final int MESSAGE_START = 0x1F << 1;
	public static final int MESSAGE_COMPLETE = 0x1F << 2;
	public static final int MESSAGE_ERROR = 0x1F << 3;
	
	private static PlutusCoreManager core = null;
	private static PlutusAndroidManager instance = null;
	private static String urlSuffix = null;
	
	private static Handler sHandler = new Handler() {
		
		@SuppressWarnings("unchecked")
		public void handleMessage(Message msg) {
			if (msg.obj == null || !(msg.obj instanceof InnerResult))
				return;
			@SuppressWarnings("rawtypes")
			InnerResult result = (InnerResult) msg.obj;
			if (result.getListener() == null)
				return;
			switch (msg.what) {
			case MESSAGE_START:
				result.getListener().onPostStart();
				break;
			case MESSAGE_COMPLETE:
				result.getListener().onPostComplete(result.getResult());
				break;
			case MESSAGE_ERROR:
				result.getListener().onPostFailed(result.getError());
				break;
			default:
				break;
			}
		};
		
	};
	
	private PlutusAndroidManager(String urlSuffix) {
		PlutusAndroidManager.urlSuffix = urlSuffix;  
		PlutusAndroidManager.core = PlutusCoreManager.getInstance(urlSuffix);
	}
	
	public static void init(String urlSuffix) {
		if (instance == null) 
			instance = new PlutusAndroidManager(urlSuffix);
	}
	
	public static <Result> void qureyAsync(Map<String, String> selection, final PlutusAndroidListener<Result> listener) {
		final InnerResult<Result> innerResult = new InnerResult<Result>();
		innerResult.setListener(listener);
		PlutusCoreListener<Result> coreListener = new PlutusCoreListener<Result>() {

			@Override
			public void onPostStart() {
				sHandler.obtainMessage(MESSAGE_START, innerResult).sendToTarget();
			}

			@Override
			public void onPostComplete(Result result) {
				innerResult.setResult(result);
				sHandler.obtainMessage(MESSAGE_COMPLETE, innerResult).sendToTarget();
			}

			@Override
			public void onPostFailed(ERROR error) {
				innerResult.setError(error);
				sHandler.obtainMessage(MESSAGE_ERROR, innerResult).sendToTarget();
			}
		};
		if (core == null || coreListener == null) return;
		core.qureyAsync(selection, coreListener);
	}
	
	public static String getUrlSuffix() {
		return PlutusAndroidManager.urlSuffix;
	}
	
	public static String getUrl() {
		return PlutusCoreManager.getUrl();
	}
	
	public static void setUrl(String url) {
		PlutusCoreManager.setUrl(url);
	}
	
	public static int getTimeOut() {
		return PlutusCoreManager.getTimeOut();
	}
	
	public static void setTimeOut(int timeOutSecond) {
		PlutusCoreManager.setTimeOut(timeOutSecond);
	}
	
	public static InetSocketAddress getInetSocketAddress() {
		return PlutusCoreManager.getInetSocketAddress();
	}
	
	public static void setInetSocketAddress(InetSocketAddress inetSocketAddress) {
		PlutusCoreManager.setInetSocketAddress(inetSocketAddress);
	}
	
	public static String getCacheDir() {
		return PlutusCoreManager.getCacheDir();
	} 
	
	public static void setCacheDir(String cacheDir) {
		PlutusCoreManager.setCacheDir(cacheDir);
	}
	
	public static String getStatisticUrl() {
		return PlutusCoreManager.getStatisticUrl();
	}
	
	public void setStatisticUrl(String statisticUrl) {
		PlutusCoreManager.setStatisticUrl(statisticUrl);
	}
	
	public interface PlutusAndroidListener<T> {
		
		public void onPostStart();
		
		public void onPostComplete(T result);
		
		public void onPostFailed(ERROR error);
		
	}
	
}
