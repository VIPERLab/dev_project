package com.ifeng.news2.bean;

import java.io.Serializable;
import java.util.ArrayList;

import android.text.TextUtils;
/**
 * 专题详情页
 * @author PJW
 *
 */
public class TopicDetailUnits implements Serializable {

	private static final long serialVersionUID = 1L;
	private TopicMeta meta = new TopicMeta();
	private TopicBody body = new TopicBody();
	
	public TopicMeta getMeta() {
		return meta;
	}
	public void setMeta(TopicMeta meta) {
		this.meta = meta;
	}
	public TopicBody getBody() {
		return body;
	}
	public void setBody(TopicBody body) {
		this.body = body;
	}
	/**
	 * 数据是否为空判断
	 * @return
	 */
	public boolean isNullDatas(){
		if(body==null || body.getHead()==null || body.getSubjects().size()==0 || body.getContent()==null){
			return true;
		}
		return false;
	}
	ArrayList<String> ids = new ArrayList<String>();
	public ArrayList<String> getIds(){
		if(null == ids)
			ids = new ArrayList<String>();
		else 
			ids.clear();
		if (null == body) 
			body = new TopicBody();
		for(TopicSubject topicSubject:body.getSubjects()){
			if (null == topicSubject || !"list".equals(topicSubject.getView())) 
				continue;
			for(TopicContent topicContent : topicSubject.getPodItems()){
				if (null == topicContent) 
					continue;
				String url = getDocUrl(topicContent.getLinks());
				if (!TextUtils.isEmpty(url)) {
					ids.add(url);
				}
			}
		}
		return ids;
	}
	
	private String getDocUrl(ArrayList<Extension> links){
		if (null == links) 
			return "";
		for (Extension link : links) {
			if (null == link) 
				continue;
			if ("doc".equals(link.getType())) {
				return link.getUrl();
			}
		}
		return "";
	}
}
