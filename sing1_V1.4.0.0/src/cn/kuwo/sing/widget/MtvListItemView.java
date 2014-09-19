package cn.kuwo.sing.widget;

import java.util.List;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.display.SimpleBitmapDisplayer;

import cn.kuwo.framework.context.AppContext;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.MTV;
import cn.kuwo.sing.util.AnimateFirstDisplayListener;
import android.content.Context;
import android.graphics.Bitmap;
import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

public class MtvListItemView extends RelativeLayout {
	private Context mContext;
	private DisplayImageOptions options;
	
	public MtvListItemView(Context context) {
		this(context, null);
	}

	public MtvListItemView(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
	}

	public MtvListItemView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		mContext = context;
		options = new DisplayImageOptions.Builder()
		.showStubImage(R.drawable.image_loading_small)
		.showImageForEmptyUri(R.drawable.image_loading_small)
		.showImageOnFail(R.drawable.image_loading_small)
		.cacheInMemory()
		.cacheOnDisc()
		.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2) // default
		.bitmapConfig(Bitmap.Config.ARGB_8888) // default
		.displayer(new SimpleBitmapDisplayer())
		.build();
	}

	public void initView(List<MTV> data, int from){
		LinearLayout ll = new LinearLayout(mContext);
		ll.setOrientation(LinearLayout.HORIZONTAL);
		RelativeLayout.LayoutParams llParams = new RelativeLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
		
		int imageWidth = AppContext.SCREEN_WIDTH/3;
		int imageHeight = AppContext.SCREEN_WIDTH/3;
		RelativeLayout.LayoutParams param = new RelativeLayout.LayoutParams(imageWidth, imageHeight);
		
		for (int i=0; i<data.size(); i++){
			MTV mtv = data.get(i);
			KuwoImageView view = new KuwoImageView(mContext, from, mtv.type, mtv.url, mtv.kid, mtv.uname, mtv.title, false); 
			ll.addView(view, param);
			ImageLoader.getInstance().displayImage(mtv.userpic, view.iv, options, new AnimateFirstDisplayListener());
		}		
		
		this.addView(ll, llParams);
	}

}
