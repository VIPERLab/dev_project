package com.ifeng.news2.bean;

import java.io.Serializable;

public class VideoElement implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = -5934778770190731734L;

	//normal video
	private VideoSrcElement Normal ; 
	//hd video
	private VideoSrcElement HD ;
	public VideoSrcElement getNormal() {
		return Normal;
	}
	public void setNormal(VideoSrcElement normal) {
		this.Normal = normal;
	}
	public VideoSrcElement getHD() {
		return HD;
	}
	public void setHD(VideoSrcElement hD) {
		HD = hD;
	}
	
}
