package com.ifeng.news2.util;

import com.ifeng.news2.plot_module.TopicSurveyModule;
import android.content.Context;
import android.view.View;
import android.widget.LinearLayout;
import com.ifeng.news2.plot_module.PlotAtlasModule;
import com.ifeng.news2.plot_module.PlotBaseModule;
import com.ifeng.news2.plot_module.PlotBigTitleModule;
import com.ifeng.news2.plot_module.PlotDiagramModule;
import com.ifeng.news2.plot_module.PlotDocTitleModule;
import com.ifeng.news2.plot_module.PlotEpilogueModule;
import com.ifeng.news2.plot_module.PlotHtmlModule;
import com.ifeng.news2.plot_module.PlotMutilTitle;
import com.ifeng.news2.plot_module.PlotSummaryModule;
import com.ifeng.news2.plot_module.PlotTextModule;
import com.ifeng.news2.plot_module.PlotTopicTitleModule;
import com.ifeng.news2.plot_module.PlotVoteModule;
import com.ifeng.news2.plot_module.bean.PlotTopicBodyItem;

/**
 * @author liu_xiaoliang
 * 
 */
public class PlotModuleViewFactory {

  public final static String PLOT_MODULE_HTML = "html";                   //正文
  public final static String PLOT_MODULE_BANNER = "banner";               //头图
  public final static String PLOT_MODULE_TOPIC_TITLE = "h1";              //大标题（带评论数）
  public final static String PLOT_MODULE_SUMMARY = "summary";             //导读
  public final static String PLOT_MODULE_DIAGRAM = "diagram";             //图说
  public final static String PLOT_MODULE_CONTENT = "content";             //文章内容
  public final static String PLOT_MODULE_ATLAS_TITLE = "atlas";           //图集
  public final static String PLOT_MODULE_DOC_TITLE = "doc_title";         //文章标题
  public final static String PLOT_MODULE_BIG_TITLE = "big_title";         //大标题
  public final static String PLOT_MODULE_PEROROATION = "peroration";      //结语
  public final static String PLOT_MODULE_VOTE = "vote";					  //投票
  public final static String PLOT_MODULE_SURVEY = "survey";				  //调查

  private static LinearLayout commentModuleView = null;                   //评论模块View
  
  public static View createView(Context context,PlotTopicBodyItem plotTopicBodyItem){
    View view = new View(context);
    String currentType = plotTopicBodyItem.getType();
    PlotBaseModule module = null;
    if(PLOT_MODULE_BANNER.equals(currentType)){
      //焦点图
      module = new PlotMutilTitle(context);
    } else if(PLOT_MODULE_SUMMARY.equals(currentType)){
      //导读模块
      module = new PlotSummaryModule(context);
    } else if(PLOT_MODULE_TOPIC_TITLE.equals(currentType)){
      //大标题（带评论数）
      module = new PlotTopicTitleModule(context);
      ((PlotTopicTitleModule)module).setCommentModuleView(commentModuleView);
    }  else if(PLOT_MODULE_BIG_TITLE.equals(currentType)){
      //大标题
      module = new PlotBigTitleModule(context);
    } else if(PLOT_MODULE_HTML.equals(currentType)){
      //正文
      module = new PlotHtmlModule(context);
    } else if(PLOT_MODULE_DOC_TITLE.equals(currentType)){
      //文章标题
      module = new PlotDocTitleModule(context);
    } else if(PLOT_MODULE_ATLAS_TITLE.equals(currentType)){
      //图集
      module = new PlotAtlasModule(context);
    } else if(PLOT_MODULE_DIAGRAM.equals(currentType)){
      //图说
      module = new PlotDiagramModule(context);
    }  else if(PLOT_MODULE_CONTENT.equals(currentType)){
      //文章内容
      module = new PlotTextModule(context);
    } else if(PLOT_MODULE_PEROROATION.equals(currentType)){
      //结语模块
      module = new PlotEpilogueModule(context);
    } 
    //投票
    else if(PLOT_MODULE_VOTE.equals(currentType)) {
    	module = new PlotVoteModule(context);
    } 
    //调查
    else if(PLOT_MODULE_SURVEY.equals(currentType)) {
      TopicSurveyModule topicSurvey = new TopicSurveyModule(context);
      topicSurvey.setData(plotTopicBodyItem);
      topicSurvey.create();
      return topicSurvey;
    }
    
    if(module!=null) {
    	 module.setData(plotTopicBodyItem);
    	 module.create();
    	 view = module;
    }
    return view;
  }

  public static LinearLayout getCommentModuleView() {
    return commentModuleView;
  }

  public static void setCommentModuleView(LinearLayout view) {
    if (null != view) {
      view.removeAllViews();
    }
    commentModuleView = view;
  }
}
