package com.ifeng.news2.bean;

import java.io.Serializable;

import android.text.TextUtils;

public class WeatherBean implements Serializable{
	private static final long serialVersionUID = 2170106490690613362L;
	public String timezone;
	public String country;
	public String city_code;
	public String city_name;
	public String city_province;
	public String date_time;
	public String detail_day_info;
	public String iphone_small_day_image;
	public String iphone_small_night_image;
	public String iphone_cover;
	public String iphone_m_new;
	public String detail_day_image;
	public String detail_night_info;
	public String detail_night_image;
	public String detail_night_temperature;
	public String detail_day_temperature;
	public String detail_night_direct;
	public String detail_day_direct;
	public String detail_night_power;
	public String detail_day_power;
	public String moon;
	public String week;
	public WeatherBean() {
	}
	public WeatherBean(String timezone, String country, String city_code,
			String city_name, String city_province, String date_time,
			String detail_day_info, String iphone_small_day_image,
			String iphone_small_night_image, String iphone_cover,
			String iphone_m_new, String detail_day_image,
			String detail_night_info, String detail_night_image,
			String detail_night_temperature, String detail_day_temperature,
			String detail_night_direct, String detail_day_direct,
			String detail_night_power, String detail_day_power, String moon,
			String week) {
		this.timezone = timezone;
		this.country = country;
		this.city_code = city_code;
		this.city_name = city_name;
		this.city_province = city_province;
		this.date_time = date_time;
		this.detail_day_info = detail_day_info;
		this.iphone_small_day_image = iphone_small_day_image;
		this.iphone_small_night_image = iphone_small_night_image;
		this.iphone_cover = iphone_cover;
		this.iphone_m_new = iphone_m_new;
		this.detail_day_image = detail_day_image;
		this.detail_night_info = detail_night_info;
		this.detail_night_image = detail_night_image;
		this.detail_night_temperature = detail_night_temperature;
		this.detail_day_temperature = detail_day_temperature;
		this.detail_night_direct = detail_night_direct;
		this.detail_day_direct = detail_day_direct;
		this.detail_night_power = detail_night_power;
		this.detail_day_power = detail_day_power;
		this.moon = moon;
		this.week = week;
	}
	public String getTimezone() {
		return timezone;
	}
	public void setTimezone(String timezone) {
		this.timezone = timezone;
	}
	public String getCountry() {
		return country;
	}
	public void setCountry(String country) {
		this.country = country;
	}
	public String getCity_code() {
		return city_code;
	}
	public void setCity_code(String city_code) {
		this.city_code = city_code;
	}
	public String getCity_name() {
		return city_name;
	}
	public void setCity_name(String city_name) {
		this.city_name = city_name;
	}
	public String getCity_province() {
		return city_province;
	}
	public void setCity_province(String city_province) {
		this.city_province = city_province;
	}
	public String getDate_time() {
		if (TextUtils.isEmpty(date_time)) 
			return "";
		return date_time;
	}
	public void setDate_time(String date_time) {
		this.date_time = date_time;
	}
	public String getDetail_day_info() {
		return detail_day_info;
	}
	public void setDetail_day_info(String detail_day_info) {
		this.detail_day_info = detail_day_info;
	}
	public String getIphone_small_day_image() {
		return iphone_small_day_image;
	}
	public void setIphone_small_day_image(String iphone_small_day_image) {
		this.iphone_small_day_image = iphone_small_day_image;
	}
	public String getIphone_small_night_image() {
		return iphone_small_night_image;
	}
	public void setIphone_small_night_image(String iphone_small_night_image) {
		this.iphone_small_night_image = iphone_small_night_image;
	}
	public String getIphone_cover() {
		return iphone_cover;
	}
	public void setIphone_cover(String iphone_cover) {
		this.iphone_cover = iphone_cover;
	}
	public String getIphone_m_new() {
		return iphone_m_new;
	}
	public void setIphone_m_new(String iphone_m_new) {
		this.iphone_m_new = iphone_m_new;
	}
	public String getDetail_day_image() {
		return detail_day_image;
	}
	public void setDetail_day_image(String detail_day_image) {
		this.detail_day_image = detail_day_image;
	}
	public String getDetail_night_info() {
		return detail_night_info;
	}
	public void setDetail_night_info(String detail_night_info) {
		this.detail_night_info = detail_night_info;
	}
	public String getDetail_night_image() {
		return detail_night_image;
	}
	public void setDetail_night_image(String detail_night_image) {
		this.detail_night_image = detail_night_image;
	}
	public String getDetail_night_temperature() {
		return detail_night_temperature;
	}
	public void setDetail_night_temperature(String detail_night_temperature) {
		this.detail_night_temperature = detail_night_temperature;
	}
	public String getDetail_day_temperature() {
		return detail_day_temperature;
	}
	public void setDetail_day_temperature(String detail_day_temperature) {
		this.detail_day_temperature = detail_day_temperature;
	}
	public String getDetail_night_direct() {
		return detail_night_direct;
	}
	public void setDetail_night_direct(String detail_night_direct) {
		this.detail_night_direct = detail_night_direct;
	}
	public String getDetail_day_direct() {
		return detail_day_direct;
	}
	public void setDetail_day_direct(String detail_day_direct) {
		this.detail_day_direct = detail_day_direct;
	}
	public String getDetail_night_power() {
		return detail_night_power;
	}
	public void setDetail_night_power(String detail_night_power) {
		this.detail_night_power = detail_night_power;
	}
	public String getDetail_day_power() {
		return detail_day_power;
	}
	public void setDetail_day_power(String detail_day_power) {
		this.detail_day_power = detail_day_power;
	}
	public String getMoon() {
		return moon;
	}
	public void setMoon(String moon) {
		this.moon = moon;
	}
	public String getWeek() {
		if (TextUtils.isEmpty(week)) 
			return "";
		return week;
	}
	public void setWeek(String week) {
		this.week = week;
	}
	
}
