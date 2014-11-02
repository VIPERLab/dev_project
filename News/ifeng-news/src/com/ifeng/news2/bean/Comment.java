package com.ifeng.news2.bean;

import java.util.Collections;

import java.text.SimpleDateFormat;
import java.util.ArrayList;

import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;

import com.ifeng.news2.util.DateUtil;

public class Comment implements Parcelable{
	
	private String doc_url;
	private String doc_name;
	private String ip_from;
	private String comment_date;
	private String comment_contents;
	private String briefDate;
	//@lxl, add for reply comment
	private String uuid;
	private String quote_id;
	private ArrayList<ParentComment> parent = new ArrayList<ParentComment>();
	private String uname;
	private String uptime;
	private String userFace;
	private transient boolean isUpped = false;
	
	
	public String getUptime() {
		return uptime;
	}
	public void setUptime(String uptime) {
		this.uptime = uptime;
	}
	public String getUserFace() {
      	if (TextUtils.isEmpty(userFace)) {
      	  userFace = "";
      	}
		return userFace;
	}
	public void setUserFace(String userFace) {
		this.userFace = userFace;
	}
	private String client_ip;
	private int is_hiddenip;
	private int last_update_time;
	private int add_time;
	private int report;	
	private Ext ext = new Ext();
	private String ext1;
	private String ext2;
	private String ext3;
	private int ext4;
	private int ext5;
	private int ext6;
	private int application;
	private int channel_id;
	private int level;
	private int comment_id;
	private int article_id;
	private String id;
	private String uptimes;
	public boolean isUped() {
		return isUpped;
	}
	public void setUped(boolean isUped) {
		this.isUpped = isUped;
	}
	private int downtimes;
	/**是否是刚发送的评论作为一个标示  程序中用到，接口并没有此字段*/
	private boolean isSendComment;
	//是否展开  程序中用到，接口并没有此字段
	private boolean isExpansion;

	public boolean isExpansion() {
		return isExpansion;
	}
	public void setExpansion(boolean isExpansion) {
		this.isExpansion = isExpansion;
	}
	public boolean isSendComment() {
		return isSendComment;
	}
	public void setSendComment(boolean isSendComment) {
		this.isSendComment = isSendComment;
	}
	public int getComment_id() {
		return comment_id;
	}
	public void setComment_id(int comment_id) {
		this.comment_id = comment_id;
	}
	public int getAdd_time() {
		return add_time;
	}
	public void setAdd_time(int add_time) {
		this.add_time = add_time;
	}
	public int getApplication() {
		return application;
	}
	public void setApplication(int application) {
		this.application = application;
	}
	public int getChannel_id() {
		return channel_id;
	}
	public void setChannel_id(int channel_id) {
		this.channel_id = channel_id;
	}
	public int getArticle_id() {
		return article_id;
	}
	public void setArticle_id(int article_id) {
		this.article_id = article_id;
	}
	public String getUptimes() {
		return uptimes;
	}
	public void setUptimes(String uptimes) {
		this.uptimes = uptimes;
	}
	public int getDowntimes() {
		return downtimes;
	}
	public void setDowntimes(int downtimes) {
		this.downtimes = downtimes;
	}
	public String getUuid() {
		return uuid;
	}
	public void setUuid(String uuid) {
		this.uuid = uuid;
	}
	public String getQuote_id() {
		return quote_id;
	}
	public void setQuote_id(String quote_id) {
		this.quote_id = quote_id;
	}
	public ArrayList<ParentComment> getParent() {
		return parent;
	}
	public void setParent(ArrayList<ParentComment> parent) {
		this.parent = parent;
	}
	public String getUname() {
		return uname;
	}
	public void setUname(String uname) {
		this.uname = uname;
	}
	public String getClient_ip() {
		return client_ip;
	}
	public void setClient_ip(String client_ip) {
		this.client_ip = client_ip;
	}
	public int getIs_hiddenip() {
		return is_hiddenip;
	}
	public void setIs_hiddenip(int is_hiddenip) {
		this.is_hiddenip = is_hiddenip;
	}
	public int getLast_update_time() {
		return last_update_time;
	}
	public void setLast_update_time(int last_update_time) {
		this.last_update_time = last_update_time;
	}
	public int getReport() {
		return report;
	}
	public void setReport(int report) {
		this.report = report;
	}
	public Ext getExt() {
		return ext;
	}
	public void setExt(Ext ext) {
		this.ext = ext;
	}
	public String getExt1() {
		return ext1;
	}
	public void setExt1(String ext1) {
		this.ext1 = ext1;
	}
	public String getExt2() {
		return ext2;
	}
	public void setExt2(String ext2) {
		this.ext2 = ext2;
	}
	public String getExt3() {
		return ext3;
	}
	public void setExt3(String ext3) {
		this.ext3 = ext3;
	}
	public int getExt4() {
		return ext4;
	}
	public void setExt4(int ext4) {
		this.ext4 = ext4;
	}
	public int getExt5() {
		return ext5;
	}
	public void setExt5(int ext5) {
		this.ext5 = ext5;
	}
	public int getExt6() {
		return ext6;
	}
	public void setExt6(int ext6) {
		this.ext6 = ext6;
	}
	public int getLevel() {
		return level;
	}
	public void setLevel(int level) {
		this.level = level;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	private final static SimpleDateFormat commentDateParser=new SimpleDateFormat("yyyy-MM-dd HH:mm");
	/**
	 * @return the ip_from
	 */
	public String getIp_from() {
		return ip_from;
	}
	/**
	 * @param ip_from the ip_from to set
	 */
	public void setIp_from(String ip_from) {
		if (TextUtils.isEmpty(ip_from)) {
			ip_from = "";
		}
		this.ip_from = ip_from;
	}
	
	/**
	 * @return the comment_date
	 */
	public String getComment_date() {
		if(briefDate==null)
		{
			briefDate=DateUtil.toBriefString(DateUtil.parse(comment_date, commentDateParser));
		}
		return briefDate;
	}
	/**
	 * @param comment_date the comment_date to set
	 */
	public void setComment_date(String comment_date) {
		this.comment_date = comment_date;
	}
	/**
	 * @return the comment_contents
	 */
	public String getComment_contents() {
		return comment_contents;
	}
	/**
	 * @param comment_contents the comment_contents to set
	 */
	public void setComment_contents(String comment_contents) {
		this.comment_contents = comment_contents;
	}
	/**
	 * @return the doc_url
	 */
	public String getDoc_url() {
		return doc_url;
	}
	/**
	 * @param doc_url the doc_url to set
	 */
	public void setDoc_url(String doc_url) {
		this.doc_url = doc_url;
	}
	/**
	 * @return the doc_name
	 */
	public String getDoc_name() {
		return doc_name;
	}
	/**
	 * @param doc_name the doc_name to set
	 */
	public void setDoc_name(String doc_name) {
		this.doc_name = doc_name;
	}
	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}
	@Override
	public void writeToParcel(Parcel dest, int flags) {
		// TODO Auto-generated method stub
		
	}
	
	
}
