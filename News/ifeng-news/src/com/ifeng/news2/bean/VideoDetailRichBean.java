package com.ifeng.news2.bean;

import java.io.Serializable;

/**
 * 视频正文页描述信息
 * @author chenxi
 *
 */
public class VideoDetailRichBean implements Serializable{

  /**
   * 
   */
  private static final long serialVersionUID = -6108130728991946199L;
  
  private String richText = ""; 
  private String imgUrl = "";
  private String richType ="";
  
  public String getRichType() {
    return richType;
  }
  public void setRichType(String richType) {
    this.richType = richType;
  }
  public String getRichText() {
    return richText;
  }
  public void setRichText(String richText) {
    this.richText = richText;
  }
  public String getImgUrl() {
    return imgUrl;
  }
  public void setImgUrl(String imgUrl) {
    this.imgUrl = imgUrl;
  }
  
  

}
