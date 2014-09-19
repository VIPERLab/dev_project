/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.logic;

import java.io.File;
import java.util.HashMap;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import cn.kuwo.framework.download.DownloadManager;
import cn.kuwo.framework.download.DownloadManager.OnConnectionListener;
import cn.kuwo.framework.download.DownloadManager.OnDownloadListener;
import cn.kuwo.framework.download.DownloadManager.OnManagerListener;
import cn.kuwo.framework.download.DownloadTask;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.db.MusicDao;

/**
 * @Package cn.kuwo.sing.logic
 *
 * @Date 2012-12-11, 下午3:31:26, 2012
 *
 * @Author wangming
 *
 */
public class DownloadLogic {
	private static final String TAG = "DownloadLogic";
	private static DownloadManager dm;
	private Context mContext;
	private FileLogic lFile = new FileLogic();
	private static HashMap pauseMusicMap = new HashMap<String, Long>();
	
	public DownloadLogic(boolean single, Context context) {
		mContext = context;
		if (single && dm != null) 
			return;
		
		dm = new DownloadManager();
	}
	
	public DownloadLogic(Context context) {
		this(true, context);
	}
	
	
	public void setOnDownloadListener (OnDownloadListener l) {
		dm.setOnDownloadListener(l);
	}
	
	public void setOnConnectionListener(OnConnectionListener l) {
		dm.setOnConnectionListener(l);
	}
	
	public void setOnManagerListener(OnManagerListener l) {
		dm.setOnManagerListener(l);
	}
	
	public void addPauseMusicMap(String musicId, Long totalBytes) {
		pauseMusicMap.put(musicId, totalBytes);
	}
	
	public long getPauseMusicTotalBytes(String musicId) {
		return (Long) pauseMusicMap.get(musicId);
	}
	
	/**
	 * 在下载进行中调用
	 * @param totalBytes
	 * @param music
	 * @return
	 */
	public int computeDownloadedBytes(String musicId) {
		int result = 0;
		long downloadedBytes = 0;
		File originalFile = new File(lFile.getMusicFile(musicId));
		File accompFile = new File(lFile.getAccompanimentFile(musicId));
		File tmpOriginalFile = new File(lFile.getMusicTempFile(musicId));
		File tmpAccompFile = new File(lFile.getAccompanimentTempFile(musicId));
		if(originalFile.exists()) {
			//如果原唱下载完毕,那么伴唱肯定没有下载完
			long originalLength = originalFile.length();
			if(tmpAccompFile.exists()) {
				long tmpAccompFileLength = tmpAccompFile.length();
				downloadedBytes = originalLength + tmpAccompFileLength;
			}else {
				downloadedBytes = originalLength;
			}
		}else if(accompFile.exists()) {
			//如果伴唱下载完毕
			long accomFileLength = accompFile.length();
			if(tmpOriginalFile.exists()) {
				long tmpOriginalLength = tmpOriginalFile.length();
				downloadedBytes = accomFileLength + tmpOriginalLength;
			}else {
				downloadedBytes = accomFileLength;
			}
		}else {
			//原唱和伴唱都没下载完
			if(tmpOriginalFile.exists() && tmpAccompFile.exists()) {
				long tmpOriginalLength = tmpOriginalFile.length();
				long tmpAccompFileLength = tmpAccompFile.length();
				downloadedBytes = tmpAccompFileLength + tmpOriginalLength;
			}else if(tmpOriginalFile.exists() && !tmpAccompFile.exists()) {
				long tmpOriginalLength = tmpOriginalFile.length();
				downloadedBytes = tmpOriginalLength;
			}else if(tmpAccompFile.exists() && !tmpOriginalFile.exists()) {
				long tmpAccompFileLength = tmpAccompFile.length();
				downloadedBytes = tmpAccompFileLength;
			}else {
				downloadedBytes = 0;
			}
		}
		double pauseProgress = 0.0;
		MusicDao musicDao = new MusicDao(mContext);
		Music pauseMusic = musicDao.getMusic(musicId);
		if(pauseMusic == null){
			KuwoLog.e(TAG, "music can not find in db, return 0");
			return 0;
		}
		if(pauseMusic.getOriginalTotal() != 0 && pauseMusic.getAccompTotal() != 0) { 
			pauseProgress = (double)downloadedBytes/(pauseMusic.getOriginalTotal()+pauseMusic.getAccompTotal());
		}else if(pauseMusic.getOriginalTotal() != 0 && pauseMusic.getAccompTotal() == 0) {
			pauseProgress = (double)downloadedBytes/(2*pauseMusic.getOriginalTotal());
		}else if(pauseMusic.getAccompTotal() != 0 && pauseMusic.getOriginalTotal() == 0) {
			pauseProgress = (double)downloadedBytes/(2*pauseMusic.getAccompTotal());
		}else {
			pauseProgress = 0;
		}
		int tmpResult = (int)(pauseProgress*100);
		if(tmpResult >= 0 && tmpResult <= 100) {
			result = tmpResult;
		}
		return result;
	}
	
