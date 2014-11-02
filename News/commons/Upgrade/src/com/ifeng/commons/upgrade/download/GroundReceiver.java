package com.ifeng.commons.upgrade.download;

import java.io.File;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Environment;
import android.widget.RemoteViews;

import com.ifeng.commons.upgrade.UpgradeService;
import com.ifeng.commons.upgrade.UpgradeType;
import com.ifeng.commons.upgrade.Utils;
import com.qad.service.DownloadReceiver;
import com.qad.system.PhoneManager;
import com.qad.util.IntentFactory;
import com.qad.util.NotificationBuilder;

/**
 * 更新Notification提示
 * 
 * @author 13leaf
 * 
 */
public class GroundReceiver extends DownloadReceiver {

	private final static int NOTIFY_ID_START = 0;
	private final static int NOTIFY_ID_PUBLISH = 0;// they are the same,after
													// publish auto replace
													// start
	private final static int NOTIFY_ID_SUCCESS = 2;
	private final static int NOTIFY_ID_FAIL = 3;
	private final static int NOTIFY_ID_FAIL_NETWORK = 4;

	// configs
	protected int layout_update;

	protected int drawable_default_icon, drawable_start_icon,
			drawable_update_icon, drawable_success_icon, drawable_fail_icon;
	protected int id_percent, id_icon, id_title, id_progressbar;

	protected CharSequence startTicker, successTicker, successMessage,
			failTicker, failMessage, updateTitle,newtorkTicker;
	// Notifications
	protected NotificationManager manager;

	protected Notification updateNotification;

	protected Notification startNotification;

	protected Notification successNotification;

	protected Notification failNotification;
	
	protected Notification networkNotification;

	protected Callback callback;

	/**
	 * 定制化参数
	 * 
	 * @author 13leaf
	 * 
	 */
	public static class Builder {
		GroundReceiver receiver;
		Context context;

		public Builder(final Context context) {
			receiver = new GroundReceiver();
			this.context = context;
		}

		public Builder setUpdateLayout(int layout) {
			receiver.layout_update = layout;
			return this;
		}

		/**
		 * 默认图标，成功失败均如此现实
		 * 
		 * @param drawable
		 */
		public Builder setDefaultIcon(int drawable) {
			receiver.drawable_default_icon = drawable;
			return this;
		}

		public Builder setUpdateIcon(int drawable) {
			receiver.drawable_update_icon = drawable;
			return this;
		}

		public Builder setStartIcon(int drawable) {
			receiver.drawable_start_icon = drawable;
			return this;
		}

		public Builder setSuccessIcon(int drawable) {
			receiver.drawable_success_icon = drawable;
			return this;
		}

		public Builder setFailIcon(int drawable) {
			receiver.drawable_fail_icon = drawable;
			return this;
		}

		public Builder setPercentTextId(int id) {
			receiver.id_percent = id;
			return this;
		}

		public Builder setUpdateImageId(int id) {
			receiver.id_icon = id;
			return this;
		}

		public Builder setTitleTextId(int id) {
			receiver.id_title = id;
			return this;
		}

		public Builder setProgressBarId(int id) {
			receiver.id_progressbar = id;
			return this;
		}

		public Builder setStartTicker(CharSequence start) {
			receiver.startTicker = start;
			return this;
		}

		public Builder setSuccessTicker(CharSequence s) {
			receiver.successTicker = s;
			return this;
		}

		public Builder setSucessMessage(CharSequence s) {
			receiver.successMessage = s;
			return this;
		}

		public Builder setFailMessage(CharSequence s) {
			receiver.failMessage = s;
			return this;
		}

		public Builder setUpdateTitle(CharSequence s) {
			receiver.updateTitle = s;
			return this;
		}

		public Builder setCallback(Callback callback) {
			receiver.callback = callback;
			return this;
		}

		public GroundReceiver build() {
			if(receiver.layout_update==0)
				throw new IllegalArgumentException("You must set layout_update at least!");
			ensureDefaultDrawable();
			ensureMessage();
			return receiver;
		}

		private void ensureMessage() {
			String appLabel = Utils.getAppLabel(context);
			if (receiver.startTicker == null)
				receiver.startTicker = appLabel + "开始下载";
			if (receiver.successTicker == null)
				receiver.successTicker = appLabel + "下载成功";
			if (receiver.failTicker == null)
				receiver.failTicker =  "当前无SD卡,下载失败";
			if (receiver.successMessage == null)
				receiver.successMessage = appLabel + "下载成功";
			if (receiver.failMessage == null)
				receiver.failMessage = appLabel + "当前无SD卡,下载失败";
			if (receiver.updateTitle == null)
				receiver.updateTitle = appLabel;
			if (receiver.newtorkTicker == null)
				receiver.newtorkTicker =  "网络连接错误，下载失败";
		}

