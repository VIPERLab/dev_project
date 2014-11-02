package com.ifeng.news2.activity;

import java.util.ArrayList;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;

import com.handmark.pulltorefresh.library.internal.IfengScrollView;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengLoadableActivity;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.fragment.NewsMasterFragmentActivity;
import com.ifeng.news2.plot_module.bean.PlotTopicBodyItem;
import com.ifeng.news2.plot_module.bean.PlotTopicUnit;
import com.ifeng.news2.share.ShareAlertBig;
import com.ifeng.news2.share.WXHandler;
import com.ifeng.news2.util.CommentsManager;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.FunctionButtonWindow;
import com.ifeng.news2.util.FunctionButtonWindow.FunctionButtonInterface;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.PlotModuleViewFactory;
import com.ifeng.news2.util.RecordUtil;
import com.ifeng.news2.util.RestartManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticPageType;
import com.ifeng.news2.util.StatisticUtil.StatisticRecordAction;
import com.ifeng.news2.widget.IfengBottom;
import com.ifeng.news2.widget.IfengBottomTitleTabbar;
import com.ifeng.news2.widget.LoadableViewWrapper;
import com.ifeng.share.util.NetworkState;
import com.qad.annotation.InjectExtras;
import com.qad.loader.LoadContext;
import com.qad.loader.RetryListener;
import com.qad.loader.StateAble;
import com.qad.net.HttpGetListener;
import com.qad.util.OnFlingListener;
import com.umeng.analytics.MobclickAgent;


/**
 * @author liu_xiaoliang
 * 策划专题
 */
public class PlotTopicModuleActivity extends
IfengLoadableActivity<PlotTopicUnit> implements FunctionButtonInterface, OnFlingListener {

  public static String topicId = null ; //专题ID

  @InjectExtras(name = "id")
  String topicDetailUrl;          // 内容URL
  private long startTime = 0;
  
  private String wwwUrl = null;   //被评论ID
  private String title = null;    //专题标题
  private String thumbnail = null;//专题缩略图
  private String description = null ; //导读描述信息,用于分享
  
  private boolean loadSuccessful = false;  //标示专题是否加载出来
  private boolean isFirstResume = true;

  private View content;
  private EditText commentEditText;
  private IfengScrollView mScrollView;
  private LayoutInflater inflater;
  private LoadableViewWrapper wrapper;
  private ProgressDialog loadingDialog;
  private CommentsManager commentsManager;
  private PlotTopicUnit plotTopicUnit;
  private IfengBottomTitleTabbar ifengTabbar;
  private FunctionButtonWindow functionButtonWindow;
  private View detailCommentModule, submitCommentButton, closeCommmentButton, surveyView;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    init();
    //设置wrapper
    setWrapper();

    setContentView(wrapper);
	//获取intent数据
	getIntentData();
    startLoading();
  }
  
  private void getIntentData(){
	  Intent intent = getIntent();
	  thumbnail = intent.getStringExtra(ConstantManager.THUMBNAIL_URL);
  }

  private void init(){
    /**
     * 将窗体背景设为白色，解决专题中跟帖发布时输入法收回后出现黑块的问题。bug ID #15205
     */
    getWindow().setBackgroundDrawableResource(R.drawable.white_color);

    findViewById();
    mScrollView.setOnFlingListener(this);
    commentsManager = new CommentsManager();
    functionButtonWindow = new FunctionButtonWindow(this);
    functionButtonWindow.setFunctionButtonInterface(this);
    //设置底部导航栏为MODE_JSON_TOPIC_DAY模式
    ifengTabbar.setMode(IfengBottomTitleTabbar.MODE_JSON_TOPIC_DAY);
    commentEditText.setOnFocusChangeListener(new View.OnFocusChangeListener() {

      @Override
      public void onFocusChange(View v, boolean hasFocus) {
        if (!hasFocus) {
          updateEditCommentModule(false);
        }
      }
    });
    
    commentEditText.addTextChangedListener(new TextWatcher() {

      @Override
      public void onTextChanged(CharSequence s, int start, int before,
                                int count) {
      }

      @Override
      public void beforeTextChanged(CharSequence s, int start, int count,
                                    int after) {

      }

      @Override
      public void afterTextChanged(Editable s) {
        if (Config.SEND_COMMENT_WORDS_LIMIT < s.length()) {
          s.delete(Config.SEND_COMMENT_WORDS_LIMIT, s.length());
        }
      }
    });
  }

  private void findViewById(){
    inflater = LayoutInflater.from(this);
    content = (View) inflater.inflate(R.layout.plot_topic_detail_module, null);
    detailCommentModule = content.findViewById(R.id.detail_comment_module);
    ifengTabbar = (IfengBottomTitleTabbar) content.findViewById(R.id.detail_tabbar);
    commentEditText = (EditText) content.findViewById(R.id.detail_comment_editText);
    submitCommentButton = content.findViewById(R.id.detail_submit_comment_button);
    closeCommmentButton = content.findViewById(R.id.detail_close_commment_button);
    mScrollView = (IfengScrollView) content.findViewById(R.id.topic_detail_scrollview);
    detailCommentModule.setVisibility(View.GONE);
    commentEditText.setVisibility(View.GONE);

    // 发帖框加入“文明上网，遵守“七条底线””
    content.findViewById(R.id.policy_text).setOnClickListener(new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			updateEditCommentModule(false);
			
			Intent intent = new Intent();
			intent.setAction(Intent.ACTION_VIEW);
			intent.setData(Uri.parse("comifengnews2app://doc/68983945"));
			PlotTopicModuleActivity.this.startActivity(intent);
			//增加跳转动画
			overridePendingTransition(R.anim.in_from_right,
					R.anim.out_to_left);
		}
	});
  }

  private View getRetryView(){
    // Fix bug #14363 -
    // 【封面故事】断网时，打开挂json专题的封面故事，页面没有返回功能。
    // build the retry view
    View retryView = inflater.inflate(R.layout.load_fail_with_bottom_bar,
      null);
    ((IfengBottom) retryView.findViewById(R.id.ifeng_bottom_4_load_fail))
    .getBackButton().setOnClickListener(new OnClickListener() {

      @Override
      public void onClick(View v) {
        onBackPressed();
      }
    });
    return retryView;
  }

  private void setWrapper(){
    wrapper = new LoadableViewWrapper(this, content, getRetryView(), null);
    wrapper.setOnRetryListener(new RetryListener() {

      @Override
      public void onRetry(View arg0) {
        startLoading();
      }
    });
    wrapper.setBackgroundResource(R.drawable.channellist_selector);
  }

  public void buttonOnClick(View view) {
    if (view == ifengTabbar.findViewById(R.id.back)) {
      //关闭
      onBackPressed();
    } else if (view == ifengTabbar.findViewById(R.id.write_comment)) {
      if (NetworkState.isActiveNetworkConnected(this)) {
        // 文章加载成功
        if (loadSuccessful) {        	
			updateEditCommentModule(true);
        }         
        else
          showMessage("此功能不可用");

      } else {
        showMessage(R.string.not_network_message);
      }
    } else if (view == submitCommentButton) {
      //发送评论
      String commentContent = commentEditText.getText().toString().trim();
      if (TextUtils.isEmpty(commentContent)) {
      //  showMessage("评论不能为空");
    	  windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.toast_edit_empty_title, R.string.toast_edit_empty_content);
      } else {
        sendComment(commentContent);
        updateEditCommentModule(false);
      }
    } else if (view == closeCommmentButton) {
      //关闭评论模块
      updateEditCommentModule(false);
    }else if (view == ifengTabbar.findViewById(R.id.more)) {
		/*ArrayList<String> functionBut = new ArrayList<String>();
		functionBut.add("分享");
		functionButtonWindow.showMoreFunctionButtons(view, functionBut,
				FunctionButtonWindow.TYPE_FUNCTION_BUTTON_WHITE);*/
    	showShareView();
	}
  }
  
  /**
	 * 分享
	 */
	private void onShare() {
		// TODO Auto-generated method stub
		ShareAlertBig alert = new ShareAlertBig(me,
				new WXHandler(this), getShareUrl(), getShareTitle(), getShareContent(),
				getShareImage(), getDocumentId(), StatisticUtil.StatisticPageType.topic);
		alert.show(me);
	}
	
	/**
	 * 简介不为空，去简介作为分享内容，否则取标题
	 * 
	 * @return
	 */
	private String getShareContent() {
		if(TextUtils.isEmpty(description)){
			return getShareTitle();
		}else{
			return description.length() > Config.SHARE_MAX_LENGTH ? 
					description.substring(0, Config.SHARE_MAX_LENGTH) +"...": description;
		}
	}
	
	private String getShareTitle(){
		return plotTopicUnit.getContent().getTitle();
	}
	private String getShareUrl(){
		return plotTopicUnit.getContent().getShareurl();
	}
	private String getDocumentId(){
		return plotTopicUnit.getMeta().getDocumentId();
	}
	private ArrayList<String> getShareImage(){
		ArrayList<String> thumbnails = new ArrayList<String>();
		if(!TextUtils.isEmpty(thumbnail))
			thumbnails.add(thumbnail);
		return thumbnails;
	}

  public void sendComment(String commentContent) {
	  //回复功能统计
	  StatisticUtil.addRecord(this, StatisticRecordAction.action, "type="+StatisticPageType.follow);
    if (Config.SEND_COMMENT_TIMES.size() >= 6) {
      if (System.currentTimeMillis() - Config.SEND_COMMENT_TIMES.get(0) < 60000) {
        showMessage("发送评论太过频繁");
        return;
      } else {
        Config.SEND_COMMENT_TIMES.remove(0);
      }
    }   
    commentsManager.sendComment("0" , title, wwwUrl, commentContent, new HttpGetListener() {

      @Override
      public void loadHttpSuccess() {
        Config.SEND_COMMENT_TIMES.add(System.currentTimeMillis());
        loadingDialog.dismiss();
       // showMessage("发布成功，评论正在审核");
        windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.toast_publish_success_title, R.string.toast_publish_success_content);
      }

      @Override
      public void loadHttpFail() {
        Config.SEND_COMMENT_TIMES.add(System.currentTimeMillis());
        loadingDialog.dismiss();
     //   showMessage("发布失败");
        windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.toast_publish_fail_title, R.string.toast_publish_fail_content);
      }

      @Override
      public void preLoad() {
        loadingDialog = ProgressDialog.show(
          PlotTopicModuleActivity.this, "", "正在发布，请稍候", true,
          true, new OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
              dialog.dismiss();
            }
          });
      }
    });
  }

  public void updateEditCommentModule(boolean isShow) {
    if (isShow) {
      commentEditText.setVisibility(View.VISIBLE);
      ifengTabbar.setVisibility(View.GONE);
      detailCommentModule.setVisibility(View.VISIBLE);
    } else {
      commentEditText.setVisibility(View.GONE);
      ifengTabbar.setVisibility(View.VISIBLE);
      detailCommentModule.setVisibility(View.GONE);
    }
    showSoftInput(isShow);
  }

  public void showSoftInput(boolean isShow) {
    if (isShow) {
      commentEditText.requestFocus();
      InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
      imm.showSoftInput(commentEditText, 0);
    } else {
      ((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE))
      .hideSoftInputFromWindow(
        commentEditText.getWindowToken(),
        InputMethodManager.HIDE_NOT_ALWAYS);
    }
  }

  @Override
  public StateAble getStateAble() {
    return wrapper;
  }

  public void reLoading(final boolean ignoreExpired){

    if (TextUtils.isEmpty(topicDetailUrl)) {
      return;
    }

    loadSuccessful = false;
    //TODO 使用测试接口
    final String param = ParamsManager.addParams(topicDetailUrl); 
    final boolean expired = IfengNewsApp.getMixedCacheManager().isExpired(param);

    Handler handler = new Handler(Looper.getMainLooper());
    handler.postDelayed(new Runnable() {

      @Override
      public void run() {
        getLoader().startLoading(
          new LoadContext<String, Object, PlotTopicUnit>(param, PlotTopicModuleActivity.this,
              PlotTopicUnit.class, Parsers.newPlotTopicParser(),
              expired || ignoreExpired? LoadContext.FLAG_HTTP_FIRST :LoadContext.FLAG_CACHE_FIRST, false));
      }
      /*
       * 获取缓存会立刻就执行这是CPU占用率高，刷新会卡死一会，所以设置一个缓冲时间，300毫秒，先让scrollview回到正常高度，再执行load cache。
       * load http 不会引起占用率高的问题因此设置为0毫秒（即刻执行）
       * */
    }, expired ? 0 :300);


  }

  @Override
  public void startLoading() {
    super.startLoading();
    reLoading(false);
  }

  @Override
  public void loadComplete(LoadContext<?, ?, PlotTopicUnit> context) {
    super.loadComplete(context);
    // 策划专题打开统计
    if (ConstantManager.ACTION_FROM_TOPIC2.equals(getIntent().getAction())) {
		// 入口是专题
		if (!TextUtils.isEmpty(getIntent().getStringExtra(
				ConstantManager.EXTRA_GALAGERY))) {
			StatisticUtil.addRecord(getApplicationContext()
					, StatisticUtil.StatisticRecordAction.page
					, "id=" + topicId +"$ref=topic_"+getIntent().getStringExtra(
							ConstantManager.EXTRA_GALAGERY)+"$type=" + StatisticUtil.StatisticPageType.topic);
		}
	//
	}else if(ConstantManager.ACTION_WIDGET.equals(getIntent().getAction())) {
		// 文章打开统计
		StatisticUtil.addRecord(getApplicationContext()
				, StatisticUtil.StatisticRecordAction.page
				, "id="+topicId+"$ref=desktop$type=" + StatisticUtil.StatisticPageType.topic);
	}else {
		// 入口是列表
		Channel channel = (Channel) getIntent().getParcelableExtra(
				ConstantManager.EXTRA_CHANNEL);
		if (null != channel) {
			StatisticUtil.addRecord(getApplicationContext()
					, StatisticUtil.StatisticRecordAction.page
					, "id="+topicId+"$ref="+channel.getStatistic()+"$type=" + StatisticUtil.StatisticPageType.topic);
		}
	}
//    PlotTopicUnit topicDetailUnits = (PlotTopicUnit) (context
//        .getResult());
//    StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.TOPIC,
//      "topic_" + topicDetailUnits.getMeta().getDocumentId());
  }

  /* (non-Javadoc)
   * @see com.qad.loader.LoadableActivity#render(java.io.Serializable)
   */
  @Override
  public void render(PlotTopicUnit data) {
    //super.render(data);
    if (data == null || data.isNullDatas())
      return;
    plotTopicUnit = data;
    wwwUrl = plotTopicUnit.getContent().getWwwUrl();
    title = plotTopicUnit.getContent().getTitle();
    topicId = plotTopicUnit.getMeta().getDocumentId();
    boolean haveEpilogue = false;
    LinearLayout topicChildView = getViewContainer();
    LinearLayout topicChildCommentModule = getViewContainer();
    //塞入跟帖空壳，在TextModule中获取跟帖数据填充到跟帖空壳中
    PlotModuleViewFactory.setCommentModuleView(topicChildCommentModule);
    for (PlotTopicBodyItem plotTopicBodyItem : plotTopicUnit.getBody()) {
      if (null == plotTopicBodyItem) 
        continue;
      //更贴点击查看更多时用到title & wwwUrl
      if (PlotModuleViewFactory.PLOT_MODULE_TOPIC_TITLE.equals(plotTopicBodyItem.getType())) {
        //TODO 标题取的是哪个？
        plotTopicBodyItem.setDocumentId(topicId);
        plotTopicBodyItem.setCommentTitle(title);
        plotTopicBodyItem.setWwwUrl(wwwUrl);
        plotTopicBodyItem.setBgImage(thumbnail);
      }

      if(PlotModuleViewFactory.PLOT_MODULE_SUMMARY.equals(plotTopicBodyItem.getType())){
    	  description = plotTopicBodyItem.getIntro();
      }
      
      if (PlotModuleViewFactory.PLOT_MODULE_PEROROATION.equals(plotTopicBodyItem.getType())) {
        haveEpilogue = true;
      }
      
      View convertView = PlotModuleViewFactory.createView(this, plotTopicBodyItem);
      if (PlotModuleViewFactory.PLOT_MODULE_HTML.equals(plotTopicBodyItem
        .getType())){
        surveyView = convertView;
        plotTopicBodyItem.setThumbnail(thumbnail);
      }
      topicChildView.addView(convertView);
    }
    //防止后台修改将总结模块删除，导致客户端总结模块不显示
    if (!haveEpilogue) {
      PlotTopicBodyItem plotTopicBodyItem = new PlotTopicBodyItem();
      plotTopicBodyItem.setType(PlotModuleViewFactory.PLOT_MODULE_PEROROATION);
      topicChildView.addView(PlotModuleViewFactory.createView(this, plotTopicBodyItem));
    }
    
    topicChildView.addView(topicChildCommentModule);
    removeViewsRecursively(mScrollView);
    mScrollView.addView(topicChildView);
    loadSuccessful = true;
  }

  private LinearLayout getViewContainer(){
    LinearLayout linearLayout = new LinearLayout(this);
    LayoutParams layoutParams = new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
    linearLayout.setLayoutParams(layoutParams);
    linearLayout.setOrientation(LinearLayout.VERTICAL);
    linearLayout.setBackgroundColor(0xffffffff);
    return linearLayout;
  }

  // TODO: 只有ListModule被设置了tag导致不能回收，未来可以考虑只移除tag的引用即可
  // 另：AdapterView不支持removeAllViews操作，如果专题中未来要缴入AdapterView控件，这里需要修改，否则抛异常
  private void removeViewsRecursively(ViewGroup vg) {
    for (int x=0; x < vg.getChildCount(); x++) {
      if (vg.getChildAt(x) instanceof ViewGroup) {
        removeViewsRecursively((ViewGroup)vg.getChildAt(x));
      }	        
    }
    vg.removeAllViews();
  }

  @Override
  public Class<PlotTopicUnit> getGenericType() {
    return PlotTopicUnit.class;
  }

  @Override
  public boolean onKeyUp(int keyCode, KeyEvent event) {
    if (keyCode == KeyEvent.KEYCODE_BACK
        && View.VISIBLE == detailCommentModule.getVisibility()) {
      updateEditCommentModule(false);
      return true;
    }
    return super.onKeyUp(keyCode, event);
  }

  @Override
  public void onBackPressed() {
	StatisticUtil.isBack = true ;   
    //TODO   
  if (ConstantManager.isOutOfAppAction(getIntent().getAction()) || getIntent()
	        .getBooleanExtra(IntentUtil.EXTRA_REDIRECT_HOME, false)){
	        if (!NewsMasterFragmentActivity.isAppRunning) {
	            IntentUtil.redirectHome(this);
	        }
	    }     
    finish();
    overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
  }

  @Override
  protected void onBackgroundRunning() {
    startTime = System.currentTimeMillis();
    super.onBackgroundRunning();
  }

  @Override
  protected void onPause() {
    super.onPause();
    if (Config.ADD_UMENG_STAT)
      MobclickAgent.onPause(this);
  }

  @Override
  protected void onResume() {
	StatisticUtil.doc_id = topicId ; 
	StatisticUtil.type = StatisticUtil.StatisticPageType.topic.toString() ; 
    RestartManager.checkRestart(this, startTime, RestartManager.LOCK);
    mScrollView.setIntercept(false);
    super.onResume();
    if (Config.ADD_UMENG_STAT)
      MobclickAgent.onResume(this);
    if (isFirstResume) {
      isFirstResume = false;
      return;
    }
    /*
     * 参与调查后返回更新调查按钮，因结构限制，暂时采用这种方式
     * */
    try {
      if (null != surveyView) {
          Button joinSurveyBut = (Button)surveyView.findViewById(R.id.topic_join_survey_but);
          if (RecordUtil.isRecorded(this, (String)joinSurveyBut.getTag(), RecordUtil.SURVEY)) {
              joinSurveyBut.setText(R.string.survey_see_results);  
            } else {
              joinSurveyBut.setText(R.string.survey_join);
            }
        } 
    } catch (Exception e) {
    }
    
  }

  @Override
  protected void onDestroy() {
    removeViewsRecursively(mScrollView);
    topicId = null; // 重置documentId
    super.onDestroy();
  }

  @Override
  public void postExecut(LoadContext<?, ?, PlotTopicUnit> arg0) {
    if (arg0.getResult() == null || arg0.getResult().getBody() == null || arg0.getResult().getBody().size() == 0) {
      arg0.setResult(null);
      return;
    }
    super.postExecut(arg0);
  }

  @Override
  public void downloadPicture() {
    //TODO nothing
  }

  @Override
  public void showShareView() {
	  if(plotTopicUnit != null)
		  onShare();
    /*ShareAlertBig alert = new ShareAlertBig(this,
				new WXHandler(), getUrlforShare()"url", getArticleTitle()"你妹啊",
				getShareContent()"內容", null);
		alert.show(this);*/
  }

  @Override
  public void initCollectViewState() {
    //TODO 收藏状态
  }

  @Override
  public boolean onCollect() {
    //TODO 实现收藏
    return false;
  }

  @Override
  public int getBottomTabbarHeight() {
    return ifengTabbar.getHeight();
  }

  @Override
  public void onFling(int flingState) {
    mScrollView.setIntercept(true);
    if (flingState == OnFlingListener.FLING_RIGHT) {
      onBackPressed();
    } else {
      //左滑评论页？
      showComments();
    }
  }

  /**
   * 显示评论页
   */
  public void showComments() {

    if(wwwUrl != null && title != null && topicId != null){
    	 CommentsActivity.redirect2Comments(this,wwwUrl,null, 
 		        title, wwwUrl, topicId, true, true,thumbnail,getShareUrl(),null,ConstantManager.ACTION_FROM_PLOTATLAST);
    }
    //切换动画
    overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
  }
}
