package com.ifeng.news2.plutus.core.model.bean;

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
	private String closeForm = "";
	
	public String getCloseForm() {
		return closeForm;
	}

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
