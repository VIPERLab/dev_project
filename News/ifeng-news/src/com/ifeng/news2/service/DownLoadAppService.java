package com.ifeng.news2.service;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.net.Uri;
import android.os.Binder;
import android.os.Environment;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.util.Log;
import android.widget.RemoteViews;
import android.widget.Toast;

import com.ifeng.news2.R;
import com.ifeng.news2.activity.DownloadManageActivity;

public class DownLoadAppService extends Service {
	public static final String DOWNLOAD_APP_ACTION = "com.ifeng.openbook.downloadappservice";
	private ArrayList<UpdateThread> taskList = new ArrayList<DownLoadAppService.UpdateThread>();
	public ArrayList<UpdateThread> getTaskList() {
		return taskList;
	}

	public void setTaskList(ArrayList<UpdateThread> taskList) {
		this.taskList = taskList;
	}

	@Override
	public IBinder onBind(Intent intent) {
		return mBinder;
	}

	public class localBinder extends Binder {
		public DownLoadAppService getService() {
			return DownLoadAppService.this;
		}
	}

	private int currentBindServiceIndex = 0;

	private DownloadManageListener listener;

	private File updateDir = null;
	private File updateFile = null;

	// 标题
	private String appName = "";
	private String downloadUrl;

	private final IBinder mBinder = new localBinder();
	private final static int DOWNLOAD_COMPLETE = 0;
	private final static int DOWNLOAD_FAIL = 1;

	// 通知栏
	private NotificationManager updateNotificationManager = null;
	// 通知栏跳转Intent

	private int currentIndex = 0;

	public int getCurrentIndex() {
		return currentIndex;
	}

