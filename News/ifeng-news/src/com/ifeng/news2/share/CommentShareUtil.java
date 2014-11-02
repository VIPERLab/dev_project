package com.ifeng.news2.share;

import im.yixin.sdk.api.IYXAPI;
import im.yixin.sdk.api.SendMessageToYX;
import im.yixin.sdk.api.YXMessage;
import im.yixin.sdk.api.YXTextMessageData;
import im.yixin.sdk.api.YXWebPageMessageData;
import im.yixin.sdk.util.BitmapUtil;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import com.ifeng.news2.R;
import com.ifeng.news2.exception.WXUninstallException;
import com.ifeng.news2.exception.YXUninstallException;
import com.ifeng.news2.util.FilterUtil;
import com.ifeng.news2.util.ResourceUtils;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticPageType;
import com.ifeng.share.action.ShareManager;
import com.ifeng.share.activity.EditShareActivity;
import com.ifeng.share.bean.ShareMessage;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.SendMessageToWX;
import com.tencent.mm.sdk.openapi.WXMediaMessage;
import com.tencent.mm.sdk.openapi.WXTextObject;
import com.tencent.mm.sdk.openapi.WXWebpageObject;
import com.tencent.mm.sdk.platformtools.Util;
import com.tencent.tauth.Constants;
import com.tencent.tauth.Tencent;

public class CommentShareUtil extends BaseShareUtil{
	
	
	//网友评论字数的限制类
	public static final class CommentConstantsLength{
		public static final int XIN_CONTENT_LENGTH = 40;     //易信&微信
		public static final int QQ_CONTENT__LENGTH = 40; //QQ好友&QQ空间
		public static final int SMS_CONTENT_LENGTH = 36;     //短信
		public static final int WEIBO_CONSTANT_TEN = 22;     //新浪微博&腾讯微博
		public static final int TITLE_LENGTH = 5;            //凤凰新闻：的长度
		public static final int QQSPACE_CONSTENT_LENGTH = 7; //QQ空间评论固定字数  (网友评论:\r\n)
	}

	private String copyTitle;
	

	public CommentShareUtil(final Context context, IWXAPI wapi, IYXAPI yapi , Tencent tencent,
			WXHandler wxHandler, String url, String title, String content,
			ArrayList<String> imageList, String documentId,
			StatisticUtil.StatisticPageType type) {
		
		super(context, wapi, yapi, tencent, wxHandler, url,
				FilterUtil.getNotNullString(title),
				FilterUtil.getNotNullString(content), 
				imageList, documentId, type);
		this.copyTitle = this.shareTitle;
	}

	/**
	 * 发送新浪微博
	 */
	public void sendWeibo() {
		handleCommentWeiBoShareHandler();
		ShareMessage message = new ShareMessage();
		message.setContent(shareContent);
		message.setTitle(shareTitle);
		message.setUrl(shareUrl);
		message.setImageResources( shareImageList);

		ShareManager.setShareMessage(message);
		ShareManager.setShareByType("sina");
		Intent intent = new Intent(context, EditShareActivity.class);
		context.startActivity(intent);

		StatisticUtil.addRecord(context,
				StatisticUtil.StatisticRecordAction.ts, "id=" + aid + "$type="
						+ type + "$share=swb");
	}

	/**
	 * 发送腾讯微博
	 */
	public void sendTenQt() {
		handleCommentWeiBoShareHandler();
		ShareMessage message = new ShareMessage();
		message.setContent(shareContent);
		message.setTitle(shareTitle);
		message.setUrl(shareUrl);
		message.setImageResources(shareImageList);
		
		ShareManager.setShareMessage(message);
		ShareManager.setShareByType("tenqt");
		Intent intent = new Intent(context, EditShareActivity.class);
		context.startActivity(intent);
		// StatisticUtil.addRecord(context, StatisticUtil.SHARE,
		// shareUrl+"$"+"swb");

		StatisticUtil.addRecord(context,
				StatisticUtil.StatisticRecordAction.ts, "id=" + aid + "$type="
						+ type + "$share=twb");
	}

