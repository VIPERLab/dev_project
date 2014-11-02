package com.ifeng.share.bean;

import com.ifeng.share.defined.DefinedShare;
/**
 * 
 * @author PJW
 *
 */
public class DefinedShareBean {
	private String name;
	private String type;
	private int num;
	private DefinedShare definedShare;
	public DefinedShareBean() {
	}
	public DefinedShareBean(String type, String name, int num,
			DefinedShare definedShare) {
		this.name = name;
		this.type = type;
		this.num = num;
		this.definedShare = definedShare;
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
	public int getNum() {
		return num;
	}
	public void setNum(int num) {
		this.num = num;
	}
	public DefinedShare getDefinedShare() {
		return definedShare;
	}
	public void setDefinedShare(DefinedShare definedShare) {
		this.definedShare = definedShare;
	}
}
