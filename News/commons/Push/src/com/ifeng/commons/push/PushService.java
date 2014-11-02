package com.ifeng.commons.push;

import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.util.HashMap;
import java.util.LinkedList;

import com.qad.lang.Files;
import com.qad.system.PhoneManager;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.ComponentName;
import android.content.Intent;
import android.os.IBinder;

public class PushService extends Service {

	public static boolean ALIVE = false;

	public static final long INTERVAL = 900L * 1000;

	public static final String ACTION_BASE = "action.com.ifeng.commons.push.";

	/**
	 * 拉数据的目标URL，今后扩展
	 */
	// public static final String EXTRA_URL="extra.com.ifeng.commons.push.url";

	/**
	 * 推送产品名称，最后将发送ACTION_BASE+product的广播
	 */
	public static final String EXTRA_PRODUCT = "extra.com.ifeng.commons.push.product";
	
	/**
	 * 完成pull后发送广播的目标
	 */
	public static final String EXTRA_COMPONENT_NAME="extra.com.ifeng.commons.push.component_name";

	/**
	 * 拉数据的实体
	 */
	public static final String EXTRA_ENTITY = "extra.com.ifeng.commons.push.entity";
	
	public static final String EXTRA_CONTENT_INTENT="extra.com.ifeng.commons.push.content_intent";

	/**
	 * 设置闹钟
	 */
	public static final String ACTION_SET = "action.com.ifeng.commons.push.set";

	public static final String ACTION_PULL = "action.com.ifeng.commons.push.pull";

	public static final String ACTION_STARTUP = "action.com.ifeng.commons.push.startup";

	public static final String ACTION_STOP = "action.com.ifeng.commons.push.stop";
	/**
	 * 周期
	 */
	public static final String EXTRA_TIMER = "extra.com.ifeng.commons.push.timer";

	private LinkedList<String> stoppedProducts = new LinkedList<String>();

	/*
	 * TODO 应在应用卸载时做移除操作
	 */
	private LinkedList<String> startedProducts = new LinkedList<String>();
	
	private HashMap<String, SerializeComponent> productComponents=new HashMap<String, PushService.SerializeComponent>();

	private File stopDatFile;

	private File startDatFile;
	
	private File componentsDatFile;
	
	private static final class SerializeComponent implements Serializable
	{

		/**
		 * 
		 */
		private static final long serialVersionUID = -2634609487568620700L;
		
		SerializeComponent(String pkg, String cls) {
			this.pkg = pkg;
			this.cls = cls;
		}
		String pkg;
		String cls;

		@Override
		public String toString() {
			return "SerializeComponent [pkg=" + pkg + ", cls=" + cls + "]";
		}
		
	}

	@Override
	public void onCreate() {
		super.onCreate();
		ALIVE=true;
		stopDatFile=getFileStreamPath("ifeng_commons_push_stop.dat");
		startDatFile=getFileStreamPath("ifeng_commons_push_startup.dat");
		componentsDatFile=getFileStreamPath("ifeng_commons_push_components.dat");
		load();
		for(String product : startedProducts){
			Utils.LogReceiver("repeat "+product);
			AlarmManager manager=(AlarmManager) getSystemService(ALARM_SERVICE);
			Intent pullIntent = new Intent(this,PushService.class);
			pullIntent.putExtra(EXTRA_PRODUCT, product);
			PendingIntent pendingIntent=PendingIntent.getService(this, 0, pullIntent, PendingIntent.FLAG_CANCEL_CURRENT);;
			manager.setRepeating(AlarmManager.RTC_WAKEUP, System.currentTimeMillis()+INTERVAL, INTERVAL, pendingIntent);//确保活跃，每15分钟监护一次
		}
	}

