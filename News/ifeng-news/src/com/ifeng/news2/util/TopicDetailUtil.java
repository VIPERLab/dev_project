package com.ifeng.news2.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.graphics.drawable.BitmapDrawable;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout.LayoutParams;
import android.widget.TextView;
import android.widget.Toast;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.id;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.activity.CommentsActivity;
import com.ifeng.news2.activity.TopicDetailModuleActivity;
import com.ifeng.news2.adapter.IfengGridViewAdapter;
import com.ifeng.news2.adapter.TopicDetailAdapter;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.SurveyInfo;
import com.ifeng.news2.bean.SurveyItem;
import com.ifeng.news2.bean.SurveyUnit;
import com.ifeng.news2.bean.TopicContent;
import com.ifeng.news2.bean.TopicSubject;
import com.ifeng.news2.topic_module.VoteModuleNew;
import com.ifeng.news2.util.ListDisplayStypeUtil.ChannelViewHolder;
import com.ifeng.news2.util.PhotoModeUtil.PhotoMode;
import com.ifeng.news2.vote.entity.VoteData;
import com.ifeng.news2.widget.HeadImage;
import com.ifeng.news2.widget.IfengGridView;
import com.ifeng.news2.widget.TopicAlbumImageView;
import com.ifeng.news2.widget.TopicFocusImageView;
import com.ifeng.share.util.NetworkState;
import com.qad.loader.ImageLoader;
import com.qad.loader.ImageLoader.DisplayShow;
import com.qad.loader.ImageLoader.ImageDisplayer;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import java.io.File;
import java.text.DecimalFormat;
import java.util.ArrayList;

/**
 * @author liu_xiaoliang
 * 
 */
public class TopicDetailUtil {

  //TODO IOS没有图集样式　我暂时注释掉
  public static final int[] layouts = {layout.topic_mutil_title_module, layout.text_module,
                                       layout.topic_link_module,  layout.widget_topic_list_item_new, 
                                       layout.album_module_new, layout.topic_survey_layout, 
                                       layout.topic_comment_list_item, layout.topic_default_layout,};

  private static final ListDisplayStypeUtil listDisplayStypeUtil = new ListDisplayStypeUtil();

  private static final float LIANGHUI_SUPER_TITLE_RATIO = 640/(float)306;
  private static final String IFENGNAME = "凤凰网";
  private static final String NETFRIEND = "网友";
  private static HeadImage headImage = null;
  private static VoteModuleNew topicVote = null;
  private static String TYPE = "normal";

  /**
   * V4.1.2 版本对动态专题重构，其中listItem、。。。。为自定义类型，接口中没有       
   * 接口中没有slides类型
   */
  public final static String SUPER_MODULE_TITLE_TYPE = "multiTitle";  // 整合标题、摘要、单焦点图
  public final static String SOLOIMAGE_MODULE_TYPE = "soloImage";     // 单焦点图
  public final static String COMMENT_MODULE_TYPE = "comment";         // 每行两个链接
  public final static String SLIDEER_MODULE_TYPE = "slider";          // 幻灯
  public final static String SURVEY_MODULE_TYPE = "survey";           // 调查
  public final static String LINKS_MODULE_TYPE = "links";             // 多链接
  public final static String ALBUM_MODULE_TYPE = "album";             // 每行两个链接
  public final static String TEXT_MODULE_TYPE = "text";               // 摘要
  public final static String LIST_MODULE_TYPE = "list";               // 资讯
  public final static String VOTE_MODULE_TYPE = "vote";               // 投票


  public static boolean isBuilder(TopicSubject subject) {
    String currentType = subject.getView();
    ArrayList<TopicContent> topicContents = subject.getPodItems();
    if ((SUPER_MODULE_TITLE_TYPE.equals(currentType) || TEXT_MODULE_TYPE.equals(currentType))
        && subject.getContent() != null) {
      return true;
    } else if ((LINKS_MODULE_TYPE.equals(currentType) || LIST_MODULE_TYPE.equals(currentType)
        || ALBUM_MODULE_TYPE.equals(currentType) || VOTE_MODULE_TYPE.equals(currentType) 
        || SURVEY_MODULE_TYPE.equals(currentType) || SLIDEER_MODULE_TYPE.equals(currentType))
        && (topicContents == null || topicContents.size() != 0)) {
      return true;
    } else {
      return false;
    } 
  }

