package com.ifeng.news2.util;

import java.util.ArrayList;

import com.ifeng.news2.bean.Extension;

public class ModuleLinksManager {
	/**
	 * 列表挂载extension类型
	 */
	public static final String LINK_DOC_TYPE = "doc";
	public static final String LINK_WEB_TYPE = "web";
	public static final String LINK_OLD_TOPIC_TYPE = "topic";
	public static final String LINK_TOPIC_TYPE = "topic2";
	public static final String LINK_SLIDE_TYPE = "slide";
	public static final String LINK_STYLE_SLIDE_TYPE = "slides";
	public static final String LINK_STORY_TYPE = "story";
	public static final String LINK_LIVE_TYPE = "androidLive";
	public static final String LINK_VIDEO_TYPE = "video";
	public static final String LINK_DAILY_TYPE = "daily";
	public static final String LINK_STYLE_TYPE = "style";
	
	public static final String LIVE_STYLE = "live";
	public static final String PLOT_STYLE = "plot";
	public static final String SLIDE_STYLE = "slides";
	public static final String TOPIC_STYLE = "topic";
	public static final String SURVEY_STYLE = "survey";
	
	public static Extension getTopicLink(ArrayList<Extension> links) {
		if (links == null || links.size()==0)
			return null;
		return links.get(0);
	}
}
