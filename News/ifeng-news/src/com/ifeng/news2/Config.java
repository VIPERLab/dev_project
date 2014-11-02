package com.ifeng.news2;

import android.os.Environment;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.SubscriptionBean;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

public abstract class Config {
	public static boolean isDEGUG = false;
	public static boolean enablePush = true;
	
	public static int SCREEN_WIDTH = 480;
	public static final float LIST_THUMBNAIL_RATIO = 1.4F;
	public static final float LIST_THUMBNAIL_SCREEN_RATIO = 4.2857F;

	//	public static boolean isPlayTest = true;
	public static String PUBLISH_ID = "test";
	public static boolean SPECIAL_USERKEY = false;
	public static boolean isSupportHdPlay = true;//是否支持高清播放
	public static boolean ENABLE_ADVER = true;
	public static boolean isUpgrader = true;
	public static boolean IMOCHA_AD = true;
	public static boolean ADD_UMENG_STAT = false;// 是否添加友盟统计
	public static long PULL_TO_REFRESH_EXPIRED_TIME = 10L * 1000;//用户下拉刷新缓存过期时间
	public static long START_INTERVAL_TIME = 60L * 1000 * 30;
	public static long START_OFFINE_TIME = 10L * 1000;
	public static long EXPIRED_TIME = 60L * 1000 * 10;
	public static long DETAIL_STAY_TIME = 1000 * 3;// 阅读页停留时间
	public static final long AUTO_PULL_TIME = 100;
	public static final long FAKE_PULL_TIME = 500;
	public static final long WELCOME_FORWARD_TIME = 3000;
	public static final long FIRST_COVER_TIME = 1500;
	public static final long BACKGROUND_TIME = 1000 * 60 * 60 * 4;
	public static boolean ENALBE_PREFETCH = true;
	public static boolean FORCE_2G_MODE = false;
	public static boolean FULL_EXIT = true; // 退出时需要杀掉进程完全退出，以便刷新策略能够正常
	public static final int SEND_COMMENT_WORDS_LIMIT = 300;// 评论数字上限
	// 分享内容的最大字数限制
	public static final int SHARE_MAX_LENGTH = 20;
	public static ArrayList<Long> SEND_COMMENT_TIMES = new ArrayList<Long>();
	// @lxl,
	public static boolean IS_FINSIH_PULL_SKIP = false;
	public static final ArrayList<Channel> PREFETCHED_CHANNELS = new ArrayList<Channel>();
	public static final File FOLDER_DATA = new File(
			Environment.getExternalStorageDirectory(), "ifeng/news");
	public static final File APP_CACHE = new File(
			"/data/data/com.ifeng.news2/cache");
	public static final File FOLDER_CACHE = new File(FOLDER_DATA, "cache_temp");
	public static final File FOLDER_DOWNLOAD = new File(FOLDER_DATA, "download");
	public static final File FILE_ATMO_ZIP = new File(FOLDER_DOWNLOAD,
			"atmo.zip");
	public static final File FILE_READ_RECORD = new File(FOLDER_DATA,
			"read.dat");
	public static final String FOLDER_COLLECTION = FOLDER_DATA
			.getAbsolutePath();
	public static final String COLLECTION_DAT_NAME = "collection.dat";
	public static final File FOLDER_DATA_DOWNLOAD_PICTURE = new File(
			Environment.getExternalStoragePublicDirectory(
		            Environment.DIRECTORY_PICTURES), "ifeng");
	public static final String FOLDER_DOWNLOAD_PICTURE = FOLDER_DATA_DOWNLOAD_PICTURE
			.getAbsolutePath() + "/download_pic/";
	public final static String CITYS_DB_NAME = "citylist.db";
	public final static String CITYS_DB_PATH = "/data/data/com.ifeng.news2/files/"
			+ CITYS_DB_NAME;// 城市数据库路径
	public final static String PLUGIN_NAME = "config.txt";
	public final static String CHANNEL_CONFIG_NAME = "ChannelConfig.txt";
	//两会频道开关请求接口
	public static String NPCAndCPPCC_SWITCH_URL = "http://api.3g.ifeng.com/ChannelSwitch";
	
	//两会频道开关
	public static boolean isCheckNPCAndCPPCC = true;
	// 正文文字链广告信息
	public static String TEXT_AD_DATA01 = "";
	public static String TEXT_AD_ID01 = "";
	
	// 新增正文文字链广告信
	public static String TEXT_AD_DATA02 = "";
	public static String TEXT_AD_ID02 = "";
	
