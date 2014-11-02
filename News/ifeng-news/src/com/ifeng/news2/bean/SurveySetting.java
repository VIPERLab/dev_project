package com.ifeng.news2.bean;

import java.io.Serializable;

/**
 * @author liu_xiaoliang
 *
 */
public class SurveySetting implements Serializable {

  private static final long serialVersionUID = -6595181226624174198L;

  private String surid;
  private String period;
  private String expinfo;
  private String tags;
  private String titlelink;
  private String iswarn;
  private String ishidden;
  private String limitstatus;
  private String ticknum;
  private String userstatus;
  private String userinfo;
  /**
   * 是否让用户看到结果页
   */
  private String isshow;
  private String iscomment;
  private String finishinfo;
  private String isjump;
  private String jumplink;
  public String getSurid() {
    return surid;
  }
  public void setSurid(String surid) {
    this.surid = surid;
  }
  public String getPeriod() {
    return period;
  }
  public void setPeriod(String period) {
    this.period = period;
  }
  public String getExpinfo() {
    return expinfo;
  }
  public void setExpinfo(String expinfo) {
    this.expinfo = expinfo;
  }
  public String getTags() {
    return tags;
  }
  public void setTags(String tags) {
    this.tags = tags;
  }
  public String getTitlelink() {
    return titlelink;
  }
  public void setTitlelink(String titlelink) {
    this.titlelink = titlelink;
  }
  public String getIswarn() {
    return iswarn;
  }
  public void setIswarn(String iswarn) {
    this.iswarn = iswarn;
  }
  public String getIshidden() {
    return ishidden;
  }
  public void setIshidden(String ishidden) {
    this.ishidden = ishidden;
  }
  public String getLimitstatus() {
    return limitstatus;
  }
  public void setLimitstatus(String limitstatus) {
    this.limitstatus = limitstatus;
  }
  public String getTicknum() {
    return ticknum;
  }
  public void setTicknum(String ticknum) {
    this.ticknum = ticknum;
  }
  public String getUserstatus() {
    return userstatus;
  }
  public void setUserstatus(String userstatus) {
    this.userstatus = userstatus;
  }
  public String getUserinfo() {
    return userinfo;
  }
  public void setUserinfo(String userinfo) {
    this.userinfo = userinfo;
  }
  public String getIsshow() {
    return isshow;
  }
  public void setIsshow(String isshow) {
    this.isshow = isshow;
  }
  public String getIscomment() {
    return iscomment;
  }
  public void setIscomment(String iscomment) {
    this.iscomment = iscomment;
  }
  public String getFinishinfo() {
    return finishinfo;
  }
  public void setFinishinfo(String finishinfo) {
    this.finishinfo = finishinfo;
  }
  public String getIsjump() {
    return isjump;
  }
  public void setIsjump(String isjump) {
    this.isjump = isjump;
  }
  public String getJumplink() {
    return jumplink;
  }
  public void setJumplink(String jumplink) {
    this.jumplink = jumplink;
  }
}
