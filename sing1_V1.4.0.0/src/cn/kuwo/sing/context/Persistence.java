package cn.kuwo.sing.context;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Stack;

import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.bean.SquareShow;
import cn.kuwo.sing.bean.User;

/**
 * 持久化参数
 * 
 */
public class Persistence implements Serializable {
	private static final long serialVersionUID = -3631106448346902629L;
	
	/**
	 * 搜索历史记录
	 */
	public Stack<String> searchHistory = null;

//	public String session = null;
	
	public User user = null;
	public boolean rememberUserInfo = false;
	public boolean isLogin = false;
	public Kge lastMtv = null;
	public HashMap<String, Boolean> musicCancelMap = null;
	public boolean hasCreatedShortcut = false;
	public String lastUname;
	public String lastPwd;
	public Map<String, SquareShow> squareActivityMap;
}