	public void setCurrentIndex(int currentIndex) {
		this.currentIndex = currentIndex;
	}

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		if (!Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
			Toast.makeText(this, "无法检测到外置存储卡，请安装后重试", Toast.LENGTH_LONG).show();
			if (taskList.size() == 0)
				stopSelf();
		} else
			start(intent, startId);
		return super.onStartCommand(intent, flags, startId);
	}
	
	// 在onStartCommand()方法中准备相关的下载工作：
	public void start(Intent intent, int startId) {
		if (intent == null)
			return;
		
		// 获取传值
		appName = intent.getStringExtra("apkName");
		downloadUrl = intent.getStringExtra("downloadUrl");
		//downloadUrl = Constant.addParam(downloadUrl);
		//
		updateNotificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
		// 设置下载过程中，点击通知栏，回到主界面

		for (int i = 0; i < taskList.size(); i++) {
			if (taskList.get(i).downloadUrl.equals(downloadUrl)) {
				Toast.makeText(this, "任务已在下载队列中", Toast.LENGTH_SHORT).show();
				return;
			}
		}
		UpdateThread newThread = new UpdateThread(appName, currentIndex,
				downloadUrl);
		taskList.add(newThread);
		currentIndex++;
		newThread.start();
	}
	public class UpdateThread extends Thread {
		private Notification updateNotification = null;
		public int currentTaskIndex = 0;
		public String appName = "";
		public String downloadUrl = "";
		public int totleSize = 0;
		// 文件存储

		public int progressPersent = 0;
		public boolean exit = false;
		private Intent updateIntent = null;
		private PendingIntent updatePendingIntent = null;

		public UpdateThread(String appName, int currentTaskIndex,
				String downloadUrl) {
			this.appName = appName;
			this.currentTaskIndex = currentTaskIndex;
			this.downloadUrl = downloadUrl;
			updateNotification = new Notification(R.drawable.download_icon,
					appName + "开始下载", System.currentTimeMillis());
			RemoteViews v = new RemoteViews(getPackageName(),
					R.layout.notify_download);
			v.setProgressBar(R.id.offline_down_pb, 100, 0, false);
			v.setImageViewResource(R.id.offline_down_pic,
					R.drawable.download_icon);
			v.setTextViewText(R.id.offline_down_percent, "0%");
			v.setTextViewText(R.id.offline_down_title, "正在下载" + appName);
			// 设置每一个notification的pendingIntent 和 Extra
			updateIntent = new Intent(DownLoadAppService.this,
					DownloadManageActivity.class);
			updateIntent.putExtra("index", currentTaskIndex);
			updateIntent.setAction(String.valueOf(System.currentTimeMillis()));
			updateIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			updatePendingIntent = PendingIntent.getActivity(
					DownLoadAppService.this, 0, updateIntent,
					PendingIntent.FLAG_UPDATE_CURRENT);
			v.setOnClickPendingIntent(R.id.offline_down, updatePendingIntent);
			updateNotification.contentView = v;
			updateNotification.contentIntent = updatePendingIntent;
			updateNotificationManager.notify(currentTaskIndex,
					updateNotification);
		}

		@Override
		public void run() {

			// 创建文件
			if (android.os.Environment.MEDIA_MOUNTED.equals(android.os.Environment.getExternalStorageState())){
				updateDir = new File(Environment.getExternalStorageDirectory().getAbsolutePath());
				updateFile = new File(updateDir.getPath(), appName + ".apk");
			}

			Object[] re = { currentTaskIndex, updateNotification, appName,
					updateFile };
			Message message = updateHandler
					.obtainMessage(DOWNLOAD_COMPLETE, re);
			try {
				// 增加权限<uses-permission
				// android:name="android.permission.WRITE_EXTERNAL_STORAGE">;
				if (!updateDir.exists()) {
					updateDir.mkdirs();
				}
				if (!updateFile.exists()) {
					updateFile.createNewFile();
				}
				// 下载函数，以QQ为例子
				// 增加权限<uses-permission
				// android:name="android.permission.INTERNET">;
				long downloadSize = downloadUpdateFile(downloadUrl, updateFile,
						currentTaskIndex, updateNotification);
				if (downloadSize > 0 && exit == false) {
					// 下载成功
					updateHandler.sendMessage(message);

					Log.i("-----------------------", "download_success");
				} else {
					message.what = DOWNLOAD_FAIL;
					// 下载失败
					updateHandler.sendMessage(message);
				}
			} catch (Exception ex) {
				ex.printStackTrace();
				message.what = DOWNLOAD_FAIL;
				// 下载失败
				updateHandler.sendMessage(message);
			}

			super.run();
		}

		// 下载函数的实现有很多，我这里把代码贴出来，而且我们要在下载的时候通知用户下载进度：
		public long downloadUpdateFile(String downloadUrl, File saveFile,
				int temIndex, Notification updateNotification) throws Exception {
			// 这样的下载代码很多，我就不做过多的说明
			int downloadCount = 0;
			int currentSize = 0;
			long totalSize = 0;
			int updateTotalSize = 0;

			HttpURLConnection httpConnection = null;
			InputStream is = null;
			FileOutputStream fos = null;

			try {
				URL url = new URL(downloadUrl);
				httpConnection = (HttpURLConnection) url.openConnection();
				httpConnection.setRequestProperty("User-Agent",
						"PacificHttpClient");
				if (currentSize > 0) {
					httpConnection.setRequestProperty("RANGE", "bytes="
							+ currentSize + "-");
				}
				httpConnection.setConnectTimeout(10000);
				httpConnection.setReadTimeout(20000);
				updateTotalSize = httpConnection.getContentLength();
				totleSize = updateTotalSize;
				if (httpConnection.getResponseCode() == 404) {
					throw new Exception("fail!");
				}
				is = httpConnection.getInputStream();
				fos = new FileOutputStream(saveFile, false);
				byte buffer[] = new byte[4096];
				int readsize = 0;
				while ((readsize = is.read(buffer)) > 0 && !exit) {
					fos.write(buffer, 0, readsize);
					totalSize += readsize;

					// 为了防止频繁的通知导致应用吃紧，百分比增加10才通知一次
					if ((downloadCount == 0)
							|| (int) (totalSize * 100 / updateTotalSize) - 10 > downloadCount) {
						downloadCount += 10;
						updateNotification.contentView.setProgressBar(
								R.id.offline_down_pb, 100, (int) totalSize
										* 100 / updateTotalSize, false);
						updateNotification.contentView.setTextViewText(
								R.id.offline_down_percent, (int) totalSize
										* 100 / updateTotalSize + "%");
						progressPersent = (int) totalSize * 100
								/ updateTotalSize;
						if (listener != null
								&& currentTaskIndex == currentBindServiceIndex)
							listener.updateProgress(progressPersent);
						updateNotificationManager.notify(temIndex,
								updateNotification);
					}
				}
			} finally {
				if (httpConnection != null) {
					httpConnection.disconnect();
				}
				if (is != null) {
					is.close();
				}
				if (fos != null) {
					fos.close();
				}
			}
			return totalSize;
		}

	}

	public boolean checkStopService() {
		int count = 0;
		for (UpdateThread task : taskList) {
			if (task.exit == true)
				count++;
		}
		if (count == taskList.size())
			return true;
		else
			return false;
	}

	private Handler updateHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			Object[] objects = (Object[]) msg.obj;
			int index = (Integer) objects[0];
			Notification updateNotification = (Notification) objects[1];
			String appName = (String) objects[2];
			File updateFile = (File) objects[3];
			Intent installIntent = new Intent(Intent.ACTION_VIEW);
			Uri uri = Uri.fromFile(updateFile);
			installIntent.setDataAndType(uri,
					"application/vnd.android.package-archive");
			PendingIntent updatePendingIntent = PendingIntent.getActivity(
					DownLoadAppService.this, 0, installIntent, 0);
			switch (msg.what) {
			case DOWNLOAD_COMPLETE:
				// 点击安装PendingIntent
				Toast.makeText(DownLoadAppService.this,"已成功下载至/sdcard目录下", Toast.LENGTH_SHORT).show();
				updateNotification.flags = Notification.FLAG_AUTO_CANCEL;
				updateNotification.defaults = Notification.DEFAULT_SOUND;// 铃声提醒
				updateNotification.setLatestEventInfo(DownLoadAppService.this,
						appName, "下载完成,点击安装。", updatePendingIntent);
				updateNotificationManager.notify(index, updateNotification);
				// 停止服务
				if (checkStopService())
					stopSelf();
				if (listener != null)
					listener.onComplete(updateFile);
				break;
			case DOWNLOAD_FAIL:
				// 下载失败
				updateNotification.flags |= Notification.FLAG_AUTO_CANCEL;
				updateNotification.setLatestEventInfo(DownLoadAppService.this,
						appName, "下载失败", updatePendingIntent);
				updateNotificationManager.notify(index, updateNotification);
				if (checkStopService())
					stopSelf();
				if (listener != null)
					listener.onFail();
				Toast.makeText(getApplicationContext(), appName + "下载失败",
						Toast.LENGTH_SHORT).show();
				break;
			default:
				break;
			}
		}
	};

	public interface DownloadManageListener {

		public void updateProgress(int progressPercent);

		public void onComplete(File updateFile);

		public void onFail();
	}

	public void setDownloadManageListener(int currentTask,
			DownloadManageListener listener) {
		this.listener = listener;
		this.currentBindServiceIndex = currentTask;
	}

	public void clearDownloadManageListener() {
		this.listener = null;
	}

	@Override
	public void onDestroy() {
		Log.i("++++++++++++++++++++++", "destory");
		super.onDestroy();
	}
}
