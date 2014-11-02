package com.ifeng.news2.util;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.SharedPreferences.Editor;
import android.preference.PreferenceManager;

import com.ifeng.news2.fragment.NewsMasterFragmentActivity;
import com.ifeng.share.util.NetworkState;
import com.qad.util.Utils;

/**
 * @author SunQuan:
 * @version 创建时间：2013-9-27 下午3:07:35 类说明
 */

public final class PhotoModeUtil {

	/**
	 * 2G/3G无图模式 条件： 1,2G/3G网络 2，开启无图模式开关
	 * 
	 * @return
	 */
	public static PhotoMode getCurrentPhotoMode(Context context) {
		boolean isDownload = PreferenceManager.getDefaultSharedPreferences(
				context).getBoolean("loadImage2", true);
		if (NetworkState.isActiveNetworkConnected(context)
				&& !NetworkState.isWifiNetworkConnected(context) && !isDownload) {
			return PhotoMode.INVISIBLE_PATTERN;
		} else {
			return PhotoMode.VISIBLE_PATTERN;
		}
	}
	
	/**
	 * 2G/3G无图模式（忽略网络情况）
	 * 
	 * @param context
	 * @return
	 */
	public static PhotoMode getCurrentPhotoModeIgnoreNetState(Context context) {
		boolean isDownload = PreferenceManager.getDefaultSharedPreferences(
				context).getBoolean("loadImage2", true);
		if(isDownload) {
			return PhotoMode.VISIBLE_PATTERN;
		} else {
			return PhotoMode.INVISIBLE_PATTERN;
		}
	}

	/**
	 * 用户第一次启动客户端，自动判断当前网络状态，若为2g/3g网络，弹出提示语：您当前使用的是2g/3g网络，是否开启无图模式<br>
	 * 是／否。未选择，默认为“否”（若用户已设置无图模式则不提示，提示框使用系统默认对话框）。<br>
	 * 选择“是”，直接开启无图模式；选择“否”，则不开启无图模式；以后启动不再提示。<br>
	 * 选择后，设置页无图模式选项也打开，除非用户在设置页手动调整，下次启动或升级包，均保留用户的设置效果。<br>
	 * 已设置的用户升级后保留设置且不提示，未设置的用户2g/3g下给出提示。 Wifi下没有无图模式。<br>
	 * 
	 * @param context
	 */
	public static void checkNoPhotoMode(final Context context) {
		PhotoMode currentMode = getCurrentPhotoModeIgnoreNetState(context);
		boolean isUpdate = isUpdate(context);
		boolean is2G3G = NetworkState.isActiveNetworkConnected(context)
				&& !NetworkState.isWifiNetworkConnected(context);
		//如果是2G/3G
		if(is2G3G) {
			if(currentMode == PhotoMode.INVISIBLE_PATTERN && isUpdate) {
				saveVersion(context);
			}
			else if(currentMode == PhotoMode.VISIBLE_PATTERN && isUpdate) {
				saveVersion(context);
				createDialog(context).show();	
			}
		}					 
	}
	
	public static boolean isFirstIn(Context context) {
		return PreferenceManager.getDefaultSharedPreferences(context).getBoolean("is_first_in", true);
	}
	
	public static void cancelFirstIn(Context context) {
		PreferenceManager.getDefaultSharedPreferences(context).edit().putBoolean("is_first_in", false).commit();
	}
	
	/**
	 * 得到保存的版本号
	 */
	private static String getSavedVersion(Context context){
		return context.getSharedPreferences("VERSION",
				Context.MODE_PRIVATE).getString("version", "4.0.6");
	}

	/**
	 * 设置无图模式/有图模式
	 * 
	 * @param context
	 * @param photoMode
	 * @return
	 */
	public static boolean setPhotoMode(Context context, PhotoMode photoMode) {
		Editor editor = PreferenceManager.getDefaultSharedPreferences(context)
				.edit();
		if (photoMode == PhotoMode.VISIBLE_PATTERN) {
			editor.putBoolean("loadImage2", true);
		} else {
			editor.putBoolean("loadImage2", false);
		}
		return editor.commit();
	}

	/**
	 * 判断是否是进行了升级操作，如果升级进入应用，则保存当前版本号
	 * 
	 * @param context
	 * @return
	 */
	public static boolean isUpdate(Context context) {
		String savedVersion = context.getSharedPreferences("VERSION",
				Context.MODE_PRIVATE).getString("version", "4.0.6");
	
		String currentVersion = Utils.getSoftwareVersion(context);
		if (!currentVersion.equals(savedVersion)) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * 将当前版本号保存起来
	 * 
	 * @param context
	 */
	public static void saveVersion(Context context) {
		context.getSharedPreferences("VERSION", Context.MODE_PRIVATE).edit()
				.putString("version", Utils.getSoftwareVersion(context))
				.commit();
	}

	/**
	 * 创建判断2G/3G无图模式的对话框
	 * 
	 * @param context
	 * @return
	 */
	private static AlertDialog createDialog(final Context context) {
		AlertDialog.Builder builder = new AlertDialog.Builder(context);
		AlertDialog dialog = builder
				.setCancelable(true)
				.setMessage("您当前使用的是2g/3g网络，是否开启无图模式")
				.setPositiveButton("是", new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						// 如果设置了无图模式
						if (setPhotoMode(context, PhotoMode.INVISIBLE_PATTERN)) {
							//重置设置页的无图模式选项
							((NewsMasterFragmentActivity)context).getSettingFragment().resetNophotoMode();
						}
					}
				})
				.setNegativeButton("否", new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						setPhotoMode(context, PhotoMode.VISIBLE_PATTERN);
					}
				}).setOnCancelListener(new OnCancelListener() {

					@Override
					public void onCancel(DialogInterface dialog) {
						setPhotoMode(context, PhotoMode.VISIBLE_PATTERN);
					}
				}).create();
		dialog.setCanceledOnTouchOutside(true);
		return dialog;
	}

	/**
	 * 图片的显示模式 有图/无图
	 * 
	 * @author SunQuan:
	 * @version 创建时间：2013-9-27 下午3:01:32 类说明
	 */
	public static enum PhotoMode {

		// 有图模式
		VISIBLE_PATTERN,
		// 无图模式
		INVISIBLE_PATTERN;

	}
}
