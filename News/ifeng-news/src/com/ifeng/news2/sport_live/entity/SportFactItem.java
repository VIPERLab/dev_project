package com.ifeng.news2.sport_live.entity;

import java.io.Serializable;

import android.text.TextUtils;


/**
 * @author liu_xiaoliang
 * 实况直播每一项的数据结构
 */
public class SportFactItem implements Serializable {

	private static final long serialVersionUID = 343892808904505791L;

	/**
	 * 本条直播ID
	 */
	private String id = "";
	/**
	 * 节次
	 */
	private String section = "";
	/**
	 * 直播员	
	 */
	private String liver = "";
	/**
	 * 实况图片
	 */
	private String picurl = "";
	private SportExtension ext = null;
	/**
	 * 发言时客队比分（最新）
	 */
	private String awaycore = "";
	/**
	 * 发言时主队比分（最新）
	 */
	private String homescore = "";
	/**
	 * 时间
	 */
	private String time = "";
	/**
	 * 发言内容
	 */
	private String content = "";
	/**
	 * 发言种类（recommend：推送用户发言  live:正常直播  dushe：毒蛇数据 ）
	 */
	private String type = "";
	/**
	 * 支持人logo
	 */
	private String title_img = "";
	/**
	 * 实况图是否显示了
	 */
	private boolean picIsShow = false;
	
	public boolean isPicIsShow() {
	  return picIsShow;
	}
	public void setPicIsShow(boolean picIsShow) {
	  this.picIsShow = picIsShow;
	}
	public String getId() {
	  return id;
	}
	public void setId(String id) {
	  this.id = id;
	}
	public String getSection() {
		if (TextUtils.isEmpty(section)) {
			section = "";
		}
		return section;
	}
	public void setSection(String section) {
		this.section = section;
	}
	public String getLiver() {
		return liver;
	}
	public void setLiver(String liver) {
		this.liver = liver;
	}
	public SportExtension getExt() {
		return ext;
	}
	public void setExt(SportExtension ext) {
		this.ext = ext;
	}
	public String getAwaycore() {
		return awaycore;
	}
	public void setAwaycore(String awaycore) {
		this.awaycore = awaycore;
	}
	public String getHomescore() {
		return homescore;
	}
	public void setHomescore(String homescore) {
		this.homescore = homescore;
	}
	public String getTime() {
		return time;
	}
	public void setTime(String time) {
		this.time = time;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getTitle_img() {
		return title_img;
	}
	public void setTitle_img(String title_img) {
		this.title_img = title_img;
	}
	public String getPicurl() {
		return picurl;
	}
	public void setPicurl(String picurl) {
		this.picurl = picurl;
	}
	
	
}
