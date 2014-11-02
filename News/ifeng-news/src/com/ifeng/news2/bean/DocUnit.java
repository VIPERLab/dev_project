package com.ifeng.news2.bean;

import java.io.Serializable;

import android.text.TextUtils;

public class DocUnit implements Serializable{

	public static final DocUnit NULL=new DocUnit();
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -5639525048604461603L;

	private Meta meta=new Meta();
	
	private DocBody body=new DocBody();

	public Meta getMeta() {
		if(meta==null){
			meta = new Meta();
		}
		return meta;
	}

	public void setMeta(Meta meta) {
		this.meta = meta;
	}

	public DocBody getBody() {
		return body;
	}

	public void setBody(DocBody body) {
		this.body = body;
	}
	
	public static boolean isNull(DocUnit unit)
	{
		return unit==null || unit==NULL ||unit.equals(NULL);
	}
	
	@Override
	public boolean equals(Object o) {
		if(o==null || !(o instanceof DocUnit)) return false;
		DocUnit other=(DocUnit) o;
		return other.meta.equals(meta);
	}
	
	@Override
	public int hashCode() {
		return meta.hashCode() + body.hashCode();
	}
	
	public String getDocumentIdfromMeta() {
		if(!TextUtils.isEmpty(getBody().getDocumentId())){
			return getBody().getDocumentId();
		}else if(!TextUtils.isEmpty(getMeta().getDocumentId())){
			getBody().setDocumentId(getMeta().getDocumentId());
			return getMeta().getDocumentId();
		}else{
			throw new IllegalArgumentException("can't find documentId");
		}
	}

}
