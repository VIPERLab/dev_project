package com.ifeng.news2.adapter;

import android.graphics.drawable.BitmapDrawable;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import com.qad.loader.ImageLoader.ImageDisplayer;

import android.view.View.OnClickListener;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Bitmap;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;

import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.id;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.sport_live.SportMainActivity;
import com.ifeng.news2.sport_live.entity.SportFactItem;
import com.ifeng.news2.sport_live.util.SportFactViewHolder;
import com.qad.form.BasePageAdapter;
import com.qad.loader.LoadContext;

public class SportLiveFactAdapter extends BasePageAdapter<SportFactItem>{
		
	//直播主页面
	public static final int FACT_TYPE = 0x0000;
	
	//毒舌页面
	public static final int POISONOUS_TYPE = 0x0001;
	
	private int type;
	//图标样式
	/**
	 * 用户图标
	 */
	public static final String ICON_TYPE_USER = "user";                 
	/**
	 * 毒蛇
	 */
	public static final String ICON_TYPE_DUSHE = "dushe";
	/**
	 * 主持人蓝图标
	 */
	public static final String ICON_TYPE_HOST_BULE = "liver_blue";
	/**
	 * 主持人黄图标
	 */
	public static final String ICON_TYPE_HOST_YELLOW = "liver_yellow";
	
	//内容样式
	/**
	 * 直播
	 */
	private static final String CONTENT_TYPE_LIVE = "live";
	/**
	 * 毒蛇
	 */
	private static final String CONTENT_TYPE_DUSHE = "dushe";
	/**
	 * 用户评论
	 */
	private static final String CONTENT_TYPE_RECOMMEND = "recommend";
	/**
	 * 用户回复支持人
	 */
	private static final String CONTENT_TYPE_REPLY = "reply";
	
	private static SportFactViewHolder viewHolder = null;
	
	public SportLiveFactAdapter(Context ctx) {
		super(ctx);
		type = FACT_TYPE;
	}
	
	public SportLiveFactAdapter(Context ctx,int type){
		super(ctx);
		this.type = type;
	}

	@Override
	protected int getResource() {
		return layout.sport_live_fact_item;
	}

	@Override
	protected void renderConvertView(int position, View convertView) {
		render(position, convertView, items.get(position));
	}
	
	private void render(int position, View convertView, SportFactItem item){
		viewHolder = (SportFactViewHolder) convertView.getTag();
		if (viewHolder == null) {
			viewHolder = SportFactViewHolder.create(convertView);
			convertView.setTag(viewHolder);
		}
		 
		//渲染左侧图标
		rendIcon(item);
		//渲染右侧内容
		rendConent(item);
		//渲染节数
		rendSignsTag(position);
	}
	
	
	private void rendIcon(SportFactItem item){
		//左侧图标
		int leftIcon = -1;
		String leftIconName = "";
		if (ICON_TYPE_USER.equals(item.getTitle_img())) {
			leftIcon = drawable.sport_user_icon;
			leftIconName = "网友";
		} else if (ICON_TYPE_HOST_BULE.equals(item.getTitle_img())) {
			leftIcon = drawable.sport_host_no1_icon;
			leftIconName = item.getLiver();
		} else if (ICON_TYPE_HOST_YELLOW.equals(item.getTitle_img())) {
			leftIcon = drawable.sport_host_no2_icon;
			leftIconName = item.getLiver();
		} else if (ICON_TYPE_DUSHE.equals(item.getTitle_img())) {
			leftIcon = drawable.sport_hot_comment_icon;
			//TODO 毒蛇名字？
			leftIconName = "毒舌";
		} else {
			//默认给一个主持人一图标
			leftIcon = drawable.sport_user_icon;
		}
		viewHolder.sportIcon.setBackgroundResource(leftIcon);
		viewHolder.sportIconName.setText(leftIconName);
		//SportLiveFactFragment要使用到数据
		viewHolder.item = item;
	} 
	
