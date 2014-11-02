package com.ifeng.news2.commons.upgrade;

import android.content.Context;
import android.content.Intent;

import com.ifeng.news2.commons.upgrade.download.AtmoReceiver;
import com.ifeng.news2.commons.upgrade.download.GroundReceiver;
import com.qad.service.DownloadReceiver;
import com.qad.service.DownloadService;

/**
 * 不要继承本类。欲做生命周期拦截请设置UpgradeServiceCallback
 * 
 * @author 13leaf
 * 
 */
public class UpgradeService extends DownloadService {

	/**
	 * enum名字
	 */
	public static final String EXTRA_UPGRADE_TYPE = "extra.com.ifeng.commans.upgrade.upgrade_type";

	public static void startGroundUpgrade(Context context, String url,
			String targetPath, GroundReceiver receiver) {
		start(context, UpgradeType.Ground, url, targetPath, receiver, null);
	}

	public static void startAtmoUpgrade(Context context, String url,
			String targetPath, AtmoReceiver receiver) {
		start(context, UpgradeType.Atmosphere, url, targetPath, receiver, null);
	}

	/**
	 * 
	 * @param context
	 * @param type
	 * @param url
	 * @param targetPath
	 * @param upgradeReceiver
	 *            监听更新的生命周期
	 * @param serviceCallBack
	 *            null表示没有回调拦截
	 */
	public static void start(Context context, UpgradeType type, String url,
			String targetPath, DownloadReceiver upgradeReceiver,
			UpgradeServiceCallBack serviceCallBack) {
		Intent intent = new Intent(context, UpgradeService.class);
		intent.putExtra(EXTRA_DOWNLOAD_URL, url);
		intent.putExtra(EXTRA_TARGET_PATH, targetPath);
		intent.putExtra(EXTRA_UPGRADE_TYPE, type.name());
		if (callBack != null) {
			synchronized (lock) {
				callBack = serviceCallBack;
			}
		}
		context.getApplicationContext().registerReceiver(upgradeReceiver,
				upgradeReceiver.getIntentFilter());
		context.startService(intent);

	}

	private static UpgradeServiceCallBack callBack;

	private static Object lock = new Object();

	public interface UpgradeServiceCallBack {
		void onPreDownload(UpgradeService service, Intent intent);

		void onPostDownload(UpgradeService service, Intent intent);

		void onPublish(UpgradeService service, Intent intent, long downSize,
				long fullSize, int percent);
	}

	@Override
	protected void preDownload() {
		if (callBack != null) {
			synchronized (lock) {
				callBack.onPreDownload(this, currentIntent);
			}
		}
	}

	@Override
	public boolean publish(long downSize, long fullSize, int percent) {
		if (callBack != null) {
			synchronized (lock) {
				callBack.onPublish(this, currentIntent, downSize, fullSize,
						percent);
			}
		}
		return super.publish(downSize, fullSize, percent);
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		callBack = null;
	}

}
