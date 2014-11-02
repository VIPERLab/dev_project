package com.ifeng.news2.util;

import com.ifeng.news2.R.string;

import com.ifeng.news2.vote.VoteActivity;
import com.ifeng.news2.widget.ChannelList;

import com.ifeng.news2.activity.SurveyActivity;

import com.ifeng.news2.adapter.SurveyAdapter;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import com.ifeng.news2.Config;
import com.ifeng.news2.R;
import com.ifeng.news2.activity.DetailActivity;
import com.ifeng.news2.activity.PhotoAndTextLiveActivity;
import com.ifeng.news2.activity.PlayVideoActivity;
import com.ifeng.news2.activity.PlotTopicModuleActivity;
import com.ifeng.news2.activity.SlideActivity;
import com.ifeng.news2.activity.SplashActivity;
import com.ifeng.news2.activity.TopicDetailModuleActivity;
import com.ifeng.news2.activity.TopicListActivity;
import com.ifeng.news2.advertise.AdDetailActivity;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.fragment.NewsMasterFragmentActivity;
import com.ifeng.news2.sport_live.SportMainActivity;
import com.ifeng.share.util.NetworkState;
import com.qad.util.WToast;

public class IntentUtil {

	
	public static final int TYPE_DOC = 0x0010;
	public static final int TYPE_WEB = 0x0020;
	public static final int TYPE_TOPIC = 0x0030;
	public static final int TYPE_SLIDE = 0x0040;
	public static final int TYPE_STORY = 0x0050;
	public static final int TYPE_VIDEO = 0x0060;
	public static final int TYPE_ANDROID_LIVE = 0x0070;
	public static final int TYPE_LINKS_TOPIC = 0x0080;
	public static final int TYPE_PLOT = 0x00110;
	public static final int TYPE_VOTE = 0x00120;
	public static final int TYPE_SURVEY = 0x00130;
	public static final int TYPE_DIRECT_PLAY = 0x0140;
	private static final int TYPE_DIRECT_SEEDING = 0x0101; 
	public static final int TYPE_ERROR = -0x001;
	
	/**
	 * 2013/06/07
	 * 体育直播间，一起全屏幕WEB页面
	 * 用AdDetailActivity.class 打开
	 */
	public static final int TYPE_WEB2 = 0x0021;
	
	public static final int FLAG_REDIRECT_BACK = 0x100;
	public static final int FLAG_REDIRECT_HOME = 0x200;
	public static final int FLAG_FROM_HEADIMAGE = 0x300;
	public static final int FLAG_FROM_JSON_TOPIC = 0x0400;
	
	public static final String EXTRA_REDIRECT_HOME = "extra.com.ifeng.news2.redirect_home";	
	

	public static int getTypeByString(String type) {
		if ("doc".equals(type))
			return TYPE_DOC;
		if ("web".equals(type))
			return TYPE_WEB;
		if ("web_live".equals(type))
			return TYPE_WEB2;
		if ("topic".equals(type))
			return TYPE_TOPIC;
		if ("topic2".equals(type))
			return TYPE_LINKS_TOPIC;
		if ("slide".equals(type))
			return TYPE_SLIDE;
		if ("story".equals(type))
			return TYPE_STORY;
		if ("video".equals(type))
			return TYPE_VIDEO;
		if ("direct_play".equals(type))
          return TYPE_DIRECT_PLAY;
		if ("androidLive".equals(type))
          return TYPE_ANDROID_LIVE;
		if ("vote".equals(type))
          return TYPE_VOTE;
		if ("survey".equals(type))
          return TYPE_SURVEY;
		
		if ("plot".equals(type))
            return TYPE_PLOT;
		if("directSeeding".equals(type)){
			return TYPE_DIRECT_SEEDING;
		}
		return TYPE_ERROR;
	}
	
	public static boolean startActivityByExtension(Context context,
			Extension extension) {
		return startActivityByExtension(context, extension, FLAG_REDIRECT_BACK,null);
	}

	public static boolean startActivityByExtension(Context context,
			Extension extension,Channel channel) {
		return startActivityByExtension(context, extension, FLAG_REDIRECT_BACK,channel);
	}

	public static boolean startActivityWithPos(Context context,
			Extension extension, int position) {
		return startActivityByExtension(context, extension, FLAG_FROM_JSON_TOPIC,
				position,null);
	}

	public static boolean startActivityByExtension(Context context,
			Extension extension, int flag,Channel channel) {
		return startActivityByExtension(context, extension, flag, 0,channel);
	}
	
	public static boolean startActivityByExtension(Context context,
			Extension extension, int flag) {
		return startActivityByExtension(context, extension, flag, 0,null);
	}

	

