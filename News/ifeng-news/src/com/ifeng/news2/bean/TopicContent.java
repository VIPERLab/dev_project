package com.ifeng.news2.bean;

import android.text.TextUtils;
import java.io.Serializable;
import java.util.ArrayList;

public class TopicContent implements Serializable{

	private static final long serialVersionUID = 1L;
	//Add for Album module(2G、3G mode)
	public static final int STATUS_LOADING = 0X1;
	public static final int STATUS_NORAML = 0X2;
	public static final int STATUS_SUCCESS = 0X3;
	//Album module(2G、3G mode)
	private int imageShowStatus = STATUS_NORAML; 

	//for statistic of slideActivity
	private String topicId = "";
	private String title = "";
	//副标题
	private String subTitle = "";
	private String id="";
	//专题组合焦点图图片地址
	private String bgImage = "";
	//专题普通缩略图地址
	private String thumbnail = "";
	private String intro = "";
	private ArrayList<Extension> links;
//	private ArrayList<Extension> extensions = null;
	private String style = "";
	private String editTime = "";
	private String updateTime = "";
	private String[] images = null;
	private String commentCount = "";
	private String particpateCount = "";
	private String bigBannerSrc = "";
	private boolean hasVideo = false;
	
	
	public String getStyle() {
		return style;
	}
	public void setStyle(String style) {
		this.style = style;
	}
	public String getTopicId() {
		return topicId;
	}
	public void setTopicId(String topicId) {
		this.topicId = topicId;
	}
//	public ArrayList<Extension> getExtensions() {
//		if (null == extensions) {
//			extensions = new ArrayList<Extension>();
//		}
//		return extensions;
//	}
//	public void setExtensions(ArrayList<Extension> extensions) {
//		this.extensions = extensions;
//	}
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
	public String getTitle() {
//		if (TextUtils.isEmpty(title)) 
//			title = "";
//		return title;
		// 专题中列表标题与头条等列表标题保持一致，最多显示24个中文字宽度
		return StringUtil.getStr(title, 24);
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getThumbnail() {
		return thumbnail;
	}
	public void setThumbnail(String thumnail) {
		this.thumbnail = thumnail;
	}
	public String getIntro() {
		return intro;
	}
	public void setIntro(String intro) {
		this.intro = intro;
	}
	public ArrayList<Extension> getLinks() {
		if (null == links) {
			links = new ArrayList<Extension>();
		}
		if (0 < links.size()) {
			links.get(0).setDocumentId(id);
			links.get(0).setThumbnail(thumbnail);
		}
		return links;
	}
	public void setLinks(ArrayList<Extension> links) {
		this.links = links;
	}
	public String getEditTime() {
		return editTime;
	}
	public void setEditTime(String editTime) {
		this.editTime = editTime;
	}
	public String getUpdateTime() {
		return updateTime;
	}
	public void setUpdateTime(String updateTime) {
		this.updateTime = updateTime;
	}
	public String[] getImages() {
		return images;
	}
	public void setImages(String[] images) {
		this.images = images;
	}
	public String getCommentCount() {
		if("0".equals(commentCount) || TextUtils.isEmpty(commentCount) || "false".equals(commentCount)){
			return "";
		}
		return commentCount;
	}
	public void setCommentCount(String commentCount) {
		this.commentCount = commentCount;
	}
	public String getParticpateCount() {
		return particpateCount;
	}
	public void setParticpateCount(String particpateCount) {
		this.particpateCount = particpateCount;
	}
	public boolean isHasVideo() {
		return hasVideo;
	}
	public void setHasVideo(boolean hasVideo) {
		this.hasVideo = hasVideo;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
    public int getImageShowStatus() {
      return imageShowStatus;
    }
    public void setImageShowStatus(int imageShowStatus) {
      this.imageShowStatus = imageShowStatus;
    }
    public String getBigBannerSrc() {
      return bigBannerSrc;
    }
    public void setBigBannerSrc(String bigBannerSrc) {
      this.bigBannerSrc = bigBannerSrc;
    }
}
