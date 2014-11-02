package com.ifeng.commons.upgrade.download;

import android.content.Context;

public interface Callback {
	void onDownloadDone(boolean success, Context context);
}
