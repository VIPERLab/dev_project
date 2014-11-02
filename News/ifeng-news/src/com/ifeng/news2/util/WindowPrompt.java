package com.ifeng.news2.util;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.ifeng.news2.R;


/**
 * @author liu_xiaoliang
 * @description  窗口提示控件
 */
public class WindowPrompt {

	public static final double TOAST_PER_WIDTH = 3.0/5;
	public static final double TOAST_PER_HEIGHT = 8.0/45;
	
	private Toast toast;
	@SuppressWarnings("unused")
	private Context context;
	private LayoutInflater inflater;
	
	private  int height =0;
	private  int width = 0;
	
	private static WindowPrompt windowPrompt = null;
	
	
	public static WindowPrompt getInstance(Context context) {
		if(windowPrompt == null) {
			windowPrompt = new WindowPrompt(context);
		}
		return windowPrompt;
	}
	
	private WindowPrompt(Context context){
		this.context = context;
		toast = new Toast(context);
		inflater = LayoutInflater.from(context);
		width = (int)(DeviceUtils.getWindowWidth(context)*WindowPrompt.TOAST_PER_WIDTH);
		height = (int)(DeviceUtils.getWindowWidth(context)*WindowPrompt.TOAST_PER_HEIGHT);		
	}

	
	/**
	 * @param drawable 自定义图标
	 * @param prompt   提示语
	 */
	public void showWindowPrompt(Drawable drawable, String prompt){
		showWindowPrompt(drawable, prompt, 30, 25, 30, 25);
	}
	
	/**
	 * 简易提示框
	 * @param drawable 自定义图标
	 * @param prompt   提示语
	 * @param width    窗口宽度
	 * @param hight    窗口高度
	 */
	public void showWindowPrompt(Drawable drawable, String prompt, int width, int hight){
		LinearLayout controlView = (LinearLayout)inflater.inflate(R.layout.window_control, null);
		controlView.setMinimumWidth(width);
		controlView.setMinimumHeight(hight);
		ImageView iconView = (ImageView) controlView.findViewById(R.id.prompt_icon);
		TextView promptView = (TextView) controlView.findViewById(R.id.prompt);
		if (null == drawable) 
			iconView.setVisibility(View.GONE);
		else 
			iconView.setBackgroundDrawable(drawable);
		promptView.setText(prompt);
		toast.setDuration(Toast.LENGTH_SHORT);
		toast.setView(controlView);
		toast.setGravity(Gravity.CENTER, 0, 0);
		toast.show();
	}
	
	public void showWindowPrompt(Drawable drawable, String prompt, int left, int top, int right, int bottom){
		LinearLayout controlView = (LinearLayout)inflater.inflate(R.layout.window_control, null);
		controlView.setPadding(left, top, right, bottom);
		ImageView iconView = (ImageView) controlView.findViewById(R.id.prompt_icon);
		TextView promptView = (TextView) controlView.findViewById(R.id.prompt);
		if (null == drawable) 
			iconView.setVisibility(View.GONE);
		else 
			iconView.setBackgroundDrawable(drawable);
		promptView.setText(prompt);
		toast.setDuration(Toast.LENGTH_SHORT);
		toast.setView(controlView);
		toast.setGravity(Gravity.CENTER, 0, 0);
		toast.show();
	}
	
	

	
	/**
	 * 收藏提示框
	 * @param drawable 自定义图标
	 * @param prompt   提示语
	 * @param width    窗口宽度
	 * @param hight    窗口高度
	 */
	public void showWindowStorePrompt(int drawable, int title,int message){
		LinearLayout controlView = (LinearLayout)inflater.inflate(R.layout.window_store_control, null);
		
		controlView.setMinimumWidth(width);
		controlView.setMinimumHeight(height);
		ImageView iconView = (ImageView) controlView.findViewById(R.id.prompt_iconS);
		TextView promptView = (TextView) controlView.findViewById(R.id.promptS);
		TextView promptIView = (TextView) controlView.findViewById(R.id.promptI);
		ImageView spView = (ImageView) controlView.findViewById(R.id.m_spinner);
		spView.getBackground().setAlpha(220);
		LinearLayout linLeft = (LinearLayout)controlView.findViewById(R.id.promp_1);
		LinearLayout linRight = (LinearLayout)controlView.findViewById(R.id.promp_2);
		linLeft.getBackground().setAlpha(220);
		linRight.getBackground().setAlpha(220);
		if (0 == drawable) 
			iconView.setVisibility(View.GONE);
		else 
			iconView.setBackgroundResource(drawable);
		
		promptView.setText(title);
		promptIView.setText(message);
		toast.setDuration(Toast.LENGTH_SHORT);
		toast.setView(controlView);
		toast.setGravity(Gravity.CENTER, 0, 0);
		toast.show();
	}
	
}
