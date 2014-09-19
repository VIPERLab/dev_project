/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.Map;

import android.content.Intent;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.LocalMainActivity;
import cn.kuwo.sing.ui.activities.LoginActivity;
import cn.kuwo.sing.ui.compatibility.KuwoWebView;
import cn.kuwo.sing.ui.compatibility.KuwoWebView.OnOrderListener;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2012-12-27, 上午10:52:43, 2012
 *
 * @Author wangming
 *
 */
public class DynamicController extends BaseController implements OnOrderListener{
	private final String TAG  = "DynamicController";
	private static final String URL_DYNAMIC = "http://changba.kuwo.cn/kge/webmobile/an/dynamic.html";
//	private static final String URL_DYNAMIC = "http://changba.kuwo.cn/kge/webmobile/an/domedynamic.html";
	private BaseActivity mActivity;
	private ImageView iv_login_register;
	private RelativeLayout rl_dynamic_image;
	private RelativeLayout rl_dynamic_webview;
	private KuwoWebView dynamic_web_view;
	private RelativeLayout rl_dynamic_progress;
	
	public DynamicController(BaseActivity activity) {
		KuwoLog.i(TAG, "DynamicController");
		mActivity = activity;
		initView();
	}
	

	private void initView() {
		rl_dynamic_image = (RelativeLayout) mActivity.findViewById(R.id.rl_dynamic_image);
		rl_dynamic_webview = (RelativeLayout) mActivity.findViewById(R.id.rl_dynamic_webview);
		rl_dynamic_progress = (RelativeLayout) mActivity.findViewById(R.id.rl_dynamic_progress);
		rl_dynamic_progress.setVisibility(View.INVISIBLE);
		
		if(!Config.getPersistence().isLogin) {
			loadNotLoginView();
		}else {
			loadLoginView();
		}
	}
	
	public void loadNotLoginView() {
		rl_dynamic_webview.setVisibility(View.INVISIBLE);
		rl_dynamic_image.setVisibility(View.VISIBLE);
		iv_login_register = (ImageView) mActivity.findViewById(R.id.iv_login_register);
		iv_login_register.setOnClickListener(mOnClickListener);
	}
	
	public void loadLoginView() {
		rl_dynamic_image.setVisibility(View.INVISIBLE);
		rl_dynamic_webview.setVisibility(View.VISIBLE);
		dynamic_web_view = (KuwoWebView) mActivity.findViewById(R.id.dynamic_web_view);
		dynamic_web_view.setOnOrderListener(this);
		dynamic_web_view.loadUrl(URL_DYNAMIC);
	}
	
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			Intent loginIntent = new Intent(mActivity, LoginActivity.class);
			mActivity.startActivityForResult(loginIntent, Constants.LOGIN_REQUEST);
			mActivity.overridePendingTransition(R.anim.sing_push_right_in, R.anim.sing_push_left_out);
		}
	};

	@Override
	public void onOrder(String order, Map<String, String> params) {
		KuwoLog.d(TAG, "order:"+order+" params: "+params);
		if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
			Toast.makeText(mActivity, "网络未连接，请稍后再试", 0).show();
			return;
		}
		if(order.equalsIgnoreCase("NewPage")) {
			String type = params.get("type");
			String url = params.get("url");
			String title = params.get("title");
			try {
				url = URLDecoder.decode(url, "utf-8");
				title = URLDecoder.decode(title, "utf-8");
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
			KuwoLog.i(TAG, "title="+title);
			KuwoLog.i(TAG, "url==="+url);
			String uid = url.substring(url.lastIndexOf('=')+1);
			KuwoLog.i(TAG, "uid="+uid);
			String uname = title.substring(0, title.length()-3);
			KuwoLog.i(TAG, "uname="+uname);
			Intent singerIntent = new Intent(mActivity, LocalMainActivity.class);
			singerIntent.putExtra("flag", "otherHome");
			singerIntent.putExtra("uid", uid);
			singerIntent.putExtra("uname", uname);
			mActivity.startActivity(singerIntent);
		}else if(order.equalsIgnoreCase("playsong")) {
			MTVBusiness mb = new MTVBusiness(mActivity);
			mb.playMtv(params.get("rid"));
		}
	}


	@Override
	public void onPageStart() {
		rl_dynamic_progress.setVisibility(View.VISIBLE);
	}

	@Override
	public void onPageFinished() {
		rl_dynamic_progress.setVisibility(View.INVISIBLE);
	}


	/* (non-Javadoc)
	 * @see cn.kuwo.sing.ui.compatibility.KuwoWebView.OnOrderListener#onNoServerLoading()
	 */
	@Override
	public void onNoServerLoading() {
		// TODO Auto-generated method stub
		
	}
}
