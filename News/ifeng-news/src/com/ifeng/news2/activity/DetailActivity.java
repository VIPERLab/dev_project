package com.ifeng.news2.activity;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.net.HttpURLConnection;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.regex.Pattern;
import java.util.zip.GZIPInputStream;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.preference.PreferenceManager;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.webkit.WebSettings.TextSize;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import com.google.myjson.Gson;
import com.google.myjson.JsonObject;
import com.google.myjson.JsonParser;
import com.ifeng.news2.Config;
import com.ifeng.news2.FunctionActivity;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.R.id;
import com.ifeng.news2.advertise.AdDetailActivity;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.DocUnit;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.IfengWebView;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.bean.SurveyItem;
import com.ifeng.news2.bean.SurveyResult;
import com.ifeng.news2.bean.SurveyUnit;
import com.ifeng.news2.db.CollectionDBManager;
import com.ifeng.news2.fragment.NewsMasterFragmentActivity;
import com.ifeng.news2.plutus.android.view.ExposureHandler;
import com.ifeng.news2.share.ShareAlertBig;
import com.ifeng.news2.share.WXHandler;
import com.ifeng.news2.util.CommentsManager;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.FilterUtil;
import com.ifeng.news2.util.FunctionButtonWindow;
import com.ifeng.news2.util.FunctionButtonWindow.FunctionButtonInterface;
import com.ifeng.news2.util.ImageLoadUtil;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.RecordUtil;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticPageType;
import com.ifeng.news2.util.StatisticUtil.StatisticRecordAction;
import com.ifeng.news2.util.WindowPrompt;
import com.ifeng.news2.vote.VoteExecutor;
import com.ifeng.news2.vote.VoteExecutor.VoteListener;
import com.ifeng.news2.vote.VoteModuleBuilder;
import com.ifeng.news2.vote.VoteShareUitl;
import com.ifeng.news2.vote.entity.Data;
import com.ifeng.news2.vote.entity.VoteData;
import com.ifeng.news2.vote.entity.VoteItemInfo;
import com.ifeng.news2.widget.DetailView;
import com.ifeng.news2.widget.IfengBottomTitleTabbar;
import com.ifeng.news2.widget.LoadableViewWrapper;
import com.ifeng.share.util.NetworkState;
import com.qad.annotation.InjectExtras;
import com.qad.lang.Files;
import com.qad.loader.BeanLoader;
import com.qad.loader.ImageLoader;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.net.HttpGetListener;
import com.qad.net.HttpManager;
import com.qad.system.adapter.NetWorkAdapter;
import com.qad.util.OnFlingListener;
import com.tencent.mm.sdk.openapi.BaseReq;
import com.tencent.mm.sdk.openapi.BaseResp;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;

