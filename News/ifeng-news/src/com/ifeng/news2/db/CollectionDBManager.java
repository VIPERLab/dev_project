package com.ifeng.news2.db;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.text.TextUtils;
import android.util.Log;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.util.SerializableUtil;
import java.util.ArrayList;


/**
 * @author liu_xiaoliang
 * @description 管理收藏类
 */
public class CollectionDBManager {

	private static final String[] COLUMNS = {
		CollectionDBHelper.DOC_ID_COL, 
		CollectionDBHelper.ITEM_ID_COL,
		CollectionDBHelper.STATUS_COL,
		CollectionDBHelper.HAS_VIDEO,
		CollectionDBHelper.TITLE_COL,
		CollectionDBHelper.THUMBNAIL_COL,
		CollectionDBHelper.LINKS,
		CollectionDBHelper.TYPE_COL,
		CollectionDBHelper.INTRODUCTION_COL,
		CollectionDBHelper.POSITION_COL,
		CollectionDBHelper.TYPE_ICON_COL,
	};

	
	/**
	 *   收藏类型---普通文章 doc
	 */
	public static final String TYPE_DOC = "doc";
	/**
	 *   收藏类型---图集 slide
	 */
	public static final String TYPE_SLIDE = "slide";
	/**
	 *   收藏类型---专题 topic
	 */
	public static final String TYPE_TOPIC = "topic";
	/**
	 *   民调图标类型，将来再添加类型时，添加相应类型String即可
	 */
	public static final String TYPE_ICON_SURVEY = "poll_icon";
	
	
	
	
	private SQLiteOpenHelper helper;

	public CollectionDBManager(Context context){
		helper = new CollectionDBHelper(context);
	}

	/**
	 * @param id 文章短链接
	 * @return boolean 是否已收藏
	 */
	public boolean isCollectioned(String docId){
		if (TextUtils.isEmpty(docId)) 
			return false;

		SQLiteDatabase db = null;
		Cursor cursor = null;
		try {
			db = helper.getReadableDatabase();
			cursor = db.query(CollectionDBHelper.TABLE_NAME, null,
					CollectionDBHelper.DOC_ID_COL+" =? and "+CollectionDBHelper.STATUS_COL+" =? ", new String[]{docId, "true"}, null, null, null);
			while(cursor.moveToNext()){
				return true;
			}
		} catch (Exception e) {
		} finally {
			if (null != cursor) 
				cursor.close();
			if (null != db) 
				db.close();
		}
		return false;
	}

	/**
	 * @param docId 文章短链接
	 * @return boolean 已收藏文章、图集、专题的状态
	 */
	public boolean getCollectionStatusById(String docId){
		if (TextUtils.isEmpty(docId)) 
			return false;

		SQLiteDatabase db = null;
		Cursor cursor = null;
		try {
			db = helper.getReadableDatabase();
			cursor = db.query(CollectionDBHelper.TABLE_NAME, COLUMNS,
					CollectionDBHelper.DOC_ID_COL+" =? ", new String[]{docId}, null, null, null);
			while(cursor.moveToNext()){
				return "true".equals(cursor.getString(2));
			}
		} catch (Exception e) {
			Log.e("tag", "getCollectionStatusById is error");
			e.printStackTrace();
		} finally {
			if (null != cursor) 
				cursor.close();
			if (null != db) 
				db.close();
		}
		return false;
	}
	
	/**
	 * @return  返回所有的收藏列表数据
	 */
	public ArrayList<ListItem> getCollectionListData(){
		Cursor cursor = null;
		SQLiteDatabase db = null;
		ArrayList<ListItem> listItems = new ArrayList<ListItem>();
		try {
			db = helper.getReadableDatabase();
			cursor = db.query(CollectionDBHelper.TABLE_NAME, COLUMNS, CollectionDBHelper.STATUS_COL+" =? ", new String[]{"true"}, null, null, CollectionDBHelper.ID_COL+" DESC");
			while(cursor.moveToNext()){
				ListItem listItem = new ListItem();
				listItem.setDocumentId(cursor.getString(0));
				listItem.setId(cursor.getString(1));
				listItem.setStatus(true);
				listItem.setHasVideo(cursor.getString(3));
				listItem.setTitle(cursor.getString(4));
				listItem.setThumbnail(cursor.getString(5));
				listItem.setLinks(SerializableUtil.deserialize(cursor.getBlob(6)));
				listItem.setType(cursor.getString(7));
				listItem.setIntroduction(cursor.getString(8));
				listItem.setPosition(cursor.getString(9));
				listItem.setTypeIcon(cursor.getString(10));
				listItems.add(listItem);
			}
		} catch (Exception e) {
			Log.e("tag", "getCollectionListData exception");
			e.printStackTrace();
		} finally {
			if (null != cursor) 
				cursor.close();
			if (null != db) 
				db.close();
		}
		return listItems;
	}

