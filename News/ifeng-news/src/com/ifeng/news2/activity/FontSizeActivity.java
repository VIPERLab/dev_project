package com.ifeng.news2.activity;

import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;

import com.ifeng.news2.R;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.widget.IfengBottom;
import com.ifeng.news2.widget.RelativeLayoutWithFlingDetector;
import com.qad.util.OnFlingListener;

public class FontSizeActivity extends AppBaseActivity implements
		OnClickListener, OnFlingListener {
	
	private View bigSize;
	private View largeSize;
	private View middleSize;
	private View smallSize;
	private ImageView bigSizeImg;
	private ImageView largeSizeImg;
	private ImageView middleSizeImg;
	private ImageView smallSizeImg;
	private View currentFontView ; 
	private IfengBottom bottom;
	private RelativeLayoutWithFlingDetector wrapper;
	
	private SharedPreferences sharedPreferences;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.font_size);
		
		initViews();
		initFontSizeInfo();
		beginStatistic();
	}


	private void beginStatistic() {
		// TODO Auto-generated method stub
		StatisticUtil.addRecord(this
				, StatisticUtil.StatisticRecordAction.page
				, "id=noid$ref=ys"+"$type=" + StatisticUtil.StatisticPageType.set);
	}


	private void initViews() {
		wrapper = (RelativeLayoutWithFlingDetector) findViewById(R.id.account_bind_wrapper);
		wrapper.setOnFlingListener(this);
		bottom = (IfengBottom) findViewById(R.id.ifeng_bottom);
		bottom.getBackButton().setOnClickListener(this);
		
		bigSize = findViewById(R.id.font_size_big);
		largeSize = findViewById(R.id.font_size_large);
		middleSize = findViewById(R.id.font_size_middle);
		smallSize = findViewById(R.id.font_size_small);
		
		bigSizeImg = (ImageView) findViewById(R.id.font_size_big_img);
		largeSizeImg = (ImageView) findViewById(R.id.font_size_large_img);
		middleSizeImg = (ImageView) findViewById(R.id.font_size_middle_img);
		smallSizeImg = (ImageView) findViewById(R.id.font_size_small_img);
		
		bigSize.setOnClickListener(this);
		largeSize.setOnClickListener(this);
		middleSize.setOnClickListener(this);
		smallSize.setOnClickListener(this);
	}
	
	private void initFontSizeInfo() {
		sharedPreferences = PreferenceManager
				.getDefaultSharedPreferences(this);
		
		String currentFontSize = sharedPreferences.getString("fontSize", "mid");
		resetFontSize(currentFontSize);
	}
	
	/**
	 * 初始化字体大小背景
	 */
	private void resetFontSize(String fontSize) {
		if ("mid".equals(fontSize)) {
			currentFontView = middleSizeImg;
			
			middleSizeImg.setVisibility(View.VISIBLE);
			
			bigSizeImg.setVisibility(View.GONE);
			smallSizeImg.setVisibility(View.GONE);
			largeSizeImg.setVisibility(View.GONE);
		} else if ("small".equals(fontSize)) {
			currentFontView = smallSizeImg;
			
			smallSizeImg.setVisibility(View.VISIBLE);
			
			middleSizeImg.setVisibility(View.GONE);
			bigSizeImg.setVisibility(View.GONE);
			largeSizeImg.setVisibility(View.GONE);
		} else if ("big".equals(fontSize)) {
			currentFontView = bigSizeImg;
			
			bigSizeImg.setVisibility(View.VISIBLE);
			
			middleSizeImg.setVisibility(View.GONE);
			smallSizeImg.setVisibility(View.GONE);
			largeSizeImg.setVisibility(View.GONE);
		} else if ("large".equals(fontSize)){
			currentFontView = largeSizeImg;
			
			largeSizeImg.setVisibility(View.VISIBLE);
			
			middleSizeImg.setVisibility(View.GONE);
			bigSizeImg.setVisibility(View.GONE);
			smallSizeImg.setVisibility(View.GONE);
		}
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch(v.getId()){
		case R.id.font_size_big:
			setFontSize(bigSizeImg , "big");
			break;
		case R.id.font_size_small:
			setFontSize(smallSizeImg , "small");
			break;
		case R.id.font_size_large:
			setFontSize(largeSizeImg , "large");
			break;
		case R.id.font_size_middle:
			setFontSize(middleSizeImg , "mid");
			break;
		// 返回
		case R.id.back:
			onBackPressed();
			break;
		}
	}
	
	/**
	 * 设置字体大小
	 */
	private void setFontSize(View fontView, String fontSize) {
		if (currentFontView != fontView) {
			resetFontSize(fontSize);
			saveFont(fontSize);
		}
	}
	
	/**
	 * 保存字体大小设置
	 * 
	 * @param fontSize
	 */
	private void saveFont(String fontSize) {
		Editor editor = sharedPreferences.edit();
		editor.putString("fontSize", fontSize);
		editor.commit();
	}

	
	
	@Override
	public void onBackPressed() {
		StatisticUtil.isBack = true ; 
		ConstantManager.isSettingsShow = true ; 
		finish();
		overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);
	}
	
	@Override
	public void onFling(int flingState) {
		// TODO Auto-generated method stub
		if (flingState == FLING_RIGHT) {
			onBackPressed();
		}
	}

	

}
