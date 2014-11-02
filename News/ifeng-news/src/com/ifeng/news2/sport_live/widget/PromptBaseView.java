package com.ifeng.news2.sport_live.widget;

import com.qad.util.WToast;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.EditText;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.inputmethod.InputMethodManager;

/**
 * 直播页的视图的父类，所有直播页的底部视图都继承该抽象类
 * 
 * @author SunQuan
 * 
 */
public abstract class PromptBaseView implements
		OnClickListener {
	
	protected Context context;
	private View container;
	protected WToast toast;
	protected LayoutInflater inflater;
	protected static final String EMPTY_TEXT = "";
	protected ProgressDialog loadingDialog;
	protected static String MY_USER_NAME = EMPTY_TEXT;
	protected Bundle bundle;
	
	public PromptBaseView(Context context,Bundle bundle) {
		this.bundle = bundle;
		this.context = context;
		inflater = LayoutInflater.from(context);
		toast = new WToast(context);
		onCreate();				
		setListener();
	}
	
	public View getContainer() {
		if(container.getLayoutParams() == null) {
			container.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
		}
		return container;
	};
	
	protected void setContainer(int layout){
		container = inflater.inflate(layout, null);
	}

	protected View findViewById(int resId) {
		return container.findViewById(resId);
	}

	/**
	 * 初始化控件
	 * 
	 * @param context
	 */
	protected abstract void onCreate();

	/**
	 * 为子控件设置监听
	 */
	protected void setListener(){}

	/**
	 * 切换回视图时调用该方法
	 * 
	 * @param context
	 */
	public void onResume() {
	}

	/**
	 * 切换到其他视图时调用该方法
	 * 
	 * @param context
	 */
	public void onPause() {
	}

	/**
	 * 判断输入的内容是否为空
	 * 
	 * @param editText
	 * @return
	 */
	protected boolean isEmptyInput(EditText editText) {
		if (TextUtils.isEmpty(editText.getText().toString().trim())) {
			return true;
		}
		return false;
	}

	/**
	 * 切换软键盘的状态
	 * 
	 * @param context
	 * @param targetView
	 * @param isShow
	 *            如果isShow为true，则显示软键盘，否则隐藏软键盘
	 */
	protected void showSoftInput(Context context, View targetView,
			boolean isShow) {
		if (isShow) {
			targetView.requestFocus();
			InputMethodManager imm = (InputMethodManager) context
					.getSystemService(Context.INPUT_METHOD_SERVICE);
			imm.showSoftInput(targetView, InputMethodManager.RESULT_SHOWN);
			imm.toggleSoftInput(InputMethodManager.SHOW_FORCED,
					InputMethodManager.HIDE_IMPLICIT_ONLY);

		} else {
			targetView.clearFocus();
			((InputMethodManager) context
					.getSystemService(Context.INPUT_METHOD_SERVICE))
					.hideSoftInputFromWindow(targetView.getWindowToken(), 0);
		}
	}
	
	protected void createDialog(String message,Context context) {
		loadingDialog = ProgressDialog.show(context, "", message,
				true, true, new OnCancelListener() {
					@Override
					public void onCancel(DialogInterface dialog) {
						dialog.dismiss();
					}
				});
	}

	protected void dismissDialog() {
		if (loadingDialog != null)
			loadingDialog.dismiss();
	}
	
	public void setBundle(Bundle bundle){
		this.bundle = bundle;
	}
	
	public Bundle getBundle(){
		return bundle;
	}
}
