package com.wangmingjob.androidkit.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by wangming on 11/25/14.
 */
public abstract class GenericAdapter<T> extends BaseAdapter {
	private List<T> mDataList = new ArrayList<T>();
	private Context mCurrentContext;
	private final int mItemLayoutId;

	public GenericAdapter(Context context, int itemLayoutId) {
		mCurrentContext = context;
		mItemLayoutId = itemLayoutId;
	}


	/**
	 * reset dataList
	 *
	 * @param dataList
	 */
	public void setData(List<T> dataList) {
		mDataList.clear();
		addData(dataList);
	}

	/**
	 * append data to list
	 *
	 * @param dataList
	 */
	public void addData(List<T> dataList) {
		mDataList.addAll(dataList);
		notifyDataSetChanged();
	}

	@Override
	public int getCount() {
		return mDataList.size();
	}


	@Override
	public Object getItem(int position) {
		return mDataList.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		ViewHolder holder = ViewHolder.get(mCurrentContext, convertView, mItemLayoutId);
		fillViewData(holder, (T)getItem(position));
		return holder.getConvertView();

	}

	public abstract void fillViewData(ViewHolder holder, T data);
}
