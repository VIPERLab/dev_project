package com.ifeng.news2.sport_live.util;

import java.net.URLEncoder;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.sport_live.entity.Replyer;
import com.ifeng.news2.util.ParamsManager;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import android.text.TextUtils;

/**
 * 用户发言的管理类
 * 
 * @author SunQuan:
 * @version 创建时间：2013-7-26 上午10:42:32
 */

public class SpeakHelper {

	public static final int SUCCESS_CODE = 1;
	public static final int FAIL_CODE = 0;

	// 比赛id
	private String mt;
	// 用户id
	private String uid;
	// 用户名
	private String nickname;
	// 聊天内容
	private String content;
	// 对某人聊天时某人的id
	private String touser;
	// 对某人聊天时某人的name
	private String tonick;

	/**
	 * the Constructor Method
	 * 
	 * @param mt
	 * @param uid
	 * @param nickname
	 * @param content
	 * @param touser
	 * @param tonick
	 */
	private SpeakHelper() {
	}

	private static SpeakHelper instance = null;

	public static SpeakHelper create() {
		if (instance == null) {
			instance = new SpeakHelper();
		}
		return instance;
	}

	/**
	 * 为发言并且回复他人设置参数
	 * 
	 * @param mt
	 *            比赛id
	 * @param uid
	 *            用户id
	 * @param nickname
	 *            用户名
	 * @param content
	 *            聊天内容
	 * @param touser
	 *            对某人聊天时某人的id
	 * @param tonick
	 *            对某人聊天时某人的name
	 * @return
	 */
	public SpeakHelper setSpeakParams(String mt, String uid,
			String nickname, String content, String touser, String tonick) {
		this.mt = mt;
		this.uid = uid;
		this.nickname = nickname;
		this.content = content;
		this.touser = touser;
		this.tonick = tonick;
		return this;
	}

	private String getSpeakUrl(String mt, String uid, String nickname,
			String content, String touser, String tonick) {
		nickname = encodeParams(nickname);
		content = encodeParams(content);
		tonick = encodeParams(tonick);
		String speakUrl = ParamsManager.addParams(Config.SPEAK_URL + "&mt=" + mt
				+ "&userid=" + uid + "&nickname=" + nickname + "&content="
				+ content + "&touser=" + touser + "&tonick=" + tonick);
		return speakUrl;
	}

	private String encodeParams(String param) {
		if (!TextUtils.isEmpty(param)) {
			return URLEncoder.encode(param);
		}
		return param;
	}


	/**
	 * 发言
	 * 
	 * @param listener
	 *            发言的监听类
	 * @return
	 */
	public void speak(SportLiveHttpListener<Replyer> listener) {
		String param =  getSpeakUrl(mt, uid, nickname, content,touser, tonick);
		speak(param, listener);
	}

	/**
	 * 发送发言请求
	 * 
	 * @param param
	 * @param listener
	 */
	private void speak(String param,
			final SportLiveHttpListener<Replyer> listener) {
		listener.preLoad();
		IfengNewsApp.getBeanLoader().startLoading(
				new LoadContext<String, LoadListener<Replyer>, Replyer>(param,
						new LoadListener<Replyer>() {

							@Override
							public void postExecut(
									LoadContext<?, ?, Replyer> context) {
								// do nothing
							}

							@Override
							public void loadComplete(
									LoadContext<?, ?, Replyer> context) {
								Replyer replyer = context.getResult();
								if (replyer.getStatus() == SUCCESS_CODE) {
									listener.success(replyer);
								} else if (replyer.getStatus() == FAIL_CODE) {
									listener.fail(replyer);
								} else {
									loadFail(context);
								}
							}

							@Override
							public void loadFail(
									LoadContext<?, ?, Replyer> context) {
								Replyer replyer = new Replyer();
								replyer.setMsg("网络请求失败");
								listener.fail(replyer);
							}

						}, Replyer.class, Parsers.newReplyerInfoParser(),
						LoadContext.FLAG_HTTP_ONLY, false));
	}

}
