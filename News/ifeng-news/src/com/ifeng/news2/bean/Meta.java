package com.ifeng.news2.bean;

import java.io.Serializable;

import com.ifeng.news2.util.FilterUtil;

public class Meta implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -602556175249919321L;

	private String id="";
	private String type="";
	private String documentId="";
	//liuxiaoliang add for splashpictrue begin
	private String expiredTime="";
	
	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getDocumentId() {
//		return FilterUtil.filterDocumentId(documentId);
		return documentId;
		
	}

	public void setDocumentId(String documentId) {
		this.documentId=documentId;
	}
	
	public String getExpiredTime() {
		return expiredTime;
	}

	public void setExpiredTime(String expiredTime) {
		this.expiredTime = expiredTime;
	}
	
	@Override
	public boolean equals(Object o) {
		if(o==null || !(o instanceof Meta)) return false;
		Meta other=(Meta) o;
		return other.id.equals(id) && other.type.equals(type) && other.documentId.equals(documentId) && other.documentId.equals(expiredTime);
	}
	
	@Override
	public int hashCode() {
		return id.hashCode()<<1+type.hashCode()<<2+documentId.hashCode()<<3+expiredTime.hashCode();
	}
	//liuxiaoliang add for splashpictrue end
}
