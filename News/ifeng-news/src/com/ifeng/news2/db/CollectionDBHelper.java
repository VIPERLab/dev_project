package com.ifeng.news2.db;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
 
/**
 * @author liu_xiaoliang
 * @description 收藏数据库
 * 
 * 注：如需修改数据库，请注意sql 语句 【INSERT_DATAS】 中临时表【TEMP_LIST_ITEM】元素个数不能高于表【LIST_ITEM】要插入的列的个数
 * 例如 INSERT INTO LIST_ITEM ( _id , doc_id , title , item_id , thumbnail , has_video , links , STATUS , type , position ) SELECT * FROM TEMP_LIST_ITEM;
 *                            -----------------------------一共十个元素--------------------------------------------------------            ...一共十个元素...
 */
public class CollectionDBHelper extends SQLiteOpenHelper {

	private static final int DB_VERSION = 3;
	private static final String DB_NAME = "LIST_DB.db";

	static final String TABLE_NAME = "LIST_ITEM";
	/**
	 *   @description  数据自然序列
	 */
	static final String ID_COL = "_id";  
	/**
	 *   @description  跳转
	 */
	static final String LINKS = "links"; 
	/**
	 *   @description  收藏列表标题
	 */
	static final String TITLE_COL = "title";    
	/**
	 *   @description  documentId(短id)
	 */
	static final String DOC_ID_COL = "doc_id";
	/**
	 *   @description  表示收藏的文章是否有视频
	 */
	static final String HAS_VIDEO = "has_video";
	/**
	 *   @description  列表id(长id)
	 */
	static final String ITEM_ID_COL = "item_id";
	/**
	 *   @description  收藏状态
	 */
	static final String STATUS_COL = "STATUS";
	/**
	 *   @description  缩略图地址
	 */
	static final String THUMBNAIL_COL = "thumbnail";
	/**
	 *   @description  收藏图片位于图集的位置
	 */
	static final String POSITION_COL = "position";
	/**
	 *   @description  收藏类型  slide/doc/topic
	 */
	static final String TYPE_COL = "type";
	/**
     *   @description  收藏列表样式图标，将来有新样式图标添加用TYPE_ICON_COL区分即可，无需再添加字段
     */
    static final String TYPE_ICON_COL = "type_icon";
	
	/**
	 * 描述
	 */
	static final String INTRODUCTION_COL = "introduction";
	
	private static final String CREATE_TEMP_TABLE = "ALTER TABLE "+TABLE_NAME+" RENAME TO TEMP_LIST_ITEM;";
    /*private static final String INSERT_DATAS = "INSERT INTO "+ TABLE_NAME +" ( "+ID_COL+
                                                                          ","+ DOC_ID_COL +
                                                                          ","+ TITLE_COL +
                                                                          ","+ ITEM_ID_COL +
                                                                          ","+ THUMBNAIL_COL +
                                                                          ","+ HAS_VIDEO +
                                                                          ","+ LINKS +
                                                                          ","+ STATUS_COL +
                                                                          ","+ TYPE_COL +
                                                                          ","+ POSITION_COL +" ) SELECT * FROM TEMP_LIST_ITEM;";*/
	private static final String INSERT_DATAS = "INSERT INTO LIST_ITEM ( _id , doc_id , title , item_id , thumbnail , has_video , links , STATUS , type , position ) SELECT _id , doc_id , title , item_id , thumbnail , has_video , links , STATUS , type , position FROM TEMP_LIST_ITEM;";
    private static final String DROP_TEMP_TABLE = "DROP TABLE IF EXISTS TEMP_LIST_ITEM;";
    
    private static final String CREATE_TABLE = 
        "CREATE TABLE IF NOT EXISTS " + TABLE_NAME + " (" +
        ID_COL + " INTEGER PRIMARY KEY, " +
        DOC_ID_COL + " TEXT, " +
        TITLE_COL + " TEXT, " +
        ITEM_ID_COL + " TEXT, " +
        THUMBNAIL_COL + " TEXT, " +
        HAS_VIDEO + " TEXT, " +
        LINKS + " BLOB, " +
        STATUS_COL + " TEXT, "+
        TYPE_COL+" TEXT, "+
        INTRODUCTION_COL+" TEXT, "+
        POSITION_COL+" TEXT, "+
        TYPE_ICON_COL+" TEXT );";
    
	CollectionDBHelper(Context context) {
		super(context, DB_NAME, null, DB_VERSION);
	}

	@Override
	public void onCreate(SQLiteDatabase sqLiteDatabase) {
		sqLiteDatabase.execSQL(CREATE_TABLE);
	}

	@Override
	public void onUpgrade(SQLiteDatabase sqLiteDatabase, int oldVersion, int newVersion) {
	  if (oldVersion < newVersion) {
	    sqLiteDatabase.execSQL(CREATE_TEMP_TABLE);
	    sqLiteDatabase.execSQL(CREATE_TABLE);
	    sqLiteDatabase.execSQL(INSERT_DATAS);
	    sqLiteDatabase.execSQL(DROP_TEMP_TABLE);
	  } else if (oldVersion > newVersion){
        sqLiteDatabase.execSQL("DROP TABLE IF EXISTS "+ TABLE_NAME);
        onCreate(sqLiteDatabase);
      }
    
	}

}
