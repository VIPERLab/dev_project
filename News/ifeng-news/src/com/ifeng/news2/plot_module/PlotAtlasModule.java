package com.ifeng.news2.plot_module;

import android.app.Activity;

import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.graphics.drawable.BitmapDrawable;
import com.ifeng.news2.R.drawable;
import com.qad.loader.ImageLoader.ImageDisplayer;
import android.content.Intent;

import com.ifeng.news2.activity.PlotTopicModuleActivity;
import com.ifeng.news2.activity.PopupLightbox;
import com.ifeng.news2.util.IntentUtil;
import java.util.ArrayList;
import com.ifeng.news2.bean.Extension;
import android.graphics.Bitmap;
import android.widget.ImageView;
import com.qad.loader.LoadContext;
import android.text.TextUtils;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.TextView;
import com.ifeng.news2.R;
import com.ifeng.news2.widget.PlotAtlasImageView;

/**
 * @author liu_xiaoliang
 * 图集模块
 */
public class PlotAtlasModule extends PlotBaseModule {

  private TextView atlasText;
  private View plotAtlasTagIcon;
  private PlotAtlasImageView atlasIcon;

  public PlotAtlasModule(Context context) {
    super(context);
  }

  public PlotAtlasModule(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  @Override
  public void buildModule() {
    super.buildModule();

    String text = plotTopicBody.getIntro();
    String imageUrl = plotTopicBody.getThumbnail();

    if (TextUtils.isEmpty(text) && TextUtils.isEmpty(imageUrl)) {
      return;
    }

    View atlasView = inflater.inflate(R.layout.plot_atlas_layout, null);
    plotAtlasTagIcon = atlasView.findViewById(R.id.plot_atlas_tag_icon);
    atlasText = (TextView) atlasView.findViewById(R.id.plot_atlas_text);
    atlasIcon = (PlotAtlasImageView) atlasView.findViewById(R.id.plot_atlas_icon);
    

    if (TextUtils.isEmpty(text)) {
      atlasText.setVisibility(View.GONE);
    } else {
      atlasText.setText(text);
      atlasText.setVisibility(View.VISIBLE);
    }
    
    ArrayList<Extension> links = plotTopicBody.getLinks();
    if (null == links || links.size() == 0) {
      plotAtlasTagIcon.setVisibility(View.GONE);
    } else {
      plotAtlasTagIcon.setVisibility(View.VISIBLE);
    }
    
    //加载图集缩略图
    loadAtlasImage(imageUrl);

    atlasIcon.setOnClickListener(this);

    addView(atlasView);
  }

  private void loadAtlasImage(String imageUrl){

    getDefaultLoader().startLoading(new LoadContext<String, ImageView, Bitmap>(imageUrl, 
        atlasIcon, Bitmap.class, LoadContext.FLAG_CACHE_FIRST, context), new ImageDisplayer(){

      @Override
      public void prepare(ImageView img) {
        BitmapDrawable bd = (BitmapDrawable)getResources().getDrawable(drawable.plot_atlas_bg);
        Bitmap bm = bd.getBitmap();
        img.setImageBitmap(bm);
      }

      @Override
      public void display(ImageView img, BitmapDrawable bmp) {
        if (bmp == null) {// || bmp.isRecycled()){
          BitmapDrawable bd = (BitmapDrawable)getResources().getDrawable(drawable.plot_atlas_bg);
          Bitmap bm = bd.getBitmap();
          img.setImageBitmap(bm);
        } else {
          img.setImageDrawable(bmp);
        }
      }

      @Override
      public void display(ImageView img, BitmapDrawable bmp, Context ctx) {

        if (bmp == null) {// || bmp.isRecycled()){
          BitmapDrawable bd = (BitmapDrawable)getResources().getDrawable(drawable.plot_atlas_bg);
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
		
	}});
  }

  @Override
  public void onClick(View arg0) {
    super.onClick(arg0);
    ArrayList<Extension> links = plotTopicBody.getLinks();
    if (null == links || links.size() == 0) {
      //查看大图
      toGoPopupLightbox();
      return;
    } 
    
    Extension link = null;
    for (int i = 0; i < links.size(); i++) {
    	link = links.get(i);
    	if (null == link) {
    		continue;
    	}
    	link.setCategory(PlotTopicModuleActivity.topicId);
      if (IntentUtil.startActivityByExtension(context, links.get(i))) {
        //跳转成功
        return;
      }
    }
    
    //查看大图
    toGoPopupLightbox();
  }

  private void toGoPopupLightbox(){
    Intent intent = new Intent(context, PopupLightbox.class);
    intent.putExtra("imgUrl", plotTopicBody.getThumbnail());
    context.startActivity(intent);
    ((Activity) context).overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
  }


}
