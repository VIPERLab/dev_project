package cn.kuwo.sing.logic.service;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import android.util.Xml;

import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.network.HttpProvider;
import cn.kuwo.sing.bean.LiveRoom;

public class LiveHttpService {
	private final String TAG = "LiveHttpService";
	public static String sUrl = null;
	
	/**
	 * 直播登录
	 * @throws UnsupportedEncodingException 
	 */
	public HashMap<String, String> login(String uname, String password) {
		
		String name = null;
		String psw = null;
		try {
			name = URLEncoder.encode(uname,"utf-8");
			psw = URLEncoder.encode(password,"utf-8");
		} catch (UnsupportedEncodingException e) {
			KuwoLog.printStackTrace(e);
		}
		
		StringBuilder sBuilder = new StringBuilder("<voice><cmd>login</cmd><user><name>").
				append(name).append("</name><passwd>").append(psw).append("</passwd></user></voice>");
		
		String url = "http://60.28.217.188/voice.login";
		String result = post(url, sBuilder.toString());
		KuwoLog.i(TAG, "sBuilder: " + sBuilder.toString());
		KuwoLog.i(TAG, "Login: " + result);
		InputStream is = new ByteArrayInputStream(result.getBytes());
		return parseLoginResult(is);
	}
	
	private HashMap<String, String> parseLoginResult(InputStream inStream){
		HashMap<String, String> params = new HashMap<String, String>();
		XmlPullParser parser = Xml.newPullParser();
		try {
			boolean flag = false;
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("status")) {
						String state = parser.nextText();
						if(!state.equals("1")){
//							throw new LiveException("login", state);
						}
						flag = true;
					} 
					if (name.equalsIgnoreCase("id")) {
						params.put("user_id", parser.nextText());
					} 
					if (name.equalsIgnoreCase("name")) {
						params.put("user_name", parser.nextText());
					} 
					if (name.equalsIgnoreCase("sid")) {
						params.put("user_sid", parser.nextText());
					} 
					if (name.equalsIgnoreCase("url")) {
						String urlString =  parser.nextText();
						params.put("server_url", urlString);
						if(flag){
							sUrl = urlString;
						}
					} 
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			KuwoLog.d(TAG, "" + params.get("user_id") + params.get("user_sid") + params.get("server_url") + params.get("user_name"));
			return params;
		} catch (XmlPullParserException e) {
			e.printStackTrace();
		}catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
	
	

	/**
	 * 获取本人基本信息(与DJ服务交互)
	 */
	public HashMap<String, String> getMyInfo(String id, String sid)  {

		StringBuilder sBuilder = new StringBuilder();
		sBuilder.append("<voice><cmd>getmyinfo</cmd><user><id>").append(id).append("</id><sid>").append(sid).append("</sid></user></voice>");
		
		String result = post(sUrl, sBuilder.toString());
		KuwoLog.i(TAG, "sBuilder: " + sBuilder.toString());
		KuwoLog.i(TAG, "getMyInfo: " + result);
		InputStream is = new ByteArrayInputStream(result.getBytes());
		return parseLoginResult(is);
	}
	
	/**
	 * 获取大厅(与DJ服务交互)
	 */
	public List<LiveRoom> getHall()  {
		
		String data = "<voice><cmd>gethall</cmd></voice>";
		String result = post(sUrl, data);
		KuwoLog.i(TAG, "getHall: " + result);
		InputStream is = new ByteArrayInputStream(result.getBytes());
		return parseHallResult(is);
		
	}
	
