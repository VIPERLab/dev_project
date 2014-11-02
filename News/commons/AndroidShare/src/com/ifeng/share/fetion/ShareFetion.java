package com.ifeng.share.fetion;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.os.AsyncTask;
import android.util.Log;
import android.widget.Toast;
import com.fetion.apis.android.DemonAndroid;
import com.fetion.apis.android.Response;
import com.fetion.apis.lib.model.Contact;
import com.ifeng.share.activity.FetionAuthoActivity;
import com.ifeng.share.bean.ShareInterface;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.sina.WeiboHelper.BindListener;
/**
 * 飞信分享
 * @author PJW
 *
 */
public class ShareFetion implements ShareInterface {
	private Activity activity;
	private DemonAndroid demonAndroid;
	private FetionFriendAdapter fetionFriendAdapter;
	private ProgressDialog friendProgressDialog;
	@Override
	public Boolean share(ShareMessage shareMessage) {
		if (shareMessage==null) {
			return false;
		}
		return sendMessage(shareMessage.getContent());
	}

	@Override
	public void bind(Activity activity,BindListener bindListener) {
		login();
	}

	@Override
	public void unbind(Activity activity) {
		/*try {
			FetionManager.unbindFetion(activity);
			//demonAndroid.logout(activity);
		} catch (Exception e) {
			showMessage("解绑失败");
		}*/
	}

	@Override
	public Boolean isAuthorzine(Activity activity) {
		this.activity = activity;
		demonAndroid =  DemonAndroid.getInstance();
		initProgressDialog(activity);
		//return FetionManager.isAuthorzine(activity);
		return FetionManager.isBind;
	}

	public void initProgressDialog(Activity activity) {
		friendProgressDialog=new ProgressDialog(activity);
		friendProgressDialog.setMessage("载入中...");
	}

	@Override
	public void shareSuccess() {

	}

	@Override
	public void shareFailure() {

	}
	/**
	 * 飞信登录
	 */
	public void login(){
		Intent fetionIntent = new Intent(activity,FetionAuthoActivity.class);
		activity.startActivity(fetionIntent);
	}
	/**
	 * 发送飞信消息
	 */
	public Boolean sendMessage(String message){
		new GetFriendsTask(message).execute();
		return true;
	}
	public void showFriendsDialog(final String message,final Contact[] friendsContacts){
		fetionFriendAdapter = new FetionFriendAdapter(activity, friendsContacts);
		new AlertDialog.Builder(activity).setTitle("好友列表").setAdapter(fetionFriendAdapter, new OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				Contact contact =  friendsContacts[which];
				new SendMessageTask(contact.getUserId(), contact.getUri(), message).execute();
				dialog.dismiss();
			}
		}).show();
	}
	public class SendMessageTask extends AsyncTask<Integer, Integer, Response>{
		private String userId;
		private String uri;
		private String message;
		public SendMessageTask(String userId,String uri,String message){
			this.message = message;
			this.userId = userId;
			this.uri = uri;
		}
		@Override
		protected Response doInBackground(Integer... params) {
			Response sendResponse=null;
			try {
				sendResponse = demonAndroid.sendMessage(userId, uri, message, false, FetionManager.isCMWAP(activity));
			} catch (Exception e) {
				return null;
			}
			return sendResponse;
		}

		@Override
		protected void onPreExecute() {
			super.onPreExecute();
			showMessage("发送中...");
		}

		@Override
		protected void onPostExecute(Response result) {
			super.onPostExecute(result);
			if (result!=null) {
				String sendCode= result.getStatusCode();
				if ("200".equals(sendCode)||"201".equals(sendCode)||"280".equals(sendCode)||"400".equals(sendCode)) {
					showMessage(result.getResult());
				}else {
					showMessage("发送失败");
				}
			}else {
				showMessage("发送失败");
			}
			activity.finish();
		}

	}
	public class GetFriendsTask extends AsyncTask<Integer, Integer, Contact[]>{
		private String message;
		public GetFriendsTask(String message){
			this.message = message;
		}
		@Override
		protected Contact[] doInBackground(Integer... params) {
			return getFriendsList();
		}

		@Override
		protected void onPreExecute() {
			super.onPreExecute();
			friendProgressDialog.show();
		}

		@Override
		protected void onPostExecute(Contact[] result) {
			super.onPostExecute(result);
			friendProgressDialog.dismiss();
			if (result!=null) {
				showFriendsDialog(message,result);
			}else {
				FetionManager.isBind=false;
				showMessage("获取好友失败,请稍后再试");
			}
		}
	}
	/**
	 * 获取飞信好友名单
	 */
	public Contact[] getFriendsList() {
		Contact[] contacts=null;
		if (FetionManager.fetionFriends!=null && FetionManager.fetionFriends.length>0) {
			return FetionManager.fetionFriends;
		}
		try {
				Response responseFriends=demonAndroid.getContactList(false, FetionManager.isCMWAP(activity));
				String errorCode=responseFriends.getErrorCode();
				String returnCode = responseFriends.getReturnCode();
				Log.i("share","Get FetionFriends From FetionSDK Code : "+responseFriends.getReturnCode());
				Log.i("share", "getStatusCode:"+responseFriends.getStatusCode());
				Log.i("share", "errorCode:"+responseFriends.getErrorCode());
				Log.i("share", "getContacts:"+responseFriends.getContacts());
				Log.i("share", "getResponseData:"+responseFriends.getResponseData());
				if ("200".equals(returnCode)) {
					contacts = responseFriends.getContacts();
					if (contacts!=null && contacts.length>0) {
						FetionManager.saveFriendsData(activity, contacts);
					}
				}else if("431".equals(errorCode)){
					Log.i("share","Get FetionFriends From Local");
					contacts = FetionManager.getFriendsData(activity);
				}
		} catch (Exception e) {
			return null;
		}
		return contacts;
	}
	
	public void showMessage(String message){
		Toast.makeText(activity, message, Toast.LENGTH_SHORT).show();
	}

	@Override
	public void authCallback(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		
	}
}
