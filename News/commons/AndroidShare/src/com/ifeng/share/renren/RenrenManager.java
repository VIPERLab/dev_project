package com.ifeng.share.renren;


public class RenrenManager {
	
	/**
	 * 新鲜事标题，最多30个字符，为必须参数
	 */
	public static String filterTitle(String title){
		if (title!=null && title.length()>30) {
			return title.substring(0, 30);
		}
		return title;
	}
	/**
	 * 新鲜事主体内容，最多200个字符，为必须参数
	 */
	public static String filterDescription(String description){
		if (description!=null && description.length()>200) {
			return description.substring(0, 200);
		}
		return description;
	}
	/**
	 * 新鲜事副标题，最多20个字符，为可选参数
	 */
	public static String filterCaption(String caption){
		if (caption!=null && caption.length()>20) {
			return caption.substring(0, 20);
		}
		return caption;
	}
	/**
	 * 新鲜事动作模块文案，最多20个字符，为可选参数
	 */
	public static String filterActionName(String actionName){
		if (actionName!=null && actionName.length()>20) {
			return actionName.substring(0, 20);
		}
		return actionName;
	}
	/**
	 * 用户输入的自定义内容，最多200个字符，为可选参数
	 */
	public static int getRenrenMessageCount(){
		return 200;
	}
	public static String filterMessage(String message){
		if (message!=null && message.length()>200) {
			return message.substring(0, 200);
		}
		return message;
	}
	/*public static Boolean isAuthorizeRenRen(Activity activity){
		ShareRenren shareRenren = new ShareRenren(activity);
		return shareRenren.isAuthorizeRenRen();
	}
	public static void bindRenRen(Activity activity,RenrenAuthorCallback renrenAuthorListener){
		ShareRenren shareRenren = new ShareRenren(activity);
		shareRenren.setRenrenAuthorListener(renrenAuthorListener);
		shareRenren.bindRenren();
	}
	public static void unbindRenRen(Activity activity){
		ShareRenren shareRenren = new ShareRenren(activity);
		shareRenren.unbindRenren();
	}*/
}
