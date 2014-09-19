package cn.kuwo.sing.logic.service;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.HashMap;
import org.xmlpull.v1.XmlPullParser;

import android.util.Xml;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.logic.service.CommonSocket.OnDataRecieveListener;
import cn.kuwo.sing.logic.service.CommonSocket.OnErrorListener;

public class LiveSocketService {
	
	private static final String TAG = "LiveSocketService";
	private static CommonSocket mCommonSocket;
	private OnLiveDataRecieveListener mOnLiveDataRecieveListener;
	private OnErrorListener mOnErrorListener;
	
	private static String sChannel;
	private static String sSig;
	private static String sTm;
	
	public LiveSocketService() {
		if (mCommonSocket == null) {
			mCommonSocket = new CommonSocket();
			KuwoLog.w(TAG, "Socket create");
		}
	}

	public void connect(String service) {
		String[] data = service.split(":");
		mCommonSocket.connect(data[0], Integer.parseInt(data[1]));
		
		mCommonSocket.setOnDataRecieveListener(lOnDataRecieve);
		
		if (mOnErrorListener != null)
			mCommonSocket.setOnErrorListener(mOnErrorListener);
	}
	
	/**
	 * @param sig= getsig获取后的值
	 * @param timerout = getsig获取后的值
	 * @param userId = 用户ID
	 * @param channel = 频道ID
	 * @param unameTemp 0_userName  0为身份.  userName是用户名
	 */
	//登录SOCKET
	public void loginSocket(String sig, String timeout, String userId, String unameTemp) {
		String content = "login:"+userId+":0_"+unameTemp;
		String cmd = order("1", sig, timeout, "0", "0", content);
		mCommonSocket.send(cmd);
	}
	
	
	// 加入频道
//	var data:String = "id=" + SOCKET_JOIN + "&sig=" + sig + "&t=" + timerout + "&channel=" + channel + "&type=0&content=join:" + userId;
//	参数:
//	SOCKET_JOIN = 2; 加入频道的ID
//	userId = 用户ID
//	channel = 频道ID
//	timerout = getsig获取后的值
//	sig= getsig获取后的值
	public void joinChannel(String sig, String timeout, String channel, String userId) {
		String content = "join:"+userId;
		String cmd = order("2", sig, timeout, channel, "0", content);
		mCommonSocket.send(cmd);
		
		sChannel = channel;
		sSig = sig;
		sTm = timeout;
	}
	
	// 离开频道
	public void leftChannel(String userId) {
		String content = "leave:"+userId;
		String cmd = order("3", sSig, sTm, sChannel, "0", content);
		mCommonSocket.send(cmd);
	}
	
	// 发送公聊消息
	public void sendMessage(String content) {
		String cmd = order("1", sSig, sTm, sChannel, "1", content);
		mCommonSocket.send(cmd);
	}
	
	protected boolean inChannel() {
		return sChannel != null;
	}
	
	private String order(String orderId, String sig, String timerout, String channel, String type, String content) {
		String order = String.format("id=%s&sig=%s&t=%s&channel=%s&type=%s&content=%s", orderId, sig, timerout, channel, type, content);
		if (!order.endsWith("\r\n"))
			order += "\r\n";
		
		KuwoLog.d(TAG, "Live Socket Order:   " + order);
		return order;
	}
	
	public interface OnLiveDataRecieveListener {
		/*
			c: 频道ID
			t: 消息类型，0-系统消息，1-频道消息，2-私聊消息，3-普通系统消息（状态消息）
			f: 发送者ID
			n: 发送者名称
		 */
//		void onLiveDataRecieve(String id, String c, String t, String f, String data);
		
		// 房间频道消息（登录、加入、离开、主播切换）
		void onChannelMessageRecieve(String id, String c, String t, String f, String data);
		
		// 聊天消息
		void onChatMessageRecieve(String id, String c, String t, String f, String n, String data);
		
		void onError(String id, String c, String t, String f, String n, String data);
	}
	
	protected void onChannelMessageRecieve(String id, String c, String t, String f, String data) {
		KuwoLog.d(TAG, "sChannel :" + sChannel);
//		if(c.equals("0")){
////			登录
//			sChannel = "0";
//		}
//		
//		else if(sChannel.equals(c)){
//				//离开频道
//			if(data.contains("ok"))
//				sChannel = null;
//		}
//		else{
//			//进入频道
//			// TODO 这个可能有问题 第二次发消息时没有Channel数据
//			if(data.contains("ok"))
//				sChannel = c;
//		}
				
		if (mOnLiveDataRecieveListener != null)
			mOnLiveDataRecieveListener.onChannelMessageRecieve(id, c, t, f, data);
	}
	
	protected void onChatMessageRecieve(String id, String c, String t, String f, String n, String data) {
		
		if(f.equals("0")&&!data.contains("ok")){
			//发送消息没成功
			onError(id, c, t, f, n, data);
			return;
		}
		
		KuwoLog.d(TAG, "onChatMessageRecieve");
		
		if (mOnLiveDataRecieveListener != null)
			mOnLiveDataRecieveListener.onChatMessageRecieve(id, c, t, f, n, data);
	}
	
	protected void onError(String id, String c, String t, String f, String n, String data) {
		if (mOnLiveDataRecieveListener != null)
			mOnLiveDataRecieveListener.onError(id, c, t, f, n, data);
	}
	 
	public void setOnErrorListener(OnErrorListener l) {
		mOnErrorListener = l;
		mCommonSocket.setOnErrorListener(mOnErrorListener);
	}
	
	public void setOnLiveDataRecieveListener(OnLiveDataRecieveListener l) {
		mOnLiveDataRecieveListener = l;
	}
	
	private OnDataRecieveListener lOnDataRecieve = new OnDataRecieveListener() {
		
		@Override
		public void onDataRecieve(String data) {
			// 解析参数
			HashMap<String, String> params = null;
			InputStream is = new ByteArrayInputStream(data.getBytes());
			params = parseResult(is);
			
			// 触发事件
			if(params.get("n") != null){
				onChatMessageRecieve(params.get("id"),params.get("c"),params.get("t"),params.get("f"),params.get("n"),params.get("content"));
			} else{
				onChannelMessageRecieve(params.get("id"),params.get("c"),params.get("t"),params.get("f"),params.get("status"));
			}
		}
	};
	
	private HashMap<String, String> parseResult(InputStream inStream) {
		HashMap<String, String> params = new HashMap<String, String>();
		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("resp")) {
						params.put("id", parser.getAttributeValue(null, "id"));
						params.put("c", parser.getAttributeValue(null, "c"));
						params.put("t", parser.getAttributeValue(null, "t"));
						params.put("f", parser.getAttributeValue(null, "f"));
						params.put("n", parser.getAttributeValue(null, "n"));
						
						// TODO Content
					}
					else if(name.equals("result")) {
						params.put("status", parser.getAttributeValue(null, "status"));
					}
					break;
				case XmlPullParser.TEXT:
					params.put("content", parser.getText());
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			KuwoLog.d(TAG, params.get("id") + "  " + params.get("t") + "  " + params.get("c"));
			return params;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

}