	/**
	 * 
	 * @param context
	 *            Context to startActivity
	 * @param extension
	 *            Extension containing type and documentId/url
	 * @param flag
	 *            One of the FLAG_REDIRECT_* flag
	 * @return
	 */
	public static boolean startActivityByExtension(final Context context,
			Extension extension, int flag, int position, Channel channel) {
		final Intent intent = queryIntent(context, extension, flag, position, channel);
		if(intent == null) return false;
		
		if (context.getPackageManager().queryIntentActivities(intent, 0).size() != 0)
			try {
			  if(ConstantManager.ACTION_FROM_VIDEO.equals(intent.getAction())){
			    if (NetworkState.isActiveNetworkConnected(context)
                    && !NetworkState.isWifiNetworkConnected(context)) {

                  AlertDialog.Builder alertBuilder = new AlertDialog.Builder(context);
                  AlertDialog alertPlayIn2G3GNet =
                      alertBuilder
                          .setCancelable(true)
                          .setMessage(
                              context.getResources().getString(R.string.video_dialog_play_or_not))
                          .setPositiveButton(
                            context.getResources().getString(R.string.video_dialog_positive),
                              new android.content.DialogInterface.OnClickListener() {

                                @Override
                                public void onClick(DialogInterface dialog, int which) {

                                  context.startActivity(intent);
                                  ((Activity) context).overridePendingTransition(
                                          R.anim.in_from_right, R.anim.out_to_left);

                                }
                              })
                          .setNegativeButton(
                            context.getResources().getString(R.string.video_dialog_negative),
                              new android.content.DialogInterface.OnClickListener() {

                                @Override
                                public void onClick(DialogInterface dialog, int which) {

                                }
                              }).create();
                  alertPlayIn2G3GNet.show();

                } else {
                  if (!NetworkState.isActiveNetworkConnected(context)) {
                	  WindowPrompt.getInstance(context).showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
                  }else{
                    context.startActivity(intent);
                    ((Activity) context).overridePendingTransition(
                      R.anim.in_from_right, R.anim.out_to_left);
                  }
                 
                }
		       }else{
		         context.startActivity(intent);
	                ((Activity) context).overridePendingTransition(
	                        R.anim.in_from_right, R.anim.out_to_left);
		       }
				
				return true;
			} catch (Exception e) {
				Log.i("news",
						"!!!!!!!!!!!!!!!!!!!!startActivity " + e.getMessage());
				e.printStackTrace();
				return false;
			}
		else
			return false;
	}

