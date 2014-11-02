package com.ifeng.news2.service;

import android.app.Service;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.IBinder;
import android.text.TextUtils;
import com.google.myjson.Gson;
import com.google.myjson.reflect.TypeToken;
import com.ifeng.news2.Config;
import com.ifeng.news2.bean.SplashCoverUnits;
import com.ifeng.news2.util.AlarmSplashServiceManager;
import com.ifeng.news2.util.HttpUtil;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.SplashManager;

public class SplashService extends Service{

	
	private SplashManager splashMgr = null;
	
	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		
		splashMgr = new SplashManager();
		new SplashAsyncTask().execute(new String[] {ParamsManager.addParams(Config.COVER_STORY_URL)});
		return START_NOT_STICKY;
	}
	
	@Override
	public IBinder onBind(Intent arg0) {
		return null;
	}
	
	@Override
	public void onDestroy() {
		super.onDestroy();
	}
	
	private class SplashAsyncTask extends AsyncTask<String, Long, SplashCoverUnits> {

		@Override
		protected SplashCoverUnits doInBackground(String... params) {
			String result = HttpUtil.load(params[0]);
			if (!TextUtils.isEmpty(result)) {
				SplashCoverUnits units = parseSplashUnit(result);
				if (null != units) {
					SplashCoverUnits localCoverUnits = splashMgr.getSplashUnits();
					splashMgr.saveUnits(units);
					splashMgr.downloadPictures(units, localCoverUnits);
				}
				return units;
			}
			return null;
		}

		private SplashCoverUnits parseSplashUnit(String result) {
			Gson gson = new Gson();
			SplashCoverUnits units = null;
			try {
				units = gson.fromJson(result, 
						new TypeToken<SplashCoverUnits>() {}.getType());
			} catch (Exception e) {
				e.printStackTrace();
				return null;
			}
			return units;
		}
		
		@Override
		protected void onPostExecute(SplashCoverUnits result) {
			super.onPostExecute(result);
// 为避免downloadPictures抛异常：android.os.NetworkOnMainThreadException，将图片下载放到AsyncTask的doInBackground中执行
//			if (null != result) { 
//				SplashCoverUnits localCoverUnits = splashMgr.getSplashUnits();
//				splashMgr.saveUnits(result);
//				splashMgr.downloadPictures(result, localCoverUnits);
//			}
			AlarmSplashServiceManager.setUpAlarm(SplashService.this);
			stopSelf();
		}
	} 
}