	private List<LiveRoom> parseHallResult(InputStream inStream) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			String songname;
			Boolean type = false;
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			LiveRoom currentRoom = null;
			List<LiveRoom> rooms_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					rooms_list = new ArrayList<LiveRoom>();
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("status")) {
						String state = parser.nextText();
						if(!state.equals("1")){
//							throw new LiveException("login", state);
						}
					} 
					if(name.equalsIgnoreCase("type")){
						if(parser.nextText().equals("2")){
							type = false;
						}
						else{
							type = true;
						}
					}
					if (name.equalsIgnoreCase("room")&&type) {
						currentRoom = new LiveRoom();
					}
					if (name.equalsIgnoreCase("id")&&type) {
						currentRoom.setId(parser.nextText()) ;
					} 
					if (name.equalsIgnoreCase("name")&&type) {
						songname = URLDecoder.decode(parser.nextText(), "utf-8");
						currentRoom.setName(songname);
					}  if (name.equalsIgnoreCase("pic")&&type) {
						currentRoom.setPic(parser.nextText());
					} if (name.equalsIgnoreCase("public")&&type) {
						currentRoom.setPublictype(parser.nextText());
					}if (name.equalsIgnoreCase("onlinecnt")&&type) {
						currentRoom.setOnlinecnt(parser.nextText());
					}
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("room")
							&& currentRoom != null) {
						rooms_list.add(currentRoom);
						currentRoom = null;
					}
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			KuwoLog.d(TAG, rooms_list.size() + "" );
			return rooms_list;
		} catch (XmlPullParserException e) {
			e.printStackTrace();
		}catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 离开大厅
	 * 返回status的值
	 * @throws UnsupportedEncodingException 
	 */
	public String leftHall(String uid, String sid) {
//		TODO 还没测试
//		<voice><cmd>exithall</cmd><user><id>25180</id><sid>123456</sid></user></voice>
		StringBuilder sBuilder = new StringBuilder("<voice><cmd>exithall</cmd><user><id>").
				append(uid).append("</id><sid>").append(sid).append("</sid></user></voice>");
		
		String result = post(sUrl, sBuilder.toString());
		KuwoLog.i(TAG, "logout: " + sBuilder.toString());
		KuwoLog.i(TAG, "logout: " + result);
		int first = result.indexOf("status");
		int second  = result.indexOf("status", first + 6);
		String str = result.substring(first + 7, second - 2);
		return str;
	}
	/**
	 * 进入房间(与DJ服务交互)
	 */
	public HashMap<String, String> enterRoom(String uid, String sid, String roomId)  {
		StringBuilder sBuilder = new StringBuilder();
		sBuilder.append("<voice><cmd>enterroom</cmd><user><id>").append(uid).append("</id><sid>").
		         append(sid).append("</sid></user><room><id>").append(roomId).append("</id><pwd></pwd></room></voice>");
		String result = post(sUrl, sBuilder.toString());
		KuwoLog.i(TAG, "enterRoom: " + result);
		InputStream is = new ByteArrayInputStream(result.getBytes());
		return parseEnterRoomlResult(is);
		
	}
	
	private HashMap<String, String> parseEnterRoomlResult(InputStream inStream) {
		HashMap<String, String> params = new HashMap<String, String>();
		XmlPullParser parser = Xml.newPullParser();
		try {
			String songname;
			Boolean type = false;
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("status")) {
						String state = parser.nextText();
						if(!state.equals("1")){
//							throw new LiveException("login", state);
						}
					} 
					if (name.equalsIgnoreCase("url")) {
						params.put("url", parser.nextText());
					}
					if (name.equalsIgnoreCase("op")) {
						params.put("op", parser.nextText());
					} 
					if (name.equalsIgnoreCase("tm")) {
						params.put("tm", parser.nextText());
					} 
					if (name.equalsIgnoreCase("md5")) {
						params.put("md5", parser.nextText());
					} 
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			KuwoLog.d(TAG, params.size() + "" );
			return params;
		} catch (XmlPullParserException e) {
			e.printStackTrace();
		}catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 离开房间(与DJ服务交互)
	 * 返回status的值
	 */
	public String leftRoom(String uid, String sid, String roomId)  {
//		TODO 还未测试
		StringBuilder sBuilder = new StringBuilder();
//		<voice><cmd>exitroom</cmd><user><id>25180</id><sid>123456</sid></user><room><id>1</id></room></voice>
		sBuilder.append("<voice><cmd>exitroom</cmd><user><id>").append(uid).append("</id><sid>").
		         append(sid).append("</sid></user><room><id>").append(roomId).append("</id></room></voice>");
		String result = post(sUrl, sBuilder.toString());
		KuwoLog.i(TAG, "enterRoom: " + result);
		int first = result.indexOf("status");
		int second  = result.indexOf("status", first + 6);
		String str = result.substring(first + 7, second - 2);
		return str;
		
	}
	
	/**
	 * 获取台上主播信息(与DJ服务交互)
	 */
	public HashMap<String, String> getAnchorInfo(String uid, String sid, String roomId)  {
		StringBuilder sBuilder = new StringBuilder();
		sBuilder.append("<voice><cmd>getdj</cmd><user><id>").append(uid).append("</id><sid>").
		         append(sid).append("</sid></user><room><id>").append(roomId).append("</id></room></voice>");
		String result = post(sUrl, sBuilder.toString());
		KuwoLog.i(TAG, "getAnchorInfo: " + result);
		InputStream is = new ByteArrayInputStream(result.getBytes());
		return parseAnchorInfoResult(is);
		
	}
	
	private HashMap<String, String> parseAnchorInfoResult(InputStream inStream) {
		HashMap<String, String> params = new HashMap<String, String>();
		XmlPullParser parser = Xml.newPullParser();
		try {
			String anchorId = null;
			Boolean flag1 = true;
			Boolean flag2 = false;
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("status")) {
						String state = parser.nextText();
						if(!state.equals("1")){
//							throw new LiveException("login", state);
						}
					} 
					if (name.equalsIgnoreCase("id")&&flag1) {
						params.put("anchorId", parser.nextText());
						KuwoLog.d(TAG, "id:" + params.get("anchorId"));
					}
					if (name.equalsIgnoreCase("name")&&flag1) {
						String nameString = URLDecoder.decode(parser.nextText(), "utf-8");
						params.put("anchorName", nameString);
					}
					if (name.equalsIgnoreCase("name")) {
						flag1 = false;
					}
					if (name.equalsIgnoreCase("gift")&&!flag2) {
						params.put("flowers", parser.nextText());
						flag2 = true;
					}
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			KuwoLog.d(TAG, params.get("anchorId")+ " anchorid" + params.get("anchorName") );
			return params;
		}catch (XmlPullParserException e) {
			e.printStackTrace();
		}catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 获取台上主播图片
	 * @throws IOException 
	 */
	public List<String> getAnchorPic( String anchorId) throws IOException  {
		String url = "http://kzone.kuwo.cn/mlog/getVoicePhoto?uid=" + anchorId;
		DefaultService ds = new DefaultService();
		String result = ds.read(url);
		KuwoLog.i(TAG, "getAnchorPic: " + result);
		return parseAnchorPics(result);
	}
	
    private List<String> parseAnchorPics(String str){
    	List<String> lists = new ArrayList <String>();
    	int begin = str.indexOf("[");
    	int end = str.indexOf("]");
    	if(end - begin == 1)
    		return null;
    	String newstr = str.substring(begin+1, end);  
    	String[] a = newstr.split(",");  
    	for(int i = 0; i < a.length; i++){
    		String url = a[i].substring(1, a[i].length()-1);
    		lists.add(url);
    	}
//    	KuwoLog.d(TAG, str + " list: " + lists.size()+ " "+ lists.get(1));
    	return lists;
    }
	
	//	public HashMap<String, String> parseMyInfoResult(InputStream inStream){
