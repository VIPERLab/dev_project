package com.ifeng.news2.vote.entity;

import java.io.Serializable;

public class VoteSetting implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = -4272672771145272220L;
	private String voteid;
	private String period;
	private String ticknum;
	private String limitstatus;
	private String expinfo;
	private String userstatus;
	private String userinfo;
	private String titlelink;
	public String getVoteid() {
		return voteid;
	}
	public void setVoteid(String voteid) {
		this.voteid = voteid;
	}
	public String getPeriod() {
		return period;
	}
	public void setPeriod(String period) {
		this.period = period;
	}
	public String getTicknum() {
		return ticknum;
	}
	public void setTicknum(String ticknum) {
		this.ticknum = ticknum;
	}
	public String getLimitstatus() {
		return limitstatus;
	}
	public void setLimitstatus(String limitstatus) {
		this.limitstatus = limitstatus;
	}
	public String getExpinfo() {
		return expinfo;
	}
	public void setExpinfo(String expinfo) {
		this.expinfo = expinfo;
	}
	public String getUserstatus() {
		return userstatus;
	}
	public void setUserstatus(String userstatus) {
		this.userstatus = userstatus;
	}
	public String getUserinfo() {
		return userinfo;
	}
	public void setUserinfo(String userinfo) {
		this.userinfo = userinfo;
	}
	public String getTitlelink() {
		return titlelink;
	}
	public void setTitlelink(String titlelink) {
		this.titlelink = titlelink;
	}
	
	
}
