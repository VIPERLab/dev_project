package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * 视频正文推荐视频
 * @author chenxix
 *
 */
public class VideoRelativeBean implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 7629051321326962141L;
	
	private ArrayList<VideoRelativeInfo> relativeVideoInfo = new ArrayList<VideoRelativeInfo>();

	public ArrayList<VideoRelativeInfo> getRelativeVideoInfo() {
		return relativeVideoInfo;
	}

	public void setRelativeVideoInfo(ArrayList<VideoRelativeInfo> relativeVideoInfo) {
		this.relativeVideoInfo = relativeVideoInfo;
	}

}
