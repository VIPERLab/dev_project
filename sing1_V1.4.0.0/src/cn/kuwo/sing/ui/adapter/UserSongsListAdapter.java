/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.adapter;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.business.MTVBusiness;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.ui.activities.LocalEditActivity;
import cn.kuwo.sing.ui.activities.LocalNoticeActivity;
import cn.kuwo.sing.ui.activities.MyHomeActivity;

import com.googlecode.mp4parser.h264.BTree;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;

import de.greenrobot.event.EventBus;

/**
 * @Package cn.kuwo.sing.ui.adapter
 *
 * @Date 2013-12-25, 下午3:38:12
 *
 * @Author wangming
 *
 */
public class UserSongsListAdapter extends BaseAdapter {
	private Activity mActivity;
	private List<Kge> mKgeList = new ArrayList<Kge>();
	private String mUserPicUrl;
	
	public UserSongsListAdapter(Activity activity) {
		mActivity = activity;
	}
	
	public void setUserBaseInfo(String userPicUrl) {
		mUserPicUrl = userPicUrl;
	}
	
	public void clearList() {
		mKgeList.clear();
	}
	
	public void setUserKgeList(List<Kge> kgeList) {
		mKgeList.addAll(kgeList);
		notifyDataSetChanged();
	}
	
	public void removeKge(int position) {
		mKgeList.remove(position);
		notifyDataSetChanged();
	}

	@Override
	public int getCount() {
		return mKgeList.size();
	}

	@Override
	public Object getItem(int position) {
		return mKgeList.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}
	
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View view = null;
		ViewHolder viewHolder = null;
		if(convertView == null) {
			view = View.inflate(mActivity, R.layout.user_kge_list_item, null);
			viewHolder = new ViewHolder();
			viewHolder.ivUserPortrait = (ImageView) view.findViewById(R.id.ivUserPortrait);
			viewHolder.ivUserKgeGo = (ImageView) view.findViewById(R.id.ivUserKgeGo);
			viewHolder.tvTitle = (TextView) view.findViewById(R.id.tvUserKgeTitle);
			viewHolder.tvSrc = (TextView) view.findViewById(R.id.tvUserKgeSrc);
			viewHolder.tvTime = (TextView) view.findViewById(R.id.tvUserKgeTime);
			viewHolder.tvViews = (TextView) view.findViewById(R.id.tvUserKgeViews);
			viewHolder.tvComments = (TextView) view.findViewById(R.id.tvUserKgeComments);
			viewHolder.tvFlowers = (TextView) view.findViewById(R.id.tvUserKgeFlowers);
			view.setTag(viewHolder);
		}else {
			view = convertView;
			viewHolder = (ViewHolder) view.getTag();
		}
		
		final Kge kge = mKgeList.get(position);
		KuwoLog.e("adapter", "viewHolder="+viewHolder);
		KuwoLog.e("adapter", "picUrl="+mUserPicUrl+",portrait="+viewHolder.ivUserPortrait);
		ImageLoader.getInstance().displayImage(mUserPicUrl, viewHolder.ivUserPortrait, new AnimateFirstDisplayListener());
		viewHolder.ivUserKgeGo.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				MTVBusiness mb = new MTVBusiness(mActivity);
				mb.playMtv(kge.id);
			}
		});
		viewHolder.tvTitle.setText(kge.title);
		viewHolder.tvSrc.setText(kge.src);
		viewHolder.tvTime.setText(kge.time);
		viewHolder.tvViews.setText(kge.view+"");
		viewHolder.tvComments.setText(kge.comment+"");
		viewHolder.tvFlowers.setText(kge.flower+"");
		return view;
	}
	
	private static class AnimateFirstDisplayListener extends SimpleImageLoadingListener {

		static final List<String> displayedImages = Collections.synchronizedList(new LinkedList<String>());

		@Override
		public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
			if (loadedImage != null) {
				ImageView imageView = (ImageView) view;
				boolean firstDisplay = !displayedImages.contains(imageUri);
				if (firstDisplay) {
					FadeInBitmapDisplayer.animate(imageView, 500);
					displayedImages.add(imageUri);
				} else {
					imageView.setImageBitmap(loadedImage);
				}
			}
		}
	}
	
	static class ViewHolder {
		ImageView ivUserPortrait;
		ImageView ivUserKgeGo;
		TextView tvTitle;
		TextView tvViews;
		TextView tvFlowers;
		TextView tvComments;
		TextView tvSrc;
		TextView tvTime;
		Button btPlay;
	}

}
