package com.ifeng.news2.commons.statistic;

/**
 * 统计发送拦截器
 * @author 13leaf
 *
 */
public interface SendInterceptor {
	/**
	 * 在发送之前拦截。对发送的实体可以进行拦截更改
	 * @param entity
	 * @return
	 */
	String interceptSend(String entity);
}
