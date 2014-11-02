package com.ifeng.news2.adapter;

import java.text.DecimalFormat;
import java.util.ArrayList;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.TextView;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.activity.SurveyActivity;
import com.ifeng.news2.bean.SurveyHttpResult;
import com.ifeng.news2.bean.SurveyItem;
import com.ifeng.news2.bean.SurveyResult;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.RecordUtil;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.SurveyModuleUtil;
import com.ifeng.news2.util.WindowPrompt;
import com.ifeng.news2.widget.IfengExpandableListView;
import com.ifeng.share.util.NetworkState;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;

/**
 * @author liu_xiaoliang
 *
 */
public class SurveyAdapter extends BaseExpandableListAdapter {

  private static final int[] RESULT_ICON_ID = {drawable.result_red, drawable.result_blue, drawable.result_yellow, drawable.result_dark_blue, drawable.result_green};
  private static final int[] RESULT_PROGRESS_ID = {drawable.result_color_red, drawable.result_color_blue, drawable.result_color_yellow, drawable.result_color_dark_blue, drawable.result_color_green};

  private String id;
  
  private boolean investigated = false;//是否参与过 

  private Context ctx;
  private SurveyModuleUtil surveyUtil;
  private ArrayList<SurveyResult> items;
  private IfengExpandableListView lv;

  public SurveyAdapter(Context ctx, IfengExpandableListView lv, String id,
      ArrayList<SurveyResult> items ) {
    this.ctx = ctx;
    this.lv = lv;
    this.id = id;
    this.items = items;
    init();
  }

  private void init() {
    surveyUtil = new SurveyModuleUtil(ctx);
    investigated = RecordUtil.isRecorded(ctx, id, RecordUtil.SURVEY);
  }

  @Override
  public Object getChild(int groupPosition, int childPosition) {
    return items.get(groupPosition).getResultArray().get(childPosition);
  }

  @Override
  public long getChildId(int groupPosition, int childPosition) {
    return childPosition;
  }

  private boolean isSingle(int groupPosition) {
    if ("single".equals(items.get(groupPosition).getChoosetype())) {
      return true;
    }
    return false;
  }


  @Override
  public View getChildView(int groupPosition, int childPosition, boolean isLastChild,
      View convertView, ViewGroup parent) {
    if (convertView == null) {
      convertView = surveyUtil.getInflater().inflate(R.layout.survey_list_title_qusetion_item, null);
    }
    if (investigated) {
      // 看结果
      addResultItemView(convertView, (SurveyItem) getChild(groupPosition, childPosition),
          groupPosition, childPosition, isLastChild);
    } else {
      if (isSingle(groupPosition)) {
        addSingleItemView(convertView, (SurveyItem) getChild(groupPosition, childPosition),
            groupPosition, isLastChild);
      } else {
        addMultipleItemView(convertView, (SurveyItem) getChild(groupPosition, childPosition),
            groupPosition, isLastChild);
      }
    }
    
    if (items.get(groupPosition).isChoice()) {
      convertView.setBackgroundResource(R.drawable.survey_list_answer_normal_item_bg);
    } else {
      convertView.setBackgroundResource(R.drawable.survey_list_answer_nuchoice_item_bg);
    }

    LinearLayout surveyListCommitModule =
        (LinearLayout) convertView.findViewById(R.id.survey_list_commit_module);
    surveyListCommitModule.removeAllViews();
    if (isLastChild && groupPosition == getGroupCount() - 1) {
      addCommitBut(surveyListCommitModule);
    }
    return convertView;
  }

