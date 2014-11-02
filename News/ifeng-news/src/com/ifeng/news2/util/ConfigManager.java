package com.ifeng.news2.util;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;
import com.google.myjson.Gson;
import com.google.myjson.JsonObject;
import com.google.myjson.JsonParser;
import com.ifeng.news2.Config;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.bean.SubscriptionBean;
import com.qad.lang.Strings;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;

public class ConfigManager {
	public static void initConfig(Context context){
		initConfigUrl(context);
	}
	private static void initConfigUrl(Context context){
		try {
			String configContent = readConfigFile(context);
			parseConfigFile(configContent);
			String content = readChannelConfigFile(context);
			if(content!=null){
				SubscriptionBean bean = parseChannelConfigFile(content);
				SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(context);
				if(bean!=null){
					if((sp.getBoolean("isUpgrade", false)||isUpdataVersion(bean.getVersion(), Config.SUBSCRIPTIONS.getVersion()))&&Config.SUBSCRIPTIONS!=null){
						bean.setChannels(Config.SUBSCRIPTIONS.getChannels());
						bean.setDefaultChannel(Config.SUBSCRIPTIONS.getDefaultChannel());
						bean.setVersion(Config.SUBSCRIPTIONS.getVersion());
						//去掉无效频道
						for(int i=bean.getDefaultOrderMenuItems().size()-1; i>=0; i--){
							if(Config.SUBSCRIPTIONS.getChannels().get(bean.getDefaultOrderMenuItems().get(i))==null){
								bean.getDefaultOrderMenuItems().remove(i);
							}
						}
						//增加需要固定的频道
						for(int i=Config.SUBSCRIPTIONS.getDefaultChannel().size()-1; i>=0; i--){
							if(bean.getDefaultOrderMenuItems().contains(Config.SUBSCRIPTIONS.getDefaultChannel().get(i))){
								bean.getDefaultOrderMenuItems().add(0, bean.getDefaultOrderMenuItems().remove(bean.getDefaultOrderMenuItems().indexOf(Config.SUBSCRIPTIONS.getDefaultChannel().get(i))));
							}else{
								bean.getDefaultOrderMenuItems().add(0, Config.SUBSCRIPTIONS.getDefaultChannel().get(i));
							}
						}
						saveChannelConfig(context, bean);
						sp.edit().putBoolean("isUpgrade", false).commit();
					}
					Config.SUBSCRIPTIONS = bean;
					Config.CHANNELS = Config.SUBSCRIPTIONS.getchangedChannels();
				}
			}
		} catch (Exception e) {
			Log.e("news", "parse channelConfig.txt error", e);
		}
	}
	
	private static boolean isUpdataVersion(String oldVersion, String newVersion) {
		String[] oldparts = oldVersion.split("\\.");
		String[] newparts = newVersion.split("\\.");
		for(int i=0;i<oldparts.length&&i<newparts.length;i++){
			if(oldparts[i].equals(newparts[i]))continue;
			if(Integer.parseInt(oldparts[i])>Integer.parseInt(newparts[i])){
				return false;
			}else{
				return true;
			}
		}
		return false;
	}
	public static void notifyUpgrade(Context context){
		SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(context);
		sp.edit().putBoolean("isUpgrade", true).commit();
	}
	 
