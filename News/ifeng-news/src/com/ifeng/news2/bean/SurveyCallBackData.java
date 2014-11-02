package com.ifeng.news2.bean;

import java.io.Serializable;

public class SurveyCallBackData implements Serializable {

  private static final long serialVersionUID = -8498955255019389624L;

  private String status;
  private String info;
  public String getStatus() {
    return status;
  }
  public void setStatus(String status) {
    this.status = status;
  }
  public String getInfo() {
    return info;
  }
  public void setInfo(String info) {
    this.info = info;
  }
}
