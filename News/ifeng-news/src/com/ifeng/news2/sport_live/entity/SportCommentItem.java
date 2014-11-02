package com.ifeng.news2.sport_live.entity;

import java.io.Serializable;
import android.text.TextUtils;

public class SportCommentItem implements Serializable{
	
	private static final long serialVersionUID = -2850640134073186381L;
	private String id = "";
	private String type = "";
	private String username= "";
	private String userid = "";
	private String content = "";
	private String tousername = "";
	private String touserid = "";
	private String time = "";
	
	public String getTime() {
		if (TextUtils.isEmpty(time)) {
			time = "";
		}
		return time;
	}
	public void setTime(String time) {
		this.time = time;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public String getUserid() {
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
