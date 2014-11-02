package com.ifeng.share.bean;

public class TargetShare {
	private String action;
	private String name;
	private String type;
	private int num;
	private ShareInterface shareInterface;
	public CallbackAction callback;
	public TargetShare() {
	}
	
	public TargetShare(String name, String type, int num,
			ShareInterface shareInterface) {
		this.name = name;
		this.type = type;
		this.num = num;
		this.shareInterface = shareInterface;
	}
	public TargetShare(String name, String type,String action ,ShareInterface shareInterface) {
		this.name = name;
		this.type = type;
		this.action = action;
		this.shareInterface = shareInterface;
	}
	public TargetShare(String name, String type,String action ,ShareInterface shareInterface,CallbackAction callback) {
		this.name = name;
		this.type = type;
		this.action = action;
		this.shareInterface = shareInterface;
		this.callback = callback;
	}
	public TargetShare(String name, String type,ShareInterface shareInterface) {
		this.name = name;
		this.type = type;
		this.shareInterface = shareInterface;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public ShareInterface getShareInterface() {
		return shareInterface;
	}
	public void setShareInterface(ShareInterface shareInterface) {
		this.shareInterface = shareInterface;
	}
	public String getAction() {
		return action;
	}
	public void setAction(String action) {
		this.action = action;
	}

	public int getNum() {
		return num;
	}

	public void setNum(int num) {
		this.num = num;
	}

	public CallbackAction getCallback() {
		return callback;
	}

	public void setCallback(CallbackAction callback) {
		this.callback = callback;
	}

	
	
}
