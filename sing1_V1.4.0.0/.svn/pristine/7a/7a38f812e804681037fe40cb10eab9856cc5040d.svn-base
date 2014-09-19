package cn.kuwo.sing.business;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import org.xmlpull.v1.XmlPullParser;

import android.util.Xml;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.bean.MTV;


public class ListParser {
	private String LOG_TAG = "ListParser";
	
	public List<MTV> parseSquareHotSong(int page, int size, String dataString){
		if (dataString.equals("")){
			return null;
		}
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		List<MTV> mtvlistsList = null;
		mtvlistsList = readHotSongsXML(is,"HotSongs"+page+"a"+size);
		if(mtvlistsList != null && mtvlistsList.size()!=0){
			return mtvlistsList;
		}
		return null;
	}
	
	public List<MTV> parseSquareSuperStar(int page, int size, String dataString){
		if (dataString.equals("")){
			return null;
		}
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		List<MTV> mtvlistsList = null;
		mtvlistsList = readNewSongsXML(is,"NewSongs"+page+"a"+size);
		if(mtvlistsList != null && mtvlistsList.size()!=0){
			return mtvlistsList;
		}
		return null;
	}
	
	public List<MTV> parseSquareLattestSong(String dataString){
		if (dataString.equals("")){
			return null;
		}

		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		List<MTV> mtvlistsList = null;
		mtvlistsList = readSuperStarsXML(is, null);
		if(mtvlistsList != null && mtvlistsList.size()!=0){
			return mtvlistsList;
		}
		return null;
	}
	
