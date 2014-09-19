package cn.kuwo.sing.bean;

import java.util.List;
import java.util.Random;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageLoadingListener;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.SimpleBitmapDisplayer;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.util.ImageAsyncTask.ImageAsyncTaskCallback;
import cn.kuwo.sing.util.ImageUtils;
import cn.kuwo.sing.widget.KuwoImageView;

public class SongUnit {
	private Activity mActivity;
	private RelativeLayout rl;
	private static final int FILL_TYPE_NORMAL = 67;
	private static final int FILL_TYPE_LEFT = 68;
	private static final int FILL_TYPE_RIGHT = 69;
	private int imageWidth;
	private int imageHeight;
	private ImageLoader mImageLoader;
	private DisplayImageOptions options1;
	private DisplayImageOptions options;
	private KuwoImageView iv1;
	private KuwoImageView iv2;
	private KuwoImageView iv3;
	private KuwoImageView iv4;
	private KuwoImageView iv5;
	private KuwoImageView iv6;
	private String imageUrl1;
	private String imageUrl2;
	private String imageUrl3;
	private String imageUrl4;
	private String imageUrl5;
	private String imageUrl6;
	private int mFlag;
	
	public SongUnit(Activity activity, int i, List<MTV> songUnitList, int flag, ImageLoader imageLoader) {
		mActivity = activity;
		imageWidth = mActivity.getWindowManager().getDefaultDisplay().getWidth()/3;
		imageHeight = mActivity.getWindowManager().getDefaultDisplay().getWidth()/3;
		mImageLoader = imageLoader;
		options1 = new DisplayImageOptions.Builder()
		.showStubImage(R.drawable.image_loading_big)
		.showImageForEmptyUri(R.drawable.image_loading_big)
		.showImageOnFail(R.drawable.image_loading_big)
		.cacheInMemory()
		.cacheOnDisc()
        .imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2) // default
        .bitmapConfig(Bitmap.Config.ARGB_8888) // default
		.displayer(new SimpleBitmapDisplayer())
		.build();
		options = new DisplayImageOptions.Builder()
		.showStubImage(R.drawable.image_loading_small)
		.showImageForEmptyUri(R.drawable.image_loading_small)
		.showImageOnFail(R.drawable.image_loading_small)
		.cacheInMemory()
		.cacheOnDisc()
		.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2) // default
		.bitmapConfig(Bitmap.Config.ARGB_8888) // default
		.displayer(new SimpleBitmapDisplayer())
		.build();
		rl = new RelativeLayout(mActivity);
		mFlag = flag;
		if(flag == Constants.FLAG_NEW_MTV) {
//			fillData(songUnitList);
			fillData(songUnitList, FILL_TYPE_NORMAL, flag);
		}else {
			if(i%2 == 0) {
				fillData(songUnitList, FILL_TYPE_LEFT, flag);
			}else {
				fillData(songUnitList, FILL_TYPE_RIGHT, flag);
			}
		}
	}
	
	private void fillData(List<MTV> songUnitList, int fillType, int flag) {
		int screenWidth = mActivity.getWindowManager().getDefaultDisplay().getWidth();
		int avgScreenWidth = screenWidth/3;
		
//		for(int i = 0; i <= 5; i++) {
//			MTV song = songUnitList.get(i); 
//			String imageUrl = song.userpic;
//			String imagePath = ImageUtils.makeImagePathFromUrl(imageUrl);
//			Bitmap bitmap = ImageUtils.loadImageFromCache(new ImageCallback(), imagePath, imageUrl);
//			KuwoImageView iv = new KuwoImageView(mActivity, song.kid, song.uname, song.title, bitmap);
//			iv.setId(Integer.parseInt(song.kid));
//		}
		
		//=================================position 1===================
			MTV song1 = songUnitList.get(0);
			imageUrl1 = song1.userpic;
//				String imagePath1 = ImageUtils.makeImagePathFromUrl(imageUrl1);
//				Bitmap bitmap1 = ImageUtils.loadImageFromCache(new ImageCallback(), imagePath1, imageUrl1, imageWidth*2, imageHeight*2);
			
			
			//=================================position 2=========================
			MTV song2 = songUnitList.get(1);
			imageUrl2 = song2.userpic;
//				String imagePath2 = ImageUtils.makeImagePathFromUrl(imageUrl2);
//				Bitmap bitmap2 = ImageUtils.loadImageFromCache(new ImageCallback(), imagePath2, imageUrl2, imageWidth, imageHeight);
			
			//=================================position 3=========================
			MTV song3 = songUnitList.get(2);
			imageUrl3 = song3.userpic;
//				String imagePath3 = ImageUtils.makeImagePathFromUrl(imageUrl3);
//				Bitmap bitmap3 = ImageUtils.loadImageFromCache(new ImageCallback(), imagePath3, imageUrl3, imageWidth, imageHeight);
			
			
			//=================================position 4=========================
			MTV song4 = songUnitList.get(3);
			imageUrl4 = song4.userpic;
//				String imagePath4 = ImageUtils.makeImagePathFromUrl(imageUrl4);
//				Bitmap bitmap4 = ImageUtils.loadImageFromCache(new ImageCallback(), imagePath4, imageUrl4, imageWidth, imageHeight);
			
			//=================================position 5=========================
			MTV song5 = songUnitList.get(4);
			imageUrl5 = song5.userpic;
//				String imagePath5 = ImageUtils.makeImagePathFromUrl(imageUrl5);
//				Bitmap bitmap5 = ImageUtils.loadImageFromCache(new ImageCallback(), imagePath5, imageUrl5, imageWidth, imageHeight);
			
			//=================================position 6=========================
			MTV song6 = songUnitList.get(5);
			imageUrl6 = song6.userpic;
//				String imagePath6 = ImageUtils.makeImagePathFromUrl(imageUrl6);
//				Bitmap bitmap6 = ImageUtils.loadImageFromCache(new ImageCallback(), imagePath6, imageUrl6, imageWidth, imageHeight);
		
		iv1 = null;
		iv2 = null;
		iv3 = null;
		iv4 = null;
		iv5 = null;
		iv6 = null;
		RelativeLayout.LayoutParams param1 = null;
		RelativeLayout.LayoutParams param2 = null;
		RelativeLayout.LayoutParams param3 = null;
		RelativeLayout.LayoutParams param4 = null;
		RelativeLayout.LayoutParams param5 = null;
		RelativeLayout.LayoutParams param6 = null;
		if(fillType == FILL_TYPE_NORMAL) {
			iv1 = new KuwoImageView(mActivity, flag, song1.type, song1.url, song1.kid, song1.uname, song1.title, false);
			iv1.setId(Integer.parseInt(song1.kid));
			param1 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param1.addRule(RelativeLayout.ALIGN_PARENT_TOP, RelativeLayout.TRUE);
			param1.addRule(RelativeLayout.ALIGN_PARENT_LEFT, RelativeLayout.TRUE);
			
			iv2 = new KuwoImageView(mActivity, flag,song2.type, song2.url, song2.kid, song2.uname, song2.title, false);
			iv2.setId(Integer.parseInt(song2.kid));
			param2 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param2.addRule(RelativeLayout.ALIGN_PARENT_TOP, RelativeLayout.TRUE);
			param2.addRule(RelativeLayout.RIGHT_OF, iv1.getId());
			
			iv3 = new KuwoImageView(mActivity, flag, song3.type, song3.url, song3.kid, song3.uname, song3.title, false);
			iv3.setId(Integer.parseInt(song3.kid));
			param3 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param3.addRule(RelativeLayout.ALIGN_PARENT_TOP, RelativeLayout.TRUE);
			param3.addRule(RelativeLayout.RIGHT_OF, iv2.getId());
			
			iv4 = new KuwoImageView(mActivity, flag, song4.type, song4.url, song4.kid, song4.uname, song4.title, false);
			iv4.setId(Integer.parseInt(song4.kid));
			param4 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param4.addRule(RelativeLayout.ALIGN_PARENT_LEFT, RelativeLayout.TRUE);
			param4.addRule(RelativeLayout.BELOW, iv1.getId());
			
			iv5 = new KuwoImageView(mActivity, flag, song5.type, song5.url, song5.kid, song5.uname, song5.title, false);
			iv5.setId(Integer.parseInt(song5.kid));
			param5 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param5.addRule(RelativeLayout.BELOW, iv2.getId());
			param5.addRule(RelativeLayout.RIGHT_OF, iv4.getId());
			
			iv6 = new KuwoImageView(mActivity, flag,song6.type, song6.url, song6.kid, song6.uname, song6.title, false);
			iv6.setId(Integer.parseInt(song6.kid));
			param6 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param6.addRule(RelativeLayout.BELOW, iv3.getId());
			param6.addRule(RelativeLayout.RIGHT_OF, iv5.getId());
			
		}else if(fillType == FILL_TYPE_LEFT) {
			iv1 = new KuwoImageView(mActivity, flag,song1.type, song1.url,  song1.kid, song1.uname, song1.title, true);
			iv1.setId(Integer.parseInt(song1.kid));
			param1 = new RelativeLayout.LayoutParams(avgScreenWidth*2, avgScreenWidth*2);
			param1.addRule(RelativeLayout.ALIGN_PARENT_TOP, RelativeLayout.TRUE);
			param1.addRule(RelativeLayout.ALIGN_PARENT_LEFT, RelativeLayout.TRUE);
			
			iv2 = new KuwoImageView(mActivity, flag, song2.type, song2.url, song2.kid, song2.uname, song2.title, false);
			iv2.setId(Integer.parseInt(song2.kid));
			param2 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param2.addRule(RelativeLayout.ALIGN_PARENT_TOP, RelativeLayout.TRUE);
			param2.addRule(RelativeLayout.RIGHT_OF, iv1.getId());
			
			iv3 = new KuwoImageView(mActivity, flag,song3.type, song3.url,  song3.kid, song3.uname, song3.title, false);
			iv3.setId(Integer.parseInt(song3.kid));
			param3 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param3.addRule(RelativeLayout.ALIGN_PARENT_RIGHT, RelativeLayout.TRUE);
			param3.addRule(RelativeLayout.BELOW, iv2.getId());
			
			iv4 = new KuwoImageView(mActivity, flag, song4.type, song4.url, song4.kid, song4.uname, song4.title, false);
			iv4.setId(Integer.parseInt(song4.kid));
			param4 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param4.addRule(RelativeLayout.ALIGN_PARENT_LEFT, RelativeLayout.TRUE);
			param4.addRule(RelativeLayout.BELOW, iv1.getId());
			
			iv5 = new KuwoImageView(mActivity, flag,song5.type, song5.url,  song5.kid, song5.uname, song5.title, false);
			iv5.setId(Integer.parseInt(song5.kid));
			param5 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param5.addRule(RelativeLayout.BELOW, iv1.getId());
			param5.addRule(RelativeLayout.RIGHT_OF, iv4.getId());
			
			iv6 = new KuwoImageView(mActivity, flag,song6.type, song6.url, song6.kid, song6.uname, song6.title, false);
			iv6.setId(Integer.parseInt(song6.kid));
			param6 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param6.addRule(RelativeLayout.RIGHT_OF, iv5.getId());
			param6.addRule(RelativeLayout.BELOW, iv3.getId());
		}else if(fillType == FILL_TYPE_RIGHT) {
			iv2 = new KuwoImageView(mActivity, flag, song2.type, song2.url, song2.kid, song2.uname, song2.title, false);
			iv2.setId(Integer.parseInt(song2.kid));
			param2 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param2.addRule(RelativeLayout.ALIGN_PARENT_TOP, RelativeLayout.TRUE);
			param2.addRule(RelativeLayout.ALIGN_PARENT_LEFT, RelativeLayout.TRUE);
			
			iv1 = new KuwoImageView(mActivity, flag, song1.type, song1.url, song1.kid, song1.uname, song1.title, true);
			iv1.setId(Integer.parseInt(song1.kid));
			param1 = new RelativeLayout.LayoutParams(avgScreenWidth*2, avgScreenWidth*2);
			param1.addRule(RelativeLayout.ALIGN_PARENT_TOP, RelativeLayout.TRUE);
			param1.addRule(RelativeLayout.RIGHT_OF, iv2.getId());
			
			iv3 = new KuwoImageView(mActivity, flag, song3.type, song3.url,  song3.kid, song3.uname, song3.title, false);
			iv3.setId(Integer.parseInt(song3.kid));
			param3 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param3.addRule(RelativeLayout.ALIGN_PARENT_LEFT, RelativeLayout.TRUE);
			param3.addRule(RelativeLayout.BELOW, iv2.getId());
			
			iv4 = new KuwoImageView(mActivity, flag,song4.type, song4.url,  song4.kid, song4.uname, song4.title, false);
			iv4.setId(Integer.parseInt(song4.kid));
			param4 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param4.addRule(RelativeLayout.ALIGN_PARENT_LEFT, RelativeLayout.TRUE);
			param4.addRule(RelativeLayout.BELOW, iv3.getId());
			
			iv5 = new KuwoImageView(mActivity, flag, song5.type, song5.url, song5.kid, song5.uname, song5.title, false);
			iv5.setId(Integer.parseInt(song5.kid));
			param5 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param5.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE);
			param5.addRule(RelativeLayout.RIGHT_OF, iv4.getId());
			
			iv6 = new KuwoImageView(mActivity, flag, song6.type, song6.url, song6.kid, song6.uname, song6.title, false);
			iv6.setId(Integer.parseInt(song6.kid));
			param6 = new RelativeLayout.LayoutParams(avgScreenWidth, avgScreenWidth);
			param6.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE);
			param6.addRule(RelativeLayout.RIGHT_OF, iv5.getId());
		}

		rl.addView(iv1, param1);
		rl.addView(iv2, param2);
		rl.addView(iv3, param3);
		rl.addView(iv4, param4);
		rl.addView(iv5, param5);
		rl.addView(iv6, param6);
	}
	
	public void displayImage(ImageLoadingListener listener) {
		if(mFlag == Constants.FLAG_NEW_MTV) {
			mImageLoader.displayImage(imageUrl1, iv1.iv, options, listener);
		}else {
			mImageLoader.displayImage(imageUrl1, iv1.iv, options1, listener);
		}
		mImageLoader.displayImage(imageUrl2, iv2.iv, options, listener);
		mImageLoader.displayImage(imageUrl3, iv3.iv, options, listener);
		mImageLoader.displayImage(imageUrl4, iv4.iv, options, listener);
		mImageLoader.displayImage(imageUrl5, iv5.iv, options, listener);
		mImageLoader.displayImage(imageUrl6, iv6.iv, options, listener);
	}
	
	public View getView() {
		rl.setBackgroundColor(Color.WHITE);
		return rl;
	}
}
