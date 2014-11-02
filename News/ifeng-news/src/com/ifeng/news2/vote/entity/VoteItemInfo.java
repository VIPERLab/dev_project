package com.ifeng.news2.vote.entity;

import java.io.Serializable;

import android.text.TextUtils;

/**
 * 投票的每一项的集合
 * 
 * @author SunQuan:
 * @version 创建时间：2013-11-28 下午1:53:10 类说明
 */

public class VoteItemInfo implements Serializable {

	private static final long serialVersionUID = 4975346765636678244L;

	// 选项id
	private String id = "";
	// 投票
	private String voteid = "";
	// 选项内容
	private String title = "";
	// 选项图片url
	private String imgurl = "";

	// 票数
	private String votecount = "";

	// 链接
	private String linkurl = "";

	// 投票的百分比
	private float nump;

	public String getLinkurl() {
		return linkurl;
	}

	public void setLinkurl(String linkurl) {
		this.linkurl = linkurl;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getVoteid() {
		return voteid;
	}

	public void setVoteid(String voteid) {
		this.voteid = voteid;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getImgurl() {
		return imgurl;
	}

	public void setImgurl(String imgurl) {
		this.imgurl = imgurl;
	}

	public String getVotecount() {
		if(TextUtils.isEmpty(votecount)) {
			votecount = "0";
		}
		return votecount;
	}

	public void setVotecount(String votecount) {
		this.votecount = votecount;
	}

	public float getNump() {
		return nump;
	}

	public void setNump(float nump) {
		this.nump = nump;
	}

}
