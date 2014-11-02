package com.ifeng.news2.bean;

import java.io.Serializable;

/**
 * @author SunQuan:
 * @version 创建时间：2013-10-14 下午5:27:48 类说明
 */

public class DocSize implements Serializable{

	private static final long serialVersionUID = 4403535847527394624L;
	// 图片宽
	private String width;
	// 图片高
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
