package com.ifeng.news2.plot_module;

import android.content.Context;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.util.AttributeSet;
import android.view.View;
import android.widget.TextView;
import com.ifeng.news2.R;

/**
 * @author liu_xiaoliang
 * 结语模块
 */
public class PlotEpilogueModule extends PlotBaseModule {

  public PlotEpilogueModule(Context context) {
    super(context);
  }

  public PlotEpilogueModule(Context context, AttributeSet attrs) {
    super(context, attrs);
  }
  
  @Override
  public void buildModule() {
    super.buildModule();
    //结语
    View epliogueView = inflater.inflate(R.layout.plot_epilogue_layout, null);
    TextView epliogueIcon = (TextView)epliogueView.findViewById(R.id.plot_epilogue_icon);
    TextView cotentView = (TextView)epliogueView.findViewById(R.id.plot_epilogue_content);
    TextView authorView = (TextView)epliogueView.findViewById(R.id.plot_epilogue_author);
    
    if (!TextUtils.isEmpty(plotTopicBody.getIntro())) {
      /*
       * 此处结语只是占位，实际显示的是布局中小字体结语
       * */
      SpannableString msp = new SpannableString("结语:"+plotTopicBody.getIntro().toString()); 
      msp.setSpan(new ForegroundColorSpan(0x00000000), 0, 3, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE); 
      cotentView.setText(msp);
      epliogueIcon.setVisibility(View.VISIBLE);
    }
    
    if (TextUtils.isEmpty(plotTopicBody.getAuthor())) {
      authorView.setVisibility(View.GONE);
    } else {
      authorView.setVisibility(View.VISIBLE);
      authorView.setText(plotTopicBody.getAuthor());
    }
    
    addView(epliogueView);
  }
}
