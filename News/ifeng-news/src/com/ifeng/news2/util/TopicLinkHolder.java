package com.ifeng.news2.util;

import android.view.View;
import com.ifeng.news2.widget.IfengGridView;

/**
 * @author liu_xiaoliang
 * // 多链接
 */
public class TopicLinkHolder implements TopicDetailViewHolder {

  private IfengGridView linksView;
  @Override
  public void createView(View view) {
    linksView = (IfengGridView)view;
  }
  public IfengGridView getLinksView() {
    return linksView;
  }
  public void setLinksView(IfengGridView linksView) {
    this.linksView = linksView;
  }

  
}