	public static Intent queryIntent(Context context, Extension extension,
			int flag, int position, Channel channel) {
		Intent intent = new Intent();
		if (flag != FLAG_REDIRECT_HOME) {
			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		}
		intent.putExtra(EXTRA_REDIRECT_HOME, flag == FLAG_REDIRECT_HOME);
		//将列表缩略图URL传到相应界面，用于收藏保存缩略图URL
		intent.putExtra(ConstantManager.THUMBNAIL_URL, extension.getThumbnail());
		//将列表描述信息传导相应界面，用于分享
		intent.putExtra(ConstantManager.EXTRA_INTRODUCTION, extension.getIntroduction());
		switch (getTypeByString(extension.getType())) {
		case TYPE_DOC:			
			String id = null;
			if (!TextUtils.isEmpty(extension.getDocumentId()))
				id = String.format(Config.DETAIL_URL,
						extension.getDocumentId());
			else
				id = extension.getUrl();
			if(flag==FLAG_FROM_HEADIMAGE){
				intent.setAction(ConstantManager.ACTION_FROM_HEAD_IMAGE);
			}
			else if(flag==FLAG_FROM_JSON_TOPIC){
				intent.setAction(ConstantManager.ACTION_FROM_TOPIC2);				
			}
			else {
				intent.setAction(ConstantManager.ACTION_BY_AID);
			}
			intent.setClass(context, DetailActivity.class);
			intent.putExtra(ConstantManager.EXTRA_DETAIL_ID, id);
			intent.putExtra(ConstantManager.EXTRA_CHANNEL, Channel.NULL);
			intent.putExtra(ConstantManager.EXTRA_GALAGERY, extension.getCategory());
			break;
		case TYPE_WEB:
			intent.setClass(context, AdDetailActivity.class);
			intent.setAction(ConstantManager.ACTION_FROM_APP);
			intent.putExtra("URL", extension.getUrl());
			if(flag==FLAG_FROM_JSON_TOPIC){ // 用于统计入口，这里是从专题进入
				intent.setAction(ConstantManager.ACTION_FROM_TOPIC2);	
				intent.putExtra(ConstantManager.EXTRA_GALAGERY, extension.getCategory());
			}
			if(channel != null){
				intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
			}
			break;
		case TYPE_WEB2:
			intent.setClass(context, SportMainActivity.class);
			intent.putExtra("MATCH_ID", Uri.parse(extension.getUrl()).getQueryParameter("mt"));
			if(flag==FLAG_FROM_JSON_TOPIC){ // 用于统计入口，这里是从专题进入
				intent.setAction(ConstantManager.ACTION_FROM_TOPIC2);	
				intent.putExtra(ConstantManager.EXTRA_GALAGERY, extension.getCategory());
			}
			if (flag==FLAG_REDIRECT_HOME) {
			  intent.setAction(ConstantManager.ACTION_FROM_STORY); 
            }
			if(channel != null){
				intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
			}
			//intent.setAction("FULL_SCREEN");
			break;
		case TYPE_VOTE: 
			intent.setClass(context, VoteActivity.class);
			//TODO  未设置action 如若加统计请定义action
			intent.putExtra("id", extension.getUrl());
			break;
		case TYPE_SURVEY: 
		    intent.setClass(context, SurveyActivity.class);
		    //TODO  未设置action 如若加统计请定义action
            intent.putExtra("id", extension.getUrl());
            break;
		case TYPE_LINKS_TOPIC: // topic2 JSON专题
			intent.setClass(context, TopicDetailModuleActivity.class);
			intent.setAction(TopicDetailModuleActivity.ACTION_VIEW);
			intent.putExtra("ORIGIN", extension.getOrigin());
			intent.putExtra("id", extension.getUrl());
			if(flag==FLAG_FROM_JSON_TOPIC){ // 用于统计入口，这里是从专题进入
				intent.setAction(ConstantManager.ACTION_FROM_TOPIC2);	
				intent.putExtra(ConstantManager.EXTRA_GALAGERY, extension.getCategory());
			}
			if(channel != null){
				intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
			}
			break;
		case TYPE_PLOT: // 策划专题
          intent.setClass(context, PlotTopicModuleActivity.class);
          intent.putExtra("ORIGIN", extension.getOrigin());
          intent.putExtra("id", extension.getUrl());
          if(flag==FLAG_FROM_JSON_TOPIC){ // 用于统计入口，这里是从专题进入
				intent.setAction(ConstantManager.ACTION_FROM_TOPIC2);	
				intent.putExtra(ConstantManager.EXTRA_GALAGERY, extension.getCategory());
			}
			if(channel != null){
				intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
			}
          break;
		case TYPE_SLIDE:
			intent.setClass(context, SlideActivity.class);
			if(flag==FLAG_FROM_HEADIMAGE){
				intent.setAction(ConstantManager.ACTION_FROM_HEAD_IMAGE);
			}else{
				intent.setAction(SlideActivity.ACTION_FROM_WEBVIEW);
			}			
			intent.putExtra(SlideActivity.EXTRA_URL, extension.getUrl());
			intent.putExtra(SlideActivity.EXTRA_POSITION, position);
			intent.putExtra(ConstantManager.EXTRA_GALAGERY, extension.getCategory());			
			if(channel != null){
				intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
			}
			break;
		case TYPE_VIDEO:
		case TYPE_DIRECT_PLAY:
		case TYPE_ANDROID_LIVE:
			if (extension.getDocumentId() == null)
				extension.setDocumentId("");
			intent.setAction(ConstantManager.ACTION_FROM_VIDEO);
			intent.setClass(context, PlayVideoActivity.class);
			Bundle bundle = new Bundle();
			String url = extension.getUrl();
			if (!TextUtils.isEmpty(url)) {
                url = url.split("##")[0];
            }
			bundle.putString("video_path", url);
			bundle.putString("id", extension.getDocumentId());
			intent.putExtras(bundle);
			break;
		case TYPE_DIRECT_SEEDING:
			intent.setClass(context, PhotoAndTextLiveActivity.class);
			intent.putExtra(PhotoAndTextLiveActivity.INTENT_TYPE,
					extension.getUrl());
			if(flag==FLAG_FROM_JSON_TOPIC){ // 用于统计入口，这里是从专题进入
				intent.setAction(ConstantManager.ACTION_FROM_TOPIC2);	
				intent.putExtra(ConstantManager.EXTRA_GALAGERY, extension.getCategory());
			}
			if (flag==FLAG_REDIRECT_HOME) {
              intent.setAction(ConstantManager.ACTION_FROM_STORY); 
            }
			if(channel != null){
				intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
			}
			break;
		default:
			return null;
		}
		return intent;
	}

	public static void redirectHome(Context context) {
			Intent intent = new Intent();
			intent.setClass(context, NewsMasterFragmentActivity.class);
//			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			SplashActivity.isSplashActivityCalled = true;
			context.startActivity(intent);
		}
	}

	
