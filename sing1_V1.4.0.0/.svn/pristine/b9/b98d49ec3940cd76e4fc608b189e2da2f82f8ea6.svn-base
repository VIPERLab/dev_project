package cn.kuwo.sing.logic.service;

import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.crypt.Base64Coder;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.network.BaseProvider;
import cn.kuwo.framework.network.HttpUtils;
import cn.kuwo.framework.utils.IOUtils;
import cn.kuwo.sing.bean.ASLResult;
import cn.kuwo.sing.bean.AudioResourceNode.ApplyMode;
import cn.kuwo.sing.bean.AudioResourceNode.ResourceQuality;
import cn.kuwo.sing.bean.CommentInfo;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.LyricResult;
import cn.kuwo.sing.bean.MTV;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.util.lyric.KdtxParser;
import cn.kuwo.sing.util.lyric.LrcParser;
import cn.kuwo.sing.util.lyric.LrcxParser;
import cn.kuwo.sing.util.lyric.Lyric;
import cn.kuwo.sing.util.lyric.LyricParser;
import cn.kuwo.sing.util.lyric.LyricParser.LyricsHeader;
import android.text.TextUtils;
import android.util.Log;
import android.util.MonthDisplayHelper;
import android.util.Xml;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;

import org.apache.http.util.EncodingUtils;
import org.json.JSONException;
import org.json.JSONObject;
import org.xmlpull.v1.XmlPullParser;

import com.umeng.analytics.MobclickAgent;

public class MusicService extends DefaultService {
	private final static String TAG = "MusicService";
	private final String PWD = "yeelion";
	
	private ASLResult analysis(String resultString) {
		KuwoLog.i(TAG, "asl: " + resultString);
		String[] items = resultString.split("\\n|\\r\\n");
		if (items.length < 3) {
			KuwoLog.d(TAG, "get real url failed for lack of fields!");
			setLastError(BaseProvider.FAIL_UNKNOWN);
			return null;
		}
		
		ASLResult urlResult = new ASLResult();
		for (int i = 0; i < items.length; i++) {
            
		    if (items[i].startsWith("format=")) {
		        urlResult.format = items[i].substring("format=".length()).trim();
		    }
		    
		    else if (items[i].startsWith("bitrate=")) {
		        String bitrate = items[i].substring("bitrate=".length()).trim();
		        try {
		            urlResult.bitrate = Integer.parseInt(bitrate);
		        } catch (NumberFormatException e) {
		            KuwoLog.printStackTrace(e);
		            setLastError(BaseProvider.FAIL_UNKNOWN);
		            return null;
		        }
		    }
		    
		    else if (items[i].startsWith("url=")) {
		        urlResult.url = items[i].substring("url=".length()).trim();
		    }
		    
		    else if (items[i].startsWith("sig=")) {
		        urlResult.sig = items[i].substring("sig=".length()).trim();
		    }
		    
		    else {
		        KuwoLog.d(TAG, "get real url failed for field incompatible with protocol!");
		        setLastError(BaseProvider.FAIL_UNKNOWN);
		        return null;
		    }
		    
        }			
		
		if (urlResult.format.length() ==0 || urlResult.bitrate == 0 
		        || urlResult.url.length() == 0 
		        //|| urlResult.mSig.length() == 0
		        ) {
			KuwoLog.d(TAG, "get real url failed for field invalid!");
			setLastError(BaseProvider.FAIL_UNKNOWN);
			return null;
		}
				
		return urlResult;
	}

	@Override
	public void cancel() {
		
	}
	
	/**
	 * 获取歌曲的防盗链地址信息
	 * @param rid 歌曲的服务器ID,（歌曲的rid，不带MUSIC_）
	 * @param br 想要获取的比特率字段	,128kmp3|48kaac|192kmp3|320kmp3（需要的资源类型和码率，大小写不区分）
	 * @param format 歌曲可支持格式, 如"mp3|aac"（客户端支持的音频文件格式，
	 * 							若服务器上存在多种格式的音频资源，则按先后顺序返回第一种）
	 * @return 返回获得的防盗链地址信息, 若返回null,表示返回失败
	 */
	public ASLResult fetchMusicURL(String rid, String br, String format) {
		return fetchAslURL(rid, ResourceQuality.standard, ApplyMode.download, br, format, null, 2);
	}

