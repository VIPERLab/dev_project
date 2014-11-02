package com.ifeng.news2.push;

import java.util.Calendar;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.PowerManager;
import android.preference.PreferenceManager;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationCompat.Builder;
import android.text.TextUtils;

import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.ListUnit;
import com.ifeng.news2.util.FilterUtil;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.StatisticUtil;

public class PushMessageReceiver extends BroadcastReceiver {

	/**
	 * 存储已收到的推送消息的标题
	 */
//	private static final String PUSH_MESSAGE_FILE = "push_messages.dat";
	/**
	 * 内存中存储已收到的推送消息的标题
	 */
//	private static HashSet<String> pushMessageTitles = null;
//	Plugins plugins;
	private PowerManager.WakeLock mWakeLock;
	private final int ACQUIRE_WAKE_LOCK = 1;
	private final int RELEASE_WAKE_LOCK = 2;

	@Override
	public void onReceive(Context context, Intent intent) {
	/*	只保留长连接推送后，不需要再考虑重复收到推送消息的问题
		// 得到当天午夜0点时的毫秒数
		Calendar c = Calendar.getInstance(); 
//		c.add(Calendar.DAY_OF_MONTH, -1);
		c.set(Calendar.HOUR, 0);
		c.set(Calendar.MINUTE, 0);
		c.set(Calendar.SECOND, 0);
		long threshold = c.getTimeInMillis();
		
		if (context.getFileStreamPath(PUSH_MESSAGE_FILE).lastModified() < threshold) {
			// 如果缓存文件的修改日期是前一天时清空文件，因为目前ipush和消息盒子对推送消息的缓存时间都是一天
			context.getFileStreamPath(PUSH_MESSAGE_FILE).delete();
		}
		
		if (null == pushMessageTitles) {
			// try to get saved data from file
			try {
				pushMessageTitles = (HashSet<String>) Files.deserializeObject(context.getFileStreamPath(PUSH_MESSAGE_FILE));
			} catch (IOException e) {
				Log.w("MessageReceiver", "IOException occur while deserializing object " + e.getMessage());
			} finally {
				if (null == pushMessageTitles) {
					pushMessageTitles = new HashSet<String>();
				}
			}
		}
		*/
		
		if ("action.com.ifeng.news2.push.IPUSH_MESSAGE".equals(intent.getAction())) {
			// 从ipush长连接收到消息
			Bundle b = intent.getBundleExtra(PushConfig.PUSH_EXTRA_BUNDLE);
			String title = b.getString("title");
			String message = b.getString("message");
			String id = b.getString("id");
			String sound = b.getString("sound");
//			ListUnit unit = (ListUnit) b.getSerializable("listUnit");
			
//			synchronized (PushMessageReceiver.class) {
//				if (! pushMessageTitles.contains(title)) {
					// 新推送消息
//					pushMessageTitles.add(title);
					showNotification4IpushMessage(context, title, message, id, sound);//, unit);
//					try {
//						Files.serializeObject(context.getFileStreamPath(PUSH_MESSAGE_FILE), pushMessageTitles);
//					} catch (IOException e) {
//						Log.w("MessageReceiver", "IOException occur while serializing object " + e.getMessage());
//					}
//				} else {
//					Log.w("MessageReceiver", "IPUSH get message which already be notified, title=" + title + ", id=" + id);
//				}
				
//			}
			
			
		} 
/*
		else {
			// 从消息盒子收到消息
			Bundle b = intent.getBundleExtra(PushService.EXTRA_BUNDLE);
			EntityClass entity = (EntityClass) b.getSerializable(PushService.EXTRA_ENTITY);
			if (entity.getEntity().getAllMessages().size() <= 0)
				return;
	
			String productId = entity.getPid();
			if (plugins == null)
				plugins = PluginManager.loadPlugins(context);
			Plugin plugin = plugins.findPluginById(productId);
			if (plugin == null || !Utils.getPluginActive(context, productId))
				return;
	
			if (!Config.isLibrary(context)) {
				saveMessages(context, entity.getEntity(), productId);
				sendUnreadCountBroadcast(context, entity.getEntity());
			}
			if (Utils.getMessageNoticeState(context)) {
				showNotification(context, plugin, entity.getEntity());
			}
		}
*/
	}

