package com.qad.loader;

import java.io.File;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;

import com.qad.cache.ResourceCacheManager;

public class ImageLoader {

	private static LoaderExecutor executor = null;
	private static ImageLoader instance = new ImageLoader();
	private ImageDisplayer defaultDisplayer;
	private Context appContext = null;

	public static ImageLoader getInstance() {
		return instance;
	}

	private ImageLoader() {
		executor = new LoaderExecutor(this.getClass().getSimpleName());
	}

	/**
	 * Retrive the ResourceCacheManager object of LoaderImpl
	 * 
	 * @return ResourceCacheManager object of LoaderImpl
	 */
	public static final ResourceCacheManager getResourceCacheManager() {
		
		return ResourceCacheManager.getInstance();
	}
	
	public Context getAppContext() {
		return appContext;
	}

	public void setAppContext(Context appContext) {
		this.appContext = appContext;
	}

	public ImageDisplayer getDefaultImageDisplayer() {
		return defaultDisplayer;
	}

	public void setDefaultImageDisplayer(ImageDisplayer displayer) {
		if (displayer == null)
			throw new NullPointerException();
		this.defaultDisplayer = displayer;
	}

	/**
	 * Start loading resource, return a file path to the loaded Bitmap
	 * asynchronizly by calling the LoadListener if there is no cache, or
	 * synchronizly return the file path if already exist.
	 * 
	 * @param context
	 *            LoadContext for loading task
	 */
	@SuppressWarnings("unchecked")
	public void startDownload(LoadContext<?, ?, String> context) {
		if (context == null)
			throw new IllegalArgumentException("Failed in ImageLoader, caused by: Invalid LoadContext");

		File file = getResourceCacheManager().getCacheFile(context.getParam().toString(), true);

		if (file != null) {
			context.setResult(file.getAbsolutePath());
			((LoadListener<String>) context.getTarget()).loadComplete(context);
		} else {
			executor.execute(context, LoaderExecutor.EXECUTE_ORDER.FIFO_ORDER);
		}
	}

	/**
	 * Start loading resource and display the loaded Bitmap by the displayer's
	 * callbacks
	 * 
	 * @param context
	 *            LoadContext for loading task
	 * @param displayer
	 *            ImageDisplayer to display the loaded Bitmap
	 */
	public void startLoading(LoadContext<?, ?, Bitmap> context,
			ImageDisplayer displayer) {
		if (context == null || context.getTarget() == null)
			throw new IllegalArgumentException(
					"Failed in ImageLoader, caused by: Invalid LoadContext");
		Object param = context.getParam();
		defaultDisplayer = displayer != null ? displayer : new DefaultImageDisplayer(null);
		((ImageView) context.getTarget()).setTag(new Pack(null == param ? null : param.toString(), defaultDisplayer));
		BitmapDrawable drawable = null;
		defaultDisplayer.prepare((ImageView) context.getTarget());
		if(!TextUtils.isEmpty(null == param? null : param.toString())){
			 drawable = getResourceCacheManager().getFromMemCache(context.getParam().toString());
		}else{
			defaultDisplayer.fail((ImageView) context.getTarget());
			return;
		}
		if (drawable != null) {// && !bitmap.isRecycled()) {
			defaultDisplayer.display((ImageView) context.getTarget(), drawable);
		} else {
			context.setFlag(LoadContext.FLAG_CACHE_FIRST);
			executor.execute(context, LoaderExecutor.EXECUTE_ORDER.FILO_ORDER);
		}
	}

	/**
	 * Equivalent to call {@link #startLoading(LoadContext, ImageDisplayer)}
	 * with ImageDisplayer as null.
	 * 
	 * @param context
	 *            LoadContext for loading task
	 */
	public void startLoading(LoadContext<?, ?, Bitmap> context) {
		startLoading(context, null);
	}

	public void destroy(boolean now) {
	}

	/**
	 * 回调处理预加载、加载完毕如何显示
	 * 
	 * @author 13leaf
	 * 
	 */
	public interface ImageDisplayer {
		/**
		 * 通知预备
		 * 
		 * @param img
		 */
		void prepare(ImageView img);

		/**
		 * 通知下载完毕,显示图片
		 * 
		 * @param img
		 * @param bmp
		 */
		void display(ImageView img, BitmapDrawable bmp);
		
		void display(ImageView img, BitmapDrawable bmp, Context ctx);
		