	/**
	 * 获取歌曲的防盗链地址信息
	 * @param rid 歌曲的服务器ID,（歌曲的rid，不带MUSIC_）
	 * @param type 歌曲的资源类型，可参考{#ResourceType}
	 * @param mode 歌曲的应用模式，可参考{#ApplyMode}
	 * @param br   想要获取的比特率字段  ,128kmp3|48kaac|192kmp3|320kmp3（需要的资源类型和码率，大小写不区分）
	 * @param format  歌曲可支持格式, 如"mp3|aac"（客户端支持的音频文件格式，
     *                          若服务器上存在多种格式的音频资源，则按先后顺序返回第一种）
	 * @param sig 本地已有资源的SIG，可用于断点续传控制
	 * @return 返回获得的防盗链地址信息, 若返回null,表示返回失败
	 */
    public ASLResult fetchMusicURL(String rid, ResourceQuality quality, ApplyMode mode, 
            String br, String format, String sig) {

    	return fetchAslURL(rid, quality, mode, br, format, sig, 2);
    }
    
    public ASLResult fetchAccompanimentURL(String rid, String br, String format) {
		return fetchAslURL(rid, ResourceQuality.standard, ApplyMode.download, br, format, null, 1);
	}
    
    /**
	 * 获取伴唱歌曲的防盗链地址信息
	 * @param rid 歌曲的服务器ID,（歌曲的rid，不带MUSIC_）
	 * @param type 歌曲的资源类型，可参考{#ResourceType}
	 * @param mode 歌曲的应用模式，可参考{#ApplyMode}
	 * @param br   想要获取的比特率字段  ,128kmp3|48kaac|192kmp3|320kmp3（需要的资源类型和码率，大小写不区分）
	 * @param format  歌曲可支持格式, 如"mp3|aac"（客户端支持的音频文件格式，
     *                          若服务器上存在多种格式的音频资源，则按先后顺序返回第一种）
	 * @param sig 本地已有资源的SIG，可用于断点续传控制
	 * @param ktype=1/2 1表示取伴唱防盗链，2表示取原唱防盗链
	 * @return 返回获得的防盗链地址信息, 若返回null,表示返回失败
	 */
    public ASLResult fetchAccompanimentURL(String rid, ResourceQuality quality, ApplyMode mode, 
            String br, String format, String sig) {
    	return fetchAslURL(rid, quality, mode, br, format, sig, 1);
    }


    /**
	 * 获取防盗链地址信息
	 * @param rid 歌曲的服务器ID,（歌曲的rid，不带MUSIC_）
	 * @param type 歌曲的资源类型，可参考{#ResourceType}
	 * @param mode 歌曲的应用模式，可参考{#ApplyMode}
	 * @param br   想要获取的比特率字段  ,128kmp3|48kaac|192kmp3|320kmp3（需要的资源类型和码率，大小写不区分）
	 * @param format  歌曲可支持格式, 如"mp3|aac"（客户端支持的音频文件格式，
     *                          若服务器上存在多种格式的音频资源，则按先后顺序返回第一种）
	 * @param sig 本地已有资源的SIG，可用于断点续传控制
	 * @param ktype=1/2 1表示取伴唱防盗链，2表示取原唱防盗链
	 * @return 返回获得的防盗链地址信息, 若返回null,表示返回失败
	 */
    public ASLResult fetchAslURL(String rid, ResourceQuality quality, ApplyMode mode, 
            String br, String format, String sig, int ktype) {

		KuwoLog.d(TAG, "fetchAccompanimentURL rid: " + rid + ", br: " + br + ", format: " + format
				+ ", sig: " + sig + ", type: " + quality + ", mode: " + mode + ", ktype:" + ktype);
        
		LinkedHashMap<String, String> params = new LinkedHashMap<String, String>();
		params.put("rid", String.valueOf(rid));
		params.put("quality", quality.toString());
		params.put("mode", mode.toString());
        String network = AppContext.getNetworkSensor().getNetworkType();
        if (!TextUtils.isEmpty(network)) {
        	params.put("network", network);
        }
        
        if(format != null) {
        	params.put("format", format);
        }
        
        if (!TextUtils.isEmpty(br)){
            params.put("br", br);
        }
        
        if (!TextUtils.isEmpty(sig)) {
            params.put("sig", sig);
        }
     
        params.put("ktype", String.valueOf(ktype));
        
        CharSequence url = getUrl("convert_url", params );
        Log.e(TAG, "request accomp safe url="+url);
		String data;
		try {
			data = read(url.toString(), "gbk");
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
			return null;
		}
		
		return analysis(data);
    }
    
    /**
	 * 获取歌词
	 * @param songname 歌曲名
     * @param artist 歌手名
     * @param req 请求类型，0:逐行 1：逐字  2：练唱
     * @param rid 网络歌曲ID（不带music_）
	 * @throws IOException 
     * @throws URISyntaxException 
	 */


    public byte[] getLyric(String rid) throws IOException, URISyntaxException {
    	return getLyric(null, null, Lyric.LYRIC_TYPE_KDTX, rid);
    }
    
    public byte[] getLyric(String rid, int lyricType) throws IOException, URISyntaxException {
    	return getLyric(null, null, lyricType, rid);
    }
    
    public byte[] getLyric(String songname, String artist, int req, String rid) throws IOException, URISyntaxException {

    	// 获取数据
    	LinkedHashMap<String, String> params = new LinkedHashMap<String, String>();
		
		if (songname != null) 
			params.put("songname", URLEncoder.encode(songname,"gbk"));
		if (artist != null) 
			params.put("artist", URLEncoder.encode(artist,"gbk"));
		params.put("req", String.valueOf(req));
		params.put("rid", rid);

		CharSequence url = getUrl("lyric", params );
		KuwoLog.i(TAG, "GetLyric: url: " + url);

		byte[] bytes = readBytes(url.toString());
		
		KuwoLog.i(TAG, "GetLyric: bytes lenth: " + bytes.length);
		return bytes;
	}
    
    public LyricResult analyzeLyricResult(InputStream in) throws IOException{

    	LyricResult lyricresult = new LyricResult();
		if(in==null) {
			setLastError(BaseProvider.FAIL_UNKNOWN);
			return null;
		}
		
		// 第一行
		String firstLine = IOUtils.readLine(in).replace("\r\n", "");
		if (TextUtils.isEmpty(firstLine)) {
			setLastError(BaseProvider.FAIL_IO_ERROR);
			return null;
		}
		KuwoLog.d(TAG, "lyrics first line: " + firstLine);
		
		if(firstLine.equals("TP=none")) {
			setLastError(BaseProvider.FAIL_NOT_FOUND);
			lyricresult.TP = "none";
			return lyricresult;
		}
		
		// 第二行
		String secondLine = null;
		if (firstLine.equals("TP=content")) {
			lyricresult.TP = "content";
			secondLine = IOUtils.readLine(in).replace("\r\n", "");
			KuwoLog.d(TAG, "secodeLine: " + secondLine);
		}
		if(secondLine.startsWith("lrcx=")){
			
			IOUtils.readLine(in);//取出空格行

			if(secondLine.endsWith("0")){
				lyricresult.type = 0;
			} else if(secondLine.endsWith("1")){
				lyricresult.type = 1;
			} else if(secondLine.endsWith("2")){
				lyricresult.type = 2;
			} else {
				return null;
			}
			
			byte[] bytes = IOUtils.readLeftBytes(in);
			in.close();
			lyricresult.lyric = bytes;
			return lyricresult;
		}
		setLastError(BaseProvider.FAIL_NOT_FOUND);
		return null;
    }
    
    public Lyric analyzeLyric(byte[] lyricBytes, int lrcx) throws IOException{
    	if (lyricBytes == null || lyricBytes.length == 0)
    		return null;
    	
    	ByteArrayInputStream in = new ByteArrayInputStream(lyricBytes);
    	int zipLength = IOUtils.readInt(in);
		int unzipLength = IOUtils.readInt(in);
	    KuwoLog.d(TAG, String.format("zipLength: %s     unzipLength:%s", zipLength, unzipLength));
					 
		// 解压
		byte[] bytes = IOUtils.readLeftBytes(in);
	    byte[] unzip = unzip(bytes, 0, unzipLength);
		LyricParser parser = null;
		Lyric lyric = null;
					 
		if (lrcx == Lyric.LYRIC_TYPE_LRC) {
			parser = new LrcParser();
		} else if (lrcx == Lyric.LYRIC_TYPE_LRCX) {
			// 解密
			String data = EncodingUtils.getString(unzip, "gbk");
			data = Base64Coder.decodeString(data, "gbk", PWD);
			unzip = EncodingUtils.getBytes(data, "gbk");
						 
			parser = new LrcxParser();
		} else if (lrcx == Lyric.LYRIC_TYPE_KDTX) {
			parser = new KdtxParser();
		}
		LyricsHeader header = parser.parserHeader(unzip);
		try {
			lyric = parser.parserLyrics(header, unzip);
			} catch (IOException e) {
				setLastError(BaseProvider.FAIL_IO_ERROR);
				KuwoLog.printStackTrace(e);
			}
		in.close();
		return lyric;
	}
		
	public Lyric analyzeLrc(byte[] bytes) {
		int start, end;
		
		if(bytes.length == 0) {
			setLastError(BaseProvider.FAIL_UNKNOWN);
			return null;
		}
		
		// 第一行
		end = IOUtils.indexOf(bytes, 0, HttpUtils.CRLF);
		if (end == -1) {
			//如果返回的为TP=none则继续向下走正常逻辑
			if("TP=none".equals(new String(bytes))){
				end = bytes.length;
			}else{
				setLastError(BaseProvider.FAIL_IO_ERROR);
				return null;
			}
		}
		
		String firstLine = new String(bytes, 0, end);
		
		if (TextUtils.isEmpty(firstLine)) {
			setLastError(BaseProvider.FAIL_IO_ERROR);
			return null;
		}
		KuwoLog.d(TAG, "lyrics first line: " + firstLine);
		
		if(firstLine.equals("TP=none")) {
			setLastError(BaseProvider.FAIL_NOT_FOUND);
			return null;
		}
		
		// 第二行
		start = end + HttpUtils.CRLF.length;
		int zipLength = 0, unzipLength = 0;
		if (firstLine.equals("TP=content")) {
			String secondLine = null;
			end = IOUtils.indexOf(bytes, start, HttpUtils.CRLF);
			KuwoLog.d(TAG, "secodeLineEnd: " + end);
			if (end == -1 || end >= bytes.length) {
				secondLine = "";
			}else {
				 secondLine = new String(bytes, start, end - start);
				 KuwoLog.d(TAG, "secodeLine: " + secondLine);
				 
				 if (secondLine.startsWith("lrcx="))  {
					 start = end + HttpUtils.CRLF.length *2;
					 zipLength = IOUtils.readInt(bytes, start);
					 start += 4;
					 unzipLength = IOUtils.readInt(bytes, start);
					 
					 KuwoLog.d(TAG, String.format("zipLength: %s     unzipLength:%s", zipLength, unzipLength));
					 
					 // 解压
					 start += 4;
					 byte[] unzip = unzip(bytes, start, unzipLength);
					 LyricParser parser = null;
					 Lyric lyric = null;
					 
					 if (secondLine.equals("lrcx=0")) {
						 parser = new LrcParser();
					 } else if (secondLine.equals("lrcx=1")) {
						 // 解密
						 String data = EncodingUtils.getString(unzip, "gbk");
						 data = Base64Coder.decodeString(data, "gbk", PWD);
						 unzip = EncodingUtils.getBytes(data, "gbk");
						 
						 parser = new LrcxParser();
					 } else if (secondLine.equals("lrcx=2")) {
						 parser = new KdtxParser();
					 }
					 LyricsHeader header = parser.parserHeader(unzip);
					 try {
						lyric = parser.parserLyrics(header, unzip);
					} catch (IOException e) {
						setLastError(BaseProvider.FAIL_IO_ERROR);
						KuwoLog.printStackTrace(e);
					}
					return lyric;
				 }
			}
		}
		
		setLastError(BaseProvider.FAIL_NOT_FOUND);
		return null;
	}
	
