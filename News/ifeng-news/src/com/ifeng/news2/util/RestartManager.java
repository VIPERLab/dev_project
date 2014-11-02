package com.ifeng.news2.util;

import com.ifeng.news2.fragment.NewsMasterFragmentActivity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.activity.SplashActivity;
import com.qad.util.ActivityTool;

public class RestartManager {

	/**
	 * @author sunquan 
	 * 对应用程序按下电源键或者home键后的超时的管理类
	 */
	public static final int RESTAET_TAG = 3;
	public static final ReType HOME = ReType.HOME;
	public static final ReType LOCK = ReType.LOCK;

	public static boolean checkRestart(Context context, long startTime, ReType type) {
		return type.checkRestart(context, startTime);
	}
		
	enum ReType{
		HOME {
			@Override
			boolean checkRestart(Context context, long startTime) {
				long endTime = System.currentTimeMillis();
				if (startTime != 0 && IfengNewsApp.shouldRestart) {
					if ((endTime - startTime) > Config.BACKGROUND_TIME) {
						startApp(context);
						startTime = 0;
						return true;
					}
				}
				startTime = 0;
				return false;
			}
		},
		LOCK {
			@Override
			boolean checkRestart(Context context, long startTime) {
				if (IfengNewsApp.lockTime != 0 && startTime == 0) {
					long keyEndTime = System.currentTimeMillis();
					if ((keyEndTime - IfengNewsApp.lockTime) > Config.BACKGROUND_TIME) {
						startApp(context);
						IfengNewsApp.lockTime = 0;
						return true;
					}
				}
				IfengNewsApp.lockTime = 0;
				return false;
			}
		};
		/**
		 * 
		 * @param context
		 * @param startTime
		 * @return true if the app should be restart, false otherwise
		 */
		abstract boolean checkRestart(Context context, long startTime);
		
		protected void startApp(Context context) {
			NewsMasterFragmentActivity.isAppRunning = false;
		    ActivityTool tool = new ActivityTool((Activity) context);
			tool.exitApp();
			Intent intent = new Intent(context, SplashActivity.class);
			intent.putExtra("RESTAET_TAG", RESTAET_TAG);
			context.startActivity(intent);
		}
	}
}
