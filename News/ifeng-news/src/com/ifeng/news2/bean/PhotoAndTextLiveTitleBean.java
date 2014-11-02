package com.ifeng.news2.bean;

import java.io.Serializable;

/**
 * 直播头部信息bean
 * 
 * @author SunQuan:
 * @version 创建时间：2013-8-21 下午2:34:12 类说明
 */
public class PhotoAndTextLiveTitleBean implements Serializable{

	private static final long serialVersionUID = 6618373660428457269L;
	private String header;
	private PhotoAndTextLiveStatus status;
	private PhotoAndTextLiveContent content;

	public String getHeader() {
		return header;
	}

	public void setHeader(String header) {
		this.header = header;
	}

	public PhotoAndTextLiveStatus getStatus() {
		return status;
	}

	public void setStatus(PhotoAndTextLiveStatus status) {
		this.status = status;
	}

	public PhotoAndTextLiveContent getContent() {
		return content;
	}

	public void setContent(PhotoAndTextLiveContent content) {
		this.content = content;
	}

}