	/**
	 * 发送QQ空间
	 */
	public void sendTenQz() {
		handleCommentQQSpaceHandler();
		ShareMessage message = new ShareMessage();
		
		message.setTitle(shareTitle);
		message.setContent(shareContent);
		
		message.setForm(ResourceUtils.getString(R.string.share_text_from));
		message.setUrl(shareUrl);
		message.setImageResources(shareImageList);

		ShareManager.setShareMessage(message);
		ShareManager.setShareByType("tenqz");
		Intent intent = new Intent(context, EditShareActivity.class);
		context.startActivity(intent);
		
		StatisticUtil.addRecord(context,
				StatisticUtil.StatisticRecordAction.ts, "id=" + aid + "$type="
						+ type + "$share=qzone");
	}

	/**
	 * 发送QQ好友
	 */
	public void sendTenQq() {
		handleCommentQQFriendShareHandler();
		Bundle params = new Bundle();
		
		params.putString(Constants.PARAM_TITLE, shareTitle);
		
	    if (null != shareImageList && !shareImageList.isEmpty()) {
			params.putString(Constants.PARAM_IMAGE_URL, shareImageList.get(0));
		}else{
			params.putString(Constants.PARAM_IMAGE_URL, SHARE2QQ_DEFAULT_URL);
		}
		params.putString(Constants.PARAM_TARGET_URL,
				shareUrl);

		params.putString(Constants.PARAM_SUMMARY,shareContent);
	    params.putString(Constants.PARAM_APP_SOURCE, ResourceUtils.getString(R.string.share_type));
	    params.putString(Constants.PARAM_APPNAME,
				ResourceUtils.getString(R.string.share_type));

		tencent.shareToQQ((Activity) context, params,
				new TencentQQIUiListener());

		StatisticUtil.addRecord(context,
				StatisticUtil.StatisticRecordAction.ts, "id=" + aid + "$type="
						+ type + "$share=qq");
	}

	/**
	 * 发送短信
	 */
	public void sendSMS() {
		
		handleCommentSMSShareHandler();
		Intent intent = new Intent(Intent.ACTION_VIEW);

		intent.putExtra("sms_body", shareContent);
		intent.setType("vnd.android-dir/mms-sms");
		context.startActivity(intent);
		
		StatisticUtil.addRecord(context,
				StatisticUtil.StatisticRecordAction.ts, "id=" + aid + "$type="
						+ type + "$share=sms");
	}

	/**
	 * 
	 * @param toCircle
	 *            true: 微信 false：朋友圈
	 * @throws Exception
	 *             发送微信失败
	 */
	public void sendWeiXin(boolean toCircle) throws Exception {
		// 如果不支持，则
		
		if (!api.isWXAppInstalled() || !api.isWXAppSupportAPI()) {
			throw new WXUninstallException();
		}
		if (api.getWXAppSupportAPI() < 0x21020001) {
			throw new WXUninstallException();
		}
		handleCommentXinShareHandler();
		sentWXWebPage(toCircle);
	}

	private boolean sentWXWebPage(boolean toCircle) throws Exception {
		// 如果分享地址为空或者""
		if (TextUtils.isEmpty(shareUrl)) {
			return sendText(this.shareContent, toCircle);
		}
		WXWebpageObject webpage = new WXWebpageObject();
		webpage.webpageUrl = this.shareUrl;
		WXMediaMessage msg = new WXMediaMessage(webpage);
		msg.title = this.shareTitle;
	//	msg.description = this.shareContent;
		msg.description = this.shareContent;
		// try{
		// 分享页面捕捉这个Exception，显示分享失败
		if (shareImageList != null) {
			msg.thumbData = Util.bmpToByteArray(getThumb(shareImageList), true);
		}
		
		// }catch(Exception e){
		// e.printStackTrace();
		// Bitmap thumb = getDefaultThumb();
		// msg.thumbData = Util.bmpToByteArray(thumb, true);
		// }
		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("webpage");
		req.message = msg;
		req.scene = toCircle ? SendMessageToWX.Req.WXSceneSession
				: SendMessageToWX.Req.WXSceneTimeline;
		if (toCircle) {
			// StatisticUtil.addRecord(context, StatisticUtil.SHARE,
			// shareUrl+"$"+"wxgf");
			StatisticUtil.addRecord(context,
					StatisticUtil.StatisticRecordAction.ts, "id=" + aid
							+ "$type=" + type + "$share=wxgf");
		} else {
			// StatisticUtil.addRecord(context, StatisticUtil.SHARE,
			// shareUrl+"$"+"wxcf");
			StatisticUtil.addRecord(context,
					StatisticUtil.StatisticRecordAction.ts, "id=" + aid
							+ "$type=" + type + "$share=wxcf");
		}
		boolean sentReq = api.sendReq(req);
		return sentReq;
	}



