package com.ifeng.news2.plot_module;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ViewSwitcher;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.SurveyInfo;
import com.ifeng.news2.bean.SurveyItem;
import com.ifeng.news2.bean.SurveyUnit;
import com.ifeng.news2.bean.TopicSubject;
import com.ifeng.news2.plot_module.bean.PlotTopicBodyItem;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.RecordUtil;
import com.ifeng.news2.util.SurveyModuleUtil;
import com.ifeng.news2.util.TopicDetailUtil;
import com.ifeng.share.util.NetworkState;
import com.qad.loader.BeanLoader;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import java.io.Serializable;
import java.text.DecimalFormat;

/**
 * @author liu_xiaoliang
 * 提供策划专题公共方法
 */
public class TopicSurveyModule extends LinearLayout {

  private boolean isPlot;
  public Context context;
  public LayoutInflater inflater;
  private BeanLoader beanLoader;
  public TopicSubject subject = null;
  public PlotTopicBodyItem plotTopicBody = null;

  private String id;
  private Button joinSurveyBut;
  private ViewSwitcher surveyState;
  private SurveyModuleUtil surveyUtil;
  private ImageView icon, progress;
  private View headView, surveyItemView, joinSurvey;
  private TextView title, timeState, percentageTv, pnum, answer;

  public TopicSurveyModule(Context context) {
    super(context);
    init(context);
  }


  public void init(Context context){
    this.context = context;
    inflater = LayoutInflater.from(context);
    surveyUtil = new SurveyModuleUtil(context);
    setOrientation(LinearLayout.VERTICAL);
    findViewById();
  }

  private void findViewById(){
    headView = inflater.inflate(R.layout.survey_head_item, null);
    title = (TextView) headView.findViewById(R.id.title);
    title.setTextColor(getResources().getColor(R.color.topic_title_font));
    timeState = (TextView) headView.findViewById(R.id.time_state);
    headView.findViewById(R.id.survey_introd).setVisibility(View.GONE);


    surveyItemView = inflater.inflate(R.layout.survey_list_title_qusetion_item, null);
//    surveyState = (ViewSwitcher) surveyItemView.findViewById(R.id.survey_state);
//    surveyState.setDisplayedChild(1);
    surveyItemView.findViewById(R.id.survey_answer_item).setVisibility(View.GONE);
    surveyItemView.findViewById(R.id.survey_result_item).setVisibility(View.VISIBLE);
    
    icon = (ImageView) surveyItemView.findViewById(R.id.survey_result_icon);
    progress = (ImageView) surveyItemView.findViewById(R.id.survey_result_progress);
    percentageTv = (TextView) surveyItemView.findViewById(R.id.survey_result_percentage);
    pnum = (TextView) surveyItemView.findViewById(R.id.survey_result_pnum);
    answer = (TextView) surveyItemView.findViewById(R.id.survey_result_answer_item);

    joinSurvey = inflater.inflate(R.layout.join_survey, null);
    joinSurveyBut = (Button)joinSurvey.findViewById(R.id.topic_join_survey_but);
    joinSurveyBut.setOnClickListener(new View.OnClickListener() {

      @Override
      public void onClick(View v) {
        if (!NetworkState.isActiveNetworkConnected(context)) {
          Toast.makeText(context, "当前无网络", Toast.LENGTH_SHORT).show();
          return;
        }
        Extension extension = new Extension();
        extension.setType(TopicDetailUtil.SURVEY_MODULE_TYPE);
        if (isPlot) {
          extension.setThumbnail(plotTopicBody.getShareThumbnail());
        } else {
          extension.setThumbnail(subject.getShareThumbnail());
        }
        extension.setUrl(id);
        IntentUtil.startActivityWithPos(context, extension,0);
      }
    });
  }

  public BeanLoader getDefaultLoader(){
    if(beanLoader==null){
      beanLoader = IfengNewsApp.getBeanLoader();
    }
    return beanLoader;
  }

  /**
   * 创建View
   */
  public void create(){
    if(isBuildModule())buildModule();
  }

