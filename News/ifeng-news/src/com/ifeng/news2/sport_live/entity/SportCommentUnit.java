package com.ifeng.news2.sport_live.entity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import com.qad.form.PageEntity;

public class SportCommentUnit implements Serializable, PageEntity{

	private static final long serialVersionUID = 923051282913747924L;
	private SportMeta meta = new SportMeta();
	private ArrayList<SportCommentItem> body = new ArrayList<SportCommentItem>();
	public SportMeta getMeta() {
		return meta;
	}
	public void setMeta(SportMeta meta) {
		this.meta = meta;
	}
	public ArrayList<SportCommentItem> getBody() {
		return body;
	}
	public void setBody(ArrayList<SportCommentItem> body) {
		this.body = body;
	}
	@Override
	public int getPageSum() {
		try {
//			return Integer.parseInt(getMeta().getPageSize());
			return 5;
		} catch (Exception e) {
			return 0;
		}
	}
	@Override
	public List<?> getData() {
		return body;
	}

}
