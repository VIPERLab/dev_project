/**
 * Copyright (c) 2012 Eleven Inc. All Rights Reserved.
 */
package cn.kuwo.sing.util;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.SoftReference;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.LinkedHashMap;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.support.v4.util.LruCache;
import android.util.Log;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.util.ImageAsyncTask.ImageAsyncTaskCallback;

/**
 * @File ImageUtils.java
 * 
 * @Author wangming1988
 * 
 * @Date Sep 9, 2012, 9:47:32 PM
 * 
 * @Version v0.1
 * 
 * @Description
 * 
 */

public class ImageUtils {
	/****************************** Image cache on SDCard ******************************************************/
	/** You should make a directory for image cache. */
	private static final String SDCARD_CACHE_IMAGE_PATH = DirectoryManager
			.getDirPath(DirContext.PICTURE) + "/";
	// hard cache
	private static final int hardCachedSize = 8 * 1024 * 1024;
	private static final LruCache<String, Bitmap> sHardBitmapCache = new LruCache<String, Bitmap>(
			hardCachedSize) {
		@Override
		public int sizeOf(String key, Bitmap value) {
			return value.getRowBytes() * value.getHeight();
		}

		@Override
		protected void entryRemoved(boolean evicted, String key,
				Bitmap oldValue, Bitmap newValue) {
			Log.v("tag", "hard cache is full , push to soft cache");
			// 硬引用缓存区满，将一个最不经常使用的oldvalue推入到软引用缓存区
			sSoftBitmapCache.put(key, new SoftReference<Bitmap>(oldValue));
		}
	};
	// soft cache
	private static final int SOFT_CACHE_CAPACITY = 40;
	private static final LinkedHashMap<String, SoftReference<Bitmap>> sSoftBitmapCache = new LinkedHashMap<String, SoftReference<Bitmap>>(
			SOFT_CACHE_CAPACITY, 0.75f, true) {

		@Override
		public SoftReference<Bitmap> put(String key, SoftReference<Bitmap> value) {
			return super.put(key, value);
		}

		protected boolean removeEldestEntry(
				LinkedHashMap.Entry<String, SoftReference<Bitmap>> eldest) {
			if (size() > SOFT_CACHE_CAPACITY) {
				Log.v("tag", "Soft Reference limit , purge one");
				return true;
			}
			return false;

		};
	};

	// 缓存bitmap
	public static boolean putBitmap(String key, Bitmap bitmap) {
		if (bitmap != null) {
			synchronized (sHardBitmapCache) {
				sHardBitmapCache.put(key, bitmap);
			}
			return true;
		}
		return false;
	}

	// 从缓存中获取bitmap
	public static Bitmap getBitmap(String key) {
		synchronized (sHardBitmapCache) {
			final Bitmap bitmap = sHardBitmapCache.get(key);
			if (bitmap != null)
				return bitmap;
		}
		// 硬引用缓存区间中读取失败，从软引用缓存区间读取
		synchronized (sSoftBitmapCache) {
			SoftReference<Bitmap> bitmapReference = sSoftBitmapCache.get(key);
			if (bitmapReference != null) {
				final Bitmap bitmap2 = bitmapReference.get();
				if (bitmap2 != null)
					return bitmap2;
				else {
					Log.v("tag", "soft reference 已经被回收");
					sSoftBitmapCache.remove(key);
				}
			}
		}
		return null;
	}

	public static String getCacheImagePath() {
		return SDCARD_CACHE_IMAGE_PATH;
	}

	/**
	 * Save the image to SD card.
	 * 
	 * @param imagePath
	 * @param buf
	 * @throws IOException
	 */
	public static void saveImage2SDCard(String imagePath, byte[] buf)
			throws IOException {
		KuwoLog.i("imagePath=============", imagePath);
		File file = new File(imagePath);
		if (file.exists()) {
			return;
		} else {
			File parentFile = file.getParentFile();
			if (!parentFile.exists()) {
				parentFile.mkdirs();
			}
			// you should make the directory first, and then make the file
			// not make the expanded name
			file.createNewFile();
			FileOutputStream fos = new FileOutputStream(imagePath);
			fos.write(buf);
			fos.flush();
			fos.close();
		}
	}

