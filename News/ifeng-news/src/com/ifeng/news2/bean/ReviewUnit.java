package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.List;

import com.qad.form.PageEntity;

public class ReviewUnit implements Serializable , PageEntity{
	

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
	@Override
	public int getPageSum() {
		return meta.getPageSize();
	}

	@Override
	public List<?> getData() {
		return body.getItem();
	}

	public ReviewBody getBody() {
		return body;
	}

	public void setBody(ReviewBody body) {
		this.body = body;
	}
	
}
