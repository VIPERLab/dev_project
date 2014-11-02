package com.ifeng.news2.bean;

import java.io.Serializable;

/**
 * 视频正文页
 * 
 * @author chenxi
 * 
 */
public class VideoDetailInfo implements Serializable {

  /**
	 * 
	 */
  private static final long serialVersionUID = -2305828119701783926L;


  private String GUID = "";
  private String videoSixeMid = "";
  private String imgURL = "";
  private String smallImgURL = "";
  private String audioURL = "";
  private String playTimes = ""; // 播放次数
  private String richText = "";
  private String videoURLLow = "";
  private String videoSixeLow = "";
  private String videoSixeHigh = "";
  private String videoPublishTime = ""; // 发布添加时间videoPublishTime
  private String shareURL = "";
  private String id = ""; // 视频ID
  private String statisticID = ""; // 视频父ID
  private String title = "";
  private String videoURLMid = "";
  private String videoLength = "";
  private String videoURLHigh = "";
  private String longTitle = "";
  private String largeImgURL = "";
  private String columnName = "";
  private String CP = "";
  private String collect = "";
  private String lastPlayedTime = "";// 上次播放的时间

  public String getGUID() {
    return GUID;
  }

  public void setGUID(String gUID) {
    GUID = gUID;
  }

  public String getVideoSixeMid() {
    return videoSixeMid;
  }

  public void setVideoSixeMid(String videoSixeMid) {
    this.videoSixeMid = videoSixeMid;
  }

  public String getImgURL() {
    return imgURL;
  }

  public void setImgURL(String imgURL) {
    this.imgURL = imgURL;
  }

  public String getSmallImgURL() {
    return smallImgURL;
  }

  public void setSmallImgURL(String smallImgURL) {
    this.smallImgURL = smallImgURL;
  }

  public String getAudioURL() {
    return audioURL;
  }

  public void setAudioURL(String audioURL) {
    this.audioURL = audioURL;
  }

  public String getPlayTimes() {
    return playTimes;
  }

  public void setPlayTimes(String playTimes) {
    this.playTimes = playTimes;
  }

  public String getRichText() {
    return richText;
  }

  public void setRichText(String richText) {
    this.richText = richText;
  }

  public String getVideoURLLow() {
    return videoURLLow;
  }

  public void setVideoURLLow(String videoURLLow) {
    this.videoURLLow = videoURLLow;
  }

  public String getVideoSixeLow() {
    return videoSixeLow;
  }

  public void setVideoSixeLow(String videoSixeLow) {
    this.videoSixeLow = videoSixeLow;
  }

  public String getVideoSixeHigh() {
    return videoSixeHigh;
  }

  public void setVideoSixeHigh(String videoSixeHigh) {
    this.videoSixeHigh = videoSixeHigh;
  }

  public String getVideoPublishTime() {
    return videoPublishTime;
  }

  public void setVideoPublishTime(String videoPublishTime) {
    this.videoPublishTime = videoPublishTime;
  }

  public String getShareURL() {
    return shareURL;
  }

  public void setShareURL(String shareURL) {
    this.shareURL = shareURL;
  }

  public String getId() {
    return id;
  }

  public void setId(String id) {
    this.id = id;
  }

  public String getStatisticID() {
    return statisticID;
  }

  public void setStatisticID(String statisticID) {
    this.statisticID = statisticID;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getVideoURLMid() {
    return videoURLMid;
  }

  public void setVideoURLMid(String videoURLMid) {
    this.videoURLMid = videoURLMid;
  }

  public String getVideoLength() {
    return videoLength;
  }

  public void setVideoLength(String videoLength) {
    this.videoLength = videoLength;
  }

  public String getVideoURLHigh() {
    return videoURLHigh;
  }

  public void setVideoURLHigh(String videoURLHigh) {
    this.videoURLHigh = videoURLHigh;
  }

  public String getLongTitle() {
    return longTitle;
  }

  public void setLongTitle(String longTitle) {
    this.longTitle = longTitle;
  }

  public String getLargeImgURL() {
    return largeImgURL;
  }

  public void setLargeImgURL(String largeImgURL) {
    this.largeImgURL = largeImgURL;
  }

  public String getColumnName() {
    return columnName;
  }

  public void setColumnName(String columnName) {
    this.columnName = columnName;
  }

  public String getCP() {
    return CP;
  }

  public void setCP(String cP) {
    CP = cP;
  }

  public String getCollect() {
    return collect;
  }

  public void setCollect(String collect) {
    this.collect = collect;
  }

  public String getLastPlayedTime() {
    return lastPlayedTime;
  }

  public void setLastPlayedTime(String lastPlayedTime) {
    this.lastPlayedTime = lastPlayedTime;
  }


}
