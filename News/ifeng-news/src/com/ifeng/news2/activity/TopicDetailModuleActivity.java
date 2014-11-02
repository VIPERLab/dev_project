package com.ifeng.news2.activity;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.LinearLayout;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengLoadableActivity;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.adapter.TopicDetailAdapter;
import com.ifeng.news2.bean.AllComments;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.Comment;
import com.ifeng.news2.bean.CommentsData;
import com.ifeng.news2.bean.SurveyUnit;
import com.ifeng.news2.bean.TopicBody;
import com.ifeng.news2.bean.TopicDetailUnits;
import com.ifeng.news2.bean.TopicSubject;
import com.ifeng.news2.fragment.NewsMasterFragmentActivity;
import com.ifeng.news2.share.ShareAlertBig;
import com.ifeng.news2.share.WXHandler;
import com.ifeng.news2.util.CommentsManager;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.FunctionButtonWindow;
import com.ifeng.news2.util.FunctionButtonWindow.FunctionButtonInterface;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.RestartManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticPageType;
import com.ifeng.news2.util.StatisticUtil.StatisticRecordAction;
import com.ifeng.news2.util.TopicDetailUtil;
import com.ifeng.news2.vote.entity.VoteData;
import com.ifeng.news2.widget.ChannelList;
import com.ifeng.news2.widget.IfengBottom;
import com.ifeng.news2.widget.IfengBottomTitleTabbar;
import com.ifeng.news2.widget.LoadableViewWithFlingDetector;
import com.ifeng.news2.widget.PageListViewWithHeader.ListViewListener;
import com.ifeng.share.util.NetworkState;
import com.qad.annotation.InjectExtras;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.RetryListener;
import com.qad.loader.StateAble;
import com.qad.net.HttpGetListener;
import com.qad.util.OnFlingListener;
import com.qad.view.PageListView;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * 新版专题二级页面
 * 
 * @author pjw
 * 
 */
