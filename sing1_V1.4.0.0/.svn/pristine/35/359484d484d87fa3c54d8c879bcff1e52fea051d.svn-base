package cn.kuwo.sing.logic;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import org.xmlpull.v1.XmlPullParser;
import android.annotation.SuppressLint;
import android.text.TextUtils;
import android.util.Xml;
import cn.kuwo.framework.cache.CacheManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.TimeUtils;
import cn.kuwo.sing.bean.MTV;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.bean.SearchResult;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.logic.service.MusicListService;

@SuppressLint("UseValueOf")
public class MusicListLogic {
	private final String TAG = "MusicListLogic";
	private String newListSig = null;
	private String hotListSig = null;
	private String subListSig = null;
	private String singerListSig = null;
	private String singerSubListSig = null;
	private String hotSingerSubListSig = null;
	private String singerSongListSig = null;
	private static String hotSongsSig = null;
	private static String newSongsSig = null;
	private static String SuperStarsSig = null;
	
	public static int hotCurrentPageNum = -1;
	public static int hotTotalPageNum = -1;
	public static int newCurrentPageNum = -1;
	public static int newTotalPageNum = -1;
	public static int superCurrentPageNum = -1;
	public static int superTotalPageNum = -1;
	
	public List<Music> getCacheNewList(int pagenum, int size) throws IOException {
		String dataString = CacheManager.loadString("NewList"+pagenum+"a"+size);
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readNewListXML(is);
	}
	
	public boolean checkCacheNewList(int pagenum, int size) {
		return CacheManager.checkCache("NewList"+pagenum+"a"+size, TimeUtils.HOUR*3);
	}
	
	/**
	 * 获取最新榜单
	 * @throws IOException 
	 */
	public List<Music> getNewList(int pagenum, int size) throws IOException {
		MusicListService musicListService = new MusicListService();
		String dataString = musicListService.getNewList(pagenum, size,newListSig);
		if (TextUtils.isEmpty(dataString)) {
			return null;
		}
		
		String signString = dataString.substring(0, dataString.indexOf("\r\n"));
		newListSig = signString.substring(signString.indexOf('=')+1);
		dataString = dataString.substring(dataString.indexOf("\r\n")+1).trim();
		
		CacheManager.cacheString("NewList"+pagenum+"a"+size, dataString);
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readNewListXML(is);
	}
	
	public List<Music> getCacheHotList() throws IOException {
		String dataString = CacheManager.loadString("HotList");
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readHotListXML(is);
	}
	
	public boolean checkCacheHotList() {
		return CacheManager.checkCache("HotList", TimeUtils.HOUR*3);
	}
	/**
	 * 获取热门
	 * @throws IOException 
	 */
	public List<Music> getHotList() throws IOException {
		MusicListService musicListService = new MusicListService();
		String dataString = musicListService.getHotList(hotListSig);
		if (TextUtils.isEmpty(dataString)) {
			return null;
		}
		String signString = dataString.substring(0, dataString.indexOf("\r\n"));
		hotListSig = signString.substring(signString.indexOf('=')+1);
		dataString = dataString.substring(dataString.indexOf("\r\n")+1).trim();
		
		CacheManager.cacheString("HotList", dataString);
//		KuwoLog.i(TAG, "dataString="+dataString);
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readHotListXML(is);
	}
	
	public List<Music> getCacheSubList(String listid, int pagenum, int size) throws IOException {
		String dataString = CacheManager.loadString("SubList"+listid+"a"+pagenum+"a"+size);
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readNewListXML(is);
	}
	
	public boolean checkCacheSubList(String listid, int pagenum, int size) {
		return CacheManager.checkCache("SubList"+listid+"a"+pagenum+"a"+size, TimeUtils.DAY*30);
	}
	/**
	 * 获取榜单子榜单
	 * @throws IOException 
	 *  
	 */
	public List<Music> getSubList(String listid, int pagenum, int size) throws IOException {
		MusicListService musicListService = new MusicListService();
		String dataString = musicListService.getSubList(listid,pagenum,size,subListSig);
		if (TextUtils.isEmpty(dataString)) {
			return null;
		}
		String signString;
		try {
			signString = dataString.substring(0, dataString.indexOf("\r\n"));
		} catch (Exception e) {
			return null;
		}
		subListSig = signString.substring(signString.indexOf('=')+1);
		dataString = dataString.substring(dataString.indexOf("\r\n")+1).trim();
		
		CacheManager.cacheString("SubList"+listid+"a"+pagenum+"a"+size, dataString);
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readNewListXML(is);
	}
	