	public synchronized static void saveChannelConfig(final Context context, final SubscriptionBean bean){
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				FileOutputStream outputStream = null;
				try {
					Gson gson = new Gson();
					outputStream = context.openFileOutput(Config.CHANNEL_CONFIG_NAME,
							Context.MODE_PRIVATE);
					outputStream.write(gson.toJson(bean).getBytes());
				} catch (FileNotFoundException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				} finally {
					try {
						if (outputStream != null) {
							outputStream.close();
						}
					} catch (IOException e) {
						e.printStackTrace();
					}

				}
				
			}
		}).start();
	}
	
	public static SubscriptionBean initChannelConfig(Context context) {
		String configContent;
		configContent = readChannelConfigFile(context);
		return parseChannelConfigFile(configContent);
	}
	
	private static String readChannelConfigFile(Context ctxt) {
		FileInputStream fis = null;
		try {
			fis = ctxt.openFileInput(Config.CHANNEL_CONFIG_NAME);  
			int length = fis.available();
			byte[] buffer = new byte[length];
			fis.read(buffer);
			return new String(buffer);
		} catch (Exception e) {
			return null;
		} finally {
			try {
				if (fis != null)
					fis.close();
			} catch (IOException e) {
			}
		}
	}
	
	private static SubscriptionBean parseChannelConfigFile(String json) {
		if(json==null || json.length() == 0)return null;
		SubscriptionBean subscriptionBean = null;
		try {
			subscriptionBean = Parsers.newSubscriptionBeanParser().parse(json);
		} catch (ParseException e) {
			Log.e("news", "parse channelConfig.txt error, in parseChannelConfigFile", e);
		}
		return subscriptionBean;
	}
	
	private static void parseConfigFile(String json) throws Exception{
		if(json==null || json.length() == 0)return;
		JsonParser parser = new JsonParser();
		JsonObject jsonObject = parser.parse(json).getAsJsonObject();
		if(jsonObject==null)return;
		JsonObject Subscriptions = jsonObject.get("subscriptions").getAsJsonObject();
		Config.SUBSCRIPTIONS = parseChannelConfigFile(Subscriptions.toString());
		if(Config.SUBSCRIPTIONS!=null){
		  Config.CHANNELS = Config.SUBSCRIPTIONS.getchangedChannels();
		}
//		if(channelArray!=null){
//			int num = channelArray.size();
//			Channel[] channels = new Channel[num];
//			for (int i = 0; i < num; i++) {
//				JsonObject channel = channelArray.get(i).getAsJsonObject();
//				channels[i] = new Channel(channel.get("channelName").getAsString(),
//						channel.get("channelUrl").getAsString(),
//						channel.get("offlineUrl").getAsString(),
//						channel.get("statistic").getAsString(),
//						channel.get("channelSmallUrl").getAsString(),
//						channel.get("adSite").getAsString());
//			}
//			Config.CHANNELS = channels;//频道
//		}
		String value = getTextByName(jsonObject,"gallery");
		if(!Strings.isEmpty(value)){
			Config.GALLERY_COLUMN_URL = value;//读图
		}
		value = getTextByName(jsonObject,"topic");
		if(!Strings.isEmpty(value)){
			Config.CHANNEL_TOPIC.setChannelUrl(value);//专题
		}
		value = getTextByName(jsonObject,"coverStory");
		if(!Strings.isEmpty(value)){
			Config.COVER_STORY_URL = value;//图片
		}
		value = getTextByName(jsonObject,"upgrade");
		if(!Strings.isEmpty(value)){
			Config.APP_UPGRADE_URL = value;//更新
		}
		value = getTextByName(jsonObject,"statics");
		if(!Strings.isEmpty(value)){
			StatisticUtil.STATISTICS_URL = value;//统计
		}
		value = getTextByName(jsonObject,"errorReport");
		if(!Strings.isEmpty(value)){
			Config.ERROR_REPORT_URL = value;//错误报告
		}
		value = getTextByName(jsonObject,"weatherIp");
		if(!Strings.isEmpty(value)){
			Config.WEATHER_IP_URL = value;//天气ip
		}
		value = getTextByName(jsonObject,"weatherCityByIp");
		if(!Strings.isEmpty(value)){
			Config.WEATHER_CITY_BY_IP_URL = value;//天气城市
		}
		value = getTextByName(jsonObject,"weatherDetailByCity");
		if(!Strings.isEmpty(value)){
			Config.WEATHER_DETAIL_BY_CITY_URL = value;//天气详情
		}
		value = getTextByName(jsonObject,"review");
		if(!Strings.isEmpty(value)){
			Config.CHANNEL_COMMENTARY.setChannelUrl(value);//时评
		}
		value = getTextByName(jsonObject,"commentHot");
		if(!Strings.isEmpty(value)){
			Config.COMMENT_HOT_URL = value;//专题
		}
		value = getTextByName(jsonObject,"realtimeHot");
		if(!Strings.isEmpty(value)){
			Config.REALTIME_HOT_URL = value;//评论热榜
		}
		value = getTextByName(jsonObject,"alawayHot");
		if(!Strings.isEmpty(value)){
			Config.ALAWAY_HOT_URL = value;//实时热榜
		}
		value = getTextByName(jsonObject,"getComment");
		if(!Strings.isEmpty(value)){
			Config.URL_COMMENT = value;//获取评论
		}
		value = getTextByName(jsonObject,"sendComment");
		if(!Strings.isEmpty(value)){
			Config.SEND_COMMENT_URL = value;//写评论
		}
		value = getTextByName(jsonObject,"version");
		if(!Strings.isEmpty(value)){
			Config.CURRENT_CONFIG_VERSION = value;//当前版本
		}
		value = getTextByName(jsonObject,"detail");
		if(!Strings.isEmpty(value)){
			Config.DETAIL_URL = value;//详情页
		}
		value = getTextByName(jsonObject,"alerts");
		if(!Strings.isEmpty(value)){
			Config.CHANNEL_ALERTS.setChannelUrl(value);//凤凰快讯
		}
		value = getTextByName(jsonObject,"downloadURL");
		if(!Strings.isEmpty(value)){
			Config.DETAIL_URLS = value;//批量访问接口
		}
		value = getTextByName(jsonObject,"matchInfoURL");
		if(!Strings.isEmpty(value)){
			Config.MATCH_INFO_URL = value;//体育直播主页面头部数据接口
		}
		value = getTextByName(jsonObject,"sportLiveFactURL");
		if(!Strings.isEmpty(value)){
			Config.SPORT_LIVE_FACT_URL = value;//体育直播主页面实况接口
		}
		value = getTextByName(jsonObject,"sportLiveCommentURL");
		if(!Strings.isEmpty(value)){
			Config.SPORT_LIVE_COMMENT_URL = value;//体育直播主页面评论接口
		}
		value = getTextByName(jsonObject,"dataPageURL");
		if(!Strings.isEmpty(value)){
			Config.DATA_PAGE_URL = value;//体育直播数据页面请求地址
		}
		value = getTextByName(jsonObject,"reportPageURL");
		if(!Strings.isEmpty(value)){
			Config.REPORT_PAGE_URL = value;//体育直播战报页面数据接口
		}
		value = getTextByName(jsonObject,"poisonousURL");
		if(!Strings.isEmpty(value)){
			Config.POISONOUS_URL = value;//体育直播毒舌页面数据接口
		}
		value = getTextByName(jsonObject,"shareURL");
		if(!Strings.isEmpty(value)){
			Config.SHARE_URL = value;//体育直播主页面分享数据接口
		}
		value = getTextByName(jsonObject,"requestURL");
		if(!Strings.isEmpty(value)){
			Config.REQUEST_URL = value;//登录注册接口请求
		}
		value = getTextByName(jsonObject,"speakURL");
		if(!Strings.isEmpty(value)){
			Config.SPEAK_URL = value;//体育直播发言接口
		}
		value = getTextByName(jsonObject,"directSeedingURL");
		if(!Strings.isEmpty(value)){
			Config.DIRECT_SEEDING_URL = value;//图文直播数据请求接口
		}
		value = getTextByName(jsonObject,"pushlistUrl");
		if(!Strings.isEmpty(value)){
			Config.PUSHLIST_URL = value;//推送列表接口
		}
		value = getTextByName(jsonObject, "voteGetUrl");
		if(!Strings.isEmpty(value)){
			Config.VOTE_GET_URL = value;//投票数据接口
		}
		value = getTextByName(jsonObject, "voteResultUrl");
		if(!Strings.isEmpty(value)){
			Config.VOTE_RESULT_URL = value;//投票执行接口
		}
		value = getTextByName(jsonObject, "surveyGetUrl");
        if(!Strings.isEmpty(value)){
            Config.SURVEY_GET_URL = value;//调查获取接口
        }
        value = getTextByName(jsonObject, "surveySendUrl");
        if(!Strings.isEmpty(value)){
            Config.SURVEY_SEND_URL = value;//调查发送接口
        }
        value = getTextByName(jsonObject, "surveyShareDetailUrl");
        if(!Strings.isEmpty(value)){
            Config.SURVEY_SHARE_DETAIL_URL = value;//调查分享详情页接口
        }value = getTextByName(jsonObject, "surveyShareResultUrl");
        if(!Strings.isEmpty(value)){
          Config.SURVEY_SHARE_RESULT_URL = value;//调查分享结果页接口
        }
        
        value = getTextByName(jsonObject, "voteShareUrl");
        if(!Strings.isEmpty(value)){
          Config.VOTE_SHARE_URL = value;//投票分享连接
        }
        value = getTextByName(jsonObject, "videoDetailUrl");
        if(!Strings.isEmpty(value)){
          Config.VIDEO_DETAIL_URL = value;//视频正文页连接
        }
        value = getTextByName(jsonObject, "videoDetailRelativeUrl");
        if(!Strings.isEmpty(value)){
          Config.VIDEO_DETAIL_RELATIVE_URL = value;//视频正文页相关视频连接
        }
		value = getTextByName(jsonObject, "videoDetailShareUrl");
		if(!Strings.isEmpty(value)){
			Config.VIDEO_DETAIL_SHARE_URL = value;//视频正文页分享链接
		}
		
	}
	public static String getTextByName(JsonObject jsonObjet,String name){
		try {
			return jsonObjet.get(name).getAsString();
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	private static String readConfigFile(Context ctxt){
		FileInputStream fis = null;
		try {
			fis = ctxt.openFileInput(Config.PLUGIN_NAME);  
			int length = fis.available();
			byte[] buffer = new byte[length];
			fis.read(buffer);
			return new String(buffer);
		} catch (Exception e) {
			return initDefaultConfig(ctxt);
		} finally {
			try {
				if (fis != null)
					fis.close();
			} catch (IOException e) {
			}
		}
	}
	private static String initDefaultConfig(Context ctxt){
		Log.i("news", "initDefaultConfig");
		InputStream is = null;
		try {
			is = ctxt.getResources().getAssets().open(Config.PLUGIN_NAME);
			int length = is.available();
			byte[] buffer = new byte[length];
			is.read(buffer);
			return new String(buffer);
		} catch (Exception e) {
		} finally {
			try {
				if (is != null)
					is.close();
			} catch (IOException e) {
			}
		}
		return null;
	}
}
