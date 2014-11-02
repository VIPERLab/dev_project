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
 * 正文模块
 */
public class PlotTextModule extends PlotBaseModule {

  public PlotTextModule(Context context) {
    super(context);
  }

  public PlotTextModule(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  @Override
  public void buildModule() {
    super.buildModule();
    //正文
    if (TextUtils.isEmpty(plotTopicBody.getIntro())) 
      return;

    View plotTextView = inflater.inflate(R.layout.plot_text_layout, null);
    TextView tv = (TextView)plotTextView.findViewById(R.id.plot_text);

    String icon = "<img src=\"doc\">";
    tv.setText(Html.fromHtml(icon+plotTopicBody.getIntro(), imgGetter, null));

    addView(plotTextView);
  }

  ImageGetter imgGetter = new Html.ImageGetter() { 
    public Drawable getDrawable(String source) {  
      Drawable drawable = null;
      /*
       * 正文左空格设置 只是占位置 
       * */
      if ("doc".equals(source)) {
        drawable = getResources().getDrawable(R.drawable.plot_doc_title_icon_tag);
        drawable.setAlpha(0x000000);
      } else {
        //TODO 正文插入图片  
      }
      if (null != drawable) {
        drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight()); 
      }
      return drawable;   
    }  
  };  
  
  
}