	private double getDownloadedPauseProgress(String musicId) {
		long downloadedBytes = 0;
		File originalFile = new File(lFile.getMusicFile(musicId));
		File accompFile = new File(lFile.getAccompanimentFile(musicId));
		File tmpOriginalFile = new File(lFile.getMusicTempFile(musicId));
		File tmpAccompFile = new File(lFile.getAccompanimentTempFile(musicId));
		if(originalFile.exists()) {
			//如果原唱下载完毕,那么伴唱肯定没有下载完
			long originalLength = originalFile.length();
			if(tmpAccompFile.exists()) {
				long tmpAccompFileLength = tmpAccompFile.length();
				downloadedBytes = originalLength + tmpAccompFileLength;
			}else {
				downloadedBytes = originalLength;
			}
		}else if(accompFile.exists()) {
			//如果伴唱下载完毕
			long accomFileLength = accompFile.length();
			if(tmpOriginalFile.exists()) {
				long tmpOriginalLength = tmpOriginalFile.length();
				downloadedBytes = accomFileLength + tmpOriginalLength;
			}else {
				downloadedBytes = accomFileLength;
			}
		}else {
			//原唱和伴唱都没下载完
			if(tmpOriginalFile.exists() && tmpAccompFile.exists()) {
				long tmpOriginalLength = tmpOriginalFile.length();
				long tmpAccompFileLength = tmpAccompFile.length();
				downloadedBytes = tmpAccompFileLength + tmpOriginalLength;
			}else if(tmpOriginalFile.exists() && !tmpAccompFile.exists()) {
				long tmpOriginalLength = tmpOriginalFile.length();
				downloadedBytes = tmpOriginalLength;
			}else if(tmpAccompFile.exists() && !tmpOriginalFile.exists()) {
				long tmpAccompFileLength = tmpAccompFile.length();
				downloadedBytes = tmpAccompFileLength;
			}else {
				downloadedBytes = 0;
			}
		}
		double pauseProgress = 0.0;
		MusicDao musicDao = new MusicDao(mContext);
		Music pauseMusic = musicDao.getMusic(musicId);
		if(pauseMusic != null && pauseMusic.getOriginalTotal() != 0 && pauseMusic.getAccompTotal() != 0) { 
			pauseProgress = (double)downloadedBytes/(pauseMusic.getOriginalTotal()+pauseMusic.getAccompTotal());
		}else if(pauseMusic != null && pauseMusic.getOriginalTotal() != 0 && pauseMusic.getAccompTotal() == 0) {
			pauseProgress = (double)downloadedBytes/(2*pauseMusic.getOriginalTotal());
		}else if(pauseMusic != null && pauseMusic.getAccompTotal() != 0 && pauseMusic.getOriginalTotal() == 0) {
			pauseProgress = (double)downloadedBytes/(2*pauseMusic.getAccompTotal());
		}else {
			pauseProgress = 0;
		}
		return pauseProgress;
	}
	