public class TopicDetailModuleActivity extends
IfengLoadableActivity<TopicDetailUnits> implements FunctionButtonInterface, OnFlingListener, ListViewListener {
	
    private final static int PULLTOREFRESH = 1;
    private final static int REFRESHCOMPLETE = 2;
	public final static String ACTION_VIEW = "action.com.ifeng.activity.TopicDetailModuleActivity.view";
	
	public static CommentsData commentsData = new CommentsData();
	public static SurveyUnit surveyUnit = null;
	public static VoteData voteData = null;
	public static String STYLE = "normal";
	
	@InjectExtras(name = "id")
	String topicDetailUrl;// 内容URL
	private long startTime = 0;
	private String wwwUrl = null; //被评论ID
	private String title = null;  //专题标题
	private String topicId = null ; //专题ID
	private String thumbnail = null; //专题列表缩略图
	
	private boolean loadSuccessful = false;  //标示专题是否加载出来
	private boolean isFirstResume = true;
	private boolean isFirstCreated = true;           //第一次创建出来
	private boolean isHaveCache = false;             //是否有有效缓存
	
	
	private String description = null ; //导读描述信息,用于分享
	private String shareUrl;
	private View content;
	private ChannelList list;
	private TopicDetailAdapter adapter;
	private EditText commentEditText;
	private LayoutInflater inflater;
	private LoadableViewWithFlingDetector wrapper;
	private ProgressDialog loadingDialog;
	private CommentsManager commentsManager;
	private TopicDetailUnits topicDetailUnits;
	private IfengBottomTitleTabbar ifengTabbar;
	private ArrayList<TopicSubject> topicSubjects = new ArrayList<TopicSubject>();
	private FunctionButtonWindow functionButtonWindow;
	private View detailCommentModule, submitCommentButton, closeCommmentButton;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		/**
		 * 将窗体背景设为白色，解决专题中跟帖发布时输入法收回后出现黑块的问题。bug ID #15205
		 */
		getWindow().setBackgroundDrawableResource(R.drawable.white_color);
		
		init();
		//设置wrapper
		setWrapper();
		setContentView(wrapper);
		//获取intent数据
		getIntentData();
		String param = ParamsManager.addParams(topicDetailUrl);
		isHaveCache = IfengNewsApp.getMixedCacheManager().isExpired(param) && IfengNewsApp.getMixedCacheManager().getCache(param) != null;
		startLoading();
	}

	private void getIntentData() {
		// TODO Auto-generated method stub
		Intent intent = getIntent();
		thumbnail = intent.getStringExtra(ConstantManager.THUMBNAIL_URL);
		if (Intent.ACTION_VIEW.equals(intent.getAction())) {
            Uri uri = getIntent().getData();
            topicDetailUrl = String.format(Config.TOPIC_URL,
                    uri.getLastPathSegment());
            IfengNewsApp.shouldRestart = false;
        }
		
		if (Intent.ACTION_VIEW.equals(getIntent().getAction())
				&& StatisticUtil.isValidStart(this)) {
			// 浠庡垎浜惎鍔ㄥ簲鐢�
			AppBaseActivity.startSource = ConstantManager.IN_FROM_OUTSIDE;
		}else if (ConstantManager.ACTION_WIDGET.equals(getIntent().getAction())){
			AppBaseActivity.startSource = ConstantManager.IN_FROM_WIDGET;
		}
	}

	private void init(){
		findViewById();
		adapter = new TopicDetailAdapter(this);
		adapter.setItems(topicSubjects);
		list.setAdapter(adapter);
		list.setDivider(null);
		list.setListViewListener(this);
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
		content = (View) inflater.inflate(R.layout.topic_detail_module, null);
		LinearLayout listHolder = (LinearLayout)content.findViewById(R.id.topic_listview);
		list = new ChannelList(this, null, PageListView.SINGLE_PAGE_MODE); 
		listHolder.addView(list);
		detailCommentModule = content.findViewById(R.id.detail_comment_module);
		ifengTabbar = (IfengBottomTitleTabbar) content.findViewById(R.id.detail_tabbar);
		commentEditText = (EditText) content.findViewById(R.id.detail_comment_editText);
		submitCommentButton = content.findViewById(R.id.detail_submit_comment_button);
		closeCommmentButton = content.findViewById(R.id.detail_close_commment_button);
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
				TopicDetailModuleActivity.this.startActivity(intent);
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
		wrapper = new LoadableViewWithFlingDetector(this, content, getRetryView(), null);
		wrapper.setOnRetryListener(new RetryListener() {

			@Override
			public void onRetry(View arg0) {
				startLoading();
			}
		});
		wrapper.setOnFlingListener(this);
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
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
			}
		} else if (view == submitCommentButton) {
			//发送评论
			String commentContent = commentEditText.getText().toString().trim();
			if (TextUtils.isEmpty(commentContent)) {
			//	showMessage("评论不能为空");
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.toast_edit_empty_title, R.string.toast_edit_empty_content);
			} else {
				sendComment(commentContent);
				updateEditCommentModule(false);
			}
		} else if (view == closeCommmentButton) {
			//关闭评论模块
			updateEditCommentModule(false);
		} else if (view == ifengTabbar.findViewById(R.id.more)) {
			showShareView();
//			ArrayList<String> functionBut = new ArrayList<String>();
//			functionBut.add("分享");
//			functionButtonWindow.showMoreFunctionButtons(view, functionBut,
//					FunctionButtonWindow.TYPE_FUNCTION_BUTTON_WHITE);
		} 
	}
	
	/**
	 * 分享
	 */
	private void onShare() {
		ShareAlertBig alert = new ShareAlertBig(me,
				new WXHandler(this), getShareUrl(), getShareTitle(), getShareContent(),
				getShareImage(), getDocumentId(), StatisticUtil.StatisticPageType.topic);
		alert.show(me);
	}
	
	private String getShareContent() {
	  if(TextUtils.isEmpty(description)){
	    return getShareTitle();
	  }else{
	    return description.length() > Config.SHARE_MAX_LENGTH ? 
	        description.substring(0, Config.SHARE_MAX_LENGTH) +"...": description;
	  }
	}
	private String getShareTitle(){
		return topicDetailUnits.getBody().getHead().getTitle();
	}
	private String getShareUrl(){
		return topicDetailUnits.getBody().getContent().getShareurl();
	}
	private String getDocumentId(){
		return topicDetailUnits.getMeta().getDocumentId();
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
			//	showMessage("发布成功，评论正在审核");
			    windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.toast_publish_success_title, R.string.toast_publish_success_content);
			}

			@Override
			public void loadHttpFail() {
				Config.SEND_COMMENT_TIMES.add(System.currentTimeMillis());
				loadingDialog.dismiss();
			//	showMessage("发布失败");
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.toast_publish_fail_title, R.string.toast_publish_fail_content);
			}

			@Override
			public void preLoad() {
				loadingDialog = ProgressDialog.show(
						TopicDetailModuleActivity.this, "", "正在发布，请稍候", true,
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
		loadSuccessful = false;
		final String param = ParamsManager.addParams(topicDetailUrl); 
		final boolean expired = IfengNewsApp.getMixedCacheManager().isExpired(param);
		
		Handler handler = new Handler(Looper.getMainLooper());
		handler.postDelayed(new Runnable() {

			@Override
			public void run() {
				getLoader().startLoading(
						new LoadContext<String, Object, TopicDetailUnits>(param, TopicDetailModuleActivity.this,
								TopicDetailUnits.class, Parsers.newTopicDetailParser(),
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

	/**
	 * 加载 评论、调查、投票数据
	 */
	private void loadSpecificTypeData(TopicBody body){
	  if (topicSubjects == null || topicSubjects.size() == 0) {
        return;
      }
	  //评论
	  String commentUrl = body.getContent().getWwwUrl();
	  if (!TextUtils.isEmpty(commentUrl)) {
	    commentsManager.obtainTopicComments(commentUrl, new LoadListener<CommentsData>() {
          
          @Override
          public void postExecut(LoadContext<?, ?, CommentsData> context) {
              //检查数据是否完整
              if(null == context.getResult() || null == context.getResult().getComments()){
                  context.setResult(null);
                  return;
              }
          }
          
          @Override
          public void loadFail(LoadContext<?, ?, CommentsData> context) {}
          
          @Override
          public void loadComplete(LoadContext<?, ?, CommentsData> context) {
            AllComments allComments = context.getResult().getComments();
            if (null == allComments || null == allComments.getHottest() || allComments.getHottest().size() == 0) {
              return;
            }
            commentsData = context.getResult();
            ArrayList<Comment> comments = commentsData.getComments().getHottest();
            ArrayList<TopicSubject> tempSubjects = new ArrayList<TopicSubject>();
            int size = (comments.size() > 5 ? 5 : comments.size());
            for (int i = 0; i < size; i++) {
              TopicSubject subject = new TopicSubject();
              if (i == 0) {
                subject.setFirstOrLast("First");
              } else if (i == size - 1) {
                subject.setFirstOrLast("Last");
              } else {
                subject.setFirstOrLast("AllIsNot");
              }
              subject.setView(TopicDetailUtil.COMMENT_MODULE_TYPE);
              subject.setUserFace(comments.get(i).getUserFace());
              subject.setComment_contents(comments.get(i).getComment_contents());
              subject.setIp_from(comments.get(i).getIp_from());
              subject.setWwwUrl(wwwUrl);
              subject.setTopicId(thumbnail);
              subject.setShareUrl(shareUrl);
              tempSubjects.add(subject);
            }
            topicSubjects.addAll(tempSubjects);
            adapter.notifyDataSetChanged();
          }
      });
      }
	  //默认取第一个调查 投票
	  for (int i = 0; i < topicSubjects.size(); i++) {
	    if (TopicDetailUtil.SURVEY_MODULE_TYPE.equals(topicSubjects.get(i).getView())) {
	      TopicDetailUtil.getSurveyData(TopicDetailModuleActivity.this, topicSubjects.get(i).getPodItems().get(0).getId(), adapter);
	      break;
	    } 
      }
	  
	  for (int i = 0; i < topicSubjects.size(); i++) {
        if (TopicDetailUtil.VOTE_MODULE_TYPE.equals(topicSubjects.get(i).getView())) {
          TopicDetailUtil.getVoteData(TopicDetailModuleActivity.this, topicSubjects.get(i).getPodItems().get(0).getId(), adapter);
          break;
        }
      }
	  
	}
	
	@Override
	public void loadComplete(LoadContext<?, ?, TopicDetailUnits> context) {
	  topicSubjects.clear();
      topicSubjects.addAll(context.getResult().getBody().getSubjects());
      loadSpecificTypeData(context.getResult().getBody());
      loadSuccessful = true;
	  topicDetailUnits = (TopicDetailUnits) context.getResult();
	  list.setRefreshTime(Config.getCurrentTimeString());
	  addRecord();
	  super.loadComplete(context);
	}
	
	public void addRecord(){
	  if (ConstantManager.ACTION_FROM_TOPIC2.equals(getIntent().getAction())) {
        // 入口是专题
        if (!TextUtils.isEmpty(getIntent().getStringExtra(
                ConstantManager.EXTRA_GALAGERY))) {
            // 根据统计要求：专题首页的id里不用加topic_
            StatisticUtil.addRecord(getApplicationContext()
                    , StatisticUtil.StatisticRecordAction.page
                    , "id=" + topicDetailUnits.getMeta().getDocumentId() +"$ref=topic_"+getIntent().getStringExtra(
                            ConstantManager.EXTRA_GALAGERY)+"$type=" + StatisticUtil.StatisticPageType.topic);
        }
    } if (Intent.ACTION_VIEW.equals(getIntent().getAction())) {
        // 从分享打开专题
        StatisticUtil.addRecord(getApplicationContext()
                , StatisticUtil.StatisticRecordAction.page
                , "id="+topicDetailUnits.getMeta().getDocumentId()+"$ref=outside$type=" + StatisticUtil.StatisticPageType.topic);
    }else if (ConstantManager.ACTION_WIDGET.equals(getIntent().getAction())){
        // 文章打开统计
        StatisticUtil.addRecord(getApplicationContext()
                , StatisticUtil.StatisticRecordAction.page
                , "id="+topicDetailUnits.getMeta().getDocumentId()+"$ref=desktop$type=" + StatisticUtil.StatisticPageType.topic);
    } else {
        // 入口是列表
        Channel channel = (Channel) getIntent().getParcelableExtra(
                ConstantManager.EXTRA_CHANNEL);
        if (null != channel) {
            StatisticUtil.addRecord(getApplicationContext()
                    , StatisticUtil.StatisticRecordAction.page
                    , "id="+topicDetailUnits.getMeta().getDocumentId()+"$ref="+channel.getStatistic()+"$type=" + StatisticUtil.StatisticPageType.topic);
        }
    }
	}

	@Override
	public void loadFail(LoadContext<?, ?, TopicDetailUnits> context) {
	  list.stopRefresh();
	  super.loadFail(context);
	}
	
	@Override
	public void render(TopicDetailUnits data) {
 
	    list.stopRefresh();
	    /* * TODO下拉刷新策略暂时不满足产品需求*/
		 
		if (isFirstCreated && isHaveCache) {
			isFirstCreated = false;
			handler.sendEmptyMessageDelayed(PULLTOREFRESH, 300);
		}
	}
	
	Handler handler = new Handler(new Handler.Callback() {
		
		@Override
		public boolean handleMessage(Message msg) {
			if (msg.what == PULLTOREFRESH) {
				handler.removeMessages(PULLTOREFRESH);
				list.setRefreshTime(Config.getCurrentTimeString());
	            list.startRefresh();
				handler.sendEmptyMessageDelayed(REFRESHCOMPLETE, 2000);
			} else if (msg.what == REFRESHCOMPLETE) {
			    list.stopRefresh();
			}
			return false;
		}
	});
	
	@Override
	public void onRefresh() {
	  if(NetworkState.isActiveNetworkConnected(TopicDetailModuleActivity.this)){
	    list.setRefreshTime(Config.getCurrentTimeString());
	    list.startRefresh();
	    reLoading(true);
	  }else{
	    list.stopRefresh();
	    windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
	  }
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
	public Class<TopicDetailUnits> getGenericType() {
		return TopicDetailUnits.class;
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
//		tryFinish();
		//只有从封面故事或者推送进入才返回到头条列表
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
	}
	
	@Override
	protected void onResume() {
		StatisticUtil.type = StatisticUtil.StatisticPageType.topic.toString() ;
		StatisticUtil.doc_id = topicId;
		RestartManager.checkRestart(this, startTime, RestartManager.LOCK);
		super.onResume();
		if (isFirstResume) {
			isFirstResume = false;
			return;
		}
		adapter.notifyDataSetChanged();
	}

	@Override
	protected void onForegroundRunning() {
		super.onForegroundRunning();
		RestartManager.checkRestart(this, startTime, RestartManager.HOME);
		IfengNewsApp.shouldRestart = true;
	}

	@Override
	protected void onDestroy() {
	    commentsData = null;
	    surveyUnit = null;
	    voteData = null;
	    STYLE = "normal";
		super.onDestroy();
	}

	@Override
	public void postExecut(LoadContext<?, ?, TopicDetailUnits> arg0) {
	    if (arg0.getResult() == null) {
			return;
		}
		if (arg0.getResult().getBody() == null
				|| arg0.getResult().getBody().getSubjects() == null
				|| arg0.getResult().getBody().getSubjects().size() == 0) {
			arg0.setResult(null);
			return;
		}
		//去除不支持视图
		filterNonsupportType(arg0.getResult().getBody().getSubjects());
		if (arg0.getResult().getBody().getSubjects().size() == 0) {
		  arg0.setResult(null);
          return;
        }
		//插入必要数据
		insertData(arg0.getResult());
		super.postExecut(arg0);
	}

	/**
	 * 插入必要数据
	 */
	public void insertData(TopicDetailUnits topicDetailUnits){
	  wwwUrl = topicDetailUnits.getBody().getContent().getWwwUrl();
	  title = topicDetailUnits.getBody().getHead().getTitle();
	  topicId = topicDetailUnits.getMeta().getDocumentId();
	  shareUrl = topicDetailUnits.getBody().getContent().getShareurl();
	  STYLE = topicDetailUnits.getBody().getContent().getStyle();
	  for (TopicSubject currentSubject : topicDetailUnits.getBody().getSubjects()) {
	    //保存专题的Id到每一个module 每一个item
	    currentSubject.setTopicId(topicId);
	    //更贴点击查看更多时用到title & wwwUrl
	    if (TopicDetailUtil.TEXT_MODULE_TYPE.equals(currentSubject.getView())) {
	      description = currentSubject.getContent().getIntro() ; 
	      currentSubject.setTitle(title);
	      currentSubject.setWwwUrl(wwwUrl);
	      if(TextUtils.isEmpty(shareUrl)) {
	        currentSubject.setShareUrl(wwwUrl);
	      } else {
	        currentSubject.setShareUrl(shareUrl);
	      }
	      List<String> images = getShareImage();
	      if(images == null || images.size()<=0) {
	        currentSubject.setImageUrl(null);
	      } else {
	        currentSubject.setImageUrl(images.get(0));
	      }
	    }
	    //投票和调查
	    if (TopicDetailUtil.VOTE_MODULE_TYPE.equals(currentSubject.getView())
	        || TopicDetailUtil.SURVEY_MODULE_TYPE
	        .equals(currentSubject.getView())) {
	      currentSubject.setShareThumbnail(thumbnail);
	    }

	  }
	}
	
	/**
	 * 过滤不支持的类型
	 */
	public void filterNonsupportType(ArrayList<TopicSubject> topicSubjects){
	  Iterator<TopicSubject> iterator = topicSubjects.iterator();
	  while (iterator.hasNext()) {
	    if (!TopicDetailUtil.isBuilder(iterator.next())) {
	      iterator.remove();
	    }
	  }
	}
	
	@Override
	public void downloadPicture() {
		//TODO nothing
	}

	@Override
	public void showShareView() {
		if(topicDetailUnits != null)
			onShare();
		
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
        if (flingState == OnFlingListener.FLING_RIGHT) {
            onBackPressed();
        } else {
			showComments();
        }
    }
    
    /**
     * 显示评论页
     */
    public void showComments() {
    	ArrayList<String> images = getShareImage();
    	
    	if(wwwUrl != null && title != null && topicId != null ){
    		
    		if(images == null || images.size()<=0) {
    			CommentsActivity.redirect2Comments(this,wwwUrl,null, 
        				title, wwwUrl, topicId, true, true,null,getShareUrl(),null,ConstantManager.ACTION_FROM_TOPIC2);
    		} else {
    		CommentsActivity.redirect2Comments(this,wwwUrl,null, 
    				title, wwwUrl, topicId, true, true,images.get(0),getShareUrl(),null,ConstantManager.ACTION_FROM_TOPIC2);
    		}
    	}
    	//切换动画
    	overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
	}
    


}
