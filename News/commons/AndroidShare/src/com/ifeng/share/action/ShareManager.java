package com.ifeng.share.action;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.widget.Toast;

import com.ifeng.share.activity.EditShareActivity;
import com.ifeng.share.bean.CallbackAction;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.bean.TargetShare;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.fetion.ShareFetion;
import com.ifeng.share.renren.ShareRenren;
import com.ifeng.share.sina.ShareSina;
import com.ifeng.share.tenqt.ShareTenqt;
import com.ifeng.share.tenqz.ShareTenqz;
/**
 * 
 * @author PJW
 *
 */
public class ShareManager  implements ShareAlertInterface {
	public static ShareMessage shareMessage;
	public static String[] definedShareItems = new String[]{"sina","tenqt","renren","fetion","system","tenqz"};
	public static ArrayList<String> defaultShareItems;
	private static Map<String, String> itemsResources = new HashMap<String, String>();
	public static Map<String, TargetShare> targetShareResources = new HashMap<String, TargetShare>();
	private static final ArrayList<String> canShareImageTarget = new ArrayList<String>();
	public static final String SINA = "sina";
	public static final String TENQT = "tenqt";
	public static final String IFENG = "ifeng";
	public static final String RENREN ="renren";
	public static final String KAIXIN = "kaixin";
	public static final String FETION = "fetion";
	public static final String SYSTEM = "system";
	public static final String TENQZ = "tenqz";
	public static final String BIND_ACTION = "bind";
	public static final String UNBIND_ACTION="unbind";
	public static final String SHARE_ACTION= "share";
	public static final String RENREN_AUTHORIZE_SUCCESS="renren.authorize.success";
	static{
		initItemResources();
		initShareImageTarget();
		initTargetShare();
	}
	public static void initItemResources() {
		itemsResources.put("sina", "分享到新浪微博");
		itemsResources.put("renren", "分享到人人网");
		itemsResources.put("tenqt", "分享到腾讯微博");
		itemsResources.put("tenqz", "分享到QQ空间");
		itemsResources.put("fetion", "分享到飞信");
		itemsResources.put("system", "分享到其他");
	}
	public static void initTargetShare(){
		targetShareResources.put(ShareManager.SINA,new TargetShare("新浪微博",ShareManager.SINA,ShareManager.SHARE_ACTION ,new ShareSina(),new CallbackAction()));
		targetShareResources.put(ShareManager.TENQT,new TargetShare("腾讯微博",ShareManager.TENQT ,ShareManager.SHARE_ACTION ,new ShareTenqt(),new CallbackAction()));
		targetShareResources.put(ShareManager.RENREN,new TargetShare("人人网",ShareManager.RENREN,ShareManager.SHARE_ACTION ,new ShareRenren(),new CallbackAction()));
		targetShareResources.put(ShareManager.FETION,new TargetShare("飞信",ShareManager.FETION,ShareManager.SHARE_ACTION ,new ShareFetion(),new CallbackAction()));
		targetShareResources.put(ShareManager.TENQZ,new TargetShare("QQ空间",ShareManager.TENQZ,ShareManager.SHARE_ACTION ,new ShareTenqz(),new CallbackAction()));
	}
	public static void initShareImageTarget() {
		canShareImageTarget.add("sina");
		canShareImageTarget.add("renren");
		canShareImageTarget.add("tenqt");
		canShareImageTarget.add("fetion");
		canShareImageTarget.add("tenqz");
	}
	
	public static void setShareByType(String type){
		shareMessage.setTargetShare(targetShareResources.get(type));
	}
	
	
	@Override
	public void show(Context context) {
		showShareItems(context);
	}
	
	
	private void showShareItems(final Context context){
		Boolean isShowItems=ShareManager.checkOutShareItems();
		if (!isShowItems) {
			showMessage("设置分享列表出错",context);
			return;
		}
		String[] items = getShareItemsTitle();
		AlertDialog.Builder builder = new AlertDialog.Builder(context);
		builder.setTitle("分享");
		builder.setItems(items, new DialogInterface.OnClickListener(){
			@Override
			public void onClick(DialogInterface dialog, int which) {
				String shareType = getTargetTypeByIndex(which);
				setTargetShare(shareType);
				if (ShareManager.SYSTEM.equals(shareType)) {
					showSystemShareItems(context);
				}else {
					forward(context);
				}

			}
		});
		AlertDialog shareDialog = builder.create();
		shareDialog.show();
	}
	private void showMessage(String message, Context context){
		Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
	}
	private void forward(Context context) {
		Intent intent = new Intent(context,EditShareActivity.class);
		context.startActivity(intent);
	}
	private void showSystemShareItems(Context context) {
		Intent other = new Intent("android.intent.action.SEND");
		other.setType("text/plain");
		other.putExtra("android.intent.extra.SUBJECT",shareMessage.getTitle());
		other.putExtra("android.intent.extra.TEXT",shareMessage.getContent());
		Intent exeOther = Intent.createChooser(other, "请选择：");
		context.startActivity(exeOther);
	}
	
