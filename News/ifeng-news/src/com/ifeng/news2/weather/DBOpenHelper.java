package com.ifeng.news2.weather;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.ifeng.news2.Config;

public class DBOpenHelper extends SQLiteOpenHelper {
	private static final int VERSION = 3;
	public DBOpenHelper(Context context) {
		super(context,Config.CITYS_DB_PATH, null, VERSION);
	}
	@Override
	public void onCreate(SQLiteDatabase db) {
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
	}

}
