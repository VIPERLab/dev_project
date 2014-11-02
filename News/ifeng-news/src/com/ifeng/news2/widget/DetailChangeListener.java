package com.ifeng.news2.widget;

import java.util.List;

import android.view.View;

public interface DetailChangeListener {

	/**
	 * 请求载入详情。本方法是一个同步方法
	 * @param detail 当前的内容视图
	 * @param detailIndex 索引列表
	 * @param index 索引所在位置
	 */
	void loadDetail(View detail,List<?> detailIndex,int index);
	
}
