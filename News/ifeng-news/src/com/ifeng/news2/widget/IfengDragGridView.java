package com.ifeng.news2.widget;

import android.app.Activity;
import android.content.Context;
import android.graphics.Canvas;
import android.text.GetChars;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.GridView;
import android.widget.TextView;

import com.ifeng.news2.R;
import com.ifeng.news2.util.IfengTextViewManager;

public class IfengDragGridView extends GridView {

	public IfengDragGridView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {
		return false;
	}

	@Override
	public boolean onTouchEvent(MotionEvent ev) {
		return false;
	}
}
