package com.ifeng.commons.upgrade.download;

import android.content.Context;
import android.content.Intent;

import com.ifeng.commons.upgrade.UpgradeService;
import com.ifeng.commons.upgrade.UpgradeType;
import com.qad.service.DownloadReceiver;

/**
 * 
 * @author 13leaf
 * 
 */
public class AtmoReceiver extends DownloadReceiver {

	Callback callback;

	public AtmoReceiver(Callback callback) {
		this.callback = callback;
	}
	
	public void setCallback(Callback callback) {
		this.callback = callback;
	}

	@Override
	protected void onNewDownload(String downloadUrl, String targetPath,
			Context context) {
	}

	@Override
	protected void onPublishProgress(int progress, Context context) {
	}

	@Override
	protected void onDownloadDone(boolean success, Context context) {
		if (callback != null)
			callback.onDownloadDone(success, context);
		context.getApplicationContext().unregisterReceiver(this);
		callback = null;
	}

	@Override
	public void onReceive(Context context, Intent intent) {
		if (UpgradeType.Atmosphere.name().equals(
				intent.getStringExtra(UpgradeService.EXTRA_UPGRADE_TYPE))) {
			super.onReceive(context, intent);
		}
	}
}
