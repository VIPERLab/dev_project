package com.ifeng.news2.sport_live.entity;

import java.io.Serializable;

/**
 * 比赛信息的详细数据体
 * 
 * @author SunQuan
 * 
 */
public class MatchBody implements Serializable {

	private static final long serialVersionUID = -7480569019776592848L;
	public static final String MATCH_MODE_1 = "0";
	public static final String MATCH_MODE_2 = "1";

	private String id = "";
	private String name = "";
	private String begin_time = "";
	private String end_time = "";
	private String isOneTitle = "";
	private String oneTitle = "";
	private String awayTeam = "";
	private String homeTeam = "";
	private String awayLogo = "";
	private String homeLogo = "";

	public String getHomeTeam() {
		return homeTeam;
	}

	public void setHomeTeam(String homeTeam) {
		this.homeTeam = homeTeam;
	}

	public String getAwayLogo() {
		return awayLogo;
	}

	public void setAwayLogo(String awayLogo) {
		this.awayLogo = awayLogo;
	}

	private String left_score = "";
	private String right_score = "";
	private String room_id = "";
	private String status = "";
	private String liver = "";
	private String createtime = "";

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getBegin_time() {
		return begin_time;
	}

	public void setBegin_time(String begin_time) {
		this.begin_time = begin_time;
	}

	public String getEnd_time() {
		return end_time;
	}

	public void setEnd_time(String end_time) {
		this.end_time = end_time;
	}

	public String getIsOneTitle() {
		return isOneTitle;
	}

	public void setIsOneTitle(String isOneTitle) {
		this.isOneTitle = isOneTitle;
	}

	public String getOneTitle() {
		return oneTitle;
	}

	public void setOneTitle(String oneTitle) {
		this.oneTitle = oneTitle;
	}

	public String getAwayTeam() {
		return awayTeam;
	}

	public void setAwayTeam(String awayTeam) {
		this.awayTeam = awayTeam;
	}

	public String getHomeLogo() {
		return homeLogo;
	}

	public void setHomeLogo(String homeLogo) {
		this.homeLogo = homeLogo;
	}

	public String getLeft_score() {
		return left_score;
	}

	public void setLeft_score(String left_score) {
		this.left_score = left_score;
	}

	public String getRight_score() {
		return right_score;
	}

	public void setRight_score(String right_score) {
		this.right_score = right_score;
	}

	public String getRoom_id() {
		return room_id;
	}

	public void setRoom_id(String room_id) {
		this.room_id = room_id;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getLiver() {
		return liver;
	}

	public void setLiver(String liver) {
		this.liver = liver;
	}

	public String getCreatetime() {
		return createtime;
	}

	public void setCreatetime(String createtime) {
		this.createtime = createtime;
	}

}
