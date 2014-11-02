package com.ifeng.news2.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.GridView;

public class IfengGridView extends GridView {

	public IfengGridView(Context context) {
		super(context);
	}

	public IfengGridView(Context context, AttributeSet attrs) {
		super( context, attrs );
	}

	public IfengGridView(Context context, AttributeSet attrs, int defStyle) {
		super( context, attrs, defStyle );
	}

	public void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
	{
		int expandSpec = MeasureSpec.makeMeasureSpec(Integer.MAX_VALUE >> 2,
				MeasureSpec.AT_MOST);
		super.onMeasure(widthMeasureSpec, expandSpec);
	}
}
