package com.ifeng.news2.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.id;
import com.ifeng.news2.R.layout;

public class DividerLine extends RelativeLayout{

	private ImageView divider1;
	private View divider2;
	private final String namespace = "http://api.3g.ifeng.com/textview";
	private static final String HISSTORY_ATTRS = "isHistoryDivider";
	public static final int HISTORY_DIVIDER = 0x1;
	public static final int NORMAL_DIVIDER = 0x2;
	
	public DividerLine(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		initial(context, attrs);
	}

	public DividerLine(Context context, AttributeSet attrs) {
		super(context, attrs);
		initial(context, attrs);
	}

	public DividerLine(Context context) {
		super(context);
		initialView(context);
	}
	
	private void initial(Context context, AttributeSet attrs){
		initialView(context);
		boolean isHistoryDivider = attrs.getAttributeBooleanValue(namespace, HISSTORY_ATTRS, false);
		if(isHistoryDivider){
			divider2.setVisibility(View.VISIBLE);
			divider1.setVisibility(View.GONE);
		}else{
			divider2.setVisibility(View.GONE);
			divider1.setVisibility(View.VISIBLE);
		}
		
	}
	
	public void setNormalDivider(boolean isLianghui){
	  if (isLianghui) {
	    divider1.setBackgroundResource(drawable.topic_lianghui_divider);
	  } else {
	    divider1.setBackgroundResource(drawable.channel_list_divider);
	  }
	}
	
	private void initialView(Context context){
		LayoutInflater inflater = LayoutInflater.from(context);
		View view = inflater.inflate(layout.channel_list_divider, this);
		divider1 = (ImageView) view.findViewById(id.divider);
		divider2 = view.findViewById(id.hisstory_tag);
	}
	
	public void changeState(int state){
		switch (state) {
		case HISTORY_DIVIDER:
			divider2.setVisibility(View.VISIBLE);
			divider1.setVisibility(View.GONE);
			break;
		case NORMAL_DIVIDER:			
		default:
			divider2.setVisibility(View.GONE);
			divider1.setVisibility(View.VISIBLE);
			break;
		}		
	}
	
}
