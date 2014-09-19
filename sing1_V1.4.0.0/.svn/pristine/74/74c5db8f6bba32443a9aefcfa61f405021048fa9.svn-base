package cn.kuwo.sing.logic;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.FileUtils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.TextUtils;
import android.widget.Toast;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.ZipUtils;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.MTV;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.bean.MySong;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.logic.service.UserService;
import cn.kuwo.sing.util.BitmapTools;
import cn.kuwo.sing.util.ImageUtils;

import com.j256.ormlite.dao.RuntimeExceptionDao;

public class MtvLogic {
	private final static String TAG = "MtvLogic";
	public static final int MEDIA_TYPE_AUDIO = 0;
	public static final int MEDIA_TYPE_VEDIO = 1;
	
	public int getMediaType(String url) {
		int index = url.lastIndexOf(".");
		String ext = url.substring(index+1);
		if (ext.equalsIgnoreCase("mp4"))
			return MEDIA_TYPE_VEDIO;
		else 
			return MEDIA_TYPE_AUDIO;
	}
	
	public void loadMtvPictures(MTV mtv) throws IOException{
		KuwoLog.d(TAG, "loadMtvPictures");
		String str = mtv.zip;
		if(TextUtils.isEmpty(str))
			return ;
		
		String directoryName = mtv.kid ;
		String source =DirectoryManager.getFilePath(DirContext.MTV_PICTURE, directoryName +".zip");
		String mtvPictureDir = DirectoryManager.getDirPath(DirContext.MTV_PICTURE);
		String destination = mtvPictureDir + File.separator + directoryName;
		
		//下载压缩包，解压
		File file = new File(source);
		URL url = new URL(str);
		FileUtils.copyURLToFile(url, file);
		KuwoLog.d(TAG, "copyURLToFile");
		ZipUtils.unzip(source, destination);
		KuwoLog.d(TAG, "loadMtvPictures unzip");
	}
	
	public List<Bitmap> getMtvPictures(String kid){
		
		String mtvPictureDir = DirectoryManager.getDirPath(DirContext.MTV_PICTURE);
		String destination = mtvPictureDir + File.separator + kid;
		File file = new File(destination);
		if (!file.exists()){
			return  null;
		}
		
		File[] childs = file.listFiles();
		List<Bitmap> lists = new ArrayList<Bitmap>(childs.length);
		Bitmap bitmap = null;
		for(int i = 0; i < childs.length; i++){
//			bitmap = BitmapTools.readBitmapAutoSize(childs[i].getAbsolutePath(), Constants.BITMAP_WIDTH, Constants.BITMAP_HEIGHT);
			bitmap = ImageUtils.loadImageFromCache(childs[i].getAbsolutePath(), Constants.BITMAP_WIDTH, Constants.BITMAP_HEIGHT);
			lists.add(bitmap);
		}
		return lists;
	}
	
	/**
	  * 上传录制的作品
	  * @param type=video/audio  作品类型（video/audio:视频/音频)
	  * @param step=1/2 (video只有1，audio=1=传zip图片包；audio=2=传音频文件)
	  * @param title=xxx // 作品标题
	  * @param kid=1111(音频上传传音频时带)// 作品id,只有当音频，上传音频文件是会带上
	  * @param userid=111(user_kuwo_id)
	  * @param rid=11111(资源在库里的唯一id) 作品对应的资源库中伴奏资源的唯一id
	  * @param mediaType=xx（上传的视频类型mp4/aac）
	  * @param artist=xxx(资源对应的歌手)
	  * @param sid=login_session_id
	  * @param haspic=true/false // haspic=true/false//当前上传有无zip图片包（音频）
	  * @param size=xxx(本次上传的对象大小-byte)
	  * @return 
	 * @throws UnsupportedEncodingException 
	  */
	public String videoUploadUrl(String title, String kid, String rid, String artist,  String haspic ,String size) throws UnsupportedEncodingException{
		String userid = null,sid = null;
		if(Config.getPersistence().user != null){
			sid = Config.getPersistence().user.sid;
			userid = Config.getPersistence().user.uid;
		}
		
		title = URLEncoder.encode(title);
		artist = URLEncoder.encode(artist);
		String url = " http://mboxspace.kuwo.cn/ks/mobile/Upload?type=video&step=1";
     	String param = String.format("&title=%s&kid=%s&userid=%s&rid=%s&mediaType=mp4&artist=%s&sid=%s&size=%s",title,kid,userid,rid,artist,sid,haspic,size);
     	return url + param;
     	}
	
