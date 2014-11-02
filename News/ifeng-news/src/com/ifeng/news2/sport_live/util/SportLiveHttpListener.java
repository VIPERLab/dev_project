package com.ifeng.news2.sport_live.util;
/**
	 * 登录注册回复发言的监听接口
	 */
	public interface SportLiveHttpListener<T> {
		void preLoad();

		void success(T result);

		void fail(T result);
	}