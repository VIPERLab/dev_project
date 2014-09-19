/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import com.umeng.analytics.MobclickAgent;

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.widget.Toast;
import cn.kuwo.framework.download.DownloadManager;
import cn.kuwo.framework.download.DownloadManager.OnDownloadListener;
import cn.kuwo.framework.download.DownloadManager.OnManagerListener;
import cn.kuwo.framework.download.DownloadStat;
import cn.kuwo.framework.download.DownloadTask;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.db.MusicDao;
import cn.kuwo.sing.logic.DownloadLogic;
import cn.kuwo.sing.logic.MusicLogic;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2013-2-5, 下午5:37:32, 2013
 *
 * @Author wangming
 *
 */
public class DownloadController implements OnDownloadListener, OnManagerListener {
	private final String TAG = "DownloadController";
	private Activity mActivity;
	private DownloadLogic downloadLogic;
	private Handler progressUpdateHandler;
	private Handler refreshPBVStateHandler;
	
	public DownloadController(Activity activity, DownloadLogic logic, Handler updateHandler, Handler refreshPBVHandler) {
		mActivity = activity;
		downloadLogic = logic;
		progressUpdateHandler = updateHandler;
		refreshPBVStateHandler = refreshPBVHandler;
	}
	
	@Override
	public void onProcess(DownloadManager dm, DownloadTask task, DownloadStat ds) {
		String taskId = task.getId();
		String musicId = taskId.substring(0, taskId.indexOf('_'));
		KuwoLog.i(TAG, "onProcess,musicId="+musicId);
		int progress = downloadLogic.computeProgress(musicId);
		downloadLogic.publishProgress(progressUpdateHandler, musicId, progress);
	} 
	
	@Override
	public void onAdd(DownloadManager arg0, DownloadTask task) {
		KuwoLog.i(TAG, "onAdd--taskId-"+task.getId());
	}
	
	@Override
	public boolean onPrepareAsync(DownloadManager dm, DownloadTask task) {
		if(task != null) {
			//防盗链地址获取成功返回true
			String taskId = task.getId();
			String musicId = taskId.substring(0, taskId.indexOf('_'));
			String taskType = taskId.substring(taskId.indexOf('_')+1);
			KuwoLog.i(TAG, "onPrepareAsync--taskId-"+taskId);
			MusicLogic musicLogic = new MusicLogic();
			DownloadTask downloadTask = dm.findTaskById(musicId+"_"+taskType);
			if(downloadTask != null) {
				if(taskType.equals("original")) {
					String originalUrl = musicLogic.getMusicUrl(musicId);
					KuwoLog.i(TAG, "originalUrl="+originalUrl);
					//防盗链地址获取失败
					if(originalUrl == null) {
						MobclickAgent.onEvent(mActivity, "KS_GET_SONGURL", "0");
						//downloadLogic.cancelDownloadMusic(mActivity, musicId);
						Message msg = refreshPBVStateHandler.obtainMessage();
						msg.what = Constants.DOWNLOAD_FAILED;
						msg.obj = musicId;
						refreshPBVStateHandler.sendMessage(msg);
						return false;
					}else {
						MobclickAgent.onEvent(mActivity, "KS_GET_SONGURL", "1");
					}
					downloadTask.setSource(originalUrl);
				}else if(taskType.equals("accomp")) {
					String accompUrl = musicLogic.getAccompanimentUrl(musicId);
					KuwoLog.i(TAG, "accompUrl="+accompUrl);
					//防盗链地址获取失败
					if(accompUrl == null) {
						MobclickAgent.onEvent(mActivity, "KS_GET_SONGURL", "0");
						//downloadLogic.cancelDownloadMusic(mActivity, musicId);
						Message msg = refreshPBVStateHandler.obtainMessage();
						msg.what = Constants.DOWNLOAD_FAILED;
						msg.obj = musicId;
						refreshPBVStateHandler.sendMessage(msg);
						return false;
					}else {
						MobclickAgent.onEvent(mActivity, "KS_GET_SONGURL", "1");
					}
					downloadTask.setSource(accompUrl);
				}
			}
			return true;
		}
		return false;
	}

