package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * 视频正文页
 * @author chenxi
 *
 */
public class VideoDetailBean implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = -1805241819992305132L;
	
	
	private ArrayList<VideoDetailInfo> singleVideoInfo = new ArrayList<VideoDetailInfo>();


	public ArrayList<VideoDetailInfo> getSingleVideoInfo() {
		return singleVideoInfo;
	}


	public void setSingleVideoInfo(ArrayList<VideoDetailInfo> singleVideoInfo) {
		this.singleVideoInfo = singleVideoInfo;
	}
	
	
	
}
