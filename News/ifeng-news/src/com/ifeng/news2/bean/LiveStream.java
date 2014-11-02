package com.ifeng.news2.bean;

import java.io.Serializable;

public class LiveStream implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = -7564058966713832348L;
	private String title;
	private String android;
	private String thumbnail ;
	private String duration  ;
	private ThumbnailSize thumbnailSize;
	/**
	 * @return the title
	 */
	public String getTitle() {
		return title;
	}
	/**
	 * @param title the title to set
	 */
	public void setTitle(String title) {
		this.title = title;
	}
	/**
	 * @return the android
	 */
	public String getAndroid() {
		return android;
	}
	/**
	 * @param android the android to set
	 */
	public void setAndroid(String android) {
		this.android = android;
	}
	/**
	 * @return the thumbnail
	 */
	public String getThumbnail() {
		return thumbnail;
	}
	/**
	 * @param thumbnail the thumbnail to set
	 */
	public void setThumbnail(String thumbnail) {
		this.thumbnail = thumbnail;
	}
	/**
	 * @return the duration
	 */
	public String getDuration() {
		return duration;
	}
	/**
	 * @param duration the duration to set
	 */
	public void setDuration(String duration) {
		this.duration = duration;
	}
	/**
	 * @return the thumbnailSize
	 */
	public ThumbnailSize getThumbnailSize() {
		return thumbnailSize;
	}
	/**
	 * @param thumbnailSize the thumbnailSize to set
	 */
	public void setThumbnailSize(ThumbnailSize thumbnailSize) {
		this.thumbnailSize = thumbnailSize;
	}
	
	
	
}
