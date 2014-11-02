package com.ifeng.share.tenqt;

import android.app.Activity;
import android.content.Intent;
import android.widget.Toast;

import com.ifeng.share.R;
import com.ifeng.share.action.ShareManager;
import com.ifeng.share.activity.TenqtAuthoActivity;
import com.ifeng.share.bean.ShareInterface;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.sina.WeiboHelper.BindListener;
import com.ifeng.share.util.WindowPrompt;

public class ShareTenqt implements ShareInterface{
	private Activity activity;
	private TenqtManager tenqt ; 
	private WindowPrompt windowPrompt;
	
	
	public ShareTenqt(){
	}
	
	public void showMessage(String text){
		Toast.makeText(activity,text, Toast.LENGTH_SHORT).show();
	}
	
	@Override
	public Boolean share(ShareMessage shareMessage) {
		
		if(shareMessage != null){
			tenqt.setShareMessage(shareMessage);
			tenqt.addNewMessage();
			return true;
		}
		return false;
	}
	@Override
	public void bind(Activity activity,BindListener bindListener) {
		Intent intent= new Intent(activity, TenqtAuthoActivity.class);
        activity.startActivity(intent);
        activity.overridePendingTransition(R.anim.in_from_right,
                R.anim.out_to_left);
	}
	@Override
	public void unbind(Activity activity) {
		TokenTools.removeToken(activity, ShareManager.TENQT);
		ShareManager.deleteCookie(activity);
		Toast.makeText(activity, "已取消绑定腾讯微博", Toast.LENGTH_SHORT).show();
	}
	@Override
	public Boolean isAuthorzine(Activity activity) {
		init(activity);
		if (tenqt.isAuthorizeTenqt(activity)) {
			return true;
		}
		return false;
	}
	@Override
	public void shareSuccess() {
		//showMessage("发送成功");
		windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.share_success_title,R.string.share_success_to_tenqt);
		activity.finish();
	}
	@Override
	public void shareFailure() {
		//showMessage("发送失败");
		windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.share_fail_title,R.string.share_fail_content);
		}
	@Override
	public void authCallback(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		
	}
	
	public void init(Activity activity){
		this.activity = activity;
		tenqt = new TenqtManager(activity);
		windowPrompt = WindowPrompt.getInstance(activity);
	}
}
