package com.ifeng.news2.sport_live.entity;

import java.io.Serializable;

import android.text.TextUtils;

/**
 * @author liu_xiaoliang
 *
 */
public class SportExtension implements Serializable {

	private static final long serialVersionUID = 7991320828537412650L;

	/**
	 * 发言用户昵称
	 */
	private String username = "";
	/**
	 * 发言用户ID
	 */
	private String userid = "";
	/**
	 * 内容
	 */
	private String content = "";
	/**
	 * 回复用户ID，主持人
	 */
	private String tousername = "";
	/**
	 * 回复用户昵称
	 */
	private String touserid = "";
	
	public String getUsername() {
		if (TextUtils.isEmpty(username)) {
			username = "用户";
		}
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public String getUserid() {
		if (TextUtils.isEmpty(userid)) {
			userid = "0";
		}
		return userid;
	}
	public void setUserid(String userid) {
		this.userid = userid;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getTousername() {
		return tousername;
	}
	public void setTousername(String tousername) {
		this.tousername = tousername;
	}
	public String getTouserid() {
		return touserid;
	}
	public void setTouserid(String touserid) {
		this.touserid = touserid;
	}
}
