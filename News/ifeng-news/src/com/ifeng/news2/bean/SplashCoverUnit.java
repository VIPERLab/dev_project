package com.ifeng.news2.bean;

import java.io.Serializable;

public class SplashCoverUnit implements Serializable{

	private static final long serialVersionUID = 5662271470381096810L;

	private Meta meta = new Meta();
	
	private SplashCoverBody body = new SplashCoverBody();

	public Meta getMeta() {
		return meta;
	}

	public void setMeta(Meta meta) {
		this.meta = meta;
	}

	public SplashCoverBody getBody() {
		return body;
	}

	public void setBody(SplashCoverBody body) {
		this.body = body;
	}
	
}
