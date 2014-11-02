package com.ifeng.commons.upgrade.download;

import android.app.Notification;

/**
 * 下载更新
 * 
 * @author 13leaf
 * 
 */
public interface DownloadUpdater {

	/**
	 * 根据进度做出更新
	 * 
	 * @param percent
	 * @param notification
	 */
	public void update(int percent, Notification notification);
}
