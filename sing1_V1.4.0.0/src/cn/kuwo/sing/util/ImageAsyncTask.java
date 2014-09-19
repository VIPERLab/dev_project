/**
 * Copyright (c) 2012 Eleven Inc. All Rights Reserved.
 */
package cn.kuwo.sing.util;

import java.io.IOException;

import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.util.Log;
import cn.kuwo.framework.log.KuwoLog;

/**
 * @File ImageAsyncTask.java
 * 
 * @Author wangming1988
 * 
 * @Date Sep 22, 2012, 4:45:58 PM
 * 
 * @Version v0.1
 * 
 * @Description 
 *
 */

public class ImageAsyncTask extends AsyncTask<Object, Integer, Bitmap> {
	private static final String LOG_TAG = "ImageAsyncTask";
	private String mImagePath;
	private ImageAsyncTaskCallback callback;
	
	/******************ImageAsyncTaskCallback, ImageAsyncTask***************************/
	/**
	 * The image callback, should implements the two functions when create the ImageAsyncTask.
	 */
	public interface ImageAsyncTaskCallback {
		/**
		 * when execute the AsyncTask onPreExecute, invoke this function.</br>
		 * you can create a progress dialog to prompt user.
		 */
		public abstract void onPreImageLoad(); 
		
		/**
		 * 	when execute the AsyncTask onPostExecute, invoke this function.
		 * 
		 * @param result 
		 * 			return the doInBackground(String... params) result which fetch from server.
		 */
		public abstract void onPostImageLoad(Bitmap bitmap, String imagePath); 
	}
	
	public ImageAsyncTask(ImageAsyncTaskCallback callback) {
		this.callback = callback;
	}
	
	/**
	 * it is ui thread.
	 */
	@Override
	protected void onPreExecute() {
		callback.onPreImageLoad(); //call back function before image process.
		super.onPreExecute();
		
	}
	
	/**
	 * This is a background thread, is not ui thread.
	 * use HttpURLConnection to get bitmap from server</br>
	 * however,you could get it by HttpClient.
	 * String... params ---input params
	 */
	@Override
	protected Bitmap doInBackground(Object... params) {
		Bitmap bitmap = null;
		try {
			String imagePath = (String) params[0];
			String imageUrl = (String) params[1];
			int imageWidth = (Integer) params[2];
			int imageHeight = (Integer) params[3];
			mImagePath = imagePath;
			bitmap = ImageUtils.getImageByHttpClient(imageUrl, imageWidth, imageHeight);
			if(bitmap == null) {
				return null;
			}
			//save image to SDCard, create cache for image
			ImageUtils.saveImage2SDCard(imagePath, ImageUtils.bitmap2Bytes(bitmap));
		} catch (IOException e) {
			e.printStackTrace();
		}
		return bitmap;
	}
	
	/**
	 * it is ui thread,and use the handler to handle the message(callback), update the user interface.
	 */
	@Override
	protected void onProgressUpdate(Integer... values) {
//		int total = values[0];
//		int max = values[1];
		super.onProgressUpdate(values);
	}

	/**
	 * after background thread get data from server, you should deal with the result.
	 */
	@Override
	protected void onPostExecute(Bitmap result) {
		ImageUtils.putBitmap(mImagePath, result);
		Bitmap bitmap = ImageUtils.getBitmap(mImagePath);
		if(bitmap != null) {
			callback.onPostImageLoad(bitmap, mImagePath); //call back after image process.
		}
		super.onPostExecute(result);
	}
}

