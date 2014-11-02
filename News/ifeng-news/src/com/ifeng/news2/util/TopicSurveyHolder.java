package com.ifeng.news2.util;

import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import com.ifeng.news2.R;
import com.ifeng.news2.R.id;
import com.ifeng.news2.activity.TopicDetailModuleActivity;
import com.ifeng.news2.widget.DividerLine;

/**
 * @author liu_xiaoliang
 * 
 */
public class TopicSurveyHolder implements TopicDetailViewHolder {
  
  private Button joinSurveyBut;
  private SurveyModuleUtil surveyUtil;
  private ImageView icon, progress;
  private View view, leftModule, headView, surveyItemView, joinSurvey;
  private TextView title, timeState, percentageTv, pnum, answer;
  
  @Override
  public void createView(View view) {
    
    this.view = view;
    
    leftModule = view.findViewById(R.id.topic_survey_left_module);
    TextView leftModuleTitle = ((TextView)leftModule.findViewById(R.id.title));
    leftModuleTitle.setText("民调");
    DividerLine line = (DividerLine)view.findViewById(id.channelDivider);
    if (TopicDetailModuleActivity.STYLE.equals("normal")) {
      line.setNormalDivider(false);
      leftModuleTitle.setTextColor(view.getContext().getResources().getColor(R.color.title_color));
    } else {
      line.setNormalDivider(true);
      leftModuleTitle.setTextColor(view.getContext().getResources().getColor(R.color.topic_slider_inactive_color));
    }
    
    headView = view.findViewById(R.id.survey_head);
    title = (TextView) headView.findViewById(R.id.title);
//    title.setTextColor(getResources().getColor(R.color.topic_title_font));
    timeState = (TextView) headView.findViewById(R.id.time_state);
    headView.findViewById(R.id.survey_introd).setVisibility(View.GONE);


    surveyItemView = view.findViewById(R.id.survey_qusetion);
//    surveyState = (ViewSwitcher) surveyItemView.findViewById(R.id.survey_state);
//    surveyState.setDisplayedChild(1);
    view.findViewById(R.id.survey_answer_item).setVisibility(View.GONE);
    view.findViewById(R.id.survey_result_item).setVisibility(View.VISIBLE);

    icon = (ImageView) surveyItemView.findViewById(R.id.survey_result_icon);
    progress = (ImageView) surveyItemView.findViewById(R.id.survey_result_progress);
    percentageTv = (TextView) surveyItemView.findViewById(R.id.survey_result_percentage);
    pnum = (TextView) surveyItemView.findViewById(R.id.survey_result_pnum);
    answer = (TextView) surveyItemView.findViewById(R.id.survey_result_answer_item);

    joinSurvey = view.findViewById(R.id.survey_button);
    joinSurveyBut = (Button)joinSurvey.findViewById(R.id.topic_join_survey_but);
  }

  public Button getJoinSurveyBut() {
    return joinSurveyBut;
  }

  public void setJoinSurveyBut(Button joinSurveyBut) {
    this.joinSurveyBut = joinSurveyBut;
  }

  public SurveyModuleUtil getSurveyUtil() {
    return surveyUtil;
  }

  public void setSurveyUtil(SurveyModuleUtil surveyUtil) {
    this.surveyUtil = surveyUtil;
  }

  public ImageView getIcon() {
    return icon;
  }

  public void setIcon(ImageView icon) {
    this.icon = icon;
  }

  public ImageView getProgress() {
    return progress;
  }

  public void setProgress(ImageView progress) {
    this.progress = progress;
  }

  public View getHeadView() {
    return headView;
  }

  public void setHeadView(View headView) {
    this.headView = headView;
  }

  public View getSurveyItemView() {
    return surveyItemView;
  }

  public void setSurveyItemView(View surveyItemView) {
    this.surveyItemView = surveyItemView;
  }

  public View getJoinSurvey() {
    return joinSurvey;
  }

  public void setJoinSurvey(View joinSurvey) {
    this.joinSurvey = joinSurvey;
  }

  public TextView getTitle() {
    return title;
  }

  public void setTitle(TextView title) {
    this.title = title;
  }

  public TextView getTimeState() {
    return timeState;
  }

  public void setTimeState(TextView timeState) {
    this.timeState = timeState;
  }

  public TextView getPercentageTv() {
    return percentageTv;
  }

  public void setPercentageTv(TextView percentageTv) {
    this.percentageTv = percentageTv;
  }

  public TextView getPnum() {
    return pnum;
  }

  public void setPnum(TextView pnum) {
    this.pnum = pnum;
  }

  public TextView getAnswer() {
    return answer;
  }

  public void setAnswer(TextView answer) {
    this.answer = answer;
  }

  public View getLeftModule() {
    return leftModule;
  }

  public void setLeftModule(View leftModule) {
    this.leftModule = leftModule;
  }

  public View getView() {
    return view;
  }

  public void setView(View view) {
    this.view = view;
  }
  
}
