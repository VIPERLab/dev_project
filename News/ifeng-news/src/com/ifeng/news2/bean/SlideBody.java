package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

public class SlideBody implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = -4143140033829625412L;
	private String url = "";
	private String wwwurl = "";
	private String source = "";
	private String shareurl="";
	private String title = "";
	private String thumbnail="";
	private String documentId="";
	private String comments = "0";
	private String commentsUrl="";
	private ArrayList<SlideItem> slides = new ArrayList<SlideItem>();
	
	public String getCommentsUrl() {
		return commentsUrl;
	}

	public void setCommentsUrl(String commentsUrl) {
		this.commentsUrl = commentsUrl;
	}

	public String getComments() {
		return comments;
	}

	public void setComments(String comments) {
		this.comments = comments;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getWwwurl() {
		return wwwurl;
	}

	public void setWwwurl(String wwwurl) {
		this.wwwurl = wwwurl;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}
	
	public String getThumbnail() {
		return thumbnail;
	}
	
	public void setThumbnail(String thumbnail) {
		this.thumbnail = thumbnail;
	}

	public ArrayList<SlideItem> getSlides() {
		return slides;
	}

	public void setSlides(ArrayList<SlideItem> slides) {
		this.slides = slides;
	}

	public String getShareurl() {
		return shareurl;
	}

	public void setShareurl(String shareurl) {
		this.shareurl = shareurl;
	}

	public String getDocumentId() {
		return documentId;
	}

	public void setDocumentId(String documentId) {
		this.documentId = documentId;
	}
	
}
