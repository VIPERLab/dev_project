package com.ifeng.news2.sport_live.entity;

import java.io.Serializable;

/**
 * @author SunQuan:
 * @version 创建时间：2013-7-25 下午2:50:51 类说明
 */

public class ReportBody implements Serializable {

	private static final long serialVersionUID = -1402128937728483278L;

	//标题
	private String title;
	//跳转地址
	private String url;
	//跳转类型
	private String type;

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

}
