package com.ifeng.news2.bean;

import java.io.Serializable;

import android.graphics.Bitmap;

public class StoryMessage implements Serializable{
	
	private static final long serialVersionUID = 553214377581204798L;
	
	private int position;
	private int priority;
	private String isShow;
	private String storyId;
	private ItemCover item;
	private Bitmap splashBitmap;
	
	public String getStoryId() {
		return storyId;
	}
	public void setStoryId(String storyId) {
		this.storyId = storyId;
	}
	public Bitmap getSplashBitmap() {
		return splashBitmap;
	}
	public void setSplashBitmap(Bitmap splashBitmap) {
		this.splashBitmap = splashBitmap;
	}
	public int getPosition() {
		return position;
	}
	public void setPosition(int position) {
		this.position = position;
	}
	public int getPriority() {
		return priority;
	}
	public void setPriority(int priority) {
		this.priority = priority;
	}
	public String getIsShow() {
		return isShow;
	}
	public void setIsShow(String isShow) {
		this.isShow = isShow;
	}
	public ItemCover getItem() {
		return item;
	}
	public void setItem(ItemCover item) {
		this.item = item;
	} 
}
