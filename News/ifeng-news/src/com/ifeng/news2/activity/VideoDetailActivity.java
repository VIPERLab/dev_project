package com.ifeng.news2.activity;

import java.util.ArrayList;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengLoadableActivity;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.VideoDetailBean;
import com.ifeng.news2.bean.VideoDetailInfo;
import com.ifeng.news2.fragment.NewsMasterFragmentActivity;
import com.ifeng.news2.share.ShareAlertBig;
import com.ifeng.news2.share.WXHandler;
import com.ifeng.news2.util.AutoResizeTextView;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.DateUtil;
import com.ifeng.news2.util.ImageLoadUtil;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.WindowPrompt;
import com.ifeng.news2.video.build.VideoRelativeBuilder;
import com.ifeng.news2.widget.IfengBottom;
import com.ifeng.news2.widget.IfengBottomTitleTabbar;
import com.ifeng.news2.widget.ListViewWithFlingDetector;
import com.ifeng.news2.widget.LoadableViewWrapper;
import com.ifeng.share.util.NetworkState;
import com.qad.cache.ResourceCacheManager;
import com.qad.loader.ImageLoader.ImageDisplayer;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.loader.RetryListener;
import com.qad.loader.StateAble;
import com.qad.system.adapter.NetWorkAdapter;
import com.qad.util.OnFlingListener;

/**
 * 视频正文页
 * 
 * @author chenxi
 * 
 */
