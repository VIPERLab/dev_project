package com.ifeng.news2.bean;

import java.io.Serializable;

/** 
 * 图片的宽高，针对正文页图集定宽高显示增加该字段
 * 
 * @author SunQuan: 
 * @version 创建时间：2013-11-4 下午4:32:37 
 * 类说明 
 */

public class ThumbnailSize implements Serializable{

	private static final long serialVersionUID = 1966477084106638495L;
	private String width;
	private String height;
	public String getWidth() {
		return width;
	}
	public void setWidth(String width) {
		this.width = width;
	}
	public String getHeight() {
		return height;
	}
	public void setHeight(String height) {
		this.height = height;
	}
	
	
}
