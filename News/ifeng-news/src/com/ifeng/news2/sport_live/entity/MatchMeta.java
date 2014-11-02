package com.ifeng.news2.sport_live.entity;

import java.io.Serializable;

/**
 * 比赛信息的元数据
 * 
 * @author SunQuan
 * 
 */
public class MatchMeta implements Serializable {

	private static final long serialVersionUID = -6363789929636750865L;

	private String id = "";
	private String matchId = "";
	private String type = "";

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getMatchId() {
		return matchId;
	}

	public void setMatchId(String matchId) {
		this.matchId = matchId;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

}
