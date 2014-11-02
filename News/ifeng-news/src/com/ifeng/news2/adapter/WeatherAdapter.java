package com.ifeng.news2.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.ifeng.news2.R;
import com.ifeng.news2.bean.WeatherBean;
import com.ifeng.news2.weather.AsyncImageLoader;
import com.ifeng.news2.weather.WeatherManager;

public class WeatherAdapter extends BaseAdapter{
	public Context context;
	public ArrayList<WeatherBean> weathers;
	public LayoutInflater inflater;
	AsyncImageLoader asyncImageLoader = new AsyncImageLoader();
	public WeatherAdapter(Context context,ArrayList<WeatherBean> weatherBeans){
		this.context = context;
		this.weathers = weatherBeans;
	}
	@Override
	public int getCount() {
		return weathers.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return weathers.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		if(convertView==null){
			inflater= LayoutInflater.from(context);
			convertView = inflater.inflate(R.layout.weather_item,null);
		}
		WeatherBean weatherBean = weathers.get(position);
		TextView weekly = (TextView)convertView.findViewById(R.id.weekly);
		TextView date = (TextView)convertView.findViewById(R.id.date);
		TextView temperature = (TextView)convertView.findViewById(R.id.temperature);
		final ImageView icon = (ImageView)convertView.findViewById(R.id.weather_icon);
		weekly.setText(weatherBean.getWeek());
		date.setText(weatherBean.getDate_time());
		temperature.setText(WeatherManager.getTemperatureText(weatherBean));
		Bitmap cacheImage = asyncImageLoader.loadDrawable(weatherBean.getIphone_m_new(),
				new AsyncImageLoader.ImageCallback() {
			public void imageLoaded(Bitmap bitmap) {
				icon.setImageBitmap(bitmap);
			}
		});
		if (cacheImage != null) {
			icon.setImageBitmap(cacheImage);
		}
		return convertView;
	}
	public void updateDatas(ArrayList<WeatherBean> weathers){
		this.weathers = weathers;
		notifyDataSetChanged();
	}

}
