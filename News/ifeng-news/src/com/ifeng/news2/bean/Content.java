package com.ifeng.news2.bean;

import java.io.Serializable;

import android.text.TextUtils;

public class Content implements Serializable {

  private static final long serialVersionUID = 8809922629933215862L;

  /**
   * 被评论id
   */
  private String wwwUrl = "";
  /**
   * 评论题目
   */
  private String title = "";

  /**
   * 分享Url
   */
  private String shareurl = "";
  
  /**
   * 专题类型
   */
  private String style = "";

  public String getWwwUrl() {
    return wwwUrl;
  }

  public void setWwwUrl(String wwwUrl) {
    if (TextUtils.isEmpty(wwwUrl)) {
      wwwUrl = "";
    }
    this.wwwUrl = wwwUrl;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getShareurl() {
    return shareurl;
  }

  public void setShareurl(String shareurl) {
    this.shareurl = shareurl;
  }

  public String getStyle() {
    if (TextUtils.isEmpty(style)) {
      style = "normal";
    }
    return style;
  }

  public void setStyle(String style) {
    this.style = style;
  }
}
