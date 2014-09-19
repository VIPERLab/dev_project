/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.bean;

import java.io.Serializable;
import java.util.List;

/**
 * @Package cn.kuwo.sing.bean
 *
 * @Date 2013-12-25, 上午10:27:23
 *
 * @Author wangming
 *
 */
public class UserHomeData implements Serializable {
	private static final long serialVersionUID = -2056613418548136500L;
	
	public String uname; //我的昵称
	public String uid;  //ID
	public String age;  //年龄
	public String birth_city; //来自
	public String resident_city; //现居
	public int fans; //粉丝数目
	public int fav;  
	public int hascare; //关注数目
	public int total_pn; 
	public String userpic; //用户头像url
	public List<Kge> kgeList; //用户作品列表
	public String result;
}
