package com.ifeng.commons.upgrade;

import java.io.File;
import java.io.IOException;
import java.lang.ref.WeakReference;

import android.content.Context;
import android.os.Environment;

import com.ifeng.commons.upgrade.download.AtmoReceiver;
import com.ifeng.commons.upgrade.download.Callback;
import com.ifeng.commons.upgrade.download.GroundReceiver;
import com.qad.net.HttpManager;

/**
 * 
 * @author 13leaf
 * 
 */
public class UpgradeManager {

	private final Version appVersion;
	private final Version atmoVersion;
	private final WeakReference<Context> ctxRef;
	public final File tempUpgradeApk;

	private GroundReceiver groundReceiver;
	private AtmoReceiver atmoReceiver;

	public UpgradeManager(final Context context) {
		this(context, null);
	}

	public UpgradeManager(final Context context, final Version atmoVersion) {
		appVersion = Utils.getSoftwareVersion(context);
		this.atmoVersion = atmoVersion;
		ctxRef = new WeakReference<Context>(context);
		tempUpgradeApk = new File(Environment.getExternalStorageDirectory(),
				"/com_ifeng_upgrade_temp_" + Math.random() * 10000 + ".apk");
	}

	public Version getAppVersion() {
		return appVersion;
	}

	/**
	 * 覆盖默认的Ground升级更新监听<br>
	 * @param groundReceiver
	 */
	public void setGroundReceiver(GroundReceiver groundReceiver) {
		this.groundReceiver = groundReceiver;
	}

	/**
	 * 覆盖默认的Atmo升级更新监听
	 * 
	 * @param atmoReceiver
	 */
	public void setAtmoReceiver(AtmoReceiver atmoReceiver) {
		this.atmoReceiver = atmoReceiver;
	}

	/**
	 * 从网络读取升级接口，并返回接口处理结果
	 * 
	 * @param url
	 * @param handler
	 * @return
	 * @throws 检查连接发生错误时
	 *             ,或者检查服务器升级文件错误时
	 */
	public UpgradeResult checkUpgrade(String url, UpgradeParser handler,boolean forceUpgrade)
			throws IOException, HandlerException {
		String content = HttpManager.getHttpText(url);
		return handler.parse(content, appVersion, atmoVersion,forceUpgrade);
	}

	/**
	 * 使用默认凤凰新闻的升级数据格式
	 * 
	 * @param url
	 * @return
	 * @throws IOException
	 * @throws HandlerException
	 */
	public UpgradeResult checkUpgrade(String url,boolean forceUpgrade) throws IOException,
			HandlerException {
		return checkUpgrade(url, new DefaultParser(),forceUpgrade);
	}

	/**
	 * 开始本地层升级
	 * 
	 * @param apkUrl
	 */
	public void startGroundUpgrade(String apkUrl, Callback callback) {
		Context context = ctxRef.get();
		if (context != null) {
			UpgradeService.startGroundUpgrade(context, apkUrl,
					tempUpgradeApk.getAbsolutePath(),
					getGroudReceiver(context, callback));
		}
	}

	/**
	 * 开始Atmo层升级
	 * 
	 * @param atmoUrl
	 * @param targetPath
	 * @param callback
	 */
	public void startAtmoUpgrade(String atmoUrl, String targetPath,
			Callback callback) {
		Context context = ctxRef.get();
		if (context != null) {
			UpgradeService.startAtmoUpgrade(context, atmoUrl, targetPath,
					getAtmoReceiver(callback));
		}
	}
	
	private AtmoReceiver getAtmoReceiver(Callback callback) {
		if(atmoReceiver==null)
			atmoReceiver=new AtmoReceiver(callback);
		atmoReceiver.setCallback(callback);
		return atmoReceiver;
	}

	private GroundReceiver getGroudReceiver(Context context, Callback callback) {
		if (groundReceiver == null) {
			Context app = context.getApplicationContext();
			UpgradeNotify notify = app.getClass().getAnnotation(
					UpgradeNotify.class);
			if (notify != null) {
				return new GroundReceiver.Builder(context)
						.setDefaultIcon(notify.drawable_default_icon())
						.setFailIcon(notify.drawable_fail_icon())
						.setFailMessage(
								notify.failMessage().length() == 0 ? null
										: notify.failMessage())
						.setPercentTextId(notify.id_percent())
						.setProgressBarId(notify.id_progressbar())
						.setStartIcon(notify.drawable_start_icon())
						.setStartTicker(
								notify.startTicker().length() == 0 ? null
										: notify.startTicker())
						.setSuccessIcon(notify.drawable_success_icon())
						.setSuccessTicker(
								notify.successTicker().length() == 0 ? null
										: notify.successTicker())
						.setSucessMessage(
								notify.successMessage().length() == 0 ? null
										: notify.successMessage())
						.setTitleTextId(notify.id_title())
						.setUpdateIcon(notify.drawable_update_icon())
						.setUpdateImageId(notify.id_icon())
						.setUpdateLayout(notify.layout_update())
						.setUpdateTitle(
								notify.updateTitle().length() == 0 ? null
										: notify.updateTitle())
						.setCallback(callback).build();
			} else {
				return new GroundReceiver.Builder(context)
						.setCallback(callback).build();
			}
		}
		groundReceiver.setCallback(callback);
		return groundReceiver;
	}

}