  public static int resetCount(ArrayList<TopicSubject> topicSubjects) {
    int count = 0;
    for (int i = 0; i < topicSubjects.size(); i++) {
      TopicSubject topicSubject = topicSubjects.get(i);
      String currentType = topicSubject.getView();
      if (LIST_MODULE_TYPE.equals(currentType)) {
        topicSubject.setStartPosition(count);
        count += topicSubject.getPodItems().size() - 1;
        topicSubject.setEndPosition(count);
        count++;
      } else if (ALBUM_MODULE_TYPE.equals(currentType)) {
        topicSubject.setStartPosition(count);
        count += topicSubject.getPodItems().size() / 2 + topicSubject.getPodItems().size() % 2 - 1;
        topicSubject.setEndPosition(count);
        count++;
      } else {
        topicSubject.setStartPosition(count);
        topicSubject.setEndPosition(count);
        count++;
      }
    }
    return count;
  }

  public static Object getTopicItem(int position, ArrayList<TopicSubject> topicSubjects){
    for (int i = 0; i < topicSubjects.size(); i++) {
      TopicSubject topicSubject = topicSubjects.get(i);
      if (topicSubject.getStartPosition() <= position && topicSubject.getEndPosition() >= position) {
        return topicSubject;
      }
    }
    return null;
  }

  public static int getResLayoutPositon(TopicSubject subject) {

    String currentType = subject.getView();

    if (SUPER_MODULE_TITLE_TYPE.equals(currentType)) {   // super title
      return 0;
    } else if (TEXT_MODULE_TYPE.equals(currentType)) {   // 摘要模块
      return 1;
    } else if (LINKS_MODULE_TYPE.equals(currentType)) {  // 多连接模块
      return 2;
    } else if (LIST_MODULE_TYPE.equals(currentType)) {   // 重构专题列表
      return 3;
    }else if (ALBUM_MODULE_TYPE.equals(currentType)) {   // 一行两链接
      return 4;
    } else if (SURVEY_MODULE_TYPE.equals(currentType)) { //调查
      return 5; 
    }else if (COMMENT_MODULE_TYPE.equals(currentType)) { // 一行两链接
      return 6;
    } else if (VOTE_MODULE_TYPE.equals(currentType)) {   // 投票  
      return 7;
    } else if (SLIDEER_MODULE_TYPE.equals(currentType)) {// 幻灯 
      return 7;
    } else {
      return 7;//默认
    }

  }

  public static TopicDetailViewHolder getTopicHolder(TopicSubject subject, View view) {
    String currentType = subject.getView();
    TopicDetailViewHolder topicDetailViewHolder = null;
    if (SUPER_MODULE_TITLE_TYPE.equals(currentType)) {   // super title
      topicDetailViewHolder = new TopicSuperTitleHolder();
    } else if (TEXT_MODULE_TYPE.equals(currentType)) {   // 摘要模块
      topicDetailViewHolder = new TopicTextHolder();
    } else if (LINKS_MODULE_TYPE.equals(currentType)) {  // 多连接模块
      topicDetailViewHolder = new TopicLinkHolder();
    } else if (LIST_MODULE_TYPE.equals(currentType)) {   // 资讯模块
      topicDetailViewHolder = new TopicListHolder();
    } else if (ALBUM_MODULE_TYPE.equals(currentType)) {  // 一行两链接
      topicDetailViewHolder = new TopicAlbumHolder();
    } else if (VOTE_MODULE_TYPE.equals(currentType)) {   // 投票 topicDetailViewHolder = new
      topicDetailViewHolder = new TopicDefaultHolder(); 
    } else if (SURVEY_MODULE_TYPE.equals(currentType)) { // 调查
      topicDetailViewHolder = new TopicSurveyHolder(); 
    } else if (COMMENT_MODULE_TYPE.equals(currentType)) { // 评论
      topicDetailViewHolder = new TopicCommentHolder(); 
    } else if (SLIDEER_MODULE_TYPE.equals(currentType)) { // 幻灯
      topicDetailViewHolder = new TopicDefaultHolder(); 
    } else {
      topicDetailViewHolder = new TopicDefaultHolder();
    }

    topicDetailViewHolder.createView(view);
    return topicDetailViewHolder;
  }

