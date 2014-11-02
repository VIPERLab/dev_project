package com.ifeng.news2.bean;

import java.util.ArrayList;

import java.io.Serializable;

/**
 * @author liu_xiaoliang
 *
 */
public class SurveyInfo implements Serializable {

  private static final long serialVersionUID = -1675614848246889643L;

  
  private String id;
  private String leadtxt;
  private String pnum;
  private String votecount;
  private String channelid;
  private String createtime;
  /**
   * 调查标题
   */
  private String title;
  private String author;
  private String starttime;
  private String endtime;
  /**
   * 调查标题后面的新闻背景
   */
  private String url;
  /**
   * 是否过期  V4.1.1 使用到
   */
  private String isactive;
  private String currenttime;
  private Dicts dicts;
  private ArrayList<String> questionids;
  
  
  public String getId() {
    return id;
  }
  public void setId(String id) {
    this.id = id;
  }
  public String getLeadtxt() {
    return leadtxt;
  }
  public void setLeadtxt(String leadtxt) {
    this.leadtxt = leadtxt;
  }
  public String getPnum() {
    return pnum;
  }
  public void setPnum(String pnum) {
    this.pnum = pnum;
  }
  public String getVotecount() {
    return votecount;
  }
  public void setVotecount(String votecount) {
    this.votecount = votecount;
  }
  public String getChannelid() {
    return channelid;
  }
  public void setChannelid(String channelid) {
    this.channelid = channelid;
  }
  public String getCreatetime() {
    return createtime;
  }
  public void setCreatetime(String createtime) {
    this.createtime = createtime;
  }
  public String getTitle() {
    return title;
  }
  public void setTitle(String title) {
    this.title = title;
  }
  public String getAuthor() {
    return author;
  }
  public void setAuthor(String author) {
    this.author = author;
  }
  public String getStarttime() {
    return starttime;
  }
  public void setStarttime(String starttime) {
    this.starttime = starttime;
  }
  public String getEndtime() {
    return endtime;
  }
  public void setEndtime(String endtime) {
    this.endtime = endtime;
  }
  public String getUrl() {
    return url;
  }
  public void setUrl(String url) {
    this.url = url;
  }
  public String getIsactive() {
    return isactive;
  }
  public void setIsactive(String isactive) {
    this.isactive = isactive;
  }
  public String getCurrenttime() {
    return currenttime;
  }
  public void setCurrenttime(String currenttime) {
    this.currenttime = currenttime;
  }
  public Dicts getDicts() {
    return dicts;
  }
  public void setDicts(Dicts dicts) {
    this.dicts = dicts;
  }
  public ArrayList<String> getQuestionids() {
    return questionids;
  }
  public void setQuestionids(ArrayList<String> questionids) {
    this.questionids = questionids;
  }
}
