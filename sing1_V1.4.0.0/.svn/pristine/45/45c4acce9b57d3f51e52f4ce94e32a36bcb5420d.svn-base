package cn.kuwo.sing.logic;

import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.content.Context;

import cn.kuwo.framework.config.PreferencesManager;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.SizeUtils;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.LoginResult;
import cn.kuwo.sing.bean.SquareShow;
import cn.kuwo.sing.bean.ThirdInfo;
import cn.kuwo.sing.bean.User;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.logic.service.UserService;
import de.greenrobot.event.EventBus;

public class UserLogic {
	
	private final String TAG = "UserLogic";
	
	public final static int OK = 0;
	public final static int FAIL = -1;
	public final static int ERROR_BASE64_DECODE = 11;   //base64解码失败
	public final static int ERROR_TRANS_CODE = 12;      //转码失败
	public final static int ERROR_UNAME_EMPTY = 13;     //用户名为空
	public final static int ERROR_UNAME_UNEXIST = 14;   //用户不存在
	public final static int ERROR_PWD_INVALID = 15;     //密码不正确
	public final static int ERROR_PARAM_INVALID = 16;   //参数不合法，参数不够
	public final static int ERROR_SERVICE_ERROR = 17;   //某些内部服务不正常，无法正常工作(连不上数据库或KSQL)
	public static String lastUname;
	public static String lastPwd;
	public static boolean isThirdLogin = false;

	public final static int ERROR_USER_INVALID = 18; 
	
	private UserService userservice;
	
	public UserLogic(){
		userservice = new UserService();
	}
	
	public int autoLogin(String uid, String sid) throws IOException{
		String dev_key = AppContext.DEVICE_ID;
		String dev_name = "酷我K歌android客户端";
		LoginResult result = userservice.autoLogin(uid, sid,dev_key, dev_name);
		
		if(result.result == null) {
			return FAIL;
		}
		// ok
		if(result.result.equals("ok")){
			User user = new User();
			user.sid = result.sid;
			user.uid = result.uid;
			user.uname = result.kuwo_username;
			if(Config.getPersistence() != null) 
				user.psw = Config.getPersistence().user.psw;
			user.nickname = result.nickname;
			user.birth_city = result.birth_city;
			user.resident_city = result.resident_city;
			user.birthday = result.birthday;
			user.thirdInfoList = new ArrayList<ThirdInfo>();
			if(result.thirdInfoList != null) {
				user.thirdInfoList.addAll(result.thirdInfoList);
				for(ThirdInfo info : user.thirdInfoList) {
					if(info.third_type.equals("weibo")) {
						user.isBindWeibo = true;
						user.weiboName = info.third_uname;
					}else if(info.third_type.equals("qq")) {
						user.isBindQQ = true;
						user.qqName = info.third_uname;
					}
				}
			}
			saveUser(user);
			//登录ok，获取消息数目
			UserService userService = new UserService();
			HashMap<String, String> params = userService.getNotReadNoticeNum();
			if(params != null && params.get("result") != null) {
				if(params.get("result").equals("ok")) {
					String numStr = params.get("total");
					KuwoLog.i(TAG, "noticeNum="+numStr);
					Config.getPersistence().user.noticeNumber = Integer.parseInt(numStr);
					Config.savePersistence();
				}else if(params.get("result").equals("err")) {
					KuwoLog.i(TAG, "get notice err: "+params.get("msg"));
				}
			}else {
				return FAIL;
			}
			return OK;
		}else if (result.result.equals("err")){
			Config.getPersistence().isLogin = false;
			Config.savePersistence();
			String str = result.reason;
			if(str.equals("error_base64_decode"))
				return ERROR_BASE64_DECODE;
			else if(str.equals("error_trans_code"))
				return ERROR_TRANS_CODE;
			else if(str.equals("error_uname_empty"))
				return ERROR_UNAME_EMPTY;
			else if(str.equals("error_uname_unexist"))
				return ERROR_UNAME_UNEXIST;
			else if(str.equals("error_pwd_invalid"))
				return ERROR_PWD_INVALID;
			else if(str.equals("error_param_invalid"))
				return ERROR_PARAM_INVALID;
			else if(str.equals("error_service_error"))
				return ERROR_SERVICE_ERROR;
		}
		
		return FAIL;
	}
	
