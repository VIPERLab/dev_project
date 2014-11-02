package com.ifeng.plutus.android.view;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import android.os.Handler;
import android.os.Message;

import com.ifeng.plutus.android.PlutusAndroidManager;

public class ExposureHandler {
	
	private static final int MSG_UPDATE_EXPOSURE = 0x300;
	private static final int MSG_RECYCLE = 0x400;
	private static long timeStamp = -1L;
	private static ConcurrentHashMap<String, Integer> mMap = null;
	private static Handler sHandler = new Handler() {
		
		public void handleMessage(Message msg) {
			if (msg.what == MSG_RECYCLE) {
				removeMessages(MSG_UPDATE_EXPOSURE);
			} else
				sendEmptyMessageDelayed(MSG_UPDATE_EXPOSURE, 120 * 1000);
			
			if (mMap == null || mMap.size() == 0) return;
			String startTime = String.valueOf(timeStamp);
			String endTime = String.valueOf(System.currentTimeMillis());
			if (startTime.length() > 3)
				startTime = startTime.substring(0, startTime.length() - 3);
			if (endTime.length() > 3)
				endTime = endTime.substring(0, endTime.length() - 3);
			
			Map<String, String> map = new HashMap<String, String>();
			map.put("select", "exposure");
			map.put("suffix", PlutusAndroidManager.getUrlSuffix());
			map.put("startTime", startTime);
			map.put("endTime", endTime);
			timeStamp = System.currentTimeMillis();
			
			Iterator<String> it = mMap.keySet().iterator();
			while (it.hasNext()) {
				String key = it.next();
				map.put("adid" + key, mMap.get(key).toString());
			}
			mMap.clear();
			
			PlutusAndroidManager.qureyAsync(map, null);
		}
		
	};
	
	/**
	 * Init the handler and start record loop, this will also init the suffix params required by
	 * interface regulars
	 * @param context
	 */
	public static void init() {
		sHandler.sendEmptyMessageDelayed(MSG_UPDATE_EXPOSURE, 120 * 1000);
		timeStamp = System.currentTimeMillis();
	}
	
	/**
	 * Remove looper and record the unsent recorders
	 */
	public static void recycle() {
		sHandler.sendEmptyMessageDelayed(MSG_RECYCLE, 0);
	}

	/**
	 * Put a exposure record into the looper queue, will be sent sometime in the furture
	 * @param adId the id of exposed advertisement
	 */
	public static void putInQueue(String adId) {
		if (mMap == null)
			mMap = new ConcurrentHashMap<String, Integer>();
		if (mMap.get(adId) != null) {
			int count = mMap.get(adId);
			mMap.remove(adId);
			mMap.put(adId, count + 1);
		} else
			mMap.put(adId, 1);
		
		// @gm, the period (start time to end time) of exposure data should not across days, 
		// so check if the current time is at or after 23:58, if so, send exposure at once
		Calendar calendar = Calendar.getInstance();
		if (calendar.get(Calendar.HOUR_OF_DAY) == 23) {
			if (calendar.get(Calendar.MINUTE) >= 58) 
				sHandler.sendEmptyMessageDelayed(MSG_UPDATE_EXPOSURE, 0);
		}
		// fix end
	}
}
