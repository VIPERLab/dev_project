package com.ifeng.news2.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.TextView;
import com.ifeng.news2.Config;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.id;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.bean.TopicContent;
import com.ifeng.news2.bean.VideoListItem;
import com.ifeng.news2.db.CollectionDBManager;
import com.ifeng.news2.util.PhotoModeUtil.PhotoMode;
import com.ifeng.news2.widget.ChannelSlideImageView;
import java.util.ArrayList;

public class ListDisplayStypeUtil {
	/**
	 * 普通频道列表样式标示
	 */
	public final static String CHANNEL_FLAG = "CHANNEL_FLAG";
	/**
	 * 凤凰快讯频道列表样式标示
	 */
	public final static String CHANNEL_HISTORY = "CHANNEL_HISTORY";
	/**
	 * 头条频道列表样式标示
	 */
	public final static String HEAD_CHANNEL_FLAG = "HEAD_CHANNEL_FLAG";
	/**
	 * 收藏列表样式标示
	 */
	public final static String CHANNEL_COLLECTION_FLAG = "CHANNEL_COLLECTION_FLAG";
	/**
	 * 独家频道列表标示
	 */
	public final static String SUB_CHANNEL_FLAG = "SUB_CHANNEL_FLAG";
	/**
	 * 视频频道列表
	 */
	public final static String VIDEO_CHANNEL_FLAG = "VIDEO_CHANNEL_FLAG";
	
	private Typeface tfArial = null;
	private ImageView collectionIcon = null;
	private boolean isHasVideo = false;
	private boolean isHasSurvey = false;
	private boolean hasLeftIcon = false;
	private String thumbnailUrl = null;
	private String commentCount = null;
	private String editTime = null;
	//列表跳转
	private ArrayList<Extension> links = null;
	//列表样式
	private ArrayList<Extension> extensions = null;
	private IconBean iconBean = null;
	private int duration = 0;
	
	public ListDisplayStypeUtil() {
		//
	}
	
	public ListDisplayStypeUtil(Context ctx) {
		tfArial = Typeface.createFromAsset(ctx.getApplicationContext().getAssets(), "Arial.ttf");
	}
	/**
	 * 渲染列表图片 默认是有图模式的
	 * 
	 * @param view
	 * @param data
	 * @param flag
	 * @return
	 */
	public ChannelViewHolder setListIcon(View view, Object data, String flag) {
		return setListIcon(view, data, flag, PhotoMode.VISIBLE_PATTERN);
	}
	
