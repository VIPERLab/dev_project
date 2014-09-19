package cn.kuwo.sing.logic;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.List;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import android.content.Context;
import android.graphics.Bitmap;
import android.text.TextUtils;
import android.util.Xml;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.bean.ASLResult;
import cn.kuwo.sing.bean.Comment;
import cn.kuwo.sing.bean.CommentInfo;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.db.MusicDao;
import cn.kuwo.sing.logic.service.MusicService;

public class MusicLogic {
	private final static String TAG = "MusicLogic";
	
	/**
	 * 获取伴唱文件
	 * @param rid
	 * @return 如果不存在返回null
	 */
	
	// TODO 移到DownloadLogic
	public File getAccompanyFile(String rid) {
//		String[] a={".aac",".mp3"};
//		for(int i = 0; i< a.length; i++){
//			String fileName = rid + a[i];
//			String path = DirectoryManager.getFilePath(DirContext.ACCOMPANIMENT, fileName);
//			File file = new File(path); 
//			if(file.exists()){
//				return file;
//			}
//		}
//		return null;
		
		File file = DirectoryManager.getFile(DirContext.ACCOMPANIMENT, rid+Constants.ACCOMPANIMENT_FORMAT);
		if(file.exists()) {
			return file;
		}
		return null;
	}
	
	/**
	 * 获取原唱文件
	 * @param rid
	 * @return
	 */
	public File getOriginalFile(String rid) {
		File file = DirectoryManager.getFile(DirContext.MUSIC, rid+ Constants.MUSIC_FORMAT);
		if(file.exists()) {
			return file;
		}
		return null;
	}
	
	/**
	 * 获取原唱链接
	 * @param rid
	 * @return
	 */
	public String getMusicUrl(String rid) {
		
		MusicService sMusic = new MusicService();

		ASLResult result = null;
		if (Constants.ACCOMPANIMENT_FORMAT.equals(".aac"))
			result = sMusic.fetchMusicURL(rid, "48kaac", "aac");
		else 
			result = sMusic.fetchMusicURL(rid, "128kmp3", "mp3");
		if (result == null)
			return null;
		
		return result.url;
	}

	/**
	 * 获取伴奏链接
	 * @param rid
	 * @return
	 */
	public String getAccompanimentUrl(String rid) {
		MusicService sMusic = new MusicService();

		ASLResult result = null;
		if (Constants.ACCOMPANIMENT_FORMAT.equals(".aac"))
			result = sMusic.fetchAccompanimentURL(rid, "48kaac", "aac");
		else 
			result = sMusic.fetchAccompanimentURL(rid, "128kmp3", "mp3");
		
		if (result == null)
			return null;
		
		return result.url;
	}
	
	public void savePictures(List<Bitmap> lists){
		String cacheDir = DirectoryManager.getDirPath(DirContext.MTV_PICTURE);
		
		for(int i = 0; i < lists.size(); i++){
			String filename = cacheDir + File.separator + i +".png";
			File f = new File(filename);
		    FileOutputStream fOut = null;
		    try {
		    	f.createNewFile();
		    	fOut = new FileOutputStream(f);
		    } catch (Exception e) {
		    	KuwoLog.printStackTrace(e);
		    }
		    lists.get(i).compress(Bitmap.CompressFormat.PNG, 100, fOut);//把Bitmap对象解析成流
		    try {
		    	fOut.flush();
		    	fOut.close();
		    } catch (IOException e) {
		    	KuwoLog.printStackTrace(e);
		    }
		}
		
	}
	
	public static Music getMusicFromDao(Context context, String musicId) {
		MusicDao dao = new MusicDao(context);
		return dao.getMusic(musicId);
	}
	
	public CommentInfo getCommentInfo(String kid, String sid, int pageNum) {
		CommentInfo info = null;
		List<Comment> commentList = null;
		Comment comment = null;
		MusicService service = new MusicService();
		String data = service.getCommentInfoString(kid, sid, pageNum);
		if(TextUtils.isEmpty(data)) {
			return null;
		}
		try {
			XmlPullParser parser = Xml.newPullParser();
			InputStream is = new ByteArrayInputStream(data.getBytes());
			parser.setInput(is, "UTF-8");
			for(int eventType = parser.getEventType(); eventType != XmlPullParser.END_DOCUMENT; eventType = parser.next()) {
				switch (eventType) {
				case XmlPullParser.START_DOCUMENT:
					info = new CommentInfo();
					commentList = new ArrayList<Comment>();
					break;
				case XmlPullParser.START_TAG: 
					String startTag = parser.getName();
					if(startTag.equals("total")) {
						info.total = Integer.parseInt(parser.nextText());
					}else if(startTag.equals("current")) {
						info.current = Integer.parseInt(parser.nextText());
					}else if(startTag.equals("pagesize")) {
						info.pagesize = Integer.parseInt(parser.nextText());
					}else if(startTag.equals("comment")) {
						comment = new Comment();
					}else if(startTag.equals("vip")) {
						comment.vip = parser.nextText();
					}else if(startTag.equals("time")) {
						comment.time = parser.nextText();
					}else if(startTag.equals("fid")) {
						comment.fid = parser.nextText();
					}else if(startTag.equals("fname")) {
						comment.fname = URLDecoder.decode(parser.nextText());
					}else if(startTag.equals("fpic")) {
						comment.fpic = parser.nextText();
					}else if(startTag.equals("lid")) {
						comment.lid = parser.nextText();
					}else if(startTag.equals("block")) {
						comment.block = parser.nextText();
					}else if(startTag.equals("content")) {
						comment.content = URLDecoder.decode(parser.nextText(),"utf-8");
					}
					break;
				case XmlPullParser.END_TAG:
					String endTag = parser.getName();
					if(endTag.equals("comment")) {
						commentList.add(comment);
						comment = null;
					}else if(endTag.equals("root")) {
						info.commentList = commentList;
					}
					break;
				default:
					break;
				}
			}
		} catch (XmlPullParserException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return info;
	}
	
	/**
	 * 
	 * @param kid
	 * @param uid
	 * @param sid
	 * @param loginId
	 * @param ssid
	 * @param toUid
	 * @param content
	 * @return
	 * 返回格式：
	{"result":"err","msg":"param err"}
	or
	{"result":"err","msg":"no login"}
	or
	{"result":"ok"}
	or
	{"result":"err","msg":"sys err"}
	 */
	public String sendComment(String kid, String sid, String toUid, String content) {
		
		MusicService service = new MusicService();
		String data = service.sendComment(kid, sid, toUid, content);
		KuwoLog.i(TAG, "data="+data);
		return data;
	}
	
	public static boolean isKgeSaved(String aacFileName) {
		boolean result = false;
		File aacFile = DirectoryManager.getFile(DirContext.RECORD, aacFileName);
		if(aacFile.exists()) {
			result = true;
		}
		return result;
	}
	
}
