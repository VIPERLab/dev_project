package com.ifeng.news2.bean;

import java.io.Serializable;

/**
 * @author SunQuan:
 * @version 创建时间：2013-8-22 下午2:04:48 类说明
 */

public class PhotoAndTextLiveItemVideo implements Serializable{

	private static final long serialVersionUID = 4684538524821696245L;
	// 视频图片地址
	private String video_image;
	// 视频跳转地址
	private String video_url;

	public String getVideo_image() {
		return video_image;
	}

	public void setVideo_image(String video_image) {
		this.video_image = video_image;
	}

	public String getVideo_url() {
		return video_url;
	}

	public void setVideo_url(String video_url) {
		this.video_url = video_url;
	}

}