	public ChannelViewHolder setListIcon(View view, Object data, String flag, PhotoMode mode) {
		ChannelViewHolder holder = (ChannelViewHolder) view.getTag(R.id.tag_holder);
		if (holder == null) {
			holder = ChannelViewHolder.create(view);
		}
//		else {
//			// listview item被重用时由于自体动态调整，少数item字体大小已被改变，这里需要还原
//			holder.title.setTextAppearance(view.getContext().getApplicationContext(), R.style.channel_list_title);
//		}
		collectionIcon = holder.collectionIcon;
		
		//视频列表
		if(flag.equals(VIDEO_CHANNEL_FLAG)){
			view.setTag(R.id.tag_data, ((VideoListItem)data).getMemberItem().getGuid());
			view.setTag(R.id.tag_title,((VideoListItem) data).getFullTitle());//传入正文页，需完整 不截断
			thumbnailUrl = ((VideoListItem) data).getImage();
			if (!TextUtils.isEmpty(thumbnailUrl.trim()) && mode == PhotoMode.VISIBLE_PATTERN){
				holder.title.setText(((VideoListItem) data).getTitle());
			}else{//无缩略图时多截几个字
				holder.title.setText(((VideoListItem) data).getLongTitle());
			}
			holder.title.setTextColor(((VideoListItem) data).getTitleColor());	
			//栏目名称
			holder.column.setText(((VideoListItem)data).getMemberItem().getColumnName());
			//时长
			duration = ((VideoListItem)data).getMemberItem().getDuration();
			holder.durationView.setText(DateUtil.parseDuration(duration));
//			Typeface tfArial = Typeface.createFromAsset(view.getContext().getApplicationContext().getAssets(), "Arial.ttf");
			holder.durationView.setTypeface(tfArial);
			//缩略图是否显示 及其处理方式
			holder.setThumbnailWrapper(holder.title,
					holder.listThumbnailWrapper, holder.thumbnail, thumbnailUrl,mode);
		}
		//其他列表
		else {
			if (data instanceof ListItem) {
				//频道数据
				view.setTag(R.id.tag_data, ((ListItem) data).getLinks());
				links = ((ListItem) data).getLinks();
				extensions = ((ListItem) data).getExtensions();
				isHasVideo = "Y".equals(((ListItem) data).getHasVideo()) ? true : false;
				isHasSurvey = "Y".equals(((ListItem) data).getHasSurvey()) ? true : false;
				editTime = DateUtil.getTimeOfList(((ListItem) data).getEditTime());
				commentCount = ((ListItem) data).getComments();
				thumbnailUrl = ((ListItem) data).getThumbnail();
				holder.title.setText(((ListItem) data).getTitle());
				iconBean = IconBean.getListIconBean(extensions,false);
				if (CHANNEL_COLLECTION_FLAG.equals(flag)){
				  //收藏列表是否有民调图标
				  isHasSurvey = CollectionDBManager.TYPE_ICON_SURVEY.equals(((ListItem) data).getTypeIcon()) ? true : false;
				} else {
				  holder.title.setTextColor(((ListItem) data).getTitleColor());
				}
			} else {
				//专题列表暂不设置无图模式
//				mode = PhotoMode.VISIBLE_PATTERN;
				//json专题list类型数据
				links = ((TopicContent) data).getLinks();
//				extensions = ((TopicContent) data).getExtensions();
				isHasVideo = ((TopicContent) data).isHasVideo();
				commentCount = ((TopicContent) data).getCommentCount();
				thumbnailUrl = ((TopicContent) data).getThumbnail();
				//专题中专题等样式使用style字段，style字段和Link并列
				iconBean = IconBean.getListRightIconBean(((TopicContent) data).getStyle());
			}

			if (null != iconBean) {
				if (iconBean.getId() != 0) {
					holder.listRightIcon.setVisibility(View.VISIBLE);
					holder.listLeftIcon.setVisibility(View.GONE);
					holder.listRightIcon.setBackgroundResource(iconBean.getId());
				} else {
					hasLeftIcon = holder.setLeftIcon(links, isHasVideo, isHasSurvey,
							holder.listRightIcon, holder.listLeftIcon);
				}
			} else if(flag.equals(SUB_CHANNEL_FLAG)&&!TextUtils.isEmpty(editTime)){
				holder.editTime.setVisibility(View.VISIBLE);
				holder.editTime.setText(editTime);
			} else{
				hasLeftIcon = holder.setLeftIcon(links, isHasVideo, isHasSurvey,
						holder.listRightIcon, holder.listLeftIcon);
			}
				
			if (TextUtils.isEmpty(commentCount)) {
//				if (hasLeftIcon)
					holder.listCommentModule.setVisibility(View.INVISIBLE);
//				else
//					holder.listCommentModule.setVisibility(View.GONE);
			} else {
				holder.comments.setText(commentCount);
				holder.listCommentModule.setVisibility(View.VISIBLE);
			}
			if (HEAD_CHANNEL_FLAG.equals(flag)) {
				holder.listThumbnailWrapper.setVisibility(View.VISIBLE);
				holder.setThumbnailWrapper(holder.title,
						holder.listThumbnailWrapper, holder.thumbnail, thumbnailUrl,mode);
			} else if (CHANNEL_FLAG.equals(flag)||SUB_CHANNEL_FLAG.equals(flag)) {
				holder.setThumbnailWrapper(holder.title,
						holder.listThumbnailWrapper, holder.thumbnail, thumbnailUrl,mode);
			} 
			else {
				holder.setThumbnailWrapper(holder.title,
						holder.listThumbnailWrapper, holder.thumbnail, thumbnailUrl,mode);
				holder.listCommentIcon.setVisibility(View.GONE);
			}
			if (data instanceof ListItem) {
				//频道列表三联图样式
				if (((ListItem) data).isChannelSlide(extensions)) {
					holder.title.setMinLines(1);
					//如果不是无图模式，则显示列表三联图
					if(mode == PhotoMode.VISIBLE_PATTERN) {
						holder.listSlideModule.setVisibility(View.VISIBLE);
					}				
					holder.listThumbnailWrapper.setVisibility(View.GONE);
					if (TextUtils.isEmpty(commentCount))
						holder.listCommentModule.setVisibility(View.GONE);
					else
						holder.listCommentModule.setVisibility(View.VISIBLE);
				} else
					holder.listSlideModule.setVisibility(View.GONE);
			}
			if (CHANNEL_COLLECTION_FLAG.equals(flag))
				collectionIcon.setVisibility(View.VISIBLE);
			else
				collectionIcon.setVisibility(View.GONE);
		}
		
		
		return holder;
	}

	private static class IconBean {
		private int id = 0;