public class VideoDetailActivity extends IfengLoadableActivity<VideoDetailBean>
    implements
      OnClickListener,
      LoadListener<VideoDetailBean>,
      OnFlingListener {

  private View mVideoDetailView;
  private LoadableViewWrapper mWrapper;
  private LayoutInflater inflater;
  private ListViewWithFlingDetector mIfengListView;
  private IfengBottomTitleTabbar mBottomTitleTabber;
  private ImageView mVideoHeadImg;
  private AutoResizeTextView mVideoTitleTxt;
  private TextView mVideoDateTxt;
  private TextView mVideoChannelTxt;
  private View mBackView;
  private View mShareView;
  private RelativeLayout mVideoHeadCover;
  private String mVideoDetailId;// video id
  private String mVideoDetailLastId;// video last id
  private String mVideoDetailUrl;
  private String mVideoURLLow = "";
  private String mVideoURLHigh = "";
  private View mVideoDetailContent;
  // private LinearLayout mVideoRichCover;
  private VideoDetailBean mVideoDetailBean;
  private VideoDetailInfo mVideoDetailInfo;
  private WebView mVideoRichWeb;
  private String videoTitle = null;
  //  private boolean isMemeryCache = false; 
  private Channel mChannel;
  private String mPreDocumentId ="";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    // TODO Auto-generated method stub
    super.onCreate(savedInstanceState);
    initViews();
    setWrapper();
    setContentView(mWrapper);
    // 加载数据
    startLoadingData();
  }

  // 初始化
  private void initViews() {
    inflater = LayoutInflater.from(this);
    mVideoDetailView = (View) inflater.inflate(R.layout.video_detail, null);
    mIfengListView =
        (ListViewWithFlingDetector) mVideoDetailView.findViewById(R.id.video_detail_listview);
    mBottomTitleTabber = (IfengBottomTitleTabbar) mVideoDetailView.findViewById(R.id.detail_tabbar);

    mVideoDetailContent = inflater.inflate(R.layout.video_detail_content, null);

    mVideoHeadCover = (RelativeLayout) mVideoDetailContent.findViewById(R.id.video_head_rl);
    mVideoHeadImg = (ImageView) mVideoDetailContent.findViewById(R.id.video_head_img);

    mVideoTitleTxt = (AutoResizeTextView) mVideoDetailContent.findViewById(R.id.video_title_tv);
    mVideoDateTxt = (TextView) mVideoDetailContent.findViewById(R.id.video_date_tv);
    mVideoChannelTxt = (TextView) mVideoDetailContent.findViewById(R.id.video_channel_tv);
    mVideoRichWeb = (WebView) mVideoDetailContent.findViewById(R.id.video_description_web);

    mBackView = mBottomTitleTabber.findViewById(R.id.back);
    mShareView = mBottomTitleTabber.findViewById(R.id.more);

    setViewListener();
  }

  private void setViewListener() {
    // TODO Auto-generated method stub
    mVideoHeadCover.setOnClickListener(this);
    mBackView.setOnClickListener(this);
    mShareView.setOnClickListener(this);

    mIfengListView.setDivider(null);
    mIfengListView.setOnFlingListener(this);

  }

  private void setWrapper() {
    // TODO Auto-generated method stub
    mWrapper = new LoadableViewWrapper(this, mVideoDetailView, getRetryView(), null);
    mWrapper.setOnRetryListener(new RetryListener() {

      @Override
      public void onRetry(View arg0) {
        startLoadingData();
      }

    });
    mWrapper.setBackgroundResource(R.drawable.channellist_selector);
  }

  private View getRetryView() {
    View retryView = inflater.inflate(R.layout.load_fail_with_bottom_bar, null);
    ((IfengBottom) retryView.findViewById(R.id.ifeng_bottom_4_load_fail)).getBackButton()
        .setOnClickListener(new OnClickListener() {

          @Override
          public void onClick(View v) {
            onBackPressed();
          }
        });
    return retryView;
  }

  private void startLoadingData() {
    mWrapper.showLoading();
    concatUrl();
    IfengNewsApp.getBeanLoader().startLoading(
        new LoadContext<String, LoadListener<VideoDetailBean>, VideoDetailBean>(mVideoDetailUrl,
            VideoDetailActivity.this, VideoDetailBean.class, Parsers.newVideoDetailParser(), false,
            LoadContext.FLAG_HTTP_FIRST, false));
  }

  private void concatUrl() {
    // TODO Auto-generated method stub
    // 获取intent数据
    getIntentData();
    if (!TextUtils.isEmpty(mVideoDetailId) && !TextUtils.isEmpty(mVideoDetailLastId)) {
      mVideoDetailUrl = String.format(Config.VIDEO_DETAIL_URL, mVideoDetailLastId, mVideoDetailId);
    }
  }

  private void getIntentData() {
    mVideoDetailId = getIntent().getStringExtra(ConstantManager.EXTRA_VIDEO_DETAIL_ID);
    mVideoDetailLastId = getIntent().getStringExtra(ConstantManager.EXTRA_VIDEO_DETAIL_ID_LAST);
    mChannel = (Channel) getIntent().getExtras().get(ConstantManager.EXTRA_CHANNEL);
    mPreDocumentId = getIntent().getStringExtra(ConstantManager.EXTRA_CURRENT_DETAIL_DOCUMENTID);
  }
  
  @Override
	protected void onResume() {
		// TODO Auto-generated method stub
	  StatisticUtil.doc_id = mVideoDetailId ; 
	  StatisticUtil.type = StatisticUtil.StatisticPageType.video.toString(); 
		super.onResume();
	}

  @Override
  public void onBackPressed() {
	  StatisticUtil.isBack = true ; 
    // TODO Auto-generated method stub
    if (ConstantManager.isOutOfAppAction(getIntent().getAction())
        || getIntent().getBooleanExtra(IntentUtil.EXTRA_REDIRECT_HOME, false)) {
      if (!NewsMasterFragmentActivity.isAppRunning) {
        IntentUtil.redirectHome(this);
      }
    }
    finish();
    overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
  }

  @Override
  public void onClick(View v) {
    // TODO Auto-generated method stub
    switch (v.getId()) {
      case R.id.video_head_rl:
        playVideoByNetState();
        break;
      case R.id.more:
        shareContent();
        break;
      case R.id.back:
        onBackPressed();
        break;
    }
  }

  private void playVideoByNetState() {
    if (NetworkState.isActiveNetworkConnected(VideoDetailActivity.this)
        && !NetworkState.isWifiNetworkConnected(VideoDetailActivity.this)) {
      AlertDialog.Builder alertBuilder = new AlertDialog.Builder(VideoDetailActivity.this);
      AlertDialog alertPlayIn2G3GNet =
          alertBuilder
              .setCancelable(true)
              .setMessage(getResources().getString(R.string.video_dialog_play_or_not))
              .setPositiveButton(getResources().getString(R.string.video_dialog_positive),
                  new DialogInterface.OnClickListener() {

                    @Override
                    public void onClick(DialogInterface dialog, int which) {

                      playVideo();
                    }
                  })
              .setNegativeButton(getResources().getString(R.string.video_dialog_negative),
                  new DialogInterface.OnClickListener() {

                    @Override
                    public void onClick(DialogInterface dialog, int which) {

                    }
                  }).create();
      alertPlayIn2G3GNet.show();
    } else {

      playVideo();
    }


  }

  // 播放视频
  private void playVideo() {
    Intent intent = new Intent(this, PlayVideoActivity.class);
//    intent.putExtra("title", videoTitle);
    intent.putExtra("id", "video_"+mVideoDetailId);
    // 判断是否支持高清播放
    if (Config.isSupportHdPlay && new NetWorkAdapter(this).isConnectionFast()) {
      if (!TextUtils.isEmpty(mVideoURLHigh)) {
        intent.putExtra("path", mVideoURLHigh);
      } else {
        if (!TextUtils.isEmpty(mVideoURLLow)) {
          intent.putExtra("path", mVideoURLLow);
        } else {
          showMessage("暂时不能播放哦");
          return;
        }
      }
    } else {
      if (!TextUtils.isEmpty(mVideoURLLow)) {
        intent.putExtra("path", mVideoURLLow);
      } else {
        showMessage("暂时不能播放哦");
        return;
      }
    }
    startActivity(intent);
    overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
  }


  private void shareContent() {
    // TODO Auto-generated method stub
    if (mVideoDetailBean != null && !mVideoDetailBean.getSingleVideoInfo().isEmpty()) {
      mVideoDetailInfo = mVideoDetailBean.getSingleVideoInfo().get(0);
      onShare();
    }
  }

  // 分享
  private void onShare() {
    // TODO Auto-generated method stub
    ShareAlertBig alert =
        new ShareAlertBig(me, new WXHandler(this), getShareUrl(), getShareTitle(),
            getShareContent(), getShareImage(), getDocumentId(),
            StatisticUtil.StatisticPageType.article);
    alert.show(me);
  }

  private String getShareUrl() {
    return String.format(Config.VIDEO_DETAIL_SHARE_URL,mVideoDetailId);
  }

  private String getShareTitle() {
    return mVideoDetailInfo.getTitle();
  }

  private String getShareContent() {
    return mVideoDetailInfo.getTitle();
  }

  private ArrayList<String> getShareImage() {
    ArrayList<String> imgUrls = new ArrayList<String>();
    imgUrls.add(mVideoDetailInfo.getLargeImgURL());
    return imgUrls;
  }

  private String getDocumentId() {
    return mVideoDetailInfo.getGUID();
  }


  @Override
  public void postExecut(LoadContext<?, ?, VideoDetailBean> context) {
    // TODO Auto-generated method stub
    mVideoDetailBean = context.getResult();
    if (mVideoDetailBean == null) {
      return;
    }
    if (!isValidData(mVideoDetailBean)) {
      context.setResult(null);
    }
    super.postExecut(context);
  }

  @Override
  public void loadComplete(LoadContext<?, ?, VideoDetailBean> context) {
    // TODO Auto-generated method stub
    mWrapper.showNormal();
    mVideoDetailBean = context.getResult();
    ArrayList<VideoDetailInfo> videoDetailInfos = mVideoDetailBean.getSingleVideoInfo();
    completeRender(videoDetailInfos);
    VideoRelativeBuilder relativeBuilder =
        new VideoRelativeBuilder(mIfengListView, this, mVideoDetailId, mVideoDetailLastId);
    relativeBuilder.initDatas();
    
    // 发送统计
    videoTitle = mVideoDetailBean.getSingleVideoInfo().get(0).getTitle();
    beginStatistic("video_"+mVideoDetailId);
   /* StatisticUtil.addRecord(StatisticUtil.StatisticRecordAction.page
			, "id=video_"+mVideoDetailId+"$ref=phtv$type="+ StatisticUtil.StatisticPageType.video);*/ 
  }

  @Override
  public void loadFail(LoadContext<?, ?, VideoDetailBean> context) {
    // TODO Auto-generated method stub
    mWrapper.showRetryView();
  }

  private boolean isValidData(VideoDetailBean videoDetailBean) {
    ArrayList<VideoDetailInfo> infos = videoDetailBean.getSingleVideoInfo();
    boolean isValid = infos != null && !infos.isEmpty() && infos.get(0) != null;
    return isValid;
  }

  // 绘制
  private void completeRender(ArrayList<VideoDetailInfo> videoDetailInfos) {
    // TODO Auto-generated method stub
    for (VideoDetailInfo videoDetailInfo : videoDetailInfos) {
      if (TextUtils.isEmpty(videoDetailInfo.getLargeImgURL())){
        if(!TextUtils.isEmpty(videoDetailInfo.getImgURL()))
          renderHeadImg(videoDetailInfo.getImgURL());
      }else{
          renderHeadImg(videoDetailInfo.getLargeImgURL());
      }
      mVideoChannelTxt.setText(videoDetailInfo.getColumnName());
      mVideoTitleTxt.setText(videoDetailInfo.getTitle());
      mVideoDateTxt.setText(DateUtil.formatDateTIme(videoDetailInfo.getVideoPublishTime()));
      String richText = videoDetailInfo.getRichText();
      if (!TextUtils.isEmpty(richText)) {
        String formatHtml = formatHtmlText(richText);
        mVideoRichWeb.setVisibility(View.VISIBLE);
        initWebViewSettings(mVideoRichWeb, formatHtml);
      } else {
        mVideoRichWeb.setVisibility(View.GONE);
      }
      mVideoURLLow = videoDetailInfo.getVideoURLLow();
      mVideoURLHigh = videoDetailInfo.getVideoURLHigh();
    }
    mIfengListView.addHeaderView(mVideoDetailContent,null,false);
  }

  private String formatHtmlText(String richText) {
    // TODO Auto-generated method stub
    return richText.trim().replace("&nbsp;<img ", "<img ").replace("img>&nbsp;", "img>");
  }

  //初始化webview
  private void initWebViewSettings(WebView web, String htmlStr) {
    // TODO Auto-generated method stub
    web.clearHistory();
    web.getSettings().setJavaScriptEnabled(true);
    web.getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
    web.addJavascriptInterface(new JsInterface(), "ifeng");
    web.addJavascriptInterface(htmlStr, "datas");
    web.loadUrl("file:///android_asset/video_detail_page.html");
  }

  private void renderHeadImg(String imgURL) {
    // TODO Auto-generated method stub
//    if(ResourceCacheManager.getInstance().getFromMemCache(imgURL) != null){
//        isMemeryCache = true ; 
//    }
    IfengNewsApp.getImageLoader().startLoading(
        new LoadContext<String, ImageView, Bitmap>(imgURL, mVideoHeadImg, Bitmap.class,
            LoadContext.FLAG_CACHE_FIRST, VideoDetailActivity.this), new ImageDisplayer() {

          @Override
          public void prepare(ImageView img) {
            // TODO Auto-generated method stub
            BitmapDrawable bd =
                (BitmapDrawable) getResources().getDrawable(drawable.video_head_img_default);
            Bitmap bm = bd.getBitmap();
            img.setImageBitmap(bm);
          }

          @Override
          public void display(ImageView img, BitmapDrawable bmp) {
            // TODO Auto-generated method stub
            if (bmp == null) {// || bmp.isRecycled()) {
              BitmapDrawable bd =
                  (BitmapDrawable) getResources().getDrawable(drawable.video_head_img_default);
//              Bitmap bm = bd.getBitmap();
              img.setImageDrawable(bd);
            } else {
              img.setImageDrawable(bmp);
            }
          }

          @Override
          public void display(ImageView img, BitmapDrawable bmp, Context ctx) {
            // TODO Auto-generated method stub
            if (bmp == null) {// || bmp.isRecycled()) {
              BitmapDrawable bd =
                  (BitmapDrawable) getResources().getDrawable(drawable.video_head_img_default);
//              Bitmap bm = bd.getBitmap();
              img.setImageDrawable(bd);
            } else {
              img.setImageDrawable(bmp);
              if (null != ctx) {
                // fade in 动画效果
                Animation fadeInAnimation = AnimationUtils.loadAnimation(ctx, R.anim.fade_in);
                img.startAnimation(fadeInAnimation);
              }
            }
          }

          @Override
          public void fail(ImageView img) {
            // TODO Auto-generated method stub

          }
        });
  }

  @Override
  public void onFling(int flingState) {
    if (flingState == OnFlingListener.FLING_RIGHT) {
      onBackPressed();
    } else {
      // 左滑评论页？
    }
  }

  @Override
  public Class<VideoDetailBean> getGenericType() {
    // TODO Auto-generated method stub
    return VideoDetailBean.class;
  }

  @Override
  public StateAble getStateAble() {
    // TODO Auto-generated method stub
    return mWrapper;
  }
  
  @Override
  protected void onDestroy() {
    // TODO Auto-generated method stub
    super.onDestroy();
// 由RecyclingBitmapDrawable负责判断bitmap是否可以回收，故不需要再在这个处理回收
//    if(!isMemeryCache){
//      Bitmap bitmap = ((BitmapDrawable)mVideoHeadImg.getDrawable()).getBitmap();
//      if(bitmap != null && android.os.Build.VERSION.SDK_INT < 11){
//        bitmap.recycle();
//        Log.d("Other", "bitmap ="+bitmap);
//      }
//    }
  }


  /**
   * 跳转灯箱
   * @param imgUrl
   */
  private void popupLightbox(String imgUrl) {
    try {
      if (!ImageLoadUtil.isImageExists(imgUrl) && !NetworkState.isActiveNetworkConnected(this)) {
    	 windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
        return;
      }
    } catch (Exception e) {
      return;
    }
    Intent intent = new Intent(this, PopupLightbox.class);
    intent.putExtra("imgUrl", imgUrl);
    startActivity(intent);
    overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
  }

  private class JsInterface {

    @SuppressWarnings("unused")
    public void popupLightbox(final String imgUrl) {
      runOnUiThread(new Runnable() {
        public void run() {
          VideoDetailActivity.this.popupLightbox(imgUrl);
        }
      });
    }
  }
  
  
