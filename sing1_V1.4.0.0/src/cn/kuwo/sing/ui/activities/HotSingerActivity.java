/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import com.nostra13.universalimageloader.core.ImageLoader;

import android.os.Bundle;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.controller.HotSingerController;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2012-11-29, 下午12:24:31, 2012
 *
 * @Author wangming
 *
 */
public class HotSingerActivity extends BaseActivity {
	private final String TAG = "HotSingerActivity";
	private HotSingerController mController;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.hot_songs_list);
		mController = new HotSingerController(this, ImageLoader.getInstance());
	}
	
	@Override
	public void onBackPressed() {
		mController.clearDisplayedImages();
		super.onBackPressed();
	}
}