  private View addResultItemView(View view, SurveyItem item, int groupPosition, int childPosition,
      boolean isShowListDivider) {

//    ViewSwitcher vurveyState = (ViewSwitcher) view.findViewById(R.id.survey_state);
//    vurveyState.setDisplayedChild(1);
    view.findViewById(R.id.survey_answer_item).setVisibility(View.GONE);
    view.findViewById(R.id.survey_result_item).setVisibility(View.VISIBLE);
    
        
    ImageView resultIcon = (ImageView) view.findViewById(R.id.survey_result_icon);
    ImageView resultProgress = (ImageView) view.findViewById(R.id.survey_result_progress);
    TextView resultPercentage = (TextView) view.findViewById(R.id.survey_result_percentage);
    TextView resultPnum = (TextView) view.findViewById(R.id.survey_result_pnum);
    TextView resultAnswerItem = (TextView) view.findViewById(R.id.survey_result_answer_item);

    int resultIconPosition = childPosition % RESULT_ICON_ID.length;
    resultIcon.setBackgroundResource(RESULT_ICON_ID[resultIconPosition]);
    resultProgress.setBackgroundResource(RESULT_PROGRESS_ID[resultIconPosition]);

    double percentage = 0.00;
    try {
      percentage = Double.parseDouble(item.getNump()) / 100;
    } catch (Exception e) {}
    if (item.isViewed()) {
      resultProgress.setAnimation(null);
      LayoutParams params = new LayoutParams((int)(percentage*surveyUtil.getResultProgressFullW()), surveyUtil.getResultProgressH());
      resultProgress.setLayoutParams(params);
    } else {
      LayoutParams params = new LayoutParams(0, surveyUtil.getResultProgressH());
      resultProgress.setLayoutParams(params);
      item.setViewed(true);
      surveyUtil.setAutoWScaleAnimation(resultProgress, (int)(surveyUtil.getResultProgressFullW()* percentage));
    }

    if (TextUtils.isEmpty(item.getNump())) {
      resultPercentage.setVisibility(View.GONE);
    } else {
      resultPercentage.setVisibility(View.VISIBLE);
      resultPercentage.setText(surveyUtil.getPercentageStyleStr(item.getNump()));
    }

    resultPnum.setText(new DecimalFormat(",###").format(item.getNum()) + "票");
    resultAnswerItem.setText(item.getTitle());

    View surveyListDivider = view.findViewById(R.id.survey_list_divider);
    if (isShowListDivider && !(groupPosition == getGroupCount() - 1)) {
      surveyListDivider.setVisibility(View.GONE);
      resultIconPosition = 0;
    } else {
      surveyListDivider.setVisibility(View.VISIBLE);
    }

    return view;
  }

  private View addMultipleItemView(View view, SurveyItem item, int groupPosition,
      boolean isShowListDivider) {
//    ViewSwitcher vurveyState = (ViewSwitcher) view.findViewById(R.id.survey_state);
//    vurveyState.setDisplayedChild(0);
    view.findViewById(R.id.survey_answer_item).setVisibility(View.VISIBLE);
    view.findViewById(R.id.survey_result_item).setVisibility(View.GONE);
    
    View surveyListDivider = view.findViewById(R.id.survey_list_divider);
    if (isShowListDivider && !(groupPosition == getGroupCount() - 1)) {
      surveyListDivider.setVisibility(View.GONE);
    } else {
      surveyListDivider.setVisibility(View.VISIBLE);
    }
    UserChoiceBean userChoiceBean = new UserChoiceBean();
    userChoiceBean.setPosition(groupPosition);
    userChoiceBean.setItemid(item.getItemid());
    view.setTag(userChoiceBean);
    ImageView radioIcon = (ImageView) view.findViewById(R.id.survey_radio_icon);
    ((TextView) view.findViewById(R.id.answer_item)).setText(item.getTitle());
    if (items.get(groupPosition).getUserChoice()
        .contains("&sur[" + items.get(groupPosition).getQuestionid() + "][]=" + item.getItemid())) {
      radioIcon.setImageResource(R.drawable.multiple_check_press);
    } else {
      radioIcon.setImageResource(R.drawable.multiple_check_unpress);
    }
    view.setOnClickListener(new View.OnClickListener() {

      @Override
      public void onClick(View v) {
        UserChoiceBean userChoiceBean = (UserChoiceBean) v.getTag();
        SurveyResult userChoice = (items.get(userChoiceBean.getPosition()));
        if (((ImageView) v.findViewById(R.id.survey_radio_icon))
            .getDrawable()
            .getConstantState()
            .equals(
                ctx.getResources().getDrawable(R.drawable.multiple_check_press).getConstantState())) {
          userChoice.removeChoice(userChoiceBean.getItemid());
        } else {
          userChoice.addChoice(userChoiceBean.getItemid());
        }
        notifyDataSetChanged();
      }
    });
    return view;
  }

