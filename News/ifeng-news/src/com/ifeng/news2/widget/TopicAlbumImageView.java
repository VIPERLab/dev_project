package com.ifeng.news2.widget;

import com.ifeng.news2.util.IfengTextViewManager;
import com.qad.view.RecyclingImageView;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;

/**
 * @author liu_xiaoliang
 * 
 */
public class TopicAlbumImageView extends RecyclingImageView {

  int displayWidth, displayHeight;

  public TopicAlbumImageView(Context context) {
    super(context);
    getDisplayWidth(context);
  }

  public TopicAlbumImageView(Context context, AttributeSet attrs) {
    super(context, attrs);
    getDisplayWidth(context);
  }

  private void getDisplayWidth(Context context) {
//    WindowManager wm = (WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE);
    displayHeight = getContext().getResources().getDisplayMetrics().widthPixels / 2 - IfengTextViewManager.dip2px(context, 6 * 4);
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
  
  @Override
  public void setBackgroundResource(int resid) {
    getLayoutParams().height = displayHeight;
    setAdjustViewBounds(false);
    setScaleType(ScaleType.CENTER_CROP);
    super.setBackgroundResource(resid);
  }

}
