package com.ifeng.news2.util;

import android.content.Intent;

/**
 * 常量管理(ActionName,ExtraName...)
 * @author pjw
 *
 */
public class ConstantManager {
	/**
	 * DetailActivity
	 */
  public final static  String ACTION_FROM_VIDEO = "action.com.ifeng.news2.video";
	public final static String ACTION_FROM_HEAD_IMAGE = "action.com.ifeng.news2.from_head_image";
	public final static String ACTION_ADD_NEXT_PAGE = "action.com.ifeng.news2.add_next_page";
	public final static String ACTION_FROM_APP = "action.com.ifeng.news2.from_app";
	public final static String ACTION_FROM_STORY = "action.com.ifeng.news2.story";
	public final static String ACTION_FROM_ARTICAL = "action.com.ifeng.news2.from_artical"; // 标识从正文页发起的动作，目前用于正文页打开图集时使用
	public final static String ACTION_FROM_SLIDE_URL = "action.com.ifeng.news2.from_slide_url";
	public final static String ACTION_BY_AID = "action.com.ifeng.news2.by_aid";
	public final static String ACTION_FROM_TOPIC2 = "action.com.ifeng.news2.form_topic2";
	public final static String ACTION_PUSH = "action.com.ifeng.news2.push";//推送调用
	public final static String ACTION_WIDGET = "action.com.ifeng.news2.widget";//widget调用
	public final static String ACTION_VIBE = "ifeng.news.action.detail";//硕vibe4 调用
	public final static String ACTION_SPOER_LIVE = "ifeng.news.action.sport_live";//体育直播间
	public final static String ACTION_FROM_COLLECTION = "action.com.ifeng.news2.form_collection";
	public final static String ACTION_FROM_RELATIVE = "action.com.ifeng.news2.form_relative";//相关新闻打开
	public final static String ACTION_FROM_DIRECT_SEEDING = "action.com.ifeng.news2.from_direct_seeding";//从图文直播跳转调用
	public static final String ACTION_FROM_PLOTATLAST = "com.ifeng.news2.action.from_plotatlas" ; //从策划专题中打开
	public static final String ACTION_FROM_SLIDE = "com.ifeng.news2.action.from_slide" ; //从图集中打开
	
	public final static String EXTRA_ADD_OK = "extra.com.ifeng.news2.add_ok";
	public final static String EXTRA_HAS_MORE = "extra.com.ifeng.news2.has_more";
	public final static String EXTRA_SHOW_MSG = "extra.com.ifeng.news2.show_msg";
	public final static String EXTRA_DETAIL_POSITION = "extra.com.ifeng.news2.position";//位置,可选字段。如果没有设置将默认为0
	public final static String EXTRA_DETAIL_IDS = "extra.com.ifeng.news2.ids";//ids,id两者二选一
	public final static String EXTRA_DETAIL_ID = "extra.com.ifeng.news2.id";//ids,id两者二选一
	public final static String EXTRA_DOC_UNITS = "extra.com.ifeng.news2.doc_units";//文章实体列表.可选字段
	public final static String EXTRA_CHANNEL = "extra.com.ifeng.news2.channel";//频道对应的id,可选字段.若没有,则默认为空
	public final static String ACTION_PUSH_LIST = "extra.com.ifeng.news2.pushlist";
	public final static String EXTRA_GALAGERY = "extra.com.ifeng.news2.galagery";//其他标识
	public final static String EXTRA_URL= "extra.com.ifeng.news2.url";
	public final static String THUMBNAIL_URL= "extra.com.ifeng.news2.thumbnail";
	public final static String EXTRA_INTRODUCTION= "extra.com.ifeng.news2.introduction";//文章的描述信息
	public final static String EXTRA_CURRENT_DETAIL_DOCUMENTID = "extra.com.ifeng.news2.current_doc_id";//当前文章的id
	
	public static final String ACTION_FROM_VIDEO_ARTICAL = "com.ifeng.news2.action.from_video_artical" ; //从视频正文页中打开
	public static boolean isPlayed = false;//是否播放过测试视频
	public static boolean isSupportHdPlay = true;//是否支持高清播放
	public final static String IS_SUPPORT_HD_PLAY_KEY = "isSupportHdKey";//是否支持高清播放的Key
	public final static String IS_PLAYED_KEY = "isPlayedKey";//是否播放过测试视频的Key
	//视频列表进入正文页所用id
	public final static String EXTRA_VIDEO_DETAIL_ID = "extra.com.ifeng.news2.video.id";
	public final static String EXTRA_VIDEO_DETAIL_TITLE = "extra.com.ifeng.news2.video.title";
	public final static String EXTRA_VIDEO_DETAIL_ID_LAST = "extra.com.ifeng.news2.video.id.last";
	
	public final static int IN_FROM_APP = 1;
	public final static int IN_FROM_PUSH = 2;
	public final static int IN_FROM_OUTSIDE = 4;
	public final static int IN_FROM_WIDGET = 5;
	
	public static boolean isSettingsShow = false;//设置页显示
	
	
	
	
	/**
	 * 是否从外部启动应用的判断
	 */
	public static boolean isOutOfAppAction(String action){
		if(action!=null){
			return action.equals(ACTION_PUSH)||action.equals(Intent.ACTION_VIEW)||action.equals(ACTION_WIDGET);
		}
		return false;
	}
	
	
	/**
	 * 是否是完整链接，返回true为完整http链接。 返回false则为documentId，需要与url进行拼接
	 * @return
	 */
	public static boolean isIntactUrl(String action){
		if(action!=null){
			return !ACTION_FROM_APP.equals(action)&&
					!ACTION_FROM_SLIDE_URL.equals(action)&& 
					!ACTION_PUSH_LIST.equals(action)&&
					!Intent.ACTION_VIEW.equals(action)&&
					!ACTION_WIDGET.equals(action)&&
					!ACTION_FROM_RELATIVE.equals(action);
		}
		return false;
	}
}
