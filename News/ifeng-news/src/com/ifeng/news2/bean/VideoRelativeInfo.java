package com.ifeng.news2.bean;

import java.io.Serializable;

public class VideoRelativeInfo implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -3391985808594608222L;
	
	private String GUID ; 
	private String statisticID ; 
	private String id ; 
	private String title ; 
	private String longTitle ; 
	private String imgURL ; 
	private String videoURLHigh ; 
	private String videoURLMid ; 
	private String videoURLLow ; 
	private String videoLength ; 
	private String videoPublishTime ; 
	private String shareURL ; 
	private String playTimes ; 
	private String audioURL ; 
	private String videoSizeHigh ; 
	private String videoSizeMid ; 
	private String videoSizeLow ; 
	private String collect ; 
	private String columnName ;
	private String lastPlayedTime ; 
	private String CP ; 
	private String largeImgURL ; 
	private String smallImgURL ; 
	private String richText ;
	
	
	public String getGUID() {
		return GUID;
	}
	public void setGUID(String gUID) {
		GUID = gUID;
	}
	public String getStatisticID() {
		return statisticID;
	}
	public void setStatisticID(String statisticID) {
		this.statisticID = statisticID;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getTitle() {
		return StringUtil.getStr(title, 24);
	}
	public String getFullTitle(){
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getLongTitle() {
		return longTitle;
	}
	public void setLongTitle(String longTitle) {
		this.longTitle = longTitle;
	}
	public String getImgURL() {
		return imgURL;
	}
	public void setImgURL(String imgURL) {
		this.imgURL = imgURL;
	}
	public String getVideoURLHigh() {
		return videoURLHigh;
	}
	public void setVideoURLHigh(String videoURLHigh) {
		this.videoURLHigh = videoURLHigh;
	}
	public String getVideoURLMid() {
		return videoURLMid;
	}
	public void setVideoURLMid(String videoURLMid) {
		this.videoURLMid = videoURLMid;
	}
	public String getVideoURLLow() {
		return videoURLLow;
	}
	public void setVideoURLLow(String videoURLLow) {
		this.videoURLLow = videoURLLow;
	}
	public String getVideoLength() {
		return videoLength;
	}
	public void setVideoLength(String videoLength) {
		this.videoLength = videoLength;
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
	public String getPlayTimes() {
		return playTimes;
	}
	public void setPlayTimes(String playTimes) {
		this.playTimes = playTimes;
	}
	public String getAudioURL() {
		return audioURL;
	}
	public void setAudioURL(String audioURL) {
		this.audioURL = audioURL;
	}
	public String getVideoSizeHigh() {
		return videoSizeHigh;
	}
	public void setVideoSizeHigh(String videoSizeHigh) {
		this.videoSizeHigh = videoSizeHigh;
	}
	public String getVideoSizeMid() {
		return videoSizeMid;
	}
	public void setVideoSizeMid(String videoSizeMid) {
		this.videoSizeMid = videoSizeMid;
	}
	public String getVideoSizeLow() {
		return videoSizeLow;
	}
	public void setVideoSizeLow(String videoSizeLow) {
		this.videoSizeLow = videoSizeLow;
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
	public String getCP() {
		return CP;
	}
	public void setCP(String cP) {
		CP = cP;
	}
	public String getLargeImgURL() {
		return largeImgURL;
	}
	public void setLargeImgURL(String largeImgURL) {
		this.largeImgURL = largeImgURL;
	}
	public String getSmallImgURL() {
		return smallImgURL;
	}
	public void setSmallImgURL(String smallImgURL) {
		this.smallImgURL = smallImgURL;
	}
	public String getRichText() {
		return richText;
	}
	public void setRichText(String richText) {
		this.richText = richText;
	}
	public String getColumnName() {
		return columnName;
	}
	public void setColumnName(String columnName) {
		this.columnName = columnName;
	} 
	
	
	

}