	private void showNotification4IpushMessage(Context ctx, String title, String message, String id, String sound) {
		// 唤醒屏幕
		PowerManager pm = (PowerManager) ctx.getSystemService(Context.POWER_SERVICE);
		mWakeLock = pm.newWakeLock(PowerManager.ACQUIRE_CAUSES_WAKEUP | PowerManager.FULL_WAKE_LOCK, "唤醒屏幕5秒钟");
		handler.sendEmptyMessage(ACQUIRE_WAKE_LOCK);
		// 发送pushaccess统计
		record(id);
		
		// 创建启动文章页intent
		Intent base=new Intent("action.com.ifeng.news2.push");
		base.setPackage("com.ifeng.news2");
		base.setClassName(ctx, "com.ifeng.news2.activity.DetailActivity");
		base.putExtra("extra.com.ifeng.news2.id", id);
		base.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
				| Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
				| Intent.FLAG_ACTIVITY_NEW_TASK);
		
		PendingIntent pendingIntent = PendingIntent.getActivity(ctx, (int)(Math.random() * 100000), base,
				PendingIntent.FLAG_UPDATE_CURRENT);
		
		// build通知
		int icon = ctx.getApplicationContext().getResources().getIdentifier("icon", "drawable", ctx.getPackageName());			
		Uri soundUri = getSoundUri(sound, ctx);
		NotificationCompat.BigTextStyle bigTextStyle = new NotificationCompat.BigTextStyle();
		bigTextStyle.setBigContentTitle(title).bigText(message);
		
		Builder builder = new NotificationCompat.Builder(ctx)
//	    .setLargeIcon(BitmapFactory.decodeResource(context.getResources(),icon))
	    .setSmallIcon(icon)
	    .setContentTitle(title)
	    .setContentText(message)
	    .setStyle(bigTextStyle)
	    .setLights(Color.GREEN, 1, 0)
	    .setWhen(System.currentTimeMillis())
	    .setContentIntent(pendingIntent);
		if(checkShouldsounding(ctx) && null != soundUri){
			builder.setSound(soundUri);
		}
		Notification notification = builder.build();						
		notification.flags = notification.flags | Notification.FLAG_AUTO_CANCEL | Notification.FLAG_SHOW_LIGHTS;
		
		// 发送通知
		NotificationManager manager = (NotificationManager) ctx.getSystemService(Context.NOTIFICATION_SERVICE);
		manager.notify(ctx.getPackageName(), 1111, notification);
	}

	/**
	 * 统计接收到的推送
	 */
	private void record(String id) {
		if(!TextUtils.isEmpty(id)){
//			Statistics.addRecord("PUSH_ARRIVE", URLEncoder.encode(id));
			StatisticUtil.addRecord(StatisticUtil.StatisticRecordAction.pushaccess, "aid="+FilterUtil.filterIdFromUrl(id));
		}		
	}

	/**
	 * Added for playing the ringing sound of push message from the server
	 */
	private Uri getSoundUri(String sound, Context context) {
		String soundFile = sound;
		Uri soundUri = null;
		if (!TextUtils.isEmpty(soundFile)) {
			int soundResId = context.getApplicationContext().getResources()
					.getIdentifier(soundFile, "raw", context.getPackageName());
			if (soundResId != 0) {
				soundUri = Uri.parse("android.resource://"
						+ context.getPackageName() + "/" + soundResId);
			}
		}
		return soundUri;
	}

	/**
	 * checking whether need to be mute or not
	 * @param context
	 * @return
	 */
	private boolean checkShouldsounding(Context context) {
		boolean shouldSouding = true;
		SharedPreferences sharedPreferences =  PreferenceManager.getDefaultSharedPreferences(context);
		boolean hasSetted = sharedPreferences.getBoolean("non_disturbance", true);
		Calendar cal = Calendar.getInstance();
		int currentHourse = cal.get(Calendar.HOUR_OF_DAY);
		//在夜间
		if(currentHourse>21||currentHourse<8){
			if(hasSetted){
				shouldSouding = false;
			}
		}
		return shouldSouding;
	}

	/* < ifengnews 3.3.0 20120917 liuxiaoliang add begin */
	// 处理屏幕点亮以及关闭
	Handler handler = new Handler() {
		@Override
		public void handleMessage(android.os.Message msg) {
			super.handleMessage(msg);
			switch (msg.what) {
			case ACQUIRE_WAKE_LOCK:
				mWakeLock.acquire();
				this.removeMessages(RELEASE_WAKE_LOCK);
				this.sendMessageDelayed(
						this.obtainMessage(RELEASE_WAKE_LOCK, 0, 0), 5000);
				break;

			case RELEASE_WAKE_LOCK:
				mWakeLock.release();
				break;

			default:
				break;
			}
		}
	};
	/* ifengnews 3.3.0 20120917 liuxiaoliang add end > */
}
