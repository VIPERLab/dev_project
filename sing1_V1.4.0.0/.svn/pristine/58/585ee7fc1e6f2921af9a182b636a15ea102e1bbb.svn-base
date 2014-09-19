package cn.kuwo.sing.util;

import android.content.Context;

public class DensityUtils {

	/**
	 * change dip to px
	 * 
	 * @param context
	 * @param dpValue
	 * @return
	 */
	public static int dip2px(Context context, float dpValue) {
		final float density = context.getResources().getDisplayMetrics().density;
		return (int) (dpValue * density + 0.5f);
	}

	/**
	 * change px to dip
	 * 
	 * @param context
	 * @param pxValue
	 * @return
	 */
	public static int px2dip(Context context, float pxValue) {
		final float density = context.getResources().getDisplayMetrics().density;
		return (int) (pxValue / density + 0.5f);
	}
	
	 /**
	  * 将px值转换为sp值，保证文字大小不变
	  * 
	  * @param pxValue
	  * @param fontScale（DisplayMetrics类中属性scaledDensity）
	  * @return
	  */
	 public static int px2sp(Context context, float pxValue) {
		 final float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
	  return (int) (pxValue / fontScale + 0.5f);
	 }


}
