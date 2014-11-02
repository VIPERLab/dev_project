package com.ifeng.news2.plutus.core.model.cache;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.nio.channels.FileLock;

import com.ifeng.news2.plutus.core.PlutusCoreManager;
import com.ifeng.news2.plutus.core.utils.CoderUtil;

/**
 * Persistant cache loader to get/put loaded cache
 * @author gao_miao
 *
 * @param <Result> The object to to get/put, must implements Serializable
 */
public class PlutusCorePersistantCache<Result extends Serializable> extends
		PlutusCoreCache<Result> {
	
	private static final String FILE_SUFIX = PlutusCorePersistantCache.class.getName();
	private File dir = null;

	/**
	 * Constructor with file dir used to get/put cache
	 * @param base The cache dir
	 */
	public PlutusCorePersistantCache(File base) {
		this.dir = new File(base, "." + CoderUtil.encode(FILE_SUFIX));
		if (!this.dir.exists())
			this.dir.mkdir();
	}

	/**
	 * Constructor with default dir (sdcard) to get/put cache
	 */
	public PlutusCorePersistantCache() {
		this(new File(PlutusCoreManager.getCacheDir()));
	}

	/**
	 * Check if cache coresponding to the specific key exists
	 * @param key The key used to identify a cache file
	 * @return true if specific cache exists, false otherwise
	 */
	public boolean hasCache(String key) {
		if (!checkFileState(dir))
			return false;
		File cache = new File(dir, CoderUtil.encode(key));
		return cache.exists();
	}

	/**
	 * Get the {@link java.io.File#lastModified() lastModified} time if cache exists, or 
	 * 0 if cache is not found
	 * @param key The key used to identify a cache file
	 * @return {@link java.io.File#lastModified() lastModified}
	 */
	public long lastModified(String key) {
		if (!checkFileState(dir))
			return 0L;
		File cache = new File(dir, CoderUtil.encode(key));
		if (cache.exists()) {
			return cache.lastModified();
		} else
			return 0L;
	}
	
	/**
	 * Get a cache object with the specitied key
	 * @param key The key used to identify a cache file
	 * @return Result The cached object of type Result
	 */
	@SuppressWarnings("unchecked")
	public Result get(String key) {
		if (!checkFileState(dir))
			return null;
		File cache = new File(dir, CoderUtil.encode(key));
		if (cache.exists()) {
			FileInputStream fis = null;
			ObjectInputStream ois = null;
			try {
				fis = new FileInputStream(cache);
				ois = new ObjectInputStream(fis);
				return ((Result) ois.readObject());
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
					if (ois != null)
						ois.close();
					if (fis != null)
						fis.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return null;
	}

	/**
	 * Put an object to persistant cache to refer in the furture
	 * @param key The key to identify the cache file, which should be unique
	 * @param result The object to serialize to a file object
	 */
	@Override
	public void put(String key, Result result) {
		File cache = new File(dir, CoderUtil.encode(key));
		if (!cache.exists())
			try {
				cache.createNewFile();
			} catch (IOException e) {
				e.printStackTrace();
				return;
			}
		if (checkFileState(cache)) {
			FileOutputStream fos = null;
			ObjectOutputStream oos = null;
			try {
				fos = new FileOutputStream(cache);
				FileLock lock = fos.getChannel().tryLock();
				if (lock != null) {
					oos = new ObjectOutputStream(fos);
					oos.writeObject(result);
					oos.flush();
					lock.release();
				}
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
					if (oos != null)
						oos.close();
					if (fos != null)
						fos.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}

	public void deleteCache(String key) {
		if (!checkFileState(dir))
			return;
		File cache = new File(dir, CoderUtil.encode(key));
		cache.delete();
	}
	
	/**
	 * Clear all cached files
	 */
	@Override
	public void clear() {
		File[] files = dir.listFiles();
		for (int i = 0; i < files.length; i++)
			files[i].delete();
		dir.delete();
	}

	/**
	 * Check if the given file can be read&write
	 * @param file File to check
	 * @return True if permitted to read&write, false otherwise
	 */
	private boolean checkFileState(File file) {
		return file.canRead() && file.canWrite();
	}
}
