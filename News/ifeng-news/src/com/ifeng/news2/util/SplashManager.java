package com.ifeng.news2.util;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.TextUtils;

import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.ItemCover;
import com.ifeng.news2.bean.Lifecycle;
import com.ifeng.news2.bean.SplashCoverUnits;
import com.ifeng.news2.bean.SplashSeenImgIds;
import com.ifeng.news2.bean.StoryMessage;
import com.qad.lang.Files;

/** 
* @ClassName: SplashManager 
* @Description: 管理封面故事 
* @author liu_xiaoliang@ifeng.com 
* @date 2013-3-13 上午9:24:56  
*/ 
public class SplashManager {

	private boolean tryAgain = true;
	public final static String DATA_FILE_NAME = "splash.dat";
	public final static String DATA_SEEN_IMG_NAME = "splash_id.dat";
	public final static File FILE_PATH =  IfengNewsApp.getBeanLoader().getSettings().getBaseBackupDir();
	
	public void saveUnits(SplashCoverUnits units) {
		try {
			Files.serializeObject(new File(FILE_PATH, DATA_FILE_NAME), units);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void downloadPictures(SplashCoverUnits httpUnits, SplashCoverUnits localUnits) {

		ArrayList<ItemCover> itemCovers = null;
		try {
			itemCovers = httpUnits.get(0).getBody().getItem();
		} catch (Exception e) {
		}
		if (null != itemCovers) {
			int itemCoversLength = itemCovers.size();
//			DownLoadImgTask downloader = new DownLoadImgTask();
			for (int i = 0; i < itemCoversLength; i++) {
				Extension storyExtension = getStoryExtension(itemCovers.get(i));
				if (!verifyUnits(httpUnits, localUnits, i) || null == loadSplashPicture(i+".jpg")) {
					// 这里会抛异常：android.os.NetworkOnMainThreadException，在SplashService中将图片下载放到AsyncTask的doInBackground中
					savePicture(HttpUtil.loadImage(storyExtension.getStoryImage()), i);
//					downloader.setIndex(i);
//					downloader.execute(storyExtension.getStoryImage());
				}
			}
		}
	}

	private boolean verifyUnits(SplashCoverUnits httpUnits, SplashCoverUnits loacalUnits, int item) {
		String httpStoryImage = getSplashUrl(httpUnits, item);
		String localStoryImage = getSplashUrl(loacalUnits, item);
		if (TextUtils.isEmpty(httpStoryImage)) {
			return false;
		}else{
			return httpStoryImage.equals(localStoryImage);
		}
	}	

	private String getSplashUrl(SplashCoverUnits unit, int item){
		try{
			ItemCover itemCover = unit.get(0).getBody().getItem().get(item);
			return getStoryExtension(itemCover).getStoryImage();
		}catch(Exception e){
			return null;
		}
	}

	public void savePicture(byte[] picture, int imgName) {
		Bitmap bitmap = null;
		String imgPath = FILE_PATH+ File.separator + imgName+".jpg";
		BufferedOutputStream bos = null;
		try {
			File fileDir = new File(imgPath);
			if (fileDir.exists())
				fileDir.delete();
			if (null != picture) {
				bos = new BufferedOutputStream(new FileOutputStream(imgPath));
				bitmap = BitmapFactory.decodeByteArray(picture, 0,
						picture.length);
				bitmap.compress(Bitmap.CompressFormat.JPEG, 80, bos);
				bos.flush();
			}
		} catch (Throwable e) {
		} finally {
			try {
				if (null != bos)
					bos.close();
				if (null != bitmap)
					bitmap.recycle();
			} catch (IOException e) {
			}
		}
	}

	/** 
	* @Title: getStoryMessage 
	* @Description: 获取要显示封面故事bean 
	* @param @param units
	* @return StoryMessage    返回值为空使用默认启动页
	* @throws 
	*/
	public StoryMessage getStoryMessage(SplashCoverUnits units){
		ArrayList<ItemCover> itemCovers = null;
		try {
			itemCovers = units.get(0).getBody().getItem();
		} catch (Exception e) {
			return null;
		}
		if (null == itemCovers) 
			return null;
		int count = itemCovers.size();
		ArrayList<StoryMessage> storyMessages = new ArrayList<StoryMessage>();
		for (int i = 0; i < count; i++) {
			ItemCover item = itemCovers.get(i);
			if (null != item) {
				Extension storyExtension = getStoryExtension(item);
				if (null != storyExtension && !TextUtils.isEmpty(storyExtension.getStoryId())) {
					if (!isContains(storyExtension.getStoryId()) && currentValid(storyExtension)) {
						StoryMessage sim = new StoryMessage();
						sim.setItem(item);
						sim.setPosition(i);
						sim.setStoryId(storyExtension.getStoryId());
						sim.setIsShow(storyExtension.getIsShow());
						sim.setPriority(storyExtension.getPriority());
						storyMessages.add(sim);
					}
				}
			}
		}
		
		ArrayList<StoryMessage> simList = sequenceByPriority(storyMessages);
		
		for (StoryMessage storyImgMessage : simList) {
			Bitmap splashBitmap = loadSplashPicture(storyImgMessage.getPosition()+".jpg");
			if (null != splashBitmap) {
				if ("1".equals(storyImgMessage.getIsShow())) {  //1---代表封面故事可以显示
					SplashSeenImgIds splashSeenImgIds = getSeenStoryIds();
					if (null == splashSeenImgIds) {
						splashSeenImgIds = new SplashSeenImgIds();
					}
					splashSeenImgIds.getSplashImgIds().add(storyImgMessage.getStoryId());
					if (0 != storyImgMessage.getPriority())     //0----代表优先级最高
						saveSplashId(splashSeenImgIds);         //保存封面故事ID
					storyImgMessage.setSplashBitmap(splashBitmap);
					return storyImgMessage;
				}
			}
		}

		return getStoryMessageAgain(units);
	}
	
	
	private StoryMessage getStoryMessageAgain(SplashCoverUnits units){
		if (tryAgain) {
			tryAgain = false;
			deleteSplashIds();
			return getStoryMessage(units);
		}
		return null;
	}
	
	private boolean isContains(String id) {
		SplashSeenImgIds ssiis = getSeenStoryIds();
		if (null == ssiis) 
			return false;
		if (TextUtils.isEmpty(id)) 
			return true;
		ArrayList<String> ids = ssiis.getSplashImgIds();
		if (null == ids) 
			return false;
		return ids.contains(id);
	} 
	
	private boolean currentValid(Extension storyExtension) {
		ArrayList<Lifecycle> lifecycles = null;
		if (null == storyExtension) 
			return false;
		lifecycles = storyExtension.getLifecycles();
		if (null == lifecycles) 
			return false;
		long currentTime = System.currentTimeMillis()/1000;
		for (Lifecycle lifecycle : lifecycles) {
			if (currentTime < lifecycle.getEnd() && currentTime > lifecycle.getStart()) 
				return true;
		}

		return false;
	} 

	public Extension getStoryExtension(ItemCover itemCover) {
		if(itemCover == null)
			return null;
		for (Extension extension : itemCover.getExtensions()) {
			if (null != extension && "story".equals(extension.getType())) {
				return extension;
			}
		}
		return null;
	}
	
	private ArrayList<StoryMessage> sequenceByPriority(ArrayList<StoryMessage> storyImgMessages){
		int storyImgMsgcount = storyImgMessages.size();
		StoryMessage storyImgMessage;
		for (int i = 0; i < storyImgMsgcount; i++) {
			for (int j = i; j < storyImgMsgcount; j++) {
				if (storyImgMessages.get(i).getPriority() > storyImgMessages.get(j).getPriority()) {
					storyImgMessage = storyImgMessages.get(i);
					storyImgMessages.set(i, storyImgMessages.get(j));
					storyImgMessages.set(j, storyImgMessage);
				}
			}
		}
		return storyImgMessages;
	}

	private Bitmap loadSplashPicture(String imgName) {
		File imageDir = FILE_PATH;
		File imageFile = new File(imageDir, imgName);
		if (!imageFile.exists())
			return null;
		InputStream is = null;
		try {
			is = new FileInputStream(imageFile);
			return BitmapFactory.decodeStream(is);//保存获取的封面故事
		} catch (Throwable t) {
			return null;
		} finally {
			if (null != is) {
				try {
					is.close();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
	}

	public SplashCoverUnits getSplashUnits() {
		try {
			return (SplashCoverUnits) Files.deserializeObject(new File(FILE_PATH, DATA_FILE_NAME));
		} catch (IOException e) {
			return null;
		}
	}
	
	private void saveSplashId(SplashSeenImgIds ids) {
		try {
			Files.serializeObject(new File(FILE_PATH, DATA_SEEN_IMG_NAME), ids);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private SplashSeenImgIds getSeenStoryIds() {
		try {
			return (SplashSeenImgIds)Files.deserializeObject(new File(FILE_PATH, DATA_SEEN_IMG_NAME));
		} catch (Exception e) {
			return null;
		}
	}
	
	public void deleteSplashIds(){
		String saveDir = FILE_PATH + File.separator + DATA_SEEN_IMG_NAME;
		try {
			File fileDir = new File(saveDir);
			if (fileDir.exists())
				fileDir.delete();
		} catch (Exception e) {
		}
	}
}
