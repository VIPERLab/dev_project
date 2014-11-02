package com.ifeng.news2.exception;

/**
 * 微信没有安装异常
 * @author chenxix
 *
 */
public class WXUninstallException extends Exception {

	/**
	 * 
	 */
	private static final long serialVersionUID = -1547388381059819756L;
	
	public WXUninstallException(){
		
	}
	
	public WXUninstallException(String msg){
		super(msg);
	}

}
