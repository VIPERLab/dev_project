package cn.kuwo.sing.controller;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.FileUtils;

import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.HorizontalScrollView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.BitmapUtils;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.business.ProgressedBusiness;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.logic.SquareActivityLogic;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.util.BitmapTools;

/**
 * 后期处理页面控制层
 */
public class PostProcessedController extends BaseController {

	private final String TAG = "PostProcessedController";

	private BaseActivity mActivity;
	private TextView post_processed_score;
	/*击败那一行的显示*/
	private TextView second_line_one_tip;
	private TextView post_processed_beat;
	private TextView second_line_two_tip;
	private LinearLayout processed_background_tip;
	/* 混音按钮 */
	private Button mixSetBtn;
	/* 背景图片资源 */
	public static List<Bitmap> imgList;
	/* 背景设置按钮 */
	private Button imgSetBtn;
	/* 声音设置按钮 */
	private Button volumeBtn;
	/* 背景||混音 || 声音调节 设置区域 */
	private RelativeLayout setRl;
	/* 混音设置区域 */
	private RelativeLayout mixRelative;
	/* 声音调节区域 */
	private RelativeLayout volumeRejust;
	/* 背景设置滚动区域 */
	private HorizontalScrollView imgSetScrollview;
	/* LayoutInflater */
	private LayoutInflater inflater;
	/* 背景设置区域 */
	private LinearLayout bgSetLayout;
	/* 图片预览区域 */
	private ImageView imgPreview;
	/* 后期处理业务 */
	private ProgressedBusiness mProBusiness;
	/* 弹出对话框后灰色背景 */
	private View inclickBg;
	// 添加图片对话框是否已经显示
	public boolean imgSetDialogShowed = false;
	// 混音设置,图片设置区域
	private boolean mixShowed = false, imgShowed = false, volumeShowed = false;
	
	private Music music;
	

	
	private String score;

	private LinearLayout ll_processed_line_tip;
	private String fromSquareActivity;
	
	public PostProcessedController(BaseActivity activity) {

		KuwoLog.i(TAG, "PostProcessedController()");

		mActivity = activity;
		inflater = LayoutInflater.from(mActivity);

		mProBusiness = new ProgressedBusiness(activity);

		initImgList();
		initView();
	}

	/**
	 * 初始化控件
	 * 
	 * @param activity
	 */
	private void initView() {

		inclickBg = mActivity.findViewById(R.id.post_processed_inclick_bg);
		ll_processed_line_tip = (LinearLayout) mActivity.findViewById(R.id.ll_processed_line_tip);
		ll_processed_line_tip.setVisibility(View.INVISIBLE);

		// =====================设置区域=========================
		// 混音||背景设置控制区域
		setRl = (RelativeLayout) mActivity.findViewById(R.id.post_processed_set_rl);
		// 混音设置控制区域
		mixRelative = (RelativeLayout) mActivity.findViewById(R.id.post_processed_mix_rl);
		// 背景设置控制区域
		imgSetScrollview = (HorizontalScrollView) mActivity.findViewById(R.id.post_processed_bg_scrollview);
		//
		volumeRejust = (RelativeLayout) mActivity.findViewById(R.id.post_processed_volume_rejust);
		
		bgSetLayout = (LinearLayout) mActivity.findViewById(R.id.post_processed_bg_linlayout);
		// 背景选择对话框
		addImgDialog = (RelativeLayout) mActivity.findViewById(R.id.post_processed_img_dialog);
		// "拍照"按钮
		Button post_processed_capture_btn = (Button) mActivity.findViewById(R.id.post_processed_capture_btn);
		post_processed_capture_btn.setOnClickListener(mOnClickListener);
		// "本地上传"按钮
		Button post_processed_local_btn = (Button) mActivity.findViewById(R.id.post_processed_local_btn);
		post_processed_local_btn.setOnClickListener(mOnClickListener);
		// "取消"按钮
		Button post_processed_cancle_btn = (Button) mActivity.findViewById(R.id.post_processed_cancle_btn);
		post_processed_cancle_btn.setOnClickListener(mOnClickListener);
		// "混音"按钮
		mixSetBtn = (Button) mActivity.findViewById(R.id.post_processed_mix_btn);
		mixSetBtn.setOnClickListener(mOnClickListener);
		// "背景"按钮
		imgSetBtn = (Button) mActivity.findViewById(R.id.post_processed_bg_btn);
		imgSetBtn.setOnClickListener(mOnClickListener);
		//"声音"按钮
		volumeBtn = (Button) mActivity.findViewById(R.id.post_processed_volume_btn);
		volumeBtn.setOnClickListener(mOnClickListener);
		//分数显示
		post_processed_score = (TextView) mActivity.findViewById(R.id.post_processed_score);
		//击败那一行的显示
		second_line_one_tip = (TextView) mActivity.findViewById(R.id.second_line_one_tip);
		post_processed_beat = (TextView) mActivity.findViewById(R.id.post_processed_beat);
		second_line_two_tip = (TextView) mActivity.findViewById(R.id.second_line_two_tip);
		processed_background_tip = (LinearLayout) mActivity.findViewById(R.id.processed_background_tip);
		music = (Music) mActivity.getIntent().getExtras().getSerializable("music");
//		resetSquare();
		popMixSquare();
		if(music == null){
			processed_background_tip.setVisibility(View.INVISIBLE);
		}else if(AppContext.getNetworkSensor() == null || !AppContext.getNetworkSensor().hasAvailableNetwork()){
			//没有网络
			ll_processed_line_tip.setVisibility(View.VISIBLE);
			second_line_one_tip.setText("音乐路上需要你不断努力");
			post_processed_beat.setText("");
			second_line_two_tip.setText("");
			score =  (String) mActivity.getIntent().getExtras().getSerializable("score");
			post_processed_score.setText(score);
//			post_processed_beat.setVisibility(View.INVISIBLE);
//			second_line_two_tip.setVisibility(View.INVISIBLE);
		}else{
			//有网
			score =  (String) mActivity.getIntent().getExtras().getSerializable("score");
			post_processed_score.setText(score);
			ll_processed_line_tip.setVisibility(View.INVISIBLE);
//			ranking =  (String) mActivity.getIntent().getExtras().getSerializable("ranking");
//			post_processed_beat.setText(ranking);
		}
		// =====================背景图片区域=========================
		// 背景图片
		imgPreview = (ImageView) mActivity.findViewById(R.id.post_processed_img);
		imgPreview.setOnClickListener(mOnClickListener);
		ViewGroup.LayoutParams para;
		para = imgPreview.getLayoutParams();
		para.height = (int)(AppContext.SCREEN_WIDTH*1.2f);
		para.width = AppContext.SCREEN_WIDTH;
		imgPreview.setLayoutParams(para);

		Intent intent = mActivity.getIntent();
		fromSquareActivity = intent.getStringExtra("fromSquareActivity");
		if(fromSquareActivity == null) {
			imgSetBtn.setVisibility(View.VISIBLE);
			// 初始化背景设置滚动区域
			initScrollView();
		}else {
			imgSetBtn.setVisibility(View.INVISIBLE);
			imgList = SquareActivityLogic.getSquareActivityPictures(fromSquareActivity);
			if(imgList != null && imgList.size() > 0)
				imgPreview.setImageBitmap(imgList.get(0));
			else 
				imgPreview.setBackgroundResource(R.drawable.sing_scene_temp);
		}
		if (music != null)
			getRanking();

	}
	
	private Handler rankingHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				KuwoLog.i(TAG, "【获取MTV成功！】");
				ll_processed_line_tip.setVisibility(View.VISIBLE);
				String ranking = (String) msg.obj;
				post_processed_beat.setText(ranking);
				break;
			default:
				break;
			}
		}
		
	};
	private void getRanking() {
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				UserLogic userLogic = new UserLogic();
				Message msg = rankingHandler.obtainMessage();
				msg.what = 0;
				try {
					msg.obj = userLogic.getTotalScore(music.getId(), score+"");
				} catch (IOException e) {
					KuwoLog.printStackTrace(e);
				}
				rankingHandler.sendMessage(msg);
			}
		}).start();
	}
	
	/**
	 * 初始化背景图片资源bgImgList
	 */
	private void initImgList() {
		// TODO @LIKANG
		imgList = mProBusiness.getImgs(fromSquareActivity);
		if (imgList == null) 
			imgList = new ArrayList<Bitmap>();
	}

	/**
	 * 重置图片滚动区域
	 */
	private void initScrollView() {

		if (bgSetLayout.getChildCount() != 0) {
			bgSetLayout.removeAllViews();
		}

		if (imgList != null && imgList.size() < 10) {// 可以继续添加

			// 添加图片按钮
			bgSetLayout.addView(inflater.inflate(R.layout.post_processed_bg_item, null));
			Button set_bg_img_btn = (Button) bgSetLayout.getChildAt(0).findViewById(R.id.set_bg_img_btn);
			set_bg_img_btn.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					if (!imgDialogShowed) {
						popImgSetDialog();
					}
				}
			});
			// 删除按钮不可见
			Button deleteBtn = (Button) bgSetLayout.getChildAt(0).findViewById(R.id.set_bg_delete_btn);
			deleteBtn.setVisibility(View.GONE);

			for (int i = 0; i < imgList.size(); i++) {

				bgSetLayout.addView(inflater.inflate(R.layout.post_processed_bg_item, null));
				// 放置图片
				ImageView set_bg_img = (ImageView) bgSetLayout.getChildAt(i + 1).findViewById(R.id.set_bg_img);
				set_bg_img.setVisibility(View.VISIBLE);
				set_bg_img.setBackgroundDrawable(new BitmapDrawable(reSizeBmp(imgList.get(i))));

				bgSetLayout.getChildAt(i + 1).findViewById(R.id.set_bg_img_transp).setVisibility(View.VISIBLE);
			}
			if (imgList.size() != 0) {
				imgPreview.setImageBitmap(imgList.get(0));
			}

		} else if (imgList != null && imgList.size() == 10) {// 不可以继续添加

			for (int i = 0; i < imgList.size(); i++) {

				bgSetLayout.addView(inflater.inflate(R.layout.post_processed_bg_item, null));
				// 放置图片
				ImageView set_bg_img = (ImageView) bgSetLayout.getChildAt(i).findViewById(R.id.set_bg_img);
				set_bg_img.setVisibility(View.VISIBLE);
				set_bg_img.setBackgroundDrawable(new BitmapDrawable(reSizeBmp(imgList.get(i))));

				bgSetLayout.getChildAt(i).findViewById(R.id.set_bg_img_transp).setVisibility(View.VISIBLE);
			}
			imgPreview.setImageBitmap(imgList.get(0));
		} else {
			// 添加图片按钮
			bgSetLayout.addView(inflater.inflate(R.layout.post_processed_bg_item, null));
			Button set_bg_img_btn = (Button) bgSetLayout.getChildAt(0).findViewById(R.id.set_bg_img_btn);
			set_bg_img_btn.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					if (!imgDialogShowed) {
						popImgSetDialog();
					}
				}
			});

			// 删除按钮不可见
			Button deleteBtn = (Button) bgSetLayout.getChildAt(0).findViewById(R.id.set_bg_delete_btn);
			deleteBtn.setVisibility(View.GONE);
		}

		resetDeleteBtn();
		resetImgClick();

		for (int i = 0; i < bgSetLayout.getChildCount(); i++) {

			if (i == bgSetLayout.getChildCount() - 1) {
				setMargins(bgSetLayout.getChildAt(i), 10, 15);
			} else if (i == 0) {
				setMargins(bgSetLayout.getChildAt(i), 15, 0);
			} else {
				setMargins(bgSetLayout.getChildAt(i), 10, 0);
			}
		}

	}

	public File mPhoto = DirectoryManager.getFile(DirContext.SDCARD_HIDDEN, "photo.jpg");
	/**
	 * 点击事件
	 */
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			switch (v.getId()) {
			case R.id.post_processed_img:// 图片预览区域
				// 弹出||收回背景设置区域
				if (imgShowed || mixShowed) {
					resetSquare();
					imgShowed = false;
				}
				mixShowed = false;
				imgShowed = false;
				break;
			case R.id.post_processed_volume_btn:
				// 弹出||收回背景设置区域
				if (volumeShowed) {
					resetSquare();
					volumeShowed = false;
				} else {
					popVolumeSquare();
					volumeShowed = true;
				}
				mixShowed = false;
				imgShowed = false;
				break;
			case R.id.post_processed_bg_btn:// 背景设置按钮
				// 弹出||收回背景设置区域
				if (imgShowed) {
					resetSquare();
					imgShowed = false;
				} else {
					popImageSetSquare();
					imgShowed = true;
				}
				mixShowed = false;
				volumeShowed = false;
				break;
			case R.id.post_processed_mix_btn:// 混音设置按钮
				// 弹出||收回混音设置区域
				if (mixShowed) {
					resetSquare();
					mixShowed = false;
				} else {
					popMixSquare();
					mixShowed = true;
				}
				imgShowed = false;
				volumeShowed = false;
				break;
			case R.id.post_processed_capture_btn:// 拍照
			{
				dimissImgSetDialog();
				if (mPhoto.exists())
					mPhoto.delete();
				
				Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
				//下面这句指定调用相机拍照后的照片存储的路径  
				intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(mPhoto));  
				mActivity.startActivityForResult(intent, CAPTURE_REQUESTCODE);
				break;
			}
			case R.id.post_processed_local_btn:// 本地选取
			{
				dimissImgSetDialog();
				Intent intent = new Intent(Intent.ACTION_PICK, null);
				intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");  
				mActivity.startActivityForResult(intent, MEDIA_REQUESTCODE);
				break;
			}
			case R.id.post_processed_cancle_btn:// 取消
				dimissImgSetDialog();
				break;
			}
		}
	};

	/* 添加图片选择对话框 */
	private RelativeLayout addImgDialog;
	/* 添加图片选择对话框是否已经显示 */
	private boolean imgDialogShowed = false;

	/**
	 * 点击添加图片弹出选中对话框
	 */
	public void popImgSetDialog() {

		addImgDialog.setVisibility(View.VISIBLE);
		inclickBg.setVisibility(View.VISIBLE);
		setAnimation(addImgDialog, DIALOG_BOTTOM_IN);

		imgSetDialogShowed = true;

		// 点击其他区域, 收回对话框
		addImgDialog.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View view, MotionEvent event) {

				// if (ImageView.getPixel((int) (event.getX()),
				// ((int) event.getY())) == 0) {
				// Toast.makeText(mActivity, "对话框区域", Toast.LENGTH_SHORT);
				// return true;// 透明区域返回true
				// }
				return false;
			}
		});
	}

	/**
	 * 添加图片后对话框消失
	 */
	public void dimissImgSetDialog() {

		imgPreview.setBackgroundResource(R.drawable.sing_scene_temp);
		addImgDialog.setVisibility(View.GONE);
		inclickBg.setVisibility(View.GONE);

		setAnimation(addImgDialog, DIALOG_BOTTOM_OUT);
		imgSetDialogShowed = false;
	}

	/* 拍照上传, 本地上传 */
	public static final int CAPTURE_REQUESTCODE = 0, MEDIA_REQUESTCODE = 1;

	/**
	 * 拍照后回调
	 */
	public void addCapturePicture(Bitmap bmp) {
		imgPreview.setImageBitmap(bmp);

		imgList.add(0, bmp);
		
		// 添加圆角图片
		addBgImg(bmp);
		dimissImgSetDialog();
	}

	/**
	 * 本地选取回调
	 */
	public void addMediaPicture(Uri selectedImage) {
		String picturePath = null;
		if (selectedImage.getScheme().equalsIgnoreCase("file")) {
			picturePath = selectedImage.getPath();
		} else {
			String[] filePathColumn = { MediaStore.Images.Media.DATA };
			Cursor cursor = mActivity.getContentResolver().query(selectedImage, filePathColumn, null, null, null);
			if (cursor == null)
				return;
			
			cursor.moveToFirst();
			int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
			picturePath = cursor.getString(columnIndex);
			cursor.close();
		}
		
		// 原图片
//		Bitmap bitmap = BitmapFactory.decodeFile(picturePath);
		int outWidth = imgPreview.getWidth();
		int outHeight = imgPreview.getHeight();
		Bitmap bitmap = BitmapTools.readBitmapAutoSize(picturePath, outWidth, outHeight);
		addCapturePicture(bitmap);
	}

	/**
	 * 处理缩放,圆角
	 * 
	 * @param bitmap
	 *            要处理的图片
	 * @return
	 */
	private Bitmap reSizeBmp(Bitmap bitmap) {
		// 82*82缩放
		Bitmap resizeSmallBmp = BitmapUtils.zoomBitmap(mActivity, 0, bitmap, 82, 82);
		// 设置圆角
		Bitmap roundImage = BitmapUtils.roundImage(8, resizeSmallBmp);

		return roundImage;
	}

	/**
	 * 添加图片资源
	 * 
	 * @param resource
	 *            图片资源
	 */
	private void addBgImg(Bitmap bitmap) {
		if(bitmap == null)
			return;
		
		Bitmap roundImage = reSizeBmp(bitmap);
		Drawable drawable = new BitmapDrawable(roundImage);
		
		setMargins(bgSetLayout.getChildAt(bgSetLayout.getChildCount() - 1), 10, 15);

		if (imgList.size() == 10) {// 添加后满10个

			bgSetLayout.removeViewAt(0);
			bgSetLayout.addView(inflater.inflate(R.layout.post_processed_bg_item, null), 0);
			// 放置图片
			ImageView set_bg_img = (ImageView) bgSetLayout.getChildAt(0).findViewById(R.id.set_bg_img);
			set_bg_img.setVisibility(View.VISIBLE);
			set_bg_img.setBackgroundDrawable(drawable);

			bgSetLayout.getChildAt(0).findViewById(R.id.set_bg_img_transp).setVisibility(View.VISIBLE);

			setMargins(bgSetLayout.getChildAt(0), 15, 0);

			// 添加动画
			setAnimation(bgSetLayout.getChildAt(0), LIGHTER_IN);
		} else {
			bgSetLayout.addView(inflater.inflate(R.layout.post_processed_bg_item, null), 1);
			// 放置图片
			ImageView set_bg_img = (ImageView) bgSetLayout.getChildAt(1).findViewById(R.id.set_bg_img);
			set_bg_img.setVisibility(View.VISIBLE);
			set_bg_img.setBackgroundDrawable(drawable);

			bgSetLayout.getChildAt(1).findViewById(R.id.set_bg_img_transp).setVisibility(View.VISIBLE);

			// 添加动画
			for (int i = 1; i < bgSetLayout.getChildCount(); i++) {

				setAnimation(bgSetLayout.getChildAt(i), LEFT_IN);
			}

			setMargins(bgSetLayout.getChildAt(1), 10, 0);
		}

		resetDeleteBtn();
		resetImgClick();

	}
