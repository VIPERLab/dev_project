package cn.kuwo.sing.widget;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.RelativeLayout;
import android.widget.TextView;
import cn.kuwo.sing.R;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.ui.activities.LocalMainActivity;
import cn.kuwo.sing.ui.activities.SquareShowActivity;
import cn.kuwo.sing.util.DensityUtils;
import cn.kuwo.sing.util.DialogUtils;

/**
 * 
 * @author wangming
 * 
 * 自定义ImageView
 *
 */
public class KuwoImageView extends FrameLayout {
	private final String TAG = "KuwoImageView";
	private Context mContext;
	private int mFlag;
	public ImageView iv;
	
	public KuwoImageView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}
	
	public KuwoImageView(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
	}
	
	public KuwoImageView(Context context, int flag, String type, String url, String id, String uname, String title, boolean isBigImage) {
		this(context, null);
		mContext = context;
		mFlag = flag;
		initView(type, url, id, uname, title, isBigImage);
	}
	
	public void setImageBitmap(Bitmap bitmap) {
		iv.setImageBitmap(bitmap);
	}
	
	private void initView(final String type, final String url, final String id, final String uname, final String title, boolean isBigImage) {
		iv = new ImageView(mContext);
		iv.setId(Integer.parseInt(id));
		iv.setPadding(2, 2, 2, 2);
		iv.setScaleType(ScaleType.FIT_XY);
		iv.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// id
				if(mFlag == Constants.FLAG_SUPER_STAR) {
					Intent localIntent = new Intent(mContext, LocalMainActivity.class); //个人主页
					localIntent.putExtra("uname", uname);
					localIntent.putExtra("flag", "otherHome");
					localIntent.putExtra("uid", id);
					mContext.startActivity(localIntent);
				}else {
					if(!TextUtils.isEmpty(type) && type.equals("1")) {
						Intent intent = new Intent(mContext, SquareShowActivity.class); //广场活动
						intent.putExtra("activityUrl", url);
						intent.putExtra("title", title);
						mContext.startActivity(intent);
					}else {
						MTVBusiness mb = new MTVBusiness(mContext);
						mb.playMtv(id);
					}
				}
			}

			private void showLoginDialog(String tip, final String id) {
				DialogUtils.alert(mContext, new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						switch (which) {
						case -1:
							//ok
							MTVBusiness mb = new MTVBusiness(mContext);
							mb.playMtv(id);
							dialog.dismiss();
							break;
						case -2:
							//cancel
							dialog.dismiss();
							break;
						default:
							break;
						}
						
					}
				} , R.string.logout_dialog_title, R.string.dialog_ok, R.string.dialog_cancel, -1, tip);
			}
		});
		RelativeLayout rl = new RelativeLayout(mContext);
		FrameLayout.LayoutParams rlParam = new FrameLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
		TextView unameTV = new TextView(mContext);
		unameTV.setBackgroundColor(mContext.getResources().getColor(R.color.kw_image_view_text_bg));
		unameTV.setId(Integer.parseInt(id)+1);
		unameTV.setPadding(5, 0, 0, 0);
		unameTV.setText(uname);
		unameTV.setSingleLine(true);
		unameTV.setTextColor(Color.WHITE);
		unameTV.setTextAppearance(mContext, R.style.shadowSingerName);
		unameTV.setTextSize(DensityUtils.px2sp(mContext, DensityUtils.dip2px(mContext, 12)));
		RelativeLayout.LayoutParams unameParam = new RelativeLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
		unameParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE);
		
		TextView titleTV = new TextView(mContext);
		titleTV.setTextAppearance(mContext, R.style.shadowSongName);
		if(!TextUtils.isEmpty(type) && type.equals("1")) {
			titleTV.setText("");
		}else {
			titleTV.setText(title);
		}
		if(!TextUtils.isEmpty(title))
			titleTV.setBackgroundColor(mContext.getResources().getColor(R.color.kw_image_view_text_bg));
		titleTV.setSingleLine(true);
		titleTV.setPadding(5, 0, 0, 0);
		titleTV.setTextColor(Color.WHITE);
		titleTV.setTextSize(DensityUtils.px2sp(mContext, DensityUtils.dip2px(mContext, 14f)));
		RelativeLayout.LayoutParams titleParam = new RelativeLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
		titleParam.addRule(RelativeLayout.ABOVE, unameTV.getId());
		
		rl.addView(unameTV, unameParam);
		rl.addView(titleTV, titleParam);
		addView(iv);
		addView(rl, rlParam);
	}
	


}
