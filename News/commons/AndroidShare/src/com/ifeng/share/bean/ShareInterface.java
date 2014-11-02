package com.ifeng.share.bean;

import com.ifeng.share.sina.WeiboHelper.BindListener;

import android.app.Activity;
import android.content.Intent;

public interface ShareInterface {
	public Boolean share(ShareMessage shareMessage);
	public void bind(Activity activity,BindListener bindListener);
	public void unbind(Activity activity);
	public Boolean isAuthorzine(Activity activity);
	public void shareSuccess();
	public void shareFailure();
	public void authCallback(int requestCode, int resultCode, Intent data);
}
