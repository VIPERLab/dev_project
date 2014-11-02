package com.ifeng.news2.util;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.LinearLayout.LayoutParams;

import com.ifeng.news2.R;

public class FunctionButtonWindow {

	public static final String TYPE_FUNCTION_BUTTON_WHITE = "WHITE";
	public static final String TYPE_FUNCTION_BUTTON_BLACK = "BLACK";

	private int screenWidth = 0;
	public boolean isCollected  = false;
	
	private WindowPrompt window;
	private Context context = null;
	private LayoutInflater inflater;
	private PopupWindow functionButWindow;
	
	private FunctionButtonInterface functionButtonInterface;
	private SportLiveButtonInterface sportLiveButtonInterface;

	public void setSportLiveButtonInterface(
			SportLiveButtonInterface sportLiveButtonInterface) {
		this.sportLiveButtonInterface = sportLiveButtonInterface;
	}

	public FunctionButtonWindow(Context context){
		init(context);
	}

	public void setFunctionButtonInterface(
			FunctionButtonInterface functionButtonInterface) {
		this.functionButtonInterface = functionButtonInterface;
	}

	private void init(Context context){
		
		this.context = context;
		inflater = LayoutInflater.from(context);
		window = WindowPrompt.getInstance(context);
		screenWidth = ((Activity)context).getWindowManager().getDefaultDisplay().getWidth();
	}
	
	public void showMoreFunctionButtons(View view, ArrayList<String> toolsName, String type){
		int buttonCount = -1;
		if (null == toolsName ||(buttonCount = toolsName.size()) <= 0) 
			return;
		LinearLayout functionButVector = (LinearLayout)inflater.inflate(R.layout.more_function, null);
		for (int i = 0; i < buttonCount; i++) {
			LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
			if (0 != i) 
				functionButVector.addView(getFunctionButtonsDivider(type));
			functionButVector.addView(addButtonsView(toolsName.get(i), type), params );
		}

		if (TYPE_FUNCTION_BUTTON_WHITE.equals(type)) 
			functionButVector.setBackgroundDrawable(context.getResources().getDrawable(R.drawable.more_function_white_bg));
		else 
			functionButVector.setBackgroundDrawable(context.getResources().getDrawable(R.drawable.more_function_black_bg));

		functionButWindow = new PopupWindow(functionButVector, LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		functionButWindow.setFocusable(true);
		functionButWindow.setOutsideTouchable(true);
		functionButWindow.setBackgroundDrawable(new BitmapDrawable());
		functionButWindow.showAtLocation(view, Gravity.BOTTOM|Gravity.RIGHT, leftOffset(type), topOffset());
	}

	private int leftOffset(String type){
		int leftOffset = 0;//左偏移量
		if (TYPE_FUNCTION_BUTTON_WHITE.equals(type)) {
			if (320 >= screenWidth) 
				leftOffset = 4; 
			else if (480 >= screenWidth) 
				leftOffset = 8; 
			else
				leftOffset = 10;
		}else 
			leftOffset = 0;
		return leftOffset;
	}

	private int topOffset(){
		return functionButtonInterface.getBottomTabbarHeight()+5;
	}

	private View getFunctionButtonsDivider(String type){
		View view = inflater.inflate(R.layout.more_function_buttons_divider, null);
		if (TYPE_FUNCTION_BUTTON_WHITE.equals(type)) 
			view.setBackgroundDrawable(context.getResources().getDrawable(R.drawable.more_function_divider_white));
		else 
			view.setBackgroundDrawable(context.getResources().getDrawable(R.drawable.more_function_divider_black));
		return view;
	}


	private View addButtonsView(final String buttonName, String type){

		TextView functionBut = (TextView) inflater.inflate(R.layout.more_function_buttons, null);
		if (TYPE_FUNCTION_BUTTON_BLACK.equals(type)){
			functionBut.setTextAppearance(context, R.style.gallery_title_bar_button);
			functionBut.setBackgroundDrawable(context.getResources().getDrawable(R.drawable.more_function_buttons_black_bg));
		}
		else{
			functionBut.setTextAppearance(context, R.style.detail_title_bar_button);
			functionBut.setBackgroundDrawable(context.getResources().getDrawable(R.drawable.more_function_buttons_white_bg));
		} 

		functionBut.setWidth(screenWidth/4-leftOffset(type));
		functionBut.setHeight(topOffset());//未调整
		Drawable drawable = null;
		if ("下载".equals(buttonName)) {
			if (TYPE_FUNCTION_BUTTON_BLACK.equals(type))
				drawable = context.getResources().getDrawable(R.drawable.gallery_download);
			else {}
		} else if ("收藏".equals(buttonName)){
			functionButtonInterface.initCollectViewState();
			if (TYPE_FUNCTION_BUTTON_BLACK.equals(type)){
				if (isCollected)
					drawable = context.getResources().getDrawable(R.drawable.gallery_collectioned);
				else
					drawable = context.getResources().getDrawable(R.drawable.gallery_collection);
			} else {
				if (isCollected)
					drawable = context.getResources().getDrawable(R.drawable.collectioned);
				else
					drawable = context.getResources().getDrawable(R.drawable.collection);
			}
		} else if ("分享".equals(buttonName)){
			if (TYPE_FUNCTION_BUTTON_BLACK.equals(type))
				drawable = context.getResources().getDrawable(R.drawable.gallery_share);
			else 
				drawable = context.getResources().getDrawable(R.drawable.share);
		} else if("战报".equals(buttonName)){
			if(TYPE_FUNCTION_BUTTON_WHITE.equals(type)){
				drawable = context.getResources().getDrawable(R.drawable.sport_live_report_logo);
			}else{
				//TODO
			}
		} else if("数据".equals(buttonName)){
			if(TYPE_FUNCTION_BUTTON_WHITE.equals(type)){
				drawable = context.getResources().getDrawable(R.drawable.sport_live_data_logo);
			}else{
				//TODO
			}
		}
		functionBut.setText(buttonName);
		drawable.setBounds(0, 0, drawable.getMinimumWidth(), drawable.getMinimumHeight());  
		functionBut.setCompoundDrawables(drawable,null,null,null);
		functionBut.setPadding(screenWidth/40, 0, screenWidth/40, 0);
		functionBut.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				if ("下载".equals(buttonName)) {
					functionButtonInterface.downloadPicture();
				} else if ("收藏".equals(buttonName)) {
					functionButtonInterface.onCollect();
				}  else if ("分享".equals(buttonName)) {
					functionButtonInterface.showShareView();
				}  else if("数据".equals(buttonName)){
					if(null != sportLiveButtonInterface){
						sportLiveButtonInterface.redirectToDataPage();
					}
				} else if("战报".equals(buttonName)){
					if(null != sportLiveButtonInterface){
						sportLiveButtonInterface.redirectToReportPage();
					}
				}
				functionButWindow.dismiss();
			}
		});
		return functionBut;
	}
	
	public void showWindowControl(Drawable drawable, String prompt){
		int width = screenWidth/2;
		int hight = (width*8)/19;
		window.showWindowPrompt(drawable, prompt, width, hight);
	}
	
    public interface FunctionButtonInterface   
    {  
        public void downloadPicture();
        public void showShareView();
        public void initCollectViewState();
        public boolean onCollect();
        public int  getBottomTabbarHeight();
     } 
    
    public interface SportLiveButtonInterface
    {
    	void redirectToDataPage();
    	void redirectToReportPage();
    }
}
