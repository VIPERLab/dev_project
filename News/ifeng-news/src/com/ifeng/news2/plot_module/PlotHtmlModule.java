package com.ifeng.news2.plot_module;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import com.ifeng.news2.plot_module.bean.PlotTopicBodyItem;
import com.ifeng.news2.plot_module.utils.PlotTopicHtmlParser;
import com.ifeng.news2.util.PlotModuleViewFactory;
import java.util.ArrayList;

/**
 * @author liu_xiaoliang
 * html 这里面解析html再拆分成大标题、文章标题、图说、图集、文章内容样式
 */
public class PlotHtmlModule extends PlotBaseModule {

  public PlotHtmlModule(Context context) {
    super(context);
  }

  public PlotHtmlModule(Context context, AttributeSet attrs) {
    super(context, attrs);
  }
  
  @Override
  public void buildModule() {
    super.buildModule();
    
    if (TextUtils.isEmpty(plotTopicBody.getContent())) 
      return;
    /*
     * 将html数据重新生成PlotTopicBodyItem数组便于重新组装
     * 
     * */
    ArrayList<PlotTopicBodyItem> plotTopicBodyItems= PlotTopicHtmlParser.parserHtml(plotTopicBody.getContent(), plotTopicBody.getThumbnail());
    
    if (null == plotTopicBodyItems || plotTopicBodyItems.size() == 0) 
      return;
    
    for (PlotTopicBodyItem plotTopicBodyItem : plotTopicBodyItems) {
      if (null == plotTopicBodyItem) 
        continue;
      addView(PlotModuleViewFactory.createView(context, plotTopicBodyItem));
    }
  }
}
