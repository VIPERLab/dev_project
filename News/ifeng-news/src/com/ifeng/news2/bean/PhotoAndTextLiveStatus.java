package com.ifeng.news2.bean;

import java.io.Serializable;

/**
 * 图文直播头部的状态信息
 * 
 * @author SunQuan:
 * @version 创建时间：2013-8-21 下午2:39:34 类说明
 */

public class PhotoAndTextLiveStatus implements Serializable{

	private static final long serialVersionUID = 175483773779702241L;
	
	//返回的状态码
	private String code;
	//返回的状态值
	private String value;

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

}
