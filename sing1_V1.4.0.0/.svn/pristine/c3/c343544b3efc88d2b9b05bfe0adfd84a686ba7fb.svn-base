/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.adapter;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.graphics.Bitmap;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.RelativeLayout.LayoutParams;

import cn.kuwo.framework.context.AppContext;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.ImageObject;
import cn.kuwo.sing.bean.MTV;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.util.AnimateFirstDisplayListener;
import cn.kuwo.sing.widget.KuwoImageView;
import cn.kuwo.sing.widget.MtvListItemView;


import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageLoadingListener;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.display.SimpleBitmapDisplayer;

public class SquareMtvObjectAdapter extends BaseAdapter {
	private static final String LOG_TAG = "ImageObjectAdapter";
	private Activity mActivity;
	private DisplayImageOptions mOptions;
	private List<MTV> mMtvObjectList = new ArrayList<MTV>();
	private int mType = 0; 
	
	public SquareMtvObjectAdapter(Activity activity, int type) {
		mActivity = activity;
		mType = type;
		mOptions = new DisplayImageOptions.Builder()
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
	
	public void setImageObjectData(List<MTV> imageObjectList) {
		mMtvObjectList.addAll(imageObjectList);
		notifyDataSetChanged();
	}
	
	public void clearImageObjectList() {
		mMtvObjectList.clear();
	}

	@Override
	public int getCount() {
		if (mType == Constants.FLAG_HOT_MTV){
			return mMtvObjectList.size()/3+1;
		}else{
			return mMtvObjectList.size()/3;
		}
		
	}

	@Override
	public Object getItem(int position) {
		return mMtvObjectList.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}
	
	@Override
	public boolean isEnabled(int position) {
		return false;
	}

	@Override
	public View getView(final int position, View convertView, ViewGroup parent) {
		View listView = null;
		ViewHolder viewHolder = null;
		
		if (position == 0 && mType == Constants.FLAG_HOT_MTV){
			MTV mtv = null;
			mtv = mMtvObjectList.get(0);
			
			KuwoImageView view = new KuwoImageView(mActivity, mType, mtv.type, mtv.userpic, mtv.kid==null?"0":mtv.kid, mtv.uname, mtv.title, false);
			RelativeLayout rlTopic = new RelativeLayout(mActivity);
			
			int imageHeight = AppContext.SCREEN_WIDTH/3;
			RelativeLayout.LayoutParams param = new RelativeLayout.LayoutParams(LayoutParams.FILL_PARENT, imageHeight);
			rlTopic.addView(view, param);
			ImageLoader.getInstance().displayImage(mtv.userpic, view.iv, mOptions, new AnimateFirstDisplayListener());
			return rlTopic;
		}
		
		if (convertView == null || viewHolder == null){
			listView = new MtvListItemView(mActivity);
			viewHolder = new ViewHolder();

			viewHolder.view = listView;
			listView.setTag(viewHolder);
		}else{
			listView = convertView;
			viewHolder = (ViewHolder) listView.getTag();
		}
		
//		if (mMtvObjectList == null || position*3>mMtvObjectList.size() || (position+1)*3>mMtvObjectList.size())
//			return null;
		
		MtvListItemView mtvListView = (MtvListItemView)viewHolder.view;
		List<MTV> mtvListData = null;
		
		if (mType == Constants.FLAG_HOT_MTV){
			if ((position+1)*3<=mMtvObjectList.size() && position>=1)
				mtvListData = mMtvObjectList.subList(position*3, (position+1)*3);
		}else{
			if ((position+1)*3<=mMtvObjectList.size())
				mtvListData = mMtvObjectList.subList(position*3, (position+1)*3);
		}
		
		if (mtvListView != null && mtvListData != null){
			mtvListView.initView(mtvListData, mType);
		}
		
		return listView;
	}
	
	private static class ViewHolder {
		View view;
	}
}
