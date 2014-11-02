package com.ifeng.news2.bean;

import android.text.TextUtils;
import android.text.format.DateFormat;
import com.ifeng.news2.util.FilterUtil;
import com.ifeng.news2.util.ModuleLinksManager;
import com.ifeng.news2.util.ReadUtil;
import java.io.Serializable;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

public class ListItem implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 5962831786944371524L;

	private String title = "";
	private String hasVideo = "N";

	private String source = "";

	private String editTime = "";
	private String updateTime = "";
	private String relativeTime;

	private String introduction = "";

	private String thumbnail = "";
	private String documentId = "";
	private String id = "";
	private String type = "";
	// @gm, add extra for topic
	private String extra = "";
	
	private String linkType = "";

	private String commentsAll = "0";

	private String comments = "0";
	private DocUnit docUnit = null;
	// @lxl, Customize ad position
	private String position = "";
	// @lxl, add  for collection
	private boolean status = false;
	//正文挂民调
	private String hasSurvey;
	/**
	 * V4.1.1 收藏类表icon样式图标标示符 
	 */
	private String typeIcon;
	
	private ArrayList<Extension> links = null;//new ArrayList<Extension>();

	private ArrayList<Extension> extensions = null;//new ArrayList<Extension>();


	private String thumbnail_first = "";

	private String thumbnail_second = "";

	private String thumbnail_third = "";
	
	public String getHasVideo() {
	  return hasVideo;
	}

	public void setHasVideo(String hasVideo) {
	  this.hasVideo = hasVideo;
	}

  public boolean isStatus() {
		return status;
	}
	
	public void setStatus(boolean status) {
		this.status = status;
	}
	
	public String getThumbnail_first() {
		return thumbnail_first;
	}

	public void setThumbnail_first(String thumbnail_first) {
		this.thumbnail_first = thumbnail_first;
	}

	public String getThumbnail_second() {
		return thumbnail_second;
	}

	public void setThumbnail_second(String thumbnail_second) {
		this.thumbnail_second = thumbnail_second;
	}

	public String getThumbnail_third() {
		return thumbnail_third;
	}

	public void setThumbnail_third(String thumbnail_third) {
		this.thumbnail_third = thumbnail_third;
	}

	public String getUpdateTime() {
		return updateTime;
	}

	public void setUpdateTime(String updateTime) {
		this.updateTime = updateTime;
	}

	public String getPosition() {
		return position;
	}

	public void setPosition(String position) {
		this.position = position;
	}

	public void setDocUnit(DocUnit docUnit) {
		this.docUnit = docUnit;
	}

	public DocUnit getDocUnit() {
		return docUnit;
	}

	public String getTitle() {
//		if (TextUtils.isEmpty(title)) {
//			title = "";
//		}
//		int titleLength = title.length();
//		if (titleLength < 24) {
//			return title;
//		}
//		float count = 0;
//		int i = 0;
//		for (; i < titleLength; i++) {
//			if (count >= 24) 
//				break;
//			char temp = title.charAt(i);
//			if (!IfengTextViewManager.isChineseCharacter(temp)){
//				count += 0.5;
//				continue;
//			}			
//			count ++;
//		}		
//		title = title.substring(0,i);
		return StringUtil.getStr(title, 24);
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) throws Exception {
		this.source = source;
	}

	public String getEditTime() {
		/*
		 * if (editTime != null && relativeTime == null) { relativeTime =
		 * DateUtil.toBriefString(editTime); }
		 */
		return editTime;
	}

	private static final SimpleDateFormat parseFormat = new SimpleDateFormat(
			"yyyy-MM-dd HH:mm:ss");
	private String fullEditTime;

	public String getFullEditTime() {
		if (editTime != null && fullEditTime == null) {
			try {
				fullEditTime = DateFormat.format("yyyy年MM月dd日",
						parseFormat.parse(editTime)).toString();
			} catch (ParseException e) {
				e.printStackTrace();
			}
		}
		return fullEditTime;
	}

	public void setEditTime(String editTime) {
		this.editTime = editTime;
	}

	public String getIntroduction() {
		return introduction;
	}

	public void setIntroduction(String introduction) {
		this.introduction = introduction;
	}

	public String getThumbnail() {
		return thumbnail;
	}

	public void setThumbnail(String thumbnail) {
		this.thumbnail = thumbnail;
	}

	public String getDocumentId() {
		// return FilterUtil.filterDocumentId(documentId);
		return documentId;
	}

	public String getFilterDocumentId() {
		return FilterUtil.filterDocumentId(documentId);
	}

	public void setDocumentId(String documentId) {
		this.documentId = documentId;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getType() {
		if (!"ad".equals(type) && 0 < getLinks().size() && null != getLinks().get(0)) {
			type = getLinks().get(0).getType();
		}
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public int getTitleColor() {
		return ReadUtil.isReaded(documentId) ? 0xff727272
				: 0xff004276;
	}

	public String getExtra() {
		return extra;
	}

	public void setExtra(String extra) {
		this.extra = extra;
	}

	public String getCommentsAll() {
		if ("0".equals(commentsAll) || commentsAll == null
				|| "false".equals(commentsAll)) {
			return "";
		}
		return commentsAll + "人参与";
	}

	public void setCommentsAll(String commentsAll) {
		this.commentsAll = commentsAll;
	}

	public void setComments(String comments) {
		this.comments = comments;
	}

	public String getComments() {
		if ("0".equals(comments) || TextUtils.isEmpty(comments)
				|| "false".equals(comments)) {
			return "";
		}
		try {
			Integer.parseInt(comments);
		} catch (Exception e) {
			return comments;
		}
		return comments;
	}

	public ArrayList<Extension> getExtensions() {
		if (null == extensions) {
			extensions = new ArrayList<Extension>();
		}
		return extensions;
	}

	public void setExtensions(ArrayList<Extension> extensions) {
		this.extensions = extensions;
	}

	public static Extension getDefaultExtension(ArrayList<Extension> extensions) {
		if (extensions == null)
			return null;
		for (Extension extension : extensions) {
			if ("1".equals(extension.getIsDefault())) {
				return extension;
			}
		}
		return null;
	}
	
	public String getLinkType() {
		ArrayList<Extension> linkList = getLinks(); 
		if(linkList != null && !linkList.isEmpty()){
			return linkList.get(0).getType();
		}
		return null;
	}

	public void setLinkType(String linkType) {
		this.linkType = linkType;
		
	}


	public ArrayList<Extension> getLinks() {
		if (null == links) {
			links = new ArrayList<Extension>();
		}
		if (links.size() > 0) {
			for(Extension extension:links){
				extension.setDocumentId(documentId);
				extension.setTitle(title);
				extension.setThumbnail(thumbnail);
				extension.setIntroduction(introduction);
			}			
		}
		return links;
	}

	public void setLinks(ArrayList<Extension> links) {
		this.links = links;
	}

	/**
	 * 判断是否是图集项
	 * 
	 * @param extensions
	 * @param data
	 * @return
	 */
	public boolean isChannelSlide(ArrayList<Extension> extensions) {
		if (null == extensions)
			return false;
		for (Extension extension : extensions) {
			if (null == extension)
				continue;
			if (ModuleLinksManager.LINK_STYLE_TYPE.equals(extension.getType())
					&& ModuleLinksManager.SLIDE_STYLE
							.equals(extension.getStyle())) {
				ArrayList<String> iamgeList = extension.getImages();
				if (null != iamgeList && iamgeList.size() == 3) {
					setThumbnail_first(extension.getImages().get(0));
					setThumbnail_second(extension.getImages().get(1));
					setThumbnail_third(extension.getImages().get(2));
					return true;
				}
			}
		}
		return false;
	}

  public String getHasSurvey() {
    return hasSurvey;
  }

  public void setHasSurvey(String hasSurvey) {
    this.hasSurvey = hasSurvey;
  }

  public String getTypeIcon() {
    return typeIcon;
  }

  public void setTypeIcon(String typeIcon) {
    this.typeIcon = typeIcon;
  }

}
