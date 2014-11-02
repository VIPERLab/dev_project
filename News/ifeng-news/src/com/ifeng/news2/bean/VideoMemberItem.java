package com.ifeng.news2.bean;

import java.io.Serializable;

public class VideoMemberItem implements Serializable {

	/**
	 *  @author wu_dan
	 */
	private static final long serialVersionUID = 7572619987881526988L;

	private String guid = "";
	private String name = "";
	private String createDate = "";
	private int duration = 0;
	private String actor = "";
	private String columnName = "";
	private String searchPath = "";
	
	public String getGuid() {
		return guid;
	}
	public void setGuid(String guid) {
		this.guid = guid;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getCreateDate() {
		return createDate;
	}
	public void setCreateDate(String createDate) {
		this.createDate = createDate;
	}
	public int getDuration() {
		return duration;
	}
	public void setDuration(int duration) {
		this.duration = duration;
	}
	public String getActor() {
		return actor;
	}
	public void setActor(String actor) {
		this.actor = actor;
	}
	public String getColumnName() {
		return columnName;
	}
	public void setColumnName(String columnName) {
		this.columnName = columnName;
	}
	public String getSearchPath() {
		return searchPath;
	}
	public void setSearchPath(String searchPath) {
		this.searchPath = searchPath;
	}
}
