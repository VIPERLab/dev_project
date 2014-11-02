package com.ifeng.news2.bean;

import android.text.TextUtils;
import java.io.Serializable;
import java.util.ArrayList;

/** 
* @ClassName: Extension 
* @Description:  
* @author liu_xiaoliang@ifeng.com 
* @date 2013-3-11 下午2:48:40  
*/ 
public class Extension implements Serializable{
	
	private static final long serialVersionUID = -2118522289106395720L;
	//来源
	private String origin = "";
	//扩展类型
	private String type = "";
	//子类型
	private String style = "";
    //是否显示
	private String isShow = "";
	//是否默认跳转行为
	private String title = "";
	//缩略图大小（宽/高）
	private ThumbnailSize thumbnailSize;
	public ThumbnailSize getThumbnailSize() {
		return thumbnailSize;
	}
	public void setThumbnailSize(ThumbnailSize thumbnailSize) {
		this.thumbnailSize = thumbnailSize;
	}
	//描述信息
	private String introduction = "";
	public String getIntroduction() {
		return introduction;
	}
	public void setIntroduction(String introduction) {
		this.introduction = introduction;
	}
	public String getOrigin() {
		return origin;
	}
	public void setOrigin(String origin) {
		this.origin = origin;
	}
	//统计类型
	private String category = "";
	//是否可点击
	private String isLinkable = "";
	//持续时间
	private String validTime = "";
	//支持小数点的持续时间
	private float validSeconds;
	//扩展跳转地址
    private String url = "";
    //扩展地址id
    private String documentId = "";
	//封面图片地址
	private String storyImage = "";
	//是否默认跳转行为
	private String isDefault = "";
	//@lxl,add for HistoryMessageBean begin
	//标示是早晚报
	private String subtype = "";
	//@lxl,add for HistoryMessageBean end
	//封面故事的唯一标识
	private String storyId = "";
	//显示权重
	private int priority;
	//有效显示时间区间数组
	private ArrayList<Lifecycle> lifecycle = new ArrayList<Lifecycle>();
	//列表三张连图样式
    private ArrayList<String> images = new ArrayList<String>();
    //缩略图
    private String thumbnail = "";
    private String thumbnailpic = "";
    
	public String getThumbnailpic() {
		return thumbnailpic;
	}
	
	public void setThumbnailpic(String thumbnailpic) {
		this.thumbnailpic = thumbnailpic;
	}
	
	public String getThumbnail() {
		if (TextUtils.isEmpty(thumbnail)) {
			thumbnail = "";
		}
		return thumbnail;
	}
	public void setThumbnail(String thumbnail) {
		this.thumbnail = thumbnail;
	}
	public String getStyle() {
		return style;
	}
	public void setStyle(String style) {
		this.style = style;
	}
	public ArrayList<String> getImages() {
		return images;
	}
	public void setImages(ArrayList<String> images) {
		this.images = images;
	}
	public String getStoryId() {
		return storyId;
	}
	public void setStoryId(String storyId) {
		this.storyId = storyId;
	}
	public float getValidSeconds() {
		return validSeconds;
	}
	public void setValidSeconds(float validSeconds) {
		this.validSeconds = validSeconds;
	}
	public int getPriority() {
		return priority;
	}
	public void setPriority(int priority) {
		this.priority = priority;
	}
	public ArrayList<Lifecycle> getLifecycles() {
		return lifecycle;
	}
	public void setLifecycles(ArrayList<Lifecycle> lifecycles) {
		this.lifecycle = lifecycles;
	}
	public String getSubtype() {
		return subtype;
	}
	public void setSubtype(String subtype) {
		this.subtype = subtype;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getIsShow() {
		return isShow;
	}
	public void setIsShow(String isShow) {
		this.isShow = isShow;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getCategory() {
		return category;
	}
	public void setCategory(String category) {
		this.category = category;
	}
	public String getIsLinkable() {
		return isLinkable;
	}
	public void setIsLinkable(String isLinkable) {
		this.isLinkable = isLinkable;
	}
	public String getValidTime() {
		return validTime;
	}
	public void setValidTime(String validTime) {
		this.validTime = validTime;
	}
	public String getUrl() {
		return url;
	}
	public void setUrl(String url) {
		this.url = url;
	}
	public String getDocumentId() {
		return documentId;
	}
	public void setDocumentId(String documentId) {
		this.documentId = documentId;
	}
	public String getStoryImage() {
		return storyImage;
	}
	public void setStoryImage(String storyImage) {
		this.storyImage = storyImage;
	}
	public String getIsDefault() {
		return isDefault;
	}
	public void setIsDefault(String isDefault) {
		this.isDefault = isDefault;
	}
	
}
