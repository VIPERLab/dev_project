/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import com.nostra13.universalimageloader.core.ImageLoader;

import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.CommentController;
import android.content.Intent;
import android.os.Bundle;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2012-12-18, 下午4:28:12, 2012
 *
 * @Author wangming
 *
 */
public class CommentActivity extends BaseActivity {
	private final String TAG = "CommentActivity";
	private CommentController mCommentController;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.comment_layout);
		mCommentController = new CommentController(this, ImageLoader.getInstance());
	}
	
	@Override
	public void onBackPressed() {
		mCommentController.clearDisplayedImages();
		super.onBackPressed();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case Constants.COMMENT_SEND_REQUEST:
			if(resultCode == Constants.COMMENT_SEND_SUCCESS_RESULT) {
				KuwoLog.i(TAG, "发表评论成功！");
				//刷新评论ListView
				mCommentController.toRefresh();
			}else if(resultCode == Constants.COMMENT_SEND_FAIL_RESULT) {
				KuwoLog.i(TAG, "发表评论失败！");
			}
			break;

		default:
			break;
		}
		
	}
}
