package com.ifeng.news2.bean;

import java.io.Serializable;

public class HistoryMessageUnit implements Serializable {
	

	/**
	 * 
	 */
	private static final long serialVersionUID = -8773882316061918543L;

	private ListMeta meta = new ListMeta();

	private ReviewBody body = new ReviewBody();


	public ListMeta getMeta() {
		return meta;
	}

	public void setMeta(ListMeta meta) {
		this.meta = meta;
	}

	public ReviewBody getBody() {
		return body;
	}

	public void setBody(ReviewBody body) {
		this.body = body;
	}
	
}
