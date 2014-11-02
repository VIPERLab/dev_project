package com.qad.cache;

import java.io.File;
import java.lang.ref.SoftReference;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.concurrent.atomic.AtomicLong;

import javax.microedition.khronos.opengles.GL10;

import android.annotation.TargetApi;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.opengl.GLES10;
import android.os.Build;
import android.os.StatFs;
import android.support.v4.util.LruCache;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;

import com.qad.graphics.RecyclingBitmapDrawable;
import com.qad.lang.Files;
import com.qad.loader.ImageLoader;
import com.qad.loader.LoadContext;
import com.qad.loader.Settings;
import com.qad.util.MD5;
import com.qad.util.Utils;

/**
 * Heap size is calculated by ({@link #DEFAULT_MAX_HEAP_SZIE} * {@link #DEFAULT_DISPLAY_WIDTH}) / {@link Settings#getDisplayWidth(int)} 
 */
public class ResourceCacheManager extends BaseCacheManager<String, Bitmap> {

	// 默认图片缓存8M = 8 * 1024 Kilo bytes
	private static final int DEFAULT_MAX_HEAP_SZIE = 8 * 1024;
	private static final int DEFAULT_DISPLAY_WIDTH = 480;
	private static final int DEFAULT_MAX_TEXTURE_SIZE = 2048;
	private int maxHeapSize = DEFAULT_MAX_HEAP_SZIE;
	private int displayWidth = DEFAULT_DISPLAY_WIDTH;
	private AtomicLong currentCacheSize = new AtomicLong(-1L);
//	private Map<String, WeakReference<Bitmap>> cacheMap = null;
	private List<String> timestamps = null;
	private File cacheDir = null; 
	private File backupDir = null;
	
	private LruCache<String, BitmapDrawable> imgCache = null;
	private Set<SoftReference<Bitmap>> mReusableBitmaps;
	
	/**
	 * 记录可用的缓存目录
	 */
	private File availableDir = null;
	private Thread cleanupThread = null;
	private static ResourceCacheManager instance = new ResourceCacheManager();
	
	/**
	 * Retrive a singleton of ResourceCacheManager, refer to {@link #ResourceCacheManager(File, File)}
	 */
	public static ResourceCacheManager getInstance() {
		return instance;
	}
	
