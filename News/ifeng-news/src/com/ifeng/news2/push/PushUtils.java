package com.ifeng.news2.push;

import com.ifeng.news2.Config;

import android.content.Context;

public class PushUtils {


	
	/**
	 * Check whether PushService is enabled
	 * 
	 * @param context
	 *            The application context
	 * @return If PushService is enabled
	 */
	public static final boolean isPushActivated(Context context) {
		if (!context.getSharedPreferences(PushConfig.PREFERENCE_NAME,
				Context.MODE_PRIVATE).contains(PushConfig.ATTRIBUTE_ACTIVATED)) {
			context.getSharedPreferences(PushConfig.PREFERENCE_NAME, Context.MODE_PRIVATE).edit()
				.putBoolean(PushConfig.ATTRIBUTE_ACTIVATED, Config.enablePush).commit();
			return Config.enablePush;
		}

		boolean active = context.getSharedPreferences(PushConfig.PREFERENCE_NAME, Context.MODE_PRIVATE)
				.getBoolean(PushConfig.ATTRIBUTE_ACTIVATED, true);
		return active;
	}
	
	/**
	 * set Push Service status, active or inactive
	 * 
	 * @param context
	 *            The application context
	 * @param active
	 *            boolean value indicates whether to turn on/off this service
	 */
	public static void setPushActivated(Context context, boolean active) {
		context.getSharedPreferences(PushConfig.PREFERENCE_NAME, Context.MODE_PRIVATE).edit()
			.putBoolean(PushConfig.ATTRIBUTE_ACTIVATED, active).commit();

	}
}
