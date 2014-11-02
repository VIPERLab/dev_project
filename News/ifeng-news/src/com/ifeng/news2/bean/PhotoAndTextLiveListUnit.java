package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import com.qad.form.PageEntity;

/**
 * @author SunQuan:
 * @version 创建时间：2013-8-22 下午5:27:53 类说明
 */

public class PhotoAndTextLiveListUnit implements Serializable, PageEntity {

	private static final long serialVersionUID = -7124462310917691945L;

	private ArrayList<PhotoAndTextLiveItemBean> content;
	private PhotoAndTextLiveStatus status;
	private PhotoAndTextLiveHeader header;

	public PhotoAndTextLiveStatus getStatus() {
		return status;
	}

	public PhotoAndTextLiveHeader getHeader() {
		return header;
	}

	public void setHeader(PhotoAndTextLiveHeader header) {
		this.header = header;
	}

	public void setStatus(PhotoAndTextLiveStatus status) {
		this.status = status;
	}

	public ArrayList<PhotoAndTextLiveItemBean> getContent() {
		return content;
	}

	public void setContent(ArrayList<PhotoAndTextLiveItemBean> content) {
		this.content = content;
	}

	@Override
	public int getPageSum() {
		return 5;
	}

	@Override
	public List<?> getData() {

		return content;
	}

}
