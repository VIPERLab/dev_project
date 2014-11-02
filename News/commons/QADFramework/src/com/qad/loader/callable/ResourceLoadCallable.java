package com.qad.loader.callable;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.util.regex.Pattern;
import java.util.zip.GZIPInputStream;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Process;

import com.qad.graphics.RecyclingBitmapDrawable;
import com.qad.lang.Files;
import com.qad.loader.ImageLoader;
import com.qad.loader.LoadCallable;
import com.qad.loader.LoadContext;
import com.qad.net.HttpManager;
import com.qad.util.Utils;

public class ResourceLoadCallable<Result> extends LoadCallable<Result> {

	public ResourceLoadCallable(LoadContext<?, ?, Result> context) {
		super(context);
	}

	@SuppressWarnings("unchecked")
	@Override
	public Result call() throws IOException {
		Process.setThreadPriority(Process.THREAD_PRIORITY_LOWEST - 1);
		BitmapDrawable bitmap = null;
		if (null == context.getParam()) {
          return null;
        }
		if (context.getFlag() == LoadContext.FLAG_HTTP_ONLY) {
			// 这是ImageLoader的首选
			bitmap = loadHTTP(context.getParam().toString());
		} else if (context.getFlag() == LoadContext.FLAG_HTTP_FIRST) {
			try {
				bitmap = loadHTTP(context.getParam().toString());
			} catch (IOException ioe) {
				// 如果HTTP请求抛出异常，继续loadCache
				bitmap = ImageLoader.getResourceCacheManager().getCache(context);
			}
		} else { // Cache first
			bitmap = ImageLoader.getResourceCacheManager().getCache(context);
			if (bitmap == null)
				bitmap = loadHTTP(context.getParam().toString());
		}
		
		return (Result) bitmap;
	}

	private BitmapDrawable loadHTTP(String param) throws IOException {
//		try {
//			InputStream is = HttpManager.getInputStream(param);
			HttpURLConnection connection = HttpManager.getUrlConnection(param);
			if (connection.getResponseCode() != 200) {
				throw new IOException("responseCode:"
						+ connection.getResponseCode() + " response message:"
						+ connection.getResponseMessage());
			}
			InputStream is=connection.getInputStream();
			String encoding=connection.getHeaderField("Content-Encoding");
			if(encoding!=null && Pattern.compile("gzip", Pattern.CASE_INSENSITIVE).matcher(encoding).find())
			{
				is=new GZIPInputStream(is);
			}
			
			if (is != null) { 
				File file = ImageLoader.getResourceCacheManager().getCacheFile(param);
				Files.write(file, is);
				context.setType(LoadContext.TYPE_HTTP);
				// 使SDK 11以下系统有机会缩放图片
				return ImageLoader.getResourceCacheManager().getCache(context);
//				Bitmap bitmap = BitmapFactory.decodeStream(is);//, null, bitmapOptions);
//				connection.disconnect();
//				
//				if (bitmap != null) {
//					if (10 > bitmap.getWidth() || 10 > bitmap.getHeight()) {
//						// 过滤掉小于10像素的图
//						Log.i("Sdebug", "BitmapFactory.decodeStream 过滤掉小与10像素的图片");
//						return null;
//					}
//					ImageLoader.getResourceCacheManager().saveCache(param, bitmap);
//				}
//				return bitmap;
			}
//			LogHandler.addLogRecord("ImageLoadingFailed", "Input stream is null, url is: " + param);
			return null;
//		} catch (MalformedURLException e) {
//			Log.e("Load resource error with param: ", param);
//			return null;
//		}
	}
	
//	private Bitmap loadCache(String param) {
//		return ImageLoader.getResourceCacheManager().getCache(param);
//	}
	
}