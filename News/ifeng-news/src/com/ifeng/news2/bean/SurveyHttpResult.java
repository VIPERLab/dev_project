package com.ifeng.news2.bean;

import java.io.Serializable;

/**
 * @author liu_xiaoliang
 * 调查服务器返回状态
 */
public class SurveyHttpResult implements Serializable {

  private static final long serialVersionUID = 4131417103676110200L;

  private int ifsuccess = -1;
  private String msg;
  private SurveyCallBackData data; 
  
  public int getIfsuccess() {
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
  public SurveyCallBackData getData() {
    return data;
  }
  public void setData(SurveyCallBackData data) {
    this.data = data;
  }
 
}