  public static void bindData(Context context, int position, TopicSubject subject, Object viewHolder) {
    if (viewHolder instanceof TopicSuperTitleHolder) {
      bindTopicSuperTitleData(context, subject, (TopicSuperTitleHolder) viewHolder);
    } else if (viewHolder instanceof TopicTextHolder) {
      bindTextData(context, subject, (TopicTextHolder) viewHolder);
    } else if (viewHolder instanceof TopicLinkHolder) {
      bindLinkData(context, subject, (TopicLinkHolder) viewHolder);
    } else if (viewHolder instanceof TopicListHolder) {
      bindListData(context, position, subject, (TopicListHolder) viewHolder);
    } else if (viewHolder instanceof TopicAlbumHolder) {
      bindAlbumData(context, position, subject, (TopicAlbumHolder) viewHolder);
    } else if (viewHolder instanceof TopicSurveyHolder){
      bindSurveyData(context, subject, (TopicSurveyHolder) viewHolder);
    } else if (viewHolder instanceof TopicCommentHolder){
      bindCommentData(context, position, subject, (TopicCommentHolder) viewHolder);
    } else if (viewHolder instanceof TopicDefaultHolder && VOTE_MODULE_TYPE.equals(subject.getView())){
      bindVoteData(context, subject, (TopicDefaultHolder) viewHolder);
    } else if (viewHolder instanceof TopicDefaultHolder && SLIDEER_MODULE_TYPE.equals(subject.getView())){
      bindSliderData(context, subject, (TopicDefaultHolder) viewHolder);
    }

  }

  private static HeadImage getInstanteHeadImage(Context context){
    if (headImage == null) {
      return new HeadImage(context, HeadImage.MODE_TOPIC);
    }
    return headImage;
  }

  private static VoteModuleNew getInstanteVoteModuleNew(Context context){
    if (topicVote == null) {
      return new VoteModuleNew(context);
    }
    return topicVote;
  }

  private static void bindSliderData(Context context, TopicSubject subject, TopicDefaultHolder viewHolder) {
    viewHolder.getView().removeAllViews();
    HeadImage slideView = getInstanteHeadImage(context);
    slideView.render(subject, null);
    viewHolder.getView().addView(slideView);
  }

  public static void getVoteData(Context context, String voteId, final TopicDetailAdapter adapter){
    IfengNewsApp.getBeanLoader().startLoading(
      new LoadContext<String, LoadListener<VoteData>, VoteData>(
          ParamsManager.addParams(context, String.format(Config.VOTE_GET_URL, voteId)), new LoadListener<VoteData>() {

            @Override
            public void postExecut(
                                   LoadContext<?, ?, VoteData> context) {
              VoteData voteData = context.getResult();
              if (voteData == null || null == voteData.getData() || voteData.getIfsuccess() != 1) {
                context.setResult(null);
              }
            }

            @Override
            public void loadComplete(LoadContext<?, ?, VoteData> context) {
              TopicDetailModuleActivity.voteData = context.getResult();
              adapter.notifyDataSetChanged();
            }

            @Override
            public void loadFail(LoadContext<?, ?, VoteData> context) {
            }
          }, VoteData.class, Parsers.newVoteDataParser(), false,
          LoadContext.FLAG_HTTP_FIRST, true));
  }

  private static void bindVoteData(Context context, TopicSubject subject, TopicDefaultHolder viewHolder) {
    viewHolder.getView().removeAllViews();
    VoteModuleNew topicVote = getInstanteVoteModuleNew(context);
    topicVote.setDatas(subject);
    topicVote.create();
    viewHolder.getView().addView(topicVote);
  }

  private static void bindCommentData(final Context context, int position, final TopicSubject subject, TopicCommentHolder viewHolder) {
    viewHolder.getSeeMoreView().setVisibility(View.GONE);
    viewHolder.getLeftModule().setVisibility(View.GONE);
    if ("First".equals(subject.getFirstOrLast())) {
      viewHolder.getLeftModule().setVisibility(View.VISIBLE);
    } else if ("Last".equals(subject.getFirstOrLast())) {
      viewHolder.getSeeMoreView().setVisibility(View.VISIBLE);
      viewHolder.getSeeMoreView().setOnClickListener(new View.OnClickListener() {

        @Override
        public void onClick(View v) {
          CommentsActivity.redirect2Comments(context,subject.getWwwUrl(),null, subject.getTitle(), subject.getWwwUrl(), subject.getTopicId(), true, true,subject.getImageUrl(),subject.getShareUrl(),null,ConstantManager.ACTION_FROM_TOPIC2);
        }
      });
    } else {
      //Do nothing
    }

    IfengNewsApp.getImageLoader().startLoading(new LoadContext<String, ImageView, Bitmap>(TextUtils.isEmpty(subject.getUserFace())?"":subject.getUserFace(), viewHolder.getUserIcon(), Bitmap.class, LoadContext.FLAG_CACHE_FIRST, context)
      , new ImageLoader.DefaultImageDisplayer(context.getResources().getDrawable(drawable.comment_default_photo)));
    //    		new ImageDisplayer(){
    //
    //      @Override
    //      public void prepare(ImageView img) {
    //        BitmapDrawable bd = (BitmapDrawable)context.getResources().getDrawable(drawable.comment_default_photo);
    //        Bitmap bm = bd.getBitmap();
    //        img.setImageBitmap(bm);
    //      }
    //
    //      @Override
    //      public void display(ImageView img, Bitmap bmp) {
    //        if (bmp == null || bmp.isRecycled()){
    //          BitmapDrawable bd = (BitmapDrawable)context.getResources().getDrawable(drawable.comment_default_photo);
    //          Bitmap bm = bd.getBitmap();
    //          img.setImageBitmap(bm);
    //        } else {
    //          img.setImageBitmap(bmp);
    //        }
    //      }
    //
    //      @Override
    //      public void display(ImageView img, Bitmap bmp, Context ctx) {
    //
    //        if (bmp == null || bmp.isRecycled()){
    //          BitmapDrawable bd = (BitmapDrawable)context.getResources().getDrawable(drawable.comment_default_photo);
    //          Bitmap bm = bd.getBitmap();
    //          img.setImageBitmap(bm);
    //        } else {
    //          img.setImageBitmap(bmp);
    //          if (null != ctx) {
    //            // fade in 动画效果
    //            Animation fadeInAnimation = AnimationUtils.loadAnimation(ctx, R.anim.fade_in);
    //            img.startAnimation(fadeInAnimation);
    //          }
    //        }
    //
    //      }
    //
    //      @Override
    //      public void fail(ImageView img) {
    //
    //      }});
    viewHolder.getIpFrom().setText(IFENGNAME+subject.getIp_from()+NETFRIEND);
    viewHolder.getCommentContent().setText(subject.getComment_contents());
  }

