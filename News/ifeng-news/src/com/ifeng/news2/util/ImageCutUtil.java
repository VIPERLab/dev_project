package com.ifeng.news2.util;

import android.app.Activity;
import com.ifeng.news2.Config;

/**
 * @author SunQuan:
 * @version 创建时间：2013-8-28 上午10:01:30 类说明
 */

public class ImageCutUtil {

	private static final String URL_BEGIN_STR = "http://";
	/**
	 * 根据原始的图片url获得实际请求裁图接口的url
	 * 
	 * @param activity
	 * @param original_url
	 * @return
	 */
	public static String getRealHeightAndWidthByUrl(Activity activity,
			String original_url) {
		String realUrl = "";
		try {
			String result = original_url.substring(
					original_url.indexOf("_") + 1,
					original_url.lastIndexOf("."));
			int width = Integer.parseInt(result.substring(0,
					result.indexOf("_")));
			int height = Integer
					.parseInt(result.substring(result.indexOf("_") + 1));
			int realWidth = activity.getWindowManager().getDefaultDisplay()
					.getWidth();
			;
			int realHeight = Math.round(height * ((float) realWidth / width));
			realUrl = getImageUrl(original_url, realWidth, realHeight);
		} catch (Exception e) {
			e.printStackTrace();
			realUrl = "";
		}
		return realUrl;
	}

	private static String getImageUrl(String original_url, int realWidth,
			int realHeight) {
		StringBuilder builder = new StringBuilder();
		builder.append(Config.IMAGE_CUT_URL).append("/w").append(realWidth)
				.append("_").append("h").append(realHeight).append("/")
				.append(original_url.substring(URL_BEGIN_STR.length()));
		return builder.toString();
	}

}
