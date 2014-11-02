package com.ifeng.news2.commons.upgrade;

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;

import com.ifeng.news2.commons.upgrade.download.AtmoReceiver;
import com.ifeng.news2.commons.upgrade.download.Callback;
import com.ifeng.news2.commons.upgrade.download.GroundReceiver;

/**
 * 流畅风格的更新入口
 * @author 13leaf
 * 
 */
public class Upgrader {

	private String upgradeUrl;

	private UpgradeParser parser;

	private Version atmoVersion;

	private UpgradeHandler handler;

	private Activity context;

	private String forceMessage;

	private String adviseMessage;

	private String atmoTargetPath;

	private Callback atmoCallback;

	private Intent forwardIntent;
	
	private GroundReceiver groundReceiver;
	
	private AtmoReceiver atmoReceiver;
	
	/**
	 * 是否严格校验参数
	 */
	private boolean strict=true;
	
	private boolean forceUpgrade = true;

	public boolean isForceUpgrade() {
		return forceUpgrade;
	}

	
	private Upgrader(Activity context) {
		this.context = context;
	}
	
	public static Upgrader ready(Activity context)
	{
		return new Upgrader(context);
	}
	
	public Upgrader setForceUpgrade(boolean forceUpgrade) {
		this.forceUpgrade = forceUpgrade;
		return this;
	}


	/**
	 * 设置升级接口url路径
	 * 
	 * @param url
	 * @return
	 */
	public Upgrader setUpgradeUrl(String url) {
		this.upgradeUrl = url;
		return this;
	}

	/**
	 * 覆盖默认的解析
	 * 
	 * @param handler
	 * @return
	 */
	public Upgrader setUpgradeParser(UpgradeParser handler) {
		this.parser = handler;
		return this;
	}

	public Upgrader setAtmoVersion(Version version) {
		this.atmoVersion = version;
		return this;
	}

	/**
	 * 自定义的Handler
	 * 
	 * @param handler
	 * @return
	 */
	public Upgrader setCustomUpgradeHandler(UpgradeHandler handler) {
		this.handler = handler;
		return this;
	}

	public Upgrader setForceMessage(String forceMessage) {
		this.forceMessage = forceMessage;
		return this;
	}

	public Upgrader setAdviseMessage(String adviseMessage) {
		this.adviseMessage = adviseMessage;
		return this;
	}

	public Upgrader setAtmoTargetPath(String atmoTargetPath) {
		this.atmoTargetPath = atmoTargetPath;
		return this;
	}

	public Upgrader setAtmoCallback(Callback atmoCallback) {
		this.atmoCallback = atmoCallback;
		return this;
	}

	public Upgrader setForwardIntent(Intent forwardIntent) {
		this.forwardIntent = forwardIntent;
		return this;
	}
	
	
	
	/**
	 * 是否开启严格校验,若开启.则不允许DefaultHandler使用空的forwardIntent
	 * @param strict
	 * @return
	 */
	public Upgrader setStrict(boolean strict)
	{
		this.strict=strict;
		return this;
	}
	
	/**
	 * 设置Ground下载更新的监听
	 * @param groundReceiver
	 * @return
	 */
	public Upgrader setGroundReceiver(GroundReceiver groundReceiver) {
		this.groundReceiver = groundReceiver;
		return this;
	}
	
	/**
	 * 设置Atmo下载更新的监听
	 * @param atmoReceiver
	 * @return
	 */
	public Upgrader setAtmoReceiver(AtmoReceiver atmoReceiver) {
		this.atmoReceiver = atmoReceiver;
		return this;
	}

	Handler mainHandler = new Handler(Looper.getMainLooper());
	UpgradeManager manager;

	/**
	 * 处理升级事宜
	 */
	public void upgrade() {
		if (parser == null)
			parser = new DefaultParser();
		if(forceMessage==null)
			forceMessage="当前应用需要更新版本后才能使用,是否升级?";
		if(adviseMessage==null)
			adviseMessage="发现有新的版本,是否升级?";
		if (handler == null){
			if(forwardIntent==null && strict){
				throw new IllegalArgumentException("You must set forwardIntent for default Upgrade Handler use!");
			}
			handler = new DefaultHandler(forwardIntent, context, forceMessage,
					adviseMessage, atmoTargetPath, atmoCallback);
		}
		if(upgradeUrl==null){
			throw new IllegalArgumentException("You must set upgradeUrl!");
		}
		manager = new UpgradeManager(context, atmoVersion);
		manager.setAtmoReceiver(atmoReceiver);
		manager.setGroundReceiver(groundReceiver);
		new Thread() {
			public void run() {
				try {
					final UpgradeResult result = manager.checkUpgrade(
							upgradeUrl, parser,forceUpgrade);
					mainHandler.post(new Runnable() {
						@Override
						public void run() {
							try {
								handler.handle(result, manager);
							} catch (Exception e) {
								handler.handleError(manager, e);
							}
						}
					});
				}catch(Exception exception){
					handler.handleError(manager, null);
				}
			}
		}.start();

	}

}
