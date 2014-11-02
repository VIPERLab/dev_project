package com.ifeng.share.bean;

import java.util.ArrayList;

import com.ifeng.share.config.ShareConfig;
public class ShareMessage {
	public String content;//总分享内容
	public String title;//标题
	public String caption;//副标题;
	public String description;//分享内容描述
	public String message;//用户输入内容
	public String url;//分享内容和图片 地址
	public String form;//分享内容来源格式
	public ArrayList<String> imageResources;//图片资源
	public String actionName;//应用名称
	public String actionLink;
	public String type;//分享内容类型
	public ArrayList<TargetShare> definedShareList;
	public TargetShare targetShare;
	public String shareImageUrl;
	public ShareMessage() {
	}
	public ShareMessage(String title,String description){
		this.title = title;
		this.description = description;
	}
	
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getTitle() {
		if (title==null || title.length()==0) {
			return ShareConfig.defaultTitle;
		}
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public ArrayList<String> getImageResources() {
		return imageResources;
	}
	public void setImageResources(ArrayList<String> imageResources) {
		this.imageResources = imageResources;
	}
	
	public String getActionName() {
		return actionName;
	}

	public void setActionName(String actionName) {
		this.actionName = actionName;
	}

	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	/*public String getTarget() {
		return target;
	}
	public void setTarget(String target) {
		this.target = target;
	}*/
	public String getUrl() {
		return url;
	}
	public void setUrl(String url) {
		this.url = url;
	}
	public String getForm() {
		return form;
	}
	public void setForm(String form) {
		this.form = form;
	}

	public String getDescription() {
		if(description==null || description.length()==0){
			return ShareConfig.defaultDescription;
		}
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getActionLink() {
		if (actionLink==null || actionLink.length()==0) {
			return ShareConfig.defaultAutoLine;
		}
		return actionLink;
	}

	public void setActionLink(String actionLink) {
		this.actionLink = actionLink;
	}
	public String getCaption() {
		return caption;
	}
	public void setCaption(String caption) {
		this.caption = caption;
	}
	public ArrayList<TargetShare> getDefinedShareList() {
		return definedShareList;
	}
	public void addDefinedShare(TargetShare targetShare){
		if (definedShareList==null) {
			definedShareList = new ArrayList<TargetShare>();
		}
		if (targetShare!=null) {
			definedShareList.add(targetShare);
		}
	}
	
	public TargetShare getTargetShare() {
		return targetShare;
	}
	public void setTargetShare(TargetShare targetShare) {
		this.targetShare = targetShare;
	}
	public String getShareImageUrl() {
		return shareImageUrl;
	}
	public void setShareImageUrl(String shareImageUrl) {
		this.shareImageUrl = shareImageUrl;
	}
	
}