	/**
	 * Constructor
	 * @param cacheDir Default image cache directory
	 * @param backupDir Backup image cache directory
	 */
	private ResourceCacheManager() {
		cacheDir = Settings.getInstance().getBaseCacheDir();
		backupDir = Settings.getInstance().getBaseBackupDir();
		
		if (cacheDir != null) {
			if (!cacheDir.exists()) cacheDir.mkdirs();
			this.cacheDir = new File(cacheDir, ".res");
		}
		
		if (backupDir != null) { 
			if (!backupDir.exists()) backupDir.mkdirs();
			this.backupDir = new File(backupDir, ".res");
		}
		
		setupDirs();
		
		if (Utils.hasHoneycomb()) {
			maxHeapSize = (int) (Runtime.getRuntime().maxMemory() / 1024 / 6);
			if (maxHeapSize < DEFAULT_MAX_HEAP_SZIE) {
				maxHeapSize = DEFAULT_MAX_HEAP_SZIE;
			} else if (maxHeapSize > 32 * 1024) { // 32M
				maxHeapSize = 32*1024;
			}
			mReusableBitmaps = Collections.synchronizedSet(new HashSet<SoftReference<Bitmap>>());
		} else {
			if (Runtime.getRuntime().maxMemory() <= 33554432) { // 32M
				maxHeapSize = (int) (Runtime.getRuntime().maxMemory() / 1024 / 8);
			} else {
				maxHeapSize = (int) (Runtime.getRuntime().maxMemory() / 1024 / 6);
			}
		}
		
		
		
//		if (Runtime.getRuntime().maxMemory() < 64 * 1024 * 1024) {
//		    //如果系统允许最大heap数小于64M, 最大缓存图片数为5M
//		    maxHeapSize /= 2;
//		}
//		
//		int displayWidth = Settings.getInstance().getDisplayWidth();
//		if (displayWidth > 480) {
//			maxHeapSize = (DEFAULT_MAX_HEAP_SZIE * DEFAULT_DISPLAY_WIDTH )/ displayWidth;
//		}
//		cacheMap = Collections.synchronizedMap(new HashMap<String, WeakReference<Bitmap>>());
//		timestamps = Collections.synchronizedList(new ArrayList<String>());
		Log.e("Sdebug-mm", "size of imgCache " + maxHeapSize/1024 + "MB");
		imgCache = new LruCache<String, BitmapDrawable>(maxHeapSize) {
			@Override
			protected int sizeOf(String key, BitmapDrawable value) {
				// The cache size will be measured in kilobytes rather than
	            // number of items.
//				Log.i("Sdebug-mm", "size of bitmap " + key + " : " + bitmap.getRowBytes() * bitmap.getHeight() / 1024 + "KB");
				final int bitmapSize = getBitmapSize(value) / 1024;
                return bitmapSize == 0 ? 1 : bitmapSize;
			}
			
			@Override
			protected void entryRemoved(boolean evicted, String key,
					BitmapDrawable oldValue, BitmapDrawable newValue) {
				if (RecyclingBitmapDrawable.class.isInstance(oldValue)) {
                    // The removed entry is a recycling drawable, so notify it 
                    // that it has been removed from the memory cache
                    ((RecyclingBitmapDrawable) oldValue).setIsCached(false);
                } else {
                    // The removed entry is a standard BitmapDrawable.
                    if (Utils.hasHoneycomb()) {
                        // We're running on Honeycomb or later, so add the bitmap
                        // to a SoftReference set for possible use with inBitmap later.
                        mReusableBitmaps.add(new SoftReference<Bitmap>(oldValue.getBitmap()));
                    }
                }
//				Log.w("Sdebug-mm", "imgCache entryRemoved called for " + key);
//				if (android.os.Build.VERSION.SDK_INT < 11) {
//					if (null != oldValue && !oldValue.isRecycled()) {
//						Log.w("Sdebug-mm", "recycle bitmap: " + key);
//						oldValue.recycle();
//					}
//				}
			}
		};
		
		if (!Utils.hasHoneycomb()) { // SDK < 11
			if (Settings.getInstance().getDisplayWidth() > displayWidth) {
				displayWidth = Settings.getInstance().getDisplayWidth();
			}
		} else {
			int[] maxTextureSize = new int[1];
			GLES10.glGetIntegerv(GL10.GL_MAX_TEXTURE_SIZE, maxTextureSize, 0);
			int maxTxtSize = DEFAULT_MAX_TEXTURE_SIZE;
			if (maxTextureSize[0] > DEFAULT_MAX_TEXTURE_SIZE) {
				maxTxtSize = maxTextureSize[0];
			}
			Log.e("Sdebug-mm", "maxTextureSize is " + maxTxtSize);
			displayWidth = (maxTxtSize/ 2) - 1; // OPENGL 最大画布，e.g. 2048x2048 on Galxy Nexsus
		}
		Log.e("Sdebug-mm", "displayWidth is " + displayWidth);
		
	}
	
	public Bitmap getBitmapFromReusableSet(BitmapFactory.Options options) {
		Bitmap bitmap = null;

		if (mReusableBitmaps != null && !mReusableBitmaps.isEmpty()) {
			synchronized (mReusableBitmaps) {
				final Iterator<SoftReference<Bitmap>> iterator
				= mReusableBitmaps.iterator();
				Bitmap item;

				while (iterator.hasNext()) {
					item = iterator.next().get();

					if (null != item && item.isMutable()) {
						// Check to see it the item can be used for inBitmap.
						if (canUseForInBitmap(item, options)) {
							bitmap = item;

							// Remove from reusable set so it can't be used again.
							iterator.remove();
							Log.i("Sdebug-mm", "getBitmapFromReusableSet hit!");
							break;
						}
					} else {
						// Remove from the set if the reference has been cleared.
						iterator.remove();
					}
				}
			}
		}
		return bitmap;
	}
	
