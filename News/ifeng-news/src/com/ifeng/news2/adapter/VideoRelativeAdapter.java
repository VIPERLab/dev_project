package com.ifeng.news2.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.bean.VideoRelativeInfo;
import com.qad.loader.ImageLoader.ImageDisplayer;
import com.qad.loader.LoadContext;

/**
 * 视频正文页相关视频adapter
 * @author chenxix
 *
 */
public class VideoRelativeAdapter extends BaseAdapter {

  private Context context;
  private LayoutInflater inflater;
  private ArrayList<VideoRelativeInfo> relativeInfos;

  public VideoRelativeAdapter(Context ctx) {
    this.context = ctx;
    inflater = LayoutInflater.from(context);
  }

  public void setVideoRelativeData(ArrayList<VideoRelativeInfo> infos) {
    this.relativeInfos = infos;
  }
  @Override
  public boolean isEnabled(int position) {
    // TODO Auto-generated method stub
    return super.isEnabled(position); 
  }

  @Override
  public int getCount() {
    // TODO Auto-generated method stub
    return relativeInfos.size();
  }

  @Override
  public Object getItem(int position) {
    // TODO Auto-generated method stub
    return relativeInfos.get(position);
  }

  @Override
  public long getItemId(int position) {
    // TODO Auto-generated method stub
    return 0;
  }

  @Override
  public View getView(int position, View convertView, ViewGroup parent) {
    // TODO Auto-generated method stub
    VideoRelativeHolder holder = null;
    if (convertView != null && !(convertView instanceof LinearLayout)) {
      holder = (VideoRelativeHolder) convertView.getTag();
    } else {
      convertView = inflater.inflate(R.layout.video_detail_relative_list_item, null);
      holder = new VideoRelativeHolder() ; 
      holder.relativeHeadImg = (ImageView) convertView.findViewById(R.id.video_relative_item_head);
      holder.relativeChannleTxt = (TextView) convertView.findViewById(R.id.video_relative_item_channel) ;
      holder.relativeDateTxt = (TextView) convertView.findViewById(R.id.video_relative_item_date);
      holder.relativeTitleTxt = (TextView) convertView.findViewById(R.id.video_relative_item_title);
      convertView.setTag(holder);
    }
    holder.videoRelativeInfo = (VideoRelativeInfo) getItem(position);
    renderItemView( holder , position );
    
    return convertView;
  }

  private void renderItemView(VideoRelativeHolder holder, int position) {
    // TODO Auto-generated method stub
    VideoRelativeInfo videoRelativeInfo = (VideoRelativeInfo) getItem(position);
    if(videoRelativeInfo != null){
      if(TextUtils.isEmpty(videoRelativeInfo.getSmallImgURL())){
        renderHeadImg(videoRelativeInfo.getImgURL() , holder);
      }else{
        renderHeadImg(videoRelativeInfo.getSmallImgURL() , holder);
      }
      holder.relativeChannleTxt.setText( videoRelativeInfo.getColumnName() );
      holder.relativeTitleTxt.setText(videoRelativeInfo.getTitle() );
      String videoLength = videoRelativeInfo.getVideoLength() ;
      holder.relativeDateTxt.setText(videoLength.substring(videoLength.indexOf(":")+1));
      
    }
    
  }
  
  //绘制图片
  private void renderHeadImg(String imgURL,VideoRelativeHolder holder) {
    // TODO Auto-generated method stub
    IfengNewsApp.getImageLoader().startLoading(new LoadContext<String, ImageView, Bitmap>(imgURL, 
        holder.relativeHeadImg, Bitmap.class, LoadContext.FLAG_CACHE_FIRST, context), new ImageDisplayer(){

          @Override
          public void prepare(ImageView img) {
            // TODO Auto-generated method stub
            BitmapDrawable bd = (BitmapDrawable)context.getResources().getDrawable(drawable.video_relative_list_item_head);
            Bitmap bm = bd.getBitmap();
            img.setImageBitmap(bm);
          }

          @Override
          public void display(ImageView img, BitmapDrawable bmp) {
            // TODO Auto-generated method stub
            if (bmp == null){// || bmp.isRecycled()){
              BitmapDrawable bd = (BitmapDrawable)context.getResources().getDrawable(drawable.video_relative_list_item_head);;
              Bitmap bm = bd.getBitmap();
              img.setImageBitmap(bm);
            } else {
              img.setImageDrawable(bmp);
            }
          }

          @Override
          public void display(ImageView img, BitmapDrawable bmp, Context ctx) {
            // TODO Auto-generated method stub
            if (bmp == null){// || bmp.isRecycled()){
              BitmapDrawable bd = (BitmapDrawable)context.getResources().getDrawable(drawable.video_relative_list_item_head);;
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
            // TODO Auto-generated method stub
            
          }
    });
  }
  

  public static class VideoRelativeHolder {
    public VideoRelativeInfo videoRelativeInfo;
    public ImageView relativeHeadImg ; 
    public TextView relativeTitleTxt ; 
    public TextView relativeDateTxt ; 
    public TextView relativeChannleTxt ; 
  }

}
