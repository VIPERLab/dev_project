package com.ifeng.news2.util;

import android.net.Uri;
import android.text.TextUtils;

public class FilterUtil {
	public static String filterDocumentId(String documentId) {
		if (documentId != null && documentId.contains("_")) {
			documentId = documentId.substring(documentId.indexOf("_") + 1,
					documentId.length());
		}
		return documentId;
	}

	/**
	 * 判断字符串是否为纯数字
	 * 
	 * @param comment
	 * @return
	 */
	public static boolean isNum(String comment) {
		try {
			Integer.parseInt(comment);
		} catch (Exception e) {
			return false;
		}
		return true;
	}

	/**
	 * 过滤图片调整地址
	 * 
	 * @param url
	 * @return
	 */
	public static String filterImageUrl(String url) {
	     if (TextUtils.isEmpty(url)) {
          return url;
        }
		Uri uri = Uri.parse(url);
		String imageUrl = uri.getQueryParameter("url");
		if (null == imageUrl) {
			return url;
		} else {
			return imageUrl.replace("&amp;", "&");
		}
	}
	
	/**
	 * 得到url中的id参数, 
	 * 用于分享统计中取id, 包括体育直播、图文直播、专题等
	 * 用于推送到达统计时取aid
	 * 
	 * 
	 * @param url
	 * @return
	 */
	public static String filterIdFromUrl(String url) {
	    if (TextUtils.isEmpty(url)) {
          return url;
        }
		Uri uri = Uri.parse(url);
		String id = uri.getQueryParameter("mt"); // 体育直播
		if (!TextUtils.isEmpty(id)) {
			return id;
		} 
		id = uri.getQueryParameter("liveId"); // 图文直播
		if (!TextUtils.isEmpty(id)) {
			return id;
		} 
		id = uri.getQueryParameter("aid"); // 图文直播
		if (!TextUtils.isEmpty(id)) {
			return id;
		} 
		return url;
	}
	
	public static String filterUrl(String url) {
		if(!TextUtils.isEmpty(url)){
			url = url.substring(url.lastIndexOf("/")+1);
			if(url.contains(".")){
				url = url.substring(0, url.indexOf("."));
			}
			if(url.contains("?")){
				url = url.substring(0, url.indexOf("?"));
			}
		}		
		return url;
	}
	
	
	/**
	 * @param content
	 * @param contentNumber
	 * @return String
	 * 限制字数
	 */
	public static String getFilterContent(String content,int contentNumber) {
		if(null!=content && content.length()>contentNumber) {
			if(content.length()<=3) {
				return content;
			}
			content = content.substring(0,contentNumber-3)+"...";
		} 
		return content;
	}
	
	/**
	 * @param str
	 * @return string
	 * 获得非空字符串
	 */
	public static String getNotNullString(String str) {
		return str==null?"":str.trim();
	}
	
}
