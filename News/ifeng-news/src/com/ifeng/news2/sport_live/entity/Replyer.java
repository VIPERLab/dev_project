package com.ifeng.news2.sport_live.entity;

/**
 * @author SunQuan:
 * @version 创建时间：2013-7-26 上午11:33:23 发言的返回结果
 */

public class Replyer {

	// 返回状态 0是失败，1是成功
	private int status;
	// 返回的提示信息
	private String msg;

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public String getMsg() {
		return msg;
	}

	public void setMsg(String msg) {
		this.msg = msg;
	}

}
