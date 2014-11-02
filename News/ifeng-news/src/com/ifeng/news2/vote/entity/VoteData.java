package com.ifeng.news2.vote.entity;

import java.io.Serializable;

/** 
 * 获取当前投票的内容数据
 * 
 * @author SunQuan: 
 * @version 创建时间：2013-11-28 下午1:45:41 
 * 类说明 
 */

public class VoteData implements Serializable {

	private static final long serialVersionUID = 1921648716836356140L;

	
	private int ifsuccess;
	private String msg = "";
	
	//投票的数据
	private Data data;

	public int getIfsuccess() {
		return ifsuccess;
	}

	public void setIfsuccess(int ifsuccess) {
		this.ifsuccess = ifsuccess;
	}

	public String getMsg() {
		return msg;
	}

	public void setMsg(String msg) {
		this.msg = msg;
	}

	public Data getData() {
		return data;
	}

	public void setData(Data data) {
		this.data = data;
	}	
	
}
