package com.ifeng.news2.bean;

import java.util.ArrayList;

/**
 * 记录json专题list类型文章id和位置用于json专题中文章支持左右滑动
 * （现已不用）
 */
public class DocLocation {

	private Integer docPosition;
	private ArrayList<String> ids;
	public Integer getDocPosition() {
		return docPosition;
	}
	public void setDocPosition(Integer docPosition) {
		this.docPosition = docPosition;
	}
	public ArrayList<String> getIds() {
		return ids;
	}
	public void setIds(ArrayList<String> ids) {
		this.ids = ids;
	}
	
	
}
