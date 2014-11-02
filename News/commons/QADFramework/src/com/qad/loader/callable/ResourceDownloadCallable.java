package com.qad.loader.callable;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

import android.os.Process;
import android.util.Log;

import com.qad.lang.Files;
import com.qad.loader.ImageLoader;
import com.qad.loader.LoadCallable;
import com.qad.loader.LoadContext;
import com.qad.net.HttpManager;
import com.qad.util.LogHandler;

public class ResourceDownloadCallable<Result> extends LoadCallable<Result> {

	public ResourceDownloadCallable(LoadContext<?, ?, Result> context) {
		super(context);
		this.context = context;
	}

	@SuppressWarnings("unchecked")
	@Override
	public Result call() throws IOException {
		Process.setThreadPriority(Process.THREAD_PRIORITY_LOWEST - 1);
		InputStream is = null;
		File file = null;
		if (null == context.getParam()) {
          return null;
        }
		String url = context.getParam().toString();
		is = HttpManager.getInputStream(url);

		if (null != is) {
			file = ImageLoader.getResourceCacheManager().getCacheFile(url);
			Files.write(file, is);
			if (null != file && file.exists()) {
				return (Result) file.getAbsolutePath();
			} else {
				Log.w("Sdebug", "ResourceDownloadCallable:call: failed to save image, url is: " + url);
				return null;
			}
			/*
			Bitmap bitmap = BitmapFactory.decodeStream(is);
			if (bitmap != null) {
				file = ImageLoader.getResourceCacheManager().saveCache(url, bitmap);
			} else {
				is.close();
				Log.w("Sdebug", "ResourceDownloadCallable:call: BitmapFactory.decodeStream returns null, url is: " + url + ", just writing to file.");
				file = ImageLoader.getResourceCacheManager().getCacheFile(url);
				Files.write(file, HttpManager.getInputStream(url));
//			    LogHandler.addLogRecord("ImageLoadingFailed", "ResourceDownloadCallable:call: BitmapFactory.decodeStream returns null, url is: " + url);
			    
			}
			if (null != file) {
				return (Result) file.getAbsolutePath();
			} else {
				return null;
			}
			*/
		}
		
//		LogHandler.addLogRecord("ImageLoadingFailed", "ResourceDownloadCallable:call: Input stream is null, url is: " + url);
		Log.w("Sdebug", "ResourceDownloadCallable:call: Input stream is null, url is: " + url);
		return null;
			
	}

}
