package com.ifeng.news2.weather;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

public class WeatherDBManager {
	private DBOpenHelper dbOpenHelper;
	private SQLiteDatabase db ;
	public WeatherDBManager(Context context) {
		this.dbOpenHelper = new DBOpenHelper(context);
	}
	public Boolean isFindCity(String city){
		db = dbOpenHelper.getReadableDatabase();
		Cursor cursor = db.query("cityname", new String[]{"name"}, "name=?", new String[]{city}, 
				null, null, null);
		if(cursor!=null && cursor.moveToNext()){
			String name = cursor.getString(cursor.getColumnIndex("name"));
			if(name!=null && name.length()>0){
				return true;
			}
		}
		return false;
	}
	public void closeDB(){
		if(db!=null){
			db.close();
		}
	}
}
