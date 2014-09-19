/**

 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.ProgressDialog;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.BitmapUtils;
import cn.kuwo.sing.R;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.context.App;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.service.UserService;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.LocalEditActivity;
import cn.kuwo.sing.ui.activities.LocalNoticeActivity;
import cn.kuwo.sing.ui.activities.LoginActivity;
import cn.kuwo.sing.ui.activities.MainActivity;
import cn.kuwo.sing.ui.compatibility.KuwoWebView;
import cn.kuwo.sing.ui.compatibility.KuwoWebView.OnOrderListener;
import cn.kuwo.sing.util.BitmapTools;

/**
 * @Package cn.kuwo.sing.controller
 *
 * @Date 2012-11-1, 下午12:23:54, 2012
 *
 * @Author wangming
 *
 */
public class LocalController extends BaseController implements OnOrderListener {
	private final String TAG = "LocalController";
	private static final String URL_LOCAL_MYHOME = "http://changba.kuwo.cn/kge/webmobile/an/myhome.html?r="+Math.random();
//	private static final String URL_LOCAL_MYHOME = "http://www.baidu.com";
	private BaseActivity mActivity;
	private TextView mySongsTV;
	private Button msgTV;
	private KuwoWebView local_web_view;
//	private TextView msgTip;
	private Button local_top_msg;
//	private TextView local_msg_tip;
	private ImageView local_msg_tips;
	private ImageView iv_local_login_register;
	private RelativeLayout rl_local_image;
	private RelativeLayout rl_local_web_view;
	private LinearLayout main_bottom_linlayout;
	/* 弹出对话框后灰色背景 */
	private RelativeLayout inclickBg;
	// 添加图片对话框是否已经显示
	public boolean imgSetDialogShowed = false;
	/* 添加图片选择对话框 */
	private RelativeLayout addHeadPicDialog;
	private RelativeLayout rl_local_progress;
	private MainActivity mainActivity;
	private ProgressDialog uploadPd;
	/* 动画效果 */
	private final int DIALOG_BOTTOM_IN = 6, DIALOG_BOTTOM_OUT = 7;
	/* 拍照上传, 本地上传 */
	public static final int CAPTURE_REQUESTCODE = 0, MEDIA_REQUESTCODE = 1;
	
	public LocalController(BaseActivity activity) {
		KuwoLog.i(TAG, "LocalController");
		mActivity = activity;
		initView();
	}
	
	public void setNoticeViewInvisible() {
		local_msg_tips.setVisibility(View.INVISIBLE);
	}
	
	public void setNoticeViewVisible() {
		local_msg_tips.setVisibility(View.VISIBLE);
	}
	