//		HashMap<String, String> params = new HashMap<String, String>();
//		XmlPullParser parser = Xml.newPullParser();
//		try {
//			parser.setInput(inStream, "UTF-8");
//			int eventType = parser.getEventType();
//			while (eventType != XmlPullParser.END_DOCUMENT) {
//				switch (eventType) {
//				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
//					break;
//				case XmlPullParser.START_TAG:// 开始元素事件
//					String name = parser.getName();
//					if(name.equalsIgnoreCase("user")){
//						if (name.equalsIgnoreCase("family")) {
//							if (name.equalsIgnoreCase("id")) {
//								params.put("user_family_id", parser.nextText());
//							}
//							if (name.equalsIgnoreCase("name")) {
//								params.put("user_family_name", parser.nextText());
//							}
//						}
//						if (name.equalsIgnoreCase("account")) {
//							if (name.equalsIgnoreCase("coin")) {
//								params.put("user_account_coin", parser.nextText());
//							}
//							if (name.equalsIgnoreCase("shell")) {
//								params.put("user_account_shell", parser.nextText());
//							}
//						}
//						if (name.equalsIgnoreCase("id")) {
//							params.put("user_id", parser.nextText());
//						} 
//						if (name.equalsIgnoreCase("name")) {
//							params.put("user_name", parser.nextText());
//						} 
//						if (name.equalsIgnoreCase("lvl")) {
//							params.put("user_lvl", parser.nextText());
//						} 
//						if (name.equalsIgnoreCase("singerlvl")) {
//							params.put("user_singerlvl", parser.nextText());
//						} 
//						if (name.equalsIgnoreCase("pic")) {
//							params.put("user_pic", parser.nextText());
//						} 
//						if (name.equalsIgnoreCase("identity")) {
//							params.put("user_identity", parser.nextText());
//						} 
//						if (name.equalsIgnoreCase("title")) {
//							params.put("user_title", parser.nextText());
//						} 
//						if (name.equalsIgnoreCase("createtm")) {
//							params.put("user_createtm", parser.nextText());
//						}
//					}
//					
//					if(name.equalsIgnoreCase("chatroom")){
//						if (name.equalsIgnoreCase("server")) {
//							params.put("chatroom_server", parser.nextText());
//						}
//						if (name.equalsIgnoreCase("tm")) {
//							params.put("chatroom_tm", parser.nextText());
//						}
//						if (name.equalsIgnoreCase("id")) {
//							params.put("chatroom_channel_id", parser.nextText());
//						}
//						if (name.equalsIgnoreCase("sig")) {
//							params.put("chatroom_channel_sig", parser.nextText());
//						}
//					}
//					break;
//				case XmlPullParser.END_TAG:// 结束元素事件
//					break;
//				}
//				eventType = parser.next();
//			}
//			inStream.close();
//			KuwoLog.d(TAG, "" + params.get("chatroom_server") + params.get("user_account_coin") + params.get("user_family_id"));
//			return params;
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
//		return null;
//	}
	
	
	/**
	 * 获取聊天服务频道签名(与DJ服务交互)
	 */
	public HashMap<String, String> getChatSignature(String id, String sid ,String roomid, String type)  {
		
		StringBuilder sBuilder = new StringBuilder("<voice><cmd>getchatsig</cmd><user><id>").append(id).
				append("</id><sid>").append(sid).append("</sid></user><type>").append(type).append("</type><room><id>").append(roomid).append("</id></room></voice>");
		
		String result = post(sUrl, sBuilder.toString());
		KuwoLog.i(TAG, "getChatSignature: " + result);
		InputStream is = new ByteArrayInputStream(result.getBytes());
		return parseChatSignatureResult(is);
	}
	
	private HashMap<String, String> parseChatSignatureResult(InputStream inStream){
		HashMap<String, String> params = new HashMap<String, String>();
		XmlPullParser parser = Xml.newPullParser();
		try {
			boolean flag = false;
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("status")) {
						String state = parser.nextText();
						if(!state.equals("1")){
//							throw new LiveException("login", state);
						}
						flag = true;
					} 
					if (name.equalsIgnoreCase("server")) {
						params.put("chatroom_server", parser.nextText());
					} 
					if (name.equalsIgnoreCase("timeout")) {
						params.put("chatroom_timeout", parser.nextText());
					} 
					if (name.equalsIgnoreCase("sig")) {
						params.put("chatroom_channel_sig", parser.nextText());
					} 
					
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			KuwoLog.d(TAG, "ge" + params.get("chatroom_server") + params.get("chatroom_timeout") + params.get("chatroom_channel_sig"));
			return params;
		} catch (XmlPullParserException e) {
			e.printStackTrace();
		}catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
	
	/**
	 * 请求房间所在服务器地址(与登录服务交互)
	 */
	public String getServerAddr(String id, String sid ,String roomid)  {
//		TODO 未测试
		StringBuilder sBuilder = new StringBuilder("<voice><cmd>getsvraddr</cmd><user><id>").append(id).
				append("</id><sid>").append(sid).append("</sid></user><room><id>").append(roomid).append("</id></room></voice>");
		
		String result = post(sUrl, sBuilder.toString());
		KuwoLog.i(TAG, "getServerAddr(String, String, String): " + result);
		int first = result.indexOf("url");
		int second  = result.indexOf("url", first + 2);
		String str = result.substring(first + 4, second - 2);
		return str;
	}

	/**
	 * 赠送礼物(与DJ服务交互)
	 */
	public void sendGift(String id, String sid ,String value, String tm, String roomid, String fid, String giftid, String giftcount)  {
//		TODO 未测试
		String data = String.format("<voice><cmd>sendgift</cmd><user><id>%s</id><sid>%s</sid></user><md5><value>" +
				"%s</value><tm>%s</tm></md5><room><id>%s</id></room><user><id>%s</id></user><gift><id>%s</id><cnt>%s</cnt></gift></voice>",
				id,sid,value,tm,roomid,fid,giftid,giftcount);
		
		String result = post(sUrl, data);
		KuwoLog.i(TAG, "sendGift: " + result);
		if(data.contains("<status>1</status>")){
			int first = result.indexOf("coin");
			int second  = result.indexOf("coin", first + 2);
			String str = result.substring(first + 5, second - 2);
		}
	
//		return str;
	}
	
	
	/**
	 * 领取免费礼物(放在心跳消息中，与DJ服务交互)
	 */
	public void getFreeGift(String id, String sid) {
//		TODO 未测试
		StringBuilder sBuilder = new StringBuilder();
		sBuilder.append("<voice><cmd>heartbeat</cmd><user><id>").append(id).append("</id><sid>").append(sid).append("</sid></user></voice>");
		
		String result = post(sUrl, sBuilder.toString());
		KuwoLog.i(TAG, "sendGift: " + result);
//		int first = result.indexOf("status");
//		int second  = result.indexOf("status", first + 6);
//		String str = result.substring(first + 7, second - 2);
//		return str;
	}
	
	protected String post(String url, String data) {
		HttpProvider provider = new HttpProvider();
		return provider.post(url, data);
	}
	

	
}
