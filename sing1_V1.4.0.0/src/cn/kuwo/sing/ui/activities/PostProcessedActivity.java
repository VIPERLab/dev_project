package cn.kuwo.sing.ui.activities;

import java.io.File;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.view.KeyEvent;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.PostProcessedController;
import cn.kuwo.sing.controller.ReviewController;
import cn.kuwo.sing.db.KgeDao;
import cn.kuwo.sing.util.BitmapTools;

/**
 * 后期处理页面
 */
public class PostProcessedActivity extends BaseActivity {

	private final String TAG = "PostProcessedActivity";
	private PostProcessedController ctlPostProcessed;
	private ReviewController ctlReview;
	private SaveFinishedBroadcastReceiver saveFinishedReceiver;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.post_processed_activity);
		ctlPostProcessed = new PostProcessedController(this);
		ctlReview = new ReviewController(this);
		saveFinishedReceiver = new SaveFinishedBroadcastReceiver();
		IntentFilter saveFinishedFilter = new IntentFilter();
		saveFinishedFilter.addAction("cn.kuwo.sing.save.change");
		registerReceiver(saveFinishedReceiver, saveFinishedFilter);
		KuwoLog.i(TAG, "onCreate");
	}
	
	private class SaveFinishedBroadcastReceiver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			if("cn.kuwo.sing.save.change".equals(action)) {
				ctlReview.setSaveFinishedState();
			}
			
		}
		
	}
	
	@Override
	protected void onDestroy() {
		unregisterReceiver(saveFinishedReceiver);
		super.onDestroy();
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {

		switch (requestCode) {
		case Constants.REVIEW_UPLOAD_REQUEST:
			if(resultCode == Constants.RESULT_UPLOAD_SUCCESS) {
				KuwoLog.i(TAG, "上传成功了，，^_^");
//				ctlReview.setPost(true);
			}
			break;
		case PostProcessedController.CAPTURE_REQUESTCODE:	// 拍照回调
//			if(data != null) {
//				if (data.getExtras() != null) {
//					Bitmap bitmap = (Bitmap) data.getExtras().get("data");
//					ctlPostProcessed.addCapturePicture(bitmap);
//				} else {
//					Uri uri = data.getData();
//					if(uri != null) {
//						ctlPostProcessed.addMediaPicture(uri);
//					}
//				}
			if (resultCode == Activity.RESULT_OK) {
				File temp = ctlPostProcessed.mPhoto;  
				startPhotoZoom(Uri.fromFile(temp));  
			}
			break;
		case PostProcessedController.MEDIA_REQUESTCODE:		// 本地选取回调
			if (resultCode == Activity.RESULT_OK && null != data) {
				Uri uri = data.getData();
				startPhotoZoom(uri); 
			}
			break;
		case 3000:
			if (data != null) {
				Bundle extras = data.getExtras();  
				if (extras != null) {  
					Bitmap photo = extras.getParcelable("data");  
					if (photo == null) {
						String filePath = extras.getString("filePath");
						photo = BitmapTools.readBitmapAutoSize(filePath, 320, 320);
					}
					
					ctlPostProcessed.addCapturePicture(photo);
				} 
			}
			break;
		}
		
		super.onActivityResult(requestCode, resultCode, data);
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {

			if (ctlPostProcessed.imgSetDialogShowed) {
				ctlPostProcessed.dimissImgSetDialog();
			} else {
				ctlReview.close();
				KgeDao kgeDao = new KgeDao(this);
				if(kgeDao.getKge(ctlReview.saveDate) == null) {
					ctlReview.popSureExit();
				}else {
					finish();
				}
				
			}
			return true;
		}
		return false;
	}
	
    /**  
     * 裁剪图片
     * @param uri  
     */ 
    public void startPhotoZoom(Uri uri) {
        Intent intent = new Intent("com.android.camera.action.CROP");  
        intent.setDataAndType(uri, "image/*");  
        // 置显示的VIEW可裁剪  
        intent.putExtra("crop", "true");  
        // 宽高的比例  
        intent.putExtra("aspectX", 1);  
        intent.putExtra("aspectY", 1);  
        // 裁剪图片宽高  
        intent.putExtra("outputX", 256);  
        intent.putExtra("outputY", 256);  
        intent.putExtra("return-data", true);  
        startActivityForResult(intent, 3000);  
    }  
}
