package com.ifeng.news2.sport_live.util;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.message.BasicNameValuePair;
import org.xmlpull.v1.XmlPullParser;
import android.os.AsyncTask;
import android.util.Base64;
import android.util.Xml;

import com.ifeng.news2.Config;
import com.ifeng.news2.sport_live.entity.User;
import com.ifeng.news2.sport_live.entity.User.ActionType;
import com.qad.net.HttpManager;
import com.qad.util.MD5;

/**
 * 用户登录注册的管理类
 * 
 * @author SunQuan
 * 
 */
public class LoginAndRegistHelper {

	// 签名，来自于UIB提供的配置文件
	public static final String SIGN = "testtest";
	// 用户归属地
	public static final String USER_LOCATION = "0";
	// 指令识别号，登录为2
	public static final String LOGIN_INSTRUCTION_CODE = "2";
	// 指令识别号，注册为1
	public static final String REGIST_INSTRUCTION_CODE = "1";
	// 用户IP
	public static final String USER_IP = "0.0.0.0";
	// 系统识别号（客户端默认为16）
	public static final String SYSTEM_CODE = "16";
	// 密码状态，默认为11
	public static final String PASSWORD_STATE = "11";

	private LoginAndRegistHelper() {
	}

	private static LoginAndRegistHelper instance;

	public static LoginAndRegistHelper create() {
		if (instance == null) {
			instance = new LoginAndRegistHelper();
		}
		return instance;
	}

	/**
	 * 执行登录或注册操作，对外暴露的唯一方法
	 * 
	 * @param user
	 * @param listener
	 *            注册或登录操作的监听类
	 */
	public void execute(User user, SportLiveHttpListener<User> listener) {
		new HttpTask(listener, user).execute(Config.REQUEST_URL);
	}

	/**
	 * 执行登录或注册操作，对外暴露的唯一方法
	 * 
	 * @param user
	 */
	public void execute(User user) {
		new HttpTask(null, user).execute(Config.REQUEST_URL);
	}

	/**
	 * 向服务器请求数据
	 * 
	 * @param user
	 * @param url
	 * @return 返回结果编码，详见返回编码清单
	 * @throws Exception
	 */
	private int requestData(User user, String url) throws Exception {
		// 2 指定请求方式
		List<NameValuePair> parameters = null;
		if (user.getAction() == ActionType.REGIST) {
			parameters = getRegistParameters(user);
		} else if (user.getAction() == ActionType.LOGIN) {
			parameters = getLoginParameters(user);
		}
		return getResultCode(getHttpPost(url, parameters));
	}

	/**
	 * 封装post请求的数据（登录）
	 * 
	 * @param user
	 * @return post请求的数据
	 * @throws Exception
	 */
	private List<NameValuePair> getLoginParameters(User user) throws Exception {
		List<NameValuePair> parameters = new ArrayList<NameValuePair>();
		parameters.add(new BasicNameValuePair("n", Base64.encodeToString(user
				.getUsername().getBytes(), Base64.DEFAULT)));
		parameters.add(new BasicNameValuePair("k",
				Base64.encodeToString(MD5.getEncoderByMd5(user.getPassword())
						.getBytes(), Base64.DEFAULT)));
		parameters.add(new BasicNameValuePair("p", SYSTEM_CODE));
		parameters.add(new BasicNameValuePair("a", LOGIN_INSTRUCTION_CODE));
		parameters.add(new BasicNameValuePair("l", USER_LOCATION));
		parameters.add(new BasicNameValuePair("s", getLoginSign(user)));
		return parameters;
	}

	/**
	 * 封装post请求的数据（注册）
	 * 
	 * @param user
	 * @return post请求的数据
	 * @throws Exception
	 */
	private List<NameValuePair> getRegistParameters(User user) throws Exception {
		String email = RandomUserInfoUtil
				.generateRandomInfo(RandomUserInfoUtil.EMAIL);
		List<NameValuePair> parameters = new ArrayList<NameValuePair>();
		parameters.add(new BasicNameValuePair("n", Base64.encodeToString(user
				.getUsername().getBytes(), Base64.DEFAULT)));
		parameters.add(new BasicNameValuePair("k",
				Base64.encodeToString(MD5.getEncoderByMd5(user.getPassword())
						.getBytes(), Base64.DEFAULT)));
		parameters.add(new BasicNameValuePair("p", SYSTEM_CODE));
		parameters.add(new BasicNameValuePair("m", Base64.encodeToString(
				email.getBytes(), Base64.DEFAULT)));
		parameters.add(new BasicNameValuePair("a", REGIST_INSTRUCTION_CODE));
		parameters.add(new BasicNameValuePair("ps", PASSWORD_STATE));
		parameters.add(new BasicNameValuePair("ip", USER_IP));
		parameters.add(new BasicNameValuePair("s", getRegistSign(user, email)));
		return parameters;
	}

