package com.ifeng.share.fetion;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.Date;

import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.net.Uri;
import android.util.Log;

import com.base.adapter.ApnManagerFactor;
import com.base.adapter.IApnManager;
import com.fetion.apis.lib.model.Contact;
import com.ifeng.share.action.ShareManager;
import com.ifeng.share.config.TokenTools;
/**
 * 飞信分享管理
 * @author PJW
 *
 */
public class FetionManager {
	public static String redirectURL = "fetion://shareSDK";
	public final static String FETION_FRIENDS_FILE="friends.dat";
	public final static String FETION_FRIENDS_ICON="fetionFriends";
	public final static long FETION_FRIENDS_TIME=86400000;
	public static String NETWORK_TYPE="";
	public static Contact[] fetionFriends = null;
	public static Boolean isBind=false;
	/**
	 * 是否绑定
	 * @param activity
	 * @return
	 */
	public static Boolean isAuthorzine(Activity activity) {
		String fetionToken =TokenTools.getToken(activity, ShareManager.FETION);
		if (fetionToken==null || fetionToken.length()==0) {
			return false;
		}
		return true;
	}
	/**
	 * 分享解绑
	 * @param activity
	 */
	public static void unbindFetion(Activity activity){
		TokenTools.removeToken(activity, ShareManager.FETION);
		Log.i("share", "unbindFetion success");
	}
	public static String parseResponseData(String response) throws Exception{
		JSONObject jsonObject =new JSONObject(response);
		String access_token = jsonObject.getString("access_token");
		return access_token;
	}
	public static void saveFriendsData(Context context,Contact[] friends){
		fetionFriends = friends;
		FetionData fetionData = new FetionData();
		fetionData.setFriends(friends);
		try {
			serializeObject(context.openFileOutput(FETION_FRIENDS_FILE, Context.MODE_PRIVATE),fetionData);
			Log.i("share", "fetion friends save seccess");
		} catch (Exception e) {
			e.printStackTrace();
			Log.i("share", "fetion friends save failure");
		}
	}
	public static void restoreFriendsDatas(Context context){
		Log.i("share", "restore fetion friends");
		Contact[] friends= new Contact[]{};
		FetionData fetionData = new FetionData();
		fetionData.setFriends(friends);
		try {
			serializeObject(context.openFileOutput(FETION_FRIENDS_FILE, Context.MODE_PRIVATE),fetionData);
		} catch (Exception e) {
		}
	}
	public static Contact[] getFriendsData(Context context){
		try {
			FetionData fetionData =  (FetionData)deserializeObject(context.openFileInput(FETION_FRIENDS_FILE));
			Contact[] localFriends=fetionData.getFriends();
			fetionFriends = localFriends;
			return localFriends;
		} catch (Exception e) {
			Log.i("share", "fetion friends get failure");
			return null;
		}
	}
	private static Serializable deserializeObject(FileInputStream fis)
			throws IOException {
		try {
			ObjectInputStream ois = new ObjectInputStream(fis);
			Serializable obj = (Serializable) ois.readObject();
			ois.close();
			return obj;
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return null;
	}
	private static void serializeObject(FileOutputStream fileout,
			Serializable serializable) throws IOException {
		ObjectOutputStream oos = new ObjectOutputStream(fileout);
		oos.writeObject(serializable);
		oos.close();
	}
	private static void getNetworkType(Context ctx){
		if (NETWORK_TYPE==null || NETWORK_TYPE.length()==0) {
			IApnManager apnManager = ApnManagerFactor.getInstance(ctx).create();
			String apnuri = apnManager.getApnURI();
			Uri PREFERRED_APN_URI = Uri.parse(apnuri);
			Cursor cursor = ctx.getContentResolver().query(PREFERRED_APN_URI, new String[]{"_id", "apn", "type"},null, null, null);
			cursor.moveToFirst();
			if (!cursor.isAfterLast()){
				String apn = cursor.getString(1);
				Log.i("share", "apn="+apn);
				if("".equals(apn) || null==apn){  
					NETWORK_TYPE="";
				}else{
					apn = apn.toLowerCase();
					if(apn.startsWith("cmwap")){
						NETWORK_TYPE="cmwap";
					}
				}
			}
		}
	}
	public static Boolean isCMWAP(Context context){
		getNetworkType(context);
		if ("cmwap".equals(NETWORK_TYPE)) {
			return true;
		}
		return false;
	}
}
