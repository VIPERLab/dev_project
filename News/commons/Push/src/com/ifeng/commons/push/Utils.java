package com.ifeng.commons.push;

import java.io.IOException;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

import com.qad.net.HttpManager;
import com.qad.system.PhoneManager;

public class Utils {

	public static void ensurePushService(Context context)
	{
		boolean connected=PhoneManager.getInstance(context).isConnectedNetwork();
		if(!PushService.ALIVE && connected)
		{
			context.startService(getPushIntent());
		}
	}
	
	static PushEntity getPushNews(Context context,String product) throws IOException, JSONException{
		String url="http://ct1.ifeng.com/fhzk/v2/ifengnews/getPushNews?type="+product+"&timestamp="+getTimeStamp(context,product);
		LogReceiver("getPushNews:"+url);
		String content=HttpManager.getHttpText(url);
		PushEntity entity = parsePushEntity(content);
		LogReceiver("entity:"+entity.toString());
		saveTimeStamp(context, product,entity.getTimeStamp());
		return entity;
	}
	
	public static void clearTimeStamp(Context context,String product)
	{
		saveTimeStamp(context, product, "0");
	}
	
	private static void saveTimeStamp(Context context,String product,String timeStamp)
	{
		context.getSharedPreferences("push_"+product, Context.MODE_PRIVATE)
			.edit().putLong("timestamp", Long.parseLong(timeStamp)).commit();
	}
	
	public static long getTimeStamp(Context context,String product)
	{
		return context.getSharedPreferences("push_"+product, Context.MODE_PRIVATE)
				.getLong("timestamp", 0);
	}

	public static PushEntity parsePushEntity(String content)
			throws JSONException {
		PushEntity entity=new PushEntity();
		JSONObject object=new JSONObject(content);
		entity.setMsg(object.getString("msg"));
		entity.setProduct(object.getString("product"));
		entity.setTimeStamp(object.getString("timestamp"));
		JSONObject para=object.getJSONObject("para");
		entity.setId(para.getString("id"));
		entity.setTimer(para.getString("timer"));
		entity.setType(para.getString("type"));
		return entity;
	}
	
	public static void LogReceiver(Object message)
	{
		Log.d("PushReceiver", message+"");
	}
	
	public static Intent getPushIntent()
	{
		Intent intent=new Intent();
		intent.setAction("com.ifeng.commons.push.PushService");
		return intent;
	}
	
	public static SharedPreferences getPerformanceSharedPreferences(Context context){
		return context.getSharedPreferences("push_performance", Context.MODE_PRIVATE);
	}
}
