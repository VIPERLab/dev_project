package com.ifeng.news2.util;

import android.view.View;
import android.widget.LinearLayout;

/**
 * @author liu_xiaoliang
 * 
 */
public class TopicDefaultHolder implements TopicDetailViewHolder {

  private LinearLayout view;
  
  @Override
  public void createView(View view) {
    this.view = (LinearLayout)view;
  }

  public LinearLayout getView() {
    return view;
  }

  public void setView(LinearLayout view) {
    this.view = view;
  }
  
}
