package com.qad.form;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import com.qad.view.PageListView;
import com.qad.view.PageListView.PageAdapter;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

public abstract class BasePageAdapter<T> extends BaseAdapter implements
		PageAdapter<List<T>> {

	protected List<T> items;
	protected Context ctx;

	public List<T> getItems() {
		return items;
	}

	public BasePageAdapter(Context ctx) {
		this.ctx = ctx;
	}

	public void setItems(List<T> items) {		
			this.items = items;
	}
	
	@Override
	public int getCount() {
		return items.size();
	}

	@Override
	public T getItem(int position) {
		return items.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		if (convertView == null) {
			convertView = LayoutInflater.from(ctx).inflate(getResource(), null);
		}
		renderConvertView(position, convertView);
		return convertView;
	}

	@Override
	public void addPage(List<T> pageContent) {
		if (pageContent instanceof List) {
			List<T> list = (List<T>) pageContent;
			if (items != null) {
				items.addAll(list);
				notifyDataSetChanged();
			}
		}
	}

	/**
	 * 需要渲染的视图的ID
	 * 
	 * @return
	 */
	protected abstract int getResource();

	/**
	 * 渲染视图
	 * 
	 * @param position
	 * @param convertView
	 */
	protected abstract void renderConvertView(int position, View convertView);

}
