package com.ifeng.news2.util;

import android.widget.TextView;
import com.ifeng.news2.R;
import com.ifeng.news2.widget.TopicFocusImageView;

import android.view.View;

/**
 * @author liu_xiaoliang
 * // 整合标题、摘要、单焦点图
 */
public class TopicSuperTitleHolder implements TopicDetailViewHolder {

  private TopicFocusImageView image;
  private TextView title, sutTitle;
  
  @Override
  public void createView(View view) {
    image = (TopicFocusImageView)view.findViewById(R.id.module_focus_image);
    title = (TextView)view.findViewById(R.id.mutil_title);
    sutTitle = (TextView)view.findViewById(R.id.mutil_sub_title);
  }
  
  public TopicFocusImageView getImage() {
    return image;
  }
  public void setImage(TopicFocusImageView image) {
    this.image = image;
  }
  public TextView getTitle() {
    return title;
  }
  public void setTitle(TextView title) {
    this.title = title;
  }
  public TextView getSutTitle() {
    return sutTitle;
  }
  public void setSutTitle(TextView sutTitle) {
    this.sutTitle = sutTitle;
  }
}
