package com.ifeng.news2.adapter;

import java.util.ArrayList;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.ImageView;
import android.widget.TextView;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.activity.PlayVideoActivity;
import com.ifeng.news2.activity.PopupLightbox;
import com.ifeng.news2.advertise.AdDetailActivity;
import com.ifeng.news2.bean.PhotoAndTextLiveItemBean;
import com.ifeng.news2.share.ShareAlertBig;
import com.ifeng.news2.share.WXHandler;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.ReadUtil;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.share.util.NetworkState;
import com.qad.form.BasePageAdapter;
import com.qad.loader.LoadContext;

/**
 * 图文直播列表的adapter
 * 
 * @author SunQuan:
 * @version 创建时间：2013-8-22 下午2:55:19 类说明
 */

public class PhotoAndTextLiveAdapter extends
		BasePageAdapter<PhotoAndTextLiveItemBean> {

	// 服务器返回的图片对应的屏幕分辨率
	public static final int CONFIRMEDWIDTH = 640;
	// 分享的地址
	public static final String DIRECT_SEEDING_SHARE = "http://i.ifeng.com/Emotion_sx.f?liveId=";

	// 屏幕宽 高
	private int screenWidth;

	public PhotoAndTextLiveAdapter(Context ctx) {
		super(ctx);
		screenWidth = ((Activity) ctx).getWindowManager().getDefaultDisplay()
				.getWidth();
	}

	@Override
	protected int getResource() {
		return R.layout.direct_seeding_list_item;
	}

	@Override
	protected void renderConvertView(int position, View convertView) {
		ViewHolder holder = ViewHolder.create(convertView);
		PhotoAndTextLiveItemBean item = getItem(position);
		holder.time.setText(item.getCreate_date());
		// item.setTitle("凤凰新闻客户端，天天有聊。。");
		// if(position > 5){
		// item.setTitle_link("http://www.baidu.com");
		// }

		if (!TextUtils.isEmpty(item.getTitle())) {
			holder.title.setVisibility(View.VISIBLE);			
			holder.title.setText(item.getTitle());
			if (!TextUtils.isEmpty(item.getTitle_link())) {
				holder.title.setTextColor(item.getTitleColor());
			} else {
				// 如果没有链接，默认标题的颜色
				holder.title.setTextColor(ctx.getResources().getColor(
						R.color.direct_seeding_title_default));
			}

		} else {
			holder.title.setVisibility(View.GONE);
		}

		holder.content.setText(item.getContent());

		// DirectSeedingItemImg img = new DirectSeedingItemImg();
		// img.setThumb_height("500");
		// img.setOriginal_url("http://res.ichat.3g.ifeng.com/img/lchat_live_1373102226.6375.png");
		// img.setThumb_url("http://res.ichat.3g.ifeng.com/img/lchat_live_1373102226.6375.png");
		// item.setImg(img);
		//
		// DirectSeedingItemVideo video = new DirectSeedingItemVideo();
		// video.setVideo_image("http://res.ichat.3g.ifeng.com/img/lchat_live_1373102226.6375.png");
		// item.setVideo(video);
		//item.setVideo(null);

		// 如果有视频，优先展示视频
		if (item.getVideo() != null) {
			holder.videoWrapper.setVisibility(View.VISIBLE);
			holder.imageWrapper.setVisibility(View.GONE);
			IfengNewsApp.getImageLoader().startLoading(
					new LoadContext<String, ImageView, Bitmap>(item.getVideo()
							.getVideo_image(), holder.videoImage, Bitmap.class,
							LoadContext.FLAG_CACHE_FIRST, ctx));
		} else if (item.getImg() != null) {
			holder.imageWrapper.setVisibility(View.VISIBLE);
			holder.videoWrapper.setVisibility(View.GONE);
			int height;
			try {
				height = Integer.parseInt(item.getImg().getThumb_height());
			} catch (NumberFormatException e) {
				height = 0;
			}
			if (height != 0) {
				LayoutParams lp = holder.imageWrapper.getLayoutParams();
				height = Math.round(height
						* ((float) screenWidth / CONFIRMEDWIDTH));
				lp.height = height;
				// 重新定义视图的宽高根据服务器返回的数据
				holder.imageWrapper.setLayoutParams(lp);
				IfengNewsApp.getImageLoader()
						.startLoading(
								new LoadContext<String, ImageView, Bitmap>(item
										.getImg().getThumb_url(), holder.image,
										Bitmap.class,
										LoadContext.FLAG_CACHE_FIRST, ctx));
			}
		} else {
			holder.imageWrapper.setVisibility(View.GONE);
			holder.videoWrapper.setVisibility(View.GONE);

		}

		// 设置监听
		setListener(holder, item);
	}

	private void setListener(ViewHolder holder, PhotoAndTextLiveItemBean item) {
		holder.title
				.setOnClickListener(new DirectSeedingListener(holder, item));
		holder.imageWrapper.setOnClickListener(new DirectSeedingListener(
				holder, item));
		holder.videoWrapper.setOnClickListener(new DirectSeedingListener(
				holder, item));
		holder.share
				.setOnClickListener(new DirectSeedingListener(holder, item));
	}

	/**
	 * 缓存控件
	 * 
	 * @author SunQuan
	 * 
	 */
	static class ViewHolder {
		TextView time;
		TextView title;
		TextView content;
		View videoWrapper;
		ImageView videoImage;
		View imageWrapper;
		ImageView image;
		View share;

		public static ViewHolder create(View convertView) {
			ViewHolder holder = (ViewHolder) convertView.getTag();
			if (holder == null) {
				holder = new ViewHolder();
				holder.time = (TextView) convertView
						.findViewById(R.id.direct_seeding_time_TV);
				holder.title = (TextView) convertView
						.findViewById(R.id.direct_seeding_title_TV);
				holder.content = (TextView) convertView
						.findViewById(R.id.direct_seeding_content_TV);
				holder.videoWrapper = convertView.findViewById(R.id.video_RL);
				holder.videoImage = (ImageView) convertView
						.findViewById(R.id.direct_seeding_video_IV);
				holder.imageWrapper = convertView.findViewById(R.id.image_RL);
				holder.image = (ImageView) convertView
						.findViewById(R.id.direct_seeding_img);
				holder.share = convertView
						.findViewById(R.id.direct_seeding_share_LL);
				convertView.setTag(holder);
			}
			return holder;
		}
	}

	private class DirectSeedingListener implements OnClickListener {

		private PhotoAndTextLiveItemBean item;
		private ViewHolder holder;

		public DirectSeedingListener(ViewHolder holder,
				PhotoAndTextLiveItemBean item) {
			this.item = item;
			this.holder = holder;
		}

		@Override
		public void onClick(View v) {
			if (v == holder.title) {
				// 去web页查看
				goToWebPage();
			} else if (v == holder.videoWrapper) {
				// 跳转到播放视频页
				goToVideoPage();
			} else if (v == holder.imageWrapper) {
				// 跳转到灯箱页查看图片
				goToImagePage();
			} else if (v == holder.share) {
				// 分享
				share();
			}
		}

		/**
		 * 分享
		 */
		private void share() {
			ArrayList<String> shareImage = new ArrayList<String>();
			if (item.getVideo() != null) {
				shareImage.add(item.getVideo().getVideo_image());
			} else if (item.getImg() != null) {
				shareImage.add(item.getImg().getThumb_url());
			}
			
			StringBuilder builder = new StringBuilder();
			builder.append(DIRECT_SEEDING_SHARE).append(item.getLr_id());
			// 统计时需要加入id和类型type，图文直播由于没有documentId所以直接从分享链接中解析liveId参数作为id
			new ShareAlertBig(ctx, new WXHandler(ctx), builder.toString(),
					getShareTitle(), getShareContent(), shareImage, null, StatisticUtil.StatisticPageType.piclive).show(ctx);
		}
		
		/**
		 * 获取分享标题
		 * @return
		 */
		private String getShareTitle(){
			StringBuilder builder = new StringBuilder();	
			if(!TextUtils.isEmpty(item.getTitle())){
				builder.append("[");
				builder.append(item.getTitle());
				builder.append("]");
			}
			return builder.toString();
		}

		/**
		 * 获取分享内容
		 * 
		 * @return 分享内容
		 */
		private String getShareContent() {
			// 内容长度超过20的话截断
			String content = item.getContent().length() > Config.SHARE_MAX_LENGTH ? item
							 .getContent().substring(0, Config.SHARE_MAX_LENGTH) +"...": item.getContent();
			return content ; 
		}

		/**
		 * 跳转到图片页
		 */
		private void goToImagePage() {
			//http://y2.ifengimg.com/508df9aec9e2a/image/2013/08/26/521b029b56f92_439_3803.jpg			
			String originalUrl = item.getImg().getOriginal_url();
			if (!TextUtils.isEmpty(originalUrl)) {				
				Intent intent = new Intent(ctx, PopupLightbox.class);
				intent.setAction(ConstantManager.ACTION_FROM_DIRECT_SEEDING);
				intent.putExtra("imgUrl", originalUrl);
				ctx.startActivity(intent);
				((Activity) ctx).overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
			}
		}


		/**
		 * 跳转到视频播放页面
		 */
		private void goToVideoPage() {
		  final String videoUrl = item.getVideo().getVideo_url();
	      if (!TextUtils.isEmpty(videoUrl)) {

	        if (NetworkState.isActiveNetworkConnected(ctx) && !NetworkState.isWifiNetworkConnected(ctx)) {

	          AlertDialog.Builder alertBuilder = new AlertDialog.Builder(ctx);
	          AlertDialog alertPlayIn2G3GNet =
	              alertBuilder
	                  .setCancelable(true)
	                  .setMessage(ctx.getResources().getString(R.string.video_dialog_play_or_not))
	                  .setPositiveButton(ctx.getResources().getString(R.string.video_dialog_positive),
	                      new android.content.DialogInterface.OnClickListener() {

	                        @Override
	                        public void onClick(DialogInterface dialog, int which) {
	                          PlayVideoActivity.playVideo(ctx, videoUrl.replace("&amp;", "&"), null);
	                        }
	                      })
	                  .setNegativeButton(ctx.getResources().getString(R.string.video_dialog_negative),
	                      new android.content.DialogInterface.OnClickListener() {

	                        @Override
	                        public void onClick(DialogInterface dialog, int which) {

	                        }
	                      }).create();
	          alertPlayIn2G3GNet.show();
	        } else {
	          PlayVideoActivity.playVideo(ctx, videoUrl.replace("&amp;", "&"), null);
	        }
	      }
		}

		/**
		 * 跳转到web页面
		 */
		private void goToWebPage() {
			String titleUrl = item.getTitle_link();
			if (!TextUtils.isEmpty(titleUrl)) {
				// 将该项item标记为已读
				ReadUtil.markReaded(item.getId());
				holder.title.setTextColor(ctx.getResources().getColor(
						R.color.list_readed_text_color));
				Intent intent = new Intent(ctx, AdDetailActivity.class);
				intent.setAction(ConstantManager.ACTION_FROM_APP);
				intent.putExtra("URL", titleUrl);
				ctx.startActivity(intent);
			}
		}

	}

}
