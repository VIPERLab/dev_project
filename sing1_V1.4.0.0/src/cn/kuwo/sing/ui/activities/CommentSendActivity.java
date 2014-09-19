/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.controller.CommentSendController;
import android.os.Bundle;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2012-12-19, 上午11:49:49, 2012
 *
 * @Author wangming
 *
 */
public class CommentSendActivity extends BaseActivity {
	private final String TAG = "CommentSendActivity";
	private CommentSendController mCommentSendController;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.comment_send_layout);
		mCommentSendController = new CommentSendController(this);
	}
}