	/**
	 * Get the bitmap from SD card cache.
	 * 
	 * @param imagePath
	 * @return
	 */
	public static Bitmap getImageFromSDCard(String imagePath, int imageWidth,
			int imageHeight) {
		File file = new File(imagePath);
		if (file.exists()) {
			BitmapFactory.Options options = BitmapTools.getBitmapOptions(
					imageWidth, imageHeight);
			FileInputStream fis;
			try {
				fis = new FileInputStream(imagePath);
				Bitmap bitmap = BitmapFactory.decodeStream(fis, null, options);
				file.setLastModified(System.currentTimeMillis());
				return bitmap;
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			}
		}
		return null;
	}

	/**
	 * Compress the bitmap to JPEG, and write to ByteArrayOutputStream.
	 * 
	 * @param bitmap
	 * @return
	 */
	public static byte[] bitmap2Bytes(Bitmap bitmap) {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
		return baos.toByteArray();
	}

	public static byte[] bmpToByteArray(final Bitmap bmp,
			final boolean needRecycle) {
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		bmp.compress(CompressFormat.JPEG, 100, output);
		if (needRecycle) {
			bmp.recycle();
		}

		byte[] result = output.toByteArray();
		try {
			output.close();
		} catch (Exception e) {
			e.printStackTrace();
		}

		return result;
	}

	public static Bitmap comp(Bitmap image) {

		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		image.compress(Bitmap.CompressFormat.JPEG, 100, baos);
		while (baos.toByteArray().length / 1024 > 1024) {// 判断如果图片大于1M,进行压缩避免在生成图片（BitmapFactory.decodeStream）时溢出
			baos.reset();// 重置baos即清空baos
			image.compress(Bitmap.CompressFormat.JPEG, 50, baos);// 这里压缩50%，把压缩后的数据存放到baos中
		}
		ByteArrayInputStream isBm = new ByteArrayInputStream(baos.toByteArray());
		BitmapFactory.Options newOpts = new BitmapFactory.Options();
		// 开始读入图片，此时把options.inJustDecodeBounds 设回true了
		newOpts.inJustDecodeBounds = true;
		Bitmap bitmap = BitmapFactory.decodeStream(isBm, null, newOpts);
		newOpts.inJustDecodeBounds = false;
		int w = newOpts.outWidth;
		int h = newOpts.outHeight;
		// 现在主流手机比较多是800*480分辨率，所以高和宽我们设置为
		float hh = 100f;// 这里设置高度为800f
		float ww = 100f;// 这里设置宽度为480f
		// 缩放比。由于是固定比例缩放，只用高或者宽其中一个数据进行计算即可
		int be = 1;// be=1表示不缩放
		if (w > h && w > ww) {// 如果宽度大的话根据宽度固定大小缩放
			be = (int) (newOpts.outWidth / ww);
		} else if (w < h && h > hh) {// 如果高度高的话根据宽度固定大小缩放
			be = (int) (newOpts.outHeight / hh);
		}
		if (be <= 0) {
			be = 1;
		}
		newOpts.inSampleSize = be;// 设置缩放比例
		// 重新读入图片，注意此时已经把options.inJustDecodeBounds 设回false了
		isBm = new ByteArrayInputStream(baos.toByteArray());
		bitmap = BitmapFactory.decodeStream(isBm, null, newOpts);
		return compressImage(image, 32);// 压缩好比例大小后再进行质量压缩
	}

	/**
	 * 压缩图片到指定大小的方法
	 * 
	 * @param image
	 *            图片
	 * @param size
	 *            大小
	 * @return
	 */
	public static Bitmap compressImage(Bitmap image, int size) {

		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		image.compress(Bitmap.CompressFormat.JPEG, 100, baos);// 质量压缩方法，这里100表示不压缩，把压缩后的数据存放到baos中
		int options = 100;
		while (baos.toByteArray().length / 1024 > size) { // 循环判断如果压缩后图片是否大于100kb,大于继续压缩
			baos.reset();// 重置baos即清空baos
			image.compress(Bitmap.CompressFormat.JPEG, options, baos);// 这里压缩options%，把压缩后的数据存放到baos中
			options -= 5;// 每次都减少10
		}
		ByteArrayInputStream isBm = new ByteArrayInputStream(baos.toByteArray());// 把压缩后的数据baos存放到ByteArrayInputStream中
		Bitmap bitmap = BitmapFactory.decodeStream(isBm, null, null);// 把ByteArrayInputStream数据生成图片
		return bitmap;
	}

