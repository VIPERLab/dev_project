package com.ifeng.news2.plot_module;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.Html;
import android.text.Html.ImageGetter;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.TextView;
import com.ifeng.news2.R;

/**
 * @author liu_xiaoliang
 * 导语模块
 */
public class PlotSummaryModule extends PlotBaseModule{


  public PlotSummaryModule(Context context) {
    super(context);
  }

  public PlotSummaryModule(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  @Override
  public void buildModule() {
    super.buildModule();
    //导语
    if (TextUtils.isEmpty(plotTopicBody.getIntro())) 
      return;
    /*
     * 插入导读图片
     * */
    String icon = "<img src=\"导读\">";
    View summeryView = inflater.inflate(R.layout.plot_summary_layout, null);
    TextView tv = (TextView)summeryView.findViewById(R.id.plot_summary);
    tv.setText(Html.fromHtml(icon+" "+plotTopicBody.getIntro(), imgGetter, null));
    addView(summeryView);
  }

  ImageGetter imgGetter = new Html.ImageGetter() {  
    public Drawable getDrawable(String source) {  
      Drawable drawable = getResources().getDrawable(R.drawable.plot_icon);
      drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight());  
      return drawable;   
    }  
  };  

}