		/**
		 * live topic
		 * 
		 * @param links
		 * @return
		 */
		public static IconBean getListIconBean(ArrayList<Extension> extensions,boolean isTopic) {
			if (null == extensions)
				return null;
			IconBean iconBean = new IconBean();
			for (Extension extension : extensions) {
				if (null == extension)
					continue;
				String style = extension.getStyle();
				String type = extension.getType();
				if(ModuleLinksManager.LINK_STYLE_TYPE.equals(type)||isTopic){
					if (ModuleLinksManager.LINK_DOC_TYPE.equals(style)) {
					} else if (ModuleLinksManager.TOPIC_STYLE.equals(style)) {
						iconBean.setId(drawable.channel_list_topic_icon);
						return iconBean; // web类型的的topic
					} else if (ModuleLinksManager.PLOT_STYLE.equals(style)) {
						iconBean.setId(drawable.scheme);
						return iconBean;
					} else if (ModuleLinksManager.LIVE_STYLE.equals(style)) {
						iconBean.setId(drawable.live);
						return iconBean;
					} else if (ModuleLinksManager.SURVEY_STYLE.equals(style)) {
                      iconBean.setId(drawable.poll_normal);//民调
                      return iconBean;
                  }
				}				
			}
			return null;
		}
		
		public static IconBean getListRightIconBean(String style){
			if (null == style) {
				return null;
			}
			IconBean iconBean = new IconBean();
			if (ModuleLinksManager.LINK_DOC_TYPE.equals(style)) {
			} else if (ModuleLinksManager.TOPIC_STYLE.equals(style)) {
				iconBean.setId(drawable.channel_list_topic_icon);
				return iconBean; // web类型的的topic
			} else if (ModuleLinksManager.PLOT_STYLE.equals(style)) {
				iconBean.setId(drawable.scheme); //策划
				return iconBean;
			} else if (ModuleLinksManager.LIVE_STYLE.equals(style)) {
				iconBean.setId(drawable.live); //直播
				return iconBean;
			} 
			return null;
		}

		public int getId() {
			return id;
		}

		public void setId(int id) {
			this.id = id;
		}
	}

	// get the comments space
	public static int getCommentSpace(String comment) {
		double count = 0.00;
		if (TextUtils.isEmpty(comment)) {
			return 0;
		}
		for (int i = 0; i < comment.length(); i++) {
			if (!Character.isDigit(comment.charAt(i)))
				break;
			count++;
		}
		return (int) (Math.ceil(count / 2)) + 3; //
	}
	
	/**
	 * 回收ChannelViewHolder中ImageView上的bitmap
	 * @param holder
	 */
	public static void cleanupChannelViewHolder(ChannelViewHolder holder) {
	    Bitmap bitmap = null;
	    Drawable drawable = null;
	    if(holder.firstImage != null){
	    	drawable = holder.firstImage.getDrawable();
	    	if (null != drawable) {
	    		bitmap = ((BitmapDrawable)holder.firstImage.getDrawable()).getBitmap();
	    		holder.firstImage.setImageResource(android.R.color.transparent);
	    		if (null != bitmap && !bitmap.isRecycled()) {
	    			bitmap.recycle();
	    		}
	    	}
	    }
	    if(holder.secondImage != null){
	    	drawable = holder.secondImage.getDrawable();
	    	if (null != drawable) {
	    		bitmap = ((BitmapDrawable)holder.secondImage.getDrawable()).getBitmap();
	    		holder.secondImage.setImageResource(android.R.color.transparent);
	    		if (null != bitmap && !bitmap.isRecycled()) {
	    			bitmap.recycle();
	    		}
	    	}
	    }
        if(holder.thridImage != null){
        	drawable = holder.thridImage.getDrawable();
        	if (null != drawable) {
        		bitmap = ((BitmapDrawable)holder.thridImage.getDrawable()).getBitmap();
        		holder.thridImage.setImageResource(android.R.color.transparent);
        		if (null != bitmap && !bitmap.isRecycled()) {
        			bitmap.recycle();
        		}
        	}
        }
        if(holder.thumbnail != null){
        	drawable = holder.thumbnail.getDrawable();
        	if (null != drawable) {
        		bitmap = ((BitmapDrawable)holder.thumbnail.getDrawable()).getBitmap();
        		holder.thumbnail.setImageResource(android.R.color.transparent);
        		if (null != bitmap && !bitmap.isRecycled()) {
        			bitmap.recycle();
        		}
        	}
        }
	}

	// @lxl, for list topic ,and so on end

