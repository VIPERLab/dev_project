package com.ifeng.news2.widget;

import org.taptwo.android.widget.ViewFlow;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;

import com.ifeng.news2.R;
import com.qad.loader.ImageLoader.ImageDisplayer;

public class SlideView extends ViewFlow implements ImageDisplayer{

	boolean interacting=false;
	
	public SlideView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public SlideView(Context context, int sideBuffer) {
		super(context, sideBuffer);
	}

	public SlideView(Context context) {
		super(context);
	}
	
	@Override
	public void setOnItemSelectedListener(
			final android.widget.AdapterView.OnItemSelectedListener listener) {
		setOnViewSwitchListener(new ViewSwitchListener() {
			@Override
			public void onSwitched(View view, int position) {
				if(listener!=null)
					listener.onItemSelected(SlideView.this, view, position, position);
			}
		});
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
		case MotionEvent.ACTION_MOVE:
			interacting=true;
			break;
		case MotionEvent.ACTION_UP:
		case MotionEvent.ACTION_CANCEL:
			interacting=false;
			break;
		}
		return super.onTouchEvent(event);
	}
	
	class NotifyTask implements Runnable
	{
		ImageView img;
		BitmapDrawable bmp;
		public NotifyTask(ImageView img,BitmapDrawable bmp) {
			this.img=img;
			this.bmp=bmp;
		}
		@Override
		public void run() {
			if(interacting){
				removeCallbacks(this);
				postDelayed(this, 20);
			}else {
				display(img, bmp);
			}
		}
	}


	@Override
	public void prepare(ImageView img) {
		if(interacting){
			post(new NotifyTask(img, null));
		}else {
			img.setImageBitmap(null);
		}
	}

	@Override
	public void display(ImageView img, BitmapDrawable bmp) {
		if(interacting){
			post(new NotifyTask(img, bmp));
		}else {
			if(null != bmp && null != img)
				img.setImageDrawable(bmp);
		}
	}
	
	@Override
	public void display(ImageView img, BitmapDrawable bmp, Context ctx) {
	    if(null != bmp) {
            img.setImageDrawable(bmp);
            Animation fadeInAnimation = AnimationUtils.loadAnimation(ctx, R.anim.fade_in);
            img.startAnimation(fadeInAnimation);
	    }
	}

	@Override
	public void fail(ImageView img) {
		
	}

}
