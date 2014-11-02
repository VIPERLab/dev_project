package com.ifeng.news2.sport_live.entity;

import java.io.Serializable;

/**
 * @author liu_xiaoliang
 * 
 */
public class SportMeta implements Serializable {

	private static final long serialVersionUID = -5243107466856300425L;
	private String id = "";   
	private int matchId;
	private String type = "";
	private String pageSize = "";
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public int getMatchId() {
		return matchId;
	}
	public void setMatchId(int matchId) {
		this.matchId = matchId;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getPageSize() {
		return pageSize;
	}
	public void setPageSize(String pageSize) {
		this.pageSize = pageSize;
	}
	
}
