package com.handmark.pulltorefresh.library.internal;

import android.content.Context;
import android.graphics.drawable.AnimationDrawable;
import android.util.AttributeSet;
import android.widget.ImageView;

public class GifView extends ImageView {

	AnimationDrawable mDrawable = null;
	
	public GifView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public GifView(Context context) {
		super(context);
	}
	
	@Override
	protected void onAttachedToWindow() {
		super.onAttachedToWindow();
		mDrawable = (AnimationDrawable) getBackground();
		mDrawable.start();
	}
	@Override
	protected void onDetachedFromWindow() {
		super.onDetachedFromWindow();
		if(mDrawable!=null)mDrawable.stop();
	}
	public void reset(){
		if(mDrawable!=null)mDrawable.start();
	}
}