	/**
	 * @param item 保存收藏数据
	 */
	public boolean insertCollectionItem(ListItem item){
		Cursor cursor = null;
		SQLiteDatabase db = null;
		try {
			db = helper.getWritableDatabase();
			ContentValues cValues = new ContentValues();
			cValues.put(CollectionDBHelper.DOC_ID_COL, item.getDocumentId());
			cValues.put(CollectionDBHelper.ITEM_ID_COL, item.getId());
			cValues.put(CollectionDBHelper.STATUS_COL, "true");
			cValues.put(CollectionDBHelper.HAS_VIDEO, item.getHasVideo());
			cValues.put(CollectionDBHelper.TITLE_COL, item.getTitle());
			cValues.put(CollectionDBHelper.THUMBNAIL_COL, item.getThumbnail());
			cValues.put(CollectionDBHelper.LINKS, SerializableUtil.serialize(item.getLinks()));
			cValues.put(CollectionDBHelper.TYPE_COL, item.getType());
			cValues.put(CollectionDBHelper.INTRODUCTION_COL, item.getIntroduction());
			cValues.put(CollectionDBHelper.POSITION_COL, item.getPosition());
			cValues.put(CollectionDBHelper.TYPE_ICON_COL, item.getTypeIcon());
			db.insert(CollectionDBHelper.TABLE_NAME, null, cValues);
		} catch (Exception e) {
			Log.e("tag", "insertCollectionItem exception");
			e.printStackTrace();
			return false;
		} finally {
			if (null != cursor) 
				cursor.close();
			if (null != db) 
				db.close();
		}
		return true;
	}

	/**
	 * 删除指定的收藏or全部
	 * @param id  如果id為空 則刪除所有，否則刪除指定docId
	 */
	public void deteleCollectionById(String id){
		SQLiteDatabase db = null;
		try {
			db = helper.getWritableDatabase();
			if (TextUtils.isEmpty(id)) 
				db.execSQL("delete from "+CollectionDBHelper.TABLE_NAME);
			else
				db.execSQL("delete from "+CollectionDBHelper.TABLE_NAME+" where "+CollectionDBHelper.DOC_ID_COL+" =? ", new String[]{id});
		} catch (Exception e) {
			Log.e("tag", "deteleCollectionById exception");
			e.printStackTrace();
		} finally {
			if (null != db) 
				db.close();
		}
	}
	
	/**
	 * 刪除取消收藏的item
	 */
	public void deteleCancelCollection(){
		SQLiteDatabase db = null;
		try {
			db = helper.getWritableDatabase();
			db.execSQL("delete from "+CollectionDBHelper.TABLE_NAME+" where "+CollectionDBHelper.STATUS_COL+" =? ",new String[]{"false"});
		} catch (Exception e) {
			Log.e("tag", "deteleCollection is error");
			e.printStackTrace();
		} finally {
			if (null != db) 
				db.close();
		}
	}
	
	/**
	 * 改变收藏状态
	 * @param id 根据修改状态
	 */
	public void updateCollectionStatus(String id, boolean isCollectioned){
		SQLiteDatabase db = null;
		try {
			db = helper.getWritableDatabase();
			ContentValues cValues = new ContentValues();  
			cValues.put(CollectionDBHelper.STATUS_COL, isCollectioned ? "true" : "false");
		    db.update(CollectionDBHelper.TABLE_NAME, cValues, CollectionDBHelper.DOC_ID_COL+" =? ", new String[]{id});
		} catch (Exception e) {
		} finally {
			if (null != db) 
				db.close();
		}
	}
}