  public static void getSurveyData(Context context, String surveyId, final TopicDetailAdapter adapter){
    IfengNewsApp.getBeanLoader().startLoading(
      new LoadContext<String, LoadListener<SurveyUnit>, SurveyUnit>(
          ParamsManager.addParams(context, Config.SURVEY_GET_URL + surveyId),
          new LoadListener<SurveyUnit>(){

            @Override
            public void postExecut(LoadContext<?, ?, SurveyUnit> surveyContext) {
              SurveyUnit unit = surveyContext.getResult();
              if (null == unit || 
                  -1 == unit.getIfsuccess() || 
                  null == unit.getData() || 
                  null == unit.getData().getResult() || 
                  unit.getData().getResult().size() == 0 || 1 != unit.getIfsuccess()) {
                surveyContext.setResult(null);
                return;
              }
            }

            @Override
            public void loadComplete(LoadContext<?, ?, SurveyUnit> surveyContext) {
              TopicDetailModuleActivity.surveyUnit = surveyContext.getResult();
              adapter.notifyDataSetChanged();
            }

            @Override
            public void loadFail(LoadContext<?, ?, SurveyUnit> surveyContext) {
            }}, SurveyUnit.class, Parsers
            .newSurveyUnitParser(), false,
            LoadContext.FLAG_HTTP_FIRST, true));
  }

  private static void bindSurveyData(final Context context, final TopicSubject subject, final TopicSurveyHolder viewHolder) {
    //只对list item 设置gone list会留一片空白区域，所以将list item中所有的父视图全部gone
    if (TopicDetailModuleActivity.surveyUnit == null || TopicDetailModuleActivity.surveyUnit.getData() == null) {
      viewHolder.getView().setVisibility(View.GONE);
      viewHolder.getLeftModule().setVisibility(View.GONE);
      viewHolder.getHeadView().setVisibility(View.GONE);
      viewHolder.getSurveyItemView().setVisibility(View.GONE);
      viewHolder.getJoinSurvey().setVisibility(View.GONE);
    } else {
      viewHolder.getView().setVisibility(View.VISIBLE);
      viewHolder.getLeftModule().setVisibility(View.VISIBLE);
      viewHolder.getHeadView().setVisibility(View.VISIBLE);
      viewHolder.getSurveyItemView().setVisibility(View.VISIBLE);
      viewHolder.getJoinSurvey().setVisibility(View.VISIBLE);
      rendUI(context, subject, viewHolder);
    }
  }

