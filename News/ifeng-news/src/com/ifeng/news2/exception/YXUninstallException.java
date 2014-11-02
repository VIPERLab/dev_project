package com.ifeng.news2.exception;

/**
 * 易信没有安装异常
 * @author chenxix
 *
 */
public class YXUninstallException extends Exception {

	/**
	 * 
	 */
	private static final long serialVersionUID = -1507009450092836387L;

	public YXUninstallException(){
		
	}
	
	public YXUninstallException(String msg){
		super(msg);
	}
	
}
