package cn.kuwo.sing.context;

import java.io.File;
import java.io.IOException;

import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.ObjectUtils;

public class Config {
	
	// 持久参数文件名
	private final static String PERSISTENCE_NAME = "persistence";
	
	// 持久参数文件路径
	private static String persistencePath = null;
	private static Persistence persistence = null;
	
	static{
		persistencePath = DirectoryManager.getFilePath(DirContext.CONFIG, PERSISTENCE_NAME);
	}
	
	public static Persistence getPersistence() {
		if (persistence == null)
			persistence = loadPersistence();
		return persistence;
	}
	
	public static void savePersistence(){
		try {
			if (persistence != null)
				ObjectUtils.Serialize(persistencePath, persistence);
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
	}
	
	public static Persistence loadPersistence(){
		File file = new File(persistencePath);
		
		try {
			if (file.exists())
				return (Persistence) ObjectUtils.Deserialize(persistencePath);
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		} catch (ClassNotFoundException e) {
			KuwoLog.printStackTrace(e);
		}

		return new Persistence();
	}
}
