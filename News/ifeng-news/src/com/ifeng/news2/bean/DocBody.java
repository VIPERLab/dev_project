package com.ifeng.news2.bean;

import java.io.File;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import com.google.myjson.Gson;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.FunctionActivity.FontSize;
import com.ifeng.news2.util.PhotoModeUtil;
import com.ifeng.news2.util.PhotoModeUtil.PhotoMode;

public class DocBody implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 2971754670203422875L;
	private String text = "";
	private String title = "";
	private String editTime = "";
	private String source = "";
	//先发后审
	private String commentsExt="";
	private String wwwurl = "";
	private String wapurl = "";
	private String shareurl = "";
	//add for comment
	private String commentsUrl="";
	//顶部banner图
	private TopBanner btl;



	private String videoPoster;
	private String videoSrc;
	//@lxl，add for comment
	private String commentType;
	private String introduction;
	// @lxl, add for collection list thumbnail
	private String thumbnail;
	private String hasVideo;
	private String fontSize;
	private String documentId="";
	//img数据的json，转换成js方便解析的格式
	private String imgJson = "";
	//video数据的json
	private String videoJson = "";
	//slide数据的json
	private String extSlidesJson = "";
	
	//视频直播
	private LiveStream liveStream;
	private String liveStreamJson = "";
	
	private String[] survey; 
	
	private String[] vote;
	
	private String articleWidth;
	
	public String getArticleWidth() {
		return articleWidth;
	}

	public void setArticleWidth(String articleWidth) {
		this.articleWidth = articleWidth;
	}

	public TopBanner getBtl() {
		return btl;
	}

	public void setBtl(TopBanner btl) {
		this.btl = btl;
	}
	
	/**
	 * @return the liveStream
	 */
	public LiveStream getLiveStream() {
		return liveStream;
	}

	/**
	 * @param liveStream the liveStream to set
	 */
	public void setLiveStream(LiveStream liveStream) {
		this.liveStream = liveStream;
	}

	public String getLiveStreamJson() {
		return liveStreamJson;
	}
	
	public DocBody setLiveStreamJson() {
		try {
			if (null != liveStream) {
				liveStreamJson = new Gson().toJson(liveStream);
			}
		} catch (Exception e) {
			Log.w("Sdebug", "Exception occurs in setLiveStreamJson", e);
			liveStreamJson = "";
		}
		return this;
	}
	
	public String getVideoJson() {
		return videoJson;
	}

	public DocBody setVideoJson() {
		try {
			if(videos!=null && videos.size()>0){
				Gson gson=new Gson();
				this.videoJson =  gson.toJson(videos);
			}
		} catch (Exception e) {
			this.videoJson = "";
		}
		return this;
	}

	public String getExtSlidesJson() {
		return extSlidesJson;
	}

	public DocBody setExtSlidesJson() {
		try {
			if(extSlides!=null && extSlides.size()>0){
				Gson gson=new Gson();
				this.extSlidesJson = gson.toJson(extSlides);
			}			
		} catch (Exception e) {
			this.extSlidesJson = "";
		}
		return this;
	}

	public DocBody setImgJson() {		
		try {
			if(img != null && img.size() > 0) {
				Gson gson = new Gson();
				Map<String, DocSize> map = new HashMap<String, DocSize>();
				for(DocImage docImage: img) {
					map.put(docImage.getUrl(), docImage.getSize());
				}
				this.imgJson = gson.toJson(map);
			}			
		} catch (Exception e) {
			this.imgJson = "";
			e.printStackTrace();
		}	
		return this;
	}
	
	public String getImgJson() {
		return imgJson;
	}


	//图片的url以及对应的宽高（图片定高显示）
	private ArrayList<DocImage> img = new ArrayList<DocImage>();


	public ArrayList<DocImage> getImg() {
		return img;
	}

	public void setImg(ArrayList<DocImage> img) {
		this.img = img;
	}
	

	private ArrayList<Relation> relations = new ArrayList<Relation>();
	private ArrayList<Extension> links = new ArrayList<Extension>();
	private ArrayList<Extension> extSlides = new ArrayList<Extension>();
	//add for video
	private ArrayList<VideoBody> videos = new ArrayList<VideoBody>();
	
	public ArrayList<VideoBody> getVideos() {
		return videos;
	}

	public void setVideos(ArrayList<VideoBody> videos) {
		this.videos = videos;
	}

	public String getCommentsExt() {
    return commentsExt;
    }

    public void setCommentsExt(String commentsExt) {
     this.commentsExt = commentsExt;
    }

    public String getHasVideo() {
		return hasVideo;
	}

	public void setHasVideo(String hasVideo) {
		this.hasVideo = hasVideo;
	}

	public String getThumbnail() {
		return thumbnail;
	}

	public void setThumbnail(String thumbnail) {
		this.thumbnail = thumbnail;
	}

	public String getIntroduction() {
		return introduction;
	}

	public void setIntroduction(String introduction) {
		this.introduction = introduction;
	}

	public String getCommentType() {
		return commentType;
	}

	public void setCommentType(String commentType) {
		this.commentType = commentType;
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getEditTime() {
		return editTime;
	}

	public void setEditTime(String editTime) {
		this.editTime = editTime;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getWwwurl() {
		return wwwurl==null?wapurl:wwwurl;
	}

	public void setWwwurl(String wwwurl) {
		this.wwwurl = wwwurl;
	}

	public String getWapurl() {
		return wapurl;
	}

	static final Pattern IMG_PATTERN=Pattern.compile("<ifengimg\\s*.*?\\s+src=['\"](.+?)['\"][\\s\\S]*?>", Pattern.CASE_INSENSITIVE);

	/**
	 * 存取图片路径，判断条件：1，图片是否已经缓存 2，是否符合无图模式条件
	 * 
	 * @param context
	 * @param srcList
	 * @param targetUrl
	 */
	private void addImage(List<String> srcList, String targetUrl,
			PhotoMode photoMode) {
		if (!TextUtils.isEmpty(targetUrl)) {
			File imgFile = IfengNewsApp.getResourceCacheManager().getCacheFile(
					targetUrl, true);
			if (photoMode == PhotoMode.VISIBLE_PATTERN) {
				srcList.add(targetUrl);
			}

			// 如果图片已经缓存，则直接显示缓存地址
			else if (imgFile != null && imgFile.exists()) {
				srcList.add(targetUrl);
			}
		}
	}
	
	public ArrayList<String> getImages(Context context)
	{
		PhotoMode photoMode = PhotoModeUtil.getCurrentPhotoMode(context);
		ArrayList<String> arrayList=new ArrayList<String>();
		if (null != liveStream && !TextUtils.isEmpty(liveStream.getThumbnail())) {
			addImage(arrayList, liveStream.getThumbnail(), photoMode);
		}
		for(VideoBody videoBody : videos){
			addImage(arrayList, videoBody.getThumbnail(),photoMode);
		}
		//TODO 分享是的时候也要显示图集的图片 
		for(Extension extension : extSlides){
			if("slide".equals(extension.getType())){
				addImage(arrayList,extension.getThumbnailpic(),photoMode);
			}
		}
		if(TextUtils.isEmpty(text)) return arrayList;
		Matcher matcher=IMG_PATTERN.matcher(text);
		while(matcher.find())
		{
			addImage(arrayList, matcher.group(1),photoMode);
		}
		return arrayList;
	}

	public void setWapurl(String wapurl) {
		this.wapurl = wapurl;
	}

	public String getVideoPoster() {
		return videoPoster;
	}

	public void setVideoPoster(String videoPoster) {
		this.videoPoster = videoPoster;
	}

	public String getVideoSrc() {
		return videoSrc;
	}

	public void setVideoSrc(String videoSrc) {
		this.videoSrc = videoSrc;
	}

	public String getDocumentId() {
//		return FilterUtil.filterDocumentId(documentId); 
		return documentId;
	}

	public void setDocumentId(String documentId) {
		this.documentId = documentId;
	}

	public String getShareurl() {
		return shareurl;
	}

	public void setShareurl(String shareurl) {
		this.shareurl = shareurl;
	}

	public ArrayList<Relation> getRelations() {
		return relations;
	}

	public void setRelations(ArrayList<Relation> relations) {
		this.relations = relations;
	}

	public String getRelationsData(){
		try {
			if(relations!=null && relations.size()>0){
				for(Relation relation : relations){
					//根据返回的type动态的设置显示的图片
					if("slide".equalsIgnoreCase(relation.getType())){
						relation.setSrc("channel_list_atlas_icon.png");
					}else if ("doc__video".equalsIgnoreCase(relation.getType())){
						relation.setSrc("channel_list_video_icon.png");
					}
				}
				Gson gson=new Gson();
				Log.d("web", gson.toJson(relations));
				return gson.toJson(relations);
			}
			return null;
		} catch (Exception e) {
			return null;
		}
	}
	
	public String getLinksData(){
		try {
			if(links!=null && links.size()>0){
				Gson gson=new Gson();
				return gson.toJson(links);
			}
			return null;
		} catch (Exception e) {
			return null;
		}
	}

	public ArrayList<Extension> getLinks() {
		return links;
	}

	public void setLinks(ArrayList<Extension> links) {
		this.links = links;
	}

	public ArrayList<Extension> getExtSlides() {
		return extSlides;
	}

	public void setExtSlides(ArrayList<Extension> extSlides) {
		this.extSlides = extSlides;
	}

	public String getCommentsUrl() {
		return commentsUrl;
	}

	public void setCommentsUrl(String commentsUrl) {
		this.commentsUrl = commentsUrl;
	}

	public String getFontSize() {
		return fontSize;
	}

	public void setFontSize(String fontSize) {
		this.fontSize = fontSize;
	}
	
	/**
	 * 通过应用当前的字体大小，修复正文中各种字体的大小
	 * @param currentFontSize
	 */
	public void formatText(FontSize currentFontSize){
		text = text.trim().replace("<img ", "<ifengimg ").replace("img>", "ifengimg>");
		if(text.contains("font-size:large")){
			text = text.replace("style=\"font-size:large;", "class=\""+currentFontSize.getLarger()+"\" name=\"content_span\" style=\"");
		}
		if(text.contains("font-size:medium")){
			text = text.replace("style=\"font-size:medium;", "class=\""+currentFontSize+"\" name=\"content_span\" style=\"");
		}
		if(text.contains("font-size:small")){
			text = text.replace("style=\"font-size:small;", "class=\""+currentFontSize.getSmaller()+"\" name=\"content_span\" style=\"");
		}
	}

	public String[] getSurvey() {
		return survey;
	}

	public void setSurvey(String[] survey) {
		this.survey = survey;
	}

	public String[] getVote() {
		return vote;
	}

	public void setVote(String[] vote) {
		this.vote = vote;
	}
	
}