	/*************************** Fetch image from server(HttpURLConnection, HttpClient) *********************************************/

	/**
	 * Get image from server by HttpURLConnection
	 * 
	 * @param imageUrl
	 * @return
	 */
	public static Bitmap getImageByHttpURLConnection(String imageUrl) {
		Bitmap bitmap = null;
		try {
			URL url = new URL(imageUrl);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			InputStream is = conn.getInputStream();
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			byte[] buf = new byte[1024];
			for (int len = 0; (len = is.read(buf)) != -1;) {
				baos.write(buf, 0, len);
			}
			if (is != null) {
				is.close();
			}
			baos.flush();
			byte[] data = baos.toByteArray();
			bitmap = BitmapFactory.decodeByteArray(data, 0, data.length);
			// BitmapFactory.Options opts =
			// bitmap = BitmapFactory.decodeByteArray(data, 0, data.length,
			// opts);
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return bitmap;
	}

	/**
	 * Get image from server by HttpClient
	 * 
	 * @param imageUrl
	 * @param sc
	 *            显示的像素大小
	 * @return
	 */
	public static Bitmap getImageByHttpClient(String imageUrl, int imageWidth,
			int imageHeight) {
		Bitmap bitmap = null;
		try {
			HttpClient client = new DefaultHttpClient();
			HttpGet getRequest = new HttpGet(imageUrl);
			HttpResponse response = client.execute(getRequest);
			// Http response status code 200 OK
			if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
				// response entity
				HttpEntity responseEntity = response.getEntity();
				InputStream is = responseEntity.getContent();
				ByteArrayOutputStream baos = new ByteArrayOutputStream();
				byte[] buf = new byte[1024];
				for (int len = 0; (len = is.read(buf)) != -1;) {
					baos.write(buf, 0, len);
				}
				baos.flush();
				byte[] data = baos.toByteArray();
				bitmap = BitmapFactory.decodeByteArray(data, 0, data.length,
						BitmapTools.getBitmapOptions(imageWidth, imageHeight));
				if (is != null) {
					is.close();
				}
				if (baos != null) {
					baos.close();
				}
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return bitmap;
	}

	/*************** Load image from local ******************************/
	/**
	 * 
	 * @param callback
	 * @param imagePath
	 *            local path
	 * @param imageUrl
	 *            server url
	 * @return
	 */
	public static Bitmap loadImageFromCache(ImageAsyncTaskCallback callback,
			String imagePath, String imageUrl, int imageWidth, int imageHeight) {
		Bitmap cacheBitmap = getBitmap(imagePath);
		if (cacheBitmap != null) {
			return cacheBitmap;
		}
		cacheBitmap = getImageFromSDCard(imagePath, imageWidth, imageHeight);
		if (cacheBitmap != null) {
			putBitmap(imagePath, cacheBitmap); // 内存缓存
			return cacheBitmap;
		} else {
			new ImageAsyncTask(callback).execute(imagePath, imageUrl,
					imageWidth, imageHeight);
		}
		return null;
	}

	public static Bitmap loadImageFromCache(String imagePath, int imageWidth,
			int imageHeight) {
		Bitmap cacheBitmap = getBitmap(imagePath);
		if (cacheBitmap != null) {
			return cacheBitmap;
		}
		cacheBitmap = getImageFromSDCard(imagePath, imageWidth, imageHeight);
		if (cacheBitmap != null) {
			putBitmap(imagePath, cacheBitmap); // 放入内存缓存
			return cacheBitmap;
		}
		return null;
	}

	public static ImageAsyncTask getImageAsyncTask(
			ImageAsyncTaskCallback callback, String imagePath, String imageUrl,
			int imageWidth, int imageHeight) {
		return (ImageAsyncTask) new ImageAsyncTask(callback).execute(imagePath,
				imageUrl, imageWidth, imageHeight);
	}

	/**
	 * Make the image path(local path) from image url,to generate cache for
	 * image
	 * 
	 * @param imageUrl
	 * @return
	 */
	public static String makeImagePathFromUrl(String imageUrl) {
		return getCacheImagePath().concat(MD5Encoder.encode(imageUrl));
	}

}
