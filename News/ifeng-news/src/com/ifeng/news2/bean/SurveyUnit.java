package com.ifeng.news2.bean;

import java.io.Serializable;

/**
 * @author liu_xiaoliang
 * 调查bean  
 * 注：如果字段没有说明，代表接口没有标注
 */
public class SurveyUnit implements Serializable {

  private static final long serialVersionUID = 4697660975213903412L;
  /**
   * 接口访问是否成功
   */
  private int ifsuccess;
  private String msg;
  private SurveyData data;
  
   
  public int getIfsuccess() {
    if (0 == ifsuccess) {
      ifsuccess = -1;
    }
    return ifsuccess;
  }
  public void setIfsuccess(int ifsuccess) {
    this.ifsuccess = ifsuccess;
  }
  public String getMsg() {
    return msg;
  }
  public void setMsg(String msg) {
    this.msg = msg;
  }
  public SurveyData getData() {
    return data;
  }
  public void setData(SurveyData data) {
    this.data = data;
  }
  public void formatAllPnum(){
    if (data == null || data.getResult() == null) {
      return;
    }
    for (SurveyResult surveyResult : data.getResult()) {
      if (null == surveyResult) {
        continue;
      }
      surveyResult.formatPnum();
    }
  }
}
