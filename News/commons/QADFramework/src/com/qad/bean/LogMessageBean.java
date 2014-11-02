package com.qad.bean;

import android.text.TextUtils;


public class LogMessageBean {

	/**
	 * custom tag
	 */
	private String tag;
	/**
	 * occurrence location
	 */
	private String position;
	/**
	 * request url
	 */
	private String url;
	/**
	 * error message
	 */
	private String msg;
	
	public LogMessageBean() {}
	
	public String getTag() {
		if (TextUtils.isEmpty(tag)) 
			tag = "DefaultTag";
		return tag;
	}
	public LogMessageBean setTag(String tag) {
		this.tag = tag;
		return this;
	}
	public String getPosition() {
		return position;
	}
	public LogMessageBean setPosition(String position) {
		this.position = position;
		return this;
	}
	public String getUrl() {
		return url;
	}
	public LogMessageBean setUrl(String url) {
		this.url = url;
		return this;
	}
	public String getMsg() {
		return msg;
	}
	public LogMessageBean setMsg(String msg) {
		this.msg = msg;
		return this;
	}
	
}
