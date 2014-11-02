package com.ifeng.news2;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.MenuItem;
import android.webkit.WebView;
import android.widget.ImageView;
import com.ifeng.news2.R.id;
import com.ifeng.news2.activity.AppBaseActivity;
import com.ifeng.news2.activity.CommentsActivity;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.MediaScanner;
import com.ifeng.share.util.NetworkState;
import com.qad.annotation.InjectPreference;
import com.qad.loader.ImageLoader.ImageDisplayer;
import com.qad.system.PhoneManager;
import com.qad.util.MD5;
import java.io.File;
import org.apache.commons.io.FileUtils;

/**
 * 包含一些可以公共使用的功能.子类有DetailPageActivity和SlideActivity
 * 
 * @author 13leaf
 * 
 */
public class FunctionActivity extends AppBaseActivity{

	protected boolean isCollected;
	private SharedPreferences sharedPreferences;
	@InjectPreference(name = "full_screen")
	public boolean enableFullScreen;
	@InjectPreference(name = "move_read")
	public boolean isMoveRead;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		sharedPreferences =  PreferenceManager.getDefaultSharedPreferences(this);
		if (ConstantManager.ACTION_PUSH.equals(getIntent().getAction())) {
			// 浠庢帹閫佸惎鍔ㄥ簲鐢�
			startSource = ConstantManager.IN_FROM_PUSH;
//			PreferenceManager.getDefaultSharedPreferences(this).edit().putLong("entryTime", System.currentTimeMillis()).commit();
			isActive = false; // 为了在onResume时调用onForegroundRunning 发送启动统计in
		} else if (Intent.ACTION_VIEW.equals(getIntent().getAction())) {
			// 浠庢帹閫佸惎鍔ㄥ簲鐢�
			startSource = ConstantManager.IN_FROM_OUTSIDE;
			isActive = false; // 为了在onResume时调用onForegroundRunning 发送启动统计in
		} else if (ConstantManager.ACTION_WIDGET.equals(getIntent().getAction())){
			//来自Widget
			startSource = ConstantManager.IN_FROM_WIDGET;
			isActive = false;
		}
	}

/*	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.function_menu, menu);
		return super.onCreateOptionsMenu(menu);
	}*/

/*	@Override
	public boolean onPrepareOptionsMenu(Menu menu) {
		MenuItem collectItem = menu.findItem(id.collect);
		MenuItem collectedItem = menu.findItem(id.collected);
		MenuItem moveItem = menu.findItem(id.move);
		MenuItem unMoveItem = menu.findItem(id.unmove);
		MenuItem fullItem = menu.findItem(id.full);
		MenuItem unFullItem = menu.findItem(id.unfull);
		FontSize fontSize=getPreferenceFontSize();
		switch (fontSize) {
		case small:
			menu.findItem(id.small).setChecked(true);
			break;
		case mid:
			menu.findItem(id.mid).setChecked(true);
			break;
		case big:
			menu.findItem(id.big).setChecked(true);
		}
		if (isCollected) {
			collectedItem.setVisible(true);
			collectItem.setVisible(false);
		} else {
			collectedItem.setVisible(false);
			collectItem.setVisible(true);
		}
		if(enableFullScreen){
			fullItem.setVisible(false);
			unFullItem.setVisible(true);
		}else{
			unFullItem.setVisible(false);
			fullItem.setVisible(true);
		}
		if(isMoveRead){
			moveItem.setVisible(false);
			unMoveItem.setVisible(true);
		}else{
			unMoveItem.setVisible(false);
			moveItem.setVisible(true);
		}
		return super.onPrepareOptionsMenu(menu);
	}*/
	
	public static enum FontSize {
		biggest {
			@Override
			public FontSize getSmaller() {
				return bigger;
			}

			@Override
			public FontSize getLarger() {
				return null;
			}
			
			public String getName() {
				return "超大号字体";
			}

			@Override
			public boolean isAvailable() {
				return false;
			}
		},bigger {
			@Override
			public FontSize getSmaller() {
				return big;
			}

			@Override
			public FontSize getLarger() {
				return biggest;
			}
			
			public String getName() {
				return "特大号字体";
			}

			@Override
			public boolean isAvailable() {
				return true;
			}
		},big {
			@Override
			public FontSize getSmaller() {
				return mid;
			}

			@Override
			public FontSize getLarger() {
				return bigger;
			}
			
			public String getName() {
				return "大号字体";
			}

			@Override
			public boolean isAvailable() {
				return true;
			}
		}, mid {
			@Override
			public FontSize getSmaller() {
				return small;
			}

			@Override
			public FontSize getLarger() {
				return big;
			}
			
			public String getName() {
				return "中号字体";
			}

			@Override
			public boolean isAvailable() {
				return true;
			}
		}, small {
			@Override
			public FontSize getSmaller() {
				return smaller;
			}

			@Override
			public FontSize getLarger() {
				return mid;
			}
			
			public String getName() {
				return "小号字体";
			}

			@Override
			public boolean isAvailable() {
				return true;
			}
			
		}, smaller {
			@Override
			public FontSize getSmaller() {
				return null;
			}

			@Override
			public FontSize getLarger() {
				return small;
			}
			
			public String getName() {
				return "特小号字体";
			}

			@Override
			public boolean isAvailable() {
				return false;
			}
			
		};
		
		public abstract FontSize getSmaller();
		
		public abstract FontSize getLarger();
		
		public abstract String getName();
		
		public abstract boolean isAvailable();
	}
	public  void initFontSize() {
	}
	public void saveAction(String name,boolean action){
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putBoolean(name, action);
		editor.commit();
	}
	public boolean getAction(String name){
		return sharedPreferences.getBoolean(name, true);
	}
	public FontSize getPreferenceFontSize() {
		String fontSize = sharedPreferences.getString("fontSize", "mid");
		return FontSize.valueOf(fontSize);
	}
	
	/**
	 * 2G/3G无图模式
	 * 条件：
	 * 1,2G/3G网络
	 * 2，开启无图模式开关
	 * 
	 * @return
	 */
	public boolean isSetNoImageModeAnd2G3G() {
		boolean isDownload = getAction("loadImage2");
		if (NetworkState.isActiveNetworkConnected(getApplicationContext())
				&& !NetworkState
						.isWifiNetworkConnected(getApplicationContext())
				&& !isDownload) {
			return true;
		} else {
			return false;
		}
	}

	public void setFont(FontSize size) {
		
	}

	public void setWebFont(WebView webView, FontSize size) {
		
	}
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case id.collect:
			onToggleCollect();
			break;
		case id.collected:
			onToggleCollect();
			break;
		case id.share:
			onShare();
			break;
		case id.comment:
			onComment(true);
			break;
		case id.big:
			setFont(FontSize.big);
			saveFont("big");
			initFontSize();
			break;
		case id.mid:
			setFont(FontSize.mid);
			saveFont("mid");
			initFontSize();
			break;
		case id.small:
			setFont(FontSize.small);
			saveFont("small");
			initFontSize();
			break;
		case id.full:
			fullAction(true);
			break;
		case id.unfull:
			fullAction(false);
			break;
		case id.move:
			moveReadAction(true);
			break;
		case id.unmove:
			moveReadAction(false);
			break;
		}
		return super.onOptionsItemSelected(item);
	}
	public void saveFont(String fontSize){
		Editor editor = sharedPreferences.edit();
		editor.putString("fontSize", fontSize);
		editor.commit();
	}
	/**
	 * 请求收藏/取消收藏。返回true表示处理成功,返回false表示处理失败。<br>
	 * 在此之前应当通过setCollected正确初始化收藏状态
	 * 
	 * @return
	 */
	protected boolean onToggleCollect() {
		// showMessage("onToggleCollect");
		return false;
	}

	/**
	 * 请求收藏
	 */
	protected void onShare() {
		// showMessage("onShare");
	}

	/**
	 * 请求评论
	 */
	protected void onComment(boolean isShowSoftInput) {
	};

	/**
	 * 设置是否收藏
	 * 
	 * @param collected
	 */
	protected void setCollected(boolean collected) {
		isCollected = collected;
	}

	protected boolean isCollected() {
		return isCollected;
	}
	/**
	 * 收藏
	 * @param listItem 
	 */
	public boolean collect(ListItem listItem) {
		return collectionDBManager.insertCollectionItem(listItem);
	}

	public void cancleCollection(String id) {
		collectionDBManager.deteleCollectionById(id);
	}

	public boolean isCollect(String documentId) {
		return false;
	}
	//双击全屏
	public void fullAction(boolean isFull){
		if(isFull){
			showMessage("您已启用双击全屏功能");
		}else{
			showMessage("您已关闭双击全屏功能");
		}
		this.enableFullScreen = isFull;
		saveAction("full_screen",enableFullScreen);
	}
	//滑动翻页
	public void moveReadAction(boolean isMove){
		if(isMove){
			showMessage("您已启用滑动翻页功能");
		}else{
			showMessage("您已关闭滑动翻页功能");
		}
		this.isMoveRead = isMove;
		saveAction("move_read",isMoveRead);
		setIsMoveRead(isMoveRead);
	}
	public void setIsMoveRead(boolean isMove){
		
	}
	/**
	 * 评论
	 * 
	 * @param title
	 * @param wwwUrl
	 * @param documentId
	 * @param isShowSoftInput
	 */

	public boolean comment(String commentsUrl,String commentType, String title, String wwwUrl, String documentId,
			boolean isShowSoftInput,String action) {
		return CommentsActivity.redirect2Comments(this,commentsUrl,commentType, title, wwwUrl, documentId, isShowSoftInput, false,action);
	}
	
	/*public boolean comment(String commentsUrl,String commentType, String title, String wwwUrl, String documentId, String commentsExt,
	                       boolean isShowSoftInput,String action) {
	  return CommentsActivity.redirect2Comments(this,commentsUrl,commentType, title, wwwUrl, documentId, commentsExt, isShowSoftInput ,false,action);
	}*/
	   
	/**
	 * 带有图片和分享链接跳转评论页面 
	 */
	public boolean commentDetail(String commentsUrl,String commentType, String title, String documentId, String commentsExt,
			boolean isShowSoftInput,String imageUrl,String shareUrl,String action) {
		return CommentsActivity.redirectDetailComments(this,commentsUrl,commentType, title, documentId, commentsExt, isShowSoftInput, false,imageUrl,shareUrl,action);
    }
	
	public boolean comment(String commentsUrl,String commentType, String title, String wwwUrl, String documentId,
			boolean isShowSoftInput,String imageUrl,String shareUrl,String position , String action) {
		return CommentsActivity.redirect2Comments(this,commentsUrl,commentType, title, wwwUrl, documentId, isShowSoftInput, false,imageUrl,shareUrl,position,action);
    }
	               
	
	     
	public static String[] defaultShareItems = new String[]{"sina"};
