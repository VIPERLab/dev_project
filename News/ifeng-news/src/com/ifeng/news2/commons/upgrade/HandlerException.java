package com.ifeng.news2.commons.upgrade;

/**
 * 因解析发生错误
 * 
 * @author 13leaf
 * 
 */
public class HandlerException extends Exception {

	/**
	 * 
	 */
	private static final long serialVersionUID = 2576989261100075466L;

	public HandlerException(Exception exception) {
		super(exception);
	}

}
