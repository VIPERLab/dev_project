/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.Map;

import android.content.Intent;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.business.UserBusiness;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.compatibility.KuwoWebView;
import cn.kuwo.sing.ui.compatibility.KuwoWebView.OnOrderListener;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2012-11-9, 下午5:06:06, 2012
 *
 * @Author wangming
 *
 */
public class CommonController extends BaseController implements OnOrderListener {
	private final String TAG = "CommonController";
	private BaseActivity mActivity;
	private TextView titleTV;
	private Button msgBT;
	private Button backBT;
	private KuwoWebView mWebView;
	
	public CommonController(BaseActivity activity) {
		KuwoLog.i(TAG, "CommonController");
		mActivity = activity;
		initView();
	}

	private void initView() {
		Intent intent = mActivity.getIntent();
		String title = intent.getStringExtra("title");
		String url = intent.getStringExtra("url");
		
		titleTV = (TextView)mActivity.findViewById(R.id.tv_common_title);
		backBT = (Button)mActivity.findViewById(R.id.bt_common_back);
		backBT.setOnClickListener(mOnClickListener);
		msgBT = (Button)mActivity.findViewById(R.id.bt_common_msg);
		msgBT.setOnClickListener(mOnClickListener);
		mWebView = (KuwoWebView) mActivity.findViewById(R.id.common_web_view);
		mWebView.setOnOrderListener(this);
		try {
			titleTV.setText(URLDecoder.decode(title, "utf-8"));
			mWebView.loadUrl(URLDecoder.decode(url, "utf-8"));
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
	}
	
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			int id = v.getId();
			switch (id) {
			case R.id.bt_common_back:
				mActivity.finish();
				break;
			case R.id.bt_common_msg:
				break;
			default:
				break;
			}
		}
	};

	@Override
	public void onOrder(String order, Map<String, String> params) {
		if(order.equalsIgnoreCase("EmiNewPage")) {
			String type = params.get("type");
			String title = params.get("title");
			String url = params.get("url");
			UserBusiness ub = new UserBusiness(mActivity);
			ub.entryGame(title, url);
		}else if (order.equalsIgnoreCase("DownLoadSong")) {
			String name = params.get("name");
			String art = params.get("art");
			try {
				name = URLDecoder.decode(name, "utf-8");
				KuwoLog.i(TAG, "name="+name);
				art = URLDecoder.decode(art, "utf-8");
				KuwoLog.i(TAG, "art="+art);
			} catch (UnsupportedEncodingException e) {
				KuwoLog.printStackTrace(e);
			}
			String strRid = params.get("strRid");
			KuwoLog.i(TAG, "strRid="+strRid);
		}
	}

	/* (non-Javadoc)
	 * @see cn.kuwo.sing.ui.compatibility.KuwoWebView.OnOrderListener#onPageStart()
	 */
	@Override
	public void onPageStart() {
		// TODO Auto-generated method stub
		
	}

	/* (non-Javadoc)
	 * @see cn.kuwo.sing.ui.compatibility.KuwoWebView.OnOrderListener#onPageFinished()
	 */
	@Override
	public void onPageFinished() {
		// TODO Auto-generated method stub
		
	}

	/* (non-Javadoc)
	 * @see cn.kuwo.sing.ui.compatibility.KuwoWebView.OnOrderListener#onNoServerLoading()
	 */
	@Override
	public void onNoServerLoading() {
		// TODO Auto-generated method stub
		
	}

}
