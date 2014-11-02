package com.ifeng.share.receiver;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.ifeng.share.action.ShareManager;
import com.ifeng.share.bean.ShareInterface;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.sina.WeiboHelper.BindListener;
/**
 * 发布功能处理器
 * @author PJW
 *
 */
public class ShareReceiver extends BroadcastReceiver{
	public Context context;
	public ShareMessage shareMessage;
	public ShareInterface shareInterface;
	public Activity activity;
	public ShareReceiver(Activity activity){
		this.activity =activity;
	}
	@Override
	public void onReceive(Context context, Intent intent) {
		initShareMessage(intent);
		String action=shareMessage.getTargetShare().getAction();
		if (ShareManager.SHARE_ACTION.equals(action)|| shareInterface.isAuthorzine(activity)) {
			shareAction();
		}else if (ShareManager.BIND_ACTION.equals(action)) {
			bindAction();
		}else if (ShareManager.UNBIND_ACTION.equals(action)) {
			unbindAction();
		}
	}
	
	public void initShareMessage(Intent intent){
		shareMessage = ShareManager.getShareMessage();
		shareInterface = shareMessage.getTargetShare().getShareInterface();
	}
	public void shareAction(){
		if (shareInterface.isAuthorzine(activity)) {
			Boolean shareState = shareInterface.share(shareMessage);
			if (shareState) {
				shareInterface.shareSuccess();
			}else {
				shareInterface.shareFailure();
			}
		}else {
			shareInterface.bind(activity,null);
			/*Boolean bindState=shareInterface.bind(activity);
			if (bindState!=null && bindState) {
				shareInterface.bindSuccess();
			}else {
				shareInterface.bindFailure();
			}*/
		}
	}
	public void bindAction(){
		if (!shareInterface.isAuthorzine(activity)) {
			shareInterface.bind(activity, null);
			/*Boolean bindState=shareInterface.bind(activity);
			if (bindState) {
				shareInterface.bindSuccess();
			}else {
				shareInterface.bindFailure();
			}*/
		}
	}
	public void unbindAction(){
		if (shareInterface.isAuthorzine(activity)) {
			shareInterface.unbind(activity);
		}
	}
}




