package com.ifeng.plutus.core.model.bean;

import java.io.Serializable;

public class AdResource implements Serializable{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -7127582927845878832L;
	
	private String type = "";
	private String url = "";
	
	public String getType() {
		return type;
	}
	
	public String getUrl() {
		return url;
	}
}
