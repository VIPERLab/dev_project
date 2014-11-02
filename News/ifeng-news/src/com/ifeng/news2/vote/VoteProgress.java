package com.ifeng.news2.vote;

import com.ifeng.news2.R;
import com.ifeng.news2.util.IfengAutoWScaleAnimation;
import com.ifeng.news2.util.IfengTextViewManager;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.widget.ImageView;
import android.widget.RelativeLayout;

/**
 * 结果页的进度条包装视图
 * 
 * @author SunQuan:
 * @version 创建时间：2013-12-3 上午10:17:48 类说明
 */

public class VoteProgress extends RelativeLayout {

  // 进度条的最大长度
  private static final float MAX_DIP = 150;
  // 进度条动画的播放时间
  private static final long PLAY_DURATION = 1000;
  private int maxLength;
  private ImageView resultBoll;
  private View resultBar;
  private int length;

  public VoteProgress(Context context, AttributeSet attrs, int defStyle) {
    super(context, attrs, defStyle);
    init(context);
  }

  public VoteProgress(Context context, AttributeSet attrs) {
    super(context, attrs);
    init(context);
  }

  public VoteProgress(Context context) {
    super(context);
    init(context);
  }

  /**
   * 初始化控件信息
   * 
   * @param context
   */
  private void init(Context context) {
    View wrapper = LayoutInflater.from(context).inflate(R.layout.vote_progress, this);
    maxLength = IfengTextViewManager.dip2px(context, MAX_DIP);
    resultBoll = (ImageView) wrapper.findViewById(R.id.vote_result_image);
    resultBar = wrapper.findViewById(R.id.vote_result_bar);
  }

  /**
   * 设置进度条的百分比长度,并且初始化动画
   * 
   * @param percent
   */
  public void setPercent(float percent) {
    length = (int) (maxLength * ((float) percent / 100));

  }

  /**
   * 直接显示进度条，无动画
   */
  public void showProgress() {
    android.view.ViewGroup.LayoutParams lp = resultBar.getLayoutParams();
    lp.width = length;
    resultBar.setLayoutParams(lp);
  }

  /**
   * 设置背景颜色
   * 
   * @param voteBarColor
   */
  public void setVoteBarColor(VoteBarColor voteBarColor) {
    resultBoll.setBackgroundResource(voteBarColor.getBollResId());
    resultBar.setBackgroundResource(voteBarColor.getColorResId());
  }

  /**
   * 播放进度条动画
   * 
   * @param v
   * @param persent
   */
  public void startAni() {
    IfengAutoWScaleAnimation animation =
        new IfengAutoWScaleAnimation(resultBar, 0.0f, 1.0f, 1.0f, 1.0f);
    animation.setAnimationW(0, length);
    animation.setDuration(PLAY_DURATION);
    animation.setFillAfter(true);
    animation.setAnimationListener(new AnimationListener() {

      @Override
      public void onAnimationStart(Animation animation) {}

      @Override
      public void onAnimationRepeat(Animation animation) {}

      @Override
      public void onAnimationEnd(Animation animation) {
        // 在动画结束后将view的动画清除
        resultBar.clearAnimation();
      }
    });
    resultBar.setAnimation(animation);
    resultBar.getAnimation().startNow();
  }

  /**
   * 投票的进度条的颜色
   * 
   * @author SunQuan
   * 
   */
  public static enum VoteBarColor {

    // 红色
    COLOR_RED(R.drawable.result_red, R.drawable.result_color_red),
    // 蓝色
    COLOR_BLUE(R.drawable.result_blue, R.drawable.result_color_blue),
    // 黄色
    COLOR_YELLOW(R.drawable.result_yellow, R.drawable.result_color_yellow),
    // 深蓝
    COLOR_DARK_BLUE(R.drawable.result_dark_blue, R.drawable.result_color_dark_blue),
    // 绿色
    COLOR_GREEN(R.drawable.result_green, R.drawable.result_color_green);

    private int bollResId;
    private int colorResId;

    public int getBollResId() {
      return bollResId;
    }

    public int getColorResId() {
      return colorResId;
    }

    /**
     * 私有的构造方法
     */
    private VoteBarColor(int bollResId, int colorResId) {
      this.bollResId = bollResId;
      this.colorResId = colorResId;
    }
  }

}
