package cn.kuwo.sing.controller;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.Map;

import android.content.DialogInterface;
import android.content.Intent;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.LocalNoticeActivity;
import cn.kuwo.sing.ui.activities.LoginActivity;
import cn.kuwo.sing.ui.compatibility.KuwoWebView;
import cn.kuwo.sing.ui.compatibility.KuwoWebView.OnOrderListener;
import cn.kuwo.sing.util.DialogUtils;

/**
 * 个人主页控制层
 * 
 * @author wangming
 * 
 */
public class LocalMainController extends BaseController implements OnOrderListener {

	private final String TAG = "LocalMainController";
	private final String URL_LOCAL_MAIN = "http://changba.kuwo.cn/kge/webmobile/an/myhome.html";

	private BaseActivity mActivity;
	private KuwoWebView mWebView;
	private TextView titleTV;
	private RelativeLayout local_main_title_rl;
	private TextView local_main_title;
	private RelativeLayout rl_local_main_progress;

	public LocalMainController(BaseActivity activity) {

		KuwoLog.v(TAG, "LocalMainController()");

		mActivity = activity;

		initView();
	}
	
	private String getOtherHomeURL(String uid) {
		String otherHomeURL = "http://changba.kuwo.cn/kge/webmobile/an/userhome.html?="+System.currentTimeMillis()+"="+uid;
		KuwoLog.i(TAG, "otherHomeUrl==="+otherHomeURL);
		return otherHomeURL;
	}

	/**
	 * 初始化控件
	 * 
	 * @param activity
	 */
	private void initView() {
		titleTV = (TextView)mActivity.findViewById(R.id.local_main_title);
		String uname = mActivity.getIntent().getStringExtra("uname");
		rl_local_main_progress = (RelativeLayout) mActivity.findViewById(R.id.rl_local_main_progress);
		rl_local_main_progress.setVisibility(View.INVISIBLE);
		try {
			titleTV.setText(URLDecoder.decode(uname, "utf-8")+"的主页");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		Button local_main_back_btn = (Button) mActivity.findViewById(R.id.local_main_back_btn);
		local_main_back_btn.setOnClickListener(mOnClickListener);
		Button local_main_leave_msg = (Button) mActivity.findViewById(R.id.local_main_leave_msg);
		local_main_leave_msg.setOnClickListener(mOnClickListener);
		
		local_main_title = (TextView) mActivity.findViewById(R.id.local_main_title);
		
		mWebView = (KuwoWebView)mActivity.findViewById(R.id.local_main_web_view);
		mWebView.setOnOrderListener(this);
		
		Intent intent = mActivity.getIntent();
		String flag = intent.getStringExtra("flag");
		if("myHome".equals(flag)) {
			mWebView.loadUrl(URL_LOCAL_MAIN);
		}else if("otherHome".equals(flag)) {
			String uid = intent.getStringExtra("uid");
			mWebView.loadUrl(getOtherHomeURL(uid));
		}else if("loadMain".equals(flag)) {
			String url = intent.getStringExtra("url");
			mWebView.loadUrl(url);
		}
	}
	
	public void reloadOtherHome() {
		String uid = mActivity.getIntent().getStringExtra("uid");
		mWebView.loadUrl(getOtherHomeURL(uid));
	}

	/*
	 * 点击事件
	 */
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			int id = v.getId();
			KuwoLog.v(TAG, "onClick " + id);

			switch (id) {
			case R.id.local_main_back_btn:// 返回按钮
				mActivity.finish();
				break;
			case R.id.local_main_leave_msg:// 写留言
				Toast.makeText(mActivity, "写留言", Toast.LENGTH_SHORT);
				break;
			}
		}
	};

	@Override
	public void onOrder(String order, Map<String, String> params) {
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
			KuwoLog.i(TAG, "type="+type);
			KuwoLog.i(TAG, "url="+url);
			KuwoLog.i(TAG, "title="+title);
			Intent intent = new Intent(mActivity, LocalNoticeActivity.class);
			intent.putExtra("title", title);
			intent.putExtra("webviewurl", url);
			mActivity.startActivity(intent);
		}else if(order.equalsIgnoreCase("playsong")) {
			MTVBusiness mb = new MTVBusiness(mActivity);
			KuwoLog.i(TAG, "rid="+params.get("rid"));
			mb.playMtv(params.get("rid"));
		}else if(order.equals("showNeedLogin")) {
			showLoginDialog(R.string.login_dialog_tip);
		}
	}
	
	private void showLoginDialog(int tip) {
		DialogUtils.alert(mActivity, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case -1:
					//ok
					dialog.dismiss();
					Intent loginIntent = new Intent(mActivity, LoginActivity.class);
					mActivity.startActivity(loginIntent);
					break;
				case -2:
					//cancel
					dialog.dismiss();
					break;
				default:
					break;
				}
				
			}
		} , R.string.logout_dialog_title, R.string.dialog_ok, R.string.dialog_cancel, -1, tip);
	}

	@Override
	public void onPageStart() {
		rl_local_main_progress.setVisibility(View.VISIBLE);
	}

	@Override
	public void onPageFinished() {
		rl_local_main_progress.setVisibility(View.INVISIBLE);
		
	}

	@Override
	public void onNoServerLoading() {
		
	}
}
