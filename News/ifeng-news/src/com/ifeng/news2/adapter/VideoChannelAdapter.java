package com.ifeng.news2.adapter;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.View;
import android.widget.ImageView;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.bean.VideoListItem;
import com.ifeng.news2.db.CollectionDBManager;
import com.ifeng.news2.util.ListDisplayStypeUtil;
import com.ifeng.news2.util.ListDisplayStypeUtil.ChannelViewHolder;
import com.ifeng.news2.util.PhotoModeUtil;
import com.ifeng.news2.util.PhotoModeUtil.PhotoMode;
import com.qad.form.BasePageAdapter;
import com.qad.loader.LoadContext;

/**
 * 频道列表Adapter
 * 
 * @author wu_dan
 * 
 */
public class VideoChannelAdapter extends BasePageAdapter<VideoListItem> {

	private ListDisplayStypeUtil displayUtil;
	private String type;
	private ChannelViewHolder holder = null;
	private int beforeNewsPosition;
	@SuppressWarnings("unused")
	private CollectionDBManager collectionManager;
	private static final int INITIAL_POSITION = -1;
	private PhotoMode mode;

	
	@Override
	public void notifyDataSetChanged() {
		mode = PhotoModeUtil.getCurrentPhotoMode(ctx);
		super.notifyDataSetChanged();
	}

	public VideoChannelAdapter(Context ctx, String type) {
		super(ctx);
		this.type = type;
		displayUtil = new ListDisplayStypeUtil(ctx);
		collectionManager = new CollectionDBManager(ctx);
		this.beforeNewsPosition = INITIAL_POSITION;
		this.mode = PhotoModeUtil.getCurrentPhotoMode(ctx);
	}

	@Override
	protected int getResource() {
		return layout.widget_video_channel_list_item;
	}

	@Override
	protected void renderConvertView(final int position, View convertView) {
		holder = displayUtil.setListIcon(convertView, getItem(position), type, mode);	
		if(mode == PhotoMode.VISIBLE_PATTERN) {
			loadImage(position, holder);
		}		
	}

	/**
	 * 异步加载图片
	 * 
	 * @param position
	 * @param holder
	 */
	private void loadImage(int position, ChannelViewHolder holder) {
		if (holder != null) {
			VideoListItem item = getItem(position);
			if (holder.listThumbnailWrapper.getVisibility() == View.VISIBLE
					&& item.getImage() != null) {
				IfengNewsApp.getImageLoader().startLoading(
						new LoadContext<String, ImageView, Bitmap>(item.getImage(), holder.thumbnail,
								Bitmap.class, LoadContext.FLAG_CACHE_FIRST, ctx));		
			}
		}
	}
}
