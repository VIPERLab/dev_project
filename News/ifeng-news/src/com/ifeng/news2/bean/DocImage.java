package com.ifeng.news2.bean;

import java.io.Serializable;

/** 
 * @author SunQuan: 
 * @version 创建时间：2013-10-14 下午4:34:08 
 * 类说明 
 */

public class DocImage implements Serializable{

	private static final long serialVersionUID = 7303675268976194304L;

	//图片地址
	private String url;
	
	//图片大小（宽，高）
	private DocSize size;
	
	public DocSize getSize() {
		return size;
	}
	public void setSize(DocSize size) {
		this.size = size;
	}
	public String getUrl() {
		return url;
	}
	public void setUrl(String url) {
		this.url = url;
	}	
	
}
