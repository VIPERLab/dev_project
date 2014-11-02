package com.ifeng.news2.vote.entity;
/** 
 * 投票结果
 * 
 * @author SunQuan: 
 * @version 创建时间：2013-11-28 下午2:51:13 
 * 类说明 
 */

public class VoteResult {
	//投票是否成功（0：失败，1：成功）
	private int ifsuccess;
	//成功失败、成功返回的信息
	private String msg ="";
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

}
