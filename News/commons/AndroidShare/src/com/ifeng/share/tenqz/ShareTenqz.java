package com.ifeng.share.tenqz;

import android.app.Activity;
import android.content.Intent;
import android.widget.Toast;

import com.ifeng.share.R;
import com.ifeng.share.activity.TenqzAuthoActivity;
import com.ifeng.share.bean.ShareInterface;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.config.ShareConfig;
import com.ifeng.share.sina.WeiboHelper.BindListener;
import com.ifeng.share.util.WindowPrompt;
import com.weibo.net.Utility;
import com.weibo.net.WeiboParameters;

public class ShareTenqz implements ShareInterface{

	private Activity activity ;
	private TenqzManager tenqz; 
	private WindowPrompt windowPrompt;
	
	@Override
	public Boolean share(ShareMessage shareMessage) {
		// TODO Auto-generated method stub
		if(shareMessage != null){
			tenqz.setShareMessage(shareMessage);
			tenqz.addNewMessage();
			return true;
		}
		return false;
	}

	@Override
	public void bind(Activity activity,BindListener bindListener) {
		// TODO Auto-generated method stub
		Intent intent = new Intent(activity,TenqzAuthoActivity.class);
		intent.putExtra("authUrl", concatUrl());
		activity.startActivity(intent);
		activity.overridePendingTransition(R.anim.in_from_right,
                R.anim.out_to_left);
		
	}

	/**
	 * 组合url
	 * @return
	 */
	private String concatUrl() {
		// TODO Auto-generated method stub
		WeiboParameters parameters = new WeiboParameters();
		parameters.add("response_type", ShareConfig.TENQZ_RESPONSE_TYPE);
		parameters.add("redirect_uri", ShareConfig.TENQZ_REDIRECT_URI);
		parameters.add("client_id", ShareConfig.TENQQ_APPID);
		parameters.add("scope", ShareConfig.TENQZ_SCOPE);
		parameters.add("swith", ShareConfig.TENQZ_SWITH);
		
		return ShareConfig.TENQZ_AUTH_URL+"?"+Utility.encodeUrl(parameters);
	}

	@Override
	public void unbind(Activity activity) {
		// TODO Auto-generated method stub
		tenqz.logoutQQ(activity);
		showMessage("已取消绑定QQ空间");
	}

	@Override
	public Boolean isAuthorzine(Activity activity) {
		// TODO Auto-generated method stub
		init(activity);
		return tenqz.isAuthorzine(activity);
	}

	@Override
	public void shareSuccess() {
		// TODO Auto-generated method stub
		windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.share_success_title,R.string.share_success_to_tenqz);
		activity.finish();
	}

	@Override
	public void shareFailure() {
		// TODO Auto-generated method stub
		//showMessage("发送失败");
		windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.share_fail_title,R.string.share_fail_content);
	}
	
	public void init(Activity activity){
		this.activity = activity;
		tenqz = new TenqzManager(activity);
		windowPrompt = WindowPrompt.getInstance(activity);
	}
	
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		tenqz.onActivityResult(requestCode, resultCode, data);
	}
	
	
	public void showMessage(String text){
		Toast.makeText(activity,text, Toast.LENGTH_SHORT).show();
	}

	@Override
	public void authCallback(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		
	}
	
}
