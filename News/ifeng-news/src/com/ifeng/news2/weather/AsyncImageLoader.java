package com.ifeng.news2.weather;

import java.io.InputStream;
import java.lang.ref.SoftReference;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;

import com.ifeng.share.util.HttpUtils;

public class AsyncImageLoader {
	private ExecutorService executorService = Executors.newFixedThreadPool(5); // 固定五个线程来执行任务
	public Map<String, SoftReference<Bitmap>> imageCache = new HashMap<String, SoftReference<Bitmap>>();
	private final Handler handler = new Handler();
	public Bitmap loadDrawable(final String imageUrl,
			final ImageCallback callback) {
		if (imageCache.containsKey(imageUrl)) {
			SoftReference<Bitmap> softReference = imageCache.get(imageUrl);
			if (softReference.get() != null) {
				return softReference.get();
			}
		}
		executorService.submit(new Runnable() {
			public void run() {
				try {
					final Bitmap bitmap = loadImageFromUrl(imageUrl); 
					imageCache.put(imageUrl, new SoftReference<Bitmap>(
							bitmap));
					handler.post(new Runnable() {
						public void run() {
							callback.imageLoaded(bitmap);
						}
					});
				} catch (Exception e) {
					throw new RuntimeException(e);
				}
			}
		});
		return null;
	}
	// 从网络上取数据方法
	protected Bitmap loadImageFromUrl(String imageUrl) {
		try {
			InputStream is = HttpUtils.getInputStream(imageUrl);
			return BitmapFactory.decodeStream(is);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}
	// 对外界开放的回调接口
	public interface ImageCallback {
		// 注意 此方法是用来设置目标对象的图像资源
		public void imageLoaded(Bitmap bm);
	}
}