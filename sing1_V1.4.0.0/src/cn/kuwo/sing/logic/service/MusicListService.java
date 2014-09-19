package cn.kuwo.sing.logic.service;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;

import android.R.integer;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;

import cn.kuwo.framework.cache.CacheManager;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.TimeUtils;
import cn.kuwo.sing.bean.Music;
import cn.kuwo.sing.bean.SearchResult;

public class MusicListService extends DefaultService {
	private final String TAG = "MusicListService";
	private static final String CLIENT_VERSION_PREFIX = "kwsing_android_";
	
	
	/**
	 * 搜索
	 * @throws UnsupportedEncodingException 
	 */
	public String getSearch(String content, int pagenum, int size) throws UnsupportedEncodingException {
		LinkedHashMap<String, String> params = new LinkedHashMap<String, String>();
		String all = URLEncoder.encode(content,"utf-8");
		params.put("all", all);
		params.put("pn", ""+pagenum);
		params.put("rn", ""+size);
		params.put("filt", "0");
		CharSequence url = getUrl("music", params );

		String data = null;
		try {
			KuwoLog.d(TAG, "url:" + url.toString());
			data = read(url.toString());
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
		KuwoLog.i(TAG, "getSearch: " + data);
		return data;
		
	}
	
	
	
	/**
	 * 搜索Tips
	 * @throws UnsupportedEncodingException 
	 */
	public String getSearchTips(String content) throws UnsupportedEncodingException {
		LinkedHashMap<String, String> params = new LinkedHashMap<String, String>();
		String all = URLEncoder.encode(content,"utf-8");
		params.put("word", all);
		params.put("encoding", "utf-8");
		CharSequence url = getUrl("tips", params );
		KuwoLog.i(TAG, "开始搜索: ");
		String data = null;
		try {
			KuwoLog.d(TAG, "url:" + url.toString());
			data = read(url.toString());
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
		KuwoLog.i(TAG, "getSearchTips: " + data);
		return data;
	}
	

	/**
	 * 获取最新榜单
	 */
	public String getNewList(int pagenum, int size, String signature) {
		LinkedHashMap<String, String> params = new LinkedHashMap<String, String>();
		params.put("id", "1");
		params.put("pn", ""+pagenum);
		params.put("rn", ""+size);
		if((signature!=null)||pagenum == 0){
			KuwoLog.d(TAG, "signature" + signature);
			params.put("sig", signature);
		}
		CharSequence url = getUrl("catalog", params );

		String data = null;
		try {
			KuwoLog.d(TAG, "url:" + url.toString());
			data = read(url.toString());
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
		KuwoLog.i(TAG, "GetNewList: " + data);
		return data;
	}
	
	/**
	 * 获取排行榜单
	 */
	public String getHotList(String signature) {
		LinkedHashMap<String, String> params = new LinkedHashMap<String, String>();
		params.put("id", "2");
//		params.put("pn", ""+pagenum);
//		params.put("rn", ""+size);
		if(signature!=null){
			KuwoLog.d(TAG, "signature" + signature);
			params.put("sig", signature);
		}
		CharSequence url = getUrl("catalog", params );

		String data = null;
		try {
			data = read(url.toString());
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
		KuwoLog.i(TAG, "GetHotList: " + data);
		return data;
	}
	 
	/**
	 * @param listid 榜单ID，64位正整型数
	 * @param digest 父节点的digest字段
	 * 获取榜单子列表
	 */
	public String getSubList(String listid, int pagenum, int size,String signature) throws IOException {
		LinkedHashMap<String, String> params = new LinkedHashMap<String, String>();
		params.put("id", listid);
		params.put("digest", "0");
		params.put("pn", ""+pagenum);
		params.put("rn", ""+size);
		if((signature!=null)||pagenum == 0){
			KuwoLog.d(TAG, "signature" + signature);
			params.put("sig", signature);
		}
		CharSequence url = getUrl("subcatalog", params );

		String data = read(url.toString());;
		KuwoLog.i(TAG, "getSubList: " + data);
		return data;
	}
	
	/**
	 * 获取歌手榜单
	 */
	public String getSingerList(String signature) {
		LinkedHashMap<String, String> params = new LinkedHashMap<String, String>();
		params.put("id", "3");
//		params.put("pn", ""+pagenum);
//		params.put("rn", ""+size);
		if(signature!=null){
			KuwoLog.d(TAG, "signature" + signature);
			params.put("sig", signature);
		}
		CharSequence url = getUrl("catalog", params );

		String data = null;
		try {
			data = read(url.toString());
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
		KuwoLog.i(TAG, "GetSingerList: " + data);
		return data;
	}
	
	/**
	 * @param listid 榜单ID，64位正整型数
	 * 获取歌手子列表
	 */
	

	public String getSingerSubList(String listid,String signature) {
		LinkedHashMap<String, String> params = new LinkedHashMap<String, String>();
		params.put("id", listid);
		params.put("digest", "1");
		if(signature!=null){
			KuwoLog.d(TAG, "signature" + signature);
			params.put("sig", signature);
		}
		CharSequence url = getUrl("subcatalog", params );

		String data = null;
		try {
			data = read(url.toString());
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
		KuwoLog.i(TAG, "GetSingerSubList: " + data);
		return data;
	}
	
	/**
	 * 获取歌星歌曲列表
	 */
	public String getSingersongList(String singerid, int pagenum, int size,String signature) {
		LinkedHashMap<String, String> params = new LinkedHashMap<String, String>();
		params.put("id", singerid);
		params.put("digest", "");
		params.put("pn", ""+pagenum);
		params.put("rn", ""+size);
		if((signature!=null)||pagenum == 0){
			KuwoLog.d(TAG, "signature" + signature);
			params.put("sig", signature);
		}
		CharSequence url = getUrl("artist_music", params );

		String data = null;
		try {
			data = read(url.toString());
		} catch (IOException e) {
			KuwoLog.printStackTrace(e);
		}
		KuwoLog.i(TAG, "getSingersongList: " + data);
		return data;
	}
	
	/**
	 * 获取热门作品
	 * 
	 * @return 
	 */
	
	public String getHotSongs(int page, int size, String signature) throws IOException {
		String url = null;
		// TODO server提取出来
		if((signature == null)||(page!=1)){
			url = String.format("http://changba.kuwo.cn/kge/mobile/Plaza?t=hot&pn=%d&rn=%d&version="+CLIENT_VERSION_PREFIX+getAppVersionName(AppContext.context), page, size);
//			url = String.format("http://60.28.200.79/kge/mobile/PlazaTest?t=hot&pn=%d&rn=%d&version="+CLIENT_VERSION_PREFIX+getAppVersionName(AppContext.context), page, size);
		}else{
			url = String.format("http://changba.kuwo.cn/kge/mobile/Plaza?t=hot&pn=%d&rn=%d&ts=%s&version="+CLIENT_VERSION_PREFIX+getAppVersionName(AppContext.context), page, size,signature);
//			url = String.format("http://60.28.200.79/kge/mobile/PlazaTest?t=hot&pn=%d&rn=%d&ts=%s&version="+CLIENT_VERSION_PREFIX+getAppVersionName(AppContext.context), page, size,signature);
		}
		KuwoLog.d(TAG, "getHotSongs: signature:" + signature);
		String data = read(url);
		KuwoLog.i(TAG, "getHotSongs[line247]: " + data);
		return data;
	}
	
	/**
	 * 获取最新作品
	 * @return 
	 */
	
	public String getNewSongs(int page, int size, String signature) throws IOException {
		// TODO t参数没有维护,其他两个函数类似
		String url = null;
		if((signature == null)||(page!=1)){
			url = String.format("http://changba.kuwo.cn/kge/mobile/Plaza?t=new&pn=%d&rn=%d", page, size);
		}else{
			url = String.format("http://changba.kuwo.cn/kge/mobile/Plaza?t=new&pn=%d&rn=%d&ts=%s", page, size,signature);
		}
		KuwoLog.d(TAG, "getNewSongs: signature:" + signature);
		String data = read(url);
		KuwoLog.i(TAG, "getNewSongs: " + data);
		return data;
	}
	
	/**
	 * 获取K歌达人
	 * @return 
	 */
	
	public String getSuperStars(int page, int size, String signature) throws IOException {
		String url = null;
		if((signature == null)||(page!=1)){
			url = String.format("http://changba.kuwo.cn/kge/mobile/Plaza?t=superstar&pn=%d&rn=%d", page, size);
		}else{
			url = String.format("http://changba.kuwo.cn/kge/mobile/Plaza?t=superstar&pn=%d&rn=%d&ts=%s", page, size, signature);
		}
		KuwoLog.d(TAG, "getSuperStars: signature:" + signature);
		String data = read(url);
		KuwoLog.d(TAG, "getSuperStars: " + data);
		return data;
	}
	
	/** 
	 * 返回当前程序版本名 
	 */  
	public static String getAppVersionName(Context context) {  
	    String versionName = "";  
	    try {  
	        // ---get the package info---  
	        PackageManager pm = context.getPackageManager();  
	        PackageInfo pi = pm.getPackageInfo(context.getPackageName(), 0);  
	        versionName = pi.versionName;  
	        if (versionName == null || versionName.length() <= 0) {  
	            return "";  
	        }  
	    } catch (Exception e) {  
	        KuwoLog.printStackTrace(e);  
	    }  
	    return versionName;  
	}  
}