	//正文页底部banner广告id
	public static String BANNER_ADID = "";
	public static String BANNER_DATA = "";
	public final static String TARGET_PLUGIN_ZIP = new File(
			Environment.getExternalStorageDirectory(),
			"ifeng/download/atmo.zip").getAbsolutePath();

	public static Channel findChannelByPrefixUrl(String wifiUrl) {
		if (wifiUrl == null)
			return null;
		for (Channel channel : CHANNELS) {
			if (wifiUrl.startsWith(channel.getChannelUrl()))
				return channel;
		}
		return null;
	}

	public static Channel findChannelByMetaId(String metaId) {
		if (metaId == null)
			return null;
		for (Channel channel : CHANNELS) {
			if (metaId.startsWith(channel.getChannelUrl())
					|| metaId.startsWith(channel.getChannelSmallUrl()))
				return channel;
		}
		return null;
	}

	public static String getCurrentTimeString() {
		SimpleDateFormat df = new SimpleDateFormat("HH:mm");
		return df.format(new Date());
	}

	/**
	 * from config.txt
	 */
	public static String SUPPORT_COMMENT = "http://icomment.ifeng.com/vote.php";
	public static String CURRENT_CONFIG_VERSION = "4.1.3";
	public static String GALLERY_COLUMN_URL = "http://cdn.iclient.ifeng.com/res/app/iclient/iclient_slides.shtml";
	public static String COVER_STORY_URL = "http://api.iapps.ifeng.com/news/coverstory.json";
	public static String APP_UPGRADE_URL = "http://api.iapps.ifeng.com/news/upgrade.json";
	public static String ERROR_REPORT_URL = "http://report.apps.ifeng.com:1288/?name=ifeng_client_news_android_log&opt=put&auth=ifeng3g8";
	public static String WEATHER_IP_URL = "http://api.3g.ifeng.com/weather_getip";// 获取ip链接
	public static String WEATHER_CITY_BY_IP_URL = "http://ipservice.3g.ifeng.com/wry?ip=";// 获取城市名称
	public static String WEATHER_DETAIL_BY_CITY_URL = "http://api.3g.ifeng.com/phoneweather?icon=small&city="; // 获取城市天气信息
	public static String COMMENT_HOT_URL = "http://api.3g.ifeng.com/iosNews?id=aid=PV173&imgwidth=100&type=list";
	public static String REALTIME_HOT_URL = "http://api.3g.ifeng.com/iosNews?id=aid=PP153&imgwidth=100&type=list";
	public static String ALAWAY_HOT_URL = "http://api.3g.ifeng.com/iosNews?id=aid=PP183&imgwidth=100&type=list";
	public static String SEND_COMMENT_URL = "http://icomment.ifeng.com/wappost.php";
	public static String DETAIL_URL = "http://api.3g.ifeng.com/ipadtestdoc?imgwidth=100&aid=%s&channel=&chid=&android=1";
	public static String DETAIL_URLS = "http://api.3g.ifeng.com/newsdocs?imgwidth=300&aid=%s&channel=push&chid=&vt=2&piece=3&android=1";
	public static String AD_URL = "http://api.3g.ifeng.com/ClientApi?adids=1058&type=json";
	public static String OLYMPIC_URL = "http://api.3g.ifeng.com/aybigpic";
	public static String TOPIC_URL = "http://api.3g.ifeng.com/%s?json=y";
	public static String PUSHLIST_URL = "http://api.3g.ifeng.com/iosNews?id=PUSH&type=list&aid=%s";
	//调查获取接口
	public static String SURVEY_GET_URL = "http://survey.ifeng.com/api/showmobilesurvey.php?format=json&surveyId=";
	//调查发送接口
	public static String SURVEY_SEND_URL = "http://survey.ifeng.com/api/pollmobilesurvey.php?format=json&surveyId=";
	//调查分享结果页接口
	public static String SURVEY_SHARE_RESULT_URL = "http://i.ifeng.com/survey_result?sharefrom=ifengnews&surveyId=";
	//调查分享详情页接口
	public static String SURVEY_SHARE_DETAIL_URL = "http://i.ifeng.com/surveyDetail?sharefrom=ifengnews&surveyId=";
	
