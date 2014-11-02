package com.ifeng.news2.bean;

import android.text.TextUtils;

import java.io.Serializable;

/**
 * @author liu_xiaoliang
 *
 */
public class SurveyItem implements Serializable {

  private static final long serialVersionUID = -7601286307427423112L;

  /**
   * 选项item
   */
  private String title;
  /**
   * 选项参与人数
   */
  private int num;
  /**
   * 选项id
   */
  private String itemid;
  /**
   * 票数
   */
  private String nump;
  /**
   * 已阅（结果页用到）
   */
  private boolean isViewed;
  
  
  public String getTitle() {
    return title;
  }
  public void setTitle(String title) {
    this.title = title;
  }
  public int getNum() {
    return num;
  }
  public void setNum(int num) {
    this.num = num;
  }
  public String getItemid() {
    return itemid;
  }
  public void setItemid(String itemid) {
    this.itemid = itemid;
  }
  public String getNump() {
    return nump;
  }
  public void setNump(String nump) {
    if (TextUtils.isEmpty(nump)) {
      this.nump = "0.0";
    } else {
      this.nump = nump;
    }
  }
  public boolean isViewed() {
    return isViewed;
  }
  public void setViewed(boolean isViewed) {
    this.isViewed = isViewed;
  }
  
}