	/**
	 * 
	 * @param 发送分享内容
	 * @param 是否分享到微信还是朋友圈
	 * @return
	 */
	private boolean sendText(String text, boolean toCircle) {
		if (text == null || text.length() == 0) {
			return false;
		}

		// 初始化一个WXTextObject对象
		WXTextObject textObj = new WXTextObject();
		textObj.text = text;

		// 用WXTextObject对象初始化一个WXMediaMessage对象
		WXMediaMessage msg = new WXMediaMessage();
		msg.mediaObject = textObj;
		// 发送文本类型的消息时，title字段不起作用
		// msg.title = "Will be ignored";
		msg.description = text;

		// 构造一个Req
		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("text"); // transaction字段用于唯一标识一个请求
		req.message = msg;
		req.scene = toCircle ? SendMessageToWX.Req.WXSceneSession
				: SendMessageToWX.Req.WXSceneTimeline;

		// 调用api接口发送数据到微信
		api.sendReq(req);
		return true;
	}


	
	/**
	 * 
	 * @param toCircle
	 *            true: 易信 false：朋友圈
	 * @throws Exception
	 *             发送易信失败
	 */
	public void sendYiXin(boolean toCircle) throws Exception {
		// 判断是否安装易信
		
		if (!yxapi.isYXAppInstalled()) {
			throw new YXUninstallException();
		}
		handleCommentXinShareHandler();
		sendWXWebPage(toCircle);
	}
	

	private void sendWXWebPage(boolean toCircle) {
		// TODO Auto-generated method stub
		// 如果分享地址为空或者""
		if (TextUtils.isEmpty(shareUrl)) {
			sendText2YX(this.shareContent, toCircle);
		}
		
		YXWebPageMessageData webpage = new YXWebPageMessageData();
		webpage.webPageUrl = this.shareUrl;
		YXMessage msg = new YXMessage(webpage);
		msg.title = this.shareTitle;
		//msg.description = this.shareContent;
		msg.description = this.shareContent;
		
		if(null != shareImageList )
			msg.thumbData = BitmapUtil.bmpToByteArray(getThumb(shareImageList), true);
		
		SendMessageToYX.Req req = new SendMessageToYX.Req();
		req.transaction = buildTransaction("webpage");
		req.message = msg;
		req.scene = toCircle ? SendMessageToYX.Req.YXSceneSession
				: SendMessageToYX.Req.YXSceneTimeline;
		
		if (toCircle) {
			StatisticUtil.addRecord(context,
					StatisticUtil.StatisticRecordAction.ts, "id=" + aid
							+ "$type=" + type + "$share=yxgf");
		} else {
			StatisticUtil.addRecord(context,
					StatisticUtil.StatisticRecordAction.ts, "id=" + aid
							+ "$type=" + type + "$share=yxcf");
		}
		yxapi.sendRequest(req);
	}

	/**
	 * 
	 * @param 发送分享内容
	 * @param 是否分享到易信还是朋友圈
	 * @return
	 */
	private void sendText2YX(String text, boolean toCircle) {
		// TODO Auto-generated method stub
		if(TextUtils.isEmpty(text))
			return ; 
		
		// 初始化一个WXTextObject对象
		YXTextMessageData textObj = new YXTextMessageData();
		textObj.text = text;

		// 用WXTextObject对象初始化一个YXMessage对象
		YXMessage msg = new YXMessage();
		msg.messageData = textObj;
		// 发送文本类型的消息时，title字段不起作用
		// msg.title = "Will be ignored";
		msg.description = text;

		// 构造一个Req
		SendMessageToYX.Req req = new SendMessageToYX.Req();
		req.transaction = buildTransaction("text"); // transaction字段用于唯一标识一个请求
		req.message = msg;
		req.scene = toCircle  ? SendMessageToYX.Req.YXSceneSession
				: SendMessageToYX.Req.YXSceneTimeline;

		// 调用api接口发送数据到易信
		yxapi.sendRequest(req);
		
	}
	
	
	public void setTitle(String title) {
		this.shareTitle = title;
	}
	
	public String getshareContent() {
		return shareContent;
	}

	public void setshareContent(String shareContent) {
		this.shareContent = shareContent;
	}

	public void setContent(String content) {
		this.shareContent = content;
	}
	public void setImages(ArrayList<String> images) {
		this.shareImageList = images;
	}
	