  /**
   * 子类实现
   */
  public void buildModule(){
    joinSurveyBut.setTag(id);
    IfengNewsApp.getBeanLoader().startLoading(
      new LoadContext<String, LoadListener<SurveyUnit>, SurveyUnit>(
          ParamsManager.addParams(context, Config.SURVEY_GET_URL + id),
          new LoadListener<SurveyUnit>(){

            @Override
            public void postExecut(LoadContext<?, ?, SurveyUnit> surveyContext) {
              SurveyUnit unit = surveyContext.getResult();
              if (null == unit || 
                  -1 == unit.getIfsuccess() || 
                  null == unit.getData() || 
                  null == unit.getData().getResult() || 
                  unit.getData().getResult().size() == 0) {
                surveyContext.setResult(null);
                return;
              }
              saveCache(surveyContext);
            }

            @Override
            public void loadComplete(LoadContext<?, ?, SurveyUnit> surveyContext) {
              SurveyUnit surveyUnit = surveyContext.getResult();
              if (1 == surveyUnit.getIfsuccess()) {
                rendUI(surveyUnit);
                if (!isPlot) {
                  addView(getLeftTitleView(subject.getTitle()));
                } else {
                  addView(inflater.inflate(R.layout.poll_title, null));
                }
                addView(headView);
                addView(inflater.inflate(R.layout.survey_head_list_divider, null));
                addView(surveyItemView);
                addView(joinSurvey);
              }
            }

            @Override
            public void loadFail(LoadContext<?, ?, SurveyUnit> surveyContext) {}}, SurveyUnit.class, Parsers
            .newSurveyUnitParser(), false,
            LoadContext.FLAG_HTTP_FIRST, false));
  }
  
  private void saveCache(LoadContext<?, ?, SurveyUnit> context){
    if(context.getResult()!=null 
            && !context.isAutoSaveCache()
            && context.getType() == LoadContext.TYPE_HTTP){
        BeanLoader.getMixedCacheManager().saveCache(context.getParam().toString(),
                (Serializable) context.getResult());
    }
  }

  /**
   * 是否构造Module
   * @return
   */
  private boolean isBuildModule(){
    if (isPlot) {
      if (null == plotTopicBody || TextUtils.isEmpty(plotTopicBody.getPollId())) {
        return false;
      } else {
        id = plotTopicBody.getPollId();
        return true;
      }
    } else {
      if (subject == null || subject.getPodItems() == null || subject.getPodItems().size() == 0 || TextUtils.isEmpty(subject.getPodItems().get(0).getId())) {
        return false;
      } else {
        id = subject.getPodItems().get(0).getId();
        return true;
      }
    }
  }
  
  public void setData(Object object){
    if (object instanceof PlotTopicBodyItem) {
      this.plotTopicBody = (PlotTopicBodyItem)object;
      isPlot = true;
      headView.setBackgroundDrawable(null);
      surveyItemView.setBackgroundDrawable(null);
    } else {
      this.subject = (TopicSubject)object;
      isPlot = false;
    }
  }

  public View getLeftTitleView(String title){
    View view=LayoutInflater.from(context).inflate(R.layout.title_left_module, null);
    TextView titleView = (TextView)view.findViewById(R.id.title);
    titleView.setText(title);
    return view;
  }

  private void rendUI(SurveyUnit surveyUnit){
    if (null == surveyUnit.getData()) {
      return;
    }
    surveyUnit.formatAllPnum();
    if (null != surveyUnit.getData().getSurveyinfo()) {
      SurveyInfo info = surveyUnit.getData().getSurveyinfo();
      title.setText(info.getTitle());
      StringBuffer buffer = new StringBuffer();
      
      if ("1".equals(info.getIsactive())) {
        buffer.append("进行中  ");
        if (RecordUtil.isRecorded(context, id, RecordUtil.SURVEY)) {
          joinSurveyBut.setText(R.string.survey_see_results);  
        } else {
          joinSurveyBut.setText(R.string.survey_join);
        }
      } else {
        buffer.append("已结束  ");
        RecordUtil.record(context, id, RecordUtil.SURVEY);
        joinSurveyBut.setText(R.string.survey_see_results);
      }

      if (TextUtils.isEmpty(info.getPnum())) {
        buffer.append("0人参与");
      } else {
        buffer.append(info.getPnum()+"人参与");
      }
      timeState.setText(buffer.toString());
      icon.setBackgroundResource(R.drawable.result_blue);
      progress.setBackgroundResource(R.drawable.result_color_blue);
      SurveyItem surveyItem = surveyUnit.getData().getTopicHighestItem();
      double percentage = 0.00;
      try {
        percentage = Double.parseDouble(surveyItem.getNump()) / 100;
      } catch (Exception e) {}
      LayoutParams params = new LayoutParams(0, surveyUtil.getResultProgressH());
      progress.setLayoutParams(params);
      surveyUtil.setAutoWScaleAnimation(progress, (int)(surveyUtil.getResultProgressFullW()*percentage));
      percentageTv.setText(surveyUtil.getPercentageStyleStr(surveyItem.getNump()));
      pnum.setText(new DecimalFormat(",###").format(surveyItem.getNum()) + "票");
      answer.setText(surveyItem.getTitle());
    }
  }
}
