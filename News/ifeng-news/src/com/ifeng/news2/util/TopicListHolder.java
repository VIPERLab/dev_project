package com.ifeng.news2.util;

import com.ifeng.news2.R;
import com.ifeng.news2.activity.TopicDetailModuleActivity;
import com.ifeng.news2.widget.DividerLine;

import android.widget.TextView;

import com.ifeng.news2.R.id;

import com.ifeng.news2.util.ListDisplayStypeUtil.ChannelViewHolder;

import android.view.View;

/**
 * @author liu_xiaoliang
 * 列表holder 在TopicDetailModuleActivity 中将 view = list的数据进行重组 list中的每一项作为一个新的视图 
 */
public class TopicListHolder implements TopicDetailViewHolder {

  private View listItem;
  private View leftModule;
  private TextView leftModuleTitle;
  private ChannelViewHolder channelViewHolder;
  
  @Override
  public void createView(View view) {
    leftModule = view.findViewById(id.topic_item_left_module);
    leftModuleTitle = (TextView)leftModule.findViewById(id.title);
    listItem = view.findViewById(id.topic_lists_item);
    channelViewHolder = ChannelViewHolder.create(listItem);
    DividerLine line = (DividerLine)view.findViewById(id.channelDivider);
    if (TopicDetailModuleActivity.STYLE.equals("normal")) {
      line.setNormalDivider(false);
      leftModuleTitle.setTextColor(view.getContext().getResources().getColor(R.color.title_color));
    } else {
      line.setNormalDivider(true);
      leftModuleTitle.setTextColor(view.getContext().getResources().getColor(R.color.topic_slider_inactive_color));
    }
  }

  public View getLeftModule() {
    return leftModule;
  }

  public void setLeftModule(View leftModule) {
    this.leftModule = leftModule;
  }

  public TextView getLeftModuleTitle() {
    return leftModuleTitle;
  }

  public void setLeftModuleTitle(TextView leftModuleTitle) {
    this.leftModuleTitle = leftModuleTitle;
  }

  public ChannelViewHolder getChannelViewHolder() {
    return channelViewHolder;
  }

  public void setChannelViewHolder(ChannelViewHolder channelViewHolder) {
    this.channelViewHolder = channelViewHolder;
  }

  public View getListItem() {
    return listItem;
  }

  public void setListItem(View listItem) {
    this.listItem = listItem;
  }
  
}
