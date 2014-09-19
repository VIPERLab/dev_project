/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.Toast;
import cn.kuwo.framework.config.PreferencesManager;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.crypt.Base64Coder;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.ThirdInfo;
import cn.kuwo.sing.bean.User;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.logic.service.UserService;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.compatibility.KuwoWebView;
import cn.kuwo.sing.ui.compatibility.KuwoWebView.OnOrderListener;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2012-11-6, 上午10:18:48, 2012
 *
 * @Author wangming
 *
 */
public class ThirdPartyLoginController extends BaseController implements OnOrderListener{
	private final String TAG = "ThirdPartyLoginController";
	private BaseActivity mActivity;
	private Button backButton;
	private KuwoWebView mWebView;
	private String mFlag;
	private String mType;
	private RelativeLayout rl_third_login_progress;
	
	public ThirdPartyLoginController(BaseActivity activity) {
		KuwoLog.i(TAG, "ThirdPartyLoginController");
		mActivity = activity;
		initView();
		loginOrBind();
	}

	private void initView() {
		backButton = (Button) mActivity.findViewById(R.id.third_back_btn);
		mWebView = (KuwoWebView)mActivity.findViewById(R.id.thirdlogin_web_view);
		rl_third_login_progress = (RelativeLayout) mActivity.findViewById(R.id.rl_third_login_progress);
		rl_third_login_progress.setVisibility(View.INVISIBLE);
		backButton.setOnClickListener(mOnClickListener);
		mWebView.setOnOrderListener(this);
	}
	
