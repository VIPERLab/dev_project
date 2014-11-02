package com.ifeng.news2.util;

import android.content.Context;
import android.view.View;
import android.view.inputmethod.InputMethodManager;

public class SoftKeyUtil {

	public static void showSoftInput(Context context,View targetView,boolean isShow) {
		if (isShow) {
			targetView.requestFocus();
			InputMethodManager imm = (InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE);
			imm.showSoftInput(targetView, 0);
		} else {
			((InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE))
					.hideSoftInputFromWindow(
							targetView.getWindowToken(),
							InputMethodManager.HIDE_NOT_ALWAYS);
		}
	}
}
