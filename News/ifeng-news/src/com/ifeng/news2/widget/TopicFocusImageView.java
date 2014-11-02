package com.ifeng.news2.widget;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import com.qad.view.RecyclingImageView;

public class TopicFocusImageView extends RecyclingImageView {
	
	public TopicFocusImageView(Context context) {
		super(context);
	}
	
	public TopicFocusImageView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public TopicFocusImageView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

//	@Override
//	public void setImageBitmap(Bitmap bm) {
//		if (bm == null) return;
//		WindowManager wm = (WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE);
//		int displayWidth = wm.getDefaultDisplay().getWidth();
//		if (bm.getWidth() <= 10) {
//			//宽度小于10像素认为是纯色底图将其拉伸
//			getLayoutParams().height = bm.getHeight();
//		} else {
//			//否者认为是专题头图，按照w/h = w1/h1比例显示   注：w为屏幕宽，h为要显示的高度，w1为图片宽，h1为图片高
//			getLayoutParams().height = bm.getHeight() * displayWidth / bm.getWidth();
//		}
//		setAdjustViewBounds(false);
//		setScaleType(ScaleType.FIT_XY);
//		super.setImageBitmap(bm);
//	}
	
	@Override
	public void setImageDrawable(Drawable drawable) {
		if (drawable instanceof BitmapDrawable) {
			int displayWidth = getContext().getResources().getDisplayMetrics().widthPixels;
			Bitmap bm = ((BitmapDrawable)drawable).getBitmap();
			if (bm.getWidth() <= 10) {
				//宽度小于10像素认为是纯色底图将其拉伸
				getLayoutParams().height = bm.getHeight();
			} else {
				//否者认为是专题头图，按照w/h = w1/h1比例显示   注：w为屏幕宽，h为要显示的高度，w1为图片宽，h1为图片高
				getLayoutParams().height = bm.getHeight() * displayWidth / bm.getWidth();
			}
			setAdjustViewBounds(false);
			setScaleType(ScaleType.FIT_XY);
		}
		
		super.setImageDrawable(drawable);
	}
}