	/**
	 * 根据请求的数据body，得到HttpPost
	 * 
	 * @param url
	 * @param parameters
	 * @return
	 * @throws Exception
	 */
	private HttpPost getHttpPost(String url, List<NameValuePair> parameters)
			throws Exception {
		HttpPost httpPost = new HttpPost(url);
		UrlEncodedFormEntity entity = new UrlEncodedFormEntity(parameters,
				"utf-8");
		// 把实体数据设置到请求对象
		httpPost.setEntity(entity);
		return httpPost;
	}

	/**
	 * 获得返回的结果编码
	 * 
	 * @param httpPost
	 * @return
	 * @throws Exception
	 */
	private int getResultCode(HttpPost httpPost) throws Exception {
		int resultCode = -1;
		HttpResponse response = HttpManager.executeHttpPost(httpPost);
		if (response.getStatusLine().getStatusCode() == 200) {
			InputStream in = response.getEntity().getContent();
			resultCode = parseResult(in);
		}
		return resultCode;
	}

	/**
	 * 解析返回的XML文件，获取返回的结果编码
	 * 
	 * @param in
	 * @return
	 * @throws Exception
	 */
	private int parseResult(InputStream in) throws Exception {
		XmlPullParser parser = Xml.newPullParser();
		parser.setInput(in, "UTF-8");
		String tag = null;
		for (int type = parser.getEventType(); type != XmlPullParser.END_DOCUMENT; type = parser
				.next()) {
			if (type == XmlPullParser.START_TAG) {
				if (parser.getName().equals("ret")) {
					tag = parser.nextText();
				}
			}
		}
		return Integer.parseInt(tag);
	}

	/**
	 * 拼装注册请求的数据的签名 （所有取值都是BASE64编码前的）
	 * 
	 * @param user
	 * @param email
	 * @return
	 * @throws Exception
	 */

	private String getRegistSign(User user, String email) throws Exception {
		// md5（”a=”+a+”k=”+k +”m=”+m+”n=”+n +”p=”+p +sign）
		StringBuilder builder = new StringBuilder();
		builder.append("a=").append(REGIST_INSTRUCTION_CODE).append("k=")
				.append(MD5.getEncoderByMd5(user.getPassword())).append("m=")
				.append(email).append("n=").append(user.getUsername())
				.append("p=").append(SYSTEM_CODE).append(SIGN);
		String sign = MD5.getEncoderByMd5(builder.toString());
		return sign;
	}

	/**
	 * 拼装登录请求的数据的签名 （所有取值都是BASE64编码前的）
	 * 
	 * @param user
	 * @param email
	 * @return
	 * @throws Exception
	 */
	private String getLoginSign(User user) throws Exception {
		// md5（”a=”+a+”k=”+k+”l=”+l+”n=”+n+”p=”+p+ sign）
		StringBuilder builder = new StringBuilder();
		builder.append("a=").append(LOGIN_INSTRUCTION_CODE).append("k=")
				.append(MD5.getEncoderByMd5(user.getPassword())).append("l=")
				.append(USER_LOCATION).append("n=").append(user.getUsername())
				.append("p=").append(SYSTEM_CODE).append(SIGN);
		String sign = MD5.getEncoderByMd5(builder.toString());
		return sign;
	}

	/**
	 * 异步请求（登录&注册）
	 * 
	 */
	private class HttpTask extends AsyncTask<String, Integer, Boolean> {
		private SportLiveHttpListener<User> listener;
		private User user;

		public HttpTask(SportLiveHttpListener<User> listener, User user) {
			this.listener = listener;
			this.user = user;
		}

		@Override
		protected void onPreExecute() {
			if (listener != null) {
				listener.preLoad();
			}
			super.onPreExecute();
		}

		@Override
		protected Boolean doInBackground(String... params) {
			boolean success = false;
			try {
				int resultCode = requestData(user, params[0]);
				success = Result.getResultMessageByResultCode(resultCode, user);
			} catch (Exception e) {
				e.printStackTrace();
				success = Result.getResultMessageByResultCode(
						Result.COMMON_FAIL_CODE, user);
			}
			return success;
		}

		@Override
		protected void onPostExecute(Boolean success) {
			if (success) {
				if (listener != null)
					listener.success(user);
			} else {
				if (listener != null)
					listener.fail(user);
			}
			super.onPostExecute(success);
		}

	}

