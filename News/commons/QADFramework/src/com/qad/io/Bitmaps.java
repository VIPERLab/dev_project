package com.qad.io;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

import android.annotation.TargetApi;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Shader.TileMode;
import android.graphics.drawable.BitmapDrawable;
import android.media.ThumbnailUtils;
import android.os.Build;
import android.util.Log;

import com.qad.cache.ResourceCacheManager;
import com.qad.lang.Streams;
import com.qad.util.Utils;

public class Bitmaps {

	/**
	 * 将图片缩放至<=requiredSize*requiredSize的大小.
	 * 
	 * @param f
	 * @param requiredSize
	 * @return 若失败则返回null
	 * @throws FileNotFoundException 
	 */
	public static Bitmap decodeFile(File f, int requiredSize) throws FileNotFoundException {
		return decodeFile(f, requiredSize, requiredSize);
	}
	
	/**
	 * 将图片缩放至<=width*height的大小.
	 * 
	 * @param f
	 * @param requiredSize
	 * @return 若失败则返回null
	 * @throws FileNotFoundException 
	 */
	public static Bitmap decodeFile(File f, int width, int height) throws FileNotFoundException {
		if (f.exists()) {
			// decode出图片大小
			BitmapFactory.Options tempOptions = null;
			tempOptions = getBitmapBounds(Streams.fileIn(f));

			// 计算需要缩放的倍数,用2的倍数尝试
			int width_tmp = tempOptions.outWidth, height_tmp = tempOptions.outHeight;// 自动识别缩放大小,以达到期望的大小
			if (10 > width_tmp || 10 > height_tmp) {
				// 过滤掉小于10像素的图
				return null;
			}
//			float scale = 1;
//			while (true) {
//				if (width_tmp / 1.2 < requiredSize
//						&& height_tmp / 1.2 < requiredSize)
//					break;
//				width_tmp /= 1.2;
//				height_tmp /= 1.2;
//				scale *= 1.2;
//			}
			
			// Calculate inSampleSize
			tempOptions.inSampleSize = calculateInSampleSize(tempOptions, width, height);
			
			// 使用缩略图decode
//			BitmapFactory.Options scaleOptions = new BitmapFactory.Options();
//			int tempScale = (int)Math.ceil(scale);
//			Log.e("Sdebug-mm", "inSampleSize is: " + tempOptions.inSampleSize);
//			tempOptions.inSampleSize = (int)Math.ceil(scale);
//			tempOptions.inPurgeable = true;
			tempOptions.inJustDecodeBounds = false;
			
			if (Utils.hasHoneycomb()) {
				addInBitmapOptions(tempOptions);
			}
			
			InputStream is = Streams.fileIn(f);
			Bitmap res = BitmapFactory.decodeStream(is, null,
					tempOptions);
			try {
				is.close();
			} catch (IOException e) {
				Log.w("Sdebug", "IOException occurs while closing input stream", e);
				// just ignore this exception
			}
			return res;
		}
		return null;
	}

	/**
	 * 返回的options可以读取其outerWidth和outerHeight来获取图片尺寸
	 * 
	 * @param is
	 * @return
	 */
	public static BitmapFactory.Options getBitmapBounds(InputStream is) {
		BitmapFactory.Options tempOptions = new BitmapFactory.Options();// 首先预测一下图片文件的尺寸
		tempOptions.inJustDecodeBounds = true;// 设置了该属性后不真正的decode,只是计算外围尺寸
		BitmapFactory.decodeStream(is, null, tempOptions);
		try {
			is.close();
		} catch (IOException e) {
			Log.w("Sdebug", "IOException occurs while closing input stream", e);
			// just ignore this exception
		}
		return tempOptions;
	}
	