  /**
   * listview 中的item如果有动画会引起系统调用getview一直更新视图，所有调查、投票没有动画效果，只是投票进行投票过程有有动画
   * 
   */
  private static void rendUI(final Context context, final TopicSubject subject, TopicSurveyHolder viewHolder){
    SurveyUnit surveyUnit = TopicDetailModuleActivity.surveyUnit;
    SurveyModuleUtil surveyUtil = new SurveyModuleUtil(context);
    surveyUnit.formatAllPnum();
    if (null != surveyUnit.getData().getSurveyinfo()) {
      SurveyInfo info = surveyUnit.getData().getSurveyinfo();
      viewHolder.getTitle().setText(info.getTitle());
      StringBuffer buffer = new StringBuffer();

      if ("1".equals(info.getIsactive())) {
        buffer.append("进行中  ");
        if (RecordUtil.isRecorded(context, subject.getPodItems().get(0).getId(), RecordUtil.SURVEY)) {
          viewHolder.getJoinSurveyBut().setText(R.string.survey_see_results);  
        } else {
          viewHolder.getJoinSurveyBut().setText(R.string.survey_join);
        }
      } else {
        buffer.append("已结束  ");
        RecordUtil.record(context, surveyUnit.getData().getSurveyinfo().getId(), RecordUtil.SURVEY);
        viewHolder.getJoinSurveyBut().setText(R.string.survey_see_results);
      }

      if (TextUtils.isEmpty(info.getPnum())) {
        buffer.append("0人参与");
      } else {
        buffer.append(info.getPnum()+"人参与");
      }
      viewHolder.getTimeState().setText(buffer.toString());
      viewHolder.getIcon().setBackgroundResource(R.drawable.result_blue);
      viewHolder.getProgress().setBackgroundResource(R.drawable.result_color_blue);
      SurveyItem surveyItem = surveyUnit.getData().getTopicHighestItem();
      double percentage = 0.00;
      try {
        percentage = Double.parseDouble(surveyItem.getNump()) / 100;
      } catch (Exception e) {}
      LayoutParams params = new LayoutParams((int)(percentage*surveyUtil.getResultProgressFullW()), surveyUtil.getResultProgressH());
      viewHolder.getProgress().setLayoutParams(params);
      //      surveyUtil.setAutoWScaleAnimation(viewHolder.getProgress(), (int)(surveyUtil.getResultProgressFullW()*percentage));
      viewHolder.getPercentageTv().setText(surveyUtil.getPercentageStyleStr(surveyItem.getNump()));
      viewHolder.getPnum().setText(new DecimalFormat(",###").format(surveyItem.getNum()) + "票");
      viewHolder.getAnswer().setText(surveyItem.getTitle());
    }
    viewHolder.getJoinSurveyBut().setOnClickListener(new View.OnClickListener() {

      @Override
      public void onClick(View v) {
        if (!NetworkState.isActiveNetworkConnected(context)) {
          Toast.makeText(context, "当前无网络", Toast.LENGTH_SHORT).show();
          return;
        }
        Extension extension = new Extension();
        extension.setType(TopicDetailUtil.SURVEY_MODULE_TYPE);
        extension.setThumbnail(subject.getShareThumbnail());
        extension.setUrl(subject.getPodItems().get(0).getId());
        IntentUtil.startActivityWithPos(context, extension,0);
      }
    });
  }

