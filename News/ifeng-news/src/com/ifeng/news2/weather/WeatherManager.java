package com.ifeng.news2.weather;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Type;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.util.Log;

import com.google.myjson.Gson;
import com.google.myjson.reflect.TypeToken;
import com.ifeng.news2.Config;
import com.ifeng.news2.bean.WeatherBean;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.share.util.HttpUtils;
import com.qad.lang.Files;
import com.qad.net.HttpManager;
public class WeatherManager {
	public static ArrayList<WeatherBean> weatherList=new ArrayList<WeatherBean>();
	public static WeatherBean todayWeather;
	public final static String default_city="北京";
	public static String current_city = "";
	public static HashMap<String,String> cityMap;
	public final static int SEARCHED_CITY_NUM = 7;
	public final static String SEARCHED_CITY_DAT = "searched.dat";
	public static ArrayList<String> searchedCitysList;
	public static ArrayList<String> default_seached_city;
	static{
		default_seached_city = new ArrayList<String>();
		default_seached_city.add("北京");
		default_seached_city.add("上海");
		default_seached_city.add("广州");
		default_seached_city.add("深圳");
		default_seached_city.add("成都");
		default_seached_city.add("天津");
		default_seached_city.add("重庆");
	}
	/**
	 * 获取城市名称
	 * @param weatherCity
	 * @return
	 */
	public  static String getWeatherCityName() throws Exception{
		return  HttpManager.getHttpText(getWeatherCityUrl());
	}
	public static String getCurrentCity(Context context){
		if (TextUtils.isEmpty(current_city)) {
			current_city = getChooseCity(context);
		}
		return current_city;
	}
	private static String getWeatherIp() throws Exception{
		String weatherIp = HttpManager.getHttpText(ParamsManager.addParams(Config.WEATHER_IP_URL));
		return weatherIp;
	}
	public static void initWeatherDatasByCity(String city){
		try {
			parseWeatherJson(city);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	public static String getChooseCity(Context context){
		SharedPreferences shareCity = context.getSharedPreferences("city",
				Context.MODE_PRIVATE);
		String name=null;
		try {
			name = shareCity.getString("cityName",null);
			if(name==null)name=getWeatherCityName();
		} catch (Exception e) {
			return default_city;
		}
		return name;
	}
	public static void saveChooseCity(Context context,String city){
		SharedPreferences shareCity = context.getSharedPreferences("city",
				Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = shareCity.edit();
		editor.putString("cityName", city);
		editor.commit();
	}
	public static void initWeatherDefaultCity(Context context){
		Log.i("news", "initWeatherDefaultCity");
		try {
			initWeatherDatasByCity(getChooseCity(context));
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
	public static void parseWeatherJson(String city){
		try {
			if(city==null || city.length()==0){
				city = default_city;
			}
			String weatherJson = getWeatherJson(city);
			if(weatherJson!=null && weatherJson.length()>0){
				current_city = city;
				Gson gson = new Gson();
				Type type = new TypeToken<ArrayList<WeatherBean>>(){}.getType();
				weatherList=new ArrayList<WeatherBean>();
				weatherList = gson.fromJson(weatherJson, type);
				if(weatherList.size()>0){
					todayWeather  = weatherList.get(0);
					
					weatherList.remove(0);
				}
			}
		} catch (Exception e) {
		}
	}
	private static String getWeatherJson(String city) throws Exception{
		return HttpManager.getHttpText(getWeatherDetailUrl(city));
	}
	private static String getWeatherCityUrl() throws Exception{
		return ParamsManager.addParams(Config.WEATHER_CITY_BY_IP_URL + getWeatherIp());
	}
	public static String getWeatherDetailUrl(String city) {
		try {
			return ParamsManager.addParams(Config.WEATHER_DETAIL_BY_CITY_URL + URLEncoder.encode(city, "utf-8"));
		} catch (UnsupportedEncodingException e) {			
			e.printStackTrace();
			return "";
		}
	}
	/**
	 * 更新天气信息
	 * @param city
	 */
	public static void updateWeatherByCity(String city){
		parseWeatherJson(city);
	}
	/**
	 * 获取天气数据
	 * @return
	 */
	public static ArrayList<WeatherBean> getAllWeathers(Context context){
		if(weatherList==null || weatherList.size()==0){
			initWeatherDefaultCity(context);
		}
		return weatherList;
	}
	public static WeatherBean getTodayWeather(){
		return todayWeather;
	}
	public static String getTemperatureText(WeatherBean weather){
		String lowTemperature = weather.getDetail_night_temperature();
		String highTemperature = weather.getDetail_day_temperature();
		int count = 0;
		if (TextUtils.isEmpty(lowTemperature)) {
			count++;
			lowTemperature = "";
		}
		if (TextUtils.isEmpty(highTemperature)) {
			count++;
			highTemperature = "";
		}
		if (2 != count) {
			return lowTemperature+"~"+highTemperature+"℃";
		} else {
			return "";
		}
	}
	public static Drawable getWeatherIndexDrawable(Context context,WeatherBean weather){
		try {
			Resources res=context.getResources();  
			String detail_day_image  =  weather.getDetail_day_image();
			int imageIcon=res.getIdentifier(cutImageUrl(detail_day_image),"drawable",context.getPackageName()); 
			return context.getResources().getDrawable(imageIcon);
		} catch (Exception e) {
			return getWeatherDefaultDrawable(context);
		}
	}
	private static Drawable getWeatherDefaultDrawable(Context context){
		int defaultIcon=context.getResources().getIdentifier("weather_default","drawable",context.getPackageName()); 
		return context.getResources().getDrawable(defaultIcon);
	}
	private  static String cutImageUrl(String imageUrl){
		if(imageUrl==null || imageUrl.length()==0)return "weather_default";
		Pattern pattern =Pattern.compile("cool/s/(.*).png");
		Matcher matcher = pattern.matcher(imageUrl);
		if(matcher.find()){
			return matcher.group(1);

		}
		return "weather_default";
	}
	// 从网络上取数据方法
	public static Bitmap loadWeatherBitmap(String imageUrl) {
		try {
			InputStream is = HttpUtils.getInputStream(imageUrl);
			return BitmapFactory.decodeStream(is);
		} catch (Exception e) {
			return null;
		}
	}
	public static Boolean isTodayWeather(String date){
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
		String nowDate=simpleDateFormat.format(new Date());
		if(nowDate.equals(date)){
			return true;
		}
		return false;
	}
	public static void resetSearchedCitys(String searchCity){
		if(!getDefaultSearchedMap().containsKey(searchCity)){
			ArrayList<String> tempList = new ArrayList<String>();
			tempList.add(searchCity);
			for(int i=0;i<SEARCHED_CITY_NUM-1;i++){
				tempList.add(searchedCitysList.get(i));
			}
			searchedCitysList=tempList;
		}

	}
	public static void saveSearchedCitys(Context context){
		try {
			Files.serializeObject(context.openFileOutput(SEARCHED_CITY_DAT, Context.MODE_PRIVATE),searchedCitysList);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	@SuppressWarnings("unchecked")
	public static void initSearchedCitys(Context context){
		try {
			searchedCitysList = new ArrayList<String>(SEARCHED_CITY_NUM);
			searchedCitysList =(ArrayList<String>) Files.deserializeObject(context.openFileInput(SEARCHED_CITY_DAT));
		} catch (Exception e) {
			searchedCitysList = getDefaultSearchedList(); 
		}
		if(searchedCitysList==null || searchedCitysList.size()==0){
			searchedCitysList = getDefaultSearchedList(); 
		}
	}
	private static HashMap<String,String> getDefaultSearchedMap(){
		HashMap<String,String> searchedCitysMap = new HashMap<String, String>();
		for(int i=0;i<searchedCitysList.size();i++){
			searchedCitysMap.put(searchedCitysList.get(i),null);
		}
		return searchedCitysMap;
	}
	private static ArrayList<String> getDefaultSearchedList(){
		
		return default_seached_city;
	}
	public static ArrayList<String> getSearchedCitysList(Context context){
		if(searchedCitysList==null || searchedCitysList.size()==0){
			initSearchedCitys(context);
		}
		return searchedCitysList;
	}
	public static Boolean isCitysDBExist(){
		File dbFile = new File(Config.CITYS_DB_PATH);
		if(dbFile.exists()){
			return true;
		}
		return false;
	}
	public static void copyDBDatas(Context context){
		try {
			InputStream assetsDB = context.getAssets().open(Config.CITYS_DB_NAME);
			FileOutputStream dbOut = context.openFileOutput(Config.CITYS_DB_NAME, Context.MODE_PRIVATE);
			byte[] buffer = new byte[1024];
			int length;
			while ((length = assetsDB.read(buffer)) > 0) {
				dbOut.write(buffer, 0, length);
			}
			dbOut.flush();
			dbOut.close();
			assetsDB.close();
			Log.i("news", "db copy end");
		} catch (Exception e) {
			e.printStackTrace();
		} 
	}
}
