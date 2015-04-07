package com.wangmingjob.androidkit;

import android.app.Application;

import com.wangmingjob.androidkit.http.RequestManager;

/**
 * Created by wangming on 11/25/14.
 */
public class BaseApplication extends Application {

	@Override
	public void onCreate() {
		super.onCreate();
		initRequestManager();
	}

	private void initRequestManager() {

		RequestManager.init(this);
	}
}
