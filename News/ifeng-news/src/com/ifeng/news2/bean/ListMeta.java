package com.ifeng.news2.bean;

import java.io.Serializable;

public class ListMeta extends Meta implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = -4453861601070603675L;
	
	private int pageSize=Integer.MAX_VALUE;
	private String documentId = null;
	private String id = null;

	public int getPageSize() {
		return pageSize;
	}

	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}

	/**
	 * @return the documentId
	 */
	public String getDocumentId() {
		return documentId;
	}

	/**
	 * @param documentId the documentId to set
	 */
	public void setDocumentId(String documentId) {
		this.documentId = documentId;
	}

	/**
	 * @return the id
	 */
	public String getId() {
		return id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(String id) {
		this.id = id;
	}

	
}