	private boolean canUseForInBitmap(
	        Bitmap candidate, BitmapFactory.Options targetOptions) {
//
//	    if (Build.VERSION.SDK_INT >= 19) {
//	        // From Android 4.4 (KitKat) onward we can re-use if the byte size of
//	        // the new bitmap is smaller than the reusable bitmap candidate
//	        // allocation byte count.
//	        int width = targetOptions.outWidth / targetOptions.inSampleSize;
//	        int height = targetOptions.outHeight / targetOptions.inSampleSize;
//	        int byteCount = width * height * getBytesPerPixel(candidate.getConfig());
//	        return byteCount <= candidate.getAllocationByteCount();
//	    }

	    // On earlier versions, the dimensions must match exactly and the inSampleSize must be 1
	    return candidate.getWidth() == targetOptions.outWidth
	            && candidate.getHeight() == targetOptions.outHeight
	            && targetOptions.inSampleSize == 1;
	}
	
	public void setupDirs() {
		if (null != cacheDir && !cacheDir.exists()) {
			cacheDir.mkdirs();
		}
		if (null != backupDir && !backupDir.exists()) {
			backupDir.mkdirs();
		}
		
		if (cacheDir.exists()) {
			availableDir = cacheDir;
		} else if (backupDir.exists()) {
			availableDir = backupDir;
		} else {
			availableDir = null;
		}
	}
	
	public synchronized BitmapDrawable getFromMemCache(String param) {
		if (imgCache != null) {
			return imgCache.get(param);
		}
		return null;
	}
	
	public BitmapDrawable getCache(LoadContext context) {
		BitmapDrawable drawable = null;
		String param = context.getParam().toString();
//		if (null != imgCache) {
//			drawable = getFromMemCache(param);
//		}
//		if (null == drawable) {
			File file = getCacheFile(param, true);
			if (file != null && file.exists()) {
				Bitmap bitmap = null;
				Object target = context.getTarget();
				if (context.is4Slide()) {
					bitmap = Files.fetchImage(file.getAbsolutePath(), displayWidth);
				} else if (null != target && target instanceof ImageView) {
					int w = ((ImageView)target).getWidth();
					int h = ((ImageView)target).getHeight();
//					Log.w("Sdebug-mm", "ResouceCacheManager w x h: " + ((ImageView)target).getWidth() + " x "+((ImageView)target).getHeight());
					if (0 == w || 0 == h) {
						bitmap = Files.fetchImage(file.getAbsolutePath(), displayWidth);
					} else {
						bitmap = Files.fetchImage(file.getAbsolutePath(), ((ImageView)target).getWidth(), ((ImageView)target).getHeight());
					}
				} else {
					bitmap = Files.fetchImage(file.getAbsolutePath(), displayWidth);
				}
				if (null != bitmap) {
//					if (null != context.getTarget() && context.getTarget() instanceof ImageView) {
						if (Utils.hasHoneycomb()) {
		                    // Running on Honeycomb or newer, so wrap in a standard BitmapDrawable
		                    drawable = new BitmapDrawable(ImageLoader.getInstance().getAppContext().getResources(), bitmap);
		                } else {
		                    // Running on Gingerbread or older, so wrap in a RecyclingBitmapDrawable
		                    // which will recycle automagically
		                    drawable = new RecyclingBitmapDrawable(ImageLoader.getInstance().getAppContext().getResources(), bitmap);
		                } 
						saveMemCache(param, drawable);
//					}
				}
			}
//		}
		return drawable;
	}


	@Override
	public Bitmap getCache(String param) {
//		Bitmap bitmap = null;
//		if (imgCache != null) {
//			bitmap = imgCache.get(param).getBitmap();
//			if (null != bitmap && !bitmap.isRecycled()) {
//				return bitmap;
//			} else if (null != bitmap && bitmap.isRecycled()) {
//				imgCache.remove(param);
//			}
//			WeakReference<Bitmap> bmpRef = cacheMap.get(param);
//
//			if (null != bmpRef) {
//				bitmap = bmpRef.get();
//				if (null != bitmap && !bitmap.isRecycled()) {
//					return bitmap;
//				} else if (null != bitmap && bitmap.isRecycled()) {
//					Log.e("Sdebug-mm", "bitmap " + param + " got recycled !!!");
//					cacheMap.remove(param);
//					bitmap = null;
//				}
//			}
//			bitmap = cacheMap.get(param).get();
//			if (bitmap != null && !bitmap.isRecycled()) {
//				return bitmap;
//			} else if (null != bitmap && bitmap.isRecycled()) {
//				Log.e("Sdebug-mm", "bitmap " + param + " got recycled !!!");
//				cacheMap.remove(param);
//				bitmap = null;
//			}
//		}
		
//		File file = getCacheFile(param, true);
//		if (file != null && file.exists()) {
//			bitmap = Files.fetchImage(file.getAbsolutePath(), displayWidth);
//			if (bitmap != null && !bitmap.isRecycled()) {
////				saveMemCache(param, bitmap);
//				return bitmap;
//			}
//		}
		return null;
	}
	