	private void rendConent(final SportFactItem item){
		//渲染右侧内容
		viewHolder.title.setVisibility(View.GONE);
		viewHolder.sportFactIconModule.setVisibility(View.GONE);
		viewHolder.sportLiveReplyModule.setVisibility(View.GONE);
		viewHolder.title.setTextColor(ctx.getResources().getColor(R.color.sport_title_color));
		
		if (CONTENT_TYPE_LIVE.equals(item.getType())) {
			viewHolder.sportLiveReplyModule.setVisibility(View.GONE);
			//普通实况
			if (TextUtils.isEmpty(item.getPicurl())) {
				viewHolder.sportFactIconModule.setVisibility(View.GONE);
			} else {
				//TODO 设置实况图片
				viewHolder.sportFactIconModule.setVisibility(View.VISIBLE);
				//download fact icon
				IfengNewsApp.getImageLoader().startLoading(
						new LoadContext<String, ImageView, Bitmap>(item
								.getPicurl(), viewHolder.sportFactIcon,
								Bitmap.class, LoadContext.FLAG_CACHE_FIRST, ctx),new ImageDisplayer(){

				          @Override
				          public void prepare(ImageView img) {
				            BitmapDrawable bd = (BitmapDrawable)ctx.getResources().getDrawable(drawable.sport_fact_icon_bg);
				            Bitmap bm = bd.getBitmap();
				            img.setImageBitmap(bm);
				            item.setPicIsShow(false);
				          }

				          @Override
				          public void display(ImageView img, BitmapDrawable bmp) {
				            if (bmp == null){// || bmp.isRecycled()){
				              BitmapDrawable bd = (BitmapDrawable)ctx.getResources().getDrawable(drawable.sport_fact_icon_bg);
				              Bitmap bm = bd.getBitmap();
				              img.setImageBitmap(bm);
				            } else {
				              img.setImageDrawable(bmp);
				              item.setPicIsShow(true);
				            }
				          }

				          @Override
				          public void display(ImageView img, BitmapDrawable bmp, Context ctx) {

				            if (bmp == null){// || bmp.isRecycled()){
				              BitmapDrawable bd = (BitmapDrawable)ctx.getResources().getDrawable(drawable.sport_fact_icon_bg);
				              Bitmap bm = bd.getBitmap();
				              img.setImageBitmap(bm);
				            } else {
				              img.setImageDrawable(bmp);
				              if (null != ctx) {
				                // fade in 动画效果
				                Animation fadeInAnimation = AnimationUtils.loadAnimation(ctx, R.anim.fade_in);
				                img.startAnimation(fadeInAnimation);
				              }
				              item.setPicIsShow(true);
				            }
				          }

				        @Override
				        public void fail(ImageView img) {
				            
				        }});
				viewHolder.sportFactIcon.setOnClickListener(new View.OnClickListener() {

					@Override
					public void onClick(View v) {
						if (item.isPicIsShow()) {
						  //幻灯
						  showBigPictureDialog(item);
                        }
					}
				});
			}

			viewHolder.title.setVisibility(View.VISIBLE);
			viewHolder.title.setText(item.getContent());
		} else if (CONTENT_TYPE_REPLY.equals(item.getType())) {
			//主持人回复用户
		    //内容为空的话不设置其显示，其他类型不处理
		    if (!TextUtils.isEmpty(item.getContent()) && !TextUtils.isEmpty(item.getContent().trim())) {
		      viewHolder.title.setVisibility(View.VISIBLE);
		      viewHolder.title.setText(item.getContent());
            }
			
			if (null == item.getExt()) 
				return;
			//设置回复内容
			viewHolder.sportLiveReplyModule.setVisibility(View.VISIBLE);
			viewHolder.sportLiveReplyModule.setBackgroundResource(drawable.sport_reply_bg);
			viewHolder.replyModuleName.setText(item.getExt().getUsername());
			viewHolder.replyModuleToName.setText(item.getLiver());
			viewHolder.replyModuleContent.setText(item.getExt().getContent());
		}  else if (CONTENT_TYPE_DUSHE.equals(item.getType())) {
			//毒蛇
			viewHolder.title.setVisibility(View.VISIBLE);
			viewHolder.title.setText(item.getContent());			
			
			if (type == POISONOUS_TYPE) {
				viewHolder.title.setTextColor(ctx.getResources().getColor(R.color.sport_title_color));
			} else {
				viewHolder.title.setTextColor(ctx.getResources().getColor(R.color.sport_dushe_color));//红色
			}
		} else if (CONTENT_TYPE_RECOMMEND.equals(item.getType())) {
			//用户发言
			if (null == item.getExt()) {
				return;
			}
			viewHolder.sportLiveReplyModule.setVisibility(View.VISIBLE);
			viewHolder.sportLiveReplyModule.setBackgroundColor(ctx.getResources().getColor(
					R.color.sport_bg_color));
			//0 -- 代表未登陆用户
			if ("0".equals(item.getExt().getUserid())) {
				viewHolder.replyModuleName.setTextColor(ctx.getResources().getColor(R.color.loading_fail_font));
				viewHolder.replyModuleName.setText(item.getExt().getUsername());
			} else {
				viewHolder.replyModuleName.setTextColor(ctx.getResources().getColor(R.color.sport_live_blue));
				viewHolder.replyModuleName.setText(item.getExt().getUsername());
				viewHolder.replyModuleName.setOnClickListener(new View.OnClickListener() {
					
					@Override
					public void onClick(View v) {
						((SportMainActivity)ctx).speech(item.getExt().getUsername(), item.getExt().getUserid());
					}
				});
			}
			
			//对 xx 说
			if (TextUtils.isEmpty(item.getExt().getTousername())) {
				viewHolder.replyModuleTo.setVisibility(View.GONE);
				viewHolder.replyModuleSay.setVisibility(View.GONE);
				viewHolder.replyModuleToName.setVisibility(View.GONE);
			} else {
				viewHolder.replyModuleTo.setVisibility(View.VISIBLE);
				viewHolder.replyModuleSay.setVisibility(View.VISIBLE);
				viewHolder.replyModuleToName.setVisibility(View.VISIBLE);
				
				viewHolder.replyModuleToName.setTextColor(ctx.getResources().getColor(
						R.color.sport_live_blue));
				viewHolder.replyModuleToName.setText(item.getExt().getTousername());
				viewHolder.replyModuleToName.setOnClickListener(new View.OnClickListener() {
					
					@Override
					public void onClick(View v) {
						((SportMainActivity)ctx).speech(item.getExt().getTousername(), item.getExt().getTouserid());						
					}
				});
			}
			viewHolder.replyModuleTime.setText(item.getTime());
			viewHolder.replyModuleContent.setText(item.getExt().getContent());
		} else {
			//默认
		}
		
		if (CONTENT_TYPE_REPLY.equals(item.getType())) {
			//回复用户模块   20 -- px
			viewHolder.replyModuleTime.setVisibility(View.GONE);
			viewHolder.sportLiveReplyModule.setPadding(20, 20, 20, 20);
		} else {
			//归位
			viewHolder.replyModuleTime.setVisibility(View.VISIBLE);
			viewHolder.sportLiveReplyModule.setPadding(0, 0, 0, 0);
		}
		
	}
	
