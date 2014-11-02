package com.ifeng.share.activity;

import java.io.InputStream;
import java.util.ArrayList;

import org.apache.http.client.ClientProtocolException;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.EditText;
import android.widget.Gallery;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.ifeng.share.R;
import com.ifeng.share.action.ShareManager;
import com.ifeng.share.adapter.ShareImgAdapter;
import com.ifeng.share.bean.ShareInterface;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.bean.TargetShare;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.fetion.FetionManager;
import com.ifeng.share.receiver.ShareReceiver;
import com.ifeng.share.util.HttpUtils;
import com.ifeng.share.util.NetworkState;
import com.ifeng.share.util.WindowPrompt;
/**
 * 分享可编辑界面
 * @author PJW
 *
 */
public class EditShareActivity extends Activity {
	private String title;
	private String url;
	private String contentMsg;  //分享的内容
	private String contentTail; //隐藏的  分享的链接和其后部分
	private int contentTailLength = 0;   //隐藏文字的长度 
	private LinearLayout backBtn,submitBtn;
	private EditText edit;
	private TextView bindStatus,statusLeft,statusCount,shareToWhich;
	private ArrayList<String> imageList;
	private RelativeLayout shareTitle,write_relative;
	private Gallery gallery;
	private String shareImgUrl;
	private ShareImgAdapter galleryAdapter;
	public ShareMessage shareMessage;
	public ShareReceiver shareReceiver;
	private DownLoadImgHandler handler;
	private Bitmap[] imgs;
	private WindowPrompt windowPrompt;
	private TargetShare targetShare;
	public static final int SHARELENGTH = 140;   //分享的字数
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.share_to_blog);
		findViewsById();
		try {
			initShareDatas();
			initShareImage();
			initView();
			registerShareReceiver();
			setButtonListeners();
		} catch (Exception e) {
			finish();
			e.printStackTrace();
		}
	}
	public void initShareImage() {
		if (imageList != null && imageList.size()>0 && ShareManager.isShareImage(targetShare.getType())) {
			imgs = new Bitmap[imageList.size()];
			galleryAdapter = new ShareImgAdapter(EditShareActivity.this,imgs);
			gallery.setAdapter(galleryAdapter);
			gallery.setSpacing(10);
			gallery.setOnItemClickListener(new OnItemClickListener() {
				@Override
				public void onItemClick(AdapterView<?> parent, View view,
						int position, long id) {
					if (position == 0){
						view.setSelected(true);
					}
				}
			});
			gallery.setOnItemSelectedListener(new OnItemSelectedListener() {
				@Override
				public void onItemSelected(AdapterView<?> parent,
						View view, int position, long id) {
					shareImgUrl = imageList.get(position);
				}
				@Override
				public void onNothingSelected(AdapterView<?> parent) {
				}
			});
			handler = new DownLoadImgHandler();
			for (int i = 0; i < imageList.size(); i++) {
				String imgUrl = imageList.get(i);
				new DownLoadImgthread(imgUrl, i).start();
			}
		}
	}
	
	class DownLoadImgthread extends Thread {
		private String imgUrl;
		private int index;

		public DownLoadImgthread(String imgUrl, int index) {
			this.imgUrl = imgUrl;
			this.index = index;
		}

		@Override
		public void run() {
			try {
				InputStream is =  HttpUtils.getInputStream(imgUrl);
				Bitmap bitmap = BitmapFactory.decodeStream(is);
				imgs[index] = bitmap;
				handler.sendEmptyMessage(1);
			} catch (ClientProtocolException e) {
				e.printStackTrace();
			} catch (Throwable e) {
				e.printStackTrace();
			}
			super.run();
		}
	}

	class DownLoadImgHandler extends Handler {
		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 1:
				galleryAdapter.notifyDataSetChanged();
				break;
			default:
				break;
			}
			super.handleMessage(msg);
		}
	}
	public void changeBindStatus(){
		if (bindStatus!=null) {
			bindStatus.setText(ShareManager.getTargetState(this, shareMessage.getType()));
		}

	}
	public void initView() {
		String titleBarString=shareToWhich.getText().toString().replace("$TYPE", targetShare.getName());
		bindStatus.setVisibility(View.GONE);
		shareToWhich.setText(titleBarString);
		windowPrompt = WindowPrompt.getInstance(this);
		bindStatus.setText(ShareManager.getTargetState(this, targetShare.getType()));
		int avaCnt = 0;
		if (ShareManager.RENREN.equals(targetShare.getType())) {
			edit.setText("");
		} else {
			edit.setText(contentMsg);
			avaCnt = edit.getText().length();
			edit.setSelection(avaCnt);
		}
		if (avaCnt <= SHARELENGTH-contentTailLength) {
			statusLeft.setText("还可输入");
		} else {
			statusLeft.setText("已超出");
		}
		statusCount.setText(Math.abs(SHARELENGTH - contentTailLength - avaCnt) + "");
		if (ShareManager.SINA.equals(targetShare.getType()) 
				|| ShareManager.TENQT.equals(targetShare.getType())
						|| ShareManager.TENQZ.equals(targetShare.getType())) {
			write_relative.setVisibility(View.VISIBLE);
		}else {
			write_relative.setVisibility(View.GONE);
		}
		/*shareTitle.postDelayed(new Runnable() {
			@Override
			public void run() {
				shareTitle.setBackgroundDrawable(BitmapTool
						.fillHorizontalAndRepeatX(getResources(),
								R.drawable.titlebar_bg_item,
								shareTitle.getHeight()));
			}
		}, 0);*/
	}
	public void initShareDatas() {
		
		shareMessage = ShareManager.getShareMessage();
		imageList = shareMessage.getImageResources();
		title = shareMessage.getTitle();
		url = shareMessage.getUrl();
		targetShare = shareMessage.getTargetShare();
		initialSendMsgAndtail();
	}
	
	/** 
	 *   初始化分享信息   
	 *   显示部分和隐藏部分
	 */
	private void initialSendMsgAndtail() {
		int index = shareMessage.getContent().lastIndexOf("http");
		if(index != -1) {
			contentMsg = shareMessage.getContent().substring(0,index);
			contentTail = ' '+shareMessage.getContent().substring(index);
			contentTailLength = contentTail.length();	
		} else {
			contentMsg = shareMessage.getContent();
			contentTail = "";
			contentTailLength = 0;
		}
	}
	
	@Override
	protected void onResume() {
		changeBindStatus();
		super.onResume();
	}

	private void findViewsById() {
		write_relative = (RelativeLayout)findViewById(R.id.write_relative);
		backBtn = (LinearLayout) findViewById(R.id.cancle);
		submitBtn = (LinearLayout) findViewById(R.id.submit);
		edit = (EditText) findViewById(R.id.share_edit);
		bindStatus = (TextView) findViewById(R.id.bind_status);
		statusLeft = (TextView) findViewById(R.id.text_status);
		statusCount = (TextView) findViewById(R.id.avaliable_size);
		shareTitle = (RelativeLayout) findViewById(R.id.share_title);
		gallery = (Gallery) findViewById(R.id.share_garllery);
		shareToWhich = (TextView) findViewById(R.id.weibo_title);
	}

	private void setButtonListeners() {
		backBtn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				EditShareActivity.this.finish();
			}
		});
		submitBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				if (NetworkState.isActiveNetworkConnected(EditShareActivity.this)) {
					String editInfor = edit.getText().toString();
					if(editInfor == null || "".equals(editInfor.trim())) {
						windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong,R.string.message_empty_title,R.string.message_empty_content);
					} else {
						ShareManager.setShareContent(getShareContent());
						ShareManager.setShareImageUrl(shareImgUrl);
						Intent intent = new Intent();
						intent.setAction(TokenTools.SHARE_RECEIVER_ACTION);
						sendBroadcast(intent);
					}
				}else {
					Toast.makeText(EditShareActivity.this, "当前无可用网络", Toast.LENGTH_SHORT).show();
				}

			}
		});
		edit.addTextChangedListener(new TextWatcher() {

			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
			}
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
			}
			@Override
			public void afterTextChanged(Editable s) {
				if (s.length() <= SHARELENGTH - contentTailLength) {
					statusLeft.setText("还可输入");
				} else {
					statusLeft.setText("已超出");
				}
				statusCount.setText(Math.abs(SHARELENGTH - contentTailLength - s.length()) + "");
			}
		});
	}
	//分享最终内容
	public String getShareContent(){
		String shareContent = edit.getText().toString()+contentTail;
		if (shareContent==null || shareContent.length()==0) {
			shareContent = title + "  " + url+ this.getResources().getString(R.string.share_text);
		}
		return shareContent;
	}
	public void registerShareReceiver(){
		shareReceiver = new ShareReceiver(EditShareActivity.this);
		IntentFilter intentFilter = new IntentFilter();
		intentFilter.addAction(TokenTools.SHARE_RECEIVER_ACTION);
		registerReceiver(shareReceiver,intentFilter);
	}
	public void unregisterShareReceiver(){
		if (shareReceiver!=null) {
			unregisterReceiver(shareReceiver);
		}
	}
	@Override
	protected void onPause() {
		super.onPause();
		if (ShareManager.FETION.equals(targetShare.getType())) {
			Log.i("share", "清空飞信登录信息");
			FetionManager.isBind = false;
			ShareManager.deleteCookie(this);
		}
	}
	@Override
	protected void onDestroy() {
		if (Build.VERSION.SDK_INT < 11) {
			for (int i = 0; i < imgs.length; i++) {
				if (null != imgs[i] && !imgs[i].isRecycled()) {
					imgs[i].recycle();
				}
			}
		}
		super.onDestroy();
		unregisterShareReceiver();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		if (targetShare!=null) {
			ShareInterface shareInterface = targetShare.getShareInterface();
			shareInterface.authCallback(requestCode, resultCode, data);
		}
	}
	

}
