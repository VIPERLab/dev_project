package cn.kuwo.sing.logic;

import java.io.File;

import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.utils.ZipUtils;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.context.DirContext;

public class FileLogic {

	public FileLogic() {
	}

	public String getMusicFile(String musicId) {
		if (musicId == null)
			return null;
		return DirectoryManager.getFilePath(DirContext.MUSIC, musicId + Constants.MUSIC_FORMAT);
	}
	public String getMusicTempFile(String musicId) {
		if (musicId == null)
			return null;
		return DirectoryManager.getFilePath(DirContext.MUSIC, musicId + Constants.MUSIC_FORMAT + ".tmp");
	}
	public String getAccompanimentFile(String musicId) {
		if (musicId == null)
			return null;
		return DirectoryManager.getFilePath(DirContext.ACCOMPANIMENT, musicId + Constants.MUSIC_FORMAT);
	}
	public String getAccompanimentTempFile(String musicId) {
		if (musicId == null)
			return null;
		return DirectoryManager.getFilePath(DirContext.ACCOMPANIMENT, musicId + Constants.MUSIC_FORMAT + ".tmp");
	}
	
	public long getRawFileLength() {
		return DirectoryManager.getFile(DirContext.RECORD, "record.raw").length();
	}
	
	
	/**
	 * 获取录音文件
	 * @param rid
	 * @return
	 */
	public File getRecordFile() {
		return DirectoryManager.getFile(DirContext.RECORD, "record.raw");
	}
	
	public String getKgeFile(Kge kge) {
		String name = String.format("%s_%d.aac", kge.id==null?"":kge.id, kge.date);
		return DirectoryManager.getFilePath(DirContext.RECORD, name);
	}
	
	public String getKgePictureDir(Kge kge) {
		String name = String.format("%s_%d", kge.id==null?"":kge.id, kge.date) + File.separatorChar;
		return DirectoryManager.getFilePath(DirContext.MY_PICTURE, name); 
	}
	
	public String getLastKgePictureDir() {
		String lastPictureDir = "lastPictures";
		return DirectoryManager.getFilePath(DirContext.MY_PICTURE, lastPictureDir);
	}
	
	public String getSquareActivityPictureDir(String squareActivityName) {
		return DirectoryManager.getFilePath(DirContext.MY_PICTURE, squareActivityName);
	}
}