	private void rendSignsTag(int position){
		viewHolder.sportFactSigns.setVisibility(View.GONE);
		if(type == FACT_TYPE){
			if (0 == position) {
				if (TextUtils.isEmpty(items.get(0).getSection())) {
					viewHolder.sportFactSigns.setVisibility(View.GONE);
				} else {
					viewHolder.sportFactSigns.setVisibility(View.VISIBLE);
					viewHolder.sportFactSignsPrompt.setText(items.get(position).getSection());
				}
			} else {
				if (null != items.get(position) && !items.get(position).getSection().equals(items.get(position - 1).getSection())) {
					viewHolder.sportFactSigns.setVisibility(View.VISIBLE);
					viewHolder.sportFactSignsPrompt.setText(items.get(position).getSection());
				} else {
					viewHolder.sportFactSigns.setVisibility(View.GONE);
				}
			}
		}		
	}

	private void showBigPictureDialog(SportFactItem item){
		final Dialog dlg = new Dialog(ctx, R.style.shareDialogTheme);
		LinearLayout layout = (LinearLayout) LayoutInflater.from(ctx).inflate(R.layout.sport_big_pictrue_dialog, null);
		ImageView bigPictrue = (ImageView) layout.findViewById(id.sport_pictrue_dialog);
		bigPictrue.setOnClickListener(new OnClickListener() {
		  
		  @Override
		  public void onClick(View v) {
		    dlg.dismiss();
		  }
		});
		IfengNewsApp.getImageLoader().startLoading(
				new LoadContext<String, ImageView, Bitmap>(item.getPicurl(), bigPictrue,
						Bitmap.class, LoadContext.FLAG_CACHE_FIRST, ctx));
		LayoutParams params = new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT);
		layout.setLayoutParams(params);
		Window w = dlg.getWindow();
		WindowManager.LayoutParams lp = w.getAttributes();
		lp.gravity = Gravity.CENTER;
		dlg.onWindowAttributesChanged(lp);
		dlg.setCanceledOnTouchOutside(true);
		dlg.setContentView(layout);
		dlg.show();
	}

}
