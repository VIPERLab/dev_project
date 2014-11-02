package com.ifeng.share.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.ifeng.share.R;
import com.ifeng.share.util.AsyncImageLoader;

public class ShareImgAdapter extends BaseAdapter{
	protected AsyncImageLoader asyncImageLoader = new AsyncImageLoader();
	private Context ctxt;
	private LayoutInflater inflater;
	private Bitmap[] bitmaps;
	public ShareImgAdapter(Context ctxt,Bitmap[] bitmaps){
		this.ctxt = ctxt;
		this.inflater = LayoutInflater.from(ctxt);
		this.bitmaps = bitmaps;
	}

	@Override
	public int getCount() {
		return bitmaps.length;
	}

	@Override
	public Object getItem(int position) {
		return position;
	}

	@Override
	public long getItemId(int position) {
		return position;
	}
	public int dip2px(float dip){
		float i = ctxt.getResources().getDisplayMetrics().density;
		return (int)(dip * i + 0.5f);
	}
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		if(convertView == null){
			inflater = LayoutInflater.from(ctxt);
			convertView = inflater.inflate(R.layout.gallery_item, null);
		}

		ImageView image =(ImageView) convertView.findViewById(R.id.image);

		image.setImageBitmap(bitmaps[position]);

		return convertView;
	}

}
