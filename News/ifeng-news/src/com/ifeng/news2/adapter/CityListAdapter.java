package com.ifeng.news2.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ifeng.news2.R;

public class CityListAdapter extends BaseAdapter{
	private ArrayList<String> citys;
	private Context context;
	private LayoutInflater inflater;
	public CityListAdapter(Context context,ArrayList<String> citys){
		this.context = context;
		this.citys = citys;
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return citys.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return citys.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}
	public void updateDatas(ArrayList<String> datas){
		this.citys =datas;
		notifyDataSetChanged();
	}
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		if(convertView==null){
			inflater = LayoutInflater.from(context);
			convertView = inflater.inflate(R.layout.city_item, null);
		}
		String cityName = citys.get(position);
		TextView cityView = (TextView)convertView.findViewById(R.id.city);
		cityView.setText(cityName);
		return convertView;
	}
	
}
