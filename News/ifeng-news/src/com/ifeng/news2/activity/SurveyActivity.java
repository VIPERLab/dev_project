package com.ifeng.news2.activity;

import java.util.ArrayList;

import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.ImageSpan;
import android.text.style.URLSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.ExpandableListView.OnGroupCollapseListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengLoadableActivity;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.adapter.SurveyAdapter;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.SurveyInfo;
import com.ifeng.news2.bean.SurveyItem;
import com.ifeng.news2.bean.SurveyResult;
import com.ifeng.news2.bean.SurveyUnit;
import com.ifeng.news2.share.ShareAlertBig;
import com.ifeng.news2.share.WXHandler;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.DateUtil;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.RecordUtil;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.widget.IfengBottomTitleTabbar;
import com.ifeng.news2.widget.IfengExpandableListView;
import com.ifeng.news2.widget.LoadableViewWithFlingDetector;
import com.ifeng.news2.widget.PageListViewWithHeader.ListViewListener;
import com.ifeng.share.util.NetworkState;
import com.qad.annotation.InjectExtras;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.StateAble;
import com.qad.util.OnFlingListener;

/**
 * @author liu_xiaoliang
 * 调查单页 
 */
public class SurveyActivity extends IfengLoadableActivity<SurveyUnit> implements ListViewListener,OnFlingListener {


  private View headView;
  private View topModule;

  private ImageView back;
  private ImageView share;

  private TextView title;
  private TextView timeState;
  private TextView surveyIntrod;

  @InjectExtras(name = "id")
  private String surveyId = null;
  @InjectExtras(name = ConstantManager.THUMBNAIL_URL)
  private String shareThumbnail = null;
  @InjectExtras(name = ConstantManager.EXTRA_CHANNEL, optional = true)
  private Channel channel = null;
  private String preDocumentId = "";

  private boolean isLoadSuccessful = false;

