package com.ifeng.news2.plot_module;


import android.graphics.drawable.BitmapDrawable;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import com.ifeng.news2.R.drawable;
import com.qad.loader.ImageLoader.ImageDisplayer;

import android.graphics.Bitmap;
import android.widget.ImageView;
import com.ifeng.news2.IfengNewsApp;
import android.text.TextUtils;
import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.ifeng.news2.R;
import com.ifeng.news2.R.id;
import com.ifeng.news2.activity.CommentsActivity;
import com.ifeng.news2.bean.AllComments;
import com.ifeng.news2.bean.Comment;
import com.ifeng.news2.bean.CommentsData;
import com.ifeng.news2.util.CommentsManager;
import com.ifeng.news2.util.ConstantManager;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import java.util.ArrayList;


/**
 * @author liu_xiaoliang
 * 大标题模块（带评论数）
 */
public class PlotTopicTitleModule extends PlotBaseModule  {
    
    private String ifengName = "凤凰网";
    private String netFriend = "网友";
    private String commentModulePrompt = "跟帖";
    private TextView bigTitle;
    private TextView titleRevision;
    private TextView commentNum;
    private View bigTitleView;
    private LinearLayout commentModuleView = null;
    private CommentsManager commentsManager = null;
    
    public PlotTopicTitleModule(Context context, AttributeSet attrs) {
        super(context, attrs);
        commentsManager = new CommentsManager();
    }
    public PlotTopicTitleModule(Context context){
        super(context);
        commentsManager = new CommentsManager();
    }
    
    @Override
    public void init(Context context) {
        super.init(context);
        bigTitleView = (View)inflater.inflate(R.layout.plot_topic_title_layout, null);
        bigTitle = (TextView)bigTitleView.findViewById(R.id.plot_topic_title);
        titleRevision = (TextView)bigTitleView.findViewById(R.id.plot_topic_title_revision);
        commentNum = (TextView)bigTitleView.findViewById(R.id.comment_num);
    }
    @Override
    public void buildModule() {
        super.buildModule();
        
        if (!TextUtils.isEmpty(plotTopicBody.getTitle())) {
          bigTitle.setText(plotTopicBody.getTitle());
          titleRevision.setText(plotTopicBody.getIntro());
        }
        

        commentNum.setOnClickListener(this);
        addView(bigTitleView);
        //异步加载评论数据
        loadCommentsData();
    }
    
    private void loadCommentsData(){
        commentsManager.obtainTopicComments(plotTopicBody.getWwwUrl(), new LoadListener<CommentsData>() {
            
            @Override
            public void postExecut(LoadContext<?, ?, CommentsData> context) {
                //检查数据是否完整
                if(null == context.getResult() || null == context.getResult().getComments()){
                    loadFail(context);
                    return;
                }
            }
            
            @Override
            public void loadFail(LoadContext<?, ?, CommentsData> context) {}
            
            @Override
            public void loadComplete(LoadContext<?, ?, CommentsData> context) {
                //成功渲染跟帖模块后再设置评论数标签
                if (renderCommentModuleSuccess(context.getResult().getComments())) {
                    commentNum.setText(""+context.getResult().getCount());
                }
            }
        });
    }
    
    public boolean renderCommentModuleSuccess(AllComments allComments){
        
        ArrayList<Comment> comments = allComments.getHottest();
        if (null == comments || comments.size() < 1) 
            return false;
        //最多显示五条跟帖
        int count = comments.size() > 5 ? 5 : comments.size();
        //加载模块标示
        commentModuleView.addView(getLeftTitleView());
        //加载评论item
        for (int i = 0; i < count; i++) {
            commentModuleView.addView(getCommentItemView(comments.get(i)));
        }
        //加载查看更多
        View seeMoreView = inflater.inflate(R.layout.topic_detail_comment_list_see_more, null); 
        seeMoreView.setOnClickListener(this);
        commentModuleView.addView(seeMoreView);
        return true;
    }
    
    private View getCommentItemView(Comment comment){
        View view = inflater.inflate(R.layout.widget_comment_list_item, null);
        ImageView userIcon = (ImageView) view.findViewById(id.userIcon);
        IfengNewsApp.getImageLoader().startLoading(new LoadContext<String, ImageView, Bitmap>(comment.getUserFace(), userIcon, Bitmap.class, LoadContext.FLAG_CACHE_FIRST, context),new ImageDisplayer(){

          @Override
          public void prepare(ImageView img) {
            BitmapDrawable bd = (BitmapDrawable)getResources().getDrawable(drawable.comment_default_photo);
            Bitmap bm = bd.getBitmap();
            img.setImageBitmap(bm);
          }

          @Override
          public void display(ImageView img, BitmapDrawable bmp) {
            if (bmp == null) {//  || bmp.isRecycled()){
              BitmapDrawable bd = (BitmapDrawable)getResources().getDrawable(drawable.comment_default_photo);
              Bitmap bm = bd.getBitmap();
              img.setImageBitmap(bm);
            } else {
              img.setImageDrawable(bmp);
            }
          }

          @Override
          public void display(ImageView img, BitmapDrawable bmp, Context ctx) {

            if (bmp == null) {//  || bmp.isRecycled()){
              BitmapDrawable bd = (BitmapDrawable)getResources().getDrawable(drawable.comment_default_photo);
              Bitmap bm = bd.getBitmap();
              img.setImageBitmap(bm);
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
            
        }});
        TextView ipFrom = (TextView) view.findViewById(id.ip_from);
        TextView commentContent = (TextView) view.findViewById(id.comment_content);
        view.findViewById(id.uptimes).setVisibility(View.GONE);
        view.findViewById(id.uptimes_icon).setVisibility(View.GONE);
        ipFrom.setText(ifengName+comment.getIp_from()+netFriend);
        commentContent.setText(comment.getComment_contents());
        return view;
    }

    @Override
    public void onClick(View v) {
        //评论数标签 & 查看更多都会调用评论页    增加了分享url和图片  (策划)
    	Log.d("PlotTopic", "PlotTopicTitleModule");
    	 CommentsActivity.redirect2Comments(context,plotTopicBody.getWwwUrl(),null, plotTopicBody.getCommentTitle(), plotTopicBody.getWwwUrl(), plotTopicBody.getDocumentId(), true, true,plotTopicBody.getBgImage(),plotTopicBody.getWwwUrl(),null,ConstantManager.ACTION_FROM_PLOTATLAST);
    }
    
    public void setCommentModuleView(LinearLayout commentModuleView) {
        this.commentModuleView = commentModuleView;
    }
    
    public View getLeftTitleView(){
      View view = inflater.inflate(R.layout.plot_title_left_module, null);
      TextView titleView = (TextView)view.findViewById(id.title);
      titleView.setText(commentModulePrompt);
      return view;
  }
}
