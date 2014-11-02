package com.ifeng.share.renren;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import com.ifeng.share.action.ShareManager;
import com.ifeng.share.bean.ShareInterface;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.config.ShareConfig;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.sina.WeiboHelper.BindListener;
import com.renren.api.connect.android.AsyncRenren;
import com.renren.api.connect.android.Renren;
import com.renren.api.connect.android.common.AbstractRequestListener;
import com.renren.api.connect.android.exception.RenrenAuthError;
import com.renren.api.connect.android.exception.RenrenError;
import com.renren.api.connect.android.feed.FeedPublishRequestParam;
import com.renren.api.connect.android.feed.FeedPublishResponseBean;
import com.renren.api.connect.android.view.RenrenAuthListener;
/**
 * 人人网分享入口
 * @author PJW
 *
 */
public class ShareRenren implements ShareInterface{
	public Renren renren;
	public RenrenAuthListener renrenListener,renrenAuthorizeListener;
	public Activity activity;
	public ShareMessage shareMessage;
	public String message;
	public String shareImageUrl;
	public String title;
	public String caption;
	public String description;
	public String actionName;
	public RenrenAuthorCallback renrenCallback;
	public ProgressDialog progress;
	public ShareRenren(){}
	public void initParams(String message, String shareImageUrl) {
		this.shareImageUrl = shareImageUrl;
		this.message=RenrenManager.filterMessage(message);
		title = RenrenManager.filterTitle(shareMessage.getTitle());
		caption = RenrenManager.filterCaption(shareMessage.getCaption());
		description = RenrenManager.filterDescription(shareMessage.getDescription());
		actionName  =RenrenManager.filterActionName(shareMessage.actionName);
	}
	public void setRenrenListener(){
		renrenListener = new RenrenAuthListener() {
			@Override
			public void onComplete(Bundle values) {
				if (values.size() == 4) {
					Toast.makeText(activity, "授权成功",Toast.LENGTH_SHORT).show();
					return;
				}
				Toast.makeText(activity, "正在发送,请稍后",Toast.LENGTH_LONG).show();
				FeedPublishRequestParam param = new FeedPublishRequestParam(
						title, description, shareMessage.getUrl(),shareImageUrl,caption,actionName,shareMessage.getActionLink(), message);
				PublishFeedListener publishFeedListener = new PublishFeedListener(activity);
				AsyncRenren asyncRenren = new AsyncRenren(renren);
				asyncRenren.publishFeed(param, publishFeedListener, true);
				activity.finish();
			}
			@Override
			public void onRenrenAuthError(RenrenAuthError renrenAuthError) {
				Toast.makeText(activity, "授权失败"+renrenAuthError.getMessage(),Toast.LENGTH_SHORT).show();
			}
			@Override
			public void onCancelLogin() {
			}
			@Override
			public void onCancelAuth(Bundle values) {
			}
		};
	}
	public void setRenrenAuthorizeListener(){
		renrenAuthorizeListener = new RenrenAuthListener() {
			@Override
			public void onComplete(Bundle values) {
				if (values.size() == 4) {
					Toast.makeText(activity, "绑定成功",Toast.LENGTH_SHORT).show();
					renrenCallback.authorSuccess();
				}
			}
			@Override
			public void onRenrenAuthError(RenrenAuthError renrenAuthError) {
				Toast.makeText(activity, "绑定失败"+renrenAuthError.getMessage(),Toast.LENGTH_SHORT).show();
			}
			@Override
			public void onCancelLogin() {
			}
			@Override
			public void onCancelAuth(Bundle values) {
			}
		};
	}
	private class PublishFeedListener extends
	AbstractRequestListener<FeedPublishResponseBean> {
		private Activity ctxt;
		public PublishFeedListener(Activity ctxt) {
			this.ctxt = ctxt;
		}
		@Override
		public void onComplete(FeedPublishResponseBean bean) {
			ctxt.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					Toast.makeText(ctxt, "发送成功", Toast.LENGTH_SHORT).show();
				}
			});
		}
		@Override
		public void onRenrenError(RenrenError renrenError) {
			final int errorCode = renrenError.getErrorCode();
			final String errorMsg = renrenError.getMessage();
			ctxt.runOnUiThread(new Runnable() {
				public void run() {
					if (errorCode == RenrenError.ERROR_CODE_OPERATION_CANCELLED) {
						Toast.makeText(ctxt, "发送被取消", Toast.LENGTH_SHORT).show();
					} else {
						Toast.makeText(ctxt, "发送失败 " + errorMsg,Toast.LENGTH_SHORT).show();
					}
				}
			});
		}
		@Override
		public void onFault(Throwable fault) {
			final String errorMsg = fault.toString();
			ctxt.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					Toast.makeText(ctxt, "发送失败"+errorMsg, Toast.LENGTH_SHORT).show();
				}
			});
		}
	}
	public void setRenrenAuthorListener(RenrenAuthorCallback renrenCallback){
		this.renrenCallback = renrenCallback;
	}
	@Override
	public Boolean share(ShareMessage shareMessage) {
		initParams(shareMessage.getContent(), shareMessage.getShareImageUrl());
		setRenrenListener();
		try {
			renren.authorize(activity, renrenListener,renrenCallback);
		} catch (Exception e) {
			return false;
		}
		if (isAuthorzine(activity)) {
			return true;
		}else {
			return false;
		}
	}
	@Override
	public void bind(Activity activity,BindListener bindListener) {
		setRenrenAuthorizeListener();
		if (renren==null) {
			initDatas(activity);
		}
		try {
			renren.authorize(activity, renrenAuthorizeListener,renrenCallback);
		} catch (Exception e) {
		}
	}
	@Override
	public void unbind(Activity activity) {
		// TODO Auto-generated method stub
		TokenTools.removeRenRenToken(activity);
		ShareManager.deleteCookie(activity);
		Toast.makeText(activity, "已取消绑定人人网", Toast.LENGTH_SHORT).show();
	}
	
	public void initDatas(Activity activity){
		shareMessage = ShareManager.getShareMessage();
		renren = new Renren(ShareConfig.RENREN_APIKEY,ShareConfig.RENREN_SECRET,ShareConfig.RENREN_APPID, activity);
	}
	@Override
	public Boolean isAuthorzine(Activity activity) {
		this.activity = activity;
		initDatas(activity);
		String token=TokenTools.getRenRenToken(activity);
		if (token==null || token.length()==0) {
			return false;
		}else {
			return true;
		}
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
