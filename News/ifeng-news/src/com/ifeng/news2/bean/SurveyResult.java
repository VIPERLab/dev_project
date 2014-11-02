package com.ifeng.news2.bean;

import java.io.Serializable;
import java.text.DecimalFormat;
import java.util.ArrayList;

/**
 * @author liu_xiaoliang
 *
 */
public class SurveyResult implements Serializable {
 
  private static final long serialVersionUID = -2527329136653631794L;

  /**
   * 问题标题
   */
  private String question;
  /**
   * 问题id
   */
  private String questionid;
  /**
   * 单选or多选
   */
  private String choosetype;
  /**
   * 是否为必选项
   */
  private String ismust;
  /**
   * 用户是否选择
   */
  private boolean isChoice = true;
  /**
   * 用户选项
   */
  private ArrayList<String> userChoice = new ArrayList<String>();
  /**
   * 问题选项、每个选项参与的人数
   */
  private ArrayList<SurveyItem> resultArray = new ArrayList<SurveyItem>();
  
  
  public String getQuestion() {
    return question;
  }
  public void setQuestion(String question) {
    this.question = question;
  }
  public String getQuestionid() {
    return questionid;
  }
  public void setQuestionid(String questionid) {
    this.questionid = questionid;
  }
  public String getChoosetype() {
    return choosetype;
  }
  public void setChoosetype(String choosetype) {
    this.choosetype = choosetype;
  }
  public String getIsmust() {
    return ismust;
  }
  public void setIsmust(String ismust) {
    this.ismust = ismust;
  }
  public void addChoice(String id){
    userChoice.add("&sur["+getQuestionid()+"][]="+id);
  }
  public void removeChoice(String id){
    userChoice.remove("&sur["+getQuestionid()+"][]="+id);
  }
  public void removeAllChoice(){
    userChoice.clear();
  }
  
  public void formatPnum(){
    if (resultArray == null ) {
      return;
    }
    DecimalFormat decimalFormat = new DecimalFormat(".#");
    for (SurveyItem surveyItem : resultArray) {
      if (null == surveyItem) {
        continue;
      }
      try {
        surveyItem.setNump(""+Double.parseDouble(decimalFormat.format(Double.parseDouble(surveyItem.getNump()))));
      } catch (Exception e) {
        surveyItem.setNump("0.0");
      }
    }
  }
  
  public void resetResultArray(){
    if (null == resultArray) {
      return;
    }
    int totalCount = 0;
    for (SurveyItem surveyItem : resultArray) {
      if (null == surveyItem) {
        continue;
      }
      if (userChoice.contains("&sur["+getQuestionid()+"][]="+surveyItem.getItemid())) {
        surveyItem.setNum(surveyItem.getNum()+1);
      }
      totalCount += surveyItem.getNum();
    }
    DecimalFormat decimalFormat = new DecimalFormat(".#");
    for (SurveyItem surveyItem : resultArray) {
      if (null == surveyItem) {
        continue;
      }
      surveyItem.setNump(""+Double.parseDouble(decimalFormat.format((surveyItem.getNum()/(double)totalCount)*100)));
    }
    
  }
  
  public ArrayList<String> getUserChoice() {
    return userChoice;
  }
  public void setUserChoice(ArrayList<String> userChoice) {
    this.userChoice = userChoice;
  }
  public ArrayList<SurveyItem> getResultArray() {
    return resultArray;
  }
  public void setResultArray(ArrayList<SurveyItem> resultArray) {
    this.resultArray = resultArray;
  }
  public boolean isChoice() {
    return isChoice;
  }
  public void setChoice(boolean isChoice) {
    this.isChoice = isChoice;
  }
  public SurveyItem getResultHighestSurveyItem(){
    if (null == resultArray || resultArray.size() == 0) {
      return null;
    }
    SurveyItem  highest = new SurveyItem();
    highest.setNum(-1);
    for (SurveyItem surveyItem : resultArray) {  
        highest = surveyItem.getNum() > highest.getNum() ? surveyItem : highest;
    }  
    return highest;
  }
  
}