	public List<Music> getCacheSingerList() throws IOException {
		String dataString = CacheManager.loadString("SingerList");
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readSingerListXML(is);
	}
	
	public boolean checkCacheSingerList() {
		return CacheManager.checkCache("SingerList", TimeUtils.DAY*30);
	}
	/**
	 * 获取歌手榜单
	 * @throws IOException 
	 */
	public List<Music> getSingerList() throws IOException {
		MusicListService musicListService = new MusicListService();
		String dataString = musicListService.getSingerList(singerListSig);
		if (TextUtils.isEmpty(dataString)) {
			return null;
		}
		String signString = dataString.substring(0, dataString.indexOf("\r\n"));
		singerListSig = signString.substring(signString.indexOf('=')+1);
		dataString = dataString.substring(dataString.indexOf("\r\n")+1).trim();
		
		CacheManager.cacheString("SingerList", dataString);
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readSingerListXML(is);
	}
	
	
	public HashMap<String, List<Music>> getCacheSingerSubList(String singerid) throws IOException {
		String dataString = CacheManager.loadString("SingerSubList"+singerid);
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readSingerSubListXML(is);
	}
	
	public boolean checkCacheSingerSubList(String singerid) {
		return CacheManager.checkCache("SingerSubList"+singerid, TimeUtils.DAY*30);
	}
	/**
	 * 获取歌手子列表
	 * @throws IOException 
	 */
	public HashMap<String, List<Music>> getSingerSubList(String singerid) throws IOException {
		MusicListService musicListService = new MusicListService();
		String dataString = musicListService.getSingerSubList(singerid,singerSubListSig);
		if (TextUtils.isEmpty(dataString)) {
			return null;
		}
		String signString = dataString.substring(0, dataString.indexOf("\r\n"));
		singerSubListSig = signString.substring(signString.indexOf('='));
		dataString = dataString.substring(dataString.indexOf("\r\n")+1).trim();
		
		CacheManager.cacheString("SingerSubList"+singerid, dataString);
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readSingerSubListXML(is);
	}
	
	public List<Music> getCacheHotSingerSubList(String singerid) throws IOException {
		String dataString = CacheManager.loadString("HotSingerSubList"+singerid);
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		List<Music> result = readHotSingerSubListXML(is);
		return result;
	}
	
