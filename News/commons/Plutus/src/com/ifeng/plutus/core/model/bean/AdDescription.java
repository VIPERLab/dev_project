package com.ifeng.plutus.core.model.bean;

import java.io.Serializable;

public class AdDescription implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 2083122170400865370L;
	
	private String type = "";
	private String style = "";
	private String interval = "";
	private String direct = "";
	private String expireTime = "";
	
	public String getType() {
		return type;
	}
	
	public String getStyle() {
		return style;
	}
	
	public String getInterval() {
		return interval;
	}
	
	public String getDirect() {
		return direct;
	}

	public String getExpireTime() {
		return expireTime;
	}
}
