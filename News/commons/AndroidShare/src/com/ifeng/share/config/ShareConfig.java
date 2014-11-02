package com.ifeng.share.config;
/**
 * 系统参数
 * @author PJW
 *
 */
public class ShareConfig {
	/*
	 * renren 
	 */
	public static final String RENREN_APIKEY = "d257c20e0eec4ab0b0821bcf82147e4e";
	public static final String RENREN_SECRET = "a83028c578744047966f6eb7797199fc";
	public static final String RENREN_APPID = "169114";
	/*
	 * sina
	 */
	public static final String SINA_CONSUMER_KEY = "2639294266";
	public static final String SINA_CONSUMER_SECRET = "0746d8a294d7933100ce34aab3d50899";
	public static final String SINA_REDIRECT_URI = "http://m.ifeng.com";
	public static final String SINA_REDIRECT_URI_BACK = "http://m.ifeng.com/#";
	public static final String SINA_RESPONSE_TYPE = "token";
	public static final String SINA_DISPLAY = "mobile";
	public static final String SINA_AUTH_URL = "https://open.weibo.cn/oauth2/authorize";
	public static final String SINA_SCOPE = 
            "email,direct_messages_read,direct_messages_write,"
            + "friendships_groups_read,friendships_groups_write,statuses_to_me_read,"
            + "follow_app_official_microblog," + "invitation_write";
	/*
	 * tenq
	 */
	public static final String TENQT_URIREDIRECT_URI = "http://i.ifeng.com";
	public static final String TENQT_CONSUMER_KEY = "801065646";
	public static final String TENQT_CONSUMER_SECRET = "94375d2f77aaef0ffaec764deae99a00";
	/**
	 * fetion
	 */
	public static final String FETION_CLIENT_ID = "020b9adf0a0dd0aefa6871ed7c271060";
	public static final String FETION_CLIENT_SECRET = "3cf44118e532f6c5ea21c0854a30f4dc";
	/**
	 * tenqz/tenqq
	 */
	public static final String TENQQ_APPID = "100265315";
	public static final String TENQZ_AUTH_URL = "https://openmobile.qq.com/oauth2.0/m_authorize";
	public static final String TENQZ_REDIRECT_URI = "http://open.z.qq.com/moc2/success.jsp";
	public static final String TENQZ_SCOPE = "get_user_info,add_share";
	public static final String TENQZ_RESPONSE_TYPE = "token";
	public static final String TENQZ_DISPLAY = "mobile";
	public static final String TENQZ_SWITH = "1";
	
	
	public static final String defaultTitle="凤凰分享";
	public static final String defaultDescription="来自凤凰网";
	public static final String defaultAutoLine="http://apps.ifeng.com";
}