		/**
		 * 通知图片下载失败
		 * 
		 * @param img
		 */
		void fail(ImageView img);
	}
	
	/**
	 * 当图片加载失败的时候显示坏图
	 * 
	 * @author SunQuan
	 *
	 */
	public static class DefaultImageDisplyerWithFial extends DefaultImageDisplayer{

		private final Drawable brokenDrawable;
		public DefaultImageDisplyerWithFial(Drawable drawable,Drawable brokenDrawable) {
			super(drawable);
			this.brokenDrawable = brokenDrawable;
		}
		
		@Override
		public void fail(ImageView img) {
			img.setImageDrawable(brokenDrawable);
		}
		
	}

	/**
	 * 未加载或加载失败显示默认图片
	 * 
	 * @author 13leaf
	 * 
	 */
	public static class DefaultImageDisplayer implements
			ImageLoader.ImageDisplayer {
		private final Drawable defaultDrawable;

		public DefaultImageDisplayer(Drawable drawable) {
			this.defaultDrawable = drawable;
		}

		@Override
		public void prepare(ImageView img) {
			img.setImageDrawable(defaultDrawable);
		}

		@Override
		public void display(ImageView img, BitmapDrawable bmp) {
			if (img.getVisibility() == View.VISIBLE) {
				if (bmp == null) {//||bmp.isRecycled()) {
					img.setImageDrawable(defaultDrawable);
				}
				else {
					img.setImageDrawable(bmp);
				}
			}
		}

        @Override
        public void display(ImageView img, BitmapDrawable bmp, Context ctx) {
            
            if (bmp == null) {//||bmp.isRecycled()) {
                img.setImageDrawable(defaultDrawable);
            }
            else {
                img.setImageDrawable(bmp);
                if (null != ctx) {
                    // fade in 动画效果
                    Animation fadeInAnimation = AnimationUtils.loadAnimation(ctx, ctx.getResources().getIdentifier("fade_in", "anim", ctx.getPackageName()));
                    img.startAnimation(fadeInAnimation);
                }
            }
        }

		@Override
		public void fail(ImageView img) {
			//do nothing 以后如果有添加坏图的需求，可以再处理
		}
	}

	/**
	 * 未加载或加载失败不显示任何图片
	 * 
	 * @author 13leaf
	 * 
	 */
	public static class DisplayShow implements ImageLoader.ImageDisplayer {

		private boolean shouldHide;

		public DisplayShow() {
			shouldHide = false;
		}

		public DisplayShow(boolean shouldHide) {
			this.shouldHide = shouldHide;
		}

		@Override
		public void prepare(ImageView img) {
			img.setImageBitmap(null);
			if (shouldHide)
				img.setVisibility(View.GONE);
		}

		@Override
		public void display(ImageView img, BitmapDrawable bmp) {
			if (bmp == null) {// || bmp.isRecycled()) {
				img.setImageDrawable(null);
				if (shouldHide)
					img.setVisibility(View.GONE);
			} else {
				if (shouldHide)
					img.setVisibility(View.VISIBLE);
				img.setImageDrawable(bmp);
			}
		}

        @Override
        public void display(ImageView img, BitmapDrawable bmp, Context ctx) {
            if (bmp == null) {// || bmp.isRecycled()) {
                img.setImageDrawable(null);
                if (shouldHide)
                    img.setVisibility(View.GONE);
            } else {
                if (shouldHide)
                    img.setVisibility(View.VISIBLE);
                img.setImageDrawable(bmp);
                // fade in 动画效果
                Animation fadeInAnimation = AnimationUtils.loadAnimation(ctx, ctx.getResources().getIdentifier("fade_in", "anim", ctx.getPackageName()));
                img.startAnimation(fadeInAnimation);
            }
        }

		@Override
		public void fail(ImageView img) {
			// TODO Auto-generated method stub			
		}
	}

	public class Pack {
		private String param = null;
		private ImageDisplayer displayer = null;

		public Pack(String param, ImageDisplayer displayer) {
			this.setParam(param);
			this.setDisplayer(displayer);
		}

		public String getParam() {
			return param;
		}

		public void setParam(String param) {
			this.param = param;
		}

		public ImageDisplayer getDisplayer() {
			return displayer;
		}

		public void setDisplayer(ImageDisplayer displayer) {
			this.displayer = displayer;
		}
		
	}
}
