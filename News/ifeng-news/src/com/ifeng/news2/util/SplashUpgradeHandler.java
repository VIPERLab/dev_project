package com.ifeng.news2.util;

import android.view.Window;

import android.widget.LinearLayout.LayoutParams;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.os.Environment;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.ifeng.news2.Config;
import com.ifeng.news2.R;
import com.ifeng.news2.commons.upgrade.UpgradeHandler;
import com.ifeng.news2.commons.upgrade.UpgradeManager;
import com.ifeng.news2.commons.upgrade.UpgradeResult;
import com.ifeng.news2.commons.upgrade.UpgradeResult.Status;
import com.ifeng.news2.commons.upgrade.UpgradeType;
import com.ifeng.news2.commons.upgrade.download.Callback;
import com.ifeng.news2.fragment.NewsMasterFragmentActivity;
import com.qad.app.BaseApplication;
import com.qad.util.DialogTool;
import com.qad.util.IntentFactory;
import java.io.File;

public class SplashUpgradeHandler implements UpgradeHandler {

	public boolean shouldForward;
	Intent forwardIntent;
	String forceMessage;
	String adviseMessage;
	Activity activity;
	UpgradeListener listener;

	// use default atmo target Path
	String atmoTargetPath = new File(Environment.getExternalStorageDirectory(),
			"ifeng/download/atmo.zip").getAbsolutePath();

	Callback atmoCallback;
	private boolean autoUpgrade = true;

	public SplashUpgradeHandler(Intent forwardIntent, Activity context,
			String forceUpdateMessage, String adviseUpdateMessage,
			String atmoTargetPath, Callback atmoCallback) {
		this.forwardIntent = forwardIntent;
		this.forceMessage = forceUpdateMessage;
		this.adviseMessage = adviseUpdateMessage;
		this.activity = context;
		if (atmoTargetPath != null)
			this.atmoTargetPath = atmoTargetPath;
		this.atmoCallback = atmoCallback;
	}

	public boolean isAutoUpgrade() {
		return autoUpgrade;
	}

	public SplashUpgradeHandler setAutoUpgrade(boolean checkAtom) {
		this.autoUpgrade = checkAtom;
		return this;
	}

	private AlertDialog buildDialog(Context context, String updateMessage,
			final OnClickListener yes, final OnClickListener no) {
	  return IfengAlertDialog.CreateDialog(activity, "升级提示", updateMessage, "更新", "取消", yes, no);
	}

	private static class DialogHandler implements
	DialogInterface.OnClickListener, Callback {
		UpgradeResult result;
		UpgradeManager manager;
		Activity activity;
		Intent forwardIntent;
		boolean shouldForward;

		public DialogHandler(UpgradeResult result, UpgradeManager manager,
				Activity context, Intent forwardIntent, boolean shouldForward) {
			this.result = result;
			this.manager = manager;
			this.activity = context;
			this.forwardIntent = forwardIntent;
			this.shouldForward = shouldForward;
		}

		@Override
		public void onClick(DialogInterface dialog, int which) {
			Status groundStatus = result.getStatus(UpgradeType.Ground);
			//确定后启动升级服务
			if (which == DialogInterface.BUTTON_POSITIVE) {
				manager.startGroundUpgrade(
						result.getDownUrl(UpgradeType.Ground), this);
			}  
			//非强制升级,做出任意选择后继续
			if (groundStatus == Status.ForceUpgrade) {//强制升级做出任意选择后关闭
				//升级时下载安装包  需要程序后台运行
				Config.FULL_EXIT = false;
				NewsMasterFragmentActivity.isAppRunning = false;
				activity.finish();
			} else if (forwardIntent != null) {
				activity.startActivity(forwardIntent);
				activity.finish();
			}
		}

		@Override
		public void onDownloadDone(boolean success, Context context) {
			// TODO Add Safe Notify Dialog hereQUE
			if (!success)
				return;
			BaseApplication app = (BaseApplication) context
					.getApplicationContext();
			try {
				if (app == null || app.getTaskSize() == 0 || app.getTopActivity() == null)
					return;
//				new DialogTool(app.getTopActivity()).createNoTitleConfirmDialog(
//						"是否立即安装新版本?", new DialogInterface.OnClickListener() {
//							@Override
//							public void onClick(DialogInterface dialog, int which) {
//								
//							}
//						}).show();
				Intent installIntent = IntentFactory.getInstallIntent(manager.tempUpgradeApk.getAbsoluteFile());
				installIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				activity.startActivity(installIntent);
				activity.finish();
			} catch (Exception e) {
				//ignore
			}
		}
	}
	/**
	 * 处理升级校验结果,通知依赖listener通知调用者,listener不能为空
	 */
	@Override
	public void handle(UpgradeResult result, UpgradeManager manager){
		// 处理Ground
		if ((result.getStatus(UpgradeType.Ground) != Status.NoUpgrade)
				&& (!TextUtils.isEmpty(result.getDownUrl(UpgradeType.Ground)))) {
			if (listener != null){
				listener.onReceiveUpgrade();//stop splash跳转
			}			
			if (!TextUtils.isEmpty(result.getDownloadTips())) {
				adviseMessage = result.getDownloadTips();
			}
			DialogHandler handler = new DialogHandler(result, manager,
					activity, forwardIntent, shouldForward);
			buildDialog(activity, result.getStatus(UpgradeType.Ground) == Status.ForceUpgrade ? 
					forceMessage : adviseMessage, handler, handler).show();
			return;
		} else if (result.getStatus(UpgradeType.Atmosphere) != Status.NoUpgrade
				&& autoUpgrade
				&& !TextUtils
						.isEmpty(result.getDownUrl(UpgradeType.Atmosphere))) {
			if (listener != null){
				listener.onReceiveUpgrade();
			} 
			manager.startAtmoUpgrade(result.getDownUrl(UpgradeType.Atmosphere),
					atmoTargetPath, new Callback() {
				@Override
				public void onDownloadDone(boolean success, Context context) {
					atmoCallback.onDownloadDone(success, context);
				}
			});
		}else if(listener!=null){
			listener.onReceiveFinish();
		}
	}

	@Override
	public void handleError(UpgradeManager manager, Exception exception) {
		if (listener != null)
			listener.onReceiveError();
		else doForwarding();
	}

	private void doForwarding() {
		if (forwardIntent == null)
			return;
		activity.startActivity(forwardIntent);
		activity.finish();
	}

	public void setListener(UpgradeListener listener) {
		this.listener = listener;
	}

	public void setShouldForward(boolean shouldForward) {
		this.shouldForward = shouldForward; 
	}

	public interface UpgradeListener {

		/**
		 * Upgrade available
		 */
		public void onReceiveUpgrade();

		/**
		 * Finished with on upgrade available
		 */
		public void onReceiveFinish();

		/**
		 * Terminated with error
		 */
		public void onReceiveError();

	}
}
