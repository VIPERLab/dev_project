package com.ifeng.news2.util;

import android.net.Uri;
import android.os.Process;
import android.text.TextUtils;
import android.util.Log;

import com.ifeng.news2.Config;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.DocUnit;
import com.ifeng.news2.bean.ListUnit;
import com.ifeng.news2.bean.ListUnits;
import com.qad.cache.PersistantCacheManager;

public class SaveBackupUtil {
	private final ListUnits listUnits;

	public SaveBackupUtil(ListUnit unit) {
		ListUnits units = new ListUnits();
		units.add(unit);
		listUnits = units;
	}

	public SaveBackupUtil(ListUnits units) {
		listUnits = units;
	}

	public void run() {
		if (listUnits == null || listUnits.size() == 0) return;
		try {
			if (listUnits == null || listUnits.size() == 0) return;
			String key = SaveBackupUtil.getSaveKey(listUnits.get(0).getMeta().getId());
			if (TextUtils.isEmpty(key)) return;
			
			PersistantCacheManager cacheManager = PersistantCacheManager.getInstance(Config.EXPIRED_TIME);
			cacheManager.saveCache(key, listUnits);
			for (DocUnit docUnit : listUnits.getDocUnits()){
				cacheManager.saveCache(docUnit.getMeta().getId(), docUnit);
			}
		} catch (Exception e) {
			Log.d(getClass().getName(), e.getLocalizedMessage());
		}
	}
	
	private static String getSaveKey(String metaId) {
		try {
			metaId = SaveBackupUtil.filterMetaId(metaId);
			Channel channel = Config.findChannelByMetaId(metaId);
			String page = Uri.parse(metaId).getQueryParameter("page");
			if (metaId.contains("android2GList"))
				return ParamsManager.addParams(channel.getChannelUrl() + "&page=" + page);
			else
				return ParamsManager.addParams(channel.getChannelSmallUrl() + "&page=" + page);
		} catch (Exception e) {
			return null;
		}
	}

	private static String filterMetaId(String metaId) {
		if (!metaId.startsWith("http://"))
			metaId = "http://" + metaId;
		metaId = metaId.replace("&amp;", "&");
		return metaId;
	}
}
