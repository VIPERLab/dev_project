package cn.kuwo.sing.logic;

import java.io.IOException;
import java.io.Serializable;
import java.util.HashMap;
import java.util.List;

import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.bean.LiveRoom;
import cn.kuwo.sing.logic.service.LiveHttpService;
import cn.kuwo.sing.logic.service.LiveSocketService;
import cn.kuwo.sing.logic.service.LiveSocketService.OnLiveDataRecieveListener;

public class LiveLogic {

	private static final String TAG = "LiveLogic";

	private LiveHttpService mLiveHttpService;
	private static LiveSocketService mLiveSocketService;
	
	public LiveLogic() {
		if (mLiveSocketService == null)
			mLiveSocketService = new LiveSocketService();
		if (mLiveHttpService == null)
			mLiveHttpService = new LiveHttpService();
	}
	
	public static String sUserId;
	public static String sUserSid;
	public static String sUserName;
	
	public void login(String uname, String password) {
		HashMap<String, String> params = mLiveHttpService.login(uname, password);
		String id = params.get("user_id");
		String sid = params.get("user_sid");
		KuwoLog.d(TAG, "");
		
		params = mLiveHttpService.getChatSignature(id, sid, "0", "1");
		String sig = params.get("chatroom_channel_sig");
		String tm = params.get("chatroom_timeout");
		String service = params.get("chatroom_server");

		params = mLiveHttpService.getMyInfo(id, sid); 
		String name = params.get("user_name");
		
		KuwoLog.d(TAG, " rewtrwet:" + sig+" "+ tm+ " "+sid+ " "+name+ "" + service);
		mLiveSocketService.connect(service);
		mLiveSocketService.loginSocket(sig, tm, id, name);

		// 成功
		sUserId = id;
		sUserSid = sid;
		sUserName = name;
		KuwoLog.d(TAG, sUserId + "" + sUserSid);
	}
	
	public List<LiveRoom> getHall() {
		return mLiveHttpService.getHall();
	}
	
	public void enterRoom(String roomId, OnLiveDataRecieveListener l) {
		HashMap<String, String> params = null;
		params = mLiveHttpService.getChatSignature(sUserId, sUserSid, roomId, "2");
		String sig = params.get("chatroom_channel_sig");
		String tm = params.get("chatroom_timeout");

		mLiveHttpService.enterRoom(sUserId, sUserSid, roomId);
		mLiveSocketService.joinChannel(sig, tm, roomId, sUserId);
		mLiveSocketService.setOnLiveDataRecieveListener(l);
	}
	
	public void leftRoom(String roomId) {
		mLiveHttpService.leftRoom(sUserId, sUserSid, roomId);
		mLiveSocketService.leftChannel(sUserId);
	}
	
	public void sendMessage(String content) {
		mLiveSocketService.sendMessage(content);
	}
	
//	public void getMyInfo(String id, String sid){
//		
//		HashMap<String, String> params = mLiveHttpService.getMyInfo(id, sid);
//		String name = params.get("user_name");
//		this.userName = name;
//	}
//	
	/*
	 * 进入房间获取聊天服务频道签名
	 */
//	public void getChatSignature(String id, String sid, String roomid){
//		
//		HashMap<String, String> params = mLiveHttpService.getChatSignature(id, sid, roomid);
//		String server = params.get("chatroom_server");
//		String timeout = params.get("chatroom_timeout");
//		String sig = params.get("chatroom_channel_sig");
//		this.sig = sig;
//	}
//	
	
	public HashMap<String, String> getAnchorInfo(String roomId) {
		return mLiveHttpService.getAnchorInfo(sUserId, sUserSid, roomId);
	}
	
	public List<String> getAnchorPic(String  anchorId) throws IOException {
		return mLiveHttpService.getAnchorPic(anchorId);
	}
}
