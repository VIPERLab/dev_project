package com.ifeng.news2.bean;

import java.io.Serializable;
/**
 * 专题Head信息
 * @author PJW
 *
 */
public class TopicHead implements Serializable{
	private static final long serialVersionUID = 1L;
	private String title="";//头部文字
	private String type="";//头部类型
	private String img="";//头部图片地址
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getImg() {
		return img;
	}
	public void setImg(String img) {
		this.img = img;
	}
	
}
