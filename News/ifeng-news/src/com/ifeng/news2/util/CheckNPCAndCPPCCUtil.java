package com.ifeng.news2.util;

import java.io.IOException;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.ifeng.news2.Config;
import com.ifeng.news2.bean.Channel;
import com.ifeng.share.util.NetworkState;
import com.qad.net.HttpManager;

/** 
 * @author SunQuan: 
 * @version 创建时间：2014-1-17 下午1:00:12 
 * 类说明 
 */

public class CheckNPCAndCPPCCUtil {
	
	protected static final int NPC_AND_CPPC_SWITCH_OPEN = 0;
	protected static final int NPC_AND_CPPC_SWITCH_CLOSE = 1;
	public static Channel NPCAndCPPCCChannel = 	new Channel(
			"两會",
			"http://api.3g.ifeng.com/iosNews?id=LHPD,LHPDRECOMMEND&imgwidth=300&type=list&pagesize=20",
			null,
			"lianghui",
			"http://api.3g.ifeng.com/iosNews?id=LHPD,LHPDRECOMMEND&imgwidth=300&type=list&pagesize=20",
			null
			);
	
	private static Handler mHandler = new Handler(){
		public void handleMessage(android.os.Message msg) {
			NPCAndCPPCCCheckCallback callback = (NPCAndCPPCCCheckCallback) msg.obj;
			switch (msg.what) {
			//如果开关开启，则打开
			case NPC_AND_CPPC_SWITCH_OPEN:
				//当前频道中没有两会频道
				callback.switchOpen();
				break;
			case NPC_AND_CPPC_SWITCH_CLOSE:
				callback.switchClose();
				break;
			default:
				break;
			}
		};
	};

	public static void checkNPCAndCPPCCChannel(Context context,final NPCAndCPPCCCheckCallback callback) {
		//如果没有网络连接，不进行开关检查
		if(!NetworkState.isActiveNetworkConnected(context)) {
			return;
		}
		
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				try {
					String result = HttpManager.getHttpText(Config.NPCAndCPPCC_SWITCH_URL);
					Message message = new Message();
					message.obj = callback;
//					result="{isShowLH: true}";
					if(!TextUtils.isEmpty(result) && result.contains("true")) {					
						message.what = NPC_AND_CPPC_SWITCH_OPEN;
						mHandler.sendMessage(message);
					} else {
						message.what = NPC_AND_CPPC_SWITCH_CLOSE;
						mHandler.sendMessage(message);
					}
				} catch (IOException e) {
					return;
				} 
			}
		}).start();
	}
	
	/**
	 * 两会频道的开关的监听
	 * 
	 * @author SunQuan
	 *
	 */
	public interface NPCAndCPPCCCheckCallback{
		void switchOpen();
		void switchClose();
	}
}
