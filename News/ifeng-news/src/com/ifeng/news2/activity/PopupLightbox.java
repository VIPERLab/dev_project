package com.ifeng.news2.activity;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import com.ifeng.news2.FunctionActivity;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.ImageCutUtil;
import com.ifeng.news2.widget.zoom.PhotoView;
import com.ifeng.news2.widget.zoom.PhotoViewAttacher.OnViewTapListener;
import com.ifeng.share.util.NetworkState;
import com.qad.loader.ImageLoader.ImageDisplayer;
import com.qad.loader.LoadContext;

public class PopupLightbox extends FunctionActivity implements OnClickListener,
		OnViewTapListener {

	protected static final int DOWNLOAD_FAIL = 1;
	protected static final int DOWNLOAD_SUCCESS = 2;
	private String imgUrl;
	private String callbackId;
	private PhotoView mImageView;
	private ImageView back;
	private ImageView downLoad;
	private TextView message;
	private View container;
	private int width;
	private int height;

	private class Displayer implements ImageDisplayer {

		@Override
		public void prepare(ImageView img) {
			message.setText("正在加载图片，请稍候");
		}

		@Override
		public void display(ImageView img, final BitmapDrawable bmp) {
			if (bmp != null) {// && !bmp.isRecycled()) {
				width = bmp.getBounds().width();
	            height = bmp.getBounds().height();
				message.setVisibility(View.GONE);
				container.setVisibility(View.VISIBLE);
				mImageView.setImageDrawable(bmp);
			} else if (NetworkState
					.isActiveNetworkConnected(getApplicationContext())) {
				message.setText(R.string.getUnit_fail);
			} else {
				message.setText(R.string.not_network_message);
			}
		}

		@Override
		public void display(ImageView img, BitmapDrawable bmp, Context ctx) {
			if (bmp != null) {// && !bmp.isRecycled()) {
				width = bmp.getBounds().width();
		        height = bmp.getBounds().height();
				message.setVisibility(View.GONE);
				container.setVisibility(View.VISIBLE);
				mImageView.setImageDrawable(bmp);
				// fade in 动画效果
				Animation fadeInAnimation = AnimationUtils.loadAnimation(ctx,
						R.anim.fade_in);
				mImageView.startAnimation(fadeInAnimation);
			} else if (NetworkState
					.isActiveNetworkConnected(getApplicationContext())) {
				message.setText(R.string.getUnit_fail);
			} else {
				message.setText(R.string.not_network_message);
			}
		}

		@Override
		public void fail(ImageView img) {
			if (NetworkState
					.isActiveNetworkConnected(getApplicationContext())) {
				message.setText(R.string.getUnit_fail);
			} else {
				message.setText(R.string.not_network_message);
			}
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.poplightbox);
		Bundle b = getIntent().getExtras();
		imgUrl = b.getString("imgUrl");
		callbackId = (String) b.get("callbackId");
		initView();
		if (getIntent().getAction() != null
				&& getIntent().getAction().equals(
						ConstantManager.ACTION_FROM_DIRECT_SEEDING)) {
			String resultImgUrl = ImageCutUtil.getRealHeightAndWidthByUrl(PopupLightbox.this,imgUrl);
			Log.d("i", resultImgUrl);
			if(!TextUtils.isEmpty(resultImgUrl)){
				imgUrl = resultImgUrl;
			}			
		}		
		loadImage();				
	}

	private void initView() {
		container = findViewById(R.id.container);
		mImageView = (PhotoView) findViewById(R.id.mImageView);
		mImageView.setOnViewTapListener(this);
		back = (ImageView) findViewById(R.id.slide_back);
		downLoad = (ImageView) findViewById(R.id.slide_download);
		message = (TextView) findViewById(R.id.tip);
		back.setOnClickListener(this);
		downLoad.setOnClickListener(this);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
		getWindow().addFlags(
				WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
	}

	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			backToDetail();
		}
		return true;
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.slide_back:
			backToDetail();
			break;
		case R.id.slide_download:
			downLoadImage(imgUrl);
			break;
		default:
		}
	}

	/**
	 * 加载图片
	 */
	private void loadImage() {
		if (imgUrl != null) {
			IfengNewsApp.getImageLoader().startLoading(
					new LoadContext<String, ImageView, Bitmap>(imgUrl,
							mImageView, Bitmap.class,
							LoadContext.FLAG_FILECACHE_FIRST, this),
					new Displayer());
		} else {
			finish();
		}
	}

	private void backToDetail() {
		if (callbackId != null) {
			Intent intent = new Intent(this, DetailActivity.class);
			intent.putExtra("url", imgUrl);
			intent.putExtra("callbackId", callbackId);
			setResult(100, intent);
		}
		if(width!=0&&height!=0){
			mImageView.getDrawable().setBounds(0, 0, width, height);
		}
		finish();
		overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
	}

	@Override
	public void onViewTap(View view, float x, float y) {
		backToDetail();
	}

}