  private SurveyUnit unit;
  private SurveyAdapter adapter;
  private LayoutInflater inflater;
  private IfengExpandableListView list;
  private IfengBottomTitleTabbar ifengBottom;
  private ArrayList<SurveyResult> surveyResults = new ArrayList<SurveyResult>();
  private LoadableViewWithFlingDetector wrapper;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    getIntentData();
    setContentView();
    startLoading();
  }


  private void getIntentData() {
	// TODO Auto-generated method stub
	preDocumentId = getIntent().getStringExtra(ConstantManager.EXTRA_CURRENT_DETAIL_DOCUMENTID);
}


  private void setContentView(){
    setContentView(layout.survey_layout);
    findViewById();

    LinearLayout historyWrapper = (LinearLayout) findViewById(R.id.wrapper);
    LayoutParams params = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
    list = new IfengExpandableListView(this);
    list.setGroupIndicator(null);
    list.setLayoutParams(params);
    list.setOnFlingListener(this);
    list.addHeaderView(headView);
    adapter = new SurveyAdapter(this, list, surveyId, surveyResults);
    list.setAdapter(adapter);
    list.setOnGroupCollapseListener(new OnGroupCollapseListener() {

      @Override
      public void onGroupCollapse(int groupPosition) {
        list.expandGroup(groupPosition);
      }
    });
    list.setDivider(null);
    wrapper = new LoadableViewWithFlingDetector(this, list);
    wrapper.setOnRetryListener(this);       
    wrapper.setOnFlingListener(this);
    historyWrapper.addView(wrapper, params);
  }

  private void findViewById(){
    ifengBottom = (IfengBottomTitleTabbar) findViewById(R.id.ifeng_bottom_tabbar);

    back = (ImageView)ifengBottom.findViewById(R.id.back);
    share = (ImageView)ifengBottom.findViewById(R.id.more);

    inflater = LayoutInflater.from(this);
    headView = inflater.inflate(R.layout.survey_head_item, null);
    topModule = findViewById(R.id.top_module);
    title = (TextView) headView.findViewById(R.id.title);
    timeState = (TextView) headView.findViewById(R.id.time_state);
    surveyIntrod = (TextView) headView.findViewById(R.id.survey_introd);
  }

  public void startLoading() {
    super.startLoading();
    getLoader().startLoading(
      new LoadContext<String, LoadListener<SurveyUnit>, SurveyUnit>(
          ParamsManager.addParams(this, Config.SURVEY_GET_URL+surveyId),
          SurveyActivity.this,
          SurveyUnit.class,
          Parsers.newSurveyUnitParser(), false,
          LoadContext.FLAG_HTTP_FIRST, false));
  }

  @Override
  public void loadComplete(LoadContext<?, ?, SurveyUnit> context) {
    isLoadSuccessful = true;
    unit = (SurveyUnit) context.getResult();
    if ("1".equals(unit.getData().getSurveyinfo().getIsactive())) {
      if (RecordUtil.isRecorded(this, unit.getData().getSurveyinfo().getId(), RecordUtil.SURVEY)) {
        adapter.setInvestigated(true);
      } else {
        adapter.setInvestigated(false);
      }
    } else {
      RecordUtil.record(this, unit.getData().getSurveyinfo().getId(), RecordUtil.SURVEY);
      adapter.setInvestigated(true);
    }
    surveyResults.clear();
    //格式化百分比
    unit.formatAllPnum();
    surveyResults.addAll(unit.getData().getResult());
    renderHead(unit);
    super.loadComplete(context);
    beginStatistic(surveyId);
    //展开所有项
    for (int position = 1; position <= adapter.getGroupCount(); position++)
      list.expandGroup(position - 1);
  }

  @Override
  public void postExecut(LoadContext<?, ?, SurveyUnit> context) {
    SurveyUnit unit = context.getResult();
    if (null == unit || 
        -1 == unit.getIfsuccess() || 
        null == unit.getData() || 
        null == unit.getData().getResult() || 
        unit.getData().getResult().size() == 0) {
      context.setResult(null);
      return;
    }
    super.postExecut(context);
  }

  public void renderHead(SurveyUnit data) {

    SurveyInfo surveyInfo = data.getData().getSurveyinfo();
    if (null == surveyInfo) {
      topModule.setVisibility(View.GONE);
    } else {

      if (TextUtils.isEmpty(surveyInfo.getTitle())) {
        title.setVisibility(View.GONE);
      } else {
        title.setText(surveyInfo.getTitle());
        title.setVisibility(View.VISIBLE);
      }
      StringBuffer buffer = new StringBuffer();
      if (!TextUtils.isEmpty(surveyInfo.getStarttime())) {
        buffer.append(DateUtil.getTimeOfList(surveyInfo.getStarttime())+" ");
      } 

      if ("1".equals(surveyInfo.getIsactive())) {
        buffer.append("进行中  ");
      } else {
        buffer.append("已结束  ");
      }

      if (TextUtils.isEmpty(surveyInfo.getPnum())) {
        buffer.append("0人参与");
      } else {
        buffer.append(surveyInfo.getPnum()+"人参与");
      }

      timeState.setText(buffer.toString());


      if (TextUtils.isEmpty(surveyInfo.getUrl())) {
        if (TextUtils.isEmpty(surveyInfo.getLeadtxt())) {
          surveyIntrod.setVisibility(View.GONE);
        } else {
          surveyIntrod.setText(surveyInfo.getLeadtxt());
          surveyIntrod.setVisibility(View.VISIBLE);
        }
      } else {
        boolean hasIntrod = true;
        if (TextUtils.isEmpty(surveyInfo.getLeadtxt())) {
          hasIntrod = false;
        } 
        int aid = 0;
        try {
          aid = Integer.parseInt(Uri.parse(surveyInfo.getUrl())
            .getQueryParameter("aid"));
        } catch (Exception e) {
          aid = 0;
        } finally {
          if (aid != 0) {
            //插入图片将超链接去除下划线并改变颜色，超链接相应正文内链
            NoLineClickSpan clickSpan = new NoLineClickSpan();
            SpannableString sp = new SpannableString(surveyInfo.getLeadtxt()+" 新闻背景"); 
            Drawable d = getResources().getDrawable(R.drawable.survey_news_back_icon);  
            d.setBounds(0, 0, d.getIntrinsicWidth(), d.getIntrinsicHeight());  
            ImageSpan span = new ImageSpan(d, ImageSpan.ALIGN_BASELINE);  
            int startPosition = hasIntrod ? surveyInfo.getLeadtxt().length() : 1;
            int endPosition = hasIntrod ? surveyInfo.getLeadtxt().length() + 5 : 5;
            sp.setSpan(span, hasIntrod ? surveyInfo.getLeadtxt().length() : 0, hasIntrod ? surveyInfo.getLeadtxt().length() + 1 : 1, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);  
            if (aid != 0) sp.setSpan(new URLSpan("comifengnews2app://doc/"+aid+"?opentype=out"), startPosition, endPosition, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            sp.setSpan(clickSpan, startPosition, endPosition, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
            sp.setSpan(new ForegroundColorSpan(getResources().getColor(R.color.survey_news_back_color)), startPosition, endPosition, Spannable.SPAN_EXCLUSIVE_INCLUSIVE); 
            surveyIntrod.setText(sp);
            surveyIntrod.setMovementMethod(LinkMovementMethod.getInstance());   
            surveyIntrod.setVisibility(View.VISIBLE);
          } else {
            if (TextUtils.isEmpty(surveyInfo.getLeadtxt())) {
              surveyIntrod.setVisibility(View.GONE);
            } else {
              surveyIntrod.setText(surveyInfo.getLeadtxt());
              surveyIntrod.setVisibility(View.VISIBLE);
            }
          }
        }
      }      
    }

  }

  private class NoLineClickSpan extends ClickableSpan {

    public NoLineClickSpan() {
      super();
    }

    @Override
    public void updateDrawState(TextPaint ds) {
      ds.setColor(ds.linkColor);
      ds.setUnderlineText(false); //去掉下划线
    }

    @Override
    public void onClick(View widget) {
      //TODO 点击跳转
    }
  }

  @Override
  public void onFling(int flingState) {
    if (flingState == OnFlingListener.FLING_RIGHT) {
      onBackPressed();
    }
  }

  @Override
  public Class<SurveyUnit> getGenericType() {
    return SurveyUnit.class;
  }

  @Override
  public StateAble getStateAble() {
    return wrapper;
  }

  @Override
  public void onRefresh() {
  }

  public void buttonOnClick(View view) {
    if (view == back) {
      onBackPressed();
    } else if (view == share) {
      onShareContent();
    }
  }

  private void onShareContent(){
    if (isLoadSuccessful) {
      if (NetworkState.isActiveNetworkConnected(this)) {
        onShare();
      } else {
    	  windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
      }
    } else {
      showMessage("此功能不可用");
    }
  }

  //分享
  private void onShare(){
    ShareAlertBig alert = new ShareAlertBig(me,
      new WXHandler(this), getShareUrl(), getShareTitle(), getShareContent(),
      getShareImage(), getDocumentId(), StatisticUtil.StatisticPageType.vote);
    alert.show(me);
  }

  private String getShareUrl(){
    SurveyInfo surveyInfo = unit.getData().getSurveyinfo();
    if (null != surveyInfo) {
      if ("1".equals(surveyInfo.getIsactive())) {
        return  Config.SURVEY_SHARE_DETAIL_URL+surveyId;
      } else {
        return  Config.SURVEY_SHARE_RESULT_URL+surveyId; 
      }
    }
    return  Config.SURVEY_SHARE_RESULT_URL+surveyId; 
  }

  private String getShareTitle(){
    SurveyItem surveyItem = unit.getData().getTopicHighestItem();
    return surveyItem.getNump()+"%的人选择\""+surveyItem.getTitle()+"\"。";
  }

  private String getShareContent(){
    return "凤凰民调："+unit.getData().getSurveyinfo().getTitle();
  }

  private ArrayList<String> getShareImage(){
    ArrayList<String> shareImage = new ArrayList<String>();
    if (!TextUtils.isEmpty(shareThumbnail)) {
      shareImage.add(shareThumbnail);
    }  
    return shareImage;
  }

  private String getDocumentId(){
    return null; 
  }
  
  @Override
	protected void onResume() {
		// TODO Auto-generated method stub
	  StatisticUtil.doc_id = surveyId ;
	  StatisticUtil.type = StatisticUtil.StatisticPageType.other.toString() ; 
		super.onResume();
	}

  @Override
  public void onBackPressed() {
    super.onBackPressed();
    StatisticUtil.isBack = true ; 
    //给正文反馈本调查是否调查过
    Intent intent = new Intent();
    setResult(RESULT_OK, intent);
    finish();
    overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
  }

  public void updateJoinNum(){
    SurveyInfo surveyInfo = unit.getData().getSurveyinfo();
    if (null == surveyInfo) {
      return;
    } 
    int count = 0;
    try {
      count = Integer.parseInt(surveyInfo.getPnum()) + 1;
    } catch (Exception e) {
      count = 1;
    }
    surveyInfo.setPnum(count+"");

    StringBuffer buffer = new StringBuffer();
    if (!TextUtils.isEmpty(surveyInfo.getStarttime())) {
      buffer.append(DateUtil.getTimeOfList(surveyInfo.getStarttime())+" ");
    } 

    if ("1".equals(surveyInfo.getIsactive())) {
      buffer.append("进行中  ");
    } else {
      buffer.append("已结束  ");
    }
    buffer.append(count+"人参与");
    timeState.setText(buffer.toString());
  }
  
  private void beginStatistic(String documentId) {
		// TODO Auto-generated method stub
	  // 从推送进入文章的统计
	    if (ConstantManager.ACTION_PUSH.equals(getIntent().getAction())) {
	      // 文章打开统计
	      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	          "id=" + documentId + "$ref=push$type=" + StatisticUtil.StatisticPageType.other);

	      // 推送打开统计，推送打开需要去掉系统标识 imcp
	      String docId = documentId;
	      if (documentId.startsWith("imcp_")) {
	        docId = documentId.split("_")[1];
	      }
	      StatisticUtil.addRecord(getApplicationContext(),
	          StatisticUtil.StatisticRecordAction.openpush, "aid=" + docId + "$type=n");
	    }
	    // 从新闻列表进入文章的推送统计
	    else if (ConstantManager.ACTION_FROM_APP.equals(getIntent().getAction())
	        || ConstantManager.ACTION_FROM_SLIDE_URL.equals(getIntent().getAction())) {
	      if (channel != null) {
	        // 文章打开统计
	       if (!channel.equals(Channel.NULL)) {
	          StatisticUtil.addRecord(getApplicationContext(),
	              StatisticUtil.StatisticRecordAction.page,
	              "id=" + documentId + "$ref=" + channel.getStatistic() + "$type="
	                  + StatisticUtil.StatisticPageType.other);
	        } else {
	          // fix bug #18093 推送打开相关文章，来源为空。
	          StatisticUtil.addRecord(getApplicationContext(),
	              StatisticUtil.StatisticRecordAction.page, "id=" + documentId + "$ref=push$type="
	                  + StatisticUtil.StatisticPageType.other);
	        }
	      }
	      // 凤凰快讯进入文章统计
	    } else if (ConstantManager.ACTION_PUSH_LIST.equals(getIntent().getAction())) {
	      // 推送打开统计，推送打开需要去掉系统标识 imcp
	      // 文章打开
	      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	          "id=" + documentId + "$ref=pushlist$type=" + StatisticUtil.StatisticPageType.article);
	    }
	    // json专题和web专题进入文章的PA统计
	    else if (ConstantManager.ACTION_BY_AID.equals(getIntent().getAction())
	        ) {
	      if (!TextUtils.isEmpty(getIntent().getStringExtra(ConstantManager.EXTRA_GALAGERY))) {
	        StatisticUtil.addRecord(
	            getApplicationContext(),
	            StatisticUtil.StatisticRecordAction.page,
	            "id=" + documentId + "$ref=topic_"
	                + getIntent().getStringExtra(ConstantManager.EXTRA_GALAGERY) + "$type="
	                + StatisticUtil.StatisticPageType.other);
	      }
	    }
	    // 头条焦点图进入文章的PA统计
	    else if (ConstantManager.ACTION_FROM_HEAD_IMAGE.equals(getIntent().getAction())) {
	      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	          "id=" + documentId + "$ref=sy$type=" + StatisticUtil.StatisticPageType.article+"$tag=t3");
	    } else if (Intent.ACTION_VIEW.equals(getIntent().getAction())) {
	      if (getIntent().hasExtra("from_ifeng_news")) {
	        // 推送文章内链
	        StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	            "id=" + documentId +  "$ref="+preDocumentId+"$type=" + StatisticUtil.StatisticPageType.article);
	      } else if (getIntent().hasExtra(ConstantManager.EXTRA_CHANNEL)) {
	        // 普通文章内链
	        StatisticUtil.addRecord(
	            getApplicationContext(),
	            StatisticUtil.StatisticRecordAction.page,
	            "id="+ documentId+ "$ref="
	                + preDocumentId + "$type=" + StatisticUtil.StatisticPageType.other);
	      } else {
	        // 从分享渠道打开文章
	        StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	            "id=" + documentId + "$ref=outside$type=" + StatisticUtil.StatisticPageType.article);
	      }
	      // 从widget进入文章统计
	    } else if (ConstantManager.ACTION_WIDGET.equals(getIntent().getAction())) {
	      // 文章打开统计
	      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	          "id=" + documentId + "$ref=desktop$type=" + StatisticUtil.StatisticPageType.other);
      // 从正文页、专题进入文章统计
 	    } else if (ConstantManager.ACTION_FROM_ARTICAL.equals(getIntent().getAction()) || 
 	    		ConstantManager.ACTION_FROM_PLOTATLAST.equals(getIntent().getAction()) || 
 	    		ConstantManager.ACTION_FROM_TOPIC2.equals(getIntent().getAction())) {
 	      // 文章打开统计
 	    	StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
 	  	          "id=" + documentId + "$ref="+preDocumentId+"$type=" + StatisticUtil.StatisticPageType.other);
	    } else {
	      // 默认算作从首页打开
	      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	          "id=" + documentId + "$ref=sy$type=" + StatisticUtil.StatisticPageType.other);
	    }
	}

}
