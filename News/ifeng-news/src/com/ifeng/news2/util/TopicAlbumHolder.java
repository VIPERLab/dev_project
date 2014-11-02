package com.ifeng.news2.util;

import com.ifeng.news2.widget.DividerLine;

import com.ifeng.news2.activity.TopicDetailModuleActivity;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import com.ifeng.news2.R;
import com.ifeng.news2.R.id;
import com.ifeng.news2.widget.TopicAlbumImageView;

/**
 * @author liu_xiaoliang
 * 重构的Album布局
 */
public class TopicAlbumHolder implements TopicDetailViewHolder {
 
  private View leftLayout, rightLayout, topicItemLeftModule;
  private TextView leftTitleView, rightTitleView, leftModuleTitle;
  private ImageView leftVideoView, rightVideoView;
  private TopicAlbumImageView leftImageView, rightImageView;
  
  @Override
  public void createView(View view) {
    
    leftLayout = view.findViewById(R.id.left_layout);
    
    leftImageView= (TopicAlbumImageView)view.findViewById(R.id.left_image);
    leftTitleView= (TextView)view.findViewById(id.left_title);
    leftVideoView = (ImageView)view.findViewById(R.id.left_video);

    
    rightLayout = view.findViewById(R.id.right_layout);

    rightImageView= (TopicAlbumImageView)view.findViewById(R.id.right_image);
    rightTitleView= (TextView)view.findViewById(id.right_title);
    rightVideoView = (ImageView)view.findViewById(R.id.right_video);
    
    topicItemLeftModule = view.findViewById(R.id.topic_album_left_module);
    leftModuleTitle = (TextView)topicItemLeftModule.findViewById(R.id.title);
    DividerLine line = (DividerLine)view.findViewById(id.channelDivider);
    if (TopicDetailModuleActivity.STYLE.equals("normal")) {
      line.setNormalDivider(false);
      leftModuleTitle.setTextColor(view.getContext().getResources().getColor(R.color.title_color));
    } else {
      line.setNormalDivider(true);
      leftModuleTitle.setTextColor(view.getContext().getResources().getColor(R.color.topic_slider_inactive_color));
    }
    
  }

  public TextView getLeftTitleView() {
    return leftTitleView;
  }

  public void setLeftTitleView(TextView leftTitleView) {
    this.leftTitleView = leftTitleView;
  }

  public TextView getRightTitleView() {
    return rightTitleView;
  }

  public void setRightTitleView(TextView rightTitleView) {
    this.rightTitleView = rightTitleView;
  }

  public ImageView getLeftVideoView() {
    return leftVideoView;
  }

  public void setLeftVideoView(ImageView leftVideoView) {
    this.leftVideoView = leftVideoView;
  }

  public ImageView getRightVideoView() {
    return rightVideoView;
  }

  public void setRightVideoView(ImageView rightVideoView) {
    this.rightVideoView = rightVideoView;
  }

  public TopicAlbumImageView getLeftImageView() {
    return leftImageView;
  }

  public void setLeftImageView(TopicAlbumImageView leftImageView) {
    this.leftImageView = leftImageView;
  }

  public TopicAlbumImageView getRightImageView() {
    return rightImageView;
  }

  public void setRightImageView(TopicAlbumImageView rightImageView) {
    this.rightImageView = rightImageView;
  }

  public View getRightLayout() {
    return rightLayout;
  }

  public void setRightLayout(View rightLayout) {
    this.rightLayout = rightLayout;
  }

  public View getLeftLayout() {
    return leftLayout;
  }

  public void setLeftLayout(View leftLayout) {
    this.leftLayout = leftLayout;
  }

  public View getTopicItemLeftModule() {
    return topicItemLeftModule;
  }

  public void setTopicItemLeftModule(View topicItemLeftModule) {
    this.topicItemLeftModule = topicItemLeftModule;
  }

  public TextView getLeftModuleTitle() {
    return leftModuleTitle;
  }

  public void setLeftModuleTitle(TextView leftModuleTitle) {
    this.leftModuleTitle = leftModuleTitle;
  }
}
