package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import com.qad.form.PageEntity;

public class VideoListUnit implements Serializable,PageEntity {

	/**
	 * 视频频道
	 * @author wu_dan
	 */
	private static final long serialVersionUID = 8880075422957687796L;
	
	private String relate = "";
	private String title = "";
	private ArrayList<VideoListItem> header = new ArrayList<VideoListItem>();
	private ArrayList<VideoListItem> bodyList = new ArrayList<VideoListItem>();
	
	public String getRelate() {
		return relate;
	}
	public void setRelate(String relate) {
		this.relate = relate;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public ArrayList<VideoListItem> getHeader() {
		return header;
	}
	public void setHeader(ArrayList<VideoListItem> header) {
		this.header = header;
	}
	public ArrayList<VideoListItem> getBodyList() {
		return bodyList;
	}
	public void setBodyList(ArrayList<VideoListItem> bodyList) {
		this.bodyList = bodyList;
	}
	@Override
	public int getPageSum() {
		return Integer.MAX_VALUE;
	}
	@Override
	public List<?> getData() {
		return this.bodyList;
	}
}
