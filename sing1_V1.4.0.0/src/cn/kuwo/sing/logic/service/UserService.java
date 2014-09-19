package cn.kuwo.sing.logic.service;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.xmlpull.v1.XmlPullParser;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.text.TextUtils;
import android.util.Xml;
import cn.kuwo.framework.crypt.Base64Coder;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.network.HttpProvider;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.LoginResult;
import cn.kuwo.sing.bean.NoticeResult;
import cn.kuwo.sing.bean.SquareShow;
import cn.kuwo.sing.bean.ThirdInfo;
import cn.kuwo.sing.bean.User;
import cn.kuwo.sing.context.Config;

public class UserService extends DefaultService {
	private final String TAG = "UserService";
	
	/**
	 * 用户登录
	 * @param uname 用户名
     * @param pwd 密码
     * @param pk 加密串
     * @param dev_key 登陆终端的唯一标识码
     * @param dev_name 登陆终端的名称（酷我音乐盒PC客户端，酷我音乐盒iphone客户端，酷我DJ等，详细显示名称请咨询产品）
	 * @throws IOException 
	 */
	public LoginResult login(String uname, String pwd, String dev_key, String dev_name) throws IOException {
		
		String enuname = URLEncoder.encode(uname,"utf8");
		String enpwd = URLEncoder.encode(pwd,"utf8");
		String endev_key = URLEncoder.encode(dev_key,"utf8");
		String endev_name = URLEncoder.encode(dev_name,"utf8");
		String url = null;
		url = String.format("http://changba.kuwo.cn/kge/mobile/Login?uname=%s&pwd=%s&devKey=%s&devName=%s&pk=%s&reqEnc=%s&respEnc=%s",
				enuname,enpwd,endev_key,endev_name, "", "utf8", "utf8");
		
		KuwoLog.i(TAG, "url="+url);
		String data = null;
		data = read(url);
		KuwoLog.i(TAG, "data="+data);
		
		LoginResult loginResult = new LoginResult();
		try {
			JSONObject dataObj = new JSONObject(data);
			loginResult.result = dataObj.getString("result");
			KuwoLog.i(TAG, "result="+loginResult.result);
			if(loginResult.result.equals("ok")) {
				loginResult.uid = dataObj.getString("uid");
				loginResult.kuwo_username = dataObj.getString("uname");
				loginResult.sid = dataObj.getString("sid");
				loginResult.kwpwd = dataObj.getString("pwd");
				loginResult.nickname = dataObj.getString("nickname");
				loginResult.sex = dataObj.getString("sex");
				loginResult.birth_city = dataObj.getString("birth_city");
				loginResult.resident_city = dataObj.getString("resident_city");
				loginResult.birthday = dataObj.getString("birthday");
				loginResult.vip = dataObj.getString("vip");
//				if(null != dataObj.getString("headpic")) {
//					logResult.headpic = dataObj.getString("headpic");
//				}
				
				JSONArray thirdInfo = dataObj.getJSONArray("3rdInf");
				if(thirdInfo.length() > 0) {
					ArrayList<ThirdInfo> thirdInfoList = new ArrayList<ThirdInfo>();
					for(int i = 0; i < thirdInfo.length(); i++) {
						JSONObject thirdInfoObj = (JSONObject) thirdInfo.get(i);
						ThirdInfo info = new ThirdInfo();
						info.third_type = thirdInfoObj.getString("type");
						info.third_id = thirdInfoObj.getString("id");
						info.third_uname = thirdInfoObj.getString("uname");
						info.third_headpic = thirdInfoObj.getString("headpic");
						info.third_expire = thirdInfoObj.getBoolean("expire");
						thirdInfoList.add(i, info);
					}
					loginResult.thirdInfoList = thirdInfoList;
				}
			}else if(loginResult.result.equals("err")) {
				KuwoLog.i(TAG, "用户名或密码错误！");
				loginResult.reason = dataObj.getString("errMsg");
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return loginResult;
	}
	
	public LoginResult autoLogin(String uid, String sid, String dev_key, String dev_name) throws IOException {
		 //String uid = URLEncoder.encode(_uid,"utf8");
//		String sid = URLEncoder.encode(_sid,"utf8");
		String endev_key = URLEncoder.encode(dev_key,"utf8");
		String endev_name = URLEncoder.encode(dev_name,"utf8");
		String url = null;
		url = String.format("http://changba.kuwo.cn/kge/mobile/Login?autologin=1&userid=%s&sid=%s&devKey=%s&devName=%s&pk=%s&reqEnc=%s&respEnc=%s",
				uid,sid,endev_key,endev_name, "", "utf8", "utf8");
		
		KuwoLog.i(TAG, "url="+url);
		String data = null;
		data = read(url);
		KuwoLog.i(TAG, "data="+data);
		
		LoginResult loginResult = new LoginResult();
		try {
			JSONObject dataObj = new JSONObject(data);
			loginResult.result = dataObj.getString("result");
			KuwoLog.i(TAG, "result="+loginResult.result);
			if(loginResult.result.equals("ok")) {
				loginResult.uid = dataObj.getString("uid");
				loginResult.kuwo_username = dataObj.getString("uname");
				loginResult.sid = dataObj.getString("sid");
				loginResult.kwpwd = dataObj.getString("pwd");
				loginResult.nickname = dataObj.getString("nickname");
				loginResult.sex = dataObj.getString("sex");
				loginResult.birth_city = dataObj.getString("birth_city");
				loginResult.resident_city = dataObj.getString("resident_city");
				loginResult.birthday = dataObj.getString("birthday");
				loginResult.vip = dataObj.getString("vip");
//				if(null != dataObj.getString("headpic")) {
//					logResult.headpic = dataObj.getString("headpic");
//				}
				
				JSONArray thirdInfo = dataObj.getJSONArray("3rdInf");
				if(thirdInfo.length() > 0) {
					ArrayList<ThirdInfo> thirdInfoList = new ArrayList<ThirdInfo>();
					for(int i = 0; i < thirdInfo.length(); i++) {
						JSONObject thirdInfoObj = (JSONObject) thirdInfo.get(i);
						ThirdInfo info = new ThirdInfo();
						info.third_type = thirdInfoObj.getString("type");
						info.third_id = thirdInfoObj.getString("id");
						info.third_uname = thirdInfoObj.getString("uname");
						info.third_headpic = thirdInfoObj.getString("headpic");
						info.third_expire = thirdInfoObj.getBoolean("expire");
						thirdInfoList.add(i, info);
					}
					loginResult.thirdInfoList = thirdInfoList;
				}
			}else if(loginResult.result.equals("err")) {
				KuwoLog.i(TAG, "用户名或密码错误！");
				loginResult.reason = dataObj.getString("errMsg");
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return loginResult;
	}
	
	/**
	 * 用户登出
	 * @param uid 用户id
     * @param sid 用户session id
	 * @throws IOException 
	 */
	public LoginResult logout(String uid, String sid) throws IOException {
		String url = String.format("http://changba.kuwo.cn/kge/mobile/Logout?uid=%s&sid=%s&reqEnc=utf8&respEnc=utf8",uid,sid);
		String data = read(url);
		LoginResult logResult = new LoginResult();
		
		try {
			JSONObject dataObj = new JSONObject(data);
			logResult.result = dataObj.getString("result");
			if("err".equals(logResult.result)) {
				logResult.errMsg = dataObj.getString("errMsg");
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return logResult;
	}
	
	/**
	 * 第三方登录
	 * @param type weibo/renren/qq
	 * @throws IOException 
	 */
	public String loginThirdParty(String type) throws IOException {
//		String url = "http://60.28.205.41/US/platform/orig_kwsing.htm?t=" + type +"&src=kwsing_andriod&_="+System.currentTimeMillis();
		String url = "http://i.kuwo.cn/US/platform/orig_kwsing.htm?t=" + type +"&src=kwsing_andriod&_="+System.currentTimeMillis();
		return url;
	}
	
	public String bindThirdParty(String type) throws IOException {
		String kid = "",sid = "";
		if(Config.getPersistence().user != null) {
			kid = Config.getPersistence().user.uid;
			sid = Config.getPersistence().user.sid;
		}
//		return "http://60.28.205.41/US/platform/orig_kwsing.htm?t=" + type +"&src=kwsing_andriod&kid=" + kid +"&sid=" + sid +"&sync=1&_="+System.currentTimeMillis();
		return "http://i.kuwo.cn/US/platform/orig_kwsing.htm?t=" + type +"&src=kwsing_andriod&kid=" + kid +"&sid=" + sid +"&sync=1&_="+System.currentTimeMillis();
	}
	
	/**
	 * 接收用户分享K歌作品的微博发送请求
	 * @param t weibo/renren/qq
	 * @param kid 酷我id
     * @param cont 微博内容
     * @param pic 微博图片二进制流 
	 * @throws IOException 
	 */
	public int shareWeibo(String t, String kid, String cont, InputStream pic) throws IOException {
		//TODO cxh 还未成功
		String url = "http://mboxspace.kuwo.cn/ks/mobile/pubWeiBo";

		String picture = null;
		if(pic != null)
			picture = pic.toString();
		String content = URLEncoder.encode(cont,"utf-8");
		String data = String.format("t=%s&kid=%s&src=kwsing_andriod&cont=%s&pic=%s",t,kid,content,picture);
		
		KuwoLog.d(TAG, "data: " + data);
		String result = post(url, data);
		KuwoLog.d(TAG, "result: " + result);
		int feedback = 0;
		if(result == null){
	    	return feedback;
	    }
		if(result.equals("r=0")){
//			feedback = "授权过期";
			feedback = AUTHORIZATION_EXPIRED;
	   	}
		else if(result.equals("r=1")){
//			feedback = "发送成功";
			feedback = SENT_SUCCESSFULLY;
		}
		else if(result.equals("r=2")){
//			feedback = "发送失败，需重试";
			feedback = SENT_FAILURE;
		}
		else if(result.equals("r=3")){
//			feedback = "未关连该t类型的第三方账户";
			feedback = UNASSOCIATED;
		}
		else if(result.equals("r=4")){
//			feedback = "系统错误，稍候重试";
			feedback = SYSTEM_ERROR;
		}
		return feedback;
	}
	
	public int shareByThird(String t, String cont, String uid, String sid) {
		String url = String.format("http://changba.kuwo.cn/kge/mobile/pubWeiBo?t=%s&src=%s&cont=%s&uid=%s&sid=%s", t, "kwsing_andriod", URLEncoder.encode(cont), uid, sid);
//		String url = String.format("http://60.28.205.41/kge/mobile/pubWeiBo?t=%s&src=%s&cont=%s&uid=%s&sid=%s", t, "kwsing_andriod", URLEncoder.encode(cont), uid, sid);
		KuwoLog.e(TAG, "share Url="+url);
		String result = post(url, "");
		KuwoLog.i(TAG, "t="+t+",share result="+result);
		JSONObject jsonObj = null;
		if(result == null) {
			return 0;
		}
		try {
			jsonObj = new JSONObject(result);
			result = (String)jsonObj.get(t);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		try {
			return Integer.parseInt(result);
		} catch (NumberFormatException e){
			KuwoLog.printStackTrace(e);
			return 0;
		}
	}
	
	public List<SquareShow> getSquareActivityList() {
		List<SquareShow> squareActivityList = null;
//		String url = "http://60.28.205.41:8180/kge/mobile/ActivityServer?act=banglistid";
		String url = "http://changba.kuwo.cn/kge/mobile/ActivityServer?act=banglistid";
		try {
			String responseData = read(url);
			JSONObject jsonObject = new JSONObject(responseData);
			String result = jsonObject.getString("result");
			if(!TextUtils.isEmpty(result) && result.equals("ok")) {
				JSONArray activityArray = jsonObject.getJSONArray("activity");
				squareActivityList = new ArrayList<SquareShow>();
				for(int i=0; i < activityArray.length(); i++) {
					JSONObject activityObj = (JSONObject)activityArray.get(i);
					SquareShow activity = new SquareShow();
					activity.type = activityObj.getString("type");
					activity.bangId = activityObj.getString("bangId");
					activity.zip = activityObj.getString("zip");
					activity.sharecont = activityObj.getString("sharecont");
					squareActivityList.add(activity);
				}
			}else if(!TextUtils.isEmpty(result) && result.equals("err")) {
				KuwoLog.e(TAG, "参数错误");
			}else {
				KuwoLog.e(TAG, "服务端数据错误");
			}
		} catch (JSONException e) {
			KuwoLog.printStackTrace(e);
		} catch (UnknownHostException e) {
			KuwoLog.printStackTrace(e);
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
		return squareActivityList;
	}
	
	public Integer getHrbSquareActivityListId() {
		Integer resultInteger = null;
		String url = "http://changba.kuwo.cn/kge/mobile/ActivityServer?act=bangid&src=HRB";
		try {
			String responseData = read(url);
			JSONObject jsonObject = new JSONObject(responseData);
			String result = jsonObject.getString("result");
			if(!TextUtils.isEmpty(result) && result.equals("ok")) {
				String bangid = jsonObject.getString("bangid");
				if(!TextUtils.isEmpty(bangid) ) {
					resultInteger = Integer.valueOf(bangid);
				}
			}else if(!TextUtils.isEmpty(result) && result.equals("err")) {
				KuwoLog.e(TAG, "参数错误");
			}else {
				KuwoLog.e(TAG, "服务端数据错误");
			}
		} catch (JSONException e) {
			KuwoLog.printStackTrace(e);
		} catch (UnknownHostException e) {
			KuwoLog.printStackTrace(e);
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
		
		return resultInteger;
	}
	
	public Integer checkUserIsPartInSquareActivity(String src) {
		Integer resultInteger = null;
		String uid = "", ssid = "";
		if(Config.getPersistence().user != null){
			uid = Config.getPersistence().user.uid;
			ssid = Config.getPersistence().user.sid;
		}
		String url = String.format("http://changba.kuwo.cn/kge/mobile/ActivityServer?act=ispartin&uid=%s&sid=%s&src=%s", 
				uid, ssid, src);
		KuwoLog.d(TAG, "checkUserIsPartIn url="+url);
		try {
			//={"result":"err","msg":"sid错误","ispartin":"0"}
			String responseData = read(url);
			KuwoLog.d(TAG, "checkUserIsPartIn responseData="+responseData);
			JSONObject jsonObject = new JSONObject(responseData);
			String result = jsonObject.getString("result");
			if(!TextUtils.isEmpty(result) && result.equals("ok")) {
				String ispartin = jsonObject.getString("ispartin");
				if(!TextUtils.isEmpty(ispartin) ) {
					resultInteger = Integer.valueOf(ispartin);
				}
			}else if(!TextUtils.isEmpty(result) && result.equals("err")) {
				KuwoLog.e(TAG, "参数错误");
			}else {
				KuwoLog.e(TAG, "服务端数据错误");
			}
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		} catch (JSONException e) {
			KuwoLog.printStackTrace(e);
		}
		
		return resultInteger;
	}
	
	public HashMap<String, String> getMyInformation() throws IOException {
		
		String uid = "";
		if(Config.getPersistence().user != null){
			uid = Config.getPersistence().user.uid;
		}
		HashMap<String, String> params = null;
		String url = "http://loginserver.kuwo.cn/u.s?type=getinfo&uid=" + uid + "&req_enc=utf8&res_enc=utf8";
		String data = null;
	    data = read(url.toString());
		KuwoLog.d(TAG, "data: " + data);
		params = splitParams(data,"\r\n");
		return params;
	}
	
	public Integer lotterying4HrbActivity(Context context, String src, String kid) {
		Integer resultInteger = null;
		String uid = "", ssid = "";
		if(Config.getPersistence().user != null){
			uid = Config.getPersistence().user.uid;
			ssid = Config.getPersistence().user.sid;
		}
		String key = "dxFLTEs6v"; 
		String v = getAppVersionName(context);
		String url = String.format("http://changba.kuwo.cn/kge/mobile/ActivityServer?act=draw&uid=%s&sid=%s&key=%s&src=%s&v=%s&kid=%s", 
				uid, ssid, key, src, v, kid);
		String responseData;
		try {
			responseData = read(url);
			JSONObject jsonObject = new JSONObject(responseData);
			String result = jsonObject.getString("result");
			if(!TextUtils.isEmpty(result) && result.equals("ok")) {
				String isdraw = jsonObject.getString("isdraw");
				if(!TextUtils.isEmpty(isdraw) ) {
					resultInteger = Integer.valueOf(isdraw);
				}
			}
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		} catch (JSONException e) {
			KuwoLog.printStackTrace(e);
		}
		//{“result”:”ok”,”isdraw”:”1”}
		return resultInteger;
	}
	
	/**
	 * 返回当前程序版本名
	 * 
	 * @param context
	 * @return
	 */
	private String getAppVersionName(Context context) {
		String versionName = "";
		try {
			// ---get the package info---
			PackageManager pm = context.getPackageManager();
			PackageInfo pi = pm.getPackageInfo(context.getPackageName(), 0);
			versionName = pi.versionName;
			if (versionName == null || versionName.length() <= 0) {
				return "";
			}
		} catch (Exception e) {
			KuwoLog.printStackTrace(e);
		}
		return versionName;
	}
	
	public static final int AUTHORIZATION_EXPIRED = 0;
	public static final int SENT_SUCCESSFULLY = 1;
	public static final int SENT_FAILURE = 2;
	public static final int UNASSOCIATED = 3;
	public static final int SYSTEM_ERROR = 4;
	
	public static final int NO_LOGIN = -1; //没有登录
	public static final int UPPERLIMIT = -2;   //达到送花上限，今日不能再送
	public static final int KGE_DEL_OR_SHENHE = -3;  //当前作品已被删除或在审核当中
	public static final int NOT_EXIST = -4;  //当前作品不存在
	
	public static final int ATTENTION = 10;  //已经关注
	public static final int NOATTENTION = 11;  //未关注
	public static final int PARAM_ERR = 12;  //参数错误
	
	public static final int ATTENTION_SUCCESSFUL = 13;  //关注成功
	public static final int ATTENTION_FAILURE = 14;  //关注失败
	
	public static final int UPLOAD_LIMIT = 20;
	public static final int FILESIZE_LIMIT = 21;
	public static final int SUCCESS = 22;
	
	
	/**
	 * 注册用户接口
	 * @param name 用户名 
	 * @param pwd 密码
     * @param sid session id
     * @param ver 软件版本号
     * @param src  
	 * @throws IOException 
	 */
	public int register(String name, String pwd, String sid, String ver, String src) throws IOException {
		
		String url = "http://kzone.kuwo.cn/mlog/client/RegService";

		byte[] uname = name.getBytes("GB18030");
		char[] namestr = Base64Coder.encode(uname, uname.length);
		byte[] upwd = pwd.getBytes("GB18030");
		char[] pwdstr = Base64Coder.encode(upwd, upwd.length);
		
		byte[] uver = ver.getBytes("GB18030");
		char[] verstr = Base64Coder.encode(uver, uver.length);
		
		String username = new String(namestr);
		String userpwd = new String(pwdstr);
		String userver = new String(verstr);
		
		String usernames = URLEncoder.encode(username,"utf8");
		String userpwds = URLEncoder.encode(userpwd,"utf8");
		String uservers = URLEncoder.encode(userver,"utf8");

		String data= String.format("name=%s&pwd=%s&sid=%s&ver=%s&src=%s",usernames,userpwds,null,uservers,null);

		String result = posts(url, data);
		KuwoLog.d(TAG, "data:"+data+" register result="+result);
		int feedback = 0;
		if(result.startsWith("#200#")){
			// 注册成功
			feedback = SUCCESSFUL_REGISTRATION;
			Config.getPersistence().rememberUserInfo = true;
			User user = new User();
			Config.getPersistence().user = user;
			Config.getPersistence().user.uid = result.substring(result.indexOf('|')+1);
			Config.getPersistence().user.uname = name;
			Config.getPersistence().user.psw = pwd;
			Config.savePersistence();
	   	}
		else if(result.startsWith("#550#|1")){
			// 用户名已被注册
			feedback = REGISTERED;
		}
		else if(result.startsWith("#550#|2")){
			// 操作失败
			feedback = OPERATE_FAILURE;
		}
		return feedback;
	 }
	
	
	private String posts(String url, String data) {
		PrintWriter out = null; 
		BufferedReader in = null; 
		StringBuffer result = new StringBuffer(); 
		try {
			URL realUrl = new URL(url); 
			// 打开和URL之间的连接 
			HttpURLConnection conn = (HttpURLConnection) realUrl.openConnection(); 
	
			// 发送POST请求必须设置如下两行 
			conn.setDoOutput(true); 
			conn.setDoInput(true); 
			
			conn.setRequestMethod("POST");
			// 获取URLConnection对象对应的输出流 
			out = new PrintWriter(conn.getOutputStream()); 
			// 发送请求参数 
			out.print(data); 
			// flush输出流的缓冲 
			out.flush(); 
			// 定义BufferedReader输入流来读取URL的响应 
			in = new BufferedReader(new InputStreamReader(conn.getInputStream())); 
			String line = ""; 
			while ((line = in.readLine()) != null) { 
				result.append(line); 
				}
			} catch (Exception e) {
				
			}
		finally {
			try {
				if (out != null) { 
					out.close(); 
					out = null; 
				} 
				if (in != null) { 
					in.close(); 
					in = null; 
				}
				} catch (Exception ex) {
					
				} 
			}
		return result.toString();
		
	}
	
	/**
	 * 检查两人关系接口
	 * @param uid 登录用户id 
	 * @param tid 要检查和谁的关注关系，就传谁的id 
     * @param sid session id
	 * @throws IOException 
	 */
	public int checkAction(String uid,String tid,String sid) throws IOException{
		
		String url = String.format("http://changba.kuwo.cn/kge/mobile/FollowOperat?act=chk&uid=%s&sid=%s&tid=%s",uid,sid,tid);
		String data = null;
		KuwoLog.d(TAG, "url" + url);
	    data = read(url.toString());
	    KuwoLog.d(TAG, "data" + data);
	    
	    KuwoLog.d(TAG, "DATA:"+data);
	    HashMap<String, String> params = new HashMap<String, String>();
	    params = splitParams(data, "&");
//	    params = sepResult(data);
	    String result = params.get("result");
	    if(result == null) return PARAM_ERR;
	    if(result.equals("ok")){
	    	 String rel = params.get("rel");
	    	 if(rel.equals("1"))
	    		 return ATTENTION;
	    	 else if(rel.equals("0"))
	    		 return NOATTENTION;
	    }
	    else if(result.equals("err")){
		    String msg = params.get("msg"); 
			if(msg.equals("param_err"))
				return PARAM_ERR;
			else if(msg.equals("no_login"))
				return NO_LOGIN;
			else if(msg.equals("sys_err"))
				return SYSTEM_ERROR;
	    }
	    
		return PARAM_ERR;
	}
	
	/**
	 * 关注某人接口
	 * @param fid 登录用户id 
	 * @param tid 要关注的人的id
     * @param sid session id
	 * @throws IOException 
	 */
	public int payAttention(String fid,String tid,String sid) throws IOException{
		
		KuwoLog.i(TAG, "uid="+fid+",tid="+tid+",sid="+sid);
		String url = String.format("http://changba.kuwo.cn/kge/mobile/userAction?fid=%s&tid=%s&sid=%s&type=care",fid,tid,sid);
		String data = null;
		
		KuwoLog.d(TAG, "data" + url);
	    data = read(url.toString());
	    
	    KuwoLog.d(TAG, "data: " + data);
	    HashMap<String, String> params = new HashMap<String, String>();
//	    params = sepResult(data);
	    params = splitParams(data, "&");
	    String result = params.get("result");
	    if(result.equals("ok")){
	    	return ATTENTION_SUCCESSFUL;
	    }
	    else if(result.equals("err")){
		    String msg = params.get("msg");
			return ATTENTION_FAILURE;
	    }
	    
		return ATTENTION_FAILURE;
	}
	
//	http://changba.kuwo.cn/kge/mobile/userAction?fid=123&tid=456&sid=111111&type=care
//		fid:发起人id（a关注b，则为a的id）http://changba.kuwo.cn/kge/mobile/FollowOperat?act=chk&uid=%s&sid=%s&tid=%s
//		tid：接受人id
//		sid：fid的登录后的sessionid（前提是：必须要先登录才能关注）
//		type：care
//		 
//		返回：
//		1、result=ok
//		2、result=err&msg=xxxx
	
	public static final int SUCCESSFUL_REGISTRATION = 5;
	public static final int REGISTERED = 6;
	public static final int OPERATE_FAILURE = 7;
	
	/**
	  * 获取当前登录用户当天还剩余可送的鲜花数
	  * @param uid 
	  * @param sid 
	  * @return 
	  */	
	public int getLeftFlowersNum(String uid, String sid){
		String url = "http://changba.kuwo.cn/kge/mobile/KgeFlower";
		
//		{"result":"ok","leftFlower":1}
//		{"result":"err","msg":"no login"}
		
		String data = "uid=" + uid +"&sid=" + sid;
		PrintWriter out = null; 
		BufferedReader in = null; 
		StringBuffer result = new StringBuffer(); 
		try {
			URL realUrl = new URL(url + "?" + data); 
			// 打开和URL之间的连接 
			HttpURLConnection conn = (HttpURLConnection) realUrl.openConnection(); 

			// 定义BufferedReader输入流来读取URL的响应 
			in = new BufferedReader(new InputStreamReader(conn.getInputStream())); 
			String line = ""; 
			while ((line = in.readLine()) != null) { 
				result.append(line); 
				}
			} catch (Exception e) {
				
			}
		finally {
			try {
				if (out != null) { 
					out.close(); 
					out = null; 
				} 
				if (in != null) { 
					in.close(); 
					in = null; 
				}
				} catch (Exception ex) {
					
				} 
			}
	    
		HashMap<String, String> params = new HashMap<String, String>();
		params = sepFlowerResult(result.toString());
		
		String res = params.get("result");
		if(res == null) {
			return NO_LOGIN;
		}
		if(res.equals("ok")){
			String str = params.get("leftFlower");
			if(str == null ||str.trim().equals(""))
				return NO_LOGIN;
			else 
				return Integer.parseInt(str);
		}
		else if(res.equals("err")){
			if(params.get("msg").equals("no login"))
				return NO_LOGIN;
		}
		return NO_LOGIN;
	}
	 
	/**
	  * 给作品送花
	  * @param uid 
	  * @param sid 
	  * @param tid
	  * @return 
	  */	
	public int avalidFlowersNum(String uid, String sid,String tid){
		String url = "http://changba.kuwo.cn/kge/mobile/KgeFlower";
		String data = String.format("uid=%s&sid=%s&id=%s&tv=1",uid,sid,tid);
		url = url +"?"+ data;
		String result = post(url, data);
		KuwoLog.d(TAG, "data:"+ data +"  result:" + result);
		HashMap<String, String> params = new HashMap<String, String>();
		if(result == null){
			return NO_LOGIN;
		}
		params = sepFlowerResult(result);
	
		String res = params.get("result");
		if(res.equals("ok")){
			String str = params.get("avalidFlower");
			if(str == null ||str.trim().equals(""))
				return NO_LOGIN;
			else 
				return Integer.parseInt(str);
		}
		else if(res.equals("err")){
			String str = params.get("msg");
			if(str.equals("no login"))
				return NO_LOGIN;
			else if(str.equals("upperLimit"))
				return UPPERLIMIT;
			else if(str.equals("kge del or shenhe"))
				return KGE_DEL_OR_SHENHE;
			else if(str.equals("not exist"))
				return NOT_EXIST;
			
		}
		return NO_LOGIN;
	}
//	
//	public static final int UPPERLIMIT = -2;
//	public static final int KGE_DEL_OR_SHENHE = -3;
//	public static final int NOT_EXIST = -4;
	
	public List<Kge> readXML(InputStream inStream) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			Kge currentKge = null;
			List<Kge> kge_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					kge_list = new ArrayList<Kge>();
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("kge")) {
						currentKge = new Kge();
						currentKge.id = "";
					}else if (currentKge != null) {
						if (name.equalsIgnoreCase("id")) {
							currentKge.id = parser.nextText();
						} 
						if (name.equalsIgnoreCase("title")) {
							currentKge.title = parser.nextText();
//						} else if (name.equalsIgnoreCase("time")) {	// TODO CXH
//							currentKge.setTime(parser.nextText());
						}else if (name.equalsIgnoreCase("view")) {
							currentKge.view = Integer.parseInt(parser.nextText());
						}else if (name.equalsIgnoreCase("comment")) {
							currentKge.comment = Integer.parseInt(parser.nextText());
						}else if (name.equalsIgnoreCase("flower")) {
							currentKge.flower = Integer.parseInt(parser.nextText());
						}else if (name.equalsIgnoreCase("src")) {
							currentKge.src = parser.nextText();
						}else if (name.equalsIgnoreCase("sid")) {
							currentKge.sid = Integer.parseInt(parser.nextText());
						}
					}
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("kge")
							&& currentKge != null) {
						kge_list.add(currentKge);
						currentKge = null;
					}
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
//			KuwoLog.d(TAG, "4  " + kge_list.size() + "kk" + kge_list.get(0).id + kge_list.get(1).id);
			return kge_list;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

//	public String getProfiles(String id) {
//		
//	}
	
	/**
	  * 获取用户个人主页内容（基本信息、作品列表）接口
	  * @param id 要访问的用户id 
	  * @return 
	  */	
	public List<Kge> getProfile(String id) throws IOException{
		String loginid = null;
		String sid = null;
		if(Config.getPersistence().user != null){
			loginid = Config.getPersistence().user.uid;
			sid = Config.getPersistence().user.sid;
		}
		String url;
		if(loginid != null){
			url = String.format("http://changba.kuwo.cn/kge/mobile/User?id=%s&loginid=%s&sid=%s",id,loginid,sid);
		}
		else
			url = "http://changba.kuwo.cn/kge/mobile/User?id=" + id + "&loginid=&sid=";
		String result = read(url.toString());
		ByteArrayInputStream stream = new ByteArrayInputStream(result.getBytes());
		List<Kge> kge_list = null;
		kge_list = readXML(stream);
		
		return kge_list;
	}
	
	/**
	  * 获取我的未读提醒消息列表
	  * @return 
	  */	
	public NoticeResult getNotReadNoticeList() throws IOException{
		String sid = null,uid = null;
		if(Config.getPersistence().user != null){
			uid = Config.getPersistence().user.uid;
			sid = Config.getPersistence().user.sid;
		}
		String url = String.format("http://changba.kuwo.cn/kge/mobile/Notice?uid=%s&sid=%s",uid,sid);
		String data = read(url.toString());
		KuwoLog.d(TAG, "data::::"+data);
		
		NoticeResult noticeResult = new NoticeResult();
		HashMap<String, String> params = new HashMap<String, String>();
		int indexfirst = data.indexOf("[");   //"["在结果字符串中的下标
		if(indexfirst < 0){
			//如果不含[，表示结果是err
			params = sepFlowerResult(data);
			noticeResult.setResult(params.get("result"));
			noticeResult.setMsg("no login");
			noticeResult.nlist = null;
		}
		else {
			//结果是ok的情况
			int indexsecond = data.indexOf("]");  //"]"在结果字符串中的下标
			String str = "{" + data.substring(indexsecond + 2);
			
			//解析除list以外的notice实体
			KuwoLog.d(TAG, "str1:" + str);
			params = sepFlowerResult(str);
			noticeResult.setShenheCnt(Integer.parseInt(params.get("shenheCnt")));
			noticeResult.setFansCnt(Integer.parseInt(params.get("fansCnt")));
			noticeResult.setFlowerCnt(Integer.parseInt(params.get("flowerCnt")));
			noticeResult.setCmtCnt(Integer.parseInt(params.get("cmtCnt")));
			noticeResult.setCmtRepCnt(Integer.parseInt(params.get("cmtRepCnt")));
			noticeResult.setResult("ok");
			
			//解析list实体
			if(indexsecond - indexfirst != 1){
				str = data.substring(indexfirst, indexsecond-1);
				KuwoLog.d(TAG, "str2:" + str); 
				params = sepFlowerResult(str);
				noticeResult.nlist.setCont(params.get("cont"));
				noticeResult.nlist.setType(params.get("type"));
				noticeResult.nlist.setDesc(params.get("desc"));
				noticeResult.nlist.setActId(params.get("actId"));
				noticeResult.nlist.setTime(params.get("time"));
			}
			
		}
		KuwoLog.d(TAG, noticeResult.getMsg() + "  9999  " + noticeResult.getCmtCnt());
		return  noticeResult;
//		http://changba.kuwo.cn/kge/mobile/Notice?uid=111&sid=111
	}
	
	public HashMap<String, String> getNotReadNoticeNum() throws IOException {
//		http://changba.kuwo.cn/kge/mobile/ChkNotice?uid=XXX&sid=XXX"
		String sid = null,uid = null;
		if(Config.getPersistence().user != null){
			uid = Config.getPersistence().user.uid;
			sid = Config.getPersistence().user.sid;
		}
		String url = String.format("http://changba.kuwo.cn/kge/mobile/ChkNotice?uid=%s&sid=%s",uid,sid);
		String data = read(url.toString());
		KuwoLog.d(TAG, "getNotReadNum::::"+data);
		HashMap<String, String> params = null;
		params = sepFlowerResult(data);
		return params;
	}
	/**
	 * 
	 * @param uid
	 * @param sid
	 * @param type
	 * @param id3
	 * @return 0:成功； -1：失败
	 */
	public int unBindThirdAccount(String uid, String sid, String type) {
		int result = -1;
		String url = String.format("http://changba.kuwo.cn/kge/mobile/CancelBind?uid=%s&sid=%s&type=%s", 
				uid, sid, type);
		try {
			String data = read(url);
			JSONObject jsonObject = new JSONObject(data);
			String resultStr = jsonObject.getString("result");
			KuwoLog.i(TAG, "resultStr="+resultStr);
			if(resultStr.equals("ok")) {
				result = 0;
			}else if(resultStr.equals("err")) {
				result = -1;
			}
		} catch (IOException e) {
			e.printStackTrace();
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return result;
	}
	
//	{"result":"ok","lower":0,"total":0}
	public String getTotalScore(String rid, String score) throws IOException {
//		http://changba.kuwo.cn/kge/mobile/UserPercent?rid=s%&score=%d&uid=%@&sid=%@
		String sid = "",uid = "";
		if(Config.getPersistence().user != null){
			uid = Config.getPersistence().user.uid;
			sid = Config.getPersistence().user.sid;
		}
		String url = String.format("http://changba.kuwo.cn/kge/mobile/UserPercent?rid=%s&score=%s&uid=%s&sid=%s",rid,score,uid,sid);
		KuwoLog.d(TAG, "url:::=========:"+url);
		String data = read(url.toString());
		KuwoLog.d(TAG, "data:::===========:"+data);
		HashMap<String, String> params = null;
		if(data!=null){
			params = sepFlowerResult(data);
			if(params.get("result")!= null && params.get("result").equals("ok")){
				int total = Integer.parseInt(params.get("total"));
				int lower = Integer.parseInt(params.get("lower"));
				if(total == 0){
					return "100";
				}else{
					return lower*100/total+"";
				}
			}
		}
		return "0";
	}
	
	/**
	  * 修改个人资料
	  * @param uid 
	  * @param sid 
	  * @param 
	  * @return 
	 * @throws UnsupportedEncodingException 
	  */	
	public boolean editMyData(String nickname, String sex, String birth_city, String resident_city, String birthday) throws UnsupportedEncodingException{
		
		String sid = null,uid = null;
		if(Config.getPersistence().user != null){
			uid = Config.getPersistence().user.uid;
			sid = Config.getPersistence().user.sid;
		}
		String nicknames = URLEncoder.encode(nickname,"utf8");
		String birth_citys = URLEncoder.encode(birth_city,"utf8"); 
		String resident_citys = URLEncoder.encode(resident_city,"utf8");
		String birthdays = URLEncoder.encode(birthday,"utf8");
		String url = "http://changba.kuwo.cn/kge/mobile/ModProfile?uid="+uid+"&sid="+sid+"&";
		String data = String.format("&nickname=%s&sex=%s&birth_city=%s&resident_city=%s&birthday=%s&act=mod",nicknames,sex,birth_citys,resident_citys,birthdays);
		url = url + data;
		String result = post(url, data);
		KuwoLog.d(TAG, "url:"+ url +"  result:" + result);
		
		HashMap<String, String> params = new HashMap<String, String>();
		if(result == null){
			return false;
		}
		params = sepFlowerResult(result);
		String res = params.get("result");
		if(res.equals("ok")){
			Config.getPersistence().user.nickname = nickname;
			Config.getPersistence().user.birth_city= birth_city;
			Config.getPersistence().user.birthday = birthday;
			Config.getPersistence().user.resident_city = resident_city;
			return true;
		}
		return false;
	}
	/**
	  * 获取个人资料
	  * @param uid 
	  * @param sid 
	  * @param 
	  * @return 
	 * @throws IOException 
	  */	
	public boolean getMyData() throws IOException{
		
		String sid = null,uid = null;
		if(Config.getPersistence().user != null){
			uid = Config.getPersistence().user.uid;
			sid = Config.getPersistence().user.sid;
		}
		String url = "http://changba.kuwo.cn/kge/mobile/ModProfile?uid="+uid+"&sid="+sid;
		String result = read(url);
		KuwoLog.d(TAG, "data:" +"  result:" + result);
		
		HashMap<String, String> params = new HashMap<String, String>();
		if(result == null){
			return false;
		}
		params = sepFlowerResult(result);
		String res = params.get("result");
		if(res.equals("ok")){
			Config.getPersistence().user.nickname = params.get("nickname");
			Config.getPersistence().user.birth_city= params.get("birth_city");
			Config.getPersistence().user.birthday = params.get("birthday");
			Config.getPersistence().user.resident_city = params.get("resident_city");
			return true;
		}
		return false;
	}
	
	public String uploadMyHead(String id, String sid, InputStream is) {
		if(is == null) {
			return null;
		}
		String url = "http://changba.kuwo.cn/kge/mobile/UploadHead?id="+id+"&sid="+sid+"&cat=userhead&comp=111&suf=jpg";
		HttpProvider provider = new HttpProvider();
		String result = provider.upload(url, is);
		return result;
	}
	
}
