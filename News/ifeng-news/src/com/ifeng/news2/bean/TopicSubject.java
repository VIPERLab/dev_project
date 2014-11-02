package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

public class TopicSubject implements Serializable, Cloneable{

	private static final long serialVersionUID = 1L;
	private String shareThumbnail = "";//投票调查分享图片url
	private String topicId ="";
	private String imageUrl =""; // 专题图片
	
	private String title="";//标题
	private String view="";//对应的视图类型
    /*< begin 动态专题重构 liuxiaoliang 20131224 */
	//动态专题view = list类型数据重构用到标示是第一项还是最后一项
	private int startPosition;
	private int endPosition;
	private int lastSelectionPosition;
	private String firstOrLast;
	private String userFace;
	private String ip_from;
	private String comment_contents;
	/*end 动态专题重构 liuxiaoliang 20131224 >*/
	private ArrayList<TopicSubject> subjects = new ArrayList<TopicSubject>();
	private ArrayList<TopicContent> podItems = new ArrayList<TopicContent>();
	private TopicContent content;//内容
	private String wwwUrl = "";//被评论ID 在CommentListModule.java中使用， 在代码中强行塞入
	private String shareUrl =""; //分享的url
	
	public String getWwwUrl() {
		return wwwUrl;
	}
	public void setWwwUrl(String wwwUrl) {
		this.wwwUrl = wwwUrl;
	}
	
	public String getImageUrl() {
		return imageUrl;
	}
	public void setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getView() {
		return view;
	}
	public void setView(String view) {
		this.view = view;
	}
	public TopicContent getContent() {
		return content;
	}
	public void setContent(TopicContent content) {
		this.content = content;
	}
	public ArrayList<TopicSubject> getSubjects() {
		return subjects;
	}
	public void setSubjects(ArrayList<TopicSubject> subjects) {
		this.subjects = subjects;
	}
	public ArrayList<TopicContent> getPodItems() {
		return podItems;
	}
	public void setPodItems(ArrayList<TopicContent> podItems) {
		this.podItems = podItems;
	}
	
	public String getTopicId() {
		return topicId;
	}
	public void setTopicId(String topicId) {
		this.topicId = topicId;
		if (null == podItems || podItems.size() ==0) {
          return;
        }
		for (TopicContent topicContent : podItems) {
		  topicContent.setTopicId(topicId);
        }
	}
	public String getShareThumbnail() {
		return shareThumbnail;
	}
	public void setShareThumbnail(String shareThumbnail) {
		this.shareThumbnail = shareThumbnail;
	}
	
	public String getShareUrl() {
		return shareUrl;
	}
	public void setShareUrl(String shareUrl) {
		this.shareUrl = shareUrl;
	}
	@Override
	public Object clone(){
	  try{
	    return super.clone(); 
	  } catch (CloneNotSupportedException e) {
	    return null;
	  } 
	}
  public int getStartPosition() {
    return startPosition;
  }
  public void setStartPosition(int startPosition) {
    this.startPosition = startPosition;
  }
  public int getEndPosition() {
    return endPosition;
  }
  public void setEndPosition(int endPosition) {
    this.endPosition = endPosition;
  }
  public String getUserFace() {
    return userFace;
  }
  public void setUserFace(String userFace) {
    this.userFace = userFace;
  }
  public String getIp_from() {
    return ip_from;
  }
  public void setIp_from(String ip_from) {
    this.ip_from = ip_from;
  }
  public String getComment_contents() {
    return comment_contents;
  }
  public void setComment_contents(String comment_contents) {
    this.comment_contents = comment_contents;
  }
  public String getFirstOrLast() {
    return firstOrLast;
  }
  public void setFirstOrLast(String firstOrLast) {
    this.firstOrLast = firstOrLast;
  }
  public int getLastSelectionPosition() {
    return lastSelectionPosition;
  }
  public void setLastSelectionPosition(int lastSelectionPosition) {
    this.lastSelectionPosition = lastSelectionPosition;
  }
	
}