	private boolean isDownloading(String musicId) {
		boolean isOriginalTaskExit = dm.findTaskById(musicId+"_original",dm.getPrepareTasks()) != null; //准备队列，等待队列，运行队列，完成队列(不包含失败队列)
		isOriginalTaskExit = isOriginalTaskExit || dm.findTaskById(musicId+"_original",dm.getWaitingTasks()) != null; //准备队列，等待队列，运行队列，完成队列(不包含失败队列)
		isOriginalTaskExit = isOriginalTaskExit || dm.findTaskById(musicId+"_original",dm.getRunningTasks()) != null;
		boolean  isAccompTaskExit = dm.findTaskById(musicId+"_accomp", dm.getPrepareTasks()) != null;
		isAccompTaskExit = isAccompTaskExit || dm.findTaskById(musicId+"_accomp", dm.getWaitingTasks()) != null;
		isAccompTaskExit = isAccompTaskExit || dm.findTaskById(musicId+"_accomp", dm.getRunningTasks()) != null;
		if(isOriginalTaskExit == false && isAccompTaskExit == false) {
			return true;
		}
		return false;
	}
	
	
	/**
	 * "
	 * @param musicId
	 * @return 0-100
	 */
	public int computeProgress(String musicId) {
		int result = -1; 
		if(isDownloading(musicId)) {
			return result;
		}
		DownloadTask originalTask = dm.findTaskById(musicId+"_original"); //准备队列，等待队列，运行队列，完成队列(不包含失败队列)
		DownloadTask accompTask = dm.findTaskById(musicId+"_accomp");
		long originalTotalBytes = 0;
		long accompTotalBytes = 0;
		long originalDownloadedBytes = 0;
		long accompDownloadedBytes = 0; 
		MusicDao musicDao = new MusicDao(mContext);
		Music currentMusic = musicDao.getMusic(musicId);
		if(originalTask != null) {
			originalTotalBytes = originalTask.getTotalBytes();
			originalDownloadedBytes = originalTask.getDownloadedBytes();
		}else {
			FileLogic fileLogic = new FileLogic();
			File originalFile = new File(fileLogic.getMusicFile(musicId));
			if(originalFile.exists()) {
				originalTotalBytes = currentMusic.getOriginalTotal();
				originalDownloadedBytes = currentMusic.getOriginalTotal();
			}
		}
		if(accompTask != null) {
			accompTotalBytes = accompTask.getTotalBytes();
			accompDownloadedBytes = accompTask.getDownloadedBytes();
		}else {
			FileLogic fileLogic = new FileLogic();
			File accompFile = new File(fileLogic.getAccompanimentFile(musicId));
			if(accompFile.exists()) {
				accompTotalBytes = currentMusic.getAccompTotal();
				accompDownloadedBytes = currentMusic.getAccompTotal();
			}
		}
		double progress = 0;
		if(originalTotalBytes != 0 && accompTotalBytes == 0) { 
			if(pauseMusicMap.containsKey(musicId)) {
				if(currentMusic != null && (currentMusic.getOriginalTotal() == 0 || currentMusic.getAccompTotal() == 0)) {
					progress = (double)(originalDownloadedBytes + accompDownloadedBytes)/(2*getPauseMusicTotalBytes(musicId));
				}else {
					progress = (double)(originalDownloadedBytes + accompDownloadedBytes)/getPauseMusicTotalBytes(musicId);
				}
			}else {
				progress = (double)originalDownloadedBytes/(2*originalTotalBytes);
			}
		}else if(originalTotalBytes == 0 && accompTotalBytes != 0) { 
			if(pauseMusicMap.containsKey(musicId)) {
				if(currentMusic != null && (currentMusic.getOriginalTotal() == 0 || currentMusic.getAccompTotal() == 0)) {
					progress = (double)(originalDownloadedBytes + accompDownloadedBytes)/(2*getPauseMusicTotalBytes(musicId));
				}else {
					progress = (double)(originalDownloadedBytes + accompDownloadedBytes)/getPauseMusicTotalBytes(musicId);
				}
			}else {
				progress = (double)accompDownloadedBytes/(2*accompTotalBytes);
			}
		}else if(originalTotalBytes == 0 && accompTotalBytes == 0) {
			if(pauseMusicMap.containsKey(musicId)) {
				if(currentMusic != null && (currentMusic.getOriginalTotal() == 0 || currentMusic.getAccompTotal() == 0)) {
					progress = (double)(originalDownloadedBytes + accompDownloadedBytes)/(2*getPauseMusicTotalBytes(musicId));
				}else {
					progress = (double)(originalDownloadedBytes + accompDownloadedBytes)/getPauseMusicTotalBytes(musicId);
				}
			}else {
				progress = 	getDownloadedPauseProgress(musicId);
			}
		}else {
			progress = (double)originalDownloadedBytes/(2*originalTotalBytes) + (double)accompDownloadedBytes/(2*accompTotalBytes);
		}
		KuwoLog.i(TAG, "name="+currentMusic.getName()+",progress="+progress);
		int tmpResult = (int)(progress*100);
		if(tmpResult >= 0 && tmpResult <= 100) {
			result = tmpResult;
		}
		return result;
	}
	 
