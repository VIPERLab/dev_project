package com.ifeng.news2.widget;

import com.qad.view.RecyclingImageView;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.WindowManager;
import android.widget.ImageView;

public class PlotAtlasImageView extends RecyclingImageView {

  public PlotAtlasImageView(Context context) {
    super(context);
  }

  public PlotAtlasImageView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public PlotAtlasImageView(Context context, AttributeSet attrs, int defStyle) {
    super(context, attrs, defStyle);
  }
  
  @Override
  public void setImageBitmap(Bitmap bm) {
    if (bm == null) return;
    WindowManager wm = (WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE);
    int margins = getPaddingLeft() + getPaddingRight();
    int displayWidth = wm.getDefaultDisplay().getWidth() - margins;
    //按照w/h = w1/h1比例显示   注：w为屏幕宽，h为要显示的高度，w1为图片宽，h1为图片高
    getLayoutParams().height = bm.getHeight() * displayWidth / bm.getWidth();
    setAdjustViewBounds(false);
    setScaleType(ScaleType.FIT_XY);
    super.setImageBitmap(bm);
  }

  @Override
  public void setBackgroundDrawable(Drawable background) {
    super.setBackgroundDrawable(background);
  }
}