//	public static String[] defaultShareItems = new String[]{"sina","tenqt","fetion","system"};

//	public void share(Context context,String title,String content,String url,ArrayList<String> imageList){
//		if(imageList==null)return;
//		ArrayList<String> filterImages = new ArrayList<String>();
//		for(String image : imageList){
//			filterImages.add(FilterUtil.filterImageUrl(image));
//		}
//		ShareAlertSmall  alert = new ShareAlertSmall(this, new WXHandler(this), url, title, content, imageList);
//		alert.show(this);
//		
//	}
	
	
	@Override
	protected void onPause() {
		super.onPause();
	}
	
	public boolean isNetworkConnected(Context context){
		return NetworkState.isActiveNetworkConnected(context);
	}
	
	protected ProgressDialog loadingDialog;
	public static class NoneImageDisplayer implements ImageDisplayer {
		@Override
		public void prepare(ImageView img) {
		}

		@Override
		public void display(ImageView img, BitmapDrawable bmp) {

		}

        @Override
        public void display(ImageView img, BitmapDrawable bmp, Context ctx) {
            // TODO Auto-generated method stub
            
        }

		@Override
		public void fail(ImageView img) {
			// TODO Auto-generated method stub
			
		}
	}
	
	protected void downLoadImage(String imageUrl){
		if (PhoneManager.getInstance(me).isSDCardAvailiable()){	
			if(imageUrl!=null){
				new DownLoadImgTask().execute(imageUrl);
			}
			else{
				showMessage("下载失败");
			}				
		}else{
			showMessage("对不起,没有检测到SD卡。");
		}				
	}
	
	/**
	 * 下载图片
	 * @author Administrator
	 *
	 */
	private class DownLoadImgTask extends AsyncTask<String, Integer, Boolean> {
		@Override
		protected Boolean doInBackground(String... params) {
			return downloadImg(params[0]);
		}

		@Override
		protected void onPostExecute(Boolean result) {
			if (result == false) {
				showMessage("下载失败");
				super.onPostExecute(result);
			} else {
				showMessage("下载成功，已存入相册");
				super.onPostExecute(result);
			}
		}
		
		// TODO
		private boolean downloadImg(String imgUrl) {
			try {
				String picName = MD5.md5s(imgUrl) + ".jpg";
				File imgFile = new File(Config.FOLDER_DOWNLOAD_PICTURE, picName);		
					if (!imgFile.exists()) {
						File file = IfengNewsApp.getResourceCacheManager()
								.getCacheFile(imgUrl);
						if (file != null) {
							FileUtils.copyFile(file, imgFile);
							MediaScanner scanner = new MediaScanner(getApplicationContext());
							scanner.scanFile(imgFile.getAbsolutePath(), null);
						}
					}
			} catch (Throwable e) {
				e.printStackTrace();
				return false;
			}
			return true;
		}
	}
	
	
	
	protected void showAlertDialog(Activity activity) {
		new AlertDialog.Builder(activity)
				.setMessage(R.string.not_network_message)
				.setPositiveButton("确定",
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog,
									int which) {
								dialog.dismiss();
								if (getIntent() != null
										&& getIntent()
												.getBooleanExtra(
														IntentUtil.EXTRA_REDIRECT_HOME,
														false))
									IntentUtil
											.redirectHome(getApplicationContext());
								finish();
								overridePendingTransition(
										R.anim.in_from_left,
										R.anim.out_to_right);
							}
						}).setOnCancelListener(new OnCancelListener() {

					@Override
					public void onCancel(DialogInterface dialog) {
						dialog.dismiss();
						if (getIntent() != null
								&& getIntent().getBooleanExtra(
										IntentUtil.EXTRA_REDIRECT_HOME,
										false))
							IntentUtil.redirectHome(getApplicationContext());
						finish();
						overridePendingTransition(R.anim.in_from_left,
								R.anim.out_to_right);
					}
				}).create().show();
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
	}
	
}