//在文章加载完成后进行统计，和IOS保持一致
 private void beginStatistic(String documentId) {
   // 从推送进入文章的统计
   if (ConstantManager.ACTION_PUSH.equals(getIntent().getAction())) {
     // 文章打开统计
     StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
         "id=" + documentId + "$ref=push$type=" + StatisticUtil.StatisticPageType.video);

     // 推送打开统计，推送打开需要去掉系统标识 imcp
     String docId = documentId;
     if (documentId.startsWith("video_")) {
       docId = documentId.split("_")[1];
     }
     StatisticUtil.addRecord(getApplicationContext(),
         StatisticUtil.StatisticRecordAction.openpush, "aid=" + docId + "$type=n");
   }
   // 从新闻列表进入文章的推送统计
   else if (ConstantManager.ACTION_FROM_APP.equals(getIntent().getAction())
       || ConstantManager.ACTION_FROM_SLIDE_URL.equals(getIntent().getAction())) {
     if (mChannel != null) {
       // 文章打开统计
      if (!mChannel.equals(Channel.NULL)) {
         StatisticUtil.addRecord(getApplicationContext(),
             StatisticUtil.StatisticRecordAction.page,
             "id=" + documentId + "$ref=" + mChannel.getStatistic() + "$type="
                 + StatisticUtil.StatisticPageType.video);
       } else {
         // fix bug #18093 推送打开相关文章，来源为空。
         StatisticUtil.addRecord(getApplicationContext(),
             StatisticUtil.StatisticRecordAction.page, "id=" + documentId + "$ref=push$type="
                 + StatisticUtil.StatisticPageType.video);
       }
     }
     //相关视频打开文章
   } else if (ConstantManager.ACTION_FROM_RELATIVE.equals(getIntent().getAction())){
  	 if(!TextUtils.isEmpty(mPreDocumentId))
  	 	StatisticUtil.addRecord(getApplicationContext(),
               StatisticUtil.StatisticRecordAction.page, "id=" + documentId + "$ref="+mPreDocumentId+"$type="
                   + StatisticUtil.StatisticPageType.video+"$tag=t5");
     // 凤凰快讯进入文章统计
   } else if (ConstantManager.ACTION_PUSH_LIST.equals(getIntent().getAction())) {
     // 推送打开统计，推送打开需要去掉系统标识 imcp
     // 文章打开
     StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
         "id=" + documentId + "$ref=pushlist$type=" + StatisticUtil.StatisticPageType.video);
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
               + StatisticUtil.StatisticPageType.video);
     }
   }
   // 头条焦点图进入文章的PA统计
   else if (ConstantManager.ACTION_FROM_HEAD_IMAGE.equals(getIntent().getAction())) {
     StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
         "id=" + documentId + "$ref=phtv$type=" + StatisticUtil.StatisticPageType.video+"$tag=t3");
   } else if (Intent.ACTION_VIEW.equals(getIntent().getAction())) {
     if (getIntent().hasExtra("from_ifeng_news")) {
       // 推送文章内链
       StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
           "id=" + documentId + "$ref="+mPreDocumentId+"$type=" + StatisticUtil.StatisticPageType.video);
     } else if (getIntent().hasExtra(ConstantManager.EXTRA_CHANNEL)) {
       // 普通文章内链
       StatisticUtil.addRecord(
           getApplicationContext(),
           StatisticUtil.StatisticRecordAction.page,
           "id="
               + documentId
               + "$ref="+mPreDocumentId+ "$type=" + StatisticUtil.StatisticPageType.video);
     } else {
       // 从分享渠道打开文章
       StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
           "id=" + documentId + "$ref=outside$type=" + StatisticUtil.StatisticPageType.video);
     }
   } else if (ConstantManager.ACTION_FROM_COLLECTION.equals(getIntent().getAction())) {
     // 从收藏打开文章
     StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
         "id=" + documentId + "$ref=collect$type=" + StatisticUtil.StatisticPageType.video);
     // 从widget进入文章统计
   } else if (ConstantManager.ACTION_WIDGET.equals(getIntent().getAction())) {
     // 文章打开统计
     StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
         "id=" + documentId + "$ref=desktop$type=" + StatisticUtil.StatisticPageType.video);

   } else if (ConstantManager.ACTION_SPOER_LIVE.equals(getIntent().getAction())) {
     // 从体育直播的战报中打开文章统计
     StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
         "id=" + documentId + "$ref=sports$type=" + StatisticUtil.StatisticPageType.video);
   } else {
     // 默认算作从首页打开
     StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
         "id=" + documentId + "$ref=phtv$type=" + StatisticUtil.StatisticPageType.video);
   }
 }
 

}