	public void publishProgress(Handler handler, String musicId, int progress) {
		Message msg = Message.obtain();
		msg.what = Constants.MESSAGE_DOWNLOAD_PROGRESS;
		msg.getData().putString("musicId", musicId);
		msg.getData().putInt("progress", progress);
		handler.sendMessage(msg);
	}
	
	/**
	 * 获取音乐下载状态
	 * @param musicId
	 * @return 0为不确定状态
	 */
	public int getMusicDownloadStatus(Context context, String musicId) {
		FileLogic fileLogic = new FileLogic();
		File originalFile = new File(fileLogic.getMusicFile(musicId));
		File accompFile = new File(fileLogic.getAccompanimentFile(musicId));
		
		MusicDao musicDao = new MusicDao(context);
		Music music = musicDao.getMusic(musicId);
		if(music == null) {
			//数据库找不到,未下载
			return Constants.DOWNLOAD_STATUS_UNDWONLOAD;
		}else {
			//数据库能找到，下载中或者下载完
			if(originalFile.exists() && accompFile.exists()) {
				return Constants.DOWNLOAD_STATUS_COMPLEMENT;
			}else {
				return Constants.DOWNLOAD_STATUS_ISDOWNLOADING;
			}
		}
	}
	
	/**
	 * add Original and accompaniment task
	 * 
	 * @param context
	 * @param music
	 */
	public void addOriginalAndAccompTask(Context context, Music music) {
		dm.setMaxTask(1); //修改DownloadManager的最大任务数
		FileLogic fileLogic = new FileLogic();
		//original task
		DownloadTask originalTask = new DownloadTask();
		originalTask.setId(music.getId()+"_original");
		originalTask.setPath(fileLogic.getMusicFile(music.getId())); //set the original storage path by music id
		
		DownloadTask accompTask = new DownloadTask();
		accompTask.setId(music.getId()+"_accomp");
		accompTask.setPath(fileLogic.getAccompanimentFile(music.getId())); //set the accompaniment storage path by music id
		
		File originalFile = new File(fileLogic.getMusicFile(music.getId()));
		File originalTmpFile = new File(fileLogic.getMusicTempFile(music.getId()));
		File accompFile = new File(fileLogic.getAccompanimentFile(music.getId()));
		File accompTmpFile = new File(fileLogic.getAccompanimentTempFile(music.getId()));
		boolean originalFileExist = originalFile.exists();
		boolean originalTmpFileExist = originalTmpFile.exists();
		boolean accompFileExist = accompFile.exists();
		boolean accompTmpFileExist = accompTmpFile.exists();
		
		if (!originalFileExist) { //如果原唱不存在
			originalTask.setDownloadedBytes(originalTmpFileExist ? (int)originalTmpFile.length() : 0);
			dm.add(originalTask);
			KuwoLog.i(TAG, "添加原唱task，musicId="+music.getId());
		}
		if(!accompFileExist) { //如果伴唱不存在
			accompTask.setDownloadedBytes(accompTmpFileExist ? (int)accompTmpFile.length() : 0);
			dm.add(accompTask);
			KuwoLog.i(TAG, "添加伴唱task，musicId="+music.getId());
		}
		if(originalTmpFileExist || accompTmpFileExist) {
			return;
		}else {
			MusicDao dao = new MusicDao(context);
			dao.insertMusic(music);
		}
	}
	
