package com.ifeng.news2.bean;


import java.io.Serializable;

public class CommentsData implements Serializable {

	private static final long serialVersionUID = 1L;
	private int count;
	private int join_count;
	
	private AllComments comments;
	public AllComments getComments() {
		return comments;
	}
	public void setComments(AllComments comments) {
		this.comments = comments;
	}
	private int nopass;
	private int subjectid;
	private int followcount;
	public int getCount() {
		return count;
	}
	public void setCount(int count) {
		this.count = count;
	}
	public int getJoin_count() {
		return join_count;
	}
	public void setJoin_count(int join_count) {
		this.join_count = join_count;
	}
	public int getNopass() {
		return nopass;
	}
	public void setNopass(int nopass) {
		this.nopass = nopass;
	}
	public int getSubjectid() {
		return subjectid;
	}
	public void setSubjectid(int subjectid) {
		this.subjectid = subjectid;
	}
	public int getFollowcount() {
		return followcount;
	}
	public void setFollowcount(int followcount) {
		this.followcount = followcount;
	}
	
}
