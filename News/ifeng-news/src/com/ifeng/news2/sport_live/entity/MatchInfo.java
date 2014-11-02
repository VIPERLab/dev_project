package com.ifeng.news2.sport_live.entity;

import java.io.Serializable;

/**
 * 比赛信息实体类
 * 
 * @author SunQuan
 * 
 */
public class MatchInfo implements Serializable {

	private static final long serialVersionUID = 6733224358218265218L;

	private MatchBody body;

	private MatchMeta meta;

	public MatchBody getBody() {
		return body;
	}

	public void setBody(MatchBody body) {
		this.body = body;
	}

	public MatchMeta getMeta() {
		return meta;
	}

	public void setMeta(MatchMeta meta) {
		this.meta = meta;
	}

}
