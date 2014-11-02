package com.ifeng.news2.plot_module.utils;

import android.text.TextUtils;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.plot_module.bean.PlotTopicBodyItem;
import com.ifeng.news2.util.PlotModuleViewFactory;
import java.util.ArrayList;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

/**
 * @author liu_xiaoliang
 * 策划专题html类型解析器
 */
public class PlotTopicHtmlParser {

  /**
   * @param html 要解析的内容  如果html为空，则函数返回null
   * @return ArrayList<PlotTopicBodyItem>
   */
  public static ArrayList<PlotTopicBodyItem> parserHtml(String html, String thumbnail){

    if (TextUtils.isEmpty(html)) {
      return null;
    }

    Document doc = Jsoup.parse(html);
    Elements contents = doc.getAllElements();

    ArrayList<PlotTopicBodyItem> plotTopicBodyItems = new ArrayList<PlotTopicBodyItem>();

    for (Element content : contents) {
      if ("h2".equals(content.tag().toString())) {
        //大标题
        plotTopicBodyItems.add(buildPlotTopicBody(content, PlotModuleViewFactory.PLOT_MODULE_BIG_TITLE, null));
      } else if ("h3".equals(content.tag().toString())) {
        //文章标题
        plotTopicBodyItems.add(buildPlotTopicBody(content, PlotModuleViewFactory.PLOT_MODULE_DOC_TITLE, null));
      } else if ("p".equals(content.tag().toString())) {
        //内容文本内容直接返回html
        plotTopicBodyItems.add(buildPlotTopicBody(content, PlotModuleViewFactory.PLOT_MODULE_CONTENT, null));
      }
      else if ("img".equals(content.tag().toString())) {
//        if ("p".equals(content.parent().tag().toString())) {
//          //内容中插图片
//          continue;
//        }
        //图片
        String classs =  content.attr("class");
        plotTopicBodyItems.add(buildPlotTopicBody(content, "legend".equals(classs)?PlotModuleViewFactory.PLOT_MODULE_DIAGRAM:PlotModuleViewFactory.PLOT_MODULE_ATLAS_TITLE, null));
      }
      //
      else if("input".equals(content.tag().toString())) {
    	  String classs =  content.attr("class");
    	  //投票
    	  if(classs.equals("vote-content-block")) {
    		  plotTopicBodyItems.add(buildPlotTopicBody(content, PlotModuleViewFactory.PLOT_MODULE_VOTE, null));
    	  }
    	  //调查
    	  else if(classs.equals("survey-content-block")) {
    		  plotTopicBodyItems.add(buildPlotTopicBody(content, PlotModuleViewFactory.PLOT_MODULE_SURVEY, null));
    	  }
      }
    }
    return plotTopicBodyItems;
  }

  private static PlotTopicBodyItem buildPlotTopicBody(Element content, String type, String shareThumbnail){

    if (null == content) {
      return null;
    }

    PlotTopicBodyItem plotTopicBodyItem = new PlotTopicBodyItem();
    plotTopicBodyItem.setType(type);
    plotTopicBodyItem.setTitle(content.text() == null ? "" : content.text().toString());

    //文章内容
    if (PlotModuleViewFactory.PLOT_MODULE_CONTENT.equals(type)) {
      plotTopicBodyItem.setIntro(content.text());
    } else if (PlotModuleViewFactory.PLOT_MODULE_ATLAS_TITLE.equals(type) || PlotModuleViewFactory.PLOT_MODULE_DIAGRAM.equals(type)) {
      plotTopicBodyItem.setIntro(content.attr("alt"));
    } 
    //投票或调查
    else if (PlotModuleViewFactory.PLOT_MODULE_VOTE.equals(type) || PlotModuleViewFactory.PLOT_MODULE_SURVEY.equals(type)) {
      plotTopicBodyItem.setPollId(content.attr("data-value"));
      plotTopicBodyItem.setShareThumbnail(shareThumbnail);      
    }
    //文章标题跳转
    if (!TextUtils.isEmpty(content.attr("link"))) {
      String typeStr = content.attr("type");
      String linkStr = content.attr("link");
      if (!TextUtils.isEmpty(typeStr) && !TextUtils.isEmpty(linkStr)) {
        //type="A,B"  link="A_link,B_link"
        ArrayList<Extension> links = new ArrayList<Extension>();
        String typeArray[] = typeStr.split(",");
        String linkArray[] = linkStr.split(",");
        if (null != typeArray && null != linkArray) {
          int length =  typeArray.length > linkArray.length ? linkArray.length : typeArray.length;
          for (int i = 0; i < length ; i++) {
            Extension link = new Extension();
            link.setType(typeArray[i]);
            link.setUrl(linkArray[i]);
            links.add(link);
          }
        }
        plotTopicBodyItem.setLinks(links);;
      }
    }

    plotTopicBodyItem.setThumbnail(content.attr("src"));
    return plotTopicBodyItem;
  } 
}