	public static String[] getShareItemsTitle(){
		initDefaultShareItems();
		String[] itemsTitle=new String[defaultShareItems.size()];
		ArrayList<TargetShare> definedShareList = shareMessage.definedShareList;
		int itemCount = itemsTitle.length;
		if (definedShareList!=null && definedShareList.size()>0) {
			itemCount += definedShareList.size();
			itemsTitle = new String[itemCount];
			for (int i = 0; i < definedShareList.size(); i++) {
				TargetShare definedShareBean = definedShareList.get(i);
				targetShareResources.put(definedShareBean.getType(),definedShareBean);
				int num = definedShareBean.getNum();
				if (num<=0)num=1;
				if (num<=itemCount) {
					itemsTitle[num-1] = definedShareBean.getName();
					defaultShareItems.add(num-1,definedShareBean.getType());
				}else {
					itemsTitle[itemCount-1] = definedShareBean.getName();
					defaultShareItems.add(itemCount-1,definedShareBean.getType());
				}
				
			}
		}
		for (int i = 0; i < itemCount; i++) {
			if (itemsTitle[i]!=null && itemsTitle[i].length()>0) {
				continue;
			}else {
				itemsTitle[i]=itemsResources.get(defaultShareItems.get(i));
			}	
		}
		return itemsTitle;
	}
	public String filterTitle(String definedTitle){
		return "分享到"+definedTitle;
	}
	public static Boolean isDefinedShareNull(){
		ArrayList<TargetShare> definedShareBeans = shareMessage.getDefinedShareList();
		if (definedShareBeans==null || definedShareBeans.size()==0) {
			return false;
		}
		return true;
	}
	public static Boolean checkOutShareItems(){
		for (int i = 0; i < definedShareItems.length; i++) {
			if (!itemsResources.containsKey(definedShareItems[i])) {
				return false;
			}
		}
		return true;
	}
	public static String getTargetTypeByIndex(int position){
		return defaultShareItems.get(position);
	}
	public static void setTargetShare(String target){
		shareMessage.setTargetShare(targetShareResources.get(target));
	}
	public static void setShareImageUrl(String shareImageUrl){
		shareMessage.setShareImageUrl(shareImageUrl);
	}
	public static void setShareContent(String content){
		shareMessage.setContent(content);
	}
	public static ShareMessage getShareMessage() {
		return shareMessage;
	}

	public static void setShareMessage(ShareMessage shareMessage) {
		ShareManager.shareMessage = shareMessage;
	}
	public static Boolean isShareImage(String target){
		if (canShareImageTarget.contains(target)) {
			return true;
		}
		return false;
	}
	public static String getTargetState(Context context,String type) {
		if (TokenTools.getToken(context, type)==null) {
			return "未绑定";
		}else {
			return "已绑定";
		}
	}
	public static void initDefaultShareItems(){
		defaultShareItems= new ArrayList<String>();
		for (int i = 0; i < definedShareItems.length; i++) {
			defaultShareItems.add(definedShareItems[i]);
		}
	}
	public static void setDefaultShareItems(String[] shareItems){
		if (shareItems!=null && shareItems.length>0) {
			definedShareItems = shareItems;
		}
	}
	public static String getTargetName(String target){
		if (RENREN.equals(target)) {
			return "人人网";
		} else if (TENQT.equals(target)) {
			return "腾讯微博";
		}else if (IFENG.equals(target)) {
			return "凤凰快博";
		}else if (FETION.equals(target)) {
			return "飞信";
		}else if (TENQZ.equals(target)) {
			return "QQ空间";
		}else {
			return "新浪微博";
		}
	}
	/**
	 * 删除账号密码缓存
	 * @param activity
	 */
	public static void deleteCookie(Activity activity){
		CookieSyncManager.createInstance(activity);
		CookieManager cookieManager = CookieManager.getInstance();
		cookieManager.removeAllCookie();
	}

}
