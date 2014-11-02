package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

/** 
 * 
 * 一周的天气的信息
 * 
 * @author SunQuan: 
 * @version 创建时间：2013-11-25 上午10:58:17 
 * 类说明 
 */

public class WeatherBeans extends ArrayList<WeatherBean> implements Serializable{

	private static final long serialVersionUID = 6758479497300464568L;

	ArrayList<WeatherBean> weatherBeans = new ArrayList<WeatherBean>();

	public ArrayList<WeatherBean> getWeatherBeans() {
		return weatherBeans;
	}

	public void setWeatherBeans(ArrayList<WeatherBean> weatherBeans) {
		this.weatherBeans = weatherBeans;
	}
	
	
}