	public String getMtvPlayUrl(String id) {
		String result = null;
		String url = "http://changba.kuwo.cn/kge/mobile/getPlayUrl?id="+id;
		KuwoLog.d(TAG, "getMtvPlayUrl url="+url);
		try {
			String data = read(url, "GBK");
			KuwoLog.d(TAG, "getMtvPalyData data="+data);
			JSONObject jsonObj = new JSONObject(data);
			if("ok".equals(jsonObj.getString("result"))) {
				result = URLDecoder.decode(jsonObj.getString("url"));
				KuwoLog.d(TAG, "getMtvPlayUrl result="+result);
			}
			
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		} catch (JSONException e) {
			KuwoLog.printStackTrace(e);
		}
		return result;
	}
	
	
	public MTV getMtv(String id) throws Exception {
//		http://changba.kuwo.cn/kge/mobile/KgeData?id=3133749
		String url = "http://changba.kuwo.cn/kge/mobile/KgeData?id=" + id;
		KuwoLog.d(TAG, "getmtv url="+url);
		HashMap<String, String> params = new HashMap<String, String>();
		String data = read(url,"GBK");
		KuwoLog.i(TAG, data);
		params = splitParams(data, "\\|\\|");
		MTV mtv = null;
		
		if(params != null){
			if(params.get("result").equals("ok")){
				mtv = new MTV();
				mtv.kid = URLDecoder.decode(params.get("kid"),"utf-8");
				mtv.uid = URLDecoder.decode(params.get("uid"),"utf-8");
				mtv.title = URLDecoder.decode(params.get("title"),"utf-8");
				mtv.url = URLDecoder.decode(params.get("url"),"utf-8");
				mtv.rid = URLDecoder.decode(params.get("rid"),"utf-8");
				mtv.zip = URLDecoder.decode(params.get("zip"),"utf-8");
				mtv.flower = URLDecoder.decode(params.get("flower"),"utf-8");
				mtv.comment = URLDecoder.decode(params.get("comment"),"utf-8");
				mtv.uname = URLDecoder.decode(params.get("uname"),"utf-8");
				mtv.care = URLDecoder.decode(params.get("care"),"utf-8");
				mtv.userpic = URLDecoder.decode(params.get("userpic"),"utf-8");
				mtv.sid = URLDecoder.decode(params.get("sid"),"utf-8");
				mtv.artist =  URLDecoder.decode(params.get("artist"),"utf-8");
//				KuwoLog.d(TAG, mtv.url +"   "+ mtv.title + "   "+ mtv.zip+ "   "+ mtv.flower + "   "+ mtv.comment+"   "+ mtv.care+"   "+ mtv.sid+"   "+ mtv.kid);
			} 
			else if(params.get("result").equals("err")){
				throw new Exception(params.get("msg"));
			}
		}
			
		return mtv;

		
//		result=ok&kid=3133749&title=%E5%A5%97%E9%A9%AC%E6%9D%86
//		&url=http://media.cdn.kuwo.cn/c88b6bf0490ee8e8c689a30c89fe1177/505abf2b/resource/m3/webkge/2012/9/4/1346754294655_83973119.mp4
//		&rid=505795&zip=&flower=0&comment=0&uid=83973119&uname=%E6%88%91%E4%BB%AC%E5%94%B1%E5%94%B1%E5%94%B12&care=0
//		&userpic=http://img1.kwcdn.kuwo.cn:81/star/userhead/19/32/1346745720839_83973119m.jpg&sid=1886664&artist=%E4%B9%8C%E5%85%B0%E6%89%98%E5%A8%85
//		result=err&msg=kge_notexist
	}
	
	public String getCommentInfoString(String kid, String sid, int pageNum ) {
		//http://changba.kuwo.cn/kge/mobile/Cmt?kid=3051343&sid=1849513&page=xx 
		//kid：作品id，sid：作品评论对应的帖子id；page：获取页数（1~n）
		String data = null;
		try {
			String url = String.format("http://changba.kuwo.cn/kge/mobile/Cmt?kid=%s&sid=%s&page=%s", kid, sid, pageNum);
			data = read(url);
			KuwoLog.i(TAG, "getCommentInfoString data="+data);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return data;
	}
	
	public String sendComment(String kid, String sid, String toUid, String content) {
		String ssid = null,loginId = null;
		if(Config.getPersistence().user != null){
			ssid = Config.getPersistence().user.sid;
			loginId = Config.getPersistence().user.uid;
		}
		String data = null;
		content = URLEncoder.encode(content);
		String url = null;
		if(TextUtils.isEmpty(toUid)) {
			url = String.format("http://changba.kuwo.cn/kge/mobile/Cmt?act=post&kid=%s&uid=%s&sid=%s&loginId=%s&ssid=%s&toUid=&content=%s",
					kid, loginId,sid, loginId, ssid, content);
		}else {
			url = String.format("http://changba.kuwo.cn/kge/mobile/Cmt?act=post&kid=%s&uid=%s&sid=%s&loginId=%s&ssid=%s&toUid=%s&content=%s",
					kid, loginId,sid, loginId, ssid, toUid, content);
		}
		KuwoLog.i(TAG, "url="+url);
		try {
			data = read(url);
			KuwoLog.i(TAG, "sendComment data="+data);
		} catch (IOException e) {
			return null;
		}
		if(data == null) {
			return null;
		}
		ByteArrayInputStream stream = new ByteArrayInputStream(data.getBytes());
		return readXML(stream);
	}
	
	public String readXML(InputStream inStream) {

		XmlPullParser parser = Xml.newPullParser();
		try {
			parser.setInput(inStream, "UTF-8");
			int eventType = parser.getEventType();
			String result = null;
			while (eventType != XmlPullParser.END_DOCUMENT) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:// 文档开始事件,可以进行数据初始化处理
					break;
				case XmlPullParser.START_TAG:// 开始元素事件
					String name = parser.getName();
					if (name.equalsIgnoreCase("result")) {
							result = parser.nextText();
						} 
					break;
				case XmlPullParser.END_TAG:// 结束元素事件
					break;
				}
				eventType = parser.next();
			}
			inStream.close();
			KuwoLog.d(TAG, "4  " + result);
			return result;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
}
