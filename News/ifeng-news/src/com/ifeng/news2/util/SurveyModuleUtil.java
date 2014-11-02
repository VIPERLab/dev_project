package com.ifeng.news2.util;

import android.app.Activity;
import android.content.Context;
import android.graphics.Paint;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.RelativeSizeSpan;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;

/**
 * @author liu_xiaoliang
 *
 */
public class SurveyModuleUtil {

  private int resultProgressH;        //横条高度
  private int resultProgressFullW;    //横条100%时的宽度

  private Context context;
  private LayoutInflater inflater;
  private FunctionButtonWindow functionButtonWindow;

  public SurveyModuleUtil(Context context) {
    this.context = context;
    init();
  }

  private void init() {
    inflater = LayoutInflater.from(context);
    functionButtonWindow = new FunctionButtonWindow(context);

    DisplayMetrics display = new DisplayMetrics();
    ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(display);
    int screenW = display.widthPixels;
    int iconW = 0;//小圆标宽度
    int resulLeftMarginDp;//整个item居左屏幕边距距离
    int resultPercentageLeftMarginDp;//百分比居左进度条距离
    int resultPercentageTextSizeSp = 0;//百分比文字大小

    if (screenW > 640) {
      iconW = 32;
      resultProgressH = 8;
      resulLeftMarginDp = 25;
      resultPercentageTextSizeSp = 20;
      resultPercentageLeftMarginDp = 10;
    } else {
      iconW = 24;
      resultProgressH = 6;
      resulLeftMarginDp = 22;
      resultPercentageTextSizeSp = 19;
      resultPercentageLeftMarginDp = 8;
    }
    int leftMargin = IfengTextViewManager.dip2px(context, resulLeftMarginDp);
    int resultPercentageLeftMargin = IfengTextViewManager.dip2px(context, resultPercentageLeftMarginDp);
    Paint paint = new Paint();
    paint.setTextSize(IfengTextViewManager.dip2px(context, resultPercentageTextSizeSp));

    int resultPercentageW = (int) paint.measureText("888.8%");
    resultProgressFullW =
        (screenW - leftMargin) * 3 / 4 - iconW - resultPercentageW - resultPercentageLeftMargin;
  }

  public void setAutoWScaleAnimation(View view, int animationW){
    IfengAutoWScaleAnimation animation = new IfengAutoWScaleAnimation(view, 0, 1.0f, 1.0f, 1.0f);
    animation.setAnimationW(0, animationW);
    animation.setFillAfter(true);
    animation.setDuration(500);
    view.startAnimation(animation);
  }

  public SpannableString getPercentageStyleStr(String str){
    if (TextUtils.isEmpty(str)) {
      return null;
    }
    SpannableString span = new SpannableString(str + "%");
    span.setSpan(new RelativeSizeSpan(0.5f), str.length(),
      str.length() + 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
    return span;
  }

  public int getResultProgressH() {
    return resultProgressH;
  }

  public int getResultProgressFullW() {
    return resultProgressFullW;
  }

  public LayoutInflater getInflater() {
    return inflater;
  }

  public FunctionButtonWindow getFunctionButtonWindow() {
    return functionButtonWindow;
  }
}

