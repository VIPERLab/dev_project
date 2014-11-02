package com.ifeng.news2.util;

import android.view.View;
import android.view.animation.ScaleAnimation;
import android.view.animation.Transformation;

/**
 * @author liu_xiaoliang
 * 
 */
public class IfengAutoWScaleAnimation extends ScaleAnimation {

  /**
   * 动画开始位置
   */
  private int mStartW;
  /**
   * 执行动画的长度
   */
  private int mDeltaW;

  View view;
  
  public IfengAutoWScaleAnimation(View view, float fromX, float toX, float fromY, float toY) {
    super(fromX, toX, fromY, toY);
    this.view = view;
  }

  @Override
  protected void applyTransformation(float interpolatedTime, Transformation t) {
    super.applyTransformation(interpolatedTime, t);
    android.view.ViewGroup.LayoutParams lp = view.getLayoutParams();
    lp.width = (int) (mStartW + mDeltaW * interpolatedTime);
    view.setLayoutParams(lp);
  }

  public void setAnimationW(int startW, int endW) {
    mStartW = startW;
    mDeltaW = endW - startW;
  }
}