	@Override
	public void onStartDownload(DownloadManager dm, DownloadTask task) {
		if(task != null) {
			String taskId = task.getId();
			String musicId = taskId.substring(0, taskId.indexOf('_'));
			KuwoLog.i(TAG, "onStartDownload---"+musicId);
			//从【prepare队列，waitting队列，running队列，finished队列查找】
			DownloadTask originalTask = dm.findTaskById(musicId+"_original");
			DownloadTask accompTask = dm.findTaskById(musicId+"_accomp");
			MusicDao musicDao = new MusicDao(mActivity);
			Music music = musicDao.getMusic(musicId);
			if(music != null) {
				if(music.getOriginalTotal() == 0 && originalTask != null) {
					music.setOriginalTotal(originalTask.getTotalBytes());
					musicDao.update(music);
				}
				if(music.getAccompTotal() == 0 && accompTask != null) {
					music.setAccompTotal(accompTask.getTotalBytes());
					musicDao.update(music);
				}
				music.setTotal(music.getOriginalTotal()+music.getAccompTotal());
				musicDao.update(music);
				if(music.getOriginalTotal() != 0 || music.getAccompTotal() != 0) { //原唱或者伴唱只要一个不为空，则说明之前下载过，现在处于暂停状态
					downloadLogic.addPauseMusicMap(musicId, music.getTotal()); //使用map记住上次暂停时刻，music的totalBytes，避免频繁读取数据库
				}
			}
		}
	}
	
	@Override
	public void onRunning(DownloadManager dm, DownloadTask task) {
	}
	
	@Override
	public void onPause(DownloadManager dm, DownloadTask task) {
	}
	
	@Override
	public void onFailed(DownloadManager dm, DownloadTask task) {
		MobclickAgent.onEvent(mActivity, "KS_DOWN_MUSIC", "0");
		KuwoLog.i(TAG, "onFailed----");
		if(task != null) {
			String taskId = task.getId();
			String musicId = taskId.substring(0, taskId.indexOf('_'));
			Message msg = refreshPBVStateHandler.obtainMessage();
			msg.what = Constants.DOWNLOAD_FAILED;
			msg.obj = musicId;
			refreshPBVStateHandler.sendMessage(msg);
		}
		else{
			KuwoLog.i(TAG, "onFailed----, task is null");
		}
	}
	
	@Override
	public void onCancel(DownloadManager arg0, DownloadTask task) {
		KuwoLog.i(TAG, "onCancel---");
		if(task != null) {
			String taskId = task.getId();
			String musicId = taskId.substring(0, taskId.indexOf('_'));
			Message msg = refreshPBVStateHandler.obtainMessage();
			msg.what = Constants.DOWNLOAD_CANCEL;
			msg.obj = musicId;
			refreshPBVStateHandler.sendMessage(msg);
		}
	}
	
	@Override
	public void onCompleted(DownloadManager dm, DownloadTask task) {
		MobclickAgent.onEvent(mActivity, "KS_DOWN_MUSIC", "1");
		KuwoLog.i(TAG, "completed!");
		Intent orderChangeIntent = new Intent();
		orderChangeIntent.setAction("cn.kuwo.sing.order.change");
		mActivity.sendBroadcast(orderChangeIntent);
		if(task != null) {
			String taskId = task.getId();
			String musicId = taskId.substring(0, taskId.indexOf('_'));
			int downloadedStatus = downloadLogic.getMusicDownloadStatus(mActivity, musicId);
			if(downloadedStatus == Constants.DOWNLOAD_STATUS_COMPLEMENT) {
				downloadLogic.publishProgress(progressUpdateHandler, musicId, 100);
			}
		}
	}
	
	@Override
	public void onAllTasksCompleted(DownloadManager dm) {
	}
}
