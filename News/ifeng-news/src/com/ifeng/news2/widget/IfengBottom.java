package com.ifeng.news2.widget;

import com.ifeng.news2.R;
import com.ifeng.news2.util.StatisticUtil;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;

/**
 * 底部导航栏
 * 
 */
public class IfengBottom extends RelativeLayout {

	private ImageView back;
	private View ifengBottom;

	public ImageView getBack() {
		return back;
	}

	public IfengBottom(Context context) {
		super(context);
		init();
	}

	public IfengBottom(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	public IfengBottom(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	private void init() {
		ifengBottom = LayoutInflater.from(getContext()).inflate(
				R.layout.ifeng_bottom, this);
		back = (ImageView) ifengBottom.findViewById(R.id.back);
		
	}
	
	public ImageView getBackButton() {
		return back;
	}

	public void onClickBack(){
		back.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				StatisticUtil.isBack = true ; 
				((Activity) getContext()).finish();
				//增加底部back按钮跳转动画
				((Activity) getContext()).overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
			}
		});
	}
}
