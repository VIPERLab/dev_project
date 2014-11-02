package com.ifeng.news2.bean;

import java.io.Serializable;

import android.util.Log;

public class Relation implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String id = "";
	private String title = "";
	private String type = "";
	private String url = "";
	//用于相关新闻现实图片
	private String src ="";
	public String getUrl() {
		Log.i("news", "relations url="+url);
		return url;
	}
	public void setUrl(String url) {
		this.url = url;
	}
	public String getType() {
		return type;
	}
	public String getSrc() {
		return src;
	}
	public void setSrc(String src) {
		this.src = src;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		Log.i("news", "relations id="+id);
		this.id = id;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		Log.i("news", "relations title="+title);
		this.title = title;
	}
	
}
