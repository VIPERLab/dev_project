/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import android.os.Bundle;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.controller.SearchController;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2012-12-12, 下午4:43:56, 2012
 *
 * @Author wangming
 *
 */
public class SearchActivity extends BaseActivity {
	private final String TAG = "SearchActivity";
	private SearchController mSearchController;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.search_activity);
		mSearchController = new SearchController(this);
	}
}