	/**
	 * 返回值的结果封装类
	 * 
	 * @author SunQuan
	 * 
	 */
	private static class Result {
		public static final int COMMON_FAIL_CODE = -1;
		public static final int SUCCESS_CODE = 0;
		public static final int NO_AVIALABLE_CHANNEL_CODE = 7;
		public static final int UNMATCH_CHECK_CODE = 8;

		public static final int REGIST_USER_EXIST_CODE = 10101;
		public static final int REGIST_SYSTEM_ERROR_CODE = 10100;
		public static final int REGIST_UNFORMAT_USERNAME_CODE = 10103;

		public static final int LOGIN_SYSTEM_ERROR_CODE = 10200;
		public static final int LOGIN_USER_UNEXIST_CODE = 10201;
		public static final int LOGIN_UNMATCH_CODE = 10202;
		public static final int LOGIN_LIMIT_LOAD = 10205;

		public static final String REGIST_USER_EXIST_MESSAGE = "用户已经存在";
		public static final String REGIST_SYSTEM_ERROR_MESSAGE = "追加用户时出现系统故障";
		public static final String REGIST_UNFORMAT_USERNAME_MESSAGE = "用户名包含非法字符";

		public static final String LOGIN_SYSTEM_ERROR_MESSAGE = "用户登录时出现系统故障";
		public static final String LOGIN_USER_UNEXIST_MESSAGE = "用户名不存在";
		public static final String LOGIN_UNMATCH_MESSAGE = "用户名密码不匹配";
		public static final String LOGIN_LIMIT_MESSAGE = "限制登录";

		public static final String LOGIN_SUCCESS_MESSAGE = "恭喜您，登陆成功！";
		public static final String REGIST_SUCCESS_MESSAGE = "恭喜您，注册成功！";
		public static final String LOGIN_OTHER_FIAL_MESSAGE = "对不起，登录失败，请重试";
		public static final String REGIST_OTHER_FIAL_MESSAGE = "对不起，注册失败，请重试";

		public static final String NO_AVIALABLE_CHANNEL_MESSAGE = "没有可用通道";
		public static final String UNMATCH_CHECK_MESSAGE = "数据验证错误";

		/**
		 * 根据不同的返回编码，得到不同的结果，详情参考《UIBI返回值编码清单》
		 * 
		 * @param resultCode
		 * @param user
		 * @return
		 */
		public static boolean getResultMessageByResultCode(int resultCode,
				User user) {
			boolean isSuccess = false;
			if (resultCode == Result.SUCCESS_CODE) {
				if (user.getAction() == ActionType.LOGIN) {
					user.setResultMessage(Result.LOGIN_SUCCESS_MESSAGE);
				} else if (user.getAction() == ActionType.REGIST) {
					user.setResultMessage(Result.REGIST_SUCCESS_MESSAGE);
				}
				isSuccess = true;
			} else if (resultCode == Result.LOGIN_USER_UNEXIST_CODE) {
				user.setResultMessage(Result.LOGIN_USER_UNEXIST_MESSAGE);
			} else if (resultCode == Result.LOGIN_SYSTEM_ERROR_CODE) {
				user.setResultMessage(Result.LOGIN_SYSTEM_ERROR_MESSAGE);
			} else if (resultCode == Result.LOGIN_LIMIT_LOAD) {
				user.setResultMessage(Result.LOGIN_LIMIT_MESSAGE);
			} else if (resultCode == Result.LOGIN_UNMATCH_CODE) {
				user.setResultMessage(Result.LOGIN_UNMATCH_MESSAGE);
			} else if (resultCode == Result.REGIST_SYSTEM_ERROR_CODE) {
				user.setResultMessage(Result.REGIST_SYSTEM_ERROR_MESSAGE);
			} else if (resultCode == Result.REGIST_UNFORMAT_USERNAME_CODE) {
				user.setResultMessage(Result.REGIST_UNFORMAT_USERNAME_MESSAGE);
			} else if (resultCode == Result.REGIST_USER_EXIST_CODE) {
				user.setResultMessage(Result.REGIST_USER_EXIST_MESSAGE);
			} else if (resultCode == Result.NO_AVIALABLE_CHANNEL_CODE) {
				user.setResultMessage(Result.NO_AVIALABLE_CHANNEL_MESSAGE);
			} else if (resultCode == Result.UNMATCH_CHECK_CODE) {
				user.setResultMessage(UNMATCH_CHECK_MESSAGE);
			} else {
				if (user.getAction() == ActionType.LOGIN) {
					user.setResultMessage(Result.LOGIN_OTHER_FIAL_MESSAGE);
				} else if (user.getAction() == ActionType.REGIST) {
					user.setResultMessage(Result.REGIST_OTHER_FIAL_MESSAGE);
				}
			}
			return isSuccess;
		}

	}

}
