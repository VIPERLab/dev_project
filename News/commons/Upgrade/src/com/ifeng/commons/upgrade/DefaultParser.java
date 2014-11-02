package com.ifeng.commons.upgrade;

import org.json.JSONException;
import org.json.JSONObject;

import android.text.TextUtils;

import com.ifeng.commons.upgrade.UpgradeResult.Status;

/**
 * 格式 { "atmosphere": { "compatVersion":"1.1.0", "downloadUrl":"xxxxxxxx",
 * "lastestVersion":"2.0.1", "forceUpgrade":["1.1.2","1.2.1"], }, "ground": {
 * "compatVersion":"1.1.0", "downloadUrl":"xxxxxxxx", "lastestVersion":"2.0.1",
 * "forceUpgrade":["1.1.2","1.2.1"], } }
 * 
 * @author 13leaf
 * 
 */
public class DefaultParser implements UpgradeParser {

	@Override
	public UpgradeResult parse(String content, Version appVersion,
			Version atmoVersion,boolean forceUpgrade) throws HandlerException {
		try {
			// make JSONObject escape \
			content = content.replace("\\/","/");
			JSONObject update = new JSONObject(content);
			DefaultEntry atmo = null;
			if(update.has("atomsphere")){
				atmo = handlerEntry(update.getJSONObject("atomsphere"));
			}			
			DefaultEntry ground = handlerEntry(update.getJSONObject("ground"));
			Status atmoStatus = Status.NoUpgrade;
			if (atmoVersion != null && atmo != null){
				atmoStatus = judgeStatus(atmo, atmoVersion,forceUpgrade);
			}				
			Status groundStatus = judgeStatus(ground, appVersion,forceUpgrade);
			return new UpgradeResult(atmoStatus, atmo==null?null:atmo.downloadUrl,
					groundStatus, ground.downloadUrl);
		} catch (JSONException e) {
			e.printStackTrace();
			throw new HandlerException(e);
		}
	}

	/**
	 * 封装了判定策略的计算
	 * 
	 * @param entry
	 * @param version
	 * @return
	 */
	protected Status judgeStatus(DefaultEntry entry, Version version, boolean forceUpgrade) {
		// 强制升级判定
		if(forceUpgrade){
			if(!TextUtils.isEmpty(entry.compatVersion)){
				Version compatVersion = new Version(entry.compatVersion);
				if (version.compareTo(compatVersion) < 0)// 小于兼容版本
				{
					return Status.ForceUpgrade;
				}
			}			
			for (String forceString : entry.forceVersions) {
				if(!TextUtils.isEmpty(forceString)){
					Version forceVersion = new Version(forceString);
					if (version.equals(forceVersion))
						return Status.ForceUpgrade;
				}			
			}
		}	
		// 建议升级判定
		if(!TextUtils.isEmpty(entry.lastestVersion)){
			Version latestVersion = new Version(entry.lastestVersion);
			if (version.compareTo(latestVersion) < 0) {
				return Status.AdviseUpgrade;
			}
		}		
		
		// 无须升级
		return Status.NoUpgrade;
	}

	private DefaultEntry handlerEntry(JSONObject jsonObject)
			throws JSONException {
		DefaultEntry entry = new DefaultEntry();
		if(jsonObject.has("compatVersion")){
			entry.compatVersion = jsonObject.getString("compatVersion");
		}
		if(jsonObject.has("downloadUrl")){
			entry.downloadUrl = jsonObject.getString("downloadUrl");
		}
		if(jsonObject.has("lastestVersion")){
			entry.lastestVersion = jsonObject.getString("lastestVersion");
		}		
		if(jsonObject.has("forceUpgrade")){
			entry.forceVersions = Utils.json2String(jsonObject
					.getJSONArray("forceUpgrade"));
		}		
		return entry;
	}

}
