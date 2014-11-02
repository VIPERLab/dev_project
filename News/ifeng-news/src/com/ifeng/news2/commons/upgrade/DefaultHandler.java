package com.ifeng.news2.commons.upgrade;

import java.io.File;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.os.Environment;
import android.text.TextUtils;

import com.ifeng.news2.commons.upgrade.UpgradeResult.Status;
import com.ifeng.news2.commons.upgrade.download.Callback;
import com.qad.app.BaseApplication;
import com.qad.util.DialogTool;
import com.qad.util.IntentFactory;

public class DefaultHandler implements UpgradeHandler {

	Intent forwardIntent;

	String forceMessage;

	String adviseMessage;

	Activity activity;

	// use default atmo target Path
	String atmoTargetPath = new File(Environment.getExternalStorageDirectory(),
			"ifeng/download/atmo.zip").getAbsolutePath();

	Callback atmoCallback;

	public DefaultHandler(Intent forwardIntent, Activity context,
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

	private AlertDialog buildDialog(Context context, String updateMessage,
			final OnClickListener yes, final OnClickListener no) {
		AlertDialog dialog = new DialogTool(context).createConfirmDialog(
				"升级提示", null, updateMessage, "确定", yes, "取消", no);
		dialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
			@Override
			public void onCancel(DialogInterface dialog) {
				if (no != null)
					no.onClick(dialog, DialogInterface.BUTTON_NEGATIVE);
			}
		});
		return dialog;
	}

	private static class DialogHandler implements
			DialogInterface.OnClickListener, Callback {
		UpgradeResult result;
		UpgradeManager manager;
		Activity activity;
		Intent forwardIntent;

		public DialogHandler(UpgradeResult result, UpgradeManager manager,
				Activity context, Intent forwardIntent) {
			this.result = result;
			this.manager = manager;
			this.activity = context;
			this.forwardIntent = forwardIntent;
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
			if (groundStatus == Status.AdviseUpgrade && forwardIntent != null) {
				activity.startActivity(forwardIntent);
				activity.finish();
			}else if (groundStatus == Status.ForceUpgrade) {//强制升级做出任意选择后关闭
				activity.finish();
			}
		}

		@Override
		public void onDownloadDone(boolean success, Context context) {
			// TODO Add Safe Notify Dialog here
			if (!success)
				return;
			BaseApplication app = (BaseApplication) context
					.getApplicationContext();
			try {
				if (app == null || app.getTaskSize() == 0 || app.getTopActivity() == null)
					return;
				new DialogTool(app.getTopActivity()).createNoTitleConfirmDialog(
						"是否立即安装新版本?", new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int which) {
								Intent installIntent = IntentFactory
										.getInstallIntent(manager.tempUpgradeApk
												.getAbsoluteFile());
								activity.startActivity(installIntent);
							}
						}).show();
			} catch (Exception e) {
				//ignore
			}
		}
	}

	@Override
	public void handle(UpgradeResult result, UpgradeManager manager) {
		// 处理Ground
		if (result.getStatus(UpgradeType.Ground) != Status.NoUpgrade) {
			DialogHandler handler = new DialogHandler(result, manager,
					activity, forwardIntent);
			if (!TextUtils.isEmpty(result.getDownloadTips())) {
				adviseMessage = result.getDownloadTips();
			}
			buildDialog(
					activity,
					result.getStatus(UpgradeType.Ground) == Status.ForceUpgrade ? forceMessage
							: adviseMessage, handler, handler).show();
			return;
		}

		if (result.getStatus(UpgradeType.Atmosphere) == Status.ForceUpgrade) {
			// wrap a Callback for auto jump
			manager.startAtmoUpgrade(result.getDownUrl(UpgradeType.Atmosphere),
					atmoTargetPath, new Callback() {
						@Override
						public void onDownloadDone(boolean success,
								Context context) {
							if (forwardIntent != null)
								activity.startActivity(forwardIntent);
							atmoCallback.onDownloadDone(success, context);
						}
					});
		} else if (result.getStatus(UpgradeType.Atmosphere) == Status.AdviseUpgrade) {
			manager.startAtmoUpgrade(result.getDownUrl(UpgradeType.Atmosphere),
					atmoTargetPath, atmoCallback);
			doforwarding();
		} else {
			doforwarding();
		}
	}

	@Override
	public void handleError(UpgradeManager manager, Exception exception) {
		// simplify pass
		doforwarding();
	}

	private void doforwarding() {
		if (forwardIntent == null)
			return;
		activity.startActivity(forwardIntent);
		activity.finish();
	}

}