	/**
	 * 用户登录
	 * @param uname 用户名
     * @param pwd 密码
     * @param dev_key 登陆终端的唯一标识码
     * @param dev_name 登陆终端的名称（酷我音乐盒PC客户端，酷我音乐盒iphone客户端，酷我DJ等，详细显示名称请咨询产品）
	 * @return result
	 * @throws IOException 
	 */
	
	public int login(String uname, String pwd) throws IOException{
		
		String dev_key = AppContext.DEVICE_ID;
		String dev_name = "酷我K歌android客户端";
		if(userservice == null) 
			userservice = new UserService();
		LoginResult result = userservice.login(uname, pwd,dev_key, dev_name);
		
		// ok
		if(result.result.equals("ok")){
			PreferencesManager.put("isThirdLogin", false).commit();
			User user = new User();
			user.sid = result.sid;
			user.uid = result.uid;
			user.uname = uname;
			user.psw = pwd;
			user.nickname = result.nickname;
			user.birth_city = result.birth_city;
			user.resident_city = result.resident_city;
			user.birthday = result.birthday;
			user.thirdInfoList = new ArrayList<ThirdInfo>();
			if(result.thirdInfoList != null) {
				user.thirdInfoList.addAll(result.thirdInfoList);
				for(ThirdInfo info : user.thirdInfoList) {
					if(info.third_type.equals("weibo")) {
						user.isBindWeibo = true;
						user.weiboName = info.third_uname;
					}else if(info.third_type.equals("qq")) {
						user.isBindQQ = true;
						user.qqName = info.third_uname;
					}
				}
			}
			
			saveUser(user);
			//登录ok，获取消息数目
			UserService userService = new UserService();
			HashMap<String, String> params = userService.getNotReadNoticeNum();
			if(params.get("result").equals("ok")) {
				String numStr = params.get("total");
				KuwoLog.i(TAG, "noticeNum="+numStr);
				Config.getPersistence().user.noticeNumber = Integer.parseInt(numStr);
				Config.savePersistence();
			}else if(params.get("result").equals("err")) {				
				KuwoLog.i(TAG, "get notice err: "+params.get("msg"));
			}
			return OK;
		}else if (result.result.equals("err")){
			Config.getPersistence().isLogin = false;
			Config.savePersistence();
			
			String str = result.reason;
			if(str.equals("error_base64_decode"))
				return ERROR_BASE64_DECODE;
			else if(str.equals("error_trans_code"))
				return ERROR_TRANS_CODE;
			else if(str.equals("error_uname_empty"))
				return ERROR_UNAME_EMPTY;
			else if(str.equals("error_uname_unexist"))
				return ERROR_UNAME_UNEXIST;
			else if(str.equals("error_pwd_invalid"))
				return ERROR_PWD_INVALID;
			else if(str.equals("error_param_invalid"))
				return ERROR_PARAM_INVALID;
			else if(str.equals("error_service_error"))
				return ERROR_SERVICE_ERROR;
			

		}
		
		return FAIL;
	}
	
	public Map<String, SquareShow> getSquareActivityMap() {
		Map<String, SquareShow> squareActivityMap = null;
		List<SquareShow> activityList = userservice.getSquareActivityList();
		if(activityList != null) {
			squareActivityMap = new HashMap<String, SquareShow>();
			for(int i=0; i< activityList.size(); i++) {
				SquareShow activity = activityList.get(i);
				squareActivityMap.put(activity.bangId, activity);
			}
		}
		return squareActivityMap;
	}
	
