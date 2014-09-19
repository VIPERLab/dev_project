package cn.kuwo.sing.db;

import java.sql.SQLException;
import java.util.List;

import android.content.Context;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.bean.Kge;

import com.j256.ormlite.dao.RuntimeExceptionDao;

public class KgeDao {
	
	private final String TAG = "KgeDao";

	private RuntimeExceptionDao<Kge, Long> mDao;

	public KgeDao (Context context) {
		this.mDao = new KgeDBHelper(context).getTaskRuntimeDao();
	}
	
	public void insertKge(Kge kge){
		delete(kge.date);
		mDao.create(kge);
	}
	
	public Kge getKge(Long date) {
		return mDao.queryForId(date);
	}
	
	public Kge getKge(long date) {
		List<Kge> q = mDao.queryForEq("date", date);
		if (q != null && q.size()>0)
			return q.get(0);
		return null;
	}
	
	public void delete(Long date) {
		mDao.deleteById(date);
	}
	
	public List<Kge> queryForAll() {
		try {
			return mDao.queryBuilder().orderBy("date", false).query();
		} catch (SQLException e) {
			KuwoLog.printStackTrace(e);
			return null;
		}
	}
	
	public int update(Kge kge) {
		return mDao.update(kge);
	}
}
