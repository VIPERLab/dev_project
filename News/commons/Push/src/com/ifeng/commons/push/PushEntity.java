package com.ifeng.commons.push;

import java.io.Serializable;

public class PushEntity implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 4235466287430184037L;
	
	private String product;
	
	private String msg;
	
	private String id;
	
	private String timer;
	
	private String type;
	
	private String timeStamp;

	public String getProduct() {
		return product;
	}

	public void setProduct(String product) {
		this.product = product;
	}

	public String getMsg() {
		return msg;
	}

	public void setMsg(String msg) {
		this.msg = msg;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getTimer() {
		return timer;
	}

	public void setTimer(String timer) {
		this.timer = timer;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getTimeStamp() {
		return timeStamp;
	}

	public void setTimeStamp(String timeStamp) {
		this.timeStamp = timeStamp;
	}

	@Override
	public String toString() {
		return "PushEntity [product=" + product + ", msg=" + msg + ", id=" + id
				+ ", timer=" + timer + ", type=" + type + ", timeStamp="
				+ timeStamp + "]";
	}

}
