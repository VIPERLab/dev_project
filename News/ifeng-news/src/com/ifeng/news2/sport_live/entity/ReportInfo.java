package com.ifeng.news2.sport_live.entity;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * 战报页信息
 * 
 * @author SunQuan
 * 
 */
public class ReportInfo implements Serializable {

	private static final long serialVersionUID = -2173105599871693132L;

	private MatchMeta meta;
	private ArrayList<ReportBody> body;

	public ArrayList<ReportBody> getBody() {
		return body;
	}

	public void setBody(ArrayList<ReportBody> body) {
		this.body = body;
	}

	public MatchMeta getMeta() {
		return meta;
	}

	public void setMeta(MatchMeta meta) {
		this.meta = meta;
	}
}