	@Override
	public File saveCache(String param, Bitmap result) {
		if (result == null) return null;
		
//			Log.d("ResourceCacheManager", "FreeSize:" + getAvailableSpaceInBytes());
		if (getAvailableSpaceInBytes() < 1048576) {
			// 如果剩余空间小于1MB: 1024*1024 bytes, 启动线程，按时间排序，删除一半缓存数据
			if (null == cleanupThread) {
				synchronized(this) {
					final File dir = availableDir;
					if (null == cleanupThread) {
						cleanupThread = new Thread() {
							public void run() {
								File[] files = dir.listFiles();
								Log.e("ResourceCacheManager", "start: " + System.currentTimeMillis());
								// 较旧的文件在前面
								Arrays.sort(files, new Comparator<File>(){
									public int compare(File f1, File f2)
									{
										return Long.valueOf(f1.lastModified()).compareTo(f2.lastModified());
									} });
								for (int i = 0; i < files.length / 2; i++) {
									if (!files[i].isDirectory()) {
										// delete file
										files[i].delete();
									}
								}
								Log.e("ResourceCacheManager", "end: " + System.currentTimeMillis());
								cleanupThread = null;
							};
						};
						cleanupThread.start();

					}
				}
			}
		}
		
		File file = null;
		try {
			file = getCacheFile(param);
			if (file != null) {
				// 按PNG格式存储会造成正文中图片显示空白
//				if(param.contains(".xxxPNG")){
//					Files.writeCompressedImage(file, result, Bitmap.CompressFormat.PNG);
//				}else{
					Files.writeCompressedImage(file, result);
//				}
			}
		} catch (Exception e) {
			Log.w(getClass().getSimpleName(), "Exception occurs while saving bitmap as file", e);
//			LogHandler.addLogRecord("ResourceCacheManager"
//			        , "Exception occurs while saving bitmap as file"
//			        , "" + e.getMessage());
			file = null;
		}
		
//		saveMemCache(param, result);
		return file;
	}
	
	/**
	 * @return Number of bytes available on External storage
	 */
	private long getAvailableSpaceInBytes(){
		if (null != availableDir && availableDir.exists()) {
			StatFs stat = new StatFs(availableDir.getPath());
			return (long) stat.getAvailableBlocks() * (long) stat.getBlockSize();
		} else {
			return 1048576; // won't trigger FS cleanup
		}
	}
	
