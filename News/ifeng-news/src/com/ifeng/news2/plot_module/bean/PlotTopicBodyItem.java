package com.ifeng.news2.plot_module.bean;

import java.util.ArrayList;

import com.ifeng.news2.bean.Extension;
import java.io.Serializable;

/**
 * @author liu_xiaoliang 策划内容实体
 */
public class PlotTopicBodyItem implements Serializable {

	private static final long serialVersionUID = 5276207687383625469L;

	/**
	 * 标题
	 */
	private String title;
	/**
	 * 视图类型
	 */
	private String type;
	/**
	 * 简介
	 */
	private String intro;
	/**
	 * 详情
	 */
	private String content;
	/**
	 * 作者
	 */
	private String author;
	/**
	 * 文章id
	 */
	private String documentId;
	/**
	 * html样式中会用到
	 */
	private String thumbnail;
	/* < add for comment module, liuxiaoliang 20130822 begin */
	/**
	 * 评论标题
	 */
	private String commentTitle;
	/**
	 * 被评论的url
	 */
	private String wwwUrl;
	/* add for comment module, liuxiaoliang 20130822 end > */
	/**
	 * 子标题
	 */
	private String subTitle;
	/**
	 * banner图片地址
	 */
	private String bgImage;
	/**
	 * banner图片地址
	 */
	private String shareThumbnail;
	/**
	 * 跳转
	 */
	private ArrayList<Extension> links;

	/**
	 * 投票或者调查的id
	 */
	private String pollId;

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getIntro() {
		return intro;
	}

	public void setIntro(String intro) {
		this.intro = intro;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public String getThumbnail() {
		return thumbnail;
	}

	public void setThumbnail(String thumbnail) {
		this.thumbnail = thumbnail;
	}

	public String getDocumentId() {
		return documentId;
	}

	public void setDocumentId(String documentId) {
		this.documentId = documentId;
	}

	public String getAuthor() {
		return author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public String getCommentTitle() {
		return commentTitle;
	}

	public void setCommentTitle(String commentTitle) {
		this.commentTitle = commentTitle;
	}

	public String getWwwUrl() {
		return wwwUrl;
	}

	public void setWwwUrl(String wwwUrl) {
		this.wwwUrl = wwwUrl;
	}

	public String getSubTitle() {
		return subTitle;
	}

	public void setSubTitle(String subTitle) {
		this.subTitle = subTitle;
	}

	public String getBgImage() {
		return bgImage;
	}

	public void setBgImage(String bgImage) {
		this.bgImage = bgImage;
	}

	public ArrayList<Extension> getLinks() {
		return links;
	}

	public void setLinks(ArrayList<Extension> links) {
		this.links = links;
	}

	public String getPollId() {
		return pollId;
	}

	public void setPollId(String pollId) {
		this.pollId = pollId;
	}

	public String getShareThumbnail() {
		return shareThumbnail;
	}

	public void setShareThumbnail(String shareThumbnail) {
		this.shareThumbnail = shareThumbnail;
	}


}
