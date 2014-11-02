package com.ifeng.news2.widget;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.ifeng.news2.Config;
import com.ifeng.news2.R;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.bean.Channel;

public class ChannelMenu extends RelativeLayout implements OnClickListener {

	private LinearLayout textTitle;
	private LayoutInflater inflater;
	private RelativeLayout currentTitleItem;
	private OnChannelItemSelectedListener selectedListener;
	private HorizontalScrollView titleScoller;

	public static interface OnChannelItemSelectedListener {
		void onChannelItemClicked(View view, Channel channel, int position);
	}
	
	public ChannelMenu(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public ChannelMenu(Context context) {
		super(context);
		init();
	}

	public ChannelMenu(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}
	
	private void init() {
		inflater = LayoutInflater.from(getContext());
		inflater.inflate(layout.widget_channel_menu, this);
		findViews();
		initTitle();
	}

	private void findViews() {
		textTitle = (LinearLayout) findViewById(R.id.news_title);
		titleScoller = (HorizontalScrollView) findViewById(R.id.title_scoller);
	}

	private void initTitle() {
		for (Channel channel : Config.CHANNELS) {
			RelativeLayout  item = (RelativeLayout) inflater.inflate(
					layout.widget_channel_menu_item, null);
			TextView textView = (TextView) item.findViewById(R.id.title_text);
			textView.setText(channel.getChannelName());
			item.setId(textTitle.getChildCount());
			textTitle.addView(item);
			item.setOnClickListener(this);
		}
		changeForcuse(textTitle.getChildAt(0));
	}

	public void setOnChannelItemSelectedListener(
			OnChannelItemSelectedListener selectedListener) {
		this.selectedListener = selectedListener;
	}

	@Override
	public void onClick(View v) {
			changeForcuse(v);
			if (selectedListener != null) {
				selectedListener.onChannelItemClicked(v,
						Config.CHANNELS[v.getId()], v.getId());
			}
	}

	public void moveToDest(int position) {
		if(titleScoller==null||textTitle==null||textTitle.getChildCount()<position){
			return;
		}
		if (position < 3) {
			titleScoller.smoothScrollTo(0, 0);
		} else {
			titleScoller.smoothScrollTo(
					textTitle.getChildAt(position).getLeft() - 2 * textTitle.getChildAt(0).getWidth(),
					0);
		}
		changeForcuse(textTitle.getChildAt(position));
	}
	
	public void moveToDestFast(final int position) {
		if(titleScoller==null||textTitle==null){
			return;
		}
		if (textTitle.getChildAt(position).getLeft()
				- titleScoller.getScrollX()+textTitle.getChildAt(position).getWidth() > ((Activity) getContext())
				.getWindowManager().getDefaultDisplay().getWidth()
				|| textTitle.getChildAt(position).getLeft()
						- titleScoller.getScrollX()
						+ textTitle.getChildAt(position).getWidth() < 0||(position>0&&textTitle.getChildAt(position).getLeft()==0)) {
			new Handler(getContext().getMainLooper()).postDelayed(
					new Runnable() {
						@Override
						public void run() {
							if (position < 3) {
								titleScoller.scrollTo(0, 0);
							} else {
								titleScoller.scrollTo(textTitle.getChildAt(position).getLeft() - 2 * textTitle.getChildAt(0).getWidth(),
										0);
							}
						}
					}, 400);
		}
		changeForcuse(textTitle.getChildAt(position));
	}
	
	private void changeForcuse(View view) {
		if (currentTitleItem != null) {
			((TextView)currentTitleItem.findViewById(R.id.title_text)).setBackgroundDrawable(null);
			((TextView)currentTitleItem.findViewById(R.id.title_text)).setTextColor(getResources().getColor(R.color.otherchannel));
		}
		currentTitleItem = (RelativeLayout) view;
		((TextView)currentTitleItem.findViewById(R.id.title_text)).setBackgroundDrawable(getResources().getDrawable(R.drawable.news_title_text_background));
		((TextView)currentTitleItem.findViewById(R.id.title_text)).setTextColor(getResources().getColor(R.color.title_red));
	}
	
	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {
		getParent().requestDisallowInterceptTouchEvent(true);
		return super.onInterceptTouchEvent(ev);
	}
	
//	@Override
//	public void invalidate() {
//		if(textTitle!=null){
//			invalidateViews();
//		}
//		super.invalidate();
//	}

	public void invalidateViews(int position) {
		while(Config.CHANNELS.length<textTitle.getChildCount()){
			textTitle.removeViewAt(textTitle.getChildCount()-1);
		}
		for(int i=0;i<Config.CHANNELS.length; i++){
			RelativeLayout view = (RelativeLayout) textTitle.getChildAt(i);
			if(view==null){
				view = (RelativeLayout) inflater.inflate(
						layout.widget_channel_menu_item, null);
				TextView textView = (TextView) view.findViewById(R.id.title_text);
				textView.setText(Config.CHANNELS[i].getChannelName());
				view.setId(i);
				textTitle.addView(view);
				view.setOnClickListener(this);
			}else if(((TextView)view.findViewById(R.id.title_text)).getText().equals(Config.CHANNELS[i].getChannelName())){
				continue;
			}else{
				((TextView)view.findViewById(R.id.title_text)).setText(Config.CHANNELS[i].getChannelName());
			}
		}
	}

}
