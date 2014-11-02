package com.ifeng.news2.bean;

import java.io.Serializable;

public class SlideUnit implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4863690180183542919L;
	private Meta meta = new Meta();
	private SlideBody body = new SlideBody();

	public Meta getMeta() {
		return meta;
	}

	public void setMeta(Meta meta) {
		this.meta = meta;
	}

	public SlideBody getBody() {
		return body;
	}

	public void setBody(SlideBody body) {
		this.body = body;
	}

}
