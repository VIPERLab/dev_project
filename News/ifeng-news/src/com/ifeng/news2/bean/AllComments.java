package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

public class AllComments implements Serializable {

	private static final long serialVersionUID = 1L;
	private ArrayList<Comment> hottest = new ArrayList<Comment>();
	private ArrayList<Comment> newest = new ArrayList<Comment>();

	public ArrayList<Comment> getHottest() {
		return hottest;
	}

	public void setHottest(ArrayList<Comment> hottest) {
		this.hottest = hottest;
	}

	public ArrayList<Comment> getNewest() {
		return newest;
	}

	public void setNewest(ArrayList<Comment> newest) {
		this.newest = newest;
	}

}
