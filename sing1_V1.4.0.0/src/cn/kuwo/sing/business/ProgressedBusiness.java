package cn.kuwo.sing.business;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.util.BitmapTools;
import cn.kuwo.sing.util.ImageUtils;

/**
 * 后期处理业务: 重唱, 回放, 保存, 上传
 */
public class ProgressedBusiness extends BaseBusiness {

	private final String TAG = "ProgressedBusiness";

	private Context mContext;
	

	public ProgressedBusiness(Context context) {

		KuwoLog.v(TAG, "ProgressedBusiness(Context context)");

		this.mContext = context;
	}

	/**
	 * 重唱
	 */
	public void resing() {

	}

	/**
	 * 保存混音后的录音
	 * 
	 * @return 是否保存成功
	 */
	public boolean save() {

		return false;
	}

	/* 是否已经保存 */
	public boolean isSaved = false;

	/**
	 * 上传混音后的录音
	 * 
	 * @return 是否上传成功
	 */
	public boolean post() {

		if (!isSaved) {// 未保存, 先保存再上传

			if (!save()) {// 保存失败
				return false;
			}
		}
		// 上传

		return true;
	}

	/**
	 * 取得持久化的背景图片列表
	 * 
	 * @return
	 */
	public List<Bitmap> getImgs(String squareActivityName) {
		List<Bitmap> bitmapList = new ArrayList<Bitmap>();
		File folder = null;
		if(squareActivityName == null)
			folder = DirectoryManager.getFile(DirContext.MY_PICTURE, "lastPictures");
		else 
			folder = DirectoryManager.getFile(DirContext.MY_PICTURE, squareActivityName);
			
		if(folder.exists()) {
			File[] files = folder.listFiles();
			KuwoLog.i(TAG, "file[] size="+files.length);
			Bitmap bitmap = null;
			for(File file : files) {
//				bitmap = BitmapTools.readBitmapAutoSize(file.getAbsolutePath(), Constants.BITMAP_WIDTH, Constants.BITMAP_HEIGHT);
				bitmap = ImageUtils.loadImageFromCache(file.getAbsolutePath(), Constants.BITMAP_WIDTH, Constants.BITMAP_HEIGHT);
				bitmapList.add(bitmap);
			}
			KuwoLog.i(TAG, "bitmapList size="+bitmapList.size());
		}
		return bitmapList;
	}
}
