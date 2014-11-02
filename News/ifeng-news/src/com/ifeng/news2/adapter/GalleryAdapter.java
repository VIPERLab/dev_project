package com.ifeng.news2.adapter;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.TypedValue;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.bean.SlideBody;
import com.ifeng.news2.util.PhotoModeUtil;
import com.ifeng.news2.util.PhotoModeUtil.PhotoMode;
import com.qad.form.BasePageAdapter;
import com.qad.loader.LoadContext;

public class GalleryAdapter extends BasePageAdapter<SlideBody> {

	private PhotoMode mode;
	public GalleryAdapter(Context ctx) {
		super(ctx);
		mode = PhotoModeUtil.getCurrentPhotoMode(ctx);
	}
	
	@Override
	public void notifyDataSetChanged() {
		mode = PhotoModeUtil.getCurrentPhotoMode(ctx);
		super.notifyDataSetChanged();
	}

	@Override
	protected int getResource() {
		return R.layout.widget_slide_index_item;
	}

	@Override
	protected void renderConvertView(int position, View convertView) {
		decorateView(position,convertView);
		SlideBody body = getItem(position);	
		ViewHolder holder = (ViewHolder) convertView.getTag();
		if(holder==null){
			holder = new ViewHolder();
			holder.thumbnail = (ImageView) convertView.findViewById(R.id.thumbnail);
			holder.title = (TextView) convertView.findViewById(R.id.title);
			holder.commentsNum = (TextView) convertView.findViewById(R.id.commentsNum);
			convertView.setTag(holder);
		}
			
		String title = body.getTitle();
		holder.title.setText(title);
		holder.commentsNum.setText(body.getComments());
		if(mode == PhotoMode.VISIBLE_PATTERN) {
			IfengNewsApp.getImageLoader().startLoading(new LoadContext<String, ImageView, Bitmap>(body.getThumbnail(), holder.thumbnail, 
					Bitmap.class, LoadContext.FLAG_CACHE_FIRST, ctx));
		}		
	}
	
	static class ViewHolder{
		ImageView thumbnail;
		TextView title;
		TextView commentsNum;
	}
	
	private void decorateView(int position,View view){
		if (position < 1) {
			view.setPadding(view.getPaddingLeft(), (int) (TypedValue
					.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 10, view
							.getResources().getDisplayMetrics())), view
					.getPaddingRight(), view.getPaddingBottom());
		} else {
			view.setPadding(view.getPaddingLeft(), 0,
					view.getPaddingRight(), view.getPaddingBottom());
		}
	}

}
