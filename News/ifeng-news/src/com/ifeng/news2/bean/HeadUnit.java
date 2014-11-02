package com.ifeng.news2.bean;

import java.io.Serializable;

import com.ifeng.news2.util.FilterUtil;

public class HeadUnit implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 5962831534214371524L;
	private String title = "";
	private String introduction = "";
	private String wwwUrl = "";
	// @lxl, for accessing head data of topic unit
	private String documentId = "";
	//@lxl，add for comment
	private String commentType;
	private String commentsUrl;
	
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

	public String getDocumentId() {
		return FilterUtil.filterDocumentId(documentId);
	}

	public void setDocumentId(String documentId) {
		
		this.documentId = documentId;
	}
	public String getTitle() {
		return title;
	}
	
	public void setTitle(String title) {
		this.title = title;
	}
	
	public String getIntroductin() {
		return introduction;
	}
	
	public void setIntroductin(String introductin) {
		this.introduction = introductin;
	}

	public String getWwwUrl() {
		return wwwUrl;
	}

	public void setWwwUrl(String wwwUrl) {
		this.wwwUrl = wwwUrl;
	}
}
