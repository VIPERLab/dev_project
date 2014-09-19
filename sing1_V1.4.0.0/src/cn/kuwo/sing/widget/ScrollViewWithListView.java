/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.widget;

/**
 * @Package cn.kuwo.sing.widget
 *
 * @Date 2013-12-27, 下午3:00:44
 *
 * @Author wangming
 *
 */

import android.widget.ListView;

public class ScrollViewWithListView extends ListView {
	public ScrollViewWithListView(android.content.Context context,
			android.util.AttributeSet attrs) {
		super(context, attrs);
	}

	/**
	* Integer.MAX_VALUE >> 2,如果不设置，系统默认设置是显示两条
	*/
	public void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		int expandSpec = MeasureSpec.makeMeasureSpec(Integer.MAX_VALUE >> 2,
				MeasureSpec.AT_MOST);
		super.onMeasure(widthMeasureSpec, expandSpec);
	}
}

