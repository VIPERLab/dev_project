package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

public class SplashSeenImgIds implements Serializable{

	private static final long serialVersionUID = 3928493063812878666L;

	ArrayList<String> imgIds = new ArrayList<String>();

	public ArrayList<String> getSplashImgIds() {
		return imgIds;
	}

	public void setSplashImgIds(ArrayList<String> imgIds) {
		this.imgIds = imgIds;
	}
}