	public Integer getHrbSquareActivityListId() {
		return userservice.getHrbSquareActivityListId();
	}
	
	public Integer checkUserIsPartInSquareActivity(String src) {
		return userservice.checkUserIsPartInSquareActivity(src);
	}
	
	/**
	 * 用户登出
     * @param uid 用户id
     * @param sid 用户session id
	 * @return result
	 * @throws IOException 
	 */
	public int logout() throws IOException{
		
		
		String sid = null,uid = null;
		if(Config.getPersistence().user != null){
			sid = Config.getPersistence().user.sid;
			uid = Config.getPersistence().user.uid;
		}
		LoginResult result = userservice.logout(uid, sid);
		if(result.result.equals("ok")){
			Config.getPersistence().isLogin = false;
			if(Config.getPersistence().user != null){
				Config.getPersistence().user.uid = null;
				Config.getPersistence().user.sid = null;
			}
			Config.savePersistence();
			return OK;
		}
		else if(result.result.equals("fail")){
			String str = result.reason;
			if(str.equals("error_user_invalid")){
				return ERROR_USER_INVALID;
			}
			else if(str.equals("error_param_invalid")){
				return ERROR_PARAM_INVALID;
			}
			else if(str.equals("error_service_error")){
				return ERROR_SERVICE_ERROR;
			}
		}
		return FAIL;
	}
	
	/**
	 * 用户注册
     * @param name 用户id
     * @param pwd 用户密码
	 * @return result
	 * @throws IOException 
	 */
	public int register(String name, String pwd) throws IOException {
		
		String ver = AppContext.VERSION_NAME;
		
		int result = userservice.register(name, pwd, null, ver,null);
		return result;
		
	}
	
	public Integer lotterying4HrbActivity(Context context, String src, String kid) {
		return userservice.lotterying4HrbActivity(context, src, kid);
	}
	
	
	/**
	 * 用户第三方登录
     * @param type weibo/renren/qq
	 * @return url
	 * @throws IOException 
	 */
	public String loginThirdParty(String type) throws IOException {
		
		String url = userservice.loginThirdParty(type);
		return url;
	}
	
	public String bindThirdParty(String type) throws IOException {
		return userservice.bindThirdParty(type);
	}
	
	/**
	 * 用户第三方登录结果保存
     * @param loginResult 登录结果
	 */
//	public void saveResult(String uid, String username, String sid, String headUrl){
//		if(Config.getPersistence().user != null){
//			
//			Config.getPersistence().user.uid = uid;
//			Config.getPersistence().user.uname = username;
//			Config.getPersistence().user.sid = sid;
//			Config.getPersistence().user.headUrl = headUrl;
//		}
//	}
	
	public void saveUser(User user){
		Config.getPersistence().user = user;
		Config.getPersistence().isLogin = true;
		Config.getPersistence().lastUname = Config.getPersistence().user.uname;
		Config.getPersistence().lastPwd = Config.getPersistence().user.psw;
		Config.savePersistence();
	}
	
	public User getUser() {
		return Config.getPersistence().user;
	}
	/**
	 * 第三方分享
     * @param uid 用户id
     * @param sid 用户session id
	 * @return result
	 * @throws IOException 
	 */
	public int share(String type, String content, InputStream pic) throws IOException {
		String kid = "";
		if(Config.getPersistence().user != null){
			kid = Config.getPersistence().user.uid;
		}
		int result = userservice.shareWeibo(type, kid, content, pic);
		return result;
	}
	/**
	 * 检查俩人是否关注
     * @param tid 要检查和谁的关注关系，就传谁的id 
	 * @return result
	 * @throws IOException 
	 */
	public int checkAction(String tid) throws IOException{
		
		String sid = null,uid = null;
		if(Config.getPersistence().user != null){
			sid = Config.getPersistence().user.sid;
			uid = Config.getPersistence().user.uid;
		}
		int result = userservice.checkAction(uid,tid,sid);
		return result;
	}
	