  private static Bitmap magnificationBitmap(Context context, Bitmap bitmap){
    int widthPixels = context.getResources().getDisplayMetrics().widthPixels;
    Matrix matrix = new Matrix();
    matrix.postScale(widthPixels,widthPixels/LIANGHUI_SUPER_TITLE_RATIO); 
    return Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);  
  }

  /**
   * 整合标题、摘要、单焦点图
   * 动态专题banner 无图模式下还是有图片 
   */
  private static void bindTopicSuperTitleData(final Context context, TopicSubject subject, TopicSuperTitleHolder viewHolder) {
    TopicContent content = subject.getContent();

    TextView title = viewHolder.getTitle();
    TextView sutTitle = viewHolder.getSutTitle();
    TopicFocusImageView image = viewHolder.getImage();

    if(!TextUtils.isEmpty(content.getTitle()))title.setText(content.getTitle());
    if(!TextUtils.isEmpty(content.getSubTitle()))sutTitle.setText(content.getSubTitle());
    String url = null;
    TYPE = TopicDetailModuleActivity.STYLE;
    if ("normal".equals(TYPE)) {
      url = content.getBgImage();
    } else {
      url = content.getBigBannerSrc();
      if (TextUtils.isEmpty(url)) {
        url = content.getBgImage();
        TYPE = "normal";
      }
    }
    if(TextUtils.isEmpty(url))return;

    IfengNewsApp.getImageLoader().startLoading(new LoadContext<String, ImageView, Bitmap>(url, image, Bitmap.class, LoadContext.FLAG_CACHE_FIRST, context)
      , new ImageDisplayer() {

      @Override
      public void prepare(ImageView img) {
        if ("normal".equals(TYPE)) {
          img.setImageBitmap(((BitmapDrawable)context.getResources().getDrawable(drawable.topic_mutil_title_bg)).getBitmap());
        } else {
          img.setImageBitmap(magnificationBitmap(context, ((BitmapDrawable)context.getResources().getDrawable(drawable.topic_mutil_lianhui_title_bg)).getBitmap()));
        }
      }

      @Override
      public void fail(ImageView img) {
        if ("normal".equals(TYPE)) {
          img.setImageBitmap(((BitmapDrawable)context.getResources().getDrawable(drawable.topic_mutil_title_bg)).getBitmap());
        } else {
          img.setImageBitmap(magnificationBitmap(context, ((BitmapDrawable)context.getResources().getDrawable(drawable.topic_mutil_lianhui_title_bg)).getBitmap()));
        }
      }

      @Override
      public void display(ImageView img, BitmapDrawable bmp, Context ctx) {
        if (bmp == null){
          if ("normal".equals(TYPE)) {
            img.setImageBitmap(((BitmapDrawable)context.getResources().getDrawable(drawable.topic_mutil_title_bg)).getBitmap());
          } else {
            img.setImageBitmap(magnificationBitmap(context, ((BitmapDrawable)context.getResources().getDrawable(drawable.topic_mutil_lianhui_title_bg)).getBitmap()));
          } 
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
      public void display(ImageView img, BitmapDrawable bmp) {
        if (bmp == null) {
          if ("normal".equals(TopicDetailModuleActivity.STYLE)) {
            img.setImageBitmap(((BitmapDrawable)context.getResources().getDrawable(drawable.topic_mutil_title_bg)).getBitmap());
          } else {
            img.setImageBitmap(magnificationBitmap(context, ((BitmapDrawable)context.getResources().getDrawable(drawable.topic_mutil_lianhui_title_bg)).getBitmap()));
          }
        } else {
          img.setImageDrawable(bmp);
        }
      }
    });
  }

  private static void bindTextData(final Context context, final TopicSubject subject, TopicTextHolder viewHolder) {
    TextView textView = viewHolder.getTextView();
    TextView commentNum = viewHolder.getCommentNum();
    String text = subject.getContent().getIntro();
    if(TextUtils.isEmpty(text)){
      textView.setVisibility(View.GONE);
      commentNum.setVisibility(View.GONE);
    } else {
      textView.setVisibility(View.VISIBLE);
      commentNum.setVisibility(View.VISIBLE);
      textView.setText(text);
      commentNum.setText(TopicDetailModuleActivity.commentsData == null || TopicDetailModuleActivity.commentsData.getCount() < 0 ? "" : TopicDetailModuleActivity.commentsData.getCount()+"");
      commentNum.setOnClickListener(new View.OnClickListener() {

        @Override
        public void onClick(View v) {
          CommentsActivity.redirect2Comments(context,subject.getWwwUrl(),null, subject.getTitle(), subject.getWwwUrl(), subject.getTopicId(), true, true,subject.getImageUrl(),subject.getShareUrl(),null,ConstantManager.ACTION_FROM_TOPIC2);
        }
      });
    }
  }

  private static void bindLinkData(final Context context, TopicSubject subject, TopicLinkHolder viewHolder) {
    IfengGridView linksView = viewHolder.getLinksView();
    final ArrayList<TopicContent> topicContents = subject.getPodItems();
    linksView.setOnItemClickListener(new AdapterView.OnItemClickListener() {

      @Override
      public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        Extension defaultExtension = null;
        try {
          defaultExtension = ModuleLinksManager.getTopicLink(topicContents.get(position).getLinks());
        } catch (Exception e) {
          defaultExtension = new Extension();
        }
        if(IntentUtil.startActivityByExtension(context, defaultExtension)){
          //success
        } else {
          //fail
        }
      }});
    linksView.setAdapter(new IfengGridViewAdapter(context, topicContents));
  }

  private static void bindListData(Context context, int position, TopicSubject subject, TopicListHolder viewHolder) {
    int positionInPodItems = position - subject.getStartPosition();

    TopicContent content = subject.getPodItems().get(positionInPodItems);

    View leftModule = viewHolder.getLeftModule();
    View listItem = viewHolder.getListItem();
    TextView leftModuleTitle = viewHolder.getLeftModuleTitle();
    ChannelViewHolder channelViewHolder = viewHolder.getChannelViewHolder();

    ImageView image= channelViewHolder.thumbnail;
    TextView title= channelViewHolder.title;
    TextView comments= channelViewHolder.comments;
    View dividerLine = channelViewHolder.divider;

    leftModule.setVisibility(View.GONE);
    dividerLine.setVisibility(View.VISIBLE);

    if (positionInPodItems == 0) {
      leftModule.setVisibility(View.VISIBLE);
      leftModuleTitle.setText(subject.getTitle());
    } else if (position == subject.getEndPosition()) {
      dividerLine.setVisibility(View.GONE);
    } 

    //set item icons 无图模式将缩略图隐藏
    listDisplayStypeUtil.setListIcon(listItem, content, ListDisplayStypeUtil.CHANNEL_FLAG, PhotoModeUtil.getCurrentPhotoMode(context));    

    if(!TextUtils.isEmpty(content.getThumbnail())){
      IfengNewsApp.getImageLoader().startLoading(
        new LoadContext<String, ImageView, Bitmap>(
            content.getThumbnail(),
            image,
            Bitmap.class, 
            LoadContext.FLAG_CACHE_FIRST,
            context)
            , new DisplayShow(true));
    }

    title.setText(content.getTitle());
    comments.setText(content.getCommentCount());
    try {
      title.setTextColor(ReadUtil.isReaded(content.getLinks().get(0).getUrl()) ? context.getResources().getColor(R.color.list_readed_text_color)
          : context.getResources().getColor(R.color.list_text_font));
    } catch (Exception e) {
    }
    TopicClickListener topicClickListener = new TopicClickListener(context, content);
    listItem.setOnClickListener(topicClickListener);

  }

  private static void bindAlbumData(Context context, int position, TopicSubject subject, TopicAlbumHolder viewHolder) {
    if (position - subject.getStartPosition() == 0) {
      viewHolder.getTopicItemLeftModule().setVisibility(View.VISIBLE);
      viewHolder.getLeftModuleTitle().setText(subject.getTitle());
    } else {
      viewHolder.getTopicItemLeftModule().setVisibility(View.GONE);
    }

    int positionInPodItems = (position - subject.getStartPosition())*2;
    ArrayList<TopicContent> contents = subject.getPodItems();
    //左侧
    TopicContent leftContent = contents.get(positionInPodItems);
    leftContent.setTopicId(subject.getTopicId());
    bindAlbumItemData(context, leftContent, viewHolder.getLeftLayout(), viewHolder.getLeftImageView(), viewHolder.getLeftTitleView(), viewHolder.getLeftVideoView());
    //右侧
    if (positionInPodItems + 1 >  contents.size() - 1 ? false : true) {
      TopicContent rightContent = contents.get(positionInPodItems + 1);
      rightContent.setTopicId(subject.getTopicId());
      viewHolder.getRightLayout().setVisibility(View.VISIBLE);
      bindAlbumItemData(context, rightContent, viewHolder.getRightLayout(), viewHolder.getRightImageView(), viewHolder.getRightTitleView(), viewHolder.getRightVideoView());
    } else {
      viewHolder.getRightLayout().setVisibility(View.INVISIBLE);
    }

  }

  public static boolean isImageExist(String url){       
    File imgFile = IfengNewsApp.getResourceCacheManager().getCacheFile(url,
      true);
    if(imgFile != null && imgFile.exists()) {
      return true;
    }
    return false;
  }

  private static void bindAlbumItemData(final Context context, final TopicContent content, final View imageLayout, final TopicAlbumImageView imageView, final TextView titleView, final ImageView videoView){
    if(content.isHasVideo()){
      videoView.setVisibility(View.VISIBLE);
    }else{
      videoView.setVisibility(View.GONE);
    }
    titleView.setText(content.getTitle());

    if (PhotoMode.INVISIBLE_PATTERN == PhotoModeUtil.getCurrentPhotoMode(context)) {
      //TODO 因为qad更改 ImageLoader 设置Flag已 不生效 所以先判断缓存是否有图片 有直接取，没有设置为点击加载
      if (isImageExist(content.getThumbnail())) {
        bindAlbumImageData(context, content, imageLayout, imageView, titleView, videoView, true);
      } else {
        //点击加载
        if (content.getImageShowStatus() == TopicContent.STATUS_NORAML) {
          imageView.setImageDrawable(null);
          imageView.setBackgroundResource(drawable.image_prepare_load);
          content.setImageShowStatus(TopicContent.STATUS_NORAML);
          imageLayout.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
              bindAlbumImageData(context, content, imageLayout, imageView, titleView, videoView, true);
            }
          });
        } else if (content.getImageShowStatus() == TopicContent.STATUS_SUCCESS) {
          imageLayout.setOnClickListener(new TopicClickListener(context, content));
        } else {
          imageView.setImageDrawable(null);
          imageView.setBackgroundResource(drawable.image_loading);
        }
      }

    } else {
      bindAlbumImageData(context, content, imageLayout, imageView, titleView, videoView, false);
      imageLayout.setOnClickListener(new TopicClickListener(context, content));
    }
  }


  private static void bindAlbumImageData(final Context context, final TopicContent content, final View imageLayout, TopicAlbumImageView imageView, TextView titleView, ImageView videoView, final boolean photoMode){
    if(!TextUtils.isEmpty(content.getThumbnail())){
      IfengNewsApp.getImageLoader().startLoading(new LoadContext<String, ImageView, Bitmap>(content.getThumbnail(), imageView, Bitmap.class, LoadContext.FLAG_CACHE_FIRST, context), new ImageDisplayer() {

        @Override
        public void prepare(ImageView arg0) {
          arg0.setImageDrawable(null);
          arg0.setBackgroundResource(photoMode ? drawable.image_loading : drawable.album_item);
          content.setImageShowStatus(TopicContent.STATUS_LOADING);
        }

        @Override
        public void display(ImageView img, BitmapDrawable bmp) {
          if (bmp == null) {// || bmp.isRecycled()){
            img.setImageDrawable(null);
            img.setBackgroundResource(photoMode ? drawable.image_prepare_load : drawable.album_item);
            content.setImageShowStatus(TopicContent.STATUS_NORAML);
          } else {
            img.setImageDrawable(bmp);
            content.setImageShowStatus(TopicContent.STATUS_SUCCESS);
            imageLayout.setOnClickListener(new TopicClickListener(context, content));
          }
        }

        @Override
        public void display(ImageView img, BitmapDrawable bmp, Context ctx) {
          if (bmp == null) {// || bmp.isRecycled()){
            img.setImageDrawable(null);
            img.setBackgroundResource(photoMode ? drawable.image_prepare_load : drawable.album_item);
            content.setImageShowStatus(TopicContent.STATUS_NORAML);
          } else {
            img.setImageDrawable(bmp);
            if (null != ctx) {
              // fade in 动画效果
              Animation fadeInAnimation = AnimationUtils.loadAnimation(ctx, R.anim.fade_in);
              img.startAnimation(fadeInAnimation);
              content.setImageShowStatus(TopicContent.STATUS_SUCCESS);
              imageLayout.setOnClickListener(new TopicClickListener(context, content));
            }
          }
        }

        @Override
        public void fail(ImageView img) {
          img.setImageDrawable(null);
          img.setBackgroundResource(photoMode ? drawable.image_prepare_load : drawable.album_item);
          content.setImageShowStatus(TopicContent.STATUS_NORAML);
        }
      });
    } else {
      imageView.setImageDrawable(null);
      imageView.setBackgroundResource(photoMode ? drawable.image_prepare_load : drawable.album_item);
    }

  }

}