	/**
     * Calculate an inSampleSize for use in a {@link BitmapFactory.Options} object when decoding
     * bitmaps using the decode* methods from {@link BitmapFactory}. This implementation calculates
     * the closest inSampleSize that is a power of 2 and will result in the final decoded bitmap
     * having a width and height equal to or larger than the requested width and height.
     *
     * @param options An options object with out* params already populated (run through a decode*
     *            method with inJustDecodeBounds==true
     * @param reqWidth The requested width of the resulting bitmap
     * @param reqHeight The requested height of the resulting bitmap
     * @return The value to be used for inSampleSize
     */
    public static int calculateInSampleSize(BitmapFactory.Options options,
            int reqWidth, int reqHeight) {
        // Raw height and width of image
        final int height = options.outHeight;
        final int width = options.outWidth;
        int inSampleSize = 1;

        if (height > reqHeight || width > reqWidth) {

            final int halfHeight = height / 2;
            final int halfWidth = width / 2;

            // Calculate the largest inSampleSize value that is a power of 2 and keeps both
            // height and width larger than the requested height and width.
            while ((halfHeight / inSampleSize) > reqHeight
                    && (halfWidth / inSampleSize) > reqWidth) {
                inSampleSize *= 2;
            }

            // This offers some additional logic in case the image has a strange
            // aspect ratio. For example, a panorama may have a much larger
            // width than height. In these cases the total pixels might still
            // end up being too large to fit comfortably in memory, so we should
            // be more aggressive with sample down the image (=larger inSampleSize).

            long totalPixels = width * height / inSampleSize;

            // Anything more than 2x the requested pixels we'll sample down further
            final long totalReqPixelsCap = reqWidth * reqHeight * 2;

            while (totalPixels > totalReqPixelsCap) {
                inSampleSize *= 2;
                totalPixels /= 2;
            }
        }
        return inSampleSize;
    }
    
    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
	private static void addInBitmapOptions(BitmapFactory.Options options) {
        // inBitmap only works with mutable bitmaps so force the decoder to
        // return mutable bitmaps.
        options.inMutable = true;

        // Try and find a bitmap to use for inBitmap
        Bitmap inBitmap = ResourceCacheManager.getInstance().getBitmapFromReusableSet(options);

        if (inBitmap != null) {
        	options.inBitmap = inBitmap;
        }
    }

	/**
	 * 默认使用70*70的尺寸
	 * 
	 * @param f
	 * @return
	 * @throws FileNotFoundException 
	 */
	public static Bitmap decodeFile(File f) throws FileNotFoundException {
		return decodeFile(f, 100);
	}

	/**
	 * 获取图片占用字节的大小
	 * 
	 * @param value
	 * @return
	 */
	public static int getBytesSize(Bitmap value) {
		if (value != null && value.getConfig() != null) {
			int perPixel = 0;
			switch (value.getConfig()) {
			case ALPHA_8:
				perPixel = 1;
				break;
			case ARGB_4444:
			case RGB_565:
				perPixel = 2;
				break;
			case ARGB_8888:
			default:
				perPixel = 4;
				break;
			}
			return value.getWidth() * value.getHeight() * perPixel;
		}
		return 0;
	}
	
	/**
	 * 通过硬编码补足Bitmap xml布局中gravity和TileMode不能共存的缺陷。
	 * @param res
	 * @param originalId
	 * @param scaledHeight
	 * @return
	 */
	public static BitmapDrawable fillHorizontalAndRepeatX(Resources res,int originalId,int scaledHeight)
	{
		Bitmap original=BitmapFactory.decodeResource(res, originalId);
		if(scaledHeight==0 || original.getHeight()==scaledHeight) {
			BitmapDrawable drawable= new BitmapDrawable(original);
			drawable.setTileModeX(TileMode.REPEAT);return drawable;
		}
		Bitmap scaled=Bitmap.createScaledBitmap(original, original.getWidth(),scaledHeight,true);
		//release original
		original.recycle();
		original=null;
		BitmapDrawable drawable=new BitmapDrawable(scaled);
		drawable.setTileModeX(TileMode.REPEAT);
		return drawable;
	}
	
	/**
	 * 压缩原图像为指定大小的缩略图。
	 * @param source
	 * @param width
	 * @param height
	 * @return
	 */
	public static Bitmap extractThumbnail(Bitmap source,int width,int height)
	{
		return ThumbnailUtils.extractThumbnail(source, width, height);
	}
}
