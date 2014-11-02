package com.ifeng.share.util;

import android.content.Context;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.WindowManager;

public class DeviceUtils {

  /**
   * 手机屏幕宽度
   * @param ctx
   * @return
   */
  public static int getWindowWidth(Context ctx){
    Display display = ((WindowManager) ctx.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
    DisplayMetrics metrics = new DisplayMetrics();
    display.getMetrics(metrics);
    
    return metrics.widthPixels ; 
  }
  
  /**
   * 手机屏幕高度
   * @param ctx
   * @return
   */
  public static int getWindowHeight(Context ctx){
    
    Display display = ((WindowManager) ctx.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
    DisplayMetrics metrics = new DisplayMetrics();
    display.getMetrics(metrics);
    
    return metrics.heightPixels ; 
  }
}
