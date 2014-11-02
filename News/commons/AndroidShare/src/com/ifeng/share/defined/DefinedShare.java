package com.ifeng.share.defined;

import android.app.Activity;
import android.content.Intent;

import com.ifeng.share.bean.ShareInterface;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.sina.WeiboHelper.BindListener;

public class DefinedShare implements ShareInterface{
	@Override
	public Boolean share(ShareMessage shareMessage) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public void bind(Activity activity,BindListener bindListener) {
		// TODO Auto-generated method stub
	}

	@Override
	public void unbind(Activity activity) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public Boolean isAuthorzine(Activity activity) {
		
		return false;
	}

	@Override
	public void shareSuccess() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void shareFailure() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void authCallback(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		
	}
	
}