	public StatisticPageType getStatisticPageType() {
		return this.statisticPageType;
	}
	
	
	private  void handleCommentXinShareHandler() {
		limitInformation(CommentConstantsLength.XIN_CONTENT_LENGTH);
		shareTitle = String.format(ResourceUtils.getString(R.string.comments_content),shareContent);
		shareContent = String.format(ResourceUtils.getString(R.string.comments_news),copyTitle);
	}
	
	private void handleCommentSMSShareHandler() {
		shareContent = FilterUtil.getFilterContent(shareContent,CommentConstantsLength.SMS_CONTENT_LENGTH);
		shareContent  =String.format(ResourceUtils.getString(R.string.comment_send_msg), shareContent,shareTitle,shareUrl);
	}

	private void handleCommentQQFriendShareHandler() {
		handleshareImageList();
		limitInformation(CommentConstantsLength.QQ_CONTENT__LENGTH);
		shareTitle= String.format(ResourceUtils.getString(R.string.comments_content),shareContent);
		shareContent = String.format(ResourceUtils.getString(R.string.comments_news),copyTitle);
	}

	private void handleCommentQQSpaceHandler() {
		handleshareImageList();
		int titleLength  = filterInformationForQQSpace(shareContent,shareUrl);
		if(titleLength>CommentConstantsLength.TITLE_LENGTH) {
			titleLength-=CommentConstantsLength.TITLE_LENGTH;
			if(titleLength<copyTitle.length()) {
				copyTitle = copyTitle.substring(0, titleLength);
			}
			shareContent = String.format(ResourceUtils.getString(R.string.share_comment_text_qqspaceandx),shareContent, copyTitle,shareUrl );
		} else {
			shareContent = String.format(ResourceUtils.getString(R.string.share_comment_text_qqspaceandxTwo),shareContent, shareUrl );
		}
		
	}

	private void handleCommentWeiBoShareHandler() {
		handleshareImageList();
		shareContent = filterInformation(shareUrl,shareTitle,shareContent);
		shareContent = String.format(
				ResourceUtils.getString(
						R.string.share_comment_text_tx)
						,shareContent, shareTitle ,shareUrl);
	}
	
	
	/**
	 * 处理图片
	 */
	public void handleshareImageList() {
		ArrayList<String> imageTemp = new ArrayList<String>();
		if (null != shareImageList && !shareImageList.isEmpty()) {
			for (String image : shareImageList) {
				imageTemp.add(FilterUtil.filterImageUrl(image));
			}
		}
		shareImageList = imageTemp;
	}
	
	/**
	 * @param limitLength
	 * 限制发送信息长度字数
	 */
	public void limitInformation(int limitLength) {
		shareContent = FilterUtil.getFilterContent(shareContent,limitLength);
	}
	
	/**
	 * @param shareContent
	 * @param url
	 * 获得单条跟帖分享至QQ空间的评论内容标题长度
	 */
	public int filterInformationForQQSpace(String shareContent,String url) {
		
		int len = EditShareActivity.SHARELENGTH-1;//空格 
		len -= url.length();
		len -= CommentConstantsLength.QQSPACE_CONSTENT_LENGTH;
		int msgLen = shareContent.length();
		
		if(msgLen>CommentConstantsLength.QQ_CONTENT__LENGTH) {
			this.shareContent = shareContent.substring(0, CommentConstantsLength.QQ_CONTENT__LENGTH);
			len -= CommentConstantsLength.QQ_CONTENT__LENGTH;
		} else {
			len -= msgLen;
		}
		
		return len;
	}
	
	/**
	 * @param shareUrl
	 * @param title
	 * @param content
	 * @param sina
	 * @return  腾讯&新浪微博分享的内容
	 */
	public static String filterInformation(String shareUrl, String title,
			String content) {
		
		int len = EditShareActivity.SHARELENGTH-1;//空格 
		int lenTitle = title.length();
		int lenContent = content.length();
		
		len-=CommentConstantsLength.WEIBO_CONSTANT_TEN;
		len -= shareUrl.length();
		len -= lenTitle;
		if(len<3) {
//			if(lenContent > len+shareUrl.length()) {
//				return content.substring(0, len+shareUrl.length());
//			} else {
				return content;
//			}
		}
		if(lenContent>len-3) {
			content = content.substring(0,len-3)+"...";
		}
		return content;
	}
	
}