	/**
	  * 上传录制的作品的URL链接
	  * @param type=video/audio  作品类型（video/audio:视频/音频)
	  * @param step=1/2 (video只有1，audio=1=传zip图片包；audio=2=传音频文件)
	  * @param title=xxx // 作品标题
	  * @param kid=1111(音频上传传音频时带)// 作品id,只有当音频，上传音频文件是会带上
	  * @param userid=111(user_kuwo_id)
	  * @param rid=11111(资源在库里的唯一id) 作品对应的资源库中伴奏资源的唯一id
	  * @param mediaType=xx（上传的视频类型mp4/aac）
	  * @param artist=xxx(资源对应的歌手)
	  * @param sid=login_session_id
	  * @param haspic=true/false // haspic=true/false//当前上传有无zip图片包（音频）
	  * @param size=xxx(本次上传的对象大小-byte)
	  * @return 
	 * @throws UnsupportedEncodingException 
	  */
	public String audioUploadUrl(String title, String kid, String rid, String artist, String size, String from) throws UnsupportedEncodingException{
		String userid = null,sid = null;
		if(kid == null)
			kid = "";
		if(Config.getPersistence().user != null){
			sid = Config.getPersistence().user.sid;
			userid = Config.getPersistence().user.uid;
		}
		title = URLEncoder.encode(title);
		artist = URLEncoder.encode(artist);
		String url = " http://mboxspace.kuwo.cn/ks/mobile/Upload?type=audio&step=2";
//		String url = " http://60.28.205.41/ks/mobile/Upload?type=audio&step=2";
     	String param = String.format("&title=%s&kid=%s&userid=%s&rid=%s&mediaType=aac&artist=%s&sid=%s&size=%s&from=%s",title,kid,userid,rid,artist,sid,size, from);
		return url + param;
	}
	
	public String zipUploadUrl(String title, String rid, String artist, String size, String from) throws UnsupportedEncodingException{
		String userid = null,sid = null;
		if(Config.getPersistence().user != null){
			sid = Config.getPersistence().user.sid;
			userid = Config.getPersistence().user.uid;
		}
		title = URLEncoder.encode(title);
		artist = URLEncoder.encode(artist);
		String url = "http://mboxspace.kuwo.cn/ks/mobile/Upload?type=audio&step=1";
//		String url = "http://60.28.205.41/ks/mobile/Upload?type=audio&step=1";
		String param = String.format("&title=%s&userid=%s&rid=%s&mediaType=aac&artist=%s&sid=%s&size=%s&from=%s",title,userid,rid,artist,sid,size, from);
		return url + param;
	}
	private RuntimeExceptionDao<Music, Integer> mDao;
	
	public List<Music> getMusics() {
		return mDao.queryForAll();
	}
	
	/**
	 * 保存作品背景
	 * @param bitmaps
	 */
	public boolean savePictures(Kge kge, List<Bitmap> bitmaps, String squareActivityName) {
		if(bitmaps == null) {
			return false;
		}
		FileLogic lFile = new FileLogic();
		String bitmapExt = ".png";
		String pictureDir = null;
		if(squareActivityName == null) {
			pictureDir = lFile.getLastKgePictureDir();
		}else {
			pictureDir = lFile.getSquareActivityPictureDir(squareActivityName);
		}
		File files = new File(pictureDir);
		if(files.exists()) {
			try {
				FileUtils.deleteDirectory(files);
			} catch (IOException e1) {
				e1.printStackTrace();
			}
		}

		files.mkdirs();
		String dir = lFile.getKgePictureDir(kge);
		for (int i=0; i<bitmaps.size(); i++) {
			String path = dir + i + bitmapExt;
			String lastPath = pictureDir + File.separatorChar + i + bitmapExt;
			File file = new File(path);
			File lastFile = new File(lastPath);
			FileOutputStream fos = null;
			FileOutputStream lastFos = null;
			
			new File(dir).mkdirs();
			new File(pictureDir).mkdirs();
			
		    try {
		    	file.createNewFile();
		    	lastFile.createNewFile();
		    	fos = new FileOutputStream(file);
		    	lastFos = new FileOutputStream(lastFile);
		    	bitmaps.get(i).compress(Bitmap.CompressFormat.PNG, 100, fos);//把Bitmap对象解析成流
		    	bitmaps.get(i).compress(Bitmap.CompressFormat.PNG, 100, lastFos);//把Bitmap对象解析成流
		    	fos.flush();
		    	fos.close();
		    	lastFos.flush();
		    	lastFos.close();
		    } catch (IOException e) {
		    	KuwoLog.printStackTrace(e);
		    	return false;
		    }
		}
		try {
			ZipUtils.zipDir(files);
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
		Config.getPersistence().lastMtv = kge;
		Config.savePersistence();
		return true;
	}
	
	/**
	 * 获取上次的作品背景
	 * @return
	 */
	public List<Bitmap> getLastPicture(Music music) {
		FileLogic lFile = new FileLogic();
		String lastPictureDir = lFile.getLastKgePictureDir();
		File file = new File(lastPictureDir);
		if (!file.exists()){
			return  null;
		}
		
		File[] childs = file.listFiles();
		List<Bitmap> lists = new ArrayList<Bitmap>(childs.length);
		for(int i = 0; i < childs.length; i++){
			Bitmap bitmap = BitmapFactory.decodeFile(childs[i].getAbsolutePath());
			lists.add(bitmap);
		}
		return lists;
	}
	
	/**
	 * 删除人个作品
	 */
	public void deleteMtv() {
		
	}
	
	public Music convertMusic(MTV mtv) {
		Music music = new Music();
		music.setId(mtv.rid);
		music.setName(mtv.title);
		music.setArtist(mtv.artist);
		return music;
	}
}
