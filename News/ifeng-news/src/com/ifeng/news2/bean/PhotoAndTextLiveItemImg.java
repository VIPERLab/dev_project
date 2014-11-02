package com.ifeng.news2.bean;

import java.io.Serializable;

/** 
 * @author SunQuan: 
 * @version 创建时间：2013-8-22 下午1:38:44 
 * 类说明 
 */

public class PhotoAndTextLiveItemImg implements Serializable{

	private static final long serialVersionUID = -4425040638588715347L;

	//缩略图片地址
	private String thumb_url = "";
	
	//缩略图片高度
	private String thumb_height = "0";
	
	//原图地址
	private String original_url = "";

	public String getOriginal_url() {
		return original_url;
	}

	public void setOriginal_url(String original_url) {
		this.original_url = original_url;
	}

	public String getThumb_url() {
		return thumb_url;
	}

	public void setThumb_url(String thumb_url) {
		this.thumb_url = thumb_url;
	}

	public String getThumb_height() {
		return thumb_height;
	}

	public void setThumb_height(String thumb_height) {
		this.thumb_height = thumb_height;
	}
	
	
}

