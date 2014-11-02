package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import com.qad.form.PageEntity;

public class TopicUnit implements Serializable, PageEntity {

	private static final long serialVersionUID = 5962831786944371510L;

	private ArrayList<ListItem> body = new ArrayList<ListItem>();

	private ListMeta meta = new ListMeta();

	@Override
	public List<?> getData() {
		return null;
	}

	@Override
	public int getPageSum() {
		return meta.getPageSize();
	}

	public ArrayList<ListItem> getBody() {
		return body;
	}

	public void setBody(ArrayList<ListItem> body) {
		this.body = body;
	}

	public ListMeta getMeta() {
		return meta;
	}

	public void setMeta(ListMeta meta) {
		this.meta = meta;
	}

	public void add(TopicUnit topicUnit) {
		
	}
}
