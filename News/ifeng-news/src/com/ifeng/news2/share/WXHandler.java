package com.ifeng.news2.share;

import com.ifeng.news2.R;
import com.qad.util.WToast;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;

/**
	 * 处理返回的handle消息
	 */
	public class WXHandler extends Handler {
		private Context context;
		public WXHandler(Looper looper,Context context){
			super(looper);
			this.context = context;
		}
		
		public WXHandler(Context context){
			super();
			this.context = context;
		}
		
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case R.string.errcode_cancel:
			case R.string.errcode_success:
			case R.string.errcode_deny:
			case R.string.yixin_share_content_fail:
			case R.string.yixin_uninstall_fail:
			case R.string.weixin_share_content_fail:
			case R.string.weixin_uninstall_fail:
			case R.string.send_to_qq_error:
				new WToast(context).showMessage(msg.what);
				break;
			default:
				break;
			}
		}
	};