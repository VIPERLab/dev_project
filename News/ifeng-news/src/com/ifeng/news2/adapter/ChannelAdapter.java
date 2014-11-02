package com.ifeng.news2.adapter;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.View;
import android.widget.ImageView;

import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.id;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.db.CollectionDBManager;
import com.ifeng.news2.util.DateUtil;
import com.ifeng.news2.util.ListDisplayStypeUtil;
import com.ifeng.news2.util.ListDisplayStypeUtil.ChannelViewHolder;
import com.ifeng.news2.util.PhotoModeUtil;
import com.ifeng.news2.util.PhotoModeUtil.PhotoMode;
import com.ifeng.news2.widget.DividerLine;
import com.qad.form.BasePageAdapter;
import com.qad.loader.LoadContext;

/**
 * 频道列表Adapter
 * 
 * @author Administrator
 * 
 */
public class ChannelAdapter extends BasePageAdapter<ListItem> {

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

	public ChannelAdapter(Context ctx, String type) {
		super(ctx);
		this.type = type;
		displayUtil = new ListDisplayStypeUtil();
		collectionManager = new CollectionDBManager(ctx);
		this.beforeNewsPosition = INITIAL_POSITION;
		this.mode = PhotoModeUtil.getCurrentPhotoMode(ctx);
	}

	/**
	 * 重置凤凰快讯24小时前位置
	 */
	public void resetBeforeNewsPosition() {
		this.beforeNewsPosition = INITIAL_POSITION;
	}

	@Override
	protected int getResource() {
		return layout.widget_channel_list_item_new;
	}

	@Override
	protected void renderConvertView(final int position, View convertView) {
		if (type.equals(ListDisplayStypeUtil.CHANNEL_HISTORY)) {
			checkDate(position, convertView, getItem(position));
		}
		holder = displayUtil.setListIcon(convertView, getItem(position), type, mode);	
		if (ListDisplayStypeUtil.CHANNEL_COLLECTION_FLAG.equals(type)) {
			// Fix bug #17758, 原因是列表项重用
			if (collectionManager.getCollectionStatusById(getItem(position).getDocumentId())) 
				holder.collectionIcon.setBackgroundResource(drawable.list_collectioned);
			else
				holder.collectionIcon.setBackgroundResource(drawable.list_collection);
		}
		if(mode == PhotoMode.VISIBLE_PATTERN) {
			loadImage(position, holder);
		}		
		// === begin === 以下为折行问题的测试数据
//		String testStr1 = "[军魂100]歼-15只能挂1.5吨？某门户不要如此荒谬";
//		String testStr2 = "武汉摧毁地下卖肾团伙：买肾花40万供体仅得3万";
//		String testStr3 = "诺基亚确认10月22日Lumia1520有望亮相";
//		if (3 == position) {
//			((ChannelViewHolder) convertView.getTag(R.id.tag_holder)).title
//			.setText(testStr3);//.replaceAll(" ", "\u00A0"));
//		} else if (2 == position) {
//			((ChannelViewHolder) convertView.getTag(R.id.tag_holder)).title
//			.setText(testStr2);//.replaceAll("？", "?").replaceAll("-", "-"));
//		} else if (1 == position) {
//			((ChannelViewHolder) convertView.getTag(R.id.tag_holder)).title
//			.setText(testStr1);
//		}
		// === end ===
	}

	/**
	 * 异步加载图片
	 * 
	 * @param position
	 * @param holder
	 */
	private void loadImage(int position, ChannelViewHolder holder) {
		if (holder != null) {
			ListItem item = getItem(position);
			if (holder.listSlideModule.getVisibility() == View.VISIBLE) {
				IfengNewsApp.getImageLoader().startLoading(
						new LoadContext<String, ImageView, Bitmap>(item
								.getThumbnail_first(), holder.firstImage,
								Bitmap.class, LoadContext.FLAG_CACHE_FIRST, ctx));
				IfengNewsApp.getImageLoader().startLoading(
						new LoadContext<String, ImageView, Bitmap>(item
								.getThumbnail_second(), holder.secondImage,
								Bitmap.class, LoadContext.FLAG_CACHE_FIRST, ctx));
				IfengNewsApp.getImageLoader().startLoading(
						new LoadContext<String, ImageView, Bitmap>(item
								.getThumbnail_third(), holder.thridImage,
								Bitmap.class, LoadContext.FLAG_CACHE_FIRST, ctx));
			}
			if (holder.listThumbnailWrapper.getVisibility() == View.VISIBLE
					&& item.getThumbnail() != null) {
				IfengNewsApp.getImageLoader().startLoading(
						new LoadContext<String, ImageView, Bitmap>(item
								.getThumbnail(), holder.thumbnail,
								Bitmap.class, LoadContext.FLAG_CACHE_FIRST, ctx));
			}
		}
	}

	/**
	 * 校验日期
	 * 
	 * @param position
	 * @param convertView
	 * @param item
	 */
	private void checkDate(int position, View convertView, ListItem item) {
		// fix bug #15616 ，update时间由后台修改为取推送时间
		String date = DateUtil.getCurrentTime(item.getUpdateTime());
		item.setComments(date);
		DividerLine dividerLine = (DividerLine) convertView.findViewById(id.channelDivider);
		// 只会有一条24小时前分隔线
		if (beforeNewsPosition == INITIAL_POSITION && position + 1 < getCount()) {
			if (DateUtil.isToday(getItem(position).getUpdateTime())
					&&!DateUtil.isToday(getItem(position + 1).getUpdateTime())) {
				beforeNewsPosition = position;
				dividerLine.changeState(DividerLine.HISTORY_DIVIDER);
			}else{
			  
			  dividerLine.changeState(DividerLine.NORMAL_DIVIDER);
			}
		} else if (position == beforeNewsPosition) {
			dividerLine.changeState(DividerLine.HISTORY_DIVIDER);
		} else {
			dividerLine.changeState(DividerLine.NORMAL_DIVIDER);
		}
	}

}
