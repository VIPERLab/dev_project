package com.ifeng.news2.plot_module;

import com.ifeng.news2.util.ReadUtil;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.TextView;
import com.ifeng.news2.R;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.util.IntentUtil;
import java.util.ArrayList;

/**
 * @author liu_xiaoliang
 * 大标题
 */
public class PlotDocTitleModule extends PlotBaseModule {
  
  private View docTitleView;
  private TextView cotentView;
  private ArrayList<Extension> links;
  
  public PlotDocTitleModule(Context context) {
    super(context);
  }
  
  public PlotDocTitleModule(Context context, AttributeSet attrs) {
    super(context, attrs);
  }
  
  @Override
  public void buildModule() {
    super.buildModule();
    //大标题
    if (TextUtils.isEmpty(plotTopicBody.getTitle())) 
      return;
    
    docTitleView = inflater.inflate(R.layout.plot_doc_title_layout, null);
    cotentView = (TextView)docTitleView.findViewById(R.id.plot_doc_title);
    cotentView.setText(plotTopicBody.getTitle());
    
    links = plotTopicBody.getLinks();
    
    if (null == links || links.size() == 0/* || TextUtils.isEmpty(links.get(0).getUrl())*/) {
      //不带链接
      cotentView.setTextColor(0xff000000);
    } else {
      //带链接
      
      if (ReadUtil.isReaded(null == links.get(0) ? "空了" :links.get(0).getUrl()))
        cotentView.setTextColor(0xff868686);//读过
      else 
        cotentView.setTextColor(0xff2b5470);//未读过
      
      docTitleView.setOnClickListener(this);
    }
    
    addView(docTitleView);
  }
  
  @Override
  public void onClick(View arg0) {
    super.onClick(arg0);
    cotentView.setTextColor(0xff727272);
    
    if (null != links.get(0)) {
      ReadUtil.markReaded(links.get(0).getUrl());
    }
    
    for (int i = 0; i < links.size(); i++) {
      if (null != plotTopicBody.getLinks().get(i) && IntentUtil.startActivityByExtension(context, plotTopicBody.getLinks().get(i))) {
        break;
      }
    }
  }

}