//	/**
//	 * 将图片保存在SD卡上
//	 * 
//	 * */
//	private void saveBgSDImg(Bitmap bitmap, int position) {
//		String directoryName = position + "" ;
//		String destination =DirectoryManager.getFilePath(DirContext.MTV_PICTURE, directoryName +".PNG");
//		File file = new File(destination);
//		try{
//		    OutputStream os  =  new FileOutputStream(file);
//		    bitmap.compress(CompressFormat.PNG, 100, os);
//
//		}catch(FileNotFoundException e){
//		   e.printStackTrace();
//		}
//
//	}
//	
//	/**
//	 * 删除SD卡上图片
//	 * 根据position删除，然后依次将后面的文件名字前移
//	 * */
//	private void deleteBgSDImg(int position) {
//		String mtvPictureDir = DirectoryManager.getDirPath(DirContext.MTV_PICTURE);
//		String destination = mtvPictureDir + File.separator + position;
//		File file = new File(destination);
//		if (!file.exists()){
//			return;
//		}
//		
//		File[] childs = file.listFiles();
//		int flag = 0; File oldpath = null, newpath;
//		for(int i = 0; i < childs.length; i++){
//			if(flag == 1){
//				newpath = childs[i].getAbsoluteFile();
//				childs[i].renameTo(oldpath);
//				oldpath = newpath;
//				
//			}
//			if(childs[i].getName().equals(position+"")){
//				oldpath = childs[i].getAbsoluteFile();
//				childs.clone()[i].delete();
//				flag =1;
//			}
//		}
//		
//	}
	/**
	 * 删除已添加的图片
	 * 
	 * @param position
	 *            imgList中的position
	 */
	private void deleteBgImg(int position) {

		// 重置预览
		if (position == imgList.size() - 1) {// 删除最后一张图片

			if (imgList.size() == 1) {
				imgPreview.setImageBitmap(null);
				imgPreview.setBackgroundResource(R.drawable.sing_scene_temp);
			} else {
				imgPreview.setImageBitmap(imgList.get(position - 1));
			}
		} else {
			imgPreview.setImageBitmap(imgList.get(position + 1));
		}

		setMargins(bgSetLayout.getChildAt(bgSetLayout.getChildCount() - 1), 10, 15);

		if (imgList != null && imgList.size() < 10 && imgList.size() != 0) {// 可以继续添加

			// 动画
			setAnimation(bgSetLayout.getChildAt(position + 1), DARKER_OUT);
			bgSetLayout.removeViewAt(position + 1);

			// 添加动画
			for (int i = position + 1; i < bgSetLayout.getChildCount(); i++) {

				if (i == bgSetLayout.getChildCount() - 1 && bgSetLayout.getChildCount() <= 5) {
					setMargins(bgSetLayout.getChildAt(i), 10, 126);
				}
				setAnimation(bgSetLayout.getChildAt(i), RIGHT_IN);
			}

			if (bgSetLayout.getChildCount() == 1) {
				Button set_bg_img_btn = (Button) bgSetLayout.getChildAt(0).findViewById(R.id.set_bg_img_btn);
				set_bg_img_btn.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View v) {
						if (!imgDialogShowed) {
							popImgSetDialog();
						}
					}
				});
			}
		} else if (imgList != null && imgList.size() == 10) {// 删除后显示可以添加按钮
			// 动画
			setAnimation(bgSetLayout.getChildAt(position), DARKER_OUT);
			bgSetLayout.removeViewAt(position);
			// 添加动画
			for (int i = 0; i < position; i++) {

				setAnimation(bgSetLayout.getChildAt(i), LIGHTER_IN);
			}
			bgSetLayout.addView(inflater.inflate(R.layout.post_processed_bg_item, null), 0);
			Button set_bg_img_btn = (Button) bgSetLayout.getChildAt(0).findViewById(R.id.set_bg_img_btn);
			set_bg_img_btn.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					if (!imgDialogShowed) {
						popImgSetDialog();
					}
				}
			});
			// 删除按钮
			Button set_bg_delete_btn = (Button) bgSetLayout.getChildAt(0).findViewById(R.id.set_bg_delete_btn);
			set_bg_delete_btn.setVisibility(View.GONE);

			setMargins(bgSetLayout.getChildAt(0), 15, 0);
			setMargins(bgSetLayout.getChildAt(position), 10, 15);

		} else if (imgList != null && imgList.size() == 0) {
			// 动画
			setAnimation(bgSetLayout.getChildAt(1), DARKER_OUT);
			bgSetLayout.removeViewAt(1);
		} else {
			return;
		}

		imgList.remove(position);

		resetDeleteBtn();
		resetImgClick();
	}

	/**
	 * 重置删除按钮
	 */
	private void resetDeleteBtn() {
		if (imgList == null)
			return;

		if (imgList.size() == 10) {

			for (int i = 0; i < imgList.size(); i++) {

				Button set_bg_delete_btn = (Button) bgSetLayout.getChildAt(i).findViewById(R.id.set_bg_delete_btn);
				set_bg_delete_btn.setTag(i);
				set_bg_delete_btn.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						deleteBgImg((Integer) view.getTag());
					}
				});
			}
		} else if (imgList.size() > 0 && imgList.size() < 10) {

			for (int i = 1; i < bgSetLayout.getChildCount(); i++) {

				Button set_bg_delete_btn = (Button) bgSetLayout.getChildAt(i).findViewById(R.id.set_bg_delete_btn);
				set_bg_delete_btn.setTag(i - 1);
				set_bg_delete_btn.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						deleteBgImg((Integer) view.getTag());
					}
				});
			}
		} else {
			return;
		}
	}

	/**
	 * 重置图片预览
	 */
	private void resetImgClick() {

		if (imgList == null)
			return;

		if (imgList.size() == 10) {

			for (int i = 0; i < imgList.size(); i++) {

				Button set_bg_img_transp = (Button) bgSetLayout.getChildAt(i).findViewById(R.id.set_bg_img_transp);
				set_bg_img_transp.setTag(i);
				set_bg_img_transp.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						imgPreview.setImageBitmap(imgList.get((Integer) view.getTag()));
					}
				});
			}
		} else if (imgList.size() > 0 && imgList.size() < 10) {

			for (int i = 1; i < bgSetLayout.getChildCount(); i++) {

				Button set_bg_img_transp = (Button) bgSetLayout.getChildAt(i).findViewById(R.id.set_bg_img_transp);
				set_bg_img_transp.setTag(i - 1);
				set_bg_img_transp.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						imgPreview.setImageBitmap(imgList.get((Integer) view.getTag()));
					}
				});
			}
		} else {
			return;
		}
	}

	/**
	 * 设置item.Margin
	 * 
	 * @param view
	 *            需要设置的View
	 * @param left
	 *            leftMargin
	 * @param right
	 *            rightMargin
	 */
	private void setMargins(View view, int left, int right) {

		LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		params.setMargins(left, 0, right, 0);

		view.setLayoutParams(params);
	}

	/* 动画效果 */
	private final int RIGHT_IN = 0, DARKER_OUT = 1, LIGHTER_IN = 2, LEFT_IN = 3, SET_BOTTOM_IN = 4, SET_BOTTOM_OUT = 5, DIALOG_BOTTOM_IN = 6, DIALOG_BOTTOM_OUT = 7;

	/**
	 * 设置动画
	 * 
	 * @param view
	 *            待设置的View
	 * @param type
	 *            动画类型
	 */
	private void setAnimation(View view, int type) {

		Animation inAnim = null;

		switch (type) {
		case RIGHT_IN:
			inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.img_bg_right_in);
			break;
		case DARKER_OUT:
			inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.img_bg_darker_out);
			break;
		case LIGHTER_IN:
			inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.img_bg_lighter_in);
			break;
		case LEFT_IN:
			inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.img_bg_left_in);
			break;
		case SET_BOTTOM_IN:
			inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.set_bottom_in);
			break;
		case SET_BOTTOM_OUT:
			inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.set_bottom_out);
			break;
		case DIALOG_BOTTOM_IN:
			inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.sing_img_dialog_bottom_in);
			break;
		case DIALOG_BOTTOM_OUT:
			inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.sing_img_dialog_bottom_out);
			break;
		}
		if (inAnim != null)
			view.startAnimation(inAnim);
	}
	
	/**
	 * 弹出声音调节设置区域
	 */
	private void popVolumeSquare() {

		mixSetBtn.setBackgroundResource(R.drawable.post_processed_mix_btn_selector);
		imgSetBtn.setBackgroundResource(R.drawable.post_processed_bg_btn_pressed);

		mixRelative.setVisibility(View.GONE);
		imgSetScrollview.setVisibility(View.GONE);
		
		setRl.setVisibility(View.VISIBLE);

		Animation inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.set_bottom_in);
		volumeRejust.startAnimation(inAnim);
		
		volumeRejust.setVisibility(View.VISIBLE);
		
		RelativeLayout llReustArea = (RelativeLayout) mActivity.findViewById(R.id.post_processed_set_rl);
		llReustArea.requestLayout();
	}

	/**
	 * 弹出背景设置区域
	 */
	private void popImageSetSquare() {

		mixSetBtn.setBackgroundResource(R.drawable.post_processed_mix_btn_selector);
		imgSetBtn.setBackgroundResource(R.drawable.post_processed_bg_btn_pressed);
		
		mixRelative.setVisibility(View.GONE);
		volumeRejust.setVisibility(View.GONE);
		
		setRl.setVisibility(View.VISIBLE);

		Animation inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.set_bottom_in);
		imgSetScrollview.startAnimation(inAnim);

		imgSetScrollview.setVisibility(View.VISIBLE);
		
		RelativeLayout llReustArea = (RelativeLayout) mActivity.findViewById(R.id.post_processed_set_rl);
		llReustArea.requestLayout();
	}

	/**
	 * 弹出混音设置区域
	 */
	private void popMixSquare() {
		mixSetBtn.setBackgroundResource(R.drawable.post_processed_mix_btn_pressed);
		imgSetBtn.setBackgroundResource(R.drawable.post_processed_bg_btn_selector);

		volumeRejust.setVisibility(View.GONE);
		imgSetScrollview.setVisibility(View.GONE);
		
		setRl.setVisibility(View.VISIBLE);

		Animation inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.set_bottom_in);
		mixRelative.startAnimation(inAnim);

		mixRelative.setVisibility(View.VISIBLE);
		
		RelativeLayout llReustArea = (RelativeLayout) mActivity.findViewById(R.id.post_processed_set_rl);
		llReustArea.requestLayout();

	}

	/**
	 * 弹出区域消失
	 */
	private void resetSquare() {

		mixSetBtn.setBackgroundResource(R.drawable.post_processed_mix_btn_selector);
		imgSetBtn.setBackgroundResource(R.drawable.post_processed_bg_btn_selector);

		Animation inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.set_bottom_out);
		setRl.startAnimation(inAnim);

		imgSetScrollview.setVisibility(View.GONE);
		mixRelative.setVisibility(View.GONE);
		volumeRejust.setVisibility(View.GONE);
		
		setRl.setVisibility(View.GONE);

	}

}
