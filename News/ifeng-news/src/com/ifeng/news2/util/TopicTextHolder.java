package com.ifeng.news2.util;

import android.widget.TextView;
import com.ifeng.news2.R;

import android.view.View;

/**
 * @author liu_xiaoliang
 * 摘要viewholder
 */
public class TopicTextHolder implements TopicDetailViewHolder {

  private TextView textView;
  private TextView commentNum;

  @Override
  public void createView(View view) {
    textView = (TextView)view.findViewById(R.id.introduction);
    commentNum = (TextView)view.findViewById(R.id.comment_num);
    
  }

  public TextView getTextView() {
    return textView;
  }

  public void setTextView(TextView textView) {
    this.textView = textView;
  }

  public TextView getCommentNum() {
    return commentNum;
  }

  public void setCommentNum(TextView commentNum) {
    this.commentNum = commentNum;
  }

}