@SuppressWarnings("deprecation")
@SuppressLint("HandlerLeak")
public class DetailActivity extends FunctionActivity
    implements
      LoadListener<DocUnit>,
      IWXAPIEventHandler,
      OnFlingListener,
      FunctionButtonInterface {

  @InjectExtras(name = ConstantManager.EXTRA_CHANNEL, optional = true)
  private Channel channel;
  @InjectExtras(name = ConstantManager.EXTRA_DETAIL_ID, optional = true)
  private String aid;
  @InjectExtras(name = "isRelationClick", optional = true)
  private boolean isRelationClick;// 相关新闻阅读
  @InjectExtras(name = ConstantManager.THUMBNAIL_URL, optional = true)
  private String thumbnaiUrl;
  private String introduction; // 描述信息
  public final static String ACTION_PUSH = "action.com.ifeng.news2.push";
  private boolean loadSuccessful = false;
  private boolean canScale = true;
  private int dispalyWidth;
  private String relationUrl = "";// 当前相关新闻链接
  private ViewGroup advViewGroup;
  private DetailView detailView;
  private NetWorkAdapter netWorkAdapter;
  private EditText detailCommentEditText;
  private AlertDialog.Builder fontSizeDialog;
  private ProgressDialog progressDialog = null;
  private ImageView backView, moreView, fontSizeView, writeCommentView, placeHolder;
  private View detailSubmitCommentButton, detailCloseCommmentButton, detailCommentModule;
  private TextView more_prompt;
  private IfengBottomTitleTabbar detailTabbar;
  private CommentsManager commentsManager;
  private DocUnit unit;
  private FunctionButtonWindow functionButtonWindow;
  private ScaleGestureDetector detector;
  private String detailUrl;
  private boolean hasTap;
  private boolean isClick;
  private Data voteData;
  private VoteExecutor executor;
  private static String articleWidth;
  private String documentId;
  private String preDocumentId = "";

  // 用于判断是否需要显示正文引导页
  private boolean firstRun = false;

  // 用于记录有多少篇打开的正文，以fix bug #18012
  public static int pageCount = 0;

  @SuppressLint("UseSparseArrays")
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    if (savedInstanceState != null) {
      channel = savedInstanceState.getParcelable("channel");
      aid = savedInstanceState.getString("aid");
      isRelationClick = savedInstanceState.getBoolean("isRelationClick");
    } else
    // 记录打开文章的来源，用于统计IN启动的来源
    if (getIntent().getAction().equals(ConstantManager.ACTION_PUSH)) {
      // 从推送启动应用
      startSource = ConstantManager.IN_FROM_PUSH; // startSource在父类AppBaseActivity中定义
      IfengNewsApp.backFromPushOrWidget = true;
    } else if (Intent.ACTION_VIEW.equals(getIntent().getAction())) {
      // 从推送启动应用
      startSource = ConstantManager.IN_FROM_OUTSIDE;
    } else if (getIntent().getAction().equals(ConstantManager.ACTION_WIDGET)) {
      startSource = ConstantManager.IN_FROM_WIDGET;
      IfengNewsApp.backFromPushOrWidget = true;
    }
    init();
    // 获取intent数据
    getIntentData();
    pageCount++;
  }

  @Override
  protected void onSaveInstanceState(Bundle outState) {
    outState.putParcelable("channel", channel);
    outState.putString("aid", aid);
    outState.putBoolean("isRelationClick", isRelationClick);
    outState.putSerializable("unit", unit);
    super.onSaveInstanceState(outState);
  }

  private void init() {
    setContentView(R.layout.detail);
    initIdsAndId();
    isRelationClick = false;
    commentsManager = new CommentsManager();
    netWorkAdapter = new NetWorkAdapter(this);
    channel = channel == null ? Channel.NULL : channel;
    Config.IS_FINSIH_PULL_SKIP = true;
    dispalyWidth = getWindowManager().getDefaultDisplay().getWidth();
    articleWidth = PreferenceManager.getDefaultSharedPreferences(this).getString("articleWidth", null);
    findViewById();
    ((IfengWebView) getCurrentWebview()).setScaleGestureDetector(detector);
    loadDetail();
    setIsMoveRead(isMoveRead);
    functionButtonWindow = new FunctionButtonWindow(this);
    functionButtonWindow.setFunctionButtonInterface(this);
  }

  private void getIntentData() {
    Intent intent = getIntent();
    introduction = intent.getStringExtra(ConstantManager.EXTRA_INTRODUCTION);
    preDocumentId = intent.getStringExtra(ConstantManager.EXTRA_CURRENT_DETAIL_DOCUMENTID);
  }

  // 在文章加载完成后进行统计，和IOS保持一致
  private void beginStatistic(String documentId) {
    // 从推送进入文章的统计
    if (ConstantManager.ACTION_PUSH.equals(getIntent().getAction())) {
      // 文章打开统计
      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
          "id=" + documentId + "$ref=push$type=" + StatisticUtil.StatisticPageType.article);

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
                  + StatisticUtil.StatisticPageType.article);
        } else {
          // fix bug #18093 推送打开相关文章，来源为空。
          StatisticUtil.addRecord(getApplicationContext(),
              StatisticUtil.StatisticRecordAction.page, "id=" + documentId + "$ref=push$type="
                  + StatisticUtil.StatisticPageType.article);
        }
      }
      //从相关新闻进入文章
    } else if (ConstantManager.ACTION_FROM_RELATIVE.equals(getIntent().getAction())){
    	 if(!TextUtils.isEmpty(preDocumentId))
    	 	StatisticUtil.addRecord(getApplicationContext(),
                 StatisticUtil.StatisticRecordAction.page, "id=" + documentId + "$ref="+preDocumentId+"$type="
                     + StatisticUtil.StatisticPageType.article);
      // 凤凰快讯进入文章统计
    } else if (ConstantManager.ACTION_PUSH_LIST.equals(getIntent().getAction())) {
      // 推送打开统计，推送打开需要去掉系统标识 imcp
      // 文章打开
      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
          "id=" + documentId + "$ref=pushlist$type=" + StatisticUtil.StatisticPageType.article);
    }
    // json专题和web专题进入文章的PA统计
    else if (ConstantManager.ACTION_BY_AID.equals(getIntent().getAction())
        || ConstantManager.ACTION_FROM_TOPIC2.equals(getIntent().getAction())) {
      if (!TextUtils.isEmpty(getIntent().getStringExtra(ConstantManager.EXTRA_GALAGERY))) {
        StatisticUtil.addRecord(
            getApplicationContext(),
            StatisticUtil.StatisticRecordAction.page,
            "id=" + documentId + "$ref=topic_"
                + getIntent().getStringExtra(ConstantManager.EXTRA_GALAGERY) + "$type="
                + StatisticUtil.StatisticPageType.article);
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
            "id=" + documentId + "$ref="+preDocumentId+"$type=" + StatisticUtil.StatisticPageType.article);
      } else if (getIntent().hasExtra(ConstantManager.EXTRA_CHANNEL)) {
        // 普通文章内链
        StatisticUtil.addRecord(
            getApplicationContext(),
            StatisticUtil.StatisticRecordAction.page,
            "id="
                + documentId
                + "$ref="+preDocumentId+ "$type=" + StatisticUtil.StatisticPageType.article);
      } else {
        // 从分享渠道打开文章
        StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
            "id=" + documentId + "$ref=outside$type=" + StatisticUtil.StatisticPageType.article);
      }
    } else if (ConstantManager.ACTION_FROM_COLLECTION.equals(getIntent().getAction())) {
      // 从收藏打开文章
      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
          "id=" + documentId + "$ref=collect$type=" + StatisticUtil.StatisticPageType.article);
      // 从widget进入文章统计
    } else if (ConstantManager.ACTION_WIDGET.equals(getIntent().getAction())) {
      // 文章打开统计
      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
          "id=" + documentId + "$ref=desktop$type=" + StatisticUtil.StatisticPageType.article);

    } else if (ConstantManager.ACTION_SPOER_LIVE.equals(getIntent().getAction())) {
      // 从体育直播的战报中打开文章统计
      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
          "id=" + documentId + "$ref=sports$type=" + StatisticUtil.StatisticPageType.article);
    } else {
      // 默认算作从首页打开
      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
          "id=" + documentId + "$ref=sy$type=" + StatisticUtil.StatisticPageType.article);
    }
  }

  private void initIdsAndId() {
    if (ConstantManager.ACTION_VIBE.equals(getIntent().getAction())) {
      Intent vibeIntent = getIntent();
      aid = vibeIntent.getStringExtra("id");
    } else if (Intent.ACTION_VIEW.equals(getIntent().getAction())) {
      IfengNewsApp.shouldRestart = false;
      if (!getIntent().hasExtra("isRelationClick")) {// fix bug #15936
        Uri uri = getIntent().getData();
        aid = uri.getLastPathSegment();
      }
      // 如果是从相关新闻打开aid是由extra EXTRA_DETAIL_ID传入
    }
    if (aid == null) failRender();
    if (ConstantManager.ACTION_VIBE.equals(getIntent().getAction()))
      aid = String.format(Config.DETAIL_URL, aid);
  }

  @Override
  public void setWebFont(WebView webView, FontSize size) {
    switch (size) {
      case big:
        webView.getSettings().setTextSize(TextSize.LARGER);
        break;
      case mid:
        webView.getSettings().setTextSize(TextSize.NORMAL);
        break;
      case small:
        webView.getSettings().setTextSize(TextSize.SMALLER);
        break;
      default:
        webView.getSettings().setTextSize(TextSize.NORMAL);
        break;
    }
  }

  public void findViewById() {
    detailTabbar = (IfengBottomTitleTabbar) findViewById(R.id.detail_tabbar);
    backView = (ImageView) findViewById(R.id.back);
    moreView = (ImageView) findViewById(R.id.more);
    more_prompt = (TextView) findViewById(R.id.more_prompt);
    writeCommentView = (ImageView) findViewById(R.id.write_comment);
    placeHolder = (ImageView) findViewById(R.id.placeholder);
    detailCommentModule = (View) findViewById(id.detail_comment_module);
    detailCommentEditText = (EditText) findViewById(id.detail_comment_editText);
    detailSubmitCommentButton = findViewById(id.detail_submit_comment_button);
    detailCloseCommmentButton = findViewById(id.detail_close_commment_button);
    advViewGroup = (ViewGroup) findViewById(id.advertise);
    detailView = (DetailView) findViewById(R.id.detailView);
    detailCommentModule.setVisibility(View.GONE);
    detailView.setOnTouchListener(detailCommentEditText);
    detailView.setOnFlingListener(this);
    detailView.setOnRetryListener(new View.OnClickListener() {
      @Override
      public void onClick(View v) {
        loadDetail();
      }
    });
    detailCommentEditText.setOnFocusChangeListener(new View.OnFocusChangeListener() {

      @Override
      public void onFocusChange(View v, boolean hasFocus) {
        if (!hasFocus) {
          updateEditCommentModule(false);
        }
      }
    });

    detailCommentEditText.addTextChangedListener(new TextWatcher() {

      @Override
      public void onTextChanged(CharSequence s, int start, int before, int count) {}

      @Override
      public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

      @Override
      public void afterTextChanged(Editable s) {
        if (Config.SEND_COMMENT_WORDS_LIMIT < s.length()) {
          s.delete(Config.SEND_COMMENT_WORDS_LIMIT, s.length());
        }
      }
    });

    if (android.os.Build.VERSION.SDK_INT >= 8) {
      // 放大缩小手势识别
      detector =
          new ScaleGestureDetector(this, new ScaleGestureDetector.SimpleOnScaleGestureListener() {

            private int beginSpan;

            @Override
            public boolean onScaleBegin(ScaleGestureDetector detector) {
              beginSpan = (int) detector.getCurrentSpan();
              detailView.setOnFlingListener(null);
              return super.onScaleBegin(detector);
            }

            @Override
            public boolean onScale(ScaleGestureDetector detector) {
              if (canScale && Math.abs(detector.getCurrentSpan() - beginSpan) > dispalyWidth / 10) {
                FontSize size = getPreferenceFontSize();
                FontSize changedSize = null;
                if (detector.getCurrentSpan() - beginSpan > 0) {
                  changedSize = size.getLarger();
                } else {
                  changedSize = size.getSmaller();
                }
                if (changedSize.isAvailable()) {
                  changeWebFont(changedSize);
                }
                canScale = false;
              }
              return super.onScale(detector);
            }

            private void changeWebFont(FontSize changedSize) {
              if (changedSize != null) {
                unit.getBody().setFontSize(changedSize.toString());
                saveFont(changedSize.toString());
                getCurrentWebview().loadUrl(
                    "javascript:setFontSize('" + changedSize.toString() + "')");
                windowPrompt.showWindowPrompt(null, changedSize.getName());
              }
            }

            @Override
            public void onScaleEnd(ScaleGestureDetector detector) {
              canScale = true;
              super.onScaleEnd(detector);
              detailView.setOnFlingListener(DetailActivity.this);
            }

          });
    }
    // 发帖框加入“文明上网，遵守“七条底线””
    findViewById(R.id.policy_text).setOnClickListener(new View.OnClickListener() {

      @Override
      public void onClick(View v) {
        updateEditCommentModule(false);

        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        intent.setData(Uri.parse("comifengnews2app://doc/68983945"));
        // intent.setClass(DetailActivity.this, AdDetailActivity.class);
        // intent.putExtra("URL",
        // "http://i.ifeng.com/news/zhuanti/qd/zx/sharenews.f?vt=5&aid=68983945&mid=6qgxho");
        DetailActivity.this.startActivity(intent);
        // 增加跳转动画
        overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
      }
    });
  }

  public void buttonOnClick(View view) {
    if (view == backView) {
      onBackPressed();
    }
    if (!prepared()) {
      return;
    }
    // 此处为收藏功能
    if (view == moreView) {
      // Show more function buttons
      /*
       * ArrayList<String> functionBut = new ArrayList<String>(); functionBut.add("收藏");
       * functionBut.add("分享"); functionButtonWindow.showMoreFunctionButtons(moreView, functionBut,
       * FunctionButtonWindow.TYPE_FUNCTION_BUTTON_WHITE);
       */
      // if (isNetworkConnected(this)) {
      // 文章加载成功
      if (loadSuccessful) {
        onCollect();
      } else {
        showMessage("此功能不可用");
      }
      // } else {
      // showMessage(R.string.not_network_message);
      // }
    } else if (view == fontSizeView) {
      fontSizeDialog = new Builder(this);
      fontSizeDialog.setTitle("字体");
      final String[] arrayFruit = new String[] {"大", "中", "小"};
      fontSizeDialog.setSingleChoiceItems(arrayFruit, defaultSize(),
          new DialogInterface.OnClickListener() {

            @Override
            public void onClick(DialogInterface dialog, int which) {
              switch (which) {
                case 0:
                  setFont(FontSize.big);
                  saveFont("big");
                  break;
                case 1:
                  setFont(FontSize.mid);
                  saveFont("mid");
                  break;
                case 2:
                  setFont(FontSize.small);
                  saveFont("small");
                  break;
              }
              dialog.dismiss();
            }
          });
      fontSizeDialog.setNeutralButton("取消", new DialogInterface.OnClickListener() {

        public void onClick(DialogInterface dialog, int which) {
          dialog.dismiss();
        }
      });
      fontSizeDialog.create();
      fontSizeDialog.show();

      // 此处为分享功能
    } else if (view == writeCommentView) {
      if (isNetworkConnected(this)) {
        // 文章加载成功
        if (loadSuccessful) {
          onShare();
        } else {
          showMessage("此功能不可用");
        }
      } else {
        showMessage(R.string.not_network_message);
      }
    } else if (view == detailCloseCommmentButton) {
      updateEditCommentModule(false);
    } else if (view == detailSubmitCommentButton) {
      String commentContent = detailCommentEditText.getText().toString().trim();
      if (TextUtils.isEmpty(commentContent)) {
      //  showMessage("评论不能为空");
        windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.toast_edit_empty_title, R.string.toast_edit_empty_content);
      } else {
        sendDetailComment(commentContent);
        updateEditCommentModule(false);
      }
      // 此处评论功能
    } else if (view == placeHolder) {
      if (isNetworkConnected(this)) {
        // 文章加载成功
        if (loadSuccessful) {
          updateEditCommentModule(true);
        } else {
          showMessage("此功能不可用");
        }
      } else {
        showMessage(R.string.not_network_message);
      }
    }
  }

  @Override
  public void setFont(FontSize size) {
    for (int i = 0; i < detailView.getChildCount(); i++) {
      LoadableViewWrapper wrapper =
          (LoadableViewWrapper) ((DetailView) detailView.getChildAt(i)).getCurrentView();
      setWebFont((WebView) wrapper.getWrappedView(), size);
    }
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    if (detailView != null) {
      detailView.destroy();
    }
    if (null != workerThread && workerThread.isAlive()) {
    	Log.e("Sdebug", "interrupting image download thread.");
    	workerThread.interrupt();
    }
    pageCount--;
  }

  public void updateEditCommentModule(boolean isShow) {
    if (isShow) {
      advViewGroup.setVisibility(View.GONE);
      detailTabbar.setVisibility(View.GONE);
      detailCommentModule.setVisibility(View.VISIBLE);
    } else {
      detailTabbar.setVisibility(View.VISIBLE);
      detailCommentModule.setVisibility(View.GONE);
    }
    showSoftInput(isShow);
  }

  public void showSoftInput(boolean isShow) {
    if (isShow) {
      detailCommentEditText.requestFocus();
      InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
      imm.showSoftInput(detailCommentEditText, 0);
    } else {
      ((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE)).hideSoftInputFromWindow(
          detailCommentEditText.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
    }
  }

  public void sendDetailComment(String commentContent) {
    // 回复功能统计
    StatisticUtil.addRecord(this, StatisticRecordAction.action, "type=" + StatisticPageType.follow);
    DocUnit docUnit = unit;
    commentContent = commentContent.replaceAll("<", " ").replaceAll(">", " ");
    if (Config.SEND_COMMENT_TIMES.size() >= 6) {
      if (System.currentTimeMillis() - Config.SEND_COMMENT_TIMES.get(0) < 60000) {
        showMessage("发送评论太过频繁");
        return;
      } else {
        Config.SEND_COMMENT_TIMES.remove(0);
      }
    }
    commentsManager.sendComments("0", docUnit.getBody().getTitle(), docUnit.getBody().getWwwurl(),
        commentContent, docUnit.getBody().getCommentsExt(), new HttpGetListener() {

          @Override
          public void loadHttpSuccess() {
            Config.SEND_COMMENT_TIMES.add(System.currentTimeMillis());
            loadingDialog.dismiss();
    //        showMessage("发布成功，评论正在审核");
            windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.toast_publish_success_title, R.string.toast_publish_success_content);
          }

          @Override
          public void loadHttpFail() {
            Config.SEND_COMMENT_TIMES.add(System.currentTimeMillis());
            loadingDialog.dismiss();
            windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.toast_publish_fail_title, R.string.toast_publish_fail_content);
          }

          @Override
          public void preLoad() {
            loadingDialog =
                ProgressDialog.show(DetailActivity.this, "", "正在发布，请稍候", true, true,
                    new OnCancelListener() {
                      @Override
                      public void onCancel(DialogInterface dialog) {
                        dialog.dismiss();
                      }
                    });
          }
        });
  }

  public void loadDetail() {
    LoadableViewWrapper wrapper = (LoadableViewWrapper) detailView.getCurrentView();
    wrapper.showLoading();
    if (isRelationClick || (ConstantManager.isIntactUrl(getIntent().getAction()))) {
      detailUrl = aid;
    } else {
      detailUrl = String.format(Config.DETAIL_URL, aid);
    }

    IfengNewsApp.getBeanLoader().startLoading(
        new LoadContext<String, LoadListener<DocUnit>, DocUnit>(ParamsManager.addParams(this,
            detailUrl), this, DocUnit.class, Parsers.newSmartDocUnitParser(),
            LoadContext.FLAG_CACHE_FIRST, false));
  }

  // 相关新闻阅读
  public void loadRelationDetail(View detail, String url) {
    // TODO
    Intent intent = new Intent(this, DetailActivity.class);
    if (Intent.ACTION_VIEW.equals(getIntent().getAction())) {// fix bug #15936
      intent.setAction(Intent.ACTION_VIEW);
    } else {
//      intent.setAction(ConstantManager.ACTION_FROM_APP);
      intent.setAction(ConstantManager.ACTION_FROM_RELATIVE);
      intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
    }
    // fix bug 17228 【分享】相关新闻分享到微信好友、qq好友等没有摘要
    intent.putExtra(ConstantManager.EXTRA_INTRODUCTION, introduction);
    intent.putExtra(ConstantManager.EXTRA_DETAIL_ID, url);
    intent.putExtra(ConstantManager.EXTRA_CURRENT_DETAIL_DOCUMENTID, documentId);
    intent.putExtra("isRelationClick", true);
    startActivity(intent);
    // 增加跳转动画
    overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
    hasTap = true;
  }

  public void JumpToArticle(String type, String id) {
    if ("doc".equals(type)) {
      relationUrl = String.format(Config.DETAIL_URL, id);
      loadRelationDetail(detailView.getCurrentView(), relationUrl);
    } else if ("slide".equals(type)) {
      // 跳转相关新闻
      relationUrl = String.format(Config.DETAIL_URL, id);
      goToSlide(relationUrl);
    } else {
      Intent intent = new Intent();
      if ("browser".equals(type)) {
        intent.setAction(Intent.ACTION_VIEW);
        intent.setData(Uri.parse(id));
      } else if ("webfull".equals(type)) {
        intent.setClass(this, AdDetailActivity.class);
        intent.putExtra("URL", id);
      }
      intent.putExtra(ConstantManager.EXTRA_CURRENT_DETAIL_DOCUMENTID, documentId);
      // fix bug 17228 【分享】相关新闻分享到微信好友、qq好友等没有摘要
      intent.putExtra(ConstantManager.EXTRA_INTRODUCTION, introduction);
      startActivity(intent);
      // 增加跳转动画
      overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
      hasTap = true;
    }
  }

  private DocUnit addJumpWays(DocUnit unit) {
    Document doc = Jsoup.parse(unit.getBody().getText());
    Elements links = doc.select("a[href]"); // 带有href属性的a元素
    for (Element element : links) {
      if (null == element) continue;
      String type = element.attr("type");
      if (TextUtils.isEmpty(type) || "web".equals(type)) continue;
      String temp = element.attr("href");
      if (TextUtils.isEmpty(temp) || temp.contains("comifengnews2app")) continue;
      int id = 0;
      try {
        id = Integer.parseInt(Uri.parse(temp).getQueryParameter("aid"));
        if (0 == id) continue;
        element.attr("href", "comifengnews2app://" + type + "/" + id + "?opentype=out");
      } catch (Exception e) {}
    }
    unit.getBody().setText(doc.body().html());
    return unit;
  }

  public void renderUnit(LoadableViewWrapper wrapper, DocUnit unit) {
    unit = addJumpWays(unit);
    WebView currentWebView = (WebView) wrapper.getWrappedView();
    if (currentWebView != null) {
      try {
        currentWebView.clearCache(true);
        currentWebView.clearHistory();
        //防止js测量宽度失败
        detailView.setFocusable(true);
        detailView.setIntercept(true);
        currentWebView.addJavascriptInterface(new JsInterface(), "ifeng");
        unit.getBody().setFontSize(getPreferenceFontSize().toString());
        unit.getBody().setArticleWidth(articleWidth);
        // 特换img标签为自定义的ifengimg标签，原声的img标签会被webview识别
        // 从而访问网络下载图片，正文中的图片目前设计是由Android代码异步下载，webview不应再下载
        currentWebView.addJavascriptInterface(unit.getBody(), "datas");
        if(TextUtils.isEmpty(articleWidth)) {
        	wrapper.showNormal();
        }
        currentWebView.loadUrl("file:///android_asset/detail_page.html");
        currentWebView.setWebViewClient(new WebDetailClient());
        setWebFont(currentWebView, FontSize.valueOf("mid"));
        currentWebView.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
        loadSuccessful = true;
      } catch (Exception e) {
        wrapper.showRetryView();
      }
//      if (!android.os.Build.MANUFACTURER.equals("HTC")) {
        // fix bug #17047 【文章detail页】打开长文章时会出现如图所示几秒钟的空白。(HTC)
//        wrapper.showNormal();
//      }
    }
  }

  private class JsInterface {

    @SuppressWarnings("unused")
    public void reload(final String docmentId) {
      if (unit != null) {
        Log.d("reload", "reload");
        // UI相关的操作放到UI线程执行，避免下面的exception
        // java.lang.Throwable: Warning: A WebView method
        // was called on thread 'WebViewCoreThread'.
        // All WebView methods must be called on the UI thread.
        // Future versions of WebView may not support use on
        // other threads.
        DetailActivity.this.runOnUiThread(new Runnable() {

          @Override
          public void run() {
            renderUnit((LoadableViewWrapper) detailView.getCurrentView(), unit);
          }

        });
        // renderUnit(
        // (LoadableViewWrapper) detailView
        // .getCurrentView(),
        // currentDocUnit);
      } else {
        failRender();
      }
    }

    @SuppressWarnings("unused")
    public void hideLoadingMask(final String articleWidth) {
    	Log.d("sTag", "hideLoadingMask  "+articleWidth);
    	detailView.setFocusable(true);
    	detailView.setIntercept(false);
    	runOnUiThread(new Runnable() {
            @Override
            public void run() {
//            	if(android.os.Build.VERSION.SDK_INT != 19) {
            	if(!TextUtils.isEmpty(DetailActivity.articleWidth)){
            		((LoadableViewWrapper) detailView.getCurrentView()).showNormal();
            	}else if(!"0".equals(articleWidth)){
            		PreferenceManager.getDefaultSharedPreferences(me).edit().putString("articleWidth", articleWidth).commit();
            	}
            	// 判断是否显示引导页
            	SharedPreferences pref =
          	          DetailActivity.this.getSharedPreferences("FirstLogin", Context.MODE_PRIVATE);
            	if (!pref.contains(Config.CURRENT_CONFIG_VERSION)
            			|| (pref.getInt(Config.CURRENT_CONFIG_VERSION, 0) & 0x2) != 0x2) {
            		DetailActivity.this
            		.getSharedPreferences("FirstLogin", Context.MODE_PRIVATE)
          	   		.edit()
          	   		.putInt(Config.CURRENT_CONFIG_VERSION, pref.getInt(Config.CURRENT_CONFIG_VERSION, 0) | 0x2).commit();
          	        // 0x1: 列表, 0x2: 正文页
            		DetailActivity.this.findViewById(R.id.tips_detail).setVisibility(View.VISIBLE);
            		firstRun = true;
            	}
            }
          });
    }

    @SuppressWarnings("unused")
    public void webLog(String log) {
      // LogHandler.addLogRecord(this.getClass().getSimpleName(), "Log from JsInterface", log);
    	Log.i("Sdebug", "Log from JsInterface: "+log);
    }

    @SuppressWarnings("unused")
    public void showCommentsView(final String docmentId) {
      if (!hasTap) {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            showComments();
          }
        });
      }
    }
    
    @SuppressWarnings("unused")
	public int checkNetWorkState() {
    	if(!NetworkState.isActiveNetworkConnected(DetailActivity.this)) {
    		windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);			
			return 0;
		} 
    	return 1;
    }

    @SuppressWarnings("unused")
    public void playVideo(final String normalUrl, final String HDUrl) {
      if (!hasTap) {
        runOnUiThread(new Runnable() {
          public void run() {
            if (NetworkState.isActiveNetworkConnected(DetailActivity.this)
                && !NetworkState.isWifiNetworkConnected(DetailActivity.this)) {

              AlertDialog.Builder alertBuilder = new AlertDialog.Builder(DetailActivity.this);
              AlertDialog alertPlayIn2G3GNet =
                  alertBuilder
                      .setCancelable(true)
                      .setMessage(getResources().getString(R.string.video_dialog_play_or_not))
                      .setPositiveButton(getResources().getString(R.string.video_dialog_positive),
                          new OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                              DetailActivity.this.playVideo(normalUrl, HDUrl);

                            }
                          })
                      .setNegativeButton(getResources().getString(R.string.video_dialog_negative),
                          new OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog, int which) {

                            }
                          }).create();
              alertPlayIn2G3GNet.show();

            } else {

              DetailActivity.this.playVideo(normalUrl, HDUrl);
            }
          }
        });
      }
    }

    @SuppressWarnings("unused")
    public void popupLightbox(final String callbackId, final String imgUrl) {
      if (!hasTap) {
        runOnUiThread(new Runnable() {
          public void run() {
            DetailActivity.this.popupLightbox(callbackId, imgUrl);
          }
        });
      }
    }

    @SuppressWarnings("unused")
    public void loadImage(final String callbackId, final String url, final String documentId,
        final String forceLoad) {
//      runOnUiThread(new Runnable() {
//        @Override
//        public void run() {
//          startLoadImage(callbackId, url, forceLoad);
//        }
//      });
    	tasks.add(new TaskDataWrapper(callbackId, url, documentId, forceLoad));
    }
    
    @SuppressWarnings("unused")
    public void loadImageDirectly(final String callbackId, final String url, final String documentId,
        final String forceLoad) {
      runOnUiThread(new Runnable() {
        @Override
        public void run() {
          startLoadImage(callbackId, url, forceLoad);
        }
      });
    }
    
    @SuppressWarnings("unused")
	public void startDownload() {
      runOnUiThread(new Runnable() {
	      @Override
	      public void run() {
	        workerThread = new ImageDownloadWorker();
	        workerThread.start();
	      }
	    });
    }

    @SuppressWarnings("unused")
    public void getHotComments(final String callbackId, final String commentsUrl,
        final String documentId) {
      runOnUiThread(new Runnable() {

        @Override
        public void run() {
          commentsManager.obtainDetailComments(commentsUrl, new LoadListener<String>() {
            @Override
            public void loadComplete(LoadContext<?, ?, String> context) {
              if (context.getResult().length() > 0) {
                try {
                  showComment(context, callbackId, documentId, "1");
                } catch (Exception e) {}
              }
            }

            @Override
            public void loadFail(LoadContext<?, ?, String> context) {
              showComment(context, callbackId, documentId, "0");
            }

            private void showComment(LoadContext<?, ?, String> context, final String callbackId,
                String documentId, String state) {
              WebView webView = getCurrentWebview();
              try {
                webView.loadUrl("javascript:athene.complete('" + callbackId + "','" + state + "'"
                    + ",'" + URLEncoder.encode(context.getResult()) + "')");
              } catch (Exception e) {}
            }

            @Override
            public void postExecut(LoadContext<?, ?, String> arg0) {}
          });
        }
      });
    }

    /**
     * 判断是否符合2G/3G无图模式
     * 
     * @return
     */
    @SuppressWarnings("unused")
    public int is2g3gloadMode() {
      if (isSetNoImageModeAnd2G3G()) {
        return 1;
      }
      return 0;
    }

    @SuppressWarnings("unused")
    public void jump(final String type, final String id) {
      if (!hasTap) {
        runOnUiThread(new Runnable() {
          public void run() {
            JumpToArticle(type, id);
          }
        });
      }
    }

    @SuppressWarnings("unused")
    public void loadAdv01(final String callbackId, final String documentId) {
      runOnUiThread(new Runnable() {
        @Override
        public void run() {
          DetailActivity.this.loadAdv01(callbackId, documentId);
        }
      });
    }

    @SuppressWarnings("unused")
    public void loadAdv02(final String callbackId, final String documentId) {
      runOnUiThread(new Runnable() {
        @Override
        public void run() {
          DetailActivity.this.loadAdv02(callbackId, documentId);
        }
      });
    }

    @SuppressWarnings("unused")
    public void loadAdv2(final String callbackId, final String documentId) {
      runOnUiThread(new Runnable() {

        @Override
        public void run() {
          DetailActivity.this.loadAdv2(callbackId, documentId);
        }
      });
    }

    @SuppressWarnings("unused")
    public void goToSurvey(final String id) {
      if (!hasTap) {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            DetailActivity.this.goToSurvey(id);
          }
        });
      }
    }

    @SuppressWarnings("unused")
    public void goToSlide(final String url) {
      if (!hasTap) {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            DetailActivity.this.goToSlide(url);
          }
        });
      }
    }

    @SuppressWarnings("unused")
    public void getVoteData(final String callbackId) {
      runOnUiThread(new Runnable() {
        @Override
        public void run() {
          if (unit.getBody().getVote() != null && unit.getBody().getVote().length > 0) {
            DetailActivity.this.getVoteData(unit.getBody().getVote()[0], callbackId);
          } else {
            excuteFailed(callbackId);
          }
        }
      });
    }

    @SuppressWarnings("unused")
    public void submitVoteData(final String callbackId, final String id, final String voteid) {
      if (isClick) {
        return;
      }
      isClick = true;
      runOnUiThread(new Runnable() {
        @Override
        public void run() {
          DetailActivity.this.submitVoteData(callbackId, id, voteid);
        }
      });
    }

    @SuppressWarnings("unused")
    public void shareVoteData(final String topic) {
      runOnUiThread(new Runnable() {
        @Override
        public void run() {
          int type;
          if(voteData.getIsactive()==1) {
        	  type = VoteModuleBuilder.QUESTION_PAGE;
          } else{
        	  type = VoteModuleBuilder.RESULT_PAGE;
          }
          VoteShareUitl.shareVoteItem(me, topic, VoteShareUitl.getHighestVoteItem(voteData
              .getIteminfo()), unit.getBody().getThumbnail(),type);
        }

      });
    }

    @SuppressWarnings("unused")
    public void getSurveyData(final String callbackId) {
      runOnUiThread(new Runnable() {
        @Override
        public void run() {
          if (unit.getBody().getSurvey() != null && unit.getBody().getSurvey().length > 0) {
            DetailActivity.this.getSurveyData(unit.getBody().getSurvey()[0], callbackId);
          } else {
            excuteFailed(callbackId);
          }
        }
      });
    }
  }

	/**
	 * 
	 * @param callbackId
	 * @param id
	 *            整个投票页的id
	 * @param voteid
	 *            投票单项的id
	 */
  private void submitVoteData(final String callbackId, final String id, final String voteid) {
    executor.addVoteListener(new VoteListener() {

      @Override
      public void voteSuccess(String voteId) {  
        RecordUtil.record(me, id, RecordUtil.VOTE);
        voteData.setVotecount(Integer.valueOf(voteData.getVotecount()) + 1 + "");
        int lastPercent = 0;
        // 计算投票后票数和百分比
        for (int i = 0; i < voteData.getIteminfo().size(); i++) {
          int currentPercent = 0;
          //fix bug19524 【投票】投票完成后，选项的百分比不对。
          if (voteid.equals(voteData.getIteminfo().get(i).getId())) {
            voteData
                .getIteminfo()
                .get(i)
                .setVotecount(
                    Integer.valueOf(voteData.getIteminfo().get(i).getVotecount()) + 1 + "");
          } 
            voteData
                .getIteminfo()
                .get(i)
                .setNump(
                    (float) formatFloat(((float) Integer.valueOf(voteData.getIteminfo().get(i)
                        .getVotecount()))
                        / Integer.valueOf(voteData.getVotecount())) / 10);
          }

        Gson gson = new Gson();
        isClick = false;
        showMessage("投票成功");
        IfengWebView webView = getCurrentWebview();
        if (webView != null) {
          getCurrentWebview().loadUrl(
              "javascript:athene.complete('" + callbackId + "',1" + ",'" + gson.toJson(voteData)
                  + "')");
        }
      }

      @Override
      public void voteFail() {
        isClick = false;
        excuteFailed(callbackId);
        showMessage("投票未成功，请重试");
      }

      @Override
      public void netWorkFault() {
        isClick = false;
        excuteFailed(callbackId);
        windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
      }

    });
    executor.setVoteId(id).setItemId(voteid).vote();

  }

  private int formatFloat(Float number) {
    return Math.round(number * 1000);
  }

  protected void goToSurvey(String id) {
    Intent intent = new Intent(this, SurveyActivity.class);
    intent.putExtra(ConstantManager.THUMBNAIL_URL, thumbnaiUrl);
    intent.setAction(ConstantManager.ACTION_FROM_ARTICAL);
    intent.putExtra(ConstantManager.EXTRA_CURRENT_DETAIL_DOCUMENTID, documentId);
    intent.putExtra("id", id);
    startActivityForResult(intent, 110);
    overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
  }

  protected void getSurveyData(final String surveyId, final String callbackId) {
    IfengNewsApp.getBeanLoader().startLoading(
        new LoadContext<String, LoadListener<SurveyUnit>, SurveyUnit>(
            ParamsManager
                .addParams(this, ParamsManager.addParams(Config.SURVEY_GET_URL + surveyId)),
            new LoadListener<SurveyUnit>() {
              @Override
              public void postExecut(LoadContext<?, ?, SurveyUnit> context) {
                SurveyUnit unit = context.getResult();
                if (null == unit || -1 == unit.getIfsuccess() || null == unit.getData()
                    || null == unit.getData().getResult() || unit.getData().getResult().size() == 0) {
                  context.setResult(null);
                  return;
                }
                for(SurveyResult result : unit.getData().getResult()){
                	for(SurveyItem item : result.getResultArray()){
                		try {
                			Float.parseFloat(item.getNump());
						} catch (NumberFormatException  e) {
							 context.setResult(null);
							 return;
						}
                	}
                }
              }

              @Override
              public void loadComplete(LoadContext<?, ?, SurveyUnit> context) {
                if (context.getResult() != null && context.getResult().getIfsuccess() == 1) {
                  Gson gson = new Gson();
                  int surveyed = 0;
                  if (RecordUtil.isRecorded(me, unit.getBody().getSurvey()[0], RecordUtil.SURVEY)) {
                    if ("1".equals(context.getResult().getData().getSurveyinfo().getIsactive())) {
                      surveyed = 1;
                    }
                    context.getResult().getData().getSurveyinfo().setIsactive("0");
                  }
                  IfengWebView webView = getCurrentWebview();
                  if (webView != null) {
                    webView.loadUrl("javascript:athene.complete('" + callbackId + "',1" + ",'"
                        + URLEncoder.encode(gson.toJson(context.getResult().getData()).trim())
                        + "'," + surveyed + ")");
                  }
                } else {
                  excuteFailed(callbackId);
                }
              }

              @Override
              public void loadFail(LoadContext<?, ?, SurveyUnit> context) {
                excuteFailed(callbackId);
              }

            }, SurveyUnit.class, Parsers.newSurveyUnitParser(), false, LoadContext.FLAG_HTTP_FIRST,
            true));
  }

  private void getVoteData(String id, final String callbackId) {
    IfengNewsApp.getBeanLoader().startLoading(
        new LoadContext<String, LoadListener<VoteData>, VoteData>(ParamsManager.addParams(String
            .format(Config.VOTE_GET_URL, id)), new LoadListener<VoteData>() {

          @Override
          public void postExecut(LoadContext<?, ?, VoteData> context) {
			VoteData voteData = context.getResult();
				if (voteData != null) {
					if (voteData.getIfsuccess() != 1|| voteData.getData() == null) {
						context.setResult(null);
						return;
					}
				}
				for(VoteItemInfo info : voteData.getData().getIteminfo()){
					try {
						Integer.parseInt(info.getVotecount());
					} catch (NumberFormatException  e) {
						context.setResult(null);
						return;
					}
                }
          }

          @Override
          public void loadComplete(LoadContext<?, ?, VoteData> context) {
            if (context.getResult() != null && context.getResult().getIfsuccess() == 1) {
              voteData = context.getResult().getData();
              Gson gson = new Gson();
              executor = new VoteExecutor(me);
              int voted = 0;
              int isActive = -1;
              if (RecordUtil.isRecorded(me, unit.getBody().getVote()[0], RecordUtil.VOTE)) {
                if (1 == (voteData.getIsactive())) {
                  voted = 1;
                  isActive = voteData.getIsactive();
                }
                voteData.setIsactive(0);
              }
              IfengWebView webView = getCurrentWebview();
              if (webView != null) {
              webView.loadUrl("javascript:athene.complete('" + callbackId + "',1" + ",'"
                    + URLEncoder.encode(gson.toJson(voteData)) + "'," + voted
                    + ")");
              }
              if(isActive!=-1){
            	  voteData.setIsactive(isActive);
              }
            } else {
              excuteFailed(callbackId);
            }
          }

          @Override
          public void loadFail(LoadContext<?, ?, VoteData> context) {
            excuteFailed(callbackId);
          }
        }, VoteData.class, Parsers.newVoteDataParser(), LoadContext.FLAG_HTTP_FIRST, true));
  }

  private void showComments() {
    String image = null;
    if (unit.getBody() != null) {
      image = unit.getBody().getThumbnail();
    }

    // 新增加图片和分享链接
    if (commentDetail(unit.getBody().getCommentsUrl(), unit.getBody().getCommentType(), unit.getBody()
        .getTitle(), unit.getDocumentIdfromMeta(), unit.getBody().getCommentsExt(), true, image, unit
        .getBody().getShareurl(),ConstantManager.ACTION_FROM_ARTICAL)) {
      overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);

      hasTap = true;
    }
  }

  private void loadAdv2(final String callbackId, String documentId) {
    if (!TextUtils.isEmpty(Config.BANNER_DATA)) {
      try {
        final JsonObject jsonObject = new JsonParser().parse(Config.BANNER_DATA).getAsJsonObject();
        IfengNewsApp.getImageLoader().startDownload(
            new LoadContext<String, LoadListener<String>, String>(jsonObject.get("imgUrl")
                .getAsString(), new LoadListener<String>() {
              @Override
              public void loadComplete(LoadContext<?, ?, String> context) {
                jsonObject.addProperty("imgPath", context.getResult());
                Config.BANNER_DATA = jsonObject.toString();
                IfengWebView webView = getCurrentWebview();
                if (webView != null) {
                  getCurrentWebview().loadUrl(
                      "javascript:athene.complete('" + callbackId + "',1" + ",'"
                          + Config.BANNER_DATA + "')");
                  ExposureHandler.putInQueue(Config.BANNER_ADID);
                }
              }

              @Override
              public void loadFail(LoadContext<?, ?, String> arg0) {
                excuteFailed(callbackId);
              }

              @Override
              public void postExecut(LoadContext<?, ?, String> arg0) {}
            }, String.class, LoadContext.FLAG_HTTP_FIRST));

      } catch (Exception e) {
        excuteFailed(callbackId);
      }
    } else {
      excuteFailed(callbackId);
    }
  }

  private void goToSlide(String url) {
    if (TextUtils.isEmpty(url)) {
      return;
    }
    Intent intent = new Intent(this, SlideActivity.class);
    intent.putExtra("isRelationClick", true);
    if (Intent.ACTION_VIEW.equals(getIntent().getAction())) {// fix bug #15936
      intent.setAction(Intent.ACTION_VIEW);
    } else if (ConstantManager.ACTION_FROM_HEAD_IMAGE.equals(getIntent().getAction())) {
      intent.setAction(ConstantManager.ACTION_FROM_HEAD_IMAGE);
    }else if (ConstantManager.ACTION_FROM_RELATIVE.equals(getIntent().getAction())){
    	intent.setAction(ConstantManager.ACTION_FROM_RELATIVE);
    } else {
      intent.setAction(ConstantManager.ACTION_FROM_ARTICAL);
    }
    if (channel != null && !channel.equals(Channel.NULL)) {
      intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
    }
    // fix bug 17228 【分享】相关新闻分享到微信好友、qq好友等没有摘要
    intent.putExtra(ConstantManager.EXTRA_INTRODUCTION, introduction);
    intent.putExtra(SlideActivity.EXTRA_URL, url);
    intent.putExtra(SlideActivity.EXTRA_POSITION, 0);

    startActivity(intent);
    overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
    hasTap = true;
  }

  private void loadAdv01(String advCallbackId, String documentId) {
    if (!TextUtils.isEmpty(Config.TEXT_AD_DATA01)) {
      try {
        getCurrentWebview().loadUrl(
            "javascript:athene.complete('" + advCallbackId + "',1" + ",'"
                + URLEncoder.encode(Config.TEXT_AD_DATA01) + "')");
        ExposureHandler.putInQueue(Config.TEXT_AD_ID01);
      } catch (Exception e) {
        excuteFailed(advCallbackId);
      }
    } else {
      excuteFailed(advCallbackId);
    }
  }

  // 处理新增文字链广告
  private void loadAdv02(String advCallbackId, String documentId) {
    if (!TextUtils.isEmpty(Config.TEXT_AD_DATA02)) {
      try {
        getCurrentWebview().loadUrl(
            "javascript:athene.complete('" + advCallbackId + "',1" + ",'"
                + URLEncoder.encode(Config.TEXT_AD_DATA02) + "')");
        ExposureHandler.putInQueue(Config.TEXT_AD_ID02);
      } catch (Exception e) {
        excuteFailed(advCallbackId);
      }
    } else {
      excuteFailed(advCallbackId);
    }
  }

  private void popupLightbox(String callbackId, String imgUrl) {
    try {
      if (!ImageLoadUtil.isImageExists(imgUrl)
          && !NetworkState.isActiveNetworkConnected(getApplicationContext())) {
        return;
      }
    } catch (Exception e) {
      return;
    }
    Intent intent = new Intent(this, PopupLightbox.class);
    intent.putExtra("imgUrl", imgUrl);
    intent.putExtra("callbackId", callbackId);
    startActivityForResult(intent, 200);
    overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
    hasTap = true;
  }

  // sunquan add for image refresh
  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
    hasTap = false;
    if (resultCode == 100 && data != null) {
      String imageUrl = data.getStringExtra("url");
      String callbackId = data.getStringExtra("callbackId");
      WebView currentWebView = null;
      try {
        currentWebView =
            (WebView) ((LoadableViewWrapper) detailView.getCurrentView()).getWrappedView();
      } catch (Exception e) {
        return;
      }
      if (imageUrl != null && callbackId != null && currentWebView != null) {
        ImageLoadUtil.showImageByJs(currentWebView, callbackId, imageUrl, false);
      }
    } else if (requestCode == 110) {// 这里只能通过requestCode进行识别，resultCode返回一直为0
      updataJs();
    }
  }
  
  @Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
	  	if(savedInstanceState != null) {
	      channel = savedInstanceState.getParcelable("channel");
	      aid = savedInstanceState.getString("aid");
	      isRelationClick = savedInstanceState.getBoolean("isRelationClick");
	      unit = (DocUnit) savedInstanceState.getSerializable("unit");
	    }
		super.onRestoreInstanceState(savedInstanceState);
	}

  private void updataJs() {
    IfengWebView webView = getCurrentWebview();
    if (webView != null && unit.getBody().getSurvey().length > 0
        && !TextUtils.isEmpty(unit.getBody().getSurvey()[0])) {
      webView.loadUrl("javascript:athene.updata('"
          + (RecordUtil.isRecorded(me, unit.getBody().getSurvey()[0], RecordUtil.SURVEY) ? 0 : 1)
          + "')");
    }
  }

  /**
   * 播放视频
   * 
   * @param normalUrl
   * @param HDUrl
   */
  private void playVideo(final String normalUrl, final String HDUrl) {
    // 判断是否支持高清播放
    if (Config.isSupportHdPlay && netWorkAdapter.isConnectedWifi()) {

      if (!TextUtils.isEmpty(HDUrl)) {
        if (PlayVideoActivity.playVideo(DetailActivity.this, HDUrl, unit.getMeta().getDocumentId())) {
          hasTap = true;
        }
      } else {
        if (!TextUtils.isEmpty(normalUrl)) {
          if (PlayVideoActivity.playVideo(DetailActivity.this, HDUrl, unit.getMeta()
              .getDocumentId())) {
            hasTap = true;
          }
        } else {
          showMessage("暂时不能播放哦");
          return;
        }
      }
    } else {
      if (!TextUtils.isEmpty(normalUrl)) {
        if (PlayVideoActivity.playVideo(DetailActivity.this, HDUrl, unit.getMeta().getDocumentId())) {
          hasTap = true;
        }
      } else {
        showMessage("暂时不能播放哦");
        return;
      }

    }
  }

  @Override
  public void initCollectViewState() {
    // collectionDBManager
    // .isCollectioned(getCurrentDocumentId());
  }

  private boolean isCollectState() {
    return collectionDBManager.isCollectioned(getCurrentDocumentId());
  }

  @Override
  public void loadComplete(LoadContext<?, ?, DocUnit> context) {
    DocUnit unit = (DocUnit) context.getResult();
    documentId = unit.getDocumentIdfromMeta();
    if (!TextUtils.isEmpty(documentId)) {
      beginStatistic(documentId);
    }
    if (progressDialog != null) progressDialog.cancel();
    completeRender(unit);
    setCollectView();

  }

  /**
   * 获取加载成功试图所在的位置，并加载内容
   * 
   * @param unit 成功加载得到的unit
   * @param id 加载成功的地址
   */
  private void completeRender(DocUnit unit) {
    this.unit = unit;
    initUnitForJs(unit);
  }

  private void initUnitForJs(DocUnit unit) {
    try {
      if (detailView != null) {
        LoadableViewWrapper wrapper = (LoadableViewWrapper) detailView.getCurrentView();
        renderUnit(wrapper, unit);
      }
    } catch (ArrayIndexOutOfBoundsException e) {
      Log.d("Detail", "" + e.getLocalizedMessage());
      return;
    }
  }

  @Override
  public void loadFail(LoadContext<?, ?, DocUnit> context) {
    loadSuccessful = false;
    if (progressDialog != null) progressDialog.cancel();
    failRender();
  }

  /**
   * 获取加载成功试图所在的位置，并显示失败
   * 
   * @param id 加载失败的地址
   */
  private void failRender() {
    ((LoadableViewWrapper) detailView.getCurrentView()).showRetryView();
  }

  private String getCurrentDocumentId() {
    return unit.getDocumentIdfromMeta();
  }

  private String getArticleTitle() {
    return unit.getBody().getTitle();
  }

  private String getUrlforShare() {
    String url = unit.getBody().getShareurl();
    if (TextUtils.isEmpty(url)) url = unit.getBody().getWapurl();
    return url;
  }

  @Override
  protected void onShare() {
    ShareAlertBig alert =
        new ShareAlertBig(DetailActivity.this, new WXHandler(this), getUrlforShare(),
            getArticleTitle(), getShareContent(), subShareImageUrls(3), unit.getMeta()
                .getDocumentId(), StatisticUtil.StatisticPageType.article);
    alert.show(DetailActivity.this);
  }

  /**
   * 截取原文章的图片列表
   * 
   * @param max 最多显示x张图片
   * @return
   */
  private ArrayList<String> subShareImageUrls(int max) {
    ArrayList<String> images = new ArrayList<String>();
    int currentSize = unit.getBody().getImages(this).size();
    int count = Math.min(max, currentSize);
    for (int i = 0; i < count; i++) {
      images.add(unit.getBody().getImages(this).get(i));
    }
    if(images.size()==0 && !TextUtils.isEmpty(unit.getBody().getThumbnail())) {
    	images.add(unit.getBody().getThumbnail());
    }
    return images;
  }

  /**
   * 简介不为空，去简介作为分享内容，否则取标题
   * 
   * @return
   */
  private String getShareContent() {
    if (!TextUtils.isEmpty(introduction))
      return introduction.length() > Config.SHARE_MAX_LENGTH ? introduction.substring(0,
          Config.SHARE_MAX_LENGTH) + "..." : introduction;
    return getArticleTitle();
  }

  @Override
  public int getBottomTabbarHeight() {
    return detailTabbar.getHeight();
  }

  @Override
  public boolean onCollect() {
    try {
      String docId = unit.getDocumentIdfromMeta();
      if (isCollectState()) {
        cancleCollection(docId);
        windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_collection, R.string.toast_store_cancel_title, R.string.toast_store_cancel_content);
        setCollectView();
      } else {
        ListItem listItem = new ListItem();
        listItem.setId(detailUrl);
        // 优先使用列表传过来的缩略图URL，如果为空则用后台返回的缩略图URL
        listItem.setThumbnail(TextUtils.isEmpty(thumbnaiUrl)
            ? unit.getBody().getThumbnail()
            : thumbnaiUrl);
        listItem.setDocumentId(unit.getDocumentIdfromMeta());
        listItem.setHasVideo(unit.getBody().getHasVideo());
        listItem.setTitle(unit.getBody().getTitle());
        listItem.setIntroduction(introduction);
        listItem.setStatus(true);
        listItem.setTypeIcon((unit.getBody().getSurvey() != null && unit.getBody().getSurvey().length != 0) || (unit.getBody().getVote() != null && unit.getBody().getVote().length != 0) ? CollectionDBManager.TYPE_ICON_SURVEY : "");
        listItem.setType(CollectionDBManager.TYPE_DOC);
        ArrayList<Extension> links = new ArrayList<Extension>();
        Extension extension = new Extension();
        extension.setType("doc");
        links.add(extension);
        listItem.setLinks(links);
        if (collect(listItem)) {
        	windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.toast_store_success_title, R.string.toast_store_success_content);
          setCollectView();
          // 收藏统计
          StatisticUtil.addRecord(this, StatisticRecordAction.action, "type="
              + StatisticPageType.store);
        }
      }
    } catch (Exception e) {
      Log.e("tag", "detail collect");
      e.printStackTrace();
    }
    return true;
  }

  // 设置收藏View的样式
  private void setCollectView() {
    // TODO Auto-generated method stub
    Drawable drawable = null;
    if (isCollectState()) {
      drawable = getResources().getDrawable(R.drawable.collectioned);
    } else {
      drawable = getResources().getDrawable(R.drawable.collection);
    }
    drawable.setBounds(0, 0, drawable.getMinimumWidth(), drawable.getMinimumHeight());
    more_prompt.setCompoundDrawables(drawable, null, null, null);
  }
  
  private boolean prepared() {
    return unit != null;
  }

  @Override
  protected void onResume() {
	StatisticUtil.doc_id = documentId ; 
	StatisticUtil.type = StatisticUtil.StatisticPageType.article.toString() ; 
    super.onResume();
    hasTap = false;
  }

  @Override
  public boolean onKeyUp(int keyCode, KeyEvent event) {
    if (keyCode == KeyEvent.KEYCODE_BACK && View.VISIBLE == detailCommentModule.getVisibility()) {
      updateEditCommentModule(false);
      return true;
    }
    return super.onKeyUp(keyCode, event);
  }

  @Override
  public void onBackPressed() {
	StatisticUtil.isBack = true ; 
    showSoftInput(false);
    if ((ConstantManager.isOutOfAppAction(getIntent().getAction()))
        || getIntent().getBooleanExtra(IntentUtil.EXTRA_REDIRECT_HOME, false)) {
      if (!NewsMasterFragmentActivity.isAppRunning && pageCount == 1) {
        // 列表没有运行且当前正文页是唯一打开的正文页时才跳转到列表页
        IntentUtil.redirectHome(this);
      }
    }
    finish();
    overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);
  }

  private class WebDetailClient extends WebViewClient {
    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
      String openType = null;
      try {
        openType = Uri.parse(url).getQueryParameter("opentype");
      } catch (Exception e) {
        return false;
      }
      if ("out".equals(openType)) {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        Uri content_url = Uri.parse(url);
        intent.setData(content_url);
        if (ConstantManager.ACTION_PUSH.equals(getIntent().getAction())) {
          intent.putExtra("from_ifeng_news", true);
        } else if (channel != null && !channel.equals(Channel.NULL)) {
          intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
        }
        intent.putExtra(ConstantManager.EXTRA_CURRENT_DETAIL_DOCUMENTID, documentId);
        startActivity(intent);
        overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
      } else {
        Intent intent = new Intent(DetailActivity.this, AdDetailActivity.class);
        intent.putExtra("URL", url);
        // intent.putExtra("position", detailView.getCurrentItem());
        startActivity(intent);
        overridePendingTransition(0, R.anim.out_to_right);
      }
      return true;
    }

    @Override
    public void onPageFinished(WebView view, String url) {
      super.onPageFinished(view, url);
    }

  }

  private void startLoadImage(final String callbackId, String url, String forceLoad) {
    loadAndShowImage(callbackId, url, unit, getCurrentWebview(), forceLoad);
  }

  private void loadAndShowImage(final String callbackId, String url, final DocUnit unit,
      final WebView webView, String forceLoad) {
    try {
      ImageLoadUtil.setRequestId(unit.getDocumentIdfromMeta());
    } catch (Exception e) {
      return;
    }
    String imageUrl = FilterUtil.filterImageUrl(url);
    File imgFile = IfengNewsApp.getResourceCacheManager().getCacheFile(url, true);
    // 如果图片已存在，直接显示图片
    if (imgFile != null && imgFile.exists()) {
      ImageLoadUtil.showImageByJs(webView, callbackId, imgFile.getAbsolutePath(), false);
    }
    // 满足以下任意条件，则去网络获取图片
    // 1，wifi网络下
    // 2.移动网络连接，没有关闭2G、3G无图模式开关
    // 3,点击图片重新下载（forceLoad值为forceLoad）
    else if (("forceLoad".equals(forceLoad) || !isSetNoImageModeAnd2G3G())
        && isNetworkConnected(this)) {
      Message msg = new Message();
      Bundle data = new Bundle();
      data.putSerializable("unit", unit);
      data.putSerializable("webView", (Serializable) webView);
      data.putString("imageUrl", imageUrl);
      data.putString("callbackId", callbackId);
      msg.setData(data);
      msg.arg1 = 1;
      myHandler.sendMessage(msg);
    }
    // 不从网络获取图片
    // 如果是forceLoad为‘forceLoad’，则进行成功回调（2G/3G网络下并且只有2G、3G无图模式开启并且第一次请求图片的时候）
    // 其他情况：网络未连接
    else {
      ImageLoadUtil.showImageByJs(webView, callbackId, imageUrl, true, isNetworkConnected(this)
          ? forceLoad
          : "forceLoad");
    }
  }

  public Handler myHandler = new Handler() {
    @Override
    public void handleMessage(Message msg) {
      switch (msg.arg1) {
        case 1:
          Bundle data = null;

          try {
            data = msg.getData();
          } catch (Exception e) {
            data = null;
          }
          if (null == data) return;
          final String imageUrl = data.getString("imageUrl");
          final String callbackId = data.getString("callbackId");
          final DocUnit unit = (DocUnit) data.getSerializable("unit");
          final IfengWebView webView = (IfengWebView) data.getSerializable("webView");
          IfengNewsApp.getImageLoader().startDownload(
              new LoadContext<String, LoadListener<String>, String>(imageUrl,
                  new LoadListener<String>() {
                    @Override
                    public void loadComplete(LoadContext<?, ?, String> context) {
                      String imgPath = context.getResult();
                      imageLoaderCallback(imgPath, context == null, unit.getDocumentIdfromMeta());
                    }

                    @Override
                    public void loadFail(LoadContext<?, ?, String> arg0) {
                      imageLoaderCallback(arg0.getResult(), true, unit.getDocumentIdfromMeta());
                    }

                    private void imageLoaderCallback(String imgPath, boolean isDefault,
                        String currentId) {
                      if (webView != null && !TextUtils.isEmpty(currentId)) {
                        ImageLoadUtil.callBackJsByListener(webView, callbackId, imgPath, isDefault,
                            currentId);
                      }
                    }

                    @Override
                    public void postExecut(LoadContext<?, ?, String> arg0) {}
                  }, String.class, LoadContext.FLAG_HTTP_FIRST));
          break;
        default:
          break;
      }
      super.handleMessage(msg);
    }
  };

  public int defaultSize() {
    FontSize fontSize = getPreferenceFontSize();
    switch (fontSize) {
      case big:
        return 0;
      case mid:
        return 1;
      case small:
        return 2;
      default:
        break;
    }
    return 1;
  }

  private void excuteFailed(String advCallbackId) {
    try {
      WebView currentWebView = getCurrentWebview();
      currentWebView.loadUrl("javascript:athene.complete('" + advCallbackId + "',0)");
    } catch (Exception e) {}
  }

  private IfengWebView getCurrentWebview() {
    if (detailView != null) {
      return (IfengWebView) ((LoadableViewWrapper) detailView.getCurrentView()).getWrappedView();
    }
    return null;
  }

  @Override
  public void postExecut(LoadContext<?, ?, DocUnit> arg0) {
    if (arg0.getResult() == null) return;
    if (!isValid(arg0.getResult())) {
      arg0.setResult(null);
      return;
    }
    if (!arg0.isAutoSaveCache()) {
      BeanLoader.getMixedCacheManager().saveCache(arg0.getParam().toString(), arg0.getResult());
    }
    FontSize fontSize = getPreferenceFontSize();
    arg0.getResult().getBody().formatText(fontSize);

    // fix bug #17155 【离线下载】离线下载之后直接把视频过滤了, 在DocUnitsParser中调用SmartDocUnitParser即可解决此问题
    // if (TextUtils.isEmpty(arg0.getResult().getBody().getVideoJson())) {
    // arg0.getResult().getBody().setVideoJson().setLiveStreamJson();
    // }
  }

  @Override
  public void showShareView() {
    DetailActivity.this.onShare();
  }

  private boolean isValid(DocUnit docUnit) {
    return !TextUtils.isEmpty(docUnit.getDocumentIdfromMeta().trim()) && docUnit.getBody() != null
        && !TextUtils.isEmpty(docUnit.getBody().getText().trim())
        && !docUnit.getBody().getText().trim().equals("<p>");
  }

  /*
   * 微信api借口 微信发送请求到第三方应用时，会回调到该方法
   */
  @Override
  public void onReq(BaseReq req) {
    // TODO Auto-generated method stub
  }

  /*
   * 微信api借口 第三方应用发送到微信的请求处理后的响应结果，会回调到该方法
   */
  @Override
  public void onResp(BaseResp resp) {
    int result = 0;

    switch (resp.errCode) {
      case BaseResp.ErrCode.ERR_OK:
        result = R.string.errcode_success;
        break;
      case BaseResp.ErrCode.ERR_USER_CANCEL:
        result = R.string.errcode_cancel;
        break;
      case BaseResp.ErrCode.ERR_AUTH_DENIED:
        result = R.string.errcode_deny;
        break;
      default:
        result = R.string.errcode_unknown;
        break;
    }
    Toast.makeText(DetailActivity.this, result, Toast.LENGTH_SHORT).show();
  }

  @Override
  public void onFling(int flingState) {
    if (flingState == OnFlingListener.FLING_RIGHT) {
      onBackPressed();
    } else {
      if (unit != null) {
        showComments();
      }
    }
  }

  @Override
  public void downloadPicture() {

  }

  @Override
  public boolean dispatchKeyEvent(KeyEvent event) {
    if (firstRun) {
      firstRun = false;
      this.findViewById(R.id.tips_detail).setVisibility(View.GONE);
      return true;
    }
    return super.dispatchKeyEvent(event);
  }

  @Override
  public boolean dispatchTouchEvent(MotionEvent ev) {
    if (firstRun) {
      firstRun = false;
      this.findViewById(R.id.tips_detail).setVisibility(View.GONE);
      return true;
    }
    return super.dispatchTouchEvent(ev);
  }
  
  private class TaskDataWrapper {
	  /**
	   * loadImage(final String callbackId, final String url, final String documentId,
        final String forceLoad) 
	   */
	  public final String callId;
	  public final String url;
	  public final String docId;
	  public final String forceLoad;
	  public TaskDataWrapper(String callId, String url, String docId, String forceLoad) {
		this.callId = callId;  
		this.docId = docId;
		this.url = url;
		this.forceLoad = forceLoad;
	  }
  }
  
  private List<TaskDataWrapper> tasks = new LinkedList<TaskDataWrapper>();
  private ImageDownloadWorker workerThread = null;
  
  private class SetImageTask implements Runnable {
	  private String callbackId;
	  private String path;
	  private boolean isDefault;
	  private String forceLoad = null;
	 public SetImageTask(String callbackId, String path, boolean isDefault) {
		 this.callbackId = callbackId;
		 this.path = path;
		 this.isDefault = isDefault;
	 }
	 public SetImageTask(String callbackId, String path, boolean isDefault, String forceLoad) {
		 this.callbackId = callbackId;
		 this.path = path;
		 this.isDefault = isDefault;
		 this.forceLoad = forceLoad;
	 }
	 
	  @Override
	public void run() {
		  if (null == forceLoad)
			  ImageLoadUtil.showImageByJs(getCurrentWebview(), callbackId, path, isDefault);
		  else
			  ImageLoadUtil.showImageByJs(getCurrentWebview(), callbackId, path, true, forceLoad); 
	}
  }

  private class ImageDownloadWorker extends Thread {
	  
	  Iterator<TaskDataWrapper> it = tasks.iterator();
	  TaskDataWrapper taskData = null;
	  String imageUrl = null;
	  File imgFile = null;
	  File file = null;
	  
	public ImageDownloadWorker() {
		ImageLoadUtil.setRequestId(unit.getDocumentIdfromMeta());
	}
	  @Override
	public void run() {
		while (it.hasNext() && !this.isInterrupted()) {
			taskData = it.next();
			imageUrl = FilterUtil.filterImageUrl(taskData.url);
			imgFile = IfengNewsApp.getResourceCacheManager().getCacheFile(imageUrl, true);
		    // 如果图片已存在，直接显示图片
		    if (imgFile != null && imgFile.exists()) {
		    	runOnUiThread(new SetImageTask(taskData.callId, imgFile.getAbsolutePath(), false));
		      
		    }
		    // 满足以下任意条件，则去网络获取图片
		    // 1，wifi网络下
		    // 2.移动网络连接，没有关闭2G、3G无图模式开关
		    // 3,点击图片重新下载（forceLoad值为forceLoad）
		    else if (("forceLoad".equals(taskData.forceLoad) || !isSetNoImageModeAnd2G3G())
		        && isNetworkConnected(DetailActivity.this)) {
		    	HttpURLConnection connection;
				try {
					connection = HttpManager.getUrlConnection(imageUrl);
				
					if (connection.getResponseCode() != 200) {
						throw new IOException("responseCode:"
								+ connection.getResponseCode() + " response message:"
								+ connection.getResponseMessage());
					}
					InputStream is=connection.getInputStream();
					String encoding=connection.getHeaderField("Content-Encoding");
					if(encoding!=null && Pattern.compile("gzip", Pattern.CASE_INSENSITIVE).matcher(encoding).find())
					{
						is=new GZIPInputStream(is);
					}
					
					if (is != null) {
						file = ImageLoader.getResourceCacheManager().getCacheFile(imageUrl);
						Files.write(file, is);
						if (null != file && file.exists()) {
							// load successfully
							Log.i("Sdebug", "download image successful, path: " + file.getAbsolutePath());
							runOnUiThread(new SetImageTask(taskData.callId, file.getAbsolutePath(), false));
							continue;
						}
						
					}
					runOnUiThread(new SetImageTask(taskData.callId, null, true));
					
				} 
				//这里抛出的可能是runtimeException，所以catch住所有异常
				catch (Exception e) {
					e.printStackTrace();
					//如果出现异常，则删除无效文件
					if(file!=null){
						file.delete();
					}
					runOnUiThread(new SetImageTask(taskData.callId, null, true));
					Log.w("Sdebug", "Failed to download image: " + imageUrl, e);
				}
		    }
		    // 不从网络获取图片
		    // 如果是forceLoad为‘forceLoad’，则进行成功回调（2G/3G网络下并且只有2G、3G无图模式开启并且第一次请求图片的时候）
		    // 其他情况：网络未连接
		    else {
		    	runOnUiThread(new SetImageTask(taskData.callId, imageUrl, true, isNetworkConnected(DetailActivity.this)
				          ? taskData.forceLoad
				          : "forceLoad"));
		    }
//		    it.remove();
		}
	}
  }

}
