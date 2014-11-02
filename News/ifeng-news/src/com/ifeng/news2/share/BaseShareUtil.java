package com.ifeng.news2.share;

import im.yixin.sdk.api.IYXAPI;

import java.io.File;
import java.util.ArrayList;

import org.json.JSONObject;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Message;
import android.text.TextUtils;

import com.ifeng.news2.R;
import com.ifeng.news2.util.FilterUtil;
import com.ifeng.news2.util.ResourceUtils;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.WXUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticPageType;
import com.ifeng.share.util.NetworkState;
import com.qad.loader.ImageLoader;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;

public abstract class BaseShareUtil {

	
	//分享至QQ好友，当Detail页没有图片时候传入的默认图片
	public static final String SHARE2QQ_DEFAULT_URL = "http://s1.mimg.ifeng.com/static/img/share/defaultIcon.png";
	protected IWXAPI api;
	protected IYXAPI yxapi ; 
	protected Tencent tencent;
	protected Context context;
	protected String shareUrl;
	protected String shareTitle;
	protected String shareContent;
	protected ArrayList<String> shareImageList;
	// private String documentId;
	protected String aid = null;
	protected String type = null; // 分享的类型：文章、体育直播、图文直播、专题
	protected StatisticPageType statisticPageType = null;
	protected WXHandler handler;
	
	
	
	public BaseShareUtil(final Context context, IWXAPI wapi, IYXAPI yapi , Tencent tencent,
			WXHandler wxHandler, String url, String title, String content,
			ArrayList<String> imageList, String documentId,
			StatisticUtil.StatisticPageType type) {
		
		this.context = context;
		this.shareContent = content;
		this.shareUrl = url;
		this.shareTitle = title;
		this.shareImageList = imageList;
		this.api = wapi;
		this.yxapi = yapi ; 
		this.tencent = tencent;
		// this.documentId = documentId;/
		if (!TextUtils.isEmpty(documentId)) {
			aid = documentId;
		} else {
			aid = FilterUtil.filterIdFromUrl(shareUrl);
		}

		ResourceUtils.setContext(context);
		
		this.type = type.toString();// 分享的类型统计：文章、体育直播、图文直播、专题
		this.statisticPageType = type;// 分享的类型
		this.handler = wxHandler;
	}
	
	
	
	
	
	
	
	
	/**
	 * 发送新浪微博
	 */
	public abstract void sendWeibo();
	
	
	
	
	/**
	 * 发送腾讯微博
	 */
	public abstract void sendTenQt();
	
	
	/**
	 * 发送QQ空间
	 */
	public abstract void sendTenQz();
	
	
	/**
	 * 发送QQ好友
	 */
	public abstract void sendTenQq();
	
	
	/**
	 * 发送短信
	 */
	public abstract void sendSMS();
	
	
	/**
	 * 发送微信和朋友圈网页分享
	 * 
	 * @param toCircle
	 *            true:微信 ，false朋友圈
	 */
	public static final int THUMB_SIZE = 120;
	public static final int THUMB_WIDTH = 200;

	/**
	 * 
	 * @param toCircle
	 *            true: 微信 false：朋友圈
	 * @throws Exception
	 *             发送微信失败
	 */
	public abstract void sendWeiXin(boolean toCircle) throws Exception;
	
	
	/**
	 * 取得分享的缩略图
	 * 
	 * @param list
	 *            文章图片地址集合
	 * @return
	 */
	public Bitmap getThumb(ArrayList<String> list) {
		boolean isNetworkConnected = NetworkState
				.isActiveNetworkConnected(context);
		Bitmap thumb = null;
		try {
			if (isNetworkConnected && (null != list) && (list.size() > 0)) {
				for (String url : list) {
					// note: 带视频的文章视频底图是没有下载的，所以SD卡上没有对应的文件
					File file = ImageLoader.getResourceCacheManager()
							.getCacheFile(url);
					if (null != file && file.exists()) {
						String path = file.getAbsolutePath();
						thumb = WXUtil.extractThumbNail(path, THUMB_SIZE,
								THUMB_SIZE, true);
						if (null != thumb) {
							return thumb;
						}
					}
				}
			}
			thumb = getDefaultThumb();
			// Log.i("BitmapFactory",
			// " bitmap width:"+thumb.getWidth()+" height:"+ thumb.getHeight());
			return thumb;

		} catch (Exception e) {
			e.printStackTrace();
			thumb = getDefaultThumb();
			return thumb;
		}
	}

	public Bitmap getDefaultThumb() {
		return BitmapFactory.decodeResource(context.getResources(),
				R.drawable.weixin_default);
	}

	
	public String buildTransaction(final String type) {
		return (type == null) ? String.valueOf(System.currentTimeMillis())
				: type + System.currentTimeMillis();
	}
	
	/**
	 * 
	 * @param toCircle
	 *            true: 易信 false：朋友圈
	 * @throws Exception
	 *             发送易信失败
	 */
	public abstract void sendYiXin(boolean toCircle) throws Exception;
	
	
	
	public class TencentQQIUiListener implements IUiListener {

		@Override
		public void onCancel() {
			// TODO Auto-generated method stub
		}

		@Override
		public void onComplete(JSONObject arg0) {
			// TODO Auto-generated method stub
		}

		@Override
		public void onError(UiError arg0) {
			// TODO Auto-generated method stub
			sendMessgeToMainThread(R.string.send_to_qq_error);
		}

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
