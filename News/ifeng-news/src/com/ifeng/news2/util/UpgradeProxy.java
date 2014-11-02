package com.ifeng.news2.util;

import java.io.File;
import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import com.ifeng.news2.commons.upgrade.UpgradeHandler;
import com.ifeng.news2.commons.upgrade.Upgrader;
import com.ifeng.news2.commons.upgrade.Version;
import com.ifeng.news2.commons.upgrade.download.Callback;
import com.ifeng.news2.Config;
import com.ifeng.news2.util.SplashUpgradeHandler.UpgradeListener;
import com.qad.io.Zipper;

/**
 * The proxy class for upgrading
 * 
 * @author Administrator
 * 
 */
public class UpgradeProxy {

	protected static final int ERROR_CHECK = 0x0001;
	protected static final int NONEED_CHECK = 0x0002;
	protected static final int NEED_CHECK = 0x0003;
	private boolean strict = false;
	private boolean autoUpgrade;
	private static UpgradeProxy manualUpgradeProxy = null;
	private static UpgradeProxy autoUpgradeProxy = null;

	public UpgradeProxy setAutoUpgrade(boolean autoUpgrade) {
		this.autoUpgrade = autoUpgrade;
		return this;
	}

	private Handler mHandler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			CheckListener callback = (CheckListener) msg.obj;
			switch (msg.what) {
			case ERROR_CHECK:
				callback.errorCheck();
				break;
			case NEED_CHECK:
				callback.needUpgrade();
				break;
			case NONEED_CHECK:
				callback.noNeedUpgrade();
				break;
			default:
				break;
			}

		}
	};

	private UpgradeProxy() {
	}

	/**
	 * create an auto upgrade class
	 * 
	 * @return
	 */
	public static UpgradeProxy createAutoUpgradeProxy() {
		if(autoUpgradeProxy == null) {
			autoUpgradeProxy =  new UpgradeProxy().setAutoUpgrade(true);
		}
		return autoUpgradeProxy;
	}

	/**
	 * create a manual upgrade class
	 * 
	 * @return
	 */
	public static UpgradeProxy createManualUpgradeProxy() {
		if(manualUpgradeProxy == null) {
			manualUpgradeProxy = new UpgradeProxy().setAutoUpgrade(false); 
		}
		return manualUpgradeProxy;
	}

	/**
	 * set whether to force upgrade or not
	 * 
	 * @param strict
	 */
	public UpgradeProxy setStrict(boolean strict) {
		this.strict = strict;
		return this;
	}

	public void checkUpgrade(Activity activity, CheckListener callback) {
		check(activity, callback);
	}

	public void checkUpgrade(Activity activity) {
		check(activity, null);
	}

	private void unZipPlugin(final Activity activity) {
		final File targetDir = activity.getFileStreamPath("");
		new Thread(new Runnable() {

			@Override
			public void run() {
				try {
					Zipper.unzip(Config.TARGET_PLUGIN_ZIP,
							targetDir.getAbsolutePath());
					ConfigManager.notifyUpgrade(activity);
				} catch (Exception e) {
					Log.i("upgrade", "zip error");
					// do nothing
				}
			}
		}).start();
	}

	private SplashUpgradeHandler createUpgradeHandler(final Activity activity) {

		Log.i("news", "current config version = "
				+ Config.CURRENT_CONFIG_VERSION);
		SplashUpgradeHandler handler = new SplashUpgradeHandler(null, activity,
				"当前应用需要更新版本后才能使用,是否升级?", "发现有新的版本,是否升级?",
				Config.TARGET_PLUGIN_ZIP, new Callback() {
					@Override
					public void onDownloadDone(boolean success, Context context) {
						if (!success) {
							return;
						}
						unZipPlugin(activity);
					}
				});
		return autoUpgrade ? handler.setAutoUpgrade(true) : handler
				.setAutoUpgrade(false);
	}

	private void upgrade(Activity activity, UpgradeHandler handler) {
		Version atmoVersion = new Version(Config.CURRENT_CONFIG_VERSION);
		Upgrader upgrader = Upgrader.ready(activity)
				.setCustomUpgradeHandler(handler)
				.setUpgradeUrl(ParamsManager.addParams(activity, Config.APP_UPGRADE_URL))
				.setAtmoVersion(atmoVersion)
				.setAtmoTargetPath(Config.TARGET_PLUGIN_ZIP).setStrict(strict);
		upgrader = autoUpgrade ? upgrader.setForceUpgrade(true) : upgrader
				.setForceUpgrade(false);
		upgrader.upgrade();
	}

	private boolean isNeedCheck() {
		return Config.isUpgrader;
	}

	private void sendMessage(int checkType, CheckListener callback) {
		Message message = new Message();
		message.obj = callback;
		message.what = checkType;
		mHandler.sendMessage(message);
	}

	private void check(Activity activity, final CheckListener callback) {
		if (!isNeedCheck()&&autoUpgrade) {
			return;
		}
		SplashUpgradeHandler handler = createUpgradeHandler(activity);
		if (callback != null) {
			handler.setListener(new UpgradeListener() {

				@Override
				public void onReceiveUpgrade() {
					sendMessage(NEED_CHECK, callback);
				}

				@Override
				public void onReceiveFinish() {
					sendMessage(NONEED_CHECK, callback);
				}

				@Override
				public void onReceiveError() {
					sendMessage(ERROR_CHECK, callback);
				}
			});
		}
		upgrade(activity, handler);
	}

	public interface CheckListener {

		/**
		 * it is called if it is failing to access to the online data
		 */
		void errorCheck();

		/**
		 * it is called when the current version is not equivalent to the online
		 * version
		 */
		void needUpgrade();

		/**
		 * it is called when the current version is equivalent to the online
		 * version
		 */
		void noNeedUpgrade();
	}
}
