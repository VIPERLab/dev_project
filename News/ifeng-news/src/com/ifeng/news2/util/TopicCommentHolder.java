package com.ifeng.news2.util;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import com.ifeng.news2.R;
import com.ifeng.news2.R.id;

/**
 * @author liu_xiaoliang
 * 
 */
public class TopicCommentHolder implements TopicDetailViewHolder {
  
  View seeMoreView, leftModule;
  ImageView userIcon;
  TextView ipFrom, commentContent;
  
  @Override
  public void createView(View view) {
    
    leftModule = view.findViewById(R.id.topic_comment_left_module);
    ((TextView)leftModule.findViewById(R.id.title)).setText("跟帖");
    
    View commentView = view.findViewById(R.id.comment_list_item);
    
    userIcon = (ImageView) commentView.findViewById(id.userIcon);
    ipFrom = (TextView) commentView.findViewById(id.ip_from);
    commentContent = (TextView) commentView.findViewById(id.comment_content);
    commentView.findViewById(id.uptimes).setVisibility(View.GONE);
    commentView.findViewById(id.uptimes_icon).setVisibility(View.GONE);
    
    seeMoreView = view.findViewById(R.id.topic_comment_see_more_but);
  }
  public View getSeeMoreView() {
    return seeMoreView;
  }
  public void setSeeMoreView(View seeMoreView) {
    this.seeMoreView = seeMoreView;
  }
  public ImageView getUserIcon() {
    return userIcon;
  }
  public void setUserIcon(ImageView userIcon) {
    this.userIcon = userIcon;
  }
  public TextView getIpFrom() {
    return ipFrom;
  }
  public void setIpFrom(TextView ipFrom) {
    this.ipFrom = ipFrom;
  }
  public TextView getCommentContent() {
    return commentContent;
  }
  public void setCommentContent(TextView commentContent) {
    this.commentContent = commentContent;
  }
  public View getLeftModule() {
    return leftModule;
  }
  public void setLeftModule(View leftModule) {
    this.leftModule = leftModule;
  }
  
}
