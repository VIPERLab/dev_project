package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;


public class SplashCoverBody implements Serializable{

	private static final long serialVersionUID = 3847254112386437393L;
	
	ArrayList<ItemCover> item = new ArrayList<ItemCover>();

	public ArrayList<ItemCover> getItem() {
		return item;
	}

	public void setItem(ArrayList<ItemCover> item) {
		this.item = item;
	}

}
