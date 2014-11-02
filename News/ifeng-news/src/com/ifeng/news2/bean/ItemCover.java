package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

import com.ifeng.news2.util.FilterUtil;

public class ItemCover implements Serializable{

	private static final long serialVersionUID = -5184184196072441745L;
	//缩略图	
		private String thumbnail = "";
		//标题
		private String title = "";
	    //来源
		private String source = "";
		//类别
		private String channel = "";
		//编辑时间
		private String editTime = "";
		//更新时间
		private String updateTime = "";
		//文章地址
		private String id = "";
		//文章id
		private String documentId = "";
		//单元数据类型
		private String type = "";
		//简介
		private String introduction = "";
		//扩展单元
		private ArrayList<Extension> extensions = new ArrayList<Extension>();
		//控制跳转（因Extension包含Link所有字段，所以用Extension做载体）
		private ArrayList<Extension> links = new ArrayList<Extension>();
		
		public ArrayList<Extension> getLinks() {
			return links;
		}
		public void setLinks(ArrayList<Extension> links) {
			this.links = links;
		}
		public String getThumbnail() {
			return thumbnail;
		}
		public void setThumbnail(String thumbnail) {
			this.thumbnail = thumbnail;
		}
		public String getTitle() {
			return title;
		}
		public void setTitle(String title) {
			this.title = title;
		}
		public String getSource() {
			return source;
		}
		public void setSource(String source) {
			this.source = source;
		}
		public String getChannel() {
			return channel;
		}
		public void setChannel(String channel) {
			this.channel = channel;
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
		public String getId() {
			return id;
		}
		public void setId(String id) {
			this.id = id;
		}
		public String getDocumentId() {
			return FilterUtil.filterDocumentId(documentId);
		}
		public void setDocumentId(String documentId) {
			
			this.documentId = documentId;
		}
		public String getType() {
			return type;
		}
		public void setType(String type) {
			this.type = type;
		}
		public String getIntroduction() {
			return introduction;
		}
		public void setIntroduction(String introduction) {
			this.introduction = introduction;
		}
		public ArrayList<Extension> getExtensions() {
			return extensions;
		}
		public void setExtensions(ArrayList<Extension> extensions) {
			this.extensions = extensions;
		}
}
