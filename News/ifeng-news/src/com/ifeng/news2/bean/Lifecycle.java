package com.ifeng.news2.bean;

import java.io.Serializable;

/** 
 * @ClassName: Lifecycle 
 * @Description: 有效时间区间
 * @author liu_xiaolaing@ifeng.com 
 * @date 2013-3-11 下午2:45:26  
 */ 
public class Lifecycle implements Serializable{

	private static final long serialVersionUID = 2774874286271967590L;

	//秒级
	private long start;
	private long end;
	public long getStart() {
		return start;
	}
	public void setStart(long start) {
		this.start = start;
	}
	public long getEnd() {
		return end;
	}
	public void setEnd(long end) {
		this.end = end;
	}

}