	/**
	 * 关注某人
     * @param tid 要检查和谁的关注关系，就传谁的id 
	 * @return result
	 * @throws IOException 
	 */
	public int payAction(String tid) throws IOException{
		
		String sid = null,uid = null;
		KuwoLog.i(TAG, "User："+Config.getPersistence().user);
		if(Config.getPersistence().user != null){
			sid = Config.getPersistence().user.sid;
			uid = Config.getPersistence().user.uid;
		}
		int result = userservice.payAttention(uid,tid,sid);
		return result;
	}
	
	/**
	 * 获取当前登录用户当天还剩余可送的鲜花数
	 * @return result
	 * @throws IOException 
	 */
	public int getLeftFlowers() throws IOException{
		
		String sid = null,uid = null;
		if(Config.getPersistence().user != null){
			sid = Config.getPersistence().user.sid;
			uid = Config.getPersistence().user.uid;
		}
		int result = userservice.getLeftFlowersNum(uid, sid);
		return result;
	}
	
	/**
	 * 送花
	 * @param tid 歌曲的id
	 * @return result
	 * @throws IOException 
	 */
	public int avalidFlowers(String tid) throws IOException{
		
		String sid = null,uid = null;
		if(Config.getPersistence().user != null){
			sid = Config.getPersistence().user.sid;
			uid = Config.getPersistence().user.uid;
		}
		int result = userservice.avalidFlowersNum(uid, sid, tid);
		return result;
	}
	
	/**
	 * 访问某人主页
     * @param id 要访问的人的id
	 * @return url
	 * @throws IOException 
	 */
	public List<Kge> getProfile(String id) throws IOException {
		
		List<Kge> kge_list = null;
	    kge_list = userservice.getProfile(id);
		return kge_list;
		
	}
	
	/**
	 * 获取关注网址
	 */
	public String getAttentionUrl(){
		return "http://changba.kuwo.cn/kge/webmobile/an/dynamic.html";
	}
	/**
	 * 获取消息网址
	 */
	public String getNewsUrl(){
		return "http://changba.kuwo.cn/kge/webmobile/an/news.html";
	}
	/**
	 * 获取我的主页网址
	 */
	public String getMyHomeUrl(){
		return "http://changba.kuwo.cn/kge/webmobile/an/myhome.html";
	}
	/**
	 * 获取消息网址
	 *@param uid 要访问的人的id
	 */
	public String getOthersHomeUrl(String uid){
		
		SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyyMMddhhmmss");     
		String date = sDateFormat.format(new java.util.Date());  //时间戳
		String url = "http://changba.kuwo.cn/kge/webmobile/an/userhome.html?=" + date + "=" + uid;
		return url;
	}
	
	public int unBindThirdAccount(String uid, String sid, String type) {
		return userservice.unBindThirdAccount(uid, sid, type);
	}
	
	/**
	 * 获取我的信息（"total":1,"shenhe":0,"fav":1,"cmt":0,"cmt_reply":0,"flower":0）
	 */
	public HashMap<String, String> getNotReadNum() throws IOException {
		HashMap<String, String> params = null;
		params = userservice.getNotReadNoticeNum();
		return params;
		
	}
	/**
	 * 获取总分排名{"result":"ok","lower":0,"total":0}
	 * @param rid 伴奏带id
	 * @param score 分数
	 * @return String 排名
	 */
	public String getTotalScore(String rid, String score) throws IOException{
		return userservice.getTotalScore(rid, score);
	}
	
	/**
	 * 修改个人资料{"result":"ok"}
	 * @return 
	 */
	public boolean editMyData(String nickname, String birth_city, String resident_city, String birthday)  throws IOException{
		String sex = "0";
		return userservice.editMyData( nickname,  sex,  birth_city,  resident_city,  birthday);
	}
	

}