	private void loginOrBind() {
		UserLogic userlogic = new UserLogic();
		mFlag = mActivity.getIntent().getStringExtra("flag");
		mType = mActivity.getIntent().getStringExtra("type");
		String url = null;
		try {
			if(mFlag.equals("login")) {
				url = userlogic.loginThirdParty(mType);
			}else if(mFlag.equals("bind")) {
				url = userlogic.bindThirdParty(mType);
			}
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
		mWebView.loadUrl(url);
	}

	@Override
	public void onOrder(String order, Map<String, String> params) {
		if(order.equalsIgnoreCase("GetDevKey")) {
			//获取设备标识：userid
			String result = AppContext.DEVICE_ID;
			if(result != null){
				KuwoLog.i(TAG, "GetDevKey====");
				mWebView.js("setDevKey('result=ok&value="+ result + "')");
			}else {
				mWebView.loadUrl("javascript:setDevKey('result=err&msg=葱花，android设备Id未获取到')"); 
			}
		}else if(order.equalsIgnoreCase("GetDevName")) {
			String devName = null;
			try {
				devName = URLEncoder.encode("酷我K歌_android","utf8");
			} catch (UnsupportedEncodingException e) {
				KuwoLog.printStackTrace(e);
			}
			if(devName != null) {
				mWebView.js("setDevName('result=ok&value="+ "酷我K歌_android" + "')");
			}else {
				mWebView.js("setDevName('result=err&msg="+ "葱花，android设备Id未获取到" + "')");
			}
		}else if(order.equalsIgnoreCase("LoginResult")) {
			String result = params.get("r");
			if("1".equals(result)) {
				PreferencesManager.put("isThirdLogin", true).commit();
				//登录成功
				try {
					if(mFlag.equals("login")) {
						Toast.makeText(mActivity, "登录成功", 0).show();
						String data = Base64Coder.decodeString(URLDecoder.decode(params.get("data"), "utf8"), "utf8");
						KuwoLog.i(TAG, "data="+data);
						JSONObject dataObject = new JSONObject(data);
						UserLogic.isThirdLogin = true;
						UserLogic userLogic = new UserLogic();
						final User user = new User();
						user.uid = dataObject.getString("uid");
						user.sid = dataObject.getString("sid");
						user.uname = dataObject.getString("uname");
						user.psw = dataObject.getString("pwd");
						user.nickname = dataObject.getString("nickname");
						String thirdString = dataObject.getString("3rdInf");
						thirdString = thirdString.substring(1, thirdString.length()-1);
						if(!thirdString.equals("")) {
							JSONObject thirdObject = new JSONObject(thirdString);
							final String thirdId = thirdObject.getString("id");
							user.headUrl = thirdObject.getString("headpic");
							
							user.thirdInfoList = new ArrayList<ThirdInfo>();
							final ThirdInfo thirdInfo = new ThirdInfo();
							thirdInfo.third_headpic = thirdObject.getString("headpic");
							thirdInfo.third_id = thirdObject.getString("id");
							thirdInfo.third_uname = thirdObject.getString("uname");
							//如果是登录，则保存
							if(mType.equals("weibo")) {
								user.weiboName = thirdInfo.third_uname;
								user.isBindWeibo = true;;
								thirdInfo.third_type = "weibo";
							}else if(mType.equals("qq")) {
								user.qqName = thirdInfo.third_uname;
								user.isBindQQ = true;
								thirdInfo.third_type = "qq";
							}else if(mType.equals("renren")) {
								user.renrenName = thirdInfo.third_uname;
								user.isBindRenren = true;
								thirdInfo.third_type = "renren";
							}
							user.thirdInfoList.add(thirdInfo);
						}
						userLogic.saveUser(user);
						new Thread(new Runnable() {
							
							@Override
							public void run() {
								try {
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
									Message msg = messageHandler.obtainMessage();
									msg.what = 0; //不管成功失败，都跳转
									Bundle data = msg.getData();
									if(TextUtils.isEmpty(user.nickname)) {
										if(mType.equals("qq")) {
											user.nickname = user.qqName; 
										}else if(mType.equals("weibo")){
											user.nickname = user.weiboName;
										}else if(mType.equals("renren")) {
											user.nickname = user.renrenName;
										}
									}
									data.putString("nickname", user.nickname);
									data.putString("headUrl", user.headUrl);
									messageHandler.sendMessage(msg);
								} catch (IOException e) {
									e.printStackTrace();
								}
								
							}
						}).start();
					} else if(mFlag.equals("bind")) {
						//如果是绑定，就不保存了 LoginResult r=1&sync=1/2&type=qq/weibo&name=3rdname
						//sync:1成功；2已经绑定过其他酷我账号
						String sync = params.get("sync");
						if(sync.equals("1")) {
							Toast.makeText(mActivity, "绑定成功!", 0).show();
							String thirdName = URLDecoder.decode(params.get("name"));
							if(mType.equals("weibo")) {
								Config.getPersistence().user.isBindWeibo = true;
								Config.getPersistence().user.weiboName = thirdName;
							}else if(mType.equals("qq")) {
								Config.getPersistence().user.isBindQQ = true;
								Config.getPersistence().user.qqName = thirdName;
							}else if(mType.equals("renren")) {
								Config.getPersistence().user.isBindRenren = true;
								Config.getPersistence().user.renrenName = thirdName;
							}
							ThirdInfo info = new ThirdInfo();
							info.third_type = mType;
							info.third_uname = thirdName;
							Config.getPersistence().user.thirdInfoList.add(info);
							Config.savePersistence();
							Intent resultIntent = new Intent();
							resultIntent.putExtra("resultFlag", mType);
							resultIntent.putExtra("thirdName", thirdName);
							mActivity.setResult(Constants.SHARE_BOUND_SUCCESS_RESULT, resultIntent);
						}else if(sync.equals("2")) {
							Toast.makeText(mActivity, "已经绑定过其他酷我账号", 0).show();
						}else if("0".equals(result)) {
							//登录失败，需要进行操作
							KuwoLog.i(TAG, "第三方登录失败！");
							String errMsg = params.get("errMsg");
							if(errMsg != null) {
								errMsg = errMsg.substring(0, errMsg.indexOf('/'));
								String errMsgInfo = URLDecoder.decode(errMsg);
								KuwoLog.i(TAG, "third login errMsg="+errMsgInfo);
								Toast.makeText(mActivity, errMsgInfo, 0).show();
							}else {
								mActivity.finish();
							}
						}
						mActivity.finish();
					}
					
				} catch (UnsupportedEncodingException e) {
					KuwoLog.printStackTrace(e);
				} catch (JSONException e) {
					KuwoLog.printStackTrace(e);
				}
			}else if("0".equals(result) || "2".equals(result)) {
				//登录失败，需要进行操作
				KuwoLog.i(TAG, "第三方登录失败！");
				Config.getPersistence().isLogin = false;
				Config.savePersistence();
				
				String errMsg = params.get("errMsg");
				if(errMsg != null) {
					errMsg = errMsg.substring(0, errMsg.indexOf('/'));
					String errMsgInfo = URLDecoder.decode(errMsg);
					KuwoLog.i(TAG, "third login errMsg="+errMsgInfo);
					Toast.makeText(mActivity, errMsgInfo, 0).show();
				}
				mActivity.finish();
			}else {
				KuwoLog.i(TAG, "third login result="+result);
			}
		}else {
			mActivity.finish();
		}
	}
	
	private Handler messageHandler = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				Intent intent = new Intent();
				intent.setAction("cn.kuwo.sing.user.change");
				mActivity.sendBroadcast(intent);
				Intent resultIntent = new Intent();
				resultIntent.putExtra("nickname", msg.getData().getString("nickname"));
				resultIntent.putExtra("headUrl", msg.getData().getString("headUrl"));
				mActivity.setResult(Constants.THIRD_LOGIN_SUCCESS_RESULT, resultIntent);
				mActivity.finish();
				break;
			default:
				break;
			}
		};
	};
	
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			int id = v.getId();
			switch (id) {
			case R.id.third_back_btn:
				mActivity.finish();
				break;

			default:
				break;
			}
		}
	};

	@Override
	public void onPageStart() {
		rl_third_login_progress.setVisibility(View.VISIBLE);
	}

	@Override
	public void onPageFinished() {
		
	}

	@Override
	public void onNoServerLoading() {
		rl_third_login_progress.setVisibility(View.INVISIBLE);
		
	}
}