	//体育直播直播页数据接口
	public static String SPORT_LIVE_FACT_URL = "http://api.3g.ifeng.com/clientLive_live?count=20";
	//体育直播聊天页数据接口
	public static String SPORT_LIVE_COMMENT_URL = "http://api.3g.ifeng.com/clientLive_chat?count=20";
	//体育直播数据页请求地址
	public static  String DATA_PAGE_URL = "http://api.3g.ifeng.com/clientLive_data";
	//体育直播战报数据接口
	public static  String REPORT_PAGE_URL = "http://i.ifeng.com/clientLive_live?requestType=match_report";
	//体育直播毒舌数据接口
	public static  String POISONOUS_URL = "http://api.3g.ifeng.com/clientLive_live?requestType=dushe";
	//体育直播主页面头部数据接口
	public static String MATCH_INFO_URL = "http://api.3g.ifeng.com/clientLive_live?requestType=match_info";
	//体育直播分享地址
	public static String SHARE_URL = "http://i.ifeng.com/newLivePage.h";	
	//登录注册接口请求
	public static  String REQUEST_URL = "http://uibi.ifeng.com/uibi/gate.jsp";
	//体育直播发言接口
	public static  String SPEAK_URL = "http://i.ifeng.com/clientLive_chat?requestType=chat_send";
	
	//图文直播获取内容接口
	public static String DIRECT_SEEDING_URL = "http://ichat.3g.ifeng.com/interface/";
	//cmpp图片处理接口
	public static String IMAGE_CUT_URL = "http://d.ifengimg.com";
	
	public static String URL_COMMENT = "http://icomment.ifeng.com/geti.php";
	
	//获取投票内容接口
	public static String VOTE_GET_URL = "http://survey.ifeng.com/api/showmobilevote.php?format=json&voteId=%s";

	//投票执行接口
	public static String VOTE_RESULT_URL = "http://survey.ifeng.com/api/pollmobilevote.php?format=json&voteId=%s&itemId=%s";
	
	//投票分享地址url
	// 更改了投票分享的url 
	//public static String VOTE_SHARE_URL = "http://i.ifeng.com/vote_result?sharefrom=ifengnews&voteId=%s";
	public static String VOTE_SHARE_URL = "http://i.ifeng.com/voteDetail?sharefrom=ifengnews&surveyId=%s";
	public static String VOTE_SHARE_RESULT = "http://i.ifeng.com/vote_result?sharefrom=ifengnews&surveyId=%s";
	
	//视频正文接口
	public static String VIDEO_DETAIL_URL = "http://v.ifeng.com/appData/video/singleVideo/%s/%s.js";
	
	//视频正文页推荐视频接口
	public static String VIDEO_DETAIL_RELATIVE_URL ="http://v.ifeng.com/appData/video/relativeVideoList/%s/%s.js";
	
	//视频正文页分享url
	public static String VIDEO_DETAIL_SHARE_URL = "http://i.ifeng.com/sharenews.f?guid=%s";
	
	public static Channel CHANNEL_COMMENTARY = new Channel(
			"时评",
			"http://api.3g.ifeng.com/iosNews?id=aid=SP163&imgwidth=100&type=list",
			null, "commentary", null);
	public static Channel CHANNEL_ALERTS = new Channel(
			"凤凰快讯",
			"http://api.3g.ifeng.com/pushlist?productid=ifengnews&channelid=all",
			null, "pushlist", null);
	public static Channel CHANNEL_ISSUE = new Channel("热榜", null, null,
			"issue", null);
	public static Channel CHANNEL_TOPIC = new Channel("专题",
			"http://api.3g.ifeng.com/androidtopicwifi?id=TOPIC&type=imcpchip",
			null, "topic", null);
	public static SubscriptionBean SUBSCRIPTIONS;

