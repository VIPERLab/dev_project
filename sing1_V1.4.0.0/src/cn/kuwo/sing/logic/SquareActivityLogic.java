/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.logic;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.FileUtils;

import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.ZipUtils;
import cn.kuwo.sing.bean.MTV;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.util.ImageUtils;

import android.graphics.Bitmap;
import android.text.TextUtils;

/**
 * @Package cn.kuwo.sing.logic
 *
 * @Date 2013-8-29, 下午5:03:49
 *
 * @Author wangming
 *
 */
public class SquareActivityLogic {

	public static List<Bitmap> getSquareActivityPictures(String activityBangId) {
		String activityPictureDir = DirectoryManager.getDirPath(DirContext.SQUARE_ACTIVITY_PICTURE);
		String destination = activityPictureDir + File.separator + activityBangId;
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
	
	public static boolean downloadMtvPictures(String activityBangId) throws IOException{
		if(Config.getPersistence().squareActivityMap != null) {
			String zipUrl = Config.getPersistence().squareActivityMap.get(activityBangId).zip;
			if(TextUtils.isEmpty(zipUrl))
				return false;
			String directoryName = activityBangId ;
			String source =DirectoryManager.getFilePath(DirContext.SQUARE_ACTIVITY_PICTURE, directoryName +".zip");
			String mtvPictureDir = DirectoryManager.getDirPath(DirContext.SQUARE_ACTIVITY_PICTURE);
			String destination = mtvPictureDir + File.separator + directoryName;
			
			//下载压缩包，解压
			File file = new File(source);
			URL url = new URL(zipUrl);
			FileUtils.copyURLToFile(url, file);
			ZipUtils.unzip(source, destination);
		}
		return true;
	}
}
