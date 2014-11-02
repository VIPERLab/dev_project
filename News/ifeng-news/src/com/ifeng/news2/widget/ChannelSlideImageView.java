package com.ifeng.news2.widget;

import com.qad.view.RecyclingImageView;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.WindowManager;
import android.widget.ImageView;

/**
 * @author liu_xiaoliang
 * 三联图宽高比为3：2 
 * 计算高度需要根据宽度计算，
 * 三联图的宽度比屏幕的宽度要小而计算时是按照屏幕宽度的三分之一计算的，
 * 所以将高宽比提升为1.6才能计算较为准确的高度
 */
public class ChannelSlideImageView extends RecyclingImageView {

  private static final double ratio = 1.60;
  private int displayWidth;
  private int displayHeight;
  public ChannelSlideImageView(Context context) {
    super(context);
    getDisplayWidth();
  }

  public ChannelSlideImageView(Context context, AttributeSet attrs) {
    super(context, attrs);
    getDisplayWidth();
  }
  
  private void getDisplayWidth(){
//    WindowManager wm = (WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE);
//    displayWidth = wm.getDefaultDisplay().getWidth()/3;
    displayWidth = getContext().getResources().getDisplayMetrics().widthPixels / 3;
    displayHeight = (int)(displayWidth/ratio);
  }
  
//  @Override
//  public void setImageBitmap(Bitmap bm) {
//    if (bm == null) return;
//    getLayoutParams().height = displayHeight;
//    setAdjustViewBounds(false);
//    setScaleType(ScaleType.CENTER_CROP);
//    super.setImageBitmap(bm);
//  }
  
  @Override
	public void setImageDrawable(Drawable drawable) {
		getLayoutParams().height = displayHeight;
	    setAdjustViewBounds(false);
	    setScaleType(ScaleType.CENTER_CROP);
		super.setImageDrawable(drawable);
	}
  
}