class TopicClickListener implements OnClickListener{
  private TopicContent content;
  private Context context;
  private int position = 0;
  public TopicClickListener(Context context, TopicContent content){
    this.content = content;
    this.context = context;
  }
  public TopicClickListener(Context context, TopicContent content,int position){
    this.content = content;
    this.position = position;
    this.context = context;
  }
  @Override
  public void onClick(View v) {
    Extension defaultExtension = ModuleLinksManager.getTopicLink(content.getLinks());
    if(defaultExtension!=null){
      defaultExtension.setCategory(content.getTopicId());
      ReadUtil.markReaded(defaultExtension.getUrl());
      IntentUtil.startActivityWithPos(context, defaultExtension,position);
      // 将标题变灰，表示文章已阅读
      final View finalV = v;
      if (null == v) {
        return;
      }
      v.postDelayed(new Runnable() {
        @Override
        public void run() {
          /*
           * 解决崩溃日志中bug, 
           * 原因分析：这里改变颜色是延时操作，如果用户点击文章后，在一秒钟之内退出专题，
           * activity 执行onDestroy  remove掉添加的view,这是执行字变颜色view为null 程序报NullPointException
           * 解决方案：
           * 1.try  catch 住
           * 2.判读finalV 、finalV.findViewById(id.title) 是否为空
           * 最终选第一个，原因可能刚判断完finalV 、finalV.findViewById(id.title)不为null 执行改变颜色时被回收掉了，这是也会挂掉
           * */
          try {
            ((TextView)finalV.findViewById(id.left_title)).setTextColor(context.getResources().getColor(R.color.list_readed_text_color));
            ((TextView)finalV.findViewById(id.right_title)).setTextColor(context.getResources().getColor(R.color.list_readed_text_color));
            ((TextView)finalV.findViewById(id.title)).setTextColor(context.getResources().getColor(R.color.list_readed_text_color));
          } catch (Exception e) {
          }
        }
      }, Config.AUTO_PULL_TIME);

    }
  }

}
