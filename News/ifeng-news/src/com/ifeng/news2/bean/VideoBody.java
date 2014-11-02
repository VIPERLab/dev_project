package com.ifeng.news2.bean;

import java.io.Serializable;

public class VideoBody implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 9184825152568143361L;

	//视频截图
	private String thumbnail ;
	private String duration  ;
	private VideoElement video ;
	private ThumbnailSize thumbnailSize;
	
	public ThumbnailSize getThumbnailSize() {
		return thumbnailSize;
	}
	public void setThumbnailSize(ThumbnailSize thumbnailSize) {
		this.thumbnailSize = thumbnailSize;
	}
	public String getThumbnail() {
		return thumbnail;
	}
	public void setThumbnail(String thumbnail) {
		this.thumbnail = thumbnail;
	}
	public String getDuration() {
		return duration;
	}
	public void setDuration(String duration) {
		this.duration = duration;
	}
	public VideoElement getVideo() {
		return video;
	}
	public void setVideo(VideoElement video) {
		this.video = video;
	}
	
	
	
	
}
