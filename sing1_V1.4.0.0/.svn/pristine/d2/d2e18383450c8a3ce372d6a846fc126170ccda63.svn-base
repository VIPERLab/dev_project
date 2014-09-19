package cn.kuwo.sing.controller;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.Map;

import android.content.Intent;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.TextView;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.CommentActivity;
import cn.kuwo.sing.ui.activities.LocalNoticeActivity;
import cn.kuwo.sing.ui.activities.OtherHomeActivity;
import cn.kuwo.sing.ui.compatibility.KuwoWebView;
import cn.kuwo.sing.ui.compatibility.KuwoWebView.OnOrderListener;

public class LocalNoticeController extends BaseController implements
		OnOrderListener {
	private final String TAG = "LocalNoticeController";
	private static final String PREFIX_MY_HOME = "http://changba.kuwo.cn/kge/webmobile/an/myhome.html";
	private BaseActivity mActivity;
	private TextView tv_local_notice_title;
	public Button locol_notice_back_btn;
	public KuwoWebView local_notice_web_view;
	private String url;
	private RelativeLayout rl_local_notice_progress;

	public LocalNoticeController(BaseActivity activity) {
		KuwoLog.i(TAG, "LocalController");
		mActivity = activity;
		initView();

	}

	private void initView() {
		rl_local_notice_progress = (RelativeLayout) mActivity.findViewById(R.id.rl_local_notice_progress);
		rl_local_notice_progress.setVisibility(View.INVISIBLE);
		tv_local_notice_title = (TextView) mActivity.findViewById(R.id.tv_local_notice_title);
		locol_notice_back_btn = (Button) mActivity.findViewById(R.id.locol_notice_back_btn);
		locol_notice_back_btn.setOnClickListener(mOnClickListener);
		local_notice_web_view = (KuwoWebView) mActivity.findViewById(R.id.local_notice_web_view);
		local_notice_web_view.setOnOrderListener(this);
		Intent intent = mActivity.getIntent();
		String title = intent.getStringExtra("title");
		url = intent.getStringExtra("webviewurl");
		local_notice_web_view.loadUrl(url);
		tv_local_notice_title.setText(title);
	}

	public void loadUrl() {
		local_notice_web_view.loadUrl(url);
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
			case R.id.locol_notice_back_btn:// 返回按钮
				mActivity.finish();
				break;
			}
		}
	};

	public void onOrder(String order, Map<String, String> params) {
		KuwoLog.d(TAG, "order:" + order + " params: " + params);
		if (order.equalsIgnoreCase("NewPage")) {
			String type = params.get("type");
			String url = params.get("url");
			String title = params.get("title");
			try {
				url = URLDecoder.decode(url, "utf-8");
				title = URLDecoder.decode(title, "utf-8");
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
			KuwoLog.i(TAG, "type=" + type);
			KuwoLog.i(TAG, "url=" + url);
			KuwoLog.i(TAG, "title=" + title);
//			Intent intent = new Intent(mActivity, LocalNoticeActivity.class);
//			intent.putExtra("title", title);
//			intent.putExtra("webviewurl", url);
//			mActivity.startActivity(intent);
			if(url.startsWith(PREFIX_MY_HOME)) 
				return;
			Intent intent = new Intent(mActivity, OtherHomeActivity.class);
			String id = url.split("=")[2];
			intent.putExtra("title", title);
			intent.putExtra("id", id);
			mActivity.startActivity(intent);
			
		} else if (order.equalsIgnoreCase("playsong")) {
			MTVBusiness mb = new MTVBusiness(mActivity);
			KuwoLog.i(TAG, "rid=" + params.get("rid"));
			mb.playMtv(params.get("rid"));
		} else if (order.equalsIgnoreCase("goCmt")) {
			String kid = params.get("kid");
			String ssid = params.get("ssid");
			Config.getPersistence().user.sid = ssid;
			Config.savePersistence();
			String uid = params.get("uid");
			String t = params.get("t");
			Intent commentIntent = new Intent(mActivity, CommentActivity.class);
			commentIntent.putExtra("kid", kid);
			commentIntent.putExtra("sid", ""); // 可以不填sid，服务端自己查sid(帖子id)
			mActivity.startActivity(commentIntent);
		}

	}

	@Override
	public void onPageStart() {
		rl_local_notice_progress.setVisibility(View.VISIBLE);
	}

	@Override
	public void onPageFinished() {
		rl_local_notice_progress.setVisibility(View.INVISIBLE);
	}

	@Override
	public void onNoServerLoading() {
		// TODO Auto-generated method stub

	}
}
