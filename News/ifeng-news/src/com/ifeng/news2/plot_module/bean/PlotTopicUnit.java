package com.ifeng.news2.plot_module.bean;

import java.util.ArrayList;

import com.ifeng.news2.bean.Content;
import com.ifeng.news2.bean.TopicMeta;
import java.io.Serializable;

/**
 * @author liu_xiaoliang
 * 策划专题数据结构
 */
public class PlotTopicUnit implements Serializable {

  private static final long serialVersionUID = -8325284250951797870L;

  /**
   * 描述
   */
  private TopicMeta meta = new TopicMeta();
  /**
   * 实体
   */
  private ArrayList<PlotTopicBodyItem> body = new ArrayList<PlotTopicBodyItem>();
  /**
   * 公共信息描述
   */
  private Content content = new Content();
  
  
  public TopicMeta getMeta() {
    return meta;
  }
  public void setMeta(TopicMeta meta) {
    this.meta = meta;
  }
  public ArrayList<PlotTopicBodyItem> getBody() {
    return body;
  }
  public void setBody(ArrayList<PlotTopicBodyItem> body) {
    this.body = body;
  }
  public Content getContent() {
    return content;
  }
  public void setContent(Content content) {
    this.content = content;
  }
  
  public boolean isNullDatas(){
    if (null == body || 0 == body.size()) {
      return true;
    }
    return false;
  }
}
