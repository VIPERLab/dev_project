package com.ifeng.news2.util;

import java.io.File;
import android.graphics.Bitmap;
import android.util.Log;
import android.webkit.WebView;
import com.ifeng.news2.IfengNewsApp;

public class ImageLoadUtil {
	private static String requestId;

	/**
	 * 调用js
	 * 
	 * @param webview
	 * @param callbackId
	 * @param status
	 * @param imgPath
	 * @param imgWidth
	 * @param imgHeight
	 */
	private static void callbackJS(WebView webview, String callbackId,
			int status, String imgPath) {
		try {
			Log.d("webwiew", "" + webview);
			if (webview != null) {
				Log.i("news", "callbackJS : callbackId=" + callbackId
						+ ";status=" + status);
				webview.loadUrl("javascript:athene.complete('" + callbackId
						+ "'," + status + ",'" + imgPath + "')");
			}
		} catch (Exception e) {
			return;
		}
	}

	public static void callBackJsByListener(final WebView webView,
			final String callbackId, final String imageUrl,
			final boolean isDefault, String currentId) {
		if (!currentId.equals(requestId))
			return;
		showImageByJs(webView, callbackId, imageUrl, isDefault);
	}
	
	public static void showImageByJs(WebView webView, String callbackId,
			String imgPath, boolean isDefault){
		showImageByJs( webView,  callbackId,imgPath,  isDefault,  "forceLoad");
	}

	/**
	 * 通过js展现图片
	 * 
	 * @param webView
	 * @param callbackId
	 * @param imageUrl
	 * @param isDefault
	 *            是否展现底图
	 * @param forceLoad 
	 */
	public static void showImageByJs(WebView webView, String callbackId,
			String imgPath, boolean isDefault, String forceLoad) {
//		try {
//			webView.clearCache(true);
//		} catch (Exception e) {
//			e.printStackTrace();
//			return;
//		}
		//如果不是强制加载，就进行成功回调，只会在2G/3G无图模式下第一次加载图片的时候该条件成立
		if(!"forceLoad".equals(forceLoad)){
			callbackJS(webView, callbackId, 1, "none");
		} 
		//失败回调
		else if (isDefault) {
			callbackJS(webView, callbackId, 0, imgPath);
		} 
		//获取图片内容，并传递图片宽和高给js
		else {			
			if (imgPath == null) {
				return;
			}
			if (imgPath.trim().startsWith("http")) {
				File imgFile = getImageFile(imgPath);
				if (imgFile != null && imgFile.exists()) {
					imgPath = imgFile.getAbsolutePath();
				} else {
					return;
				}
			}
			
			int status = 0;	
				status = 1;
				callbackJS(webView, callbackId, status, imgPath);
		}
	}

	/**
	 * 获取bitmap
	 * 
	 * @param imageUrl
	 * @return
	 * @throws Exception
	 */
//	public static Bitmap getBitmapByUrl(String imageUrl) throws Exception {
//		Bitmap bitmap = IfengNewsApp.getResourceCacheManager().getCache(
//				imageUrl);
//		return bitmap;
//	}

	/**
	 * 获取图片路径
	 * 
	 * @param url
	 * @return
	 */
	private static File getImageFile(String url) {
		return IfengNewsApp.getResourceCacheManager().getCacheFile(url, true);
	}

	/**
	 * 判断图片资源是否存在
	 * 
	 * @param url
	 * @return
	 */
	public static boolean isImageExists(String url) {
		File imgFile = getImageFile(url);
		return imgFile == null ? false : imgFile.exists();
	}

	public static void setRequestId(String requestId) {
		ImageLoadUtil.requestId = requestId;
	}

}
