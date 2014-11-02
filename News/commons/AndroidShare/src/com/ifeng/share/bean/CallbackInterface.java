package com.ifeng.share.bean;

import android.content.Context;

public interface CallbackInterface {
	public void bindSuccess(Context context);
	public void bindFailure(Context context);
	public void unbindSuccess(Context context);
	public void unbindFailure(Context context);
}
