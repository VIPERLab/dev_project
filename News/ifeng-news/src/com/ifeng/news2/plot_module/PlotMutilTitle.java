package com.ifeng.news2.plot_module;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.TextView;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.widget.TopicFocusImageView;
import com.qad.loader.ImageLoader.ImageDisplayer;
import com.qad.loader.LoadContext;

/**
 * @author liu_xiaoliang
 * 焦点图
 */
public class PlotMutilTitle extends PlotBaseModule {
  private TopicFocusImageView image;
  private TextView title, sutTitle;
  private View mutilView;

  public PlotMutilTitle(Context context, AttributeSet attrs) {
    super(context, attrs);
  }
  public PlotMutilTitle(Context context){
    super(context);
  } 

  @Override
  public void buildModule() {
    super.buildModule();

    mutilView = (View)inflater.inflate(R.layout.topic_mutil_title_module, null);
    title = (TextView)mutilView.findViewById(R.id.mutil_title);
    sutTitle = (TextView)mutilView.findViewById(R.id.mutil_sub_title);
    image = (TopicFocusImageView)mutilView.findViewById(R.id.module_focus_image);

    if(!TextUtils.isEmpty(plotTopicBody.getTitle()))title.setText(plotTopicBody.getTitle());
    if(!TextUtils.isEmpty(plotTopicBody.getSubTitle()))sutTitle.setText(plotTopicBody.getSubTitle());

    loadImage(plotTopicBody.getBgImage());

    addView(mutilView);
    //加阴影
    View shadowView = inflater.inflate(R.layout.topic_bottom_shadow, null);
    shadowView.setBackgroundResource(drawable.plot_topic_divider_solid_line);
    addView(shadowView);
  }


  private void loadImage(String url){

    if(null != image){
      getDefaultLoader().startLoading(new LoadContext<String, ImageView, Bitmap>(url, image, Bitmap.class, LoadContext.FLAG_CACHE_FIRST, context), new ImageDisplayer() {

        @Override
        public void prepare(ImageView arg0) {
          BitmapDrawable bd = (BitmapDrawable)getResources().getDrawable(drawable.plot_topic_mutil_icon_bg);
          Bitmap bm = bd.getBitmap();
          arg0.setImageBitmap(bm);
        }

        @Override
        public void display(ImageView img, BitmapDrawable bmp) {
          if (bmp == null) {// || bmp.isRecycled()){
            BitmapDrawable bd = (BitmapDrawable)getResources().getDrawable(drawable.plot_topic_mutil_icon_bg);
            Bitmap bm = bd.getBitmap();
            img.setImageBitmap(bm);
          } else {
            img.setImageDrawable(bmp);
          }
        }

        @Override
        public void display(ImageView img, BitmapDrawable bmp, Context ctx) {
          if (bmp == null) {// || bmp.isRecycled()){
            BitmapDrawable bd = (BitmapDrawable)getResources().getDrawable(drawable.plot_topic_mutil_icon_bg);
            Bitmap bm = bd.getBitmap();
            img.setImageBitmap(bm);
          } else {
            img.setImageDrawable(bmp);
            if (null != ctx) {
              // fade in 动画效果
              Animation fadeInAnimation = AnimationUtils.loadAnimation(ctx, R.anim.fade_in);
              img.startAnimation(fadeInAnimation);
            }
          }
        }

		@Override
		public void fail(ImageView img) {
			
		}
      });
    }
  }
}
