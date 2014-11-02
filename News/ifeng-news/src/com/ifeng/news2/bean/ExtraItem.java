package com.ifeng.news2.bean;

import java.io.Serializable;

/**
 * Class stores the extra data for focus topic (or the header topic)
 * 
 * @author gao_miao
 * 
 */

public class ExtraItem implements Serializable {

	private static final long serialVersionUID = 5962831786977371524L;

	private String id = "";
	private String title = "";
	private String thumbnail = "";
	private String extra = "";

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getThumbnail() {
		return thumbnail;
	}

	public void setThumbnail(String thumbnail) {
		this.thumbnail = thumbnail;
	}

	public String getExtra() {
		return extra;
	}

	public void setExtra(String extra) {
		this.extra = extra;
	}
}
