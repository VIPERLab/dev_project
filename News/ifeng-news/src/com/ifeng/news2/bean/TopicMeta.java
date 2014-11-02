package com.ifeng.news2.bean;

import java.io.Serializable;

public class TopicMeta implements Serializable{

	private static final long serialVersionUID = 1L;
	private String type="";//数据类型
	private long expireTime;//过期时间
	private String id="";//数据标识
	private String documentId="";//文档id
	private String catagory="";//文档类型
	private String updateTime="";//更新时间
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	
	public long getExpireTime() {
		return expireTime;
	}
	public void setExpireTime(long expireTime) {
		this.expireTime = expireTime;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getDocumentId() {
		return documentId;
	}
	public void setDocumentId(String documentId) {
		this.documentId = documentId;
	}
	public String getCatagory() {
		return catagory;
	}
	public void setCatagory(String catagory) {
		this.catagory = catagory;
	}
	public String getUpdateTime() {
		return updateTime;
	}
	public void setUpdateTime(String updateTime) {
		this.updateTime = updateTime;
	}
	
}