	/**
	 * 下载原唱和伴唱[wangming]
	 * 
	 * @param musicId
	 * @param shakelightUrl
	 * @param accompanimentUrl
	 * @return
	 */
	public void downloadShakelightAndAccompaniment(Context context, Music music, String shakelightUrl, String accompanimentUrl, boolean isCancel) {
		FileLogic lFile = new FileLogic();
		dm.setMaxTask(2); //应为偶数2,4,6...
		//原唱任务
		DownloadTask shakelightTask = new DownloadTask();
		shakelightTask.setId(music.getId()+"_original");
		shakelightTask.setSource(shakelightUrl);
		shakelightTask.setPath(lFile.getMusicFile(music.getId()));
		
		//伴唱任务
		DownloadTask accompanimentTask = new DownloadTask();
		accompanimentTask.setId(music.getId()+"_accomp");
		accompanimentTask.setSource(accompanimentUrl);
		accompanimentTask.setPath(lFile.getAccompanimentFile(music.getId()));
		
		File shakelightFile = new File(lFile.getMusicFile(music.getId()));
		File accompFile = new File(lFile.getAccompanimentFile(music.getId()));
		File tmpShakelightFile = new File(lFile.getMusicTempFile(music.getId()));
		File tmpAccompFile = new File(lFile.getAccompanimentTempFile(music.getId()));
		boolean shakelightExist = shakelightFile.exists();
		boolean accomExist = accompFile.exists();
		boolean tmpShakelightExist = tmpShakelightFile.exists();
		boolean tmpAccomExist = tmpAccompFile.exists();
		if(isCancel) { //如果要取消，直接返回，不添加任务，不插入数据库
			KuwoLog.i(TAG, "接收到取消指令，就此返回，不加入下载队列");
			return;
		}
		if (!shakelightExist) {
			shakelightTask.setDownloadedBytes(tmpShakelightExist ? (int)tmpShakelightFile.length() : 0);
			dm.add(shakelightTask);
		}
		if(!accomExist) {
			accompanimentTask.setDownloadedBytes(tmpAccomExist ? (int)tmpAccompFile.length() : 0);
			dm.add(accompanimentTask);
		}
		if(tmpShakelightExist || tmpAccomExist) {
			return;
		}else {
			MusicDao dao = new MusicDao(context);
			KuwoLog.i(TAG, "downloadShakelightAndAccompaniment====musicId="+music.getId());
			dao.insertMusic(music);
		}
	}
	
	public void cancelDownloadMusic(Context context, String musicId) {
		DownloadTask accompanimentTask = dm.findTaskById(musicId+"_original");
		DownloadTask shakelightTask = dm.findTaskById(musicId+"_accomp");
		KuwoLog.i(TAG, "取消原唱任务："+shakelightTask);
		KuwoLog.i(TAG, "取消伴唱任务："+accompanimentTask);
		FileLogic fileLogic = new FileLogic();
		File accompFile = new File(fileLogic.getAccompanimentFile(musicId));
		File tmpAccompFile = new File(fileLogic.getAccompanimentTempFile(musicId));
		File originalFile = new File(fileLogic.getMusicFile(musicId));
		File tmpOriginalFile = new File(fileLogic.getMusicTempFile(musicId));
		if(accompFile.exists()) {
			accompFile.delete();
		}
		if(tmpAccompFile.exists()) {
			tmpAccompFile.delete();
		}
		if(originalFile.exists()) {
			originalFile.delete();
		}
		if(tmpOriginalFile.exists()) {
			tmpOriginalFile.delete();
		}
		MusicDao dao = new MusicDao(context);
		dao.delete(musicId);
		if(accompanimentTask == null && shakelightTask == null) {
			KuwoLog.i(TAG, "原唱伴唱还没有add，不必取消");
			return;
		}
		dm.cancel(accompanimentTask);
		dm.cancel(shakelightTask);
	}
}
