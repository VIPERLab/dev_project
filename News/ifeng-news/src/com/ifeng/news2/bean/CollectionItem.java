package com.ifeng.news2.bean;

import java.io.Serializable;

public class CollectionItem implements Serializable{

	private static final long serialVersionUID = 2254637156540959341L;
	private String key;
	private DocUnit docUnit;
	
	public String getKey() {
		return key;
	}
	public void setKey(String key) {
		this.key = key;
	}
	public DocUnit getDocUnit() {
		return docUnit;
	}
	public void setDocUnit(DocUnit docUnit) {
		this.docUnit = docUnit;
	}
	
}
