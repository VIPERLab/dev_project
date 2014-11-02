package com.ifeng.news2.vote.entity;

import java.io.Serializable;
import java.util.ArrayList;
import android.content.Context;
import android.text.TextUtils;

import com.ifeng.news2.util.DateUtil;
import com.ifeng.news2.util.RecordUtil;

/** 
 * 投票的具体数据
 * 
 * @author SunQuan: 
 * @version 创建时间：2013-11-28 下午1:47:41 
 * 类说明 
 */

public class Data implements Serializable {

	private static final long serialVersionUID = 2966564535140713263L;

	//投票id
	private String id = "";
	//投票标题
	private String topic = "";

	//当前票数
	private String votecount = "";
	
	//投票发起日期
	private String published = "";
	
	private String statusinfo;
	
	private VoteSetting votesetting;
	

	public String getPublished() {
		return DateUtil.getTimeForVote(Long.valueOf(this.published) * 1000);
	}

	public void setPublished(String published) {
		this.published = published;
	}
	
	/**
	 * 判断投票是否有效
	 * 
	 * @return
	 */
	public boolean isVoted(Context context) {
		//如果没有过期并且没有投过，则该投票有效
		return RecordUtil.isRecorded(context, id,RecordUtil.VOTE);
	}
	
	/**
	 * 判断投票是否过期
	 * 
	 * @return
	 */
	public boolean isOverDue() {
		if(isactive==1) {
			return false;
		}
		return true;
	}

	//投票是否过期 （0：过期，1：进行中）
	private int isactive;
	
	//投票的每一个选项的集合
	private ArrayList<VoteItemInfo> iteminfo;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getTopic() {
		return topic;
	}

	public void setTopic(String topic) {
		this.topic = topic;
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

	public int getIsactive() {
		return isactive;
	}

	public void setIsactive(int isactive) {
		this.isactive = isactive;
	}

	public ArrayList<VoteItemInfo> getIteminfo() {
		return iteminfo;
	}

	public void setIteminfo(ArrayList<VoteItemInfo> iteminfo) {
		this.iteminfo = iteminfo;
	}

	public VoteSetting getVotesetting() {
		return votesetting;
	}

	public void setVotesetting(VoteSetting votesetting) {
		this.votesetting = votesetting;
	}

	public String getStatusinfo() {
		return statusinfo;
	}

	public void setStatusinfo(String statusinfo) {
		this.statusinfo = statusinfo;
	}
	
}