		private void ensureDefaultDrawable() {
			if (receiver.drawable_default_icon == 0)
				receiver.drawable_default_icon = context.getApplicationInfo().icon;
			if (receiver.drawable_fail_icon == 0)
				receiver.drawable_fail_icon = receiver.drawable_default_icon;
			if (receiver.drawable_start_icon == 0)
				receiver.drawable_start_icon = receiver.drawable_default_icon;
			if (receiver.drawable_success_icon == 0)
				receiver.drawable_success_icon = receiver.drawable_default_icon;
			if (receiver.drawable_update_icon == 0)
				receiver.drawable_update_icon = receiver.drawable_default_icon;
		}

	}

	private GroundReceiver() {

	}
	
	public void setCallback(Callback callback) {
		this.callback = callback;
	}

	@Override
	protected void onNewDownload(String downloadUrl, String targetPath,
			Context context) {
		manager = (NotificationManager) context
				.getSystemService(Context.NOTIFICATION_SERVICE);
		initNotification(targetPath, context);
		manager.notify(NOTIFY_ID_START, startNotification);
	}

	private void initNotification(String targetPath, Context context) {
		startNotification = new NotificationBuilder(context)
				.setSmallIcon(drawable_start_icon)
				.setTicker(startTicker)
				.setAutoCancel(false).getNotification();
		//
		RemoteViews updateContent=new RemoteViews(context.getPackageName(), layout_update);
		if(id_icon!=0){
			updateContent.setImageViewResource(id_icon, drawable_update_icon);
		}
		if (id_title != 0) {
			updateContent.setTextViewText(id_title,
					updateTitle);
		}
		updateNotification = new NotificationBuilder(context)
				.setSmallIcon(drawable_start_icon)
				.setTicker(startTicker)
				.setContent(updateContent)
				.setAutoCancel(false).getNotification();
		//
		successNotification = new NotificationBuilder(context)
				.setAutoCancel(true)
				.setOnlyAlertOnce(true)
				.setTicker(successTicker)
				.setSmallIcon(drawable_success_icon)
				.setContentIntent(
						PendingIntent.getActivity(context, 0, IntentFactory
								.getInstallIntent(new File(targetPath)), 0))
				.setContentText(successMessage).getNotification();
		//
		failNotification = new NotificationBuilder(context).setAutoCancel(true)
				.setOnlyAlertOnce(true).setTicker(failTicker)
				.setSmallIcon(drawable_fail_icon).setContentText("")
				.getNotification();
		networkNotification = new NotificationBuilder(context).setAutoCancel(true)
				.setOnlyAlertOnce(true).setTicker(newtorkTicker)
				.setSmallIcon(drawable_fail_icon).setContentText("")
				.getNotification();
	}

	@Override
	protected void onPublishProgress(int progress, Context context) {
		if (id_percent != 0) {
			updateNotification.contentView.setTextViewText(id_percent, progress
					+ "%");
		}
		if (id_progressbar != 0) {
			updateNotification.contentView.setProgressBar(id_progressbar, 100,
					progress, false);
		}
		manager.notify(NOTIFY_ID_PUBLISH, updateNotification);
	}

	@Override
	protected void onDownloadDone(boolean success, Context context) {
		manager.cancel(NOTIFY_ID_START);
		if (success){
			manager.notify(NOTIFY_ID_SUCCESS, successNotification);
		}else if(!Environment.getExternalStorageDirectory().canWrite()){
			manager.notify(NOTIFY_ID_FAIL, failNotification);
		}else{
			manager.notify(NOTIFY_ID_FAIL_NETWORK, networkNotification);
		}
		if (callback != null)
			callback.onDownloadDone(success, context);
		context.getApplicationContext().unregisterReceiver(this);
		updateNotification = null;
		manager = null;
		callback = null;
	}

	@Override
	public void onReceive(Context context, Intent intent) {
		if (UpgradeType.Ground.name().equals(
				intent.getStringExtra(UpgradeService.EXTRA_UPGRADE_TYPE))) {
			super.onReceive(context, intent);
		}
	}
}