	/**
	 * view 视图缓存
	 * 
	 */
	public static class ChannelViewHolder {
		public TextView title;
		public View divider;
		public View listCommentModule;
		public View listThumbnailWrapper;
		public View listSlideModule;
		public ImageView listLeftIcon;
		public ImageView listRightIcon;
		public ImageView listCommentIcon;
		public ImageView thumbnail;
		public ChannelSlideImageView firstImage;
		public ChannelSlideImageView secondImage;
		public ChannelSlideImageView thridImage;
		public ImageView collectionIcon;
		public TextView comments;
		public TextView editTime;
		//视频添加
		public View listDurationModule;
		public ImageView listDurationIcon;
		public TextView durationView;
		public TextView column;
		
		public static ChannelViewHolder create(View view) {
			ChannelViewHolder holder = new ChannelViewHolder();
			holder.title = (TextView) view.findViewById(id.title);
			holder.listCommentModule = view
					.findViewById(id.list_comment_module);
			holder.listThumbnailWrapper = view
					.findViewById(id.thumbnail_wrapper);
			holder.listSlideModule = view
					.findViewById(id.channel_list_slide_module);
			holder.listLeftIcon = (ImageView) view
					.findViewById(id.list_left_icon);
			holder.listRightIcon = (ImageView) view
					.findViewById(id.list_right_icon);
			holder.listCommentIcon = (ImageView) view
					.findViewById(id.channel_list_comment_icon);
			holder.thumbnail = (ImageView) view.findViewById(id.thumbnail);
			
			float width = Config.SCREEN_WIDTH/(float)Config.LIST_THUMBNAIL_SCREEN_RATIO;
			int height = (int)(width/(float)Config.LIST_THUMBNAIL_RATIO);
			LayoutParams params = new LayoutParams((int)width, height);
			holder.thumbnail.setLayoutParams(params);
			view.findViewById(id.bg_thumbnail).setLayoutParams(params);
			
			holder.firstImage = (ChannelSlideImageView) view
					.findViewById(id.thumbnail_first);
			holder.secondImage = (ChannelSlideImageView) view
					.findViewById(id.thumbnail_second);
			holder.thridImage = (ChannelSlideImageView) view
					.findViewById(id.thumbnail_third);
			holder.comments = (TextView) view.findViewById(id.comments);
			holder.editTime = (TextView) view.findViewById(id.editTime);
			holder.collectionIcon = (ImageView) view
					.findViewById(id.collection_button);	
			//视频添加
			holder.listDurationModule = view
					.findViewById(id.list_duration_module);
			holder.listDurationIcon = (ImageView) view.findViewById(id.channel_list_duration_icon);
			holder.durationView = (TextView) view.findViewById(id.duration);
			holder.column = (TextView) view.findViewById(id.column);
			holder.divider = view.findViewById(id.channelDivider);
			view.setTag(R.id.tag_holder,holder);
			return holder;
		}

		public boolean setLeftIcon(ArrayList<Extension> links,
				boolean isHasVideo, boolean isHasSurvey, ImageView listBigIcon,
				ImageView listSmallIcon) {
			boolean hasLeftIcon = false;
			if (isHasSurvey) {
				
				 listBigIcon.setVisibility(View.INVISIBLE);
	              listSmallIcon.setVisibility(View.VISIBLE);
	              listSmallIcon.setBackgroundResource(drawable.poll_doc);
			} else if (isHasVideo) {
			  listSmallIcon.setVisibility(View.VISIBLE);
			  listSmallIcon
			  .setBackgroundResource(drawable.channel_list_video_icon);
			  hasLeftIcon = true;
			} else if (links.size() > 0 && null != links.get(0) && ModuleLinksManager.LINK_SLIDE_TYPE
					.equals(links.get(0).getType())) {
				listBigIcon.setVisibility(View.INVISIBLE);
				listSmallIcon.setVisibility(View.VISIBLE);
				listSmallIcon
						.setBackgroundResource(drawable.channel_list_atlas_icon);
			} else {
				listSmallIcon.setVisibility(View.INVISIBLE);
			}
			listBigIcon.setBackgroundResource(drawable.topic_icon_tag);
			listBigIcon.setVisibility(View.INVISIBLE);
			return hasLeftIcon;
		}

		public void setThumbnailWrapper(TextView title,
				View listThumbnailWrapper, ImageView thumbnail,
				String thumbnailUrl,PhotoMode mode) {
			// 处理缩略图链接仅为空的情况
			if (!TextUtils.isEmpty(thumbnailUrl.trim()) && mode == PhotoMode.VISIBLE_PATTERN) { 
				title.setMinLines(2);
				listThumbnailWrapper.setVisibility(View.VISIBLE);
			} else {
				title.setMinLines(2);
				listThumbnailWrapper.setVisibility(View.GONE);
			}
		}
	}
}
