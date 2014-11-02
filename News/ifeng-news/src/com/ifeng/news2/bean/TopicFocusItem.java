package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

import com.ifeng.news2.util.FilterUtil;

public class TopicFocusItem implements Serializable{

	private static final long serialVersionUID = 5962831786334371524L;
	private String title = "";

	private String source = "";
	private String introduction = "";
	private String thumbnail = "";
	private String documentId = "";
	private String id = "";

	private DocUnit docUnit = null;

	private ArrayList<ExtraItem> extra = new ArrayList<ExtraItem>();
	
	public void setDocUnit(DocUnit docUnit) {
		this.docUnit = docUnit;
	}

	public DocUnit getDocUnit() {
		return docUnit;
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

	public String getIntroduction() {
		return introduction;
	}

	public void setIntroduction(String introduction) {
		this.introduction = introduction;
	}

	public String getThumbnail() {
		return thumbnail;
	}

	public void setThumbnail(String thumbnail) {
		this.thumbnail = thumbnail;
	}

	public String getDocumentId() {
		return FilterUtil.filterDocumentId(documentId);
	}

	public void setDocumentId(String documentId) {
		
		this.documentId = documentId;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public ArrayList<ExtraItem> getExtra() {
		return extra;
	}

	public void setExtra(ArrayList<ExtraItem> extra) {
		this.extra = extra;
	}


}