	private synchronized void saveMemCache(String param, BitmapDrawable value) {
		if (null == imgCache.get(param)) {
			if (RecyclingBitmapDrawable.class.isInstance(value)) {
                // The removed entry is a recycling drawable, so notify it 
                // that it has been added into the memory cache
                ((RecyclingBitmapDrawable) value).setIsCached(true);
            }
			imgCache.put(param, value);
		}
//		cacheMap.put(param, new WeakReference<Bitmap>(result));
//		timestamps.add(param);
//		currentCacheSize.addAndGet(Bitmaps.getBytesSize(result));
//
//		Log.i("Sdebug", "Image current cache size is " + currentCacheSize.get() / 1024 + "K");
//		if (currentCacheSize.get() > maxHeapSize) {
//			adjustHeap();
//		}
	}
/*
	private synchronized void adjustHeap() {
	    if (currentCacheSize.get() > maxHeapSize) {
    		long clearedSize = 0L;
    		Log.i("Sdebug", "=== start === adjustHeap called maxHeapSize is " + maxHeapSize
    				+ " ,currentCacheSize is " + currentCacheSize);
    		// 删除最旧的1/2的图片引用
    		int index = timestamps.size()/2;
    		for (int i = 0; i < index; i++) {
    		    Bitmap removedBitmap = cacheMap.remove(timestamps.get(i)).get();
    		    if (null != removedBitmap && !removedBitmap.isRecycled()) {
    		        clearedSize += Bitmaps.getBytesSize(removedBitmap);
    		    }
    		}
    		timestamps = Collections.synchronizedList(timestamps.subList(index, timestamps.size()));
    		currentCacheSize.addAndGet(-clearedSize);
    		
//    		for (;;) {
//    			if (cacheMap.size() == 0 || clearedSize >= currentCacheSize / 3) {
//    				break;
//    			}
//    			Bitmap removedBitmap = cacheMap.remove(cacheMap.keySet().iterator().next());
//    			
//    			clearedSize += Bitmaps.getBytesSize(removedBitmap);
//    		}
//    		currentCacheSize -= clearedSize;
    		Log.i("Sdebug", "=== end ===  adjustHeap called clearedSize is " + clearedSize
    				+ " ,currentCacheSize is " + currentCacheSize);
	    }
	}
*/
	
	@Override
	public synchronized void clearCache() {
		if (null != imgCache) {
			imgCache.evictAll();
		}
//		clearMemCache();
//		Files.deleteDir(cacheDir);
//		Files.deleteDir(backupDir);
//		availableDir = null;
//		setupDirs();
	}
	
//	public void clearMemCache() {
//		if (cacheMap != null) {
//			cacheMap.clear();
//		}
//		if (timestamps != null) {
//            timestamps.clear();
//		}
//		currentCacheSize.set(0L);
//	}
	
	@Override
	public long length() {
		return currentCacheSize.get();
	}
	
	public File getCacheFile(String param, boolean strict) {
		if (param == null) return null;
		
		if (!strict) return getCacheFile(param);
		
		File file = null;
		String fileName = MD5.md5s(param);
		BitmapFactory.Options opts = new BitmapFactory.Options();
		opts.inJustDecodeBounds = true;
		
		if (cacheDir != null && cacheDir.exists()) {
			file = new File(cacheDir, fileName);
			if(file.exists()){
				BitmapFactory.decodeFile(file.getAbsolutePath(), opts);
				if (opts.outHeight > 0 && opts.outWidth > 0 && opts.outMimeType != null) {
					return file;
				} else {
					// 图片文件数据不对，删除之
					file.delete();
				}
			}
		}
		
		if (backupDir != null && backupDir.exists()) {
			file = new File(backupDir, fileName);
			if(file.exists()){
				BitmapFactory.decodeFile(file.getAbsolutePath(), opts);
				if (opts.outHeight > 0 && opts.outWidth > 0 && opts.outMimeType != null) {
					return file;
				} else {
					// 图片文件数据不对，删除之
					file.delete();
				}
			}
		}
		
		return null;
	}
	
	/**
	 * Return cache file according to cache directory accessability
	 * 
	 * @param param Param used to identify cache file
	 * @return Cache file object or null if cache directory is not accessable
	 */
	public File getCacheFile(String param) {
		if (param == null) return null;
		
		String fileName = MD5.md5s(param);
		
		File file = null;
		if (cacheDir != null && cacheDir.exists()) {
			file = new File(cacheDir, fileName);
			return file;
		} 
		
		if (backupDir != null && backupDir.exists()) {
			file = new File(backupDir, fileName);
			return file;
		}
		
		return null;
	}
	
	/**
     * Get the size in bytes of a bitmap in a BitmapDrawable. Note that from Android 4.4 (KitKat)
     * onward this returns the allocated memory size of the bitmap which can be larger than the
     * actual bitmap data byte count (in the case it was re-used).
     *
     * @param value
     * @return size in bytes
     */
    @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
	public static int getBitmapSize(BitmapDrawable value) {
        Bitmap bitmap = value.getBitmap();

        if (Utils.hasHoneycombMR1()) {
            return bitmap.getByteCount();
        }

        // Pre HC-MR1
        return bitmap.getRowBytes() * bitmap.getHeight();
    }
}
