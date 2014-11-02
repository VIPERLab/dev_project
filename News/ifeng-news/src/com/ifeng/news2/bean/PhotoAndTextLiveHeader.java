package com.ifeng.news2.bean;

import java.io.Serializable;

/**
 * @author SunQuan:
 * @version 创建时间：2013-8-27 上午10:04:37 类说明
 */

public class PhotoAndTextLiveHeader implements Serializable {

	private static final long serialVersionUID = 4375585717096134807L;

	private int total = -1;

	public int getTotal() {
		return total;
	}

	public void setTotal(int total) {
		this.total = total;
	}

}
