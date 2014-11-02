package com.ifeng.share.action;

import java.util.ArrayList;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.widget.Toast;

import com.ifeng.share.activity.EditShareActivity;
import com.ifeng.share.bean.CallbackAction;
import com.ifeng.share.bean.ShareInterface;
import com.ifeng.share.bean.ShareMessage;
import com.ifeng.share.bean.TargetShare;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.sina.WeiboHelper.BindListener;
/**
 * 分享功能入口
 * @author PJW
 *
 */
public class ShareAction {
	private ShareMessage shareMessage;
	private Activity context;
	public ShareAction(){
	}
	public ShareAction(Activity activity){
		this.context=activity;
		initShareMessage();
	}
	public static ShareAction init(Activity activity) {
		return new ShareAction(activity);
	}
	
	private void initShareMessage() {
		shareMessage = new ShareMessage();
	}
	/**
	 * 设置分享标题
	 * @param title
	 * @return
	 */
	public ShareAction setShareTitle(String title){
		shareMessage.setTitle(title);
		return this;
	}
	/**
	 * 设置分享内容描述(人人网)
	 * @param description
	 * @return
	 */
	public ShareAction setShareDescription(String description){
		shareMessage.setDescription(description);
		return this;
	}
	/**
	 * 设置App名称
	 * @param actionName
	 * @return
	 */
	public ShareAction setShareActionName(String actionName){
		shareMessage.setActionName(actionName);
		return this;
	}
	/**
	 * 设置分享内容
	 * @param content
	 * @return
	 */
	public ShareAction setShareContent(String content){
		shareMessage.setContent(content);
		return this;
	}
	/**
	 * 设置分享副标题(人人网)
	 * @param caption
	 * @return
	 */
	public ShareAction setShareCaption(String caption){
		shareMessage.setCaption(caption);
		return this;
	}
	/**
	 * 设置分享图片url
	 * @param imageResources
	 * @return
	 */
	public ShareAction setShareImageResources(ArrayList<String> imageResources) {
		shareMessage.setImageResources(imageResources);
		return this;
	}
	/**
	 * 设置分享内容的url地址
	 * @param url
	 * @return
	 */
	public ShareAction setShareUrl(String url){
		shareMessage.setUrl(url);
		return this;
	}
	/**
	 * 设置分享列表样式(sina/renren/tenqt/system)
	 * 如: new String[]{"renren","sina"}
	 * @param shareItems
	 * @return
	 */
	public ShareAction setShareItems(String[] definedShareItems){
		if (definedShareItems!=null && definedShareItems.length>0) {
			ShareManager.setDefaultShareItems(definedShareItems);
		}
		return this;
	}
	/**
	 * 添加自定义分享
	 * @param definedShareBean
	 * @return
	 */
	public ShareAction addDefinedShare(TargetShare targetShare){
		targetShare.setAction(ShareManager.SHARE_ACTION);
		shareMessage.addDefinedShare(targetShare);
		return this;
	}
	/**
	 * 调用分享列表
	 */
	public void shareBox(){
		saveShareMessage();
		showShareItems();
	}
	/**
	 * 分享功能
	 * @param targetShare
	 */
	public void share(TargetShare targetShare){
		if (targetShare!=null) {
			targetShare.setAction(ShareManager.SHARE_ACTION);
			shareMessage.setTargetShare(targetShare);
			saveShareMessage();
			forward();
		}
	}
	/**
	 * 分享新浪
	 */
	public void shareSina(){
		share(getTargetShare(ShareManager.SINA));
	}
	/**
	 * 分享腾讯
	 */
	public void shareTenqt(){
		share(getTargetShare(ShareManager.TENQT));
	}
	/**
	 * 分享人人网
	 */
	public void shareRenren(){
		share(getTargetShare(ShareManager.RENREN));
	}
	/**
	 * 分享飞信
	 */
	public void shareFetion(){
		share(getTargetShare(ShareManager.FETION));
	}
	/**
	 * 分享QQ空间
	 */
	public void shareTenqz(){
		share(getTargetShare(ShareManager.TENQZ));
	}
	/**
	 * 绑定功能
	 * @param targetShare
	 */
	public void bind(TargetShare targetShare,BindListener bindListener){
		if (targetShare!=null) {
			targetShare.setAction(ShareManager.BIND_ACTION);
			shareMessage.setTargetShare(targetShare);
			saveShareMessage();
			startBind(targetShare.getShareInterface(),bindListener);
		}
	}
	/**
	 * 绑定功能
	 * @param targetShare
	 */
	public void bind(String type,BindListener bindListener){
		TargetShare bindTargetShare = getTargetShare(type);
		if (bindTargetShare!=null) {
			bindTargetShare.setAction(ShareManager.BIND_ACTION);
			shareMessage.setTargetShare(bindTargetShare);
			saveShareMessage();
			startBind(bindTargetShare.getShareInterface(),bindListener);
		}
	}
	/**
	 * 绑定功能
	 * @param targetShare
	 */
	public void bind(String type,CallbackAction callback,BindListener bindListener){
		TargetShare bindTargetShare = getTargetShare(type);
		if (bindTargetShare!=null) {
			bindTargetShare.setAction(ShareManager.BIND_ACTION);
			bindTargetShare.setCallback(callback);
			shareMessage.setTargetShare(bindTargetShare);
			saveShareMessage();
			startBind(bindTargetShare.getShareInterface(),bindListener);
		}
	}
	/**
	 * 解绑定功能
	 * @param targetShare
	 */
	public void unbind(TargetShare targetShare){
		if (targetShare!=null) {
			ShareInterface shareInterface = targetShare.getShareInterface();
			shareInterface.unbind(context);
		}
	}
	/**
	 * 解绑定功能
	 * @param targetShare
	 */
	public void unbind(String type){
		TargetShare unbindTargetShare =getTargetShare(type);
		if (unbindTargetShare!=null) {
			ShareInterface shareInterface = unbindTargetShare.getShareInterface();
			shareInterface.unbind(context);
		}
	}
	/**
	 * 判断是否绑定
	 * @param targetShare
	 * @return
	 */
	public Boolean isAuthorize(TargetShare targetShare){
		if (targetShare!=null) {
			ShareInterface targetInterface = targetShare.getShareInterface();
			return targetInterface.isAuthorzine(context);
		}
		return false;
	}
	public Boolean isAuthorize(String type){
		TargetShare targetShare = getTargetShare(type);
		if (targetShare!=null) {
			ShareInterface targetInterface = targetShare.getShareInterface();
			return targetInterface.isAuthorzine(context);
		}
		return false;
	}
	/**
	 * 获取账号用户名
	 * @param context
	 * @return
	 */
	public String getUsername(String type){
		return TokenTools.getUserName(context, type);
	}
	private TargetShare getTargetShare(String type){
		return ShareManager.targetShareResources.get(type);
	}
	private void startBind(ShareInterface shareInterface,BindListener bindListener){
		shareInterface.bind(context,bindListener);
	}
	private void saveShareMessage(){
		ShareManager.shareMessage = shareMessage;
	}
	private void showShareItems(){
		Boolean isShowItems=ShareManager.checkOutShareItems();
		if (!isShowItems) {
			showMessage("设置分享列表出错");
			return;
		}
		String[] items = ShareManager.getShareItemsTitle();
		AlertDialog.Builder builder = new AlertDialog.Builder(context);
		builder.setTitle("分享");
		builder.setItems(items, new DialogInterface.OnClickListener(){
			@Override
			public void onClick(DialogInterface dialog, int which) {
				String shareType = ShareManager.getTargetTypeByIndex(which);
				shareMessage.setTargetShare(getTargetShare(shareType));
				ShareManager.setTargetShare(shareType);
				if (ShareManager.SYSTEM.equals(shareType)) {
					showSystemShareItems();
				}else {
					forward();
				}

			}
		});
		AlertDialog shareDialog = builder.create();
		shareDialog.show();
	}
	private void showMessage(String message){
		Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
	}
	private void forward() {
		Intent intent = new Intent(context,EditShareActivity.class);
		context.startActivity(intent);
	}
	private void showSystemShareItems() {
		Intent other = new Intent("android.intent.action.SEND");
		other.setType("text/plain");
		other.putExtra("android.intent.extra.SUBJECT",shareMessage.getTitle());
		other.putExtra("android.intent.extra.TEXT",shareMessage.getContent());
		Intent exeOther = Intent.createChooser(other, "请选择：");
		context.startActivity(exeOther);
	}
	
	public void onAuthCallBack(String actionType ,int requestCode, int resultCode, Intent data){
		TargetShare bindTargetShare = getTargetShare(actionType);
		if (bindTargetShare!=null) {
			ShareInterface shareInterface = bindTargetShare.getShareInterface();
			shareInterface.authCallback(requestCode, resultCode, data);
		}
	}
}