	public boolean checkCacheHotSingerSubList(String singerid) {
		return CacheManager.checkCache("HotSingerSubList"+singerid, TimeUtils.DAY*10);
	}
	/**
	 * 获取热门歌手子列表
	 * @throws IOException 
	 */
	public List<Music> getHotSingerSubList(String singerid) throws IOException {
		MusicListService musicListService = new MusicListService();
		String dataString = musicListService.getSingerSubList(singerid,hotSingerSubListSig);
		if (TextUtils.isEmpty(dataString)) {
			return null;
		}
		String signString = dataString.substring(0, dataString.indexOf("\r\n"));
		hotSingerSubListSig = signString.substring(signString.indexOf('='));
		dataString = dataString.substring(dataString.indexOf("\r\n")+1).trim();
		
		CacheManager.cacheString("HotSingerSubList"+singerid, dataString);
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readHotSingerSubListXML(is);
	}
	private List<Music> readSingerSubListXML1(InputStream inStream) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			Music currentMusic = null;
			List<Music> musics_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					musics_list = new ArrayList<Music>();
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("artist")) {
						currentMusic = new Music();
						currentMusic.setId(parser.getAttributeValue(0));
						currentMusic.setName(parser.getAttributeValue(1));
						currentMusic.setImg(parser.getAttributeValue(2));
						currentMusic.setNum(new Integer(parser.getAttributeValue(3)));
					}
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("artist")
							&& currentMusic != null) {
						musics_list.add(currentMusic);
						currentMusic = null;
					}
					
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			KuwoLog.d(TAG, musics_list.size()+ "");
			return musics_list;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
	//ABCD……
	private HashMap<String, List<Music>> readSingerSubListXML(InputStream inStream) {

		HashMap<String, List<Music>> params = new HashMap<String, List<Music>>();
		XmlPullParser parser = Xml.newPullParser();
		try {
			String tape = null;
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			Music currentMusic = null;
			List<Music> musics_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("section")) {
						musics_list = new ArrayList<Music>();
						tape = parser.getAttributeValue(null, "name");
						
					}
					if (name.equalsIgnoreCase("artist")) {
						currentMusic = new Music();
						currentMusic.setId(parser.getAttributeValue(null, "id"));
						currentMusic.setName(parser.getAttributeValue(null, "name"));
						currentMusic.setImg(parser.getAttributeValue(null, "img"));
						currentMusic.setNum(new Integer(parser.getAttributeValue(null, "num")));
					}
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("artist")
							&& currentMusic != null) {
						musics_list.add(currentMusic);
						currentMusic = null;
					}
					if (parser.getName().equalsIgnoreCase("section")
							&& musics_list != null) {
						params.put(tape, musics_list);
						musics_list = null;
					}
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			return params;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
	
	//ABCD……
		private List<Music> readHotSingerSubListXML(InputStream inStream) {

			XmlPullParser parser = Xml.newPullParser();
			try {
				parser.setInput(inStream, "UTF-8");
				int eventType = parser.getEventType();
				Music currentMusic = null;
				List<Music> musics_list = null;
				while (eventType != XmlPullParser.END_DOCUMENT) {
					switch (eventType) {
					case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
						
						break;
					case XmlPullParser.START_TAG:// 开始元素事件
						String name = parser.getName();
						if (name.equalsIgnoreCase("section")) {
							musics_list = new ArrayList<Music>();
							
						}
						if (name.equalsIgnoreCase("artist")) {
							currentMusic = new Music();
							currentMusic.setId(parser.getAttributeValue(null, "id"));
							currentMusic.setName(parser.getAttributeValue(null, "name"));
							currentMusic.setImg(parser.getAttributeValue(null, "img"));
							currentMusic.setNum(new Integer(parser.getAttributeValue(null, "num")));
						}
						break;
					case XmlPullParser.END_TAG:// 结束元素事件
						if (parser.getName().equalsIgnoreCase("artist")
								&& currentMusic != null) {
							musics_list.add(currentMusic);
							currentMusic = null;
						}
						break;
					}
					eventType = parser.next();
				}
				inStream.close();
				return musics_list;
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}
		public List<Music> getCacheSingerSongList(String singerid, int pagenum, int size) throws IOException {
			String dataString = CacheManager.loadString("SingerSongList"+singerid+"a"+pagenum+"a"+size);
			if(TextUtils.isEmpty(dataString)){
				return null;
			}
			InputStream is = new ByteArrayInputStream(dataString.getBytes());
			return readSingersongXML(is);
		}
		
		public boolean checkCacheSingerSongList(String singerid, int pagenum, int size) {
			return CacheManager.checkCache("SingerSongList"+singerid+"a"+pagenum+"a"+size, TimeUtils.DAY*30);
		}
	/**
	 * 获取歌星歌曲列表
	 * @throws IOException 
	 */
	public List<Music> getSingersongList(String singerid, int pagenum, int size) throws IOException {
		MusicListService musicListService = new MusicListService();
		String dataString = musicListService.getSingersongList(singerid, pagenum, size,singerSongListSig);
		if (TextUtils.isEmpty(dataString)) {
			return null;
		}
		String signString = dataString.substring(0, dataString.indexOf("\r\n"));
		singerSongListSig = signString.substring(signString.indexOf('='));
		dataString = dataString.substring(dataString.indexOf("\r\n")+1).trim();
		
		CacheManager.cacheString("SingerSongList"+singerid+"a"+pagenum+"a"+size, dataString);
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readSingersongXML(is);
	}
	
	
	public List<MTV> getCacheHotSongs(int page, int size) throws IOException {
		String dataString = CacheManager.loadString("HotSongs"+page+"a"+size);
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readHotSongsXML(is,null);
	}
	
	public boolean checkCacheHotSongs(int page, int size) {
		return CacheManager.checkCache("HotSongs"+page+"a"+size, TimeUtils.HOUR*3);
	}
	/**
	 * 获取广场 热门作品
	 * @param page
	 * @param size
	 * @return
	 * @throws IOException
	 */
	public List<MTV> getHotSongs(int page, int size) throws IOException {
		MusicListService musicListService = new MusicListService();
		String dataString = musicListService.getHotSongs(page, size,hotSongsSig);
		if (TextUtils.isEmpty(dataString)) {
			return null;
		}
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		List<MTV> mtvlistsList = null;
		mtvlistsList = readHotSongsXML(is,"HotSongs"+page+"a"+size);
		if(mtvlistsList != null && mtvlistsList.size()!=0){
			CacheManager.cacheString("HotSongs"+page+"a"+size, dataString);
		}
		return mtvlistsList;
	}
	
	
	public List<MTV> getCacheNewSongs(int page, int size) throws IOException {
		String dataString = CacheManager.loadString("NewSongs"+page+"a"+size);
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readNewSongsXML(is,null);
	}
	
	public boolean checkCacheNewSongs(int page, int size) {
		return CacheManager.checkCache("NewSongs"+page+"a"+size, TimeUtils.HOUR*3);
	}
	/**
	 * 获取最新作品
	 * @throws IOException 
	 */
	public List<MTV> getNewSongs(int page, int size) throws IOException {
		MusicListService musicListService = new MusicListService();
		String dataString = musicListService.getNewSongs(page, size,newSongsSig);
		if (TextUtils.isEmpty(dataString)) {
			return null;
		}
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		List<MTV> mtvlistsList = null;
		mtvlistsList = readNewSongsXML(is,"NewSongs"+page+"a"+size);
		if(mtvlistsList != null && mtvlistsList.size()!=0){
			CacheManager.cacheString("NewSongs"+page+"a"+size, dataString);
		}
		return mtvlistsList;
	}
	
	public List<MTV> getCacheSuperStars(int page, int size) throws IOException {
		String dataString = CacheManager.loadString("SuperStars"+page+"a"+size);
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		return readSuperStarsXML(is,null);
	}
	
	public boolean checkCacheSuperStars(int page, int size) {
		return CacheManager.checkCache("SuperStars"+page+"a"+size, TimeUtils.HOUR*3);
	}
	
	/**
	 * 获取K歌达人
	 * 
<list>
<id>69058531</id>
<pic1><![CDATA[http://star.kwcdn.kuwo.cn:81/star/upload/0/0/1352111465872_.jpg]]></pic1>
<pic2><![CDATA[]]></pic2>
<pic3><![CDATA[http://img3.kwcdn.kuwo.cn:81/star/userhead/31/91/1352718140056_69058531b.jpg]]></pic3>
<uname><![CDATA[思源5168]]></uname>
<flower>426</flower>
</list>
	 * @throws IOException 
	 */
	public List<MTV> getSuperStars(int page, int size) throws IOException {
		MusicListService musicListService = new MusicListService();
		String dataString = musicListService.getSuperStars(page, size,SuperStarsSig);
		if (TextUtils.isEmpty(dataString)) {
			return null;
		}
		
		InputStream is = new ByteArrayInputStream(dataString.getBytes());
		List<MTV> mtvlistsList = null;
		mtvlistsList = readSuperStarsXML(is,"SuperStars"+page+"a"+size);
		if(mtvlistsList != null && mtvlistsList.size()!=0){
			CacheManager.cacheString("SuperStars"+page+"a"+size, dataString);
		}
		return mtvlistsList;
	}

//	<music rid="709174" name="思思念念全是你" artist="高安" album="高安原唱精选集" duration="248" format="wma" hot="4" 
//			res="http://music3.9t9t.com/5/3406/7894/2074080343.wma" img=""/>
	private List<Music> readSingersongXML(InputStream inStream) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			Music currentMusic = null;
			List<Music> musics_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					musics_list = new ArrayList<Music>();
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("music")) {
						currentMusic = new Music();
						currentMusic.setId(parser.getAttributeValue(null, "rid"));
						currentMusic.setName(parser.getAttributeValue(null, "name"));
						currentMusic.setArtist(parser.getAttributeValue(null, "artist"));
						currentMusic.setAlbum(parser.getAttributeValue(null, "album"));
						currentMusic.setDuration(new Integer(parser.getAttributeValue(null, "duration")));
						currentMusic.setFormat(parser.getAttributeValue(null, "format"));
						currentMusic.setHot(new Integer(parser.getAttributeValue(null, "hot")));
						currentMusic.setRes(parser.getAttributeValue(null, "res"));
						currentMusic.setImg(parser.getAttributeValue(null, "img"));
					}
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("music")
							&& currentMusic != null) {
						musics_list.add(currentMusic);
						currentMusic = null;
					}
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			return musics_list;
		} catch (Exception e) {
			e.printStackTrace();
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
						if(str.equals(hotSongsSig)&&id!=null){//当id为null时，表示正在从缓存取数据，不需要更新时间，当不为null时，表示是从服务器取数据，sig相同则更新时间
							CacheManager.freshCache(id);
							KuwoLog.i(TAG, "hotSongsSig="+hotSongsSig);
						}else{
							hotSongsSig = str;
						}
					}
					if(name.equalsIgnoreCase("current_pn")) {
						String currentPageNum = parser.nextText();
						hotCurrentPageNum = Integer.parseInt(currentPageNum);
					}
					if(name.equalsIgnoreCase("total_pn")) {
						String totalPageNum = parser.nextText();
						hotTotalPageNum = Integer.parseInt(totalPageNum);
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
						if(str.equals(newSongsSig)&&(id!=null)){//当id为null时，表示正在从缓存取数据，不需要更新时间，当不为null时，表示是从服务器取数据，sig相同则更新时间
							CacheManager.freshCache(id);
							KuwoLog.i(TAG, "newSongsSig="+newSongsSig);
						}else{
							newSongsSig = str;
						}
						
					}
					if(name.equalsIgnoreCase("current_pn")) {
						String currentPageNum = parser.nextText();
						newCurrentPageNum = Integer.parseInt(currentPageNum);
					}
					if(name.equalsIgnoreCase("total_pn")) {
						String totalPageNum = parser.nextText();
						newTotalPageNum = Integer.parseInt(totalPageNum);
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
						if(str.equals(SuperStarsSig)&&(id!=null)){//当id为null时，表示正在从缓存取数据，不需要更新时间，当不为null时，表示是从服务器取数据，sig相同则更新时间
							CacheManager.freshCache(id);
							KuwoLog.i(TAG, "SuperStarsSig="+SuperStarsSig);
						}else{
							SuperStarsSig = str;
						}
					}
					if(name.equalsIgnoreCase("current_pn")) {
						String currentPageNum = parser.nextText();
						superCurrentPageNum = Integer.parseInt(currentPageNum);
					}
					if(name.equalsIgnoreCase("total_pn")) {
						String totalPageNum = parser.nextText();
						superTotalPageNum = Integer.parseInt(totalPageNum);
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
	
//	<music rid="535231" name="想你的夜" artist="关喆" album="永远的永远" duration="267" format="wma" hot="5" 
//	res="http://218.108.234.106/new6/20070117/2/8.wma" img="http://img1.kuwo.cn/star/starheads/55/20/72/1510786597.jpg"/>
	private List<Music> readNewListXML(InputStream inStream) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			Music currentMusic = null;
			List<Music> musics_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					musics_list = new ArrayList<Music>();
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("music")) {
						currentMusic = new Music();
						currentMusic.setId(parser.getAttributeValue(0));
						currentMusic.setName(parser.getAttributeValue(1));
						currentMusic.setArtist(parser.getAttributeValue(2));
						currentMusic.setAlbum(parser.getAttributeValue(3));
						currentMusic.setDuration(new Integer(parser.getAttributeValue(4)));
						currentMusic.setFormat(parser.getAttributeValue(5));
						currentMusic.setHot(new Integer(parser.getAttributeValue(6)));
						currentMusic.setRes(parser.getAttributeValue(7));
						currentMusic.setImg(parser.getAttributeValue(8));
					}
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("music")
							&& currentMusic != null) {
						musics_list.add(currentMusic);
						currentMusic = null;
					}
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			return musics_list;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
	
	
//	<list id="30" digest="0" name="K歌点唱榜" img="http://star.kwcdn.kuwo.cn:81/star/upload/11/11/1351755589595_.jpg"/>
	private List<Music> readHotListXML(InputStream inStream) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			Music currentMusic = null;
			List<Music> musics_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					musics_list = new ArrayList<Music>();
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("list")) {
						currentMusic = new Music();
						currentMusic.setId(parser.getAttributeValue(null, "id"));
						currentMusic.setDigest(new Integer(parser.getAttributeValue(null, "digest")));
						currentMusic.setName(parser.getAttributeValue(null, "name"));
						currentMusic.setImg(parser.getAttributeValue(null, "img"));
					}
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("list")
							&& currentMusic != null) {
						musics_list.add(currentMusic);
						currentMusic = null;
					}
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			return musics_list;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

