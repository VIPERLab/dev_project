package com.ifeng.news2.bean;

import java.io.Serializable;

/**
 * 直播顶部数据内容bean
 * 
 * @author SunQuan:
 * @version 创建时间：2013-8-21 下午2:40:47 类说明
 */

public class PhotoAndTextLiveContent implements Serializable {

	private static final long serialVersionUID = -6176436597409448436L;

	// 类型ID
	// 客户端对应显示:
	// 6 => 凤凰新闻
	// 5 => 凤凰新闻
	// 4 => 凤凰科技
	// 3 => 凤凰财经
	// 2 => 凤凰娱乐
	// 1 => 凤凰娱乐
	//在4.0.7版本开始使用lcat_name
	private String lcat_id = "";
	// 直播名称
	private String name = "";
	// 描述
	private String description = "";
	
	// 直播开始时间
	private String start_date = "";

	// 直播结束时间
	private String end_date = "";

	private String server_time = "";
	//图文直播类型
	private String lcat_name = "";
	
	public String getLcat_name() {
		return lcat_name;
	}

	public void setLcat_name(String lcat_name) {
		this.lcat_name = lcat_name;
	}

	public String getServer_time() {
		return server_time;
	}

	public void setServer_time(String server_time) {
		this.server_time = server_time;
	}

	@Deprecated
	public String getLcat_id() {
		return lcat_id;
	}

	@Deprecated
	public void setLcat_id(String lcat_id) {
		this.lcat_id = lcat_id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getStart_date() {
		return start_date;
	}

	public void setStart_date(String start_date) {
		this.start_date = start_date;
	}

	public String getEnd_date() {
		return end_date;
	}

	public void setEnd_date(String end_date) {
		this.end_date = end_date;
	}

}