	private void initView() {
		
		rl_local_image = (RelativeLayout) mActivity.findViewById(R.id.rl_local_image);
		rl_local_web_view = (RelativeLayout) mActivity.findViewById(R.id.rl_local_web_view);
		local_top_msg = (Button) mActivity.findViewById(R.id.bt_local_top_msg);
		local_top_msg.setOnClickListener(mOnClickListener);
		local_msg_tips = (ImageView) mActivity.findViewById(R.id.local_msg_tips);
		local_msg_tips.setVisibility(View.INVISIBLE);
		
		local_web_view = (KuwoWebView)mActivity.findViewById(R.id.local_web_view);
		local_web_view.setOnOrderListener(this);
		main_bottom_linlayout = (LinearLayout) mActivity.findViewById(R.id.main_bottom_linlayout);
		
		inclickBg = (RelativeLayout) mActivity.findViewById(R.id.local_inclick_bg);
		addHeadPicDialog = (RelativeLayout) mActivity.findViewById(R.id.local_img_dialog);
		rl_local_progress = (RelativeLayout) mActivity.findViewById(R.id.rl_local_progress);
		rl_local_progress.setVisibility(View.INVISIBLE);
		
		// "拍照"按钮
		Button post_processed_capture_btn = (Button)mActivity.findViewById(R.id.local_head_capture_btn);
		post_processed_capture_btn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
				mActivity.startActivityForResult(intent, CAPTURE_REQUESTCODE);
			}
		});
		// "本地上传"按钮
		Button post_processed_local_btn = (Button)mActivity.findViewById(R.id.local_head_local_btn);
		post_processed_local_btn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Intent intent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
				mActivity.startActivityForResult(intent, MEDIA_REQUESTCODE);
			}
		});
		// "取消"按钮
		Button post_processed_cancle_btn = (Button)mActivity.findViewById(R.id.local_head_cancle_btn);
		post_processed_cancle_btn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				dimissImgSetDialog();
			}
		});
		if(!Config.getPersistence().isLogin) {
			loadNotLoginView();
		}else {
			loadLoginView();
		}
	}
	
	private void setTabWidgetState(int visibility) {
		App app = (App) mActivity.getApplication();
		MainActivity mainActivity = (MainActivity) app.getActivity(MainActivity.class);
		mainActivity.setTabWidgetState(visibility);
	}
	
	/**
	 * 点击添加图片弹出选中对话框
	 */
	public void showImgSetDialog() {
		inclickBg.setVisibility(View.VISIBLE);
		setTabWidgetState(View.GONE);
		addHeadPicDialog.setVisibility(View.VISIBLE);
		setAnimation(addHeadPicDialog, DIALOG_BOTTOM_IN);
		imgSetDialogShowed = true;
	}
	
	/**
	 * 添加图片后对话框消失
	 */
	public void dimissImgSetDialog() {
		Handler handler = new Handler();
		handler.postDelayed(new Runnable() {
			
			@Override
			public void run() {
				setTabWidgetState(View.VISIBLE);
			}
		}, 500);
		addHeadPicDialog.setVisibility(View.GONE);
		inclickBg.setVisibility(View.GONE);
		setAnimation(addHeadPicDialog, DIALOG_BOTTOM_OUT);
		imgSetDialogShowed = false;
	}
	
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
		case DIALOG_BOTTOM_IN:
			inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.sing_img_dialog_bottom_in);
			break;
		case DIALOG_BOTTOM_OUT:
			inAnim = AnimationUtils.loadAnimation(mActivity, R.anim.sing_img_dialog_bottom_out);
			break;
		}
		if (inAnim != null) {
			view.startAnimation(inAnim);
		}
	}
	
	/**
	 * 本地选取回调
	 */
	public void addMediaPicture(Uri selectedImage) {
		if(selectedImage == null)
			return;
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
		int outWidth = AppContext.SCREEN_WIDTH/4;
		int outHeight = AppContext.SCREEN_WIDTH/4;
		Bitmap bitmap = BitmapTools.readBitmapAutoSize(picturePath, outWidth, outHeight);
		addCapturePicture(bitmap);
	}
	
	/**
	 * 拍照后回调
	 */
	public void addCapturePicture(Bitmap bitmap) {
		// 640*640缩放
		final Bitmap bmp = BitmapUtils.zoomBitmap(mActivity, 0, bitmap, AppContext.SCREEN_WIDTH/4, AppContext.SCREEN_WIDTH/4);
		//发送图片到server
		uploadPd = new ProgressDialog(mActivity);
		uploadPd.setCancelable(true);
		uploadPd.setCanceledOnTouchOutside(false);
		uploadPd.setMessage("正在上传中，请稍后");
		uploadPd.show();
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				UserService userService = new UserService();
				String result = userService.uploadMyHead(Config.getPersistence().user.uid, Config.getPersistence().user.sid, Bitmap2IS(bmp));
				Message msg = uploadMyHeadHandler.obtainMessage();
				msg.what = 0;
				msg.obj = result;
				uploadMyHeadHandler.sendMessage(msg);
				
			}
		}).start();
		dimissImgSetDialog();
	}
	
	private Handler uploadMyHeadHandler = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 0:
				String result = (String) msg.obj;
				KuwoLog.i(TAG, "uploadMyHead result="+result);
				if(result == null) {
					KuwoLog.i(TAG, "头像上传失败");
					Toast.makeText(mActivity, "头像上传失败", 0).show();
					uploadPd.dismiss();
					break;
				}
				try {
					JSONObject jsonObj = new JSONObject(result);
					String stat = jsonObj.getString("stat");
					KuwoLog.i(TAG, "stat="+stat);
					if(stat.equals("200")) {
						KuwoLog.i(TAG, "头像上传成功");
						uploadPd.dismiss();
						String pic = jsonObj.getString("pic");
						String function = "onHeadPic('pic="+pic+"')";
						local_web_view.js(function);
						//webview reload
						local_web_view.reload();
					}else {
						KuwoLog.i(TAG, "头像上传失败");
						uploadPd.dismiss();
					}
				} catch (JSONException e) {
					KuwoLog.printStackTrace(e);
				}
				break;

			default:
				break;
			}
		};
	};
	

    private InputStream  Bitmap2IS(Bitmap bm){  
    	if(bm == null) {
    		return null;
    	}
    	ByteArrayOutputStream baos = new ByteArrayOutputStream();  
        bm.compress(Bitmap.CompressFormat.PNG, 100, baos);  
        InputStream sbs = new ByteArrayInputStream(baos.toByteArray());    
        return sbs;  
    }  
	
	public void loadNotLoginView() {
		local_top_msg.setVisibility(View.INVISIBLE);
		local_msg_tips.setVisibility(View.INVISIBLE);
		rl_local_web_view.setVisibility(View.INVISIBLE);
		rl_local_image.setVisibility(View.VISIBLE);
		iv_local_login_register = (ImageView) mActivity.findViewById(R.id.iv_local_login_register);
		iv_local_login_register.setOnClickListener(mOnClickListener);
	}
	
	public void loadLoginView() {
		rl_local_image.setVisibility(View.INVISIBLE);
		rl_local_web_view.setVisibility(View.VISIBLE);
		local_top_msg.setVisibility(View.VISIBLE);
		if(Config.getPersistence().user.noticeNumber != 0) {
			local_msg_tips.setVisibility(View.VISIBLE);
		}else {
			local_msg_tips.setVisibility(View.INVISIBLE);
		}
		local_web_view.loadUrl(URL_LOCAL_MYHOME);
	}
	
	public void reload() {
		local_web_view.reload();
	}
	
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			int id = v.getId();
			switch (id) {
			case R.id.iv_local_login_register:
				Intent loginIntent = new Intent(mActivity, LoginActivity.class);
				mActivity.startActivityForResult(loginIntent, Constants.LOGIN_REQUEST);
				break;
			case R.id.bt_local_top_msg://消息
				Intent msgIntent = new Intent(mActivity, LocalNoticeActivity.class);
				msgIntent.putExtra("title", "我的消息");
				String url = "http://changba.kuwo.cn/kge/webmobile/an/news.html";
				msgIntent.putExtra("webviewurl", url);
				mActivity.startActivity(msgIntent);
				break;
			default:
				break;
			}
		}
	};
	
	@Override
	public void onOrder(String order, Map<String, String> params) {
		KuwoLog.d(TAG, "order:"+order+" params: "+params);
		if(!AppContext.getNetworkSensor().hasAvailableNetwork()) {
			Toast.makeText(mActivity, "网络未连接，请稍后再试", 0).show();
			return;
		}
		if(order.equalsIgnoreCase("NewPage")) {
			KuwoLog.i(TAG, "");
			String type = params.get("type");
			String url = params.get("url");
			String title = params.get("title");
			try {
				url = URLDecoder.decode(url, "utf-8");
				title = URLDecoder.decode(title, "utf-8");
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
			KuwoLog.i(TAG, "type="+type);
			KuwoLog.i(TAG, "url="+url);
			KuwoLog.i(TAG, "title="+title);
			Intent intent = new Intent(mActivity, LocalNoticeActivity.class);
			intent.putExtra("title", title);
			intent.putExtra("webviewurl", url);
			mActivity.startActivity(intent);
		}else if(order.equalsIgnoreCase("playsong")) {
			MTVBusiness mb = new MTVBusiness(mActivity);
			KuwoLog.i(TAG, "rid="+params.get("rid"));
			mb.playMtv(params.get("rid"));
		}else if(order.equalsIgnoreCase("EditMyInfo")) {
			Intent editintent = new Intent(mActivity, LocalEditActivity.class);
			mActivity.startActivityForResult(editintent, Constants.LOCAL_EDITINFO_REQUEST);
		}else if(order.equals("EditMyHead")) {
			String action = params.get("action");
			KuwoLog.i(TAG, "action="+action);
			//相册取图，照相机拍图
			if(imgSetDialogShowed) {
				//dismiss
				mActivity.runOnUiThread(new Runnable() {
					
					@Override
					public void run() {
						dimissImgSetDialog();
					}
				});
			}else {
				//show
				mActivity.runOnUiThread(new Runnable() {
					
					@Override
					public void run() {
						showImgSetDialog();
					}
				});
			}
		}
	}

	@Override
	public void onPageStart() {
		rl_local_progress.setVisibility(View.VISIBLE);
	}

	@Override
	public void onPageFinished() {
		rl_local_progress.setVisibility(View.INVISIBLE);
	}

	@Override
	public void onNoServerLoading() {
		// TODO Auto-generated method stub
		
	}
}