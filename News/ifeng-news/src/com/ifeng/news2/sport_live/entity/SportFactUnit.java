package com.ifeng.news2.sport_live.entity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import com.qad.form.PageEntity;


/**
 * @author liu_xiaoliang
 * 体育实况数据接口
 */
public class SportFactUnit implements Serializable ,PageEntity{

	private static final long serialVersionUID = -7755035167083609620L;
	private SportMeta meta = new SportMeta();
	private ArrayList<SportFactItem> body = new ArrayList<SportFactItem>();
	public SportMeta getMeta() {
		return meta;
	}
	public void setMeta(SportMeta meta) {
		this.meta = meta;
	}
	public ArrayList<SportFactItem> getBody() {
		return body;
	}
	public void setBody(ArrayList<SportFactItem> body) {
		this.body = body;
	}
	@Override
	public int getPageSum() {
		try {
//			return Integer.parseInt(getMeta().getPageSize());
			//TODO 页数
			return 4;
		} catch (Exception e) {
			return 0;
		}
	}
	@Override
	public List<?> getData() {
		// TODO Auto-generated method stub
		return body;
	}
	
	
}
