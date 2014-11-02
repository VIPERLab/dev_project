package com.ifeng.news2.push;

import android.app.PendingIntent;
import android.app.PendingIntent.CanceledException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.ifeng.ipush.client.Ipush;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.activity.DetailActivity;
import com.ifeng.news2.bean.ListUnit;
import com.ifeng.news2.util.ParamsManager;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;

public class IfengPushReceiver extends BroadcastReceiver {

	/**
	 * 与消息盒子共用的MessageReceiver注册监听下面的action，当收到ipush推送过来的消息后广播这个action
	 */
	public static final String ACTION_IPUSH_MESSAGE = "action.com.ifeng.news2.push.IPUSH_MESSAGE";
	private static final String TAG = "IfengPushReceiver";
	
	@Override
	public void onReceive(final Context context, Intent intent) {
		Bundle bundle = intent.getExtras();
		String pushMsg = bundle.getString("Msg");
		
		if(Ipush.ACTION_NOTIFICATION_RECEIVED.equals(intent.getAction())){
			//接收到通知
			Log.i(TAG, "receive a notification : " + intent.getAction());
			Log.w(TAG, "msg content: " + pushMsg);
		}else if (Ipush.ACTION_NOTIFICATION_OPENED.equals(intent.getAction())){
			Log.i(TAG, "ACTION_NOTIFICATION_OPENED : " + bundle);
			//用户打开通知
			Intent intent_dist = new Intent();
			intent_dist.setClass(context, DetailActivity.class);
			if(bundle != null){
				intent_dist.putExtras(bundle);
			}
			intent_dist.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			context.startActivity(intent_dist);
			Log.i(TAG, "a notification is opened : " + intent.getAction());
			return;
		}else if (Ipush.ACTION_MESSAGE_RECEIVED.equals(intent.getAction())){
			//接收到消息
			Log.i(TAG, "receive a msg : " + intent.getAction());
			Log.w(TAG, "msg content: " + bundle.getString("Msg"));
		}
		try {
//			String newmsg = pushMsg.replace("\\\\","");
//			Log.w(TAG, "processed msg: " + newmsg);
			final IPushBean ipushBean = Parsers.newIPushBeanParser().parse(pushMsg);
			// 目前只支持doc类型的推送消息
			if (!"doc".equals(ipushBean.getExtra().getType())) {
				Log.w(TAG, "get unsupported message type: " + ipushBean.getExtra().getType());
				return;
			}

			Bundle b = new Bundle();
			b.putCharSequence("title", ipushBean.getTitle());
			b.putCharSequence("message", ipushBean.getContent());
			b.putCharSequence("id", ipushBean.getExtra().getId());
			b.putCharSequence("sound", ipushBean.getExtra().getSound());
			Intent messageIntent = new Intent(ACTION_IPUSH_MESSAGE);
			messageIntent.setPackage(context.getPackageName());
			messageIntent.putExtra(PushConfig.PUSH_EXTRA_BUNDLE, b);
			PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, messageIntent,
							PendingIntent.FLAG_CANCEL_CURRENT);
			pendingIntent.send();
			
/*			
			IfengNewsApp.getBeanLoader().startLoading(new LoadContext<String, LoadListener<ListUnit>, ListUnit>(ParamsManager.addParams(String.format(Config.PUSHLIST_URL, ipushBean.getExtra().getAid())), new LoadListener<ListUnit>() {

				@Override
				public void postExecut(LoadContext<?, ?, ListUnit> loadContext) {
					if(isInvalidResult(loadContext)){
						loadContext.setResult(null);
					}
				}

				@Override
				public void loadComplete(LoadContext<?, ?, ListUnit> loadContext) {
					Bundle b = new Bundle();
					b.putCharSequence("title", ipushBean.getTitle());
					b.putCharSequence("message", ipushBean.getContent());
					b.putSerializable("listUnit", loadContext.getResult());
					b.putCharSequence("sound", ipushBean.getExtra().getSound());
					b.putCharSequence("message", ipushBean.getContent());
					Intent messageIntent = new Intent(ACTION_IPUSH_MESSAGE);
					messageIntent.setPackage(context.getPackageName());
					messageIntent.putExtra(PushConfig.PUSH_EXTRA_BUNDLE, b);
					PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, messageIntent,
									PendingIntent.FLAG_CANCEL_CURRENT);
					try {
						pendingIntent.send();
					} catch (CanceledException e) {
						Log.e(TAG, "Exception occurs when receiving message from ipush.", e);
					}
				}

				@Override
				public void loadFail(LoadContext<?, ?, ListUnit> loadContext) {
					LogHandler.addLogRecord("IfengPushReceiver", "Fail to access push list", loadContext.getParam().toString());
				}
				
				private boolean isInvalidResult(
						LoadContext<?, ?, ListUnit> loadContext) {
					return loadContext.getResult() == null || loadContext.getResult().getUnitListItems().size()<1 || loadContext.getResult().getUnitListItems().get(0)==null || loadContext.getResult().getUnitListItems().get(0).getLinks().size()<1;
				}

			}, ListUnit.class, Parsers.newListUnitParser(), LoadContext.FLAG_HTTP_ONLY));
*/
			
//			String pushContent = ipushBean.getContent();
//			Log.w(TAG, "pushContent: " + pushContent);
//			
//			LinkedList<EntityClass> entity = com.ifeng.messagebox.util.Parsers.newPullEntityParser().parse(pushContent);
//
//			for (int i = 0; i < entity.size(); i++) {
//				Bundle b = new Bundle();
//				b.putSerializable(PushService.EXTRA_ENTITY, entity.get(i));
//				Intent messageIntent = new Intent(PushService.ACTION_MESSAGE);
//				messageIntent.setPackage(context.getPackageName());
//				messageIntent.putExtra(PushService.EXTRA_BUNDLE, b);
//				PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, messageIntent,
//								PendingIntent.FLAG_CANCEL_CURRENT);
//				pendingIntent.send();
//			}
			
//		} catch (ParseException e) {
//			Toast.makeText(context, "ParseException occurs, " + e.getMessage(), Toast.LENGTH_SHORT).show();
//			// TODO Auto-generated catch block
//			e.printStackTrace();
		} catch (Exception e) {
			Log.e(TAG, "Exception occurs when receiving message from ipush.", e);
		}
		
	}

}
