package com.ifeng.news2.util;

import java.util.ArrayList;

import android.net.Uri;
import android.os.Process;
import android.text.TextUtils;
import android.util.Log;

import com.ifeng.news2.Config;
import com.ifeng.news2.bean.DocUnit;
import com.qad.bean.LogMessageBean;
import com.qad.cache.PersistantCacheManager;
import com.qad.util.LogUtil;

public class SaveBackupDocUnitsUtil {

	private ArrayList<DocUnit> units;
	
	public SaveBackupDocUnitsUtil(ArrayList<DocUnit> units) {
		this.units = units;
	}

	public SaveBackupDocUnitsUtil(DocUnit unit) {
		units = new ArrayList<DocUnit>();
		units.add(unit);
	}
	
	public void run() {
//		if (units == null || units.size() == 0) return;
		try {
			if (units == null || units.size() == 0) return;
			PersistantCacheManager cacheManager = PersistantCacheManager.getInstance(Config.EXPIRED_TIME);
			for (DocUnit docUnit : units){
				if(isValid(docUnit))
					cacheManager.saveCache(getSaveKey(docUnit), docUnit);
			}
		} catch (Exception e) {
			Log.d(getClass().getName(), e.getLocalizedMessage());
		}
	}
	
	private boolean isValid(DocUnit docUnit) {
		return !TextUtils.isEmpty(docUnit.getDocumentIdfromMeta())
				&&docUnit.getBody()!=null
				&&!TextUtils.isEmpty(docUnit.getBody().getText())&&!docUnit.getBody().getText().trim().equals("<p>");
	}

	private String getSaveKey(DocUnit docUnit){
		return ParamsManager.addParams(String.format(Config.DETAIL_URL, getAid(docUnit.getDocumentIdfromMeta())));
	}

	private String getAid(String id) {
		if (id.startsWith("http")) {
			id = Uri.parse(id).getQueryParameter("aid");
		}
		return id;
	}
	
}
