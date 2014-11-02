package com.ifeng.news2.sport_live.entity;

import com.ifeng.news2.util.InfoPreserver.PreferenceItem;
import com.ifeng.news2.util.InfoPreserver.PreferenceName;



/**
 * 
 * 用户实体
 * 
 * @author SunQuan
 * 
 */
@PreferenceName("USER")
public class User {

	// 用户名
	@PreferenceItem("username")
	private String username;
	// 密码
	@PreferenceItem("password")
	private String password;
	// 用户的动作（登录&注册）
	private ActionType action;
	// 返回状态
	private String resultMessage;

	public String getResultMessage() {
		return resultMessage;
	}

	public void setResultMessage(String resultMessage) {
		this.resultMessage = resultMessage;
	}

	public ActionType getAction() {
		return action;
	}

	public void setAction(ActionType action) {
		this.action = action;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public enum ActionType {
		LOGIN, REGIST
	}

}
