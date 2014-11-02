package com.ifeng.news2.adapter;

import java.io.File;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;

import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.activity.SlideActivity;
import com.ifeng.news2.bean.SlideItem;
import com.ifeng.news2.util.PhotoModeUtil;
import com.ifeng.news2.util.PhotoModeUtil.PhotoMode;
import com.ifeng.news2.widget.zoom.PhotoView;
import com.ifeng.news2.widget.zoom.PhotoViewAttacher.OnViewTapListener;
import com.qad.form.BasePageAdapter;
import com.qad.loader.ImageLoader.ImageDisplayer;
import com.qad.loader.LoadContext;

public class SlideAdapter extends BasePageAdapter<SlideItem> implements
		OnViewTapListener {

	private PhotoMode mode;
	private static final int NO_LOAD = 1<<0;
	private static final int LOADING = 1<<1;
	private static final int LOAD_FAIL = 1<<2;
	
	public SlideAdapter(Context ctx) {	
		super(ctx);		
	}

	@Override
	protected int getResource() {
		return layout.widget_slide_item;
	}

	@Override
	protected void renderConvertView(int position, View convertView) {
		this.mode = PhotoModeUtil.getCurrentPhotoMode(ctx);
		SlideHolder holder = (SlideHolder) convertView.getTag();
		if(holder == null){
			holder = new SlideHolder();
			holder.slideImage = (PhotoView) convertView
					.findViewById(R.id.slide_image);
			holder.defaultImage = (ImageView) convertView.findViewById(R.id.default_image);			
			convertView.setTag(holder);			
		}
		
		//如果是无图模式，显示相应的默认底图，并且隐藏photoView视图
		if(mode == PhotoMode.INVISIBLE_PATTERN && !isImageExist(getItem(position).getImage())) {
		    holder.defaultImage.setVisibility(View.VISIBLE);
			holder.defaultImage.setTag(NO_LOAD);
			holder.defaultImage.setBackgroundResource(R.drawable.default_slide_no_load);				
			holder.slideImage.setVisibility(View.GONE);
			holder.defaultImage.setOnClickListener(new DefaultImageListener(holder, getItem(position)));
		} 
		//有图模式下，显示photoView视图，并且加载视图
		else {
			holder.defaultImage.setTag(LOADING);
			holder.defaultImage.setBackgroundResource(R.drawable.default_slide);	
			holder.slideImage.setVisibility(View.VISIBLE);
			holder.slideImage.setTag(R.drawable.default_slide, holder.defaultImage);
			LoadContext<String, ImageView, Bitmap> loadContext = new LoadContext<String, ImageView, Bitmap>(getItem(position)
					.getImage(), holder.slideImage, Bitmap.class,
					LoadContext.FLAG_CACHE_FIRST, ctx);
					
					loadContext.set4Slide(true);
					IfengNewsApp.getImageLoader().startLoading(loadContext
							, new ImageDisplayer() {
						
						@Override
						public void prepare(ImageView img) {
							if (null == img || null == img.getTag(R.drawable.default_slide)) {
								return;
							}
							((ImageView) img.getTag(R.drawable.default_slide))
									.setVisibility(View.VISIBLE);
							img.setVisibility(View.INVISIBLE);
						}
						
						@Override
						public void display(ImageView img, BitmapDrawable bmp) {
							if (null == img || null == img.getTag(R.drawable.default_slide)) {
								return;
							}
							 img.setVisibility(View.VISIBLE);
	                            if (bmp == null) {//||bmp.isRecycled()) {
	                                img.setBackgroundResource(R.drawable.default_slide);
	                            } else {
//	                            	Bitmap oldBmp = null;
//	                            	if (android.os.Build.VERSION.SDK_INT < 11) {
//	                    	            // HONEYCOMB之前Bitmap实际的Pixel Data是分配在Native Memory中。
//	                    	            // 首先需要调用reclyce()来表明Bitmap的Pixel Data占用的内存可回收
//	                    	            // call bitmap.recycle to make the memory available for GC
//	                            		Drawable oldDrawable = img.getDrawable();
//	                        			if (null != oldDrawable && oldDrawable instanceof BitmapDrawable) {
//	                        				oldBmp = ((BitmapDrawable)oldDrawable).getBitmap();
//	                        			}
//	                            	}
	                            	((ImageView)img.getTag(R.drawable.default_slide)).setVisibility(View.GONE);
	                            	img.setImageDrawable(bmp);
	                            	
//	                            	if (null != oldBmp && !oldBmp.isRecycled()) {
//     //                   				Log.w("Sdebug", "Slide recycle bitmap " + oldBmp.toString());
//                        				oldBmp.recycle();
//                        			}
	                            }
						}

                        @Override
                        public void display(ImageView img, BitmapDrawable bmp,
                                Context ctx) {
                        	display(img, bmp);
                        }

						@Override
						public void fail(ImageView img) {
							if (null == img || null == img.getTag(R.drawable.default_slide)) {
								return;
							}
						    ((ImageView)img.getTag(R.drawable.default_slide)).setVisibility(View.VISIBLE);
						}
					});
		}										
		holder.slideImage.setOnViewTapListener(this);
	
	}
	
	/**
	 * 判断图片是否已经保存在本地，如果本地已经保存图片，则会显示图片（优先级高于2G/3G无图模式判断）
	 * 
	 * @param url
	 * @return
	 */
	public static boolean isImageExist(String url){		
		File imgFile = IfengNewsApp.getResourceCacheManager().getCacheFile(url,
				true);
		if(imgFile != null && imgFile.exists()) {
			return true;
		}
		return false;
	}

	@Override
	public void onViewTap(View view, float x, float y) {
		((SlideActivity) view.getContext()).toggleFullScreen();
	}
	
	
	public static class SlideHolder {
		public PhotoView  slideImage;
		public ImageView  defaultImage;
	}
	
	private class DefaultImageListener implements OnClickListener {

		private SlideHolder holder;
		private SlideItem item;
		
		public DefaultImageListener(SlideHolder holder,SlideItem item){
			this.holder = holder;
			this.item = item;
		}
		
		@Override
		public void onClick(View v) {
			int tag = (Integer) v.getTag();			
			switch (tag) {
			case NO_LOAD:
				loadImage();
				break;
			case LOADING:
				break;
			case LOAD_FAIL:
				loadImage();
				break;
			default:
				break;
			}
		}
		
		private void loadImage() {
			IfengNewsApp.getImageLoader().startLoading(
					new LoadContext<String, ImageView, Bitmap>(item
							.getImage(), holder.slideImage, Bitmap.class,
							LoadContext.FLAG_CACHE_FIRST, ctx), new ImageDisplayer() {
								
								@Override
								public void prepare(ImageView img) {
									holder.defaultImage.setTag(LOADING);	
									holder.defaultImage.setBackgroundResource(R.drawable.default_slide_loading);
								}
								
								@Override
								public void display(ImageView img, BitmapDrawable bmp) {
									 if (bmp == null){//||bmp.isRecycled()) {
			                            	holder.defaultImage.setTag(LOAD_FAIL);	
											holder.defaultImage.setBackgroundResource(R.drawable.default_slide_load_fail);
			                            } else {
			                            	img.setVisibility(View.VISIBLE);
			                                img.setImageDrawable(bmp);			                            
			                            }
								}

		                        @Override
		                        public void display(ImageView img, BitmapDrawable bmp,
		                                Context ctx) {		                            
		                            if (bmp == null){//||bmp.isRecycled()) {
		                            	holder.defaultImage.setTag(LOAD_FAIL);	
										holder.defaultImage.setBackgroundResource(R.drawable.default_slide_load_fail);
		                            } else {
		                            	img.setVisibility(View.VISIBLE);
		                                img.setImageDrawable(bmp);
		                                if (null != ctx) {
		                                    // fade in
		                                    Animation fadeInAnimation = AnimationUtils.loadAnimation(ctx, R.anim.fade_in);
		                                    img.startAnimation(fadeInAnimation);
		                                }
		                            }
		                        }

								@Override
								public void fail(ImageView img) {
									holder.defaultImage.setTag(LOAD_FAIL);	
									holder.defaultImage.setBackgroundResource(R.drawable.default_slide_load_fail);
								}
							});
		}		
	}
		
 

}