//	<list id="21" child="sublist" name="热门歌手" digest="1" img="http://star.kwcdn.kuwo.cn:81/star/upload/10/10/1347002202554_.jpg" desc="代表歌手周杰伦、王力宏、陈奕迅"/>
	private List<Music> readSingerListXML(InputStream inStream) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			Music currentMusic = null;
			List<Music> musics_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					musics_list = new ArrayList<Music>();
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("list")) {
						currentMusic = new Music();
						currentMusic.setId(parser.getAttributeValue(null, "id"));
						currentMusic.setChild(parser.getAttributeValue(null, "child"));
						currentMusic.setName(parser.getAttributeValue(null, "name"));
						currentMusic.setDigest(new Integer(parser.getAttributeValue(null, "digest")));
						currentMusic.setImg(parser.getAttributeValue(null, "img"));
						currentMusic.setDesc(parser.getAttributeValue(null, "desc"));
					}
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("list")
							&& currentMusic != null) {
						musics_list.add(currentMusic);
						currentMusic = null;
					}
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			return musics_list;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	//<music rid="700789" name="深情相拥" artist="张国荣&amp;辛晓琪" album="爱浪.恋歌1" duration="216" format="wma" hot="3" 
	//res="http://kkk.7song.cn/w070318/0/20051010/165833/233552513.wma" img=""/>
	
	private List<Music> readSubListXML(InputStream inStream) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			Music currentMusic = null;
			List<Music> musics_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					musics_list = new ArrayList<Music>();
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("music")) {
						currentMusic = new Music();
						currentMusic.setId(parser.getAttributeValue(0));
						currentMusic.setName(parser.getAttributeValue(1));
						currentMusic.setArtist(parser.getAttributeValue(2));
						currentMusic.setAlbum(parser.getAttributeValue(3));
						currentMusic.setDuration(new Long(parser.getAttributeValue(4)));
						currentMusic.setFormat(parser.getAttributeValue(5));
						currentMusic.setHot(new Integer(parser.getAttributeValue(6)));
						currentMusic.setRes(parser.getAttributeValue(7));
					}
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("music")
							&& currentMusic != null) {
						musics_list.add(currentMusic);
						currentMusic = null;
					}
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			return musics_list;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
//	<artist id="1647" name="龙梅子" img="http://img1.kuwo.cn/star/starheads/55/85/1/2031090755.jpg" num="31"/>
	private List<Music> readSubListXML2(InputStream inStream) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			Music currentMusic = null;
			List<Music> musics_list = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					musics_list = new ArrayList<Music>();
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("artist")) {
						currentMusic = new Music();
						currentMusic.setId(parser.getAttributeValue(0));
						currentMusic.setName(parser.getAttributeValue(1));
						currentMusic.setImg(parser.getAttributeValue(2));
						currentMusic.setNum(new Integer(parser.getAttributeValue(3)));
					}
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					if (parser.getName().equalsIgnoreCase("artist")
							&& currentMusic != null) {
						musics_list.add(currentMusic);
						currentMusic = null;
					}
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			return musics_list;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
	
	private List<HashMap<String, String>> getSearchTipsList(String content) throws IOException {
		String dataString = CacheManager.loadString("getSearchTips"+content);
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		return splitSearchTipsParams(dataString);
	}
	
	private boolean checkSearchTipsList(String content) {
		return CacheManager.checkCache("getSearchTips"+content, TimeUtils.HOUR*3);
	}
	
	public List<HashMap<String, String>> getSearchTips(String content) throws IOException {
		
		List<HashMap<String, String>> result = null;
		if(checkSearchTipsList(content)){
			result = getSearchTipsList(content);
		}
		if(result != null){
			return result;
		}
		MusicListService service = new MusicListService();
		String dataString = null;
	
		dataString = service.getSearchTips(content);
		
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		result = splitSearchTipsParams(dataString);
		if(result != null){
			CacheManager.cacheString("getSearchTips"+content, dataString);
		}
		return result;
	}
	
	private SearchResult getSearchResultList(String content, int pagenum, int size) throws IOException {
		String dataString = CacheManager.loadString("getSearch"+content+pagenum+"a"+size);
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		return splitSearchParams(dataString);
	}
	
	private boolean checkSearchResultList(String content, int pagenum, int size) {
		return CacheManager.checkCache("getSearch"+content+pagenum+"a"+size, TimeUtils.HOUR*3);
	}
	
	public SearchResult getSearchResult(String content, int pagenum, int size) throws IOException {
		SearchResult result = null;
		if(checkSearchResultList(content,pagenum,size)){
			result = getSearchResultList(content, pagenum, size);
		}
		if(result != null){
			return result;
		}
		
		String dataString = null;
		MusicListService service = new MusicListService();
		
		dataString = service.getSearch(content, pagenum, size);
		
		if(TextUtils.isEmpty(dataString)){
			return null;
		}
		CacheManager.cacheString("getSearch"+content+pagenum+"a"+size, dataString);
		result = splitSearchParams(dataString);
		return result;
	}
	
	
	
	private List<HashMap<String, String>> splitSearchTipsParams(String data) {
		String[] first = data.split("\\r\\n\\r\\n");
		List<HashMap<String, String>> result_list = null;
		result_list = new ArrayList<HashMap<String, String>>();
		if(first[0].contains("HITNUM=0"))
			return null;
		for(int i = 1; i < first.length; i++){
    		if(first[i]!=""){
    			String[] second =first[i].split("\\r\\n");
    			HashMap<String, String> params = new HashMap<String, String>();
    			for(int j =0; j < second.length; j++){
    				String[] third = second[j].split("=");
    				if(third[0]!=""){
        				if(third.length == 1){
        				    params.put(third[0], "");
       				    }else{
       					    params.put(third[0], third[1]);
       				    }
    				}
    			}
    			result_list.add(params);
    			params = null;
    		}
    	}
		KuwoLog.d(TAG, "result_list.size():" + result_list.size() );
		return result_list;
	}
	
	private SearchResult splitSearchParams(String data) {
		try {
			HashMap<String, String> params = new HashMap<String, String>();
			String[] first = data.split("\\r\\n\\r\\n");
			Music currentMusic = null;
			SearchResult searchResult = new SearchResult();
			List<Music> musics_list = null;
			musics_list = new ArrayList<Music>();
			String[] headerString = first[0].split("\\r\\n");
			String[] numString = headerString[1].split("=");
			searchResult.resultNum = numString[1];
			for(int i = 1; i < first.length; i++){
	    		if(first[i]!=""){
	    			String[] second =first[i].split("\\r\\n");
	    			currentMusic = new Music();
	    			for(int j =0; j < second.length; j++){
	    				String[] third = second[j].split("=");
	    				if(third[0]!=""){
	        				if(third.length == 1){
	        				    params.put(third[0], "");
	       				    }else{
	       					    params.put(third[0], third[1]);
	       				    }
	    				}
	    			}
	    			currentMusic.setName(params.get("SONGNAME"));
	    			currentMusic.setArtist(params.get("ARTIST"));
	    			currentMusic.setAlbum(params.get("ALBUM"));
	    			String musicId = params.get("MUSICRID");
	    			currentMusic.setId(musicId.substring(musicId.indexOf('_')+1));
	    			if(!TextUtils.isEmpty(params.get("DURATION")))
	    			{	
	    				currentMusic.setDuration(new Integer(params.get("DURATION")));
	    			}
	    			currentMusic.setRes(params.get("TAG"));
	    			currentMusic.setFormat(params.get("FORMATS"));
	    			musics_list.add(currentMusic);
	    			currentMusic = null;
	    		}
	    	}
			searchResult.musicList = musics_list;
			return searchResult;
		} catch (Exception e) {
			KuwoLog.printStackTrace(e);
			return null;
			
		}
	}
	
}
