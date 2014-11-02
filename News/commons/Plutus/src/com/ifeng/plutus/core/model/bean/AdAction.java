package com.ifeng.plutus.core.model.bean;

import java.io.Serializable;

public class AdAction implements Serializable{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -6377004261524322706L;
	
	private String type = "";
	private String url = "";
	
	public String getType() {
		return type;
	}
	
	public String getUrl() {
		return url;
	}
}
