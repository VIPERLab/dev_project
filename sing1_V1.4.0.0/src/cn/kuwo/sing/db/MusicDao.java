package cn.kuwo.sing.db;

import java.sql.SQLException;
import java.util.List;

import android.content.Context;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.bean.Music;

import com.j256.ormlite.dao.RuntimeExceptionDao;

public class MusicDao {
	private final String TAG = "MusicDao";

	private RuntimeExceptionDao<Music, String> mDao;

	public MusicDao (Context context) {
		this.mDao = new MusicDBHelper(context).getTaskRuntimeDao();
	}
	
	public void insertMusic(Music music){
		if(getMusic(music.getId()) != null) {
			return;
		}
		music.setDate(System.currentTimeMillis());
		mDao.create(music);
	}
	
	public List<Music> getMusicForAll() {
		try {
			return mDao.queryBuilder().orderBy("date", false).query();
		} catch (SQLException e) {
			KuwoLog.printStackTrace(e);
			return null;
		}
	}
	
	public Music getMusic(String id) {
		return mDao.queryForId(id);
	}
	
	public void delete(String id) {
		mDao.deleteById(id);
	}
	
	public void update(Music music) {
		mDao.update(music);
	}
}
