package com.qad.util;

import java.lang.ref.WeakReference;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

/**
 * 封装Toast的简易实现
 * 
 * @author 13leaf
 * 
 */
public class WToast {

	private Toast mToast;
	private final WeakReference<Context> context;

	public WToast(final Context context) {
		this.context = new WeakReference<Context>(context);
	}

	/**
	 * 在底部显示一条toast信息,大约3秒钟时间。<br>
	 * 若想让toast显示时间较长，请调用showLongMessage
	 * 
	 * @param msg
	 */
	public void showMessage(final Object msg) {
		if (context.get() != null) {
			if (msg instanceof Integer) {
				showToast(context.get(), (Integer) msg);
			} else if (msg instanceof String) {
				showToast(context.get(), (String) msg);
			}
		}
	}

	/**
	 * 以较长的时间来toast显示，大约5秒钟显示。
	 * 
	 * @param msg
	 */
	public void showLongMessage(final Object msg) {
		if (context.get() != null) {
			if (msg instanceof Integer) {
				showLongToast(context.get(), (Integer) msg);
			} else if (msg instanceof String) {
				showLongToast(context.get(), (String) msg);
			}
		}
	}

	private void showToast(Context context, String msg) {
		if (mToast == null) {
			mToast = Toast.makeText(context, msg, Toast.LENGTH_SHORT);
		} else {
			mToast.setText(msg);
			mToast.setDuration(Toast.LENGTH_SHORT);
		}
		mToast.show();
	}

	private void showToast(Context context, int msg) {
		if (mToast == null) {
			mToast = Toast.makeText(context, msg, Toast.LENGTH_SHORT);
		} else {
			mToast.setText(msg);
			mToast.setDuration(Toast.LENGTH_SHORT);
		}
		mToast.show();
	}

	private void showLongToast(Context context, String msg) {
		if (mToast == null) {
			mToast = Toast.makeText(context, msg, Toast.LENGTH_LONG);
		} else {
			mToast.setText(msg);
			mToast.setDuration(Toast.LENGTH_LONG);
		}
		mToast.show();
	}

	private void showLongToast(Context context, int msg) {
		if (mToast == null) {
			mToast = Toast.makeText(context, msg, Toast.LENGTH_LONG);
		} else {
			mToast.setText(msg);
			mToast.setDuration(Toast.LENGTH_LONG);
		}
		mToast.show();
	}

	/**
	 * 仅在debug模式下显示toast消息
	 * 
	 * @param msg
	 */
	public void testShowMessage(final Object msg) {
		if (context.get() != null) {
			boolean isDebug = (context.get().getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
			if (isDebug) {
				showMessage(msg);
			}
		}
	}
}
