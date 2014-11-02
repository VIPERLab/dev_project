package com.ifeng.news2.bean;

import java.io.Serializable;

import com.ifeng.news2.util.ReadUtil;

public class VideoListItem implements Serializable {

	/**
	 *  @author wu_dan
	 */
	private static final long serialVersionUID = 610994544400156554L;
	
	private String title = "";
	private String mediaUrl = "";
	private String image = "";
	private String abstractDesc = "";
	private VideoMemberItem memberItem = new VideoMemberItem();
	private String memberType = "";
	private int id = 0;
	
	public String getTitle() {
		return StringUtil.getStr(title, 24);
	}
	public String getLongTitle() {
		return StringUtil.getStr(title, 36);
	}
	public String getFullTitle(){
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getMediaUrl() {
		return mediaUrl;
	}
	public void setMediaUrl(String mediaUrl) {
		this.mediaUrl = mediaUrl;
	}
	public String getImage() {
		return image;
	}
	public void setImage(String image) {
		this.image = image;
	}
	public String getAbstractDesc() {
		return abstractDesc;
	}
	public void setAbstractDesc(String abstractDesc) {
		this.abstractDesc = abstractDesc;
	}
	public String getMemberType() {
		return memberType;
	}
	public void setMemberType(String memberType) {
		this.memberType = memberType;
	}
	public VideoMemberItem getMemberItem() {
		return memberItem;
	}
	public void setMemberItem(VideoMemberItem memberItem) {
		this.memberItem = memberItem;
	}
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public int getTitleColor() {
		return ReadUtil.isReaded(memberItem.getGuid()) ? 0xff727272
				: 0xff004276;
	}
}
