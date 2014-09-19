package cn.kuwo.sing.db;

import java.sql.SQLException;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;

import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.Music;

import com.j256.ormlite.android.apptools.OrmLiteSqliteOpenHelper;
import com.j256.ormlite.dao.Dao;
import com.j256.ormlite.dao.RuntimeExceptionDao;
import com.j256.ormlite.support.ConnectionSource;
import com.j256.ormlite.table.TableUtils;

/**
 * Database helper class used to manage the creation and upgrading of your database. This class also usually provides
 * the DAOs used by the other classes.
 */
public class KgeDBHelper extends OrmLiteSqliteOpenHelper {

	private final String TAG = "KgeDBHelper";
	private static final String DATABASE_NAME = "kwsing.db"; // TODO @LIKANG CHANGE TO SDCARD
	private static final int DATABASE_VERSION = 2;

	// the DAO object we use to access the table
	private static Dao<Kge, Long> taskDao = null;
	private static RuntimeExceptionDao<Kge, Long> taskRuntimeDao = null;

	public KgeDBHelper(Context context) {
		super(context, DATABASE_NAME, null, DATABASE_VERSION);
	}

	@Override
	public void onCreate(SQLiteDatabase db, ConnectionSource connectionSource) {
		try {
			KuwoLog.i(TAG, "onCreate");
			TableUtils.createTable(connectionSource, Music.class);
			TableUtils.createTable(connectionSource, Kge.class);
		} catch (SQLException e) {
			KuwoLog.e(TAG, "Can't create database");
			throw new RuntimeException(e);
		}
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, ConnectionSource connectionSource, int oldVersion, int newVersion) {
		KuwoLog.i(TAG, "onUpgrade");
		// after we drop the old databases, we create the new ones
		try {
			TableUtils.dropTable(connectionSource, Music.class, true);
			TableUtils.dropTable(connectionSource, Kge.class, true);
			onCreate(db, connectionSource);
		} catch (SQLException e) {
			KuwoLog.e(TAG, e);
		}
	}

	/**
	 * Returns the Database Access Object (DAO) for our DownloadItem class. It will create it or just give the cached
	 * value.
	 */
	public Dao<Kge, Long> getTaskDao() throws SQLException {
		if (taskDao == null) {
			taskDao = getDao(Kge.class);
		}
		return taskDao;
	}

	/**
	 * Returns the RuntimeExceptionDao (Database Access Object) version of a Dao for our DownloadItem class. It will
	 * create it or just give the cached value. RuntimeExceptionDao only through RuntimeExceptions.
	 */
	public RuntimeExceptionDao<Kge, Long> getTaskRuntimeDao() {
		if (taskRuntimeDao == null) {
			taskRuntimeDao = getRuntimeExceptionDao(Kge.class);
		}
		return taskRuntimeDao;
	}

	/**
	 * Close the database connections and clear any cached DAOs.
	 */
	@Override
	public void close() {
		super.close();
		taskRuntimeDao = null;
	}
}