	public static Channel[] CHANNELS = {
			new Channel(
					"頭條",
					"http://api.3g.ifeng.com/iosNews?id=aid=SYLB10,SYDT10&imgwidth=480,100&type=list,list&pagesize=20,20",
					"http://appzip.3g.ifeng.com/appstore/17706e505051a1c60f0ec2618e9f0861.zip",
					"sy",
					"http://api.3g.ifeng.com/iosNews?id=aid=SYLB10,SYDT10&imgwidth=480,100&type=list,list&pagesize=20,20",
					"10000003"),
			new Channel(
					"娛樂",
					"http://api.3g.ifeng.com/iosNews?id=aid=YL53,FOCUSYL53&imgwidth=300&type=list&pagesize=20",
					"http://appzip.3g.ifeng.com/appstore/3de17f6fb9f9f61e022de2b4f84d74c0.zip",
					"ent",
					"http://api.3g.ifeng.com/iosNews?id=aid=YL53,FOCUSYL53&imgwidth=300&type=list&pagesize=20",
					"10000023"),
			new Channel(
					"體育",
					"http://api.3g.ifeng.com/iosNews?id=aid=TY43,FOCUSTY43&imgwidth=300&type=list&pagesize=20",
					"http://appzip.3g.ifeng.com/appstore/0bb9bc2b0083e601141eeb41e88ee323.zip",
					"sports",
					"http://api.3g.ifeng.com/iosNews?id=aid=TY43,FOCUSTY43&imgwidth=300&type=list&pagesize=20",
                    "10000025"),
			new Channel("圖片", GALLERY_COLUMN_URL, "null", "photo", "null", null),
			new Channel(
					"財經",
					"http://api.3g.ifeng.com/iosNews?id=aid=CJ33,FOCUSCJ33&imgwidth=100&type=list&pagesize=20",
					"http://appzip.3g.ifeng.com/appstore/a4d0d4791647607b054d21278e813b51.zip",
					"finance",
					"http://api.3g.ifeng.com/iosNews?id=aid=CJ33,FOCUSCJ33&imgwidth=100&type=list&pagesize=20",
					"10000031"),
			new Channel(
					"科技",
					"http://api.3g.ifeng.com/iosNews?id=aid=KJ123,FOCUSKJ123&imgwidth=300&type=list&pagesize=20",
					"http://appzip.3g.ifeng.com/appstore/469e50ed66436feb6a7e4483ee9a4834.zip",
					"tech",
					"http://api.3g.ifeng.com/iosNews?id=aid=KJ123,FOCUSKJ123&imgwidth=300&type=list&pagesize=20",
                    "10000024"),
			new Channel(
					"軍事",
					"http://api.3g.ifeng.com/iosNews?id=aid=JS83,FOCUSJS83&imgwidth=100&type=list&pagesize=20",
					"http://appzip.3g.ifeng.com/appstore/c00115c9352f41b340fb787911c763d8.zip",
					"mil",
					"http://api.3g.ifeng.com/iosNews?id=aid=JS83,FOCUSJS83&imgwidth=100&type=list&pagesize=20",
					"10000033"),
			new Channel(
					"歴史",
					"http://api.3g.ifeng.com/iosNews?id=aid=LS153,FOCUSLS153&imgwidth=100&type=list&pagesize=20",
					"http://appzip.3g.ifeng.com/appstore/c00115c9352f41b340fb787911c763d8.zip",
					"history",
					"http://api.3g.ifeng.com/iosNews?id=aid=LS153,FOCUSLS153&imgwidth=100&type=list&pagesize=20",
					"10000032"),
			new Channel(
					"時事",
					"http://api.3g.ifeng.com/iosNews?id=aid=XW23&imgwidth=300&type=list&pagesize=20",
					"http://appzip.3g.ifeng.com/appstore/87cf76cada375b3551caac2fac3432da.zip",
					"events",
					"http://api.3g.ifeng.com/iosNews?id=aid=XW23&imgwidth=300&type=list&pagesize=20",
					null),
			new Channel(
					"社會",
					"http://api.3g.ifeng.com/iosNews?id=aid=SH133&imgwidth=300&type=list&pagesize=20",
					"http://appzip.3g.ifeng.com/appstore/82262a6b5faf4c38aeb2f208f8d61a5c.zip",
					"society",
					"http://api.3g.ifeng.com/iosNews?id=aid=SH133&imgwidth=300&type=list&pagesize=20",
					null),
			new Channel(
					"台灣",
					"http://api.3g.ifeng.com/iosNews?id=aid=TW73&imgwidth=300&type=list&pagesize=20",
					"http://appzip.3g.ifeng.com/appstore/56978e3ab2aa7c2bbdc0a96ab6b567ae.zip",
					"tw",
					"http://api.3g.ifeng.com/iosNews?id=aid=TW73&imgwidth=300&type=list&pagesize=20",
					null),
			new Channel(
					"獨家",
					"http://api.3g.ifeng.com/channel_list_android?id=origin",
					null,
					"exclusive",
					"http://api.3g.ifeng.com/channel_list_android?id=origin",
					null) };

	
	// WX_APP_ID 替换为你的应用从微信官方网站申请到的合法appId
	public static final String WX_APP_ID = "wx8b2030599240f886";
	// YX_APP_ID 替换为你的应用从易信官方网站申请到的合法appId
	public static final String YX_APP_ID = "yx98ab50593d2248608933deb577f7e5da";

}
