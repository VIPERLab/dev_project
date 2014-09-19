package cn.kuwo.sing.business;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

import com.umeng.analytics.MobclickAgent;

import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.bean.LyricResult;
import cn.kuwo.sing.logic.LyricLogic;
import cn.kuwo.sing.logic.service.MusicListService;
import cn.kuwo.sing.logic.service.MusicService;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.context.Persistence;
import cn.kuwo.sing.util.lyric.Lyric;
import cn.kuwo.sing.util.lyric.Parser;

public class MusicBusiness extends BaseBusiness {
	private final String TAG = "MusicBusiness";

	/**
	 * 获取新歌榜单
	 * 
	 * @return XML文本数据
	 */
	public String getNewList() {
		KuwoLog.i(TAG, "getNewList");

		String ret = null;

		// 查找缓存

		// 从服务器获取
		MusicListService sMusicList = new MusicListService();
		ret = sMusicList.getNewList(0,100,null);

		// 获取成功

		// 放入缓存

		// 失败重试一次

		// 获取失败, 提示用户

		return ret;
	}

//	/**
//	 * 获取搜索历史
//	 * 
//	 * @return
//	 */
//	public Queue<String> getHistory() {
//
//		// 得到持久化对象
//		Persistence persistence = Config.getPersistence();
//
//		// 判断搜索历史记录是否为空
//		if (persistence.searchHistory == null
//				|| persistence.searchHistory.size() == 0) {
//			// 历史记录为空, 是第一次搜索, 返回null
//			return null;
//
//		} else {
//			// 历史记录不为空, 返回历史记录列表
//			return persistence.searchHistory;
//		}
//	}

//	/**
//	 * 添加搜索关键词
//	 * 
//	 * @param keyWords
//	 */
//	public void addHistory(String keyWords) {
//
//		// 得到持久化对象
//		Persistence persistence = Config.getPersistence();
//
//		// 判断搜索历史记录是否为空
//		if (persistence.searchHistory == null) {
//
//			// 历史记录为空, 是第一次搜索, 初始化历史记录列表
//			persistence.searchHistory = new ConcurrentLinkedQueue<String>();
//		}
//		// 将搜索关键词添加到列表中
//		persistence.searchHistory.add(keyWords);
//
//		// 如果历史记录列表数量大于10, 删除多余的记录
//		if (persistence.searchHistory.size() > 10) {
//			persistence.searchHistory.poll();
//		}
//
//	}

	/**
	 * 清空搜索历史记录
	 */
	public void clearHistory() {

		// 得到持久化对象
		Persistence persistence = Config.getPersistence();

		// 判断搜索历史记录是否为空
		if (persistence.searchHistory != null) {
			persistence.searchHistory.clear();
		}
	}
	
	/**
	 * 获取原唱文件
	 * @param rid
	 * @return
	 */
	public File getMusicFile(String rid) {
		
		File file = null;
		String fileName = rid + Constants.MUSIC_FORMAT;
		String path = DirectoryManager.getFilePath(DirContext.MUSIC, fileName);
		file = new File(path);
		if(!file.exists()){
			return null;
		}

		return file;
	}
	
	
	/**
	 * 获取歌词
	 * @param rid
	 * @return
	 * @throws IOException 
	 * @throws URISyntaxException 
	 */
	public Lyric getLyric(String rid) throws IOException, URISyntaxException {
		return getLyric(rid, Lyric.LYRIC_TYPE_KDTX);
	}
	
	public Lyric getLyric(String rid, int lyricType) throws IOException, URISyntaxException {
		
		//寻找本地歌词
		String fileName = rid;
		
		switch (lyricType) {
		case Lyric.LYRIC_TYPE_KDTX: fileName += ".kdtx";break;
		case Lyric.LYRIC_TYPE_LRC: fileName += ".lrc";break;
		case Lyric.LYRIC_TYPE_LRCX: fileName += ".lrcx";break;
		}

		File file = DirectoryManager.getFile(DirContext.LYRICS, fileName);
		Parser parser = new Parser ();
		Lyric lyric = parser.paraLyricFile(file); 
		
		if(lyric==null){
			//下载歌词
			KuwoLog.i(TAG, "download Lyric");
			MusicService music = new MusicService();
			byte[] data = music.getLyric(rid, lyricType);
			ByteArrayInputStream in = new ByteArrayInputStream(data);
			LyricResult lyricresult = music.analyzeLyricResult(in);
			int lrcx = lyricresult.type;
			lyric = music.analyzeLyric(lyricresult.lyric, lrcx);  //获得歌词对象
			
			MobclickAgent.onEvent(AppContext.context, "KS_DOWN_LYRIC", lyric.getType()+"");
			
			if (lyric != null) {
				LyricLogic lLyric = new LyricLogic();
				lLyric.saveFile(lyricresult.lyric, rid, lrcx); //保存歌词密文
			}
		}
		return lyric;
	}

}
