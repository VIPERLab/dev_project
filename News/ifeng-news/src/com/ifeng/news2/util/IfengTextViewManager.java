package com.ifeng.news2.util;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;


public class IfengTextViewManager {



  /**
   * 判断一个字符是否为中文
   * 
   * @param character
   * @return
   */
  public static final boolean isChineseCharacter(Character character) {
    if ((character >= 0x4e00) && (character <= 0x9fbb)) {
      return true;
    }
    return false;
  }

  /**
   * 将px值转换为dip或dp值，保证尺寸大小不变
   * 
   * @param pxValue
   * @param scale （DisplayMetrics类中属性density）
   * @return
   */
  public static int px2dip(Context context, float pxValue) {
    final float scale = context.getResources().getDisplayMetrics().density;
    return (int) (pxValue / scale + 0.5f);
  }

  /**
   * 将dip或dp值转换为px值，保证尺寸大小不变
   * 
   * @param dipValue
   * @param scale （DisplayMetrics类中属性density）
   * @return
   */
  public static int dip2px(Context context, float dipValue) {
    final float scale = context.getResources().getDisplayMetrics().density;
    return (int) (dipValue * scale + 0.5f);
  }

  /**
   * 将px值转换为sp值，保证文字大小不变
   * 
   * @param pxValue
   * @param fontScale （DisplayMetrics类中属性scaledDensity）
   * @return
   */
  public static int px2sp(Context context, float pxValue) {
    final float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
    return (int) (pxValue / fontScale + 0.5f);
  }

  /**
   * 将sp值转换为px值，保证文字大小不变
   * 
   * @param spValue
   * @param fontScale （DisplayMetrics类中属性scaledDensity）
   * @return
   */
  public static int sp2px(Context context, float spValue) {
    final float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
    return (int) (spValue * fontScale + 0.5f);
  }

  public static int sp2px(float spVaule, float fontScale) {
    return (int) (spVaule * fontScale + 0.5f);
  }

  public static int getStatusBarHeight(Activity currActivity) {
    Rect rect = new Rect();
    currActivity.getWindow().getDecorView().getWindowVisibleDisplayFrame(rect);
    return rect.top;

  }
}
