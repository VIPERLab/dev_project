package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

public class TopicBody implements Serializable{

	private static final long serialVersionUID = 1L;
	private TopicHead head = new TopicHead();//数据头信息
	private ArrayList<TopicSubject> subjects = new ArrayList<TopicSubject>();//数据主题
	/**
	 * 公共信息描述
	 */
	private Content content = new Content();
	public TopicHead getHead() {
		return head;
	}
	public void setHead(TopicHead head) {
		this.head = head;
	}
	public ArrayList<TopicSubject> getSubjects() {
		return subjects;
	}
	public void setSubjects(ArrayList<TopicSubject> subjects) {
		this.subjects = subjects;
	}
	public Content getContent() {
		return content;
	}
	public void setContent(Content content) {
		this.content = content;
	}
}