	@SuppressWarnings("unchecked")
	private void load() {
		if(stopDatFile.exists()){
			try {
				stoppedProducts=(LinkedList<String>) Files.deserializeObject(stopDatFile);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		if(startDatFile.exists()){
			try {
				startedProducts=(LinkedList<String>) Files.deserializeObject(startDatFile);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		if(componentsDatFile.exists()){
			try {
				productComponents=(HashMap<String, SerializeComponent>) Files.deserializeObject(componentsDatFile);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		Utils.LogReceiver("load:"+startedProducts+"\n"+stoppedProducts+"\n"+componentsDatFile);
	}

	@Override
	public void onStart(Intent intent, int startId) {
		executeTask(intent);
	}

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		executeTask(intent);
		return START_NOT_STICKY;
	}
	
	public LinkedList<String> getStartedProducts() {
		return startedProducts;
	}
	
	public LinkedList<String> getStoppedProducts() {
		return stoppedProducts;
	}
	
	public void reset()
	{
		startedProducts=new LinkedList<String>();
		stoppedProducts=new LinkedList<String>();
		save();
	}

	/**
	 * 执行具体Intent的Pull任务
	 * 
	 * @param intent
	 */
	public void executeTask(Intent intent) {
		ALIVE = true;
		if(!PhoneManager.getInstance(this).isConnectedNetwork()){
			stopSelf();
			return;//
		}
		if (intent == null)
			return;
		String product = intent.getStringExtra(EXTRA_PRODUCT);
		if (product == null)
			return;

		if (ACTION_STARTUP.equals(intent.getAction())) {
			if (!startedProducts.contains(product))
				startedProducts.add(product);
			stoppedProducts.remove(product);
			ComponentName componentName=(ComponentName) intent.getParcelableExtra(EXTRA_COMPONENT_NAME);
			SerializeComponent mComponent=new SerializeComponent(componentName.getPackageName(), componentName.getClassName());
			productComponents.put(product, mComponent);
			save();
			Utils.LogReceiver("startup "+product+" "+mComponent);
		}
		if (stoppedProducts.contains(product)) {
			Utils.LogReceiver("prevent stopped "+product);
			return;
		}
		if (ACTION_STOP.equals(intent.getAction())) {
			stoppedProducts.add(product);
			startedProducts.remove(product);
			Intent pullIntent = new Intent(this,PushService.class);
			pullIntent.putExtra(EXTRA_PRODUCT, product);
			PendingIntent pendingIntent=PendingIntent.getService(this, 0, pullIntent, PendingIntent.FLAG_CANCEL_CURRENT);
			AlarmManager manager=(AlarmManager) getSystemService(ALARM_SERVICE);
			manager.cancel(pendingIntent);
			save();
			Utils.LogReceiver("stop "+product);
		} else {
			// do pull
			long nextTimeSpan = INTERVAL;
			try {
				PushEntity entity = Utils.getPushNews(this, product);
				Intent message = new Intent();
				SerializeComponent mComponent=productComponents.get(product);
				if(mComponent!=null)
					message.setComponent(new ComponentName(mComponent.pkg, mComponent.cls));
				message.setAction(ACTION_BASE + product);
				message.putExtra(EXTRA_ENTITY, entity);
				PendingIntent pendingIntent=PendingIntent.getBroadcast(this, 0, message, PendingIntent.FLAG_CANCEL_CURRENT);
				pendingIntent.send();
				Utils.LogReceiver("send message to "+mComponent);
				Utils.getPerformanceSharedPreferences(this)
						.edit()
						.putInt("send_" + product,
								Utils.getPerformanceSharedPreferences(this)
										.getInt("send_" + product, 0) + 1)
						.commit();
				nextTimeSpan = Long.parseLong(entity.getTimer()) * 1000 * 60;
			} catch (Exception ex) {
				ex.printStackTrace();
			}
			Intent setAlarm = new Intent();
			setAlarm.setAction(ACTION_SET);
			setAlarm.putExtra(EXTRA_TIMER, nextTimeSpan);
			setAlarm.putExtra(EXTRA_PRODUCT, product);
			sendBroadcast(setAlarm);
		}
	}

	private void save() {
		try {
			Files.serializeObject(startDatFile, startedProducts);
		} catch (IOException e) {
			e.printStackTrace();
		}
		try {
			Files.serializeObject(stopDatFile, stoppedProducts);
		} catch (IOException e) {
			e.printStackTrace();
		}
		try {
			Files.serializeObject(componentsDatFile, productComponents);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	@Override
	public IBinder onBind(Intent intent) {
		return null;
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		ALIVE = false;
	}
}