	private List<MTV> readHotSongsXML(InputStream inStream, String id) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			MTV currentMtv = null;
			List<MTV> mtvs_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					mtvs_list = new ArrayList<MTV>();
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if(name.equalsIgnoreCase("t")){
						String str = parser.nextText();
//						if(str.equals(hotSongsSig)&&id!=null){//当id为null时，表示正在从缓存取数据，不需要更新时间，当不为null时，表示是从服务器取数据，sig相同则更新时间
//							CacheManager.freshCache(id);
//						}else{
//							hotSongsSig = str;
//						}
					}
					if(name.equalsIgnoreCase("current_pn")) {
						String currentPageNum = parser.nextText();
//						hotCurrentPageNum = Integer.parseInt(currentPageNum);
					}
					if(name.equalsIgnoreCase("total_pn")) {
						String totalPageNum = parser.nextText();
//						hotTotalPageNum = Integer.parseInt(totalPageNum);
					}
					if (name.equalsIgnoreCase("list")) {
						currentMtv = new MTV();
					}
					if (name.equalsIgnoreCase("id")) {
						currentMtv.kid= parser.nextText();
					} 
					if(name.equalsIgnoreCase("type")) {
						currentMtv.type = parser.nextText();
					}
					if(name.equalsIgnoreCase("url")) {
						currentMtv.url = parser.nextText();
					}
					if (name.equalsIgnoreCase("title")) {
						currentMtv.title = parser.nextText();
					}  
					if (name.equalsIgnoreCase("pic")) {
						currentMtv.userpic = parser.nextText();
					} 
					if (name.equalsIgnoreCase("uname")) {
						currentMtv.uname = parser.nextText();
					}
					if (name.equalsIgnoreCase("view")) {
						currentMtv.view = parser.nextText();
					} 
					if (name.equalsIgnoreCase("comment")) {
						currentMtv.comment = parser.nextText();
					} 
					if (name.equalsIgnoreCase("flower")) {
						currentMtv.flower = parser.nextText();
					} 
					if (name.equalsIgnoreCase("sid")) {
						currentMtv.sid = parser.nextText();
					}
					
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("list")
							&& mtvs_list != null) {
						mtvs_list.add(currentMtv);
						currentMtv = null;
					}
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			return mtvs_list;
		} catch (Exception e) {
			KuwoLog.printStackTrace(e);
		}
		return null;
	}
	
	private List<MTV> readNewSongsXML(InputStream inStream,String id) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			MTV currentMtv = null;
			List<MTV> mtvs_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					mtvs_list = new ArrayList<MTV>();
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if(name.equalsIgnoreCase("t")){
						String str  = parser.nextText();
//						if(str.equals(newSongsSig)&&(id!=null)){//当id为null时，表示正在从缓存取数据，不需要更新时间，当不为null时，表示是从服务器取数据，sig相同则更新时间
//							CacheManager.freshCache(id);
//							KuwoLog.i(TAG, "newSongsSig="+newSongsSig);
//						}else{
//							newSongsSig = str;
//						}
						
					}
					if(name.equalsIgnoreCase("current_pn")) {
						String currentPageNum = parser.nextText();
//						newCurrentPageNum = Integer.parseInt(currentPageNum);
					}
					if(name.equalsIgnoreCase("total_pn")) {
						String totalPageNum = parser.nextText();
//						newTotalPageNum = Integer.parseInt(totalPageNum);
					}
					if (name.equalsIgnoreCase("list")) {
						currentMtv = new MTV();
					}
					if (name.equalsIgnoreCase("id")) {
							currentMtv.kid= parser.nextText();
						} 
						if (name.equalsIgnoreCase("title")) {
							currentMtv.title = parser.nextText();
						}  if (name.equalsIgnoreCase("pic")) {
							currentMtv.userpic = parser.nextText();
						} if (name.equalsIgnoreCase("uname")) {
							currentMtv.uname = parser.nextText();
						}if (name.equalsIgnoreCase("view")) {
							currentMtv.view = parser.nextText();
						} if (name.equalsIgnoreCase("comment")) {
							currentMtv.comment = parser.nextText();
						} if (name.equalsIgnoreCase("flower")) {
							currentMtv.flower = parser.nextText();
						} if (name.equalsIgnoreCase("sid")) {
							currentMtv.sid = parser.nextText();
						}
					
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("list")
							&& mtvs_list != null) {
						mtvs_list.add(currentMtv);
						currentMtv = null;
					}
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			return mtvs_list;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}	
	
	private List<MTV> readSuperStarsXML(InputStream inStream, String id) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			MTV currentMtv = null;
			List<MTV> mtvs_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					mtvs_list = new ArrayList<MTV>();
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if(name.equalsIgnoreCase("t")){
						
						String str = parser.nextText();
//						if(str.equals(SuperStarsSig)&&(id!=null)){//当id为null时，表示正在从缓存取数据，不需要更新时间，当不为null时，表示是从服务器取数据，sig相同则更新时间
//							CacheManager.freshCache(id);
//							KuwoLog.i(TAG, "SuperStarsSig="+SuperStarsSig);
//						}else{
//							SuperStarsSig = str;
//						}
					}
					if(name.equalsIgnoreCase("current_pn")) {
						String currentPageNum = parser.nextText();
//						superCurrentPageNum = Integer.parseInt(currentPageNum);
					}
					if(name.equalsIgnoreCase("total_pn")) {
						String totalPageNum = parser.nextText();
//						superTotalPageNum = Integer.parseInt(totalPageNum);
					}
					if (name.equalsIgnoreCase("list")) {
						currentMtv = new MTV();
					}
					if (name.equalsIgnoreCase("id")) {
							currentMtv.kid= parser.nextText();
						} 
						if (name.equalsIgnoreCase("title")) {
							currentMtv.title = parser.nextText();
						}  if (name.equalsIgnoreCase("pic")) {
							currentMtv.userpic = parser.nextText();
						} if (name.equalsIgnoreCase("uname")) {
							currentMtv.uname = parser.nextText();
						}if (name.equalsIgnoreCase("view")) {
							currentMtv.view = parser.nextText();
						} if (name.equalsIgnoreCase("comment")) {
							currentMtv.comment = parser.nextText();
						} if (name.equalsIgnoreCase("flower")) {
							currentMtv.flower = parser.nextText();
						} if (name.equalsIgnoreCase("sid")) {
							currentMtv.sid = parser.nextText();
						}
					
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("list")
							&& mtvs_list != null) {
						mtvs_list.add(currentMtv);
						currentMtv = null;
					}
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			return mtvs_list;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}	
}
