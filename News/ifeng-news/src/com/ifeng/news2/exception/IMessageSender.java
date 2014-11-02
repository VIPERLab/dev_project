package com.ifeng.news2.exception;

public interface IMessageSender {
	
	//warn
	public static final int REQUES_TIMEOUT_TOAST = 1000;
	public static final int MESSAGE_TYPE_UNKNOW = 1001;
	
	//notify
	public static final int IMAGE_DOWNLOAD_SUCCESS = 2000;
	public static final int IMAGE_DOWNLOAD_FAIL = 2001;
	public static final int DATA_LOAD_SUCCESS = 2002;
	public static final int DATA_LOAD_FAIL = 2003;
	public static final int DATA_LOAD_START = 2004;
	public static final int REQUES_TIMEOUT = 2005;
	public static final int NETWORK_INVALIABLE = 2006;
	public static final int DATA_REFRESH_SUCCESS = 2007;
	public static final int DATA_REFRESH_FAIL = 2008;
	public static final int DOWNLOAD_FAIL = 2009;
	public static final int DOWNLOAD_SUCESS = 2010;
	public static final int DOWNLOAD_PROTOCOL_ERROR = 2011;
	public static final int DOWNLOAD_NET_ALERT = 2012;
	/**
	 * 发送消息
	 * @param type 消息类型	
	 * @param obj 消息实体
	 */
	public void sendMessage(int type,Object obj);
	
}
