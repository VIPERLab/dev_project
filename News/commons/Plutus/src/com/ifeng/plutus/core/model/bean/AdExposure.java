package com.ifeng.plutus.core.model.bean;

import java.io.Serializable;

public class AdExposure implements Serializable {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 2864459224110706316L;
	
	private String adId = "";
	private String startTime = "";
	private String endTime = "";
	private String value = "";
	
	public String getStartTime() {
		return startTime;
	}
	
	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}
	
	public String getEndTime() {
		return endTime;
	}
	
	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}
	
	public String getValue() {
		return value;
	}
	
	public void setValue(String value) {
		this.value = value;
	}
	
	public String getAdId() {
		return adId;
	}
	
	public void setAdId(String adId) {
		this.adId = adId;
	}
	
}
