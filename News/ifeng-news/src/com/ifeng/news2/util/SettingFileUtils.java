package com.ifeng.news2.util;

import java.io.File;
import org.apache.commons.io.FileUtils;
import android.widget.ProgressBar;

/**
 * 用于删除文件以及删除过程中进度条的更新
 * 
 * @author SunQuan:
 * @version 创建时间：2013-11-16 下午1:21:59 类说明
 */

public class SettingFileUtils {

	private static int fileCounter = 0;

	/**
	 * 删除文件夹内的所有文件，同时更新进度条
	 * 
	 * @param file
	 * @param progressBar
	 */
	public static void deleteDirAndUpdateProgressBar(ProgressBar progressBar,
			File... filess) {
		if (progressBar == null) {
			throw new RuntimeException("Progressbar should not be null!");
		} else {
			progressBar.setProgress(0);
			int length = 0;
			for (File fil : filess) {
				fileCounter = 0;
				length += tree(fil);
			}
			progressBar.setMax(length);
			for (File fil : filess) {
				deleteDir(progressBar, fil);
			}
			
		}
	}

	private static void deleteDir(ProgressBar progressBar, File file) {
		if ((file == null) || !file.exists() ||  !file.isDirectory()) {
//			throw new IllegalArgumentException("Argument " + file
//					+ " is not a directory. ");
			return;
		}
		File[] files = file.listFiles();
		for (File fil : files) {
			if (fil.isDirectory()) {
				deleteDir(progressBar, fil);
			} else {
				fil.delete();
				if (progressBar != null) {
					progressBar.incrementProgressBy(1);
				}
			}
		}
	}


	/**
	 * 用于计数文件夹中所有文件数量
	 * 
	 * @param file
	 * @return
	 */
	public static int tree(File file) {
		if ((file == null) || !file.exists() || !file.isDirectory()) {
			return 0;
		}
		File[] files = file.listFiles();
		for (File fil : files) {
			if (fil.isDirectory()) {
				tree(fil);
			} else {
				fileCounter++;
			}
		}
		return fileCounter;
	}

	/**
	 * 得到所有文件的大小
	 * 
	 * @param files
	 * @return
	 */
	public static int getFileSize(File... files) {
		long length = 0;
		for (File file : files) {

			if (file.exists()) {
				length += FileUtils.sizeOfDirectory(file);
			}
		}
		return (int) length;
	}
}