  private View addSingleItemView(View view, SurveyItem item, int groupPosition,
      boolean isShowListDivider) {
//    ViewSwitcher vurveyState = (ViewSwitcher) view.findViewById(R.id.survey_state);
//    vurveyState.setDisplayedChild(0);
    view.findViewById(R.id.survey_answer_item).setVisibility(View.VISIBLE);
    view.findViewById(R.id.survey_result_item).setVisibility(View.GONE);
    
    View surveyListDivider = view.findViewById(R.id.survey_list_divider);
    if (isShowListDivider && !(groupPosition == getGroupCount() - 1)) {
      surveyListDivider.setVisibility(View.GONE);
    } else {
      surveyListDivider.setVisibility(View.VISIBLE);
    }
    UserChoiceBean userChoiceBean = new UserChoiceBean();
    userChoiceBean.setPosition(groupPosition);
    userChoiceBean.setItemid(item.getItemid());
    view.setTag(userChoiceBean);
    ImageView radioIcon = (ImageView) view.findViewById(R.id.survey_radio_icon);
    ((TextView) view.findViewById(R.id.answer_item)).setText(item.getTitle());
    if (items.get(groupPosition).getUserChoice()
        .contains("&sur[" + items.get(groupPosition).getQuestionid() + "][]=" + item.getItemid())) {
      radioIcon.setImageResource(R.drawable.single_check_press);
    } else {
      radioIcon.setImageResource(R.drawable.single_check_unpress);
    }
    view.setOnClickListener(new View.OnClickListener() {

      @Override
      public void onClick(View v) {
        UserChoiceBean userChoiceBean = (UserChoiceBean) v.getTag();
        ArrayList<String> userChoice = (items.get(userChoiceBean.getPosition())).getUserChoice();
        (items.get(userChoiceBean.getPosition())).removeAllChoice();
        if (userChoice.size() == 0) {
          (items.get(userChoiceBean.getPosition())).addChoice(userChoiceBean.getItemid());
        }
        notifyDataSetChanged();
      }
    });
    return view;
  }

  @Override
  public int getChildrenCount(int groupPosition) {
    return items.get(groupPosition).getResultArray().size();
  }

  @Override
  public Object getGroup(int groupPosition) {
    return items.get(groupPosition);
  }

  @Override
  public int getGroupCount() {
    return items.size();
  }

  @Override
  public long getGroupId(int groupPosition) {
    return groupPosition;
  }

  @Override
  public View getGroupView(int groupPosition, boolean isExpanded, View convertView, ViewGroup parent) {
    if (convertView == null) {
      convertView = surveyUtil.getInflater().inflate(layout.survey_list_title_item, null);
    }
    TextView surveyListTitle = (TextView) convertView.findViewById(R.id.survey_list_title_tv);
    surveyListTitle.setText(items.get(groupPosition).getQuestion());
    
    if (items.get(groupPosition).isChoice()) {
      convertView.setBackgroundResource(R.drawable.survey_list_title_normal);
    } else {
      convertView.setBackgroundResource(R.drawable.survey_list_title_unchoice);
    }
    return convertView;
  }

  private String getSendSurveyUrl() {
    StringBuffer url = new StringBuffer(Config.SURVEY_SEND_URL + id);
    for (int i = 0; i < getGroupCount(); i++) {
      ArrayList<String> choices = items.get(i).getUserChoice();
      if (choices.size() == 0) {
        surveyUtil.getFunctionButtonWindow().showWindowControl(null, "第"+(i+1)+"题未选");
        items.get(i).setChoice(false);
        notifyDataSetChanged();
        lv.setSelectedGroup(i);
        lv.clearFocus();
        return null;
      } else {
        items.get(i).setChoice(true);
        for (String choice : choices) {
          url.append(choice);
        }
      }

    }
    return url.toString();
  }

  private void addCommitBut(View convertView) {
    //提交按钮模块
    View bottomView = surveyUtil.getInflater().inflate(R.layout.survey_commit_button, null);
    TextView seeResultsBut = (TextView) bottomView.findViewById(R.id.survey_see_results_but);
    Button commitBut = (Button) bottomView.findViewById(R.id.survey_commit_but);
    if (RecordUtil.isRecorded(ctx, id, RecordUtil.SURVEY)) {
      bottomView.setVisibility(View.GONE);
    } else {
      bottomView.setVisibility(View.VISIBLE);
    }
    if (investigated) {
      seeResultsBut.setText(R.string.survey_join);
      commitBut.setVisibility(View.GONE);
    } else {
      seeResultsBut.setText(R.string.survey_see_results );
      commitBut.setVisibility(View.VISIBLE);
    }
    ((ViewGroup) convertView).addView(bottomView);
    commitBut.setOnClickListener(new View.OnClickListener() {

      private WindowPrompt windowPrompt;

	@Override
      public void onClick(View v) {
        if (!NetworkState.isActiveNetworkConnected(ctx)) {
        	if(windowPrompt == null) {
        		windowPrompt =WindowPrompt.getInstance(ctx);
        	}
        	windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
          return;
        }
        String url = getSendSurveyUrl();
        if (url == null) {
          return;
        }
    	StatisticUtil.addRecord(ctx
    			, StatisticUtil.StatisticRecordAction.action,"$type=" + StatisticUtil.StatisticPageType.survey);
        IfengNewsApp.getBeanLoader().startLoading(
            new LoadContext<String, LoadListener<SurveyHttpResult>, SurveyHttpResult>(ParamsManager.addParams(ctx, url),
                new LoadListener<SurveyHttpResult>() {

                  @Override
                  public void postExecut(LoadContext<?, ?, SurveyHttpResult> context) {}

                  @Override
                  public void loadComplete(LoadContext<?, ?, SurveyHttpResult> context) {
                    if (1 == context.getResult().getIfsuccess()) {
                      surveyUtil.getFunctionButtonWindow().showWindowControl(null, "提交成功");
                      //重置票数、百分比
                      for (SurveyResult surveyResult : items) {
                        surveyResult.resetResultArray();
                      }
                      //设置状态
                      RecordUtil.record(ctx, id, RecordUtil.SURVEY);
                      investigated = true;
                      ((SurveyActivity)ctx).updateJoinNum();
                      notifyDataSetChanged();
                    } else {
                      surveyUtil.getFunctionButtonWindow().showWindowControl(null, "提交失败");
                    }
                  }

                  @Override
                  public void loadFail(LoadContext<?, ?, SurveyHttpResult> context) {
                    surveyUtil.getFunctionButtonWindow().showWindowControl(null, "提交失败");
                  }
                }, String.class, Parsers.newSurveyHttpResultParser(), LoadContext.FLAG_HTTP_ONLY));
      }
    });
    seeResultsBut.setOnClickListener(new View.OnClickListener() {

      @Override
      public void onClick(View view) {
        // 背景归位
        for (int i = 0; i < getGroupCount(); i++) {
          items.get(i).setChoice(true);
        }
        if (investigated) {
          investigated = false;
        } else {
          investigated = true;
        }
        notifyDataSetChanged();
        lv.setSelection(0);
        lv.clearFocus();
      }
    });
  }


  @Override
  public boolean hasStableIds() {
    return false;
  }

  @Override
  public boolean isChildSelectable(int groupPosition, int childPosition) {
    return true;
  }


  public boolean isInvestigated() {
    return investigated;
  }

  public void setInvestigated(boolean investigated) {
    this.investigated = investigated;
  }


  class UserChoiceBean {
    private int position;
    private String itemid;

    public int getPosition() {
      return position;
    }

    public void setPosition(int position) {
      this.position = position;
    }

    public String getItemid() {
      return itemid;
    }

    public void setItemid(String itemid) {
      this.itemid = itemid;
    }
  }

}
