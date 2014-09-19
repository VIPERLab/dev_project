package cn.kuwo.sing.bean;

import java.io.Serializable;
import java.util.List;

public class User implements Serializable{
    
	private static final long serialVersionUID = 8569403700398886473L;

	/**
	 * 用户uid
	 */
	public String uid;
	
	/**
	 * session id
	 */
	public String sid;
	
	
	/**
	 * 用户密码
	 */
	public String psw;
	
	/**
	 * 用户名
	 */
	public String uname;
	
	public String headUrl;
	
	public String weiboName;
	
	public String qqName;
	
	public String renrenName;
	/*昵称*/
	public String nickname;
	/*出生城市*/
	public String birth_city;
	/*最近居住城市*/
	public String resident_city;
	/*生日*/
	public String birthday;
	public int noticeNumber;
	
	public boolean isBindWeibo = false;
	public boolean isBindQQ = false;
	public boolean isBindRenren = false;
	
	public List<ThirdInfo> thirdInfoList;
}

