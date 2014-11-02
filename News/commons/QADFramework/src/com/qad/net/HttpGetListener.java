package com.qad.net;

/**
 * 关于http请求的回调接口
 * @param <T>
 * 
 */
public interface HttpGetListener {

	void preLoad();
	void loadHttpFail();
	void loadHttpSuccess();
}
