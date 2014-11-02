package com.ifeng.news2.bean;

import java.io.Serializable;

public class SlideItem implements Serializable{
 
	private static final long serialVersionUID = -7377813905480156906L;
	private String description="";
	private String image="";
	private String title="";
	private String url="";
	private String wwwurl="";
	private String commentsUrl;
	private String shareurl="";
	private String documentId="";
	private String comments="";
	private String position;
	private boolean bound;//是否处于边界
	private String id;    //存储图集对应id

	//@lxl，add for comment
	private String commentType;

	public String getId() {
	  return id;
	}
	
	public void setId(String id) {
	  this.id = id;
	}

	public String getComments() {
		return comments;
	}

	public void setComments(String comments) {
		this.comments = comments;
	}

	public String getCommentsUrl() {
		return commentsUrl;
	}

	public void setCommentsUrl(String commentsUrl) {
		this.commentsUrl = commentsUrl;
	}

	public String getCommentType() {
		return commentType;
	}

	public void setCommentType(String commentType) {
		this.commentType = commentType;
	}

	public String getWwwurl() {
		return wwwurl;
	}

	public void setWwwurl(String wwwurl) {
		this.wwwurl = wwwurl;
	}

	public boolean isBound() {
		return bound;
	}

	public void setBound(boolean bound) {
		this.bound = bound;
	}

	public void setPosition(String position) {
		this.position = position;
	}
	public String getPosition() {
		return position;
	}

	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getImage() {
		return image;
	}
	public void setImage(String image) {
		this.image = image;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getDocumentId() {
		return documentId;
	}

	public void setDocumentId(String documentId) {

		this.documentId = documentId;
	}

	public String getShareurl() {
		return shareurl;
	}

	public void setShareurl(String shareurl) {
		this.shareurl = shareurl;
	}

}
