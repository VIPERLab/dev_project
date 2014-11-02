package com.ifeng.news2.bean;

import java.util.ArrayList;

import java.io.Serializable;

/**
 * @author liu_xiaoliang
 *
 */
public class SurveyData implements Serializable {

  private static final long serialVersionUID = 8595649502447465113L;

  private String count;
  
  /**
   * 调查信息
   */
  private SurveyInfo surveyinfo = new SurveyInfo();
  
  /**
   * 调查项配置项
   */
  private SurveySetting surveysetting = new SurveySetting();
  
  /**
   * 结果内容
   */
  private ArrayList<SurveyResult> result = new ArrayList<SurveyResult>();

  public String getCount() {
    return count;
  }

  public void setCount(String count) {
    this.count = count;
  }

  public SurveyInfo getSurveyinfo() {
    return surveyinfo;
  }

  public void setSurveyinfo(SurveyInfo surveyinfo) {
    this.surveyinfo = surveyinfo;
  }

  public SurveySetting getSurveysetting() {
    return surveysetting;
  }

  public void setSurveysetting(SurveySetting surveysetting) {
    this.surveysetting = surveysetting;
  }

  public ArrayList<SurveyResult> getResult() {
    return result;
  }

  public void setResult(ArrayList<SurveyResult> result) {
    this.result = result;
  }
  
  public SurveyItem getTopicHighestItem(){
    if (null == result) {
      return null;
    }
    SurveyItem  highest = new SurveyItem();
    highest.setNum(-1);
    for (int i = 0; i < result.size(); i++) {
      highest = result.get(i).getResultHighestSurveyItem().getNum() > highest.getNum() ? result.get(i).getResultHighestSurveyItem() : highest;
    }
     
    return highest;
  }
}
