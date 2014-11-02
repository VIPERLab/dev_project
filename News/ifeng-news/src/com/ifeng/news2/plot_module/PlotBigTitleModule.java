package com.ifeng.news2.plot_module;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.TextView;
import com.ifeng.news2.R;

/**
 * @author liu_xiaoliang
 * 大标题
 */
public class PlotBigTitleModule extends PlotBaseModule {

  private TextView cotentView;
  public PlotBigTitleModule(Context context) {
    super(context);
  }
  
  public PlotBigTitleModule(Context context, AttributeSet attrs) {
    super(context, attrs);
  }
  
  @Override
  public void buildModule() {
    super.buildModule();
    //大标题
    if (TextUtils.isEmpty(plotTopicBody.getTitle())) 
      return;
    
    View bigTitleView = inflater.inflate(R.layout.plot_big_title_layout, null);
    cotentView = (TextView)bigTitleView.findViewById(R.id.plot_big_title);
    cotentView.setText(plotTopicBody.getTitle());
   
//    Log.e("tag", "px(10) to dip(?)  = "+ IfengTextViewManager.px2dip(getContext(), 10));
//    Log.e("tag", "px(10) to sp(?)  = "+ IfengTextViewManager.px2sp(getContext(), 10));
    addView(bigTitleView);
  }
  
}
