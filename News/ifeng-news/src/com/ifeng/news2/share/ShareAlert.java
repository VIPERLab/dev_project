package com.ifeng.news2.share;

import im.yixin.sdk.api.IYXAPI;
import im.yixin.sdk.api.YXAPIFactory;

import java.util.ArrayList;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface.OnCancelListener;
import android.os.Message;

import com.ifeng.news2.Config;
import com.ifeng.news2.R;
import com.ifeng.news2.exception.WXUninstallException;
import com.ifeng.news2.exception.YXUninstallException;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.share.action.ShareAlertInterface;
import com.ifeng.share.config.ShareConfig;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.tencent.tauth.Tencent;

public class ShareAlert  implements ShareAlertInterface {

	public static final int WEIBO_BUT = 0 ; 
	public static final int WEIXIN_BUT = 1;
	public static final int PENGYOU_BUT = 2;
	public static final int TENQT_BUT = 3;
	public static final int TENQZ_BUT = 4;
	public static final int TENQQ_BUT = 5;
	public static final int SMS_BUT = 6;
	public static final int YIXIN_BUT = 7;
	public static final int YXPENGYOU_BUT = 8;
	
	protected BaseShareUtil share = null;
	protected IWXAPI api = null;
	protected IYXAPI yxapi = null ; 
	protected Tencent tencent = null;
	private WXHandler handler = null;
	
	public static final int COMMENT_STATE = 1; //评论分享
	public static final int MAIN_STATE = 0;   //原来的分享
	
	private int state = 0;  //分享的状态
	
	
	public interface OnAlertSelectId {
		void onClick(int whichButton);
	}
	
	protected Dialog getCustomDialog(final Context context, OnCancelListener cancelListener, final OnAlertSelectId alertDo){
		return null;
	}
	
	
	/**
	 * 增加documentId参数，由于分享的统计
	 * @param context
	 * @param wxHandler
	 * @param url
	 * @param title
	 * @param content
	 * @param imageList
	 */
	public ShareAlert(Context context, WXHandler wxHandler,  String url,String title,String content,ArrayList<String> imageList
			, String documentId, StatisticUtil.StatisticPageType type) {
		//微信
		handler = wxHandler;
		// 通过WXAPIFactory工厂，获取IWXAPI的实例,将该app注册到微信
		if(api == null){
			api = WXAPIFactory.createWXAPI(context, Config.WX_APP_ID,false);
		}
		
		// 通过YXAPIFactory工厂，获取IYXAPI的实例,将该app注册到易信
		if(yxapi == null)
			yxapi = YXAPIFactory.createYXAPI(context , Config.YX_APP_ID);
		
		if(tencent == null)
			tencent = Tencent.createInstance(ShareConfig.TENQQ_APPID, context);
	
		share = new ShareUtil(context, api,yxapi, tencent,wxHandler , url, title, content, imageList, documentId, type);
		
	}
	
	/**
	 * 增加documentId参数，由于分享的统计
	 * @param context
	 * @param wxHandler
	 * @param url
	 * @param title
	 * @param content
	 * @param imageList
	 */
	public ShareAlert(Context context, WXHandler wxHandler,  String url,String title,String content,ArrayList<String> imageList
			, String documentId, StatisticUtil.StatisticPageType type,int state) {
		
		//this(context, wxHandler, url, title, content, imageList, documentId, type);
		
		//微信
		handler = wxHandler;
		// 通过WXAPIFactory工厂，获取IWXAPI的实例,将该app注册到微信
		if(api == null){
			api = WXAPIFactory.createWXAPI(context, Config.WX_APP_ID,false);
		}
		
		// 通过YXAPIFactory工厂，获取IYXAPI的实例,将该app注册到易信
		if(yxapi == null)
			yxapi = YXAPIFactory.createYXAPI(context , Config.YX_APP_ID);
		
		if(tencent == null)
			tencent = Tencent.createInstance(ShareConfig.TENQQ_APPID, context);
		
		this.state = state;

		share = new CommentShareUtil(context, api,yxapi, tencent,wxHandler , url, title, content, imageList, documentId, type);
		
	}

	@Override
	public void show(Context context) {
		getCustomDialog(context, null, new OnAlertSelectId() {
			@Override
			public void onClick(int whichButton) {
				switch(whichButton){
				case WEIBO_BUT:
					sendWeibo();
					break;
				case WEIXIN_BUT:
					sendWeiXin(true);
					break;
				case PENGYOU_BUT:
					sendWeiXin(false);
					break;
				case TENQT_BUT:
					sendTenQt();
					break;
				case TENQZ_BUT:
					sendTenQz();
					break;
				case TENQQ_BUT:
					sendTenQq();
					break;
				case SMS_BUT:
					sendSMS();
					break;
				case YIXIN_BUT:
					sendYiXin(true);
					break;
				case YXPENGYOU_BUT:
					sendYiXin(false);
					break;
				default:
					break;
				}
			}

		}).show();
	}
	
	/**
	 * 发送到新浪微博
	 */
	private void sendWeibo(){
		share.sendWeibo();
	}
	
	/**
	 * 发送到腾讯微博
	 */
	private void sendTenQt() {
		// TODO Auto-generated method stub
		share.sendTenQt();
	}
	
	/**
	 * 发送到QQ空间
	 */
	private void sendTenQz(){
		share.sendTenQz();
	}
	
	/**
	 * 发送QQ好友
	 */
	private void sendTenQq(){
		new Thread(){
			public void run() {
				share.sendTenQq();
			};
		}.start();
	}
	
	/**
	 * 发送短信
	 */
	private void sendSMS() {
		// TODO Auto-generated method stub
		new Thread(){
			@Override
			public void run() {
				// TODO Auto-generated method stub
				share.sendSMS();
			}
		}.start();
	}
	
	/**
	 * 发送到微信
	 * @param toWeiXin
	 */
	private void sendWeiXin(final boolean toWeiXin){
		try {
			share.sendWeiXin(toWeiXin);
        }catch(WXUninstallException e){
				e.printStackTrace();
				sendMessgeToMainThread(R.string.weixin_uninstall_fail);
		} catch (Exception e) {
				e.printStackTrace();
         	    sendMessgeToMainThread(R.string.weixin_share_content_fail);
		}
//		new Thread(new Runnable() {
//	        @Override
//	        public void run() {
//	            try {
//					share.sendWeiXin(toWeiXin);
//	            }catch(WXUninstallException e){
//					e.printStackTrace();
//					sendMessgeToMainThread(R.string.weixin_uninstall_fail);
//				} catch (Exception e) {
//					e.printStackTrace();
//	            	sendMessgeToMainThread(R.string.weixin_share_content_fail);
//				}
//	        }
//	    }).start();
	}
	
	/**
	 *发送到易信
	 * @param b
	 */
	private void sendYiXin(final boolean toYiXin) {
		// TODO Auto-generated method stub
		new Thread(new Runnable() {
	        @Override
	        public void run() {
	            try {
					share.sendYiXin(toYiXin);
	            }catch(YXUninstallException e){
					e.printStackTrace();
					sendMessgeToMainThread(R.string.yixin_uninstall_fail);
				} catch (Exception e) {
					e.printStackTrace();
	            	sendMessgeToMainThread(R.string.yixin_share_content_fail);
				}
	        }
	    }).start();
	}
	
	/**
	 * 送消息给主线程
	 * @param state
	 */
	public void sendMessgeToMainThread(int state){
		if(null != handler){
			Message msg = handler.obtainMessage(state);
			handler.sendMessage(msg);
		}
	}
	
}
