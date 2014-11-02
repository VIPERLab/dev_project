package com.ifeng.news2.weather;

import com.ifeng.news2.bean.WeatherBean;

public interface WeatherCallback {
	public void Success(WeatherBean weatherBean);
	public void Fail();
}
