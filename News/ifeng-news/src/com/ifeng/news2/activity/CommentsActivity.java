package com.ifeng.news2.activity;

import java.util.ArrayList;
import java.util.Collections;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.DisplayMetrics;
import android.view.GestureDetector;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.WindowManager.LayoutParams;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationUtils;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.ifeng.news2.Config;
import com.ifeng.news2.R;
import com.ifeng.news2.R.id;
import com.ifeng.news2.adapter.CommentListAdapter;
import com.ifeng.news2.bean.AllComments;
import com.ifeng.news2.bean.Comment;
import com.ifeng.news2.bean.CommentsData;
import com.ifeng.news2.bean.ParentComment;
import com.ifeng.news2.share.ShareAlert;
import com.ifeng.news2.share.ShareAlertBig;
import com.ifeng.news2.share.WXHandler;
import com.ifeng.news2.util.CommentsManager;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.DeviceUtils;
import com.ifeng.news2.util.SoftKeyUtil;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticPageType;
import com.ifeng.news2.util.StatisticUtil.StatisticRecordAction;
import com.ifeng.news2.util.WindowPrompt;
import com.ifeng.share.util.NetworkState;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.net.HttpGetListener;
import com.qad.util.WToast;

@SuppressLint({ "NewApi", "ShowToast" })
public class CommentsActivity extends AppBaseActivity implements
		LoadListener<CommentsData>{
	private int bottomBarHeight = 66;
	protected static final int UP_ANMATION_HEIGHT = 100;

	private boolean isFollow;
	//The first page of the number of newest comments
	private static final int SINGLE_PAGE_SIZE = 15;
	private ArrayList<Comment> newsCommentsList;
	private ArrayList<Comment> hotCommentsList;
	private ImageView editBtn;
	private ListView commentListView;
	private String wwwUrl;
	private String commentsExt;
	private String titleStr;
	private String documentId;
	private int pageNo;
	private int submitCnt;
	private CommentListAdapter commentAdapter;
	private WindowPrompt prop;
	private LinearLayout loadingBar;
	private EditText commentET;
	private Comment byCommentData = null;
	private View loadFail;
	private View loadingMore;
	private String myCommentStr;
	private boolean listOnLoad;
	private boolean isFirstPageFlag = false;
	private boolean submitSuccess = false;
	private boolean isPopupOnclick = false;
	private boolean isTopicComment = false;
	private int upHeight = 0;
	private boolean isShowingPopup = true;
	private int onTouchUpY = 0;
	private CommentsManager commentsManager;
	private RelativeLayout bottomBar;
	private ImageView back;
	private String commentsUrl;
	private View detailCommentModule;
	private View submitBtn, closeButton;
	private ProgressDialog loadingDialog;
	private boolean isBottomShowing = false;
	private String imageUrl;   //评论图片url
	private String shareUrl;   //分享链接
	
	private String action ="";
	private int popupIconWidth = 0;
	private int popupIconHeight = 0;

	private String position;
	


	/**
	 * 跳转到评论页
	 * 
	 * @param context
	 * @param commentsUrl
	 * @param commentType
	 * @param title
	 * @param wwwUrl
	 * @param documentId
	 * @param ifShowSoftInput
	 */
	   public static boolean redirect2Comments(Context context, String commentsUrl,
	                                           String commentType, String title, String wwwUrl, String documentId,
	                                           boolean ifShowSoftInput, boolean isTopicComment,String action) {
	     WToast wToast = new WToast(context);
	     if (wwwUrl == null && NetworkState.isActiveNetworkConnected(context)) {

	       wToast.showMessage("文章加载中，请稍候...");
	       return false;
	     } else if (!NetworkState.isActiveNetworkConnected(context)) {
	    	 WindowPrompt.getInstance(context).showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
	       return false;
	     } else {
	       toGoCommentsActivity(context, commentsUrl, commentType, title, wwwUrl, documentId, null, ifShowSoftInput, isTopicComment,action);
	       return true;
	     }
	   }
	   
	
	private static void toGoCommentsActivity(Context context, String commentsUrl,
	                                  String commentType, String title, String wwwUrl, String documentId, String commentsExt,
	                                  boolean ifShowSoftInput, boolean isTopicComment,String action){
	  Intent intent = new Intent(context, CommentsActivity.class);
      intent.putExtra("commentsUrl", commentsUrl);
      intent.putExtra("title", title);
      intent.putExtra("commentType", commentType);
      intent.putExtra("wwwUrl", wwwUrl);
      intent.putExtra("documentId", documentId);
      intent.putExtra("commentsExt", commentsExt);
      intent.putExtra("isTopicComment", isTopicComment);
      intent.setAction(action);
      if (ifShowSoftInput) {
          intent.putExtra("popSoftInput", true);
      }
      context.startActivity(intent);
      ((Activity) context).overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
	  
	}
	
	/**
	 *  单条跟帖评论
	 */
	public static boolean redirectDetailComments(Context context,
			String commentsUrl, String commentType, String title,
			 String documentId,String commentsExt, boolean ifShowSoftInput,
			boolean isTopicComment, String imageUrl, String shareUrl,String action) {
		WToast wToast = new WToast(context);

		if (commentsUrl == null && NetworkState.isActiveNetworkConnected(context)) {

			wToast.showMessage("文章加载中，请稍候...");
			return false;
		} else if (!NetworkState.isActiveNetworkConnected(context)) {
			WindowPrompt.getInstance(context).showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
			return false;
		} else {
			Intent intent = new Intent(context, CommentsActivity.class);
			intent.putExtra("commentsUrl", commentsUrl);
			intent.putExtra("title", title);
			intent.putExtra("commentType", commentType);
			intent.putExtra("shareUrl", shareUrl);
			intent.putExtra("documentId", documentId);
			intent.putExtra("commentsExt", commentsExt);
			intent.putExtra("imageUrl", imageUrl);
			intent.putExtra("isTopicComment", isTopicComment);
			intent.setAction(action);
			if (ifShowSoftInput) {
				intent.putExtra("popSoftInput", true);
			}
			context.startActivity(intent);
			((Activity) context).overridePendingTransition(
					R.anim.in_from_right, R.anim.out_to_left);
			return true;
		}
	}
	
	public static boolean redirect2Comments(Context context,
			String commentsUrl, String commentType, String title,
			String wwwUrl, String documentId, boolean ifShowSoftInput,
			boolean isTopicComment, String imageUrl, String shareUrl,String position , String action) {
		WToast wToast = new WToast(context);

		if (commentsUrl == null && wwwUrl == null && NetworkState.isActiveNetworkConnected(context)) {
			
			wToast.showMessage("文章加载中，请稍候...");
			return false;
		} else if (!NetworkState.isActiveNetworkConnected(context)) {
			WindowPrompt.getInstance(context).showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
			return false;
		} else {
			Intent intent = new Intent(context, CommentsActivity.class);
			intent.putExtra("commentsUrl", commentsUrl);
			intent.putExtra("title", title);
			intent.putExtra("commentType", commentType);
			intent.putExtra("wwwUrl", wwwUrl);
			intent.putExtra("shareUrl", shareUrl);
			intent.putExtra("documentId", documentId);
			intent.putExtra("imageUrl", imageUrl);
			intent.putExtra("position", position);
			intent.putExtra("isTopicComment", isTopicComment);
			intent.setAction(action);
			if (ifShowSoftInput) {
				intent.putExtra("popSoftInput", true);
			}
			context.startActivity(intent);
			((Activity) context).overridePendingTransition(
					R.anim.in_from_right, R.anim.out_to_left);
			return true;
		}
	}
	
	
	
	

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.comments);
		findViewsById();
		setListeners();
		prop = WindowPrompt.getInstance(this);
		wwwUrl = getIntent().getStringExtra("wwwUrl");
		commentsExt = getIntent().getStringExtra("commentsExt");
		if (null != savedInstanceState) {
		    documentId = savedInstanceState.getString("documentId");
	        commentsUrl = savedInstanceState.getString("commentsUrl");
		} else {
		    documentId = getIntent().getStringExtra("documentId");
	        commentsUrl = TextUtils.isEmpty(getIntent().getStringExtra(
	                "commentsUrl")) ? wwwUrl : getIntent().getStringExtra(
	                "commentsUrl");
		}
		titleStr = getIntent().getStringExtra("title");
		shareUrl = getIntent().getStringExtra("shareUrl");
		position = getIntent().getStringExtra("position");
		imageUrl = getIntent().getStringExtra("imageUrl");
		action = getIntent().getAction();
		
//		Options options = new Options();
//		options.inJustDecodeBounds = true;
//		BitmapFactory.decodeResource(getResources(),
//				R.drawable.comment_share_reply_1,options);
//		popupIconWidth = options.outWidth*3;
//		
//		popupIconHeight = options.outHeight;
        popupIconWidth = (int)(DeviceUtils.getWindowWidth(this) *0.65);
        popupIconHeight = popupIconWidth * 92/471;
        upHeight = (int)(popupIconHeight/5.0);
        
		isTopicComment = getIntent().getBooleanExtra("isTopicComment", false);
		
		pageNo = 1;
		commentsManager = new CommentsManager();
		newsCommentsList = new ArrayList<Comment>();
		hotCommentsList = new ArrayList<Comment>();
		commentAdapter = new CommentListAdapter(CommentsActivity.this);
		listOnLoad = false;
		loadingBar.setVisibility(View.VISIBLE);
		setFirstPageFlag(true);
		commentsManager.obtainComments(commentsUrl, pageNo,
		  CommentsActivity.this, isTopicComment);
		beginStatistic();
		
	}
	
	private void beginStatistic() {
		// TODO Auto-generated method stub
		if(ConstantManager.ACTION_FROM_SLIDE.equals(action)){
			StatisticUtil.addRecord(getApplicationContext(),
		              StatisticUtil.StatisticRecordAction.page,
		              "id=opinion" + "$ref=" + documentId +"_"+position + "$type="
		                  + StatisticUtil.StatisticPageType.comment);
		}else if (ConstantManager.ACTION_FROM_PLOTATLAST.equals(action)){
			StatisticUtil.addRecord(getApplicationContext(),
              StatisticUtil.StatisticRecordAction.page,
              "id=opinion" + "$ref=" + documentId + "$type="
                  + StatisticUtil.StatisticPageType.comment);
		}else if (ConstantManager.ACTION_FROM_ARTICAL.equals(action)){
			StatisticUtil.addRecord(getApplicationContext(),
		              StatisticUtil.StatisticRecordAction.page,
		              "id=opinion" + "$ref=" + documentId + "$type="
		                  + StatisticUtil.StatisticPageType.comment);
		}else if (ConstantManager.ACTION_FROM_TOPIC2.equals(action)){
			StatisticUtil.addRecord(getApplicationContext(),
		              StatisticUtil.StatisticRecordAction.page,
		              "id=opinion" + "$ref=" + documentId + "$type="
		                  + StatisticUtil.StatisticPageType.comment);
		}
	}
	
	@Override
	protected void onSaveInstanceState(Bundle outState) {
	    outState.putString("documentId", documentId);
	    outState.putString("commentsUrl", commentsUrl);
	    super.onSaveInstanceState(outState);
	}

	private void findViewsById() {
		loadingMore = LayoutInflater.from(CommentsActivity.this).inflate(
				R.layout.load_more, null);
		back = (ImageView) findViewById(R.id.Comment_back);
		bottomBar = (RelativeLayout) findViewById(R.id.bottom_bar);
		detailCommentModule = findViewById(R.id.detail_comment_module2);
		detailCommentModule.setBackgroundResource(R.drawable.comment_write_background);
		editBtn = (ImageView) findViewById(R.id.edit_commentsBtn);
		commentListView = (ListView) findViewById(R.id.comment_list);
		commentListView.setBackgroundColor(getResources().getColor(R.color.white));
		commentListView.setDividerHeight(0);
		loadingBar = (LinearLayout) findViewById(R.id.loading_comments);
		commentET = (EditText) findViewById(R.id.detail_comment_editText);
		submitBtn = findViewById(id.detail_submit_comment_button);
		closeButton = findViewById(id.detail_close_commment_button);
		loadFail = findViewById(R.id.loading_fail);
		shadow = findViewById(R.id.shadow);
		updateEditCommentModule(false);
		
		findViewById(R.id.policy_text).setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				updateEditCommentModule(false);
				
				Intent intent = new Intent();
				intent.setAction(Intent.ACTION_VIEW);
				intent.setData(Uri.parse("comifengnews2app://doc/68983945"));
				CommentsActivity.this.startActivity(intent);
				//增加跳转动画
				overridePendingTransition(R.anim.in_from_right,
						R.anim.out_to_left);
			}
		});
	}

	private void updateEditCommentModule(boolean isShow) {
		if (isShow) {
			shadow.setVisibility(View.GONE);
			bottomBar.setVisibility(View.GONE);
			detailCommentModule.setVisibility(View.VISIBLE);
		} else {
			shadow.setVisibility(View.VISIBLE);
			bottomBar.setVisibility(View.VISIBLE);
			detailCommentModule.setVisibility(View.GONE);
			isFollow = false;
		}
		SoftKeyUtil.showSoftInput(getApplicationContext(), commentET, isShow);
	}
	private int mScrollState;
	private View shadow;
	private GestureDetector detector;
	
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		return super.onTouchEvent(event);
	}

	@SuppressWarnings("deprecation")
	private void setListeners() {
		editBtn.setOnClickListener(new OnClickListener() {


			@Override
			public void onClick(View v) {
				//点击跟帖后，重置是否点击跟帖的状态
				isFollow = true;
				byCommentData = null;
				isPopupOnclick = false;
				ready2Enter(false);
			}
		});
		back.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				finish();
			}
		});
		detector = new GestureDetector(new SimpleOnGestureListener(){
			@Override
			public boolean onFling(MotionEvent e1, MotionEvent e2,
					float velocityX, float velocityY) {
				if (null == e1 || null == e2) {
					// 增强健壮性，在线日志中发现少量手机这里会抛出NullPointerException
					return false;
				}
				float y = Math.abs(velocityY);
				if((e1.getX()-e2.getX()<-50&&e1.getX()-e2.getX()<-Math.abs(e1.getY()-e2.getY())-20)||(velocityX > 1500 && velocityX > y + 500)){
						onBackPressed();
						return true;
				}
				return false;
			}
		});
		commentListView.setOnScrollListener(new OnScrollListener() {
			@Override
			public void onScroll(AbsListView view, int firstVisibleItem,
					int visibleItemCount, int totalItemCount) {
				if (firstVisibleItem == 0)
					return;
				
				if (mScrollState != AbsListView.OnScrollListener.SCROLL_STATE_IDLE&&firstVisibleItem + visibleItemCount == totalItemCount
						&& !listOnLoad && !isBottomShowing) {
					try {
						listOnLoad = true; // 解决滑动到评论页底部时的重复下载问题
						loadingMore.setVisibility(View.VISIBLE);
						setFirstPageFlag(false);
						commentsManager.obtainComments(commentsUrl, pageNo,
								CommentsActivity.this, isTopicComment);
					} catch (Exception e) {
						e.printStackTrace();
					}
				} else if (isBottomShowing && firstVisibleItem + visibleItemCount < totalItemCount) {
					isBottomShowing = false;
				}
			}

			@Override
			public void onScrollStateChanged(AbsListView view, int scrollState) {
				mScrollState = scrollState;
				if (scrollState == OnScrollListener.SCROLL_STATE_IDLE) {
					view.invalidateViews();
				}
			}
		});
		submitBtn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				sendComment(isPopupOnclick);
			}
		});
		closeButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				updateEditCommentModule(false);
			}
		});
		commentET.addTextChangedListener(new TextWatcher() {

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
		commentET.setOnFocusChangeListener(new View.OnFocusChangeListener() {

			@Override
			public void onFocusChange(View v, boolean hasFocus) {
				if (!hasFocus) {
					updateEditCommentModule(false);
				}
			}
		});
		commentListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				Comment commentItem = (Comment) arg0.getItemAtPosition(arg2);
				if (commentItem != null) {
					if (!commentItem.isSendComment()
							&& View.GONE == detailCommentModule.getVisibility()) {
						showCommentPopup(arg1, commentItem);
					}
				}
			}
		});

		commentListView.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				detector.onTouchEvent(event);
				switch (event.getAction()) {
				case MotionEvent.ACTION_DOWN:
					updateEditCommentModule(false);
					if (isShowingPopup) {
						onTouchUpY = 0;
						isShowingPopup = false;
					}
					break;
				case MotionEvent.ACTION_UP:
					onTouchUpY = (int) event.getY();
					break;
				}
				return false;
			}
		});
	}

	/**
	 * 含义 ：标志是否是第一页 初始化 ：
	 * 状态变更：onCreate()加载数据时变更为true,在第一次加载失败，再次加载是状态为true,在上啦滚动刷新是状态变更为false;
	 * 
	 * @Title: setFirstPageFlag
	 * @Description: TODO(这里用一句话描述这个方法的作用)
	 * @param flag
	 *            设定文件
	 * @return void 返回类型
	 * @throws
	 */
	private void setFirstPageFlag(boolean flag) {
		this.isFirstPageFlag = flag;
	}

	private boolean getFirstPageFlag() {
		return this.isFirstPageFlag;
	}

	@SuppressWarnings("unchecked")
	private void addCommemtListItem() {
//		StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.COMMENT,
//				documentId);
		Comment myComment = new Comment();
		if (byCommentData != null) {
			if (byCommentData.getParent() != null) {
				myComment.setParent((ArrayList<ParentComment>) byCommentData
						.getParent().clone());
				ParentComment pComment = new ParentComment();
				pComment.setIp_from(byCommentData.getIp_from());
				pComment.setComment_contents(byCommentData
						.getComment_contents());
				pComment.setUname(byCommentData.getUname());
				myComment.getParent().add(pComment);
			}
		}
		myComment.setIp_from("您的评论正在审核中");
		myComment.setComment_contents(myCommentStr);
		myComment.setSendComment(true);
		newsCommentsList.add(0, myComment);
		submitSuccess = true;
		submitCnt++;
		commentAdapter.setCommentSuccess(submitSuccess, submitCnt);
		commentAdapter.setNewsComments(newsCommentsList);
		commentAdapter.notifyDataSetChanged();
		Config.SEND_COMMENT_TIMES.add(System.currentTimeMillis());
		byCommentData = null;
	}

	@Override
	public boolean dispatchKeyEvent(KeyEvent event) {
		if (KeyEvent.KEYCODE_BACK == event.getKeyCode()
				&& View.VISIBLE == detailCommentModule.getVisibility()) {
			updateEditCommentModule(false);
			return true;
		} else {
			return super.dispatchKeyEvent(event);
		}
	}

	public void ready2Enter(boolean isPopupOnclick) {
		updateEditCommentModule(true);
		if (isPopupOnclick)
			((InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE))
					.toggleSoftInput(0, 0);
	}

	public void sendComment(boolean isPopupReply) {
		String quoteId = null;
		if (isPopupReply && byCommentData != null) {
			try {
			    //评论项唯一标示为comment_id， 对某条评论项进行再评论时需求将"quoteId="+comment_id发送到服务器
				quoteId = String.valueOf(byCommentData.getComment_id());
			} catch (Exception e) {
			}
		}

		String commentContent = commentET.getText().toString().trim();
		if (TextUtils.isEmpty(commentContent)) {
			//showMessage("评论不能为空");
			prop.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.toast_edit_empty_title,R.string.toast_edit_empty_content);
			return;
		}
		StatisticPageType type = null;
		//如果是跟帖，则type为follow，如果是回复，则type为reply
		if(isFollow) {
			type = StatisticPageType.follow;
		} else {
			type = StatisticPageType.reply;
		}
		//统计
		StatisticUtil.addRecord(this,StatisticRecordAction.action,"type="+type);
		updateEditCommentModule(false);
//		String docName = "";
//		String docUrl = "";
//		if (newsCommentsList.size() == 0) {
//			docUrl = wwwUrl;
//			docName = titleStr;
//		} else {
//			docName = newsCommentsList.get(0).getDoc_name();
//			docUrl = newsCommentsList.get(0).getDoc_url();
//		}
		myCommentStr = commentContent.replaceAll("<", " ").replaceAll(">", " ");
//		String client_ip = GetIpAddress.getLocalIpAddress();
//		client_ip = URLEncoder.encode(client_ip);
//		String token_ip = MD5.md5s(client_ip);
		if (Config.SEND_COMMENT_TIMES.size() >= 6) {
			if (System.currentTimeMillis() - Config.SEND_COMMENT_TIMES.get(0) < 60000) {
				showMessage("发送评论太过频繁");
				return;
			} else {
				Config.SEND_COMMENT_TIMES.remove(0);
			}
		}
		
		commentsManager.sendComments(quoteId, titleStr, commentsUrl, myCommentStr, commentsExt, new HttpGetListener() {

					@Override
					public void loadHttpSuccess() {
						dismissDialog();
					//	showMessage("发布成功，评论正在审核");
						prop.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.toast_publish_success_title,R.string.toast_publish_success_content);
						addCommemtListItem();
					}

					@Override
					public void loadHttpFail() {
						dismissDialog();
				//		showMessage("发布失败");
						prop.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.toast_publish_fail_title,R.string.toast_publish_fail_content);
					}

					@Override
					public void preLoad() {
						createDialog("正在发布，请稍候");
					}
				});
		commentET.setText("");
	}

	public void showCommentPopup(final View clickViewItem, final Comment commentItem) {
		isShowingPopup = true;
		
		DisplayMetrics metric = new DisplayMetrics();
		
		getWindowManager().getDefaultDisplay().getMetrics(metric);
		
		View popupTools = null;
		
		int y = clickViewItem.getTop();
		int popupPosition = onTouchUpY + popupIconHeight;
		
		
		if (y>popupIconHeight-upHeight) {
			popupPosition = y-upHeight;
			popupTools = LayoutInflater.from(this).inflate(
					R.layout.widget_comment_popupwindow_bottom, null); 
		} else {
			popupTools = LayoutInflater.from(this).inflate(
					R.layout.widget_comment_popupwindow_top, null); // top show
		}
		
		ImageView popupReply = (ImageView) popupTools
				.findViewById(R.id.comment_reply_ibut);
		ImageView popupSupport = (ImageView) popupTools
				.findViewById(R.id.comment_support_ibut);
		ImageView popupShare = (ImageView) popupTools
				.findViewById(R.id.comment_share_ibut);
		
		
		final PopupWindow smile_pop = new PopupWindow(popupTools, popupIconWidth, popupIconHeight);
		
		smile_pop.setBackgroundDrawable(getResources().getDrawable(
				R.color.no_color));
		smile_pop.getBackground().setAlpha(150);
		smile_pop.setAnimationStyle(R.style.AnimationPreview);
		smile_pop.setFocusable(true);
		
		smile_pop.showAtLocation(clickViewItem, Gravity.CENTER_HORIZONTAL |
				Gravity.TOP, 0,popupPosition);
		
		popupReply.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// 状态重置
				isPopupOnclick = true;
				ready2Enter(true);
				smile_pop.dismiss();

				try {
					byCommentData = commentItem;
				} catch (Exception e) {
				}
			}
		});

		popupSupport.setOnClickListener(new OnClickListener() {
		  
		  private PopupWindow pUpAnimationWindow;// 弹出一个popWindow，用来展示"+1"的动画效果
	      private View aniamtionView; // "+1"动画的活动视图
	      private ImageView imgSlice; // "+1"内容的容器：imgView
	      private Animation mUpAnimation;
	      private ImageView imgUpTimes;// 被单击的item内的 [顶img].
	      private TextView txtUpTimes;// 被单击的item内的 [顶img].

			@Override
			public void onClick(View v) {
				//支持统计
				StatisticUtil.addRecord(CommentsActivity.this, StatisticRecordAction.action, "type="+StatisticPageType.support);
				isPopupOnclick = true;
				smile_pop.dismiss();
				try {
					if (commentItem != null && commentItem.isUped()) {
						showMessage("您已支持过了");
					} else {
					    displayUpAnimation();
						commentsManager.supportComments(commentsUrl,
								commentItem, new HttpGetListener() {
									@Override
									public void loadHttpSuccess() {
//										dismissDialog();
										commentItem.setUptimes(String.valueOf((Integer
												.parseInt(commentItem
														.getUptimes()) + 1)));
										commentItem.setUped(true);
										commentAdapter.notifyDataSetChanged();
//										showMessage("支持成功");
									}

									@Override
									public void loadHttpFail() {
//										dismissDialog();
//										showMessage("支持失败");
									}

									@Override
									public void preLoad() {
//										createDialog("操作中，请稍候");
									}
								});
					}
				} catch (Exception e) {
				}
			}

      private void displayUpAnimation() {

        if (null == pUpAnimationWindow) {

          aniamtionView =
              LayoutInflater.from(CommentsActivity.this).inflate(R.layout.support_animation_view,
                  null);
          pUpAnimationWindow = new PopupWindow(aniamtionView);
          imgSlice = (ImageView) aniamtionView.findViewById(R.id.img_slace);
        }

        pUpAnimationWindow.setWidth(LayoutParams.WRAP_CONTENT);
        pUpAnimationWindow.setHeight(UP_ANMATION_HEIGHT);

        // 获取用户点击的帖子item中[顶img]距离手机顶部的距离以定义“+1”动画效果的展示位置.
        int[] xylocation = new int[2];
        imgUpTimes = (ImageView) clickViewItem.findViewById(R.id.uptimes_icon);
        imgUpTimes.getLocationInWindow(xylocation);
        txtUpTimes = (TextView) clickViewItem.findViewById(R.id.uptimes);

        pUpAnimationWindow.showAtLocation(clickViewItem, Gravity.TOP | Gravity.LEFT, xylocation[0]
            + imgUpTimes.getWidth() / 2 ,
            xylocation[1] - UP_ANMATION_HEIGHT + imgUpTimes.getHeight());
        mUpAnimation = AnimationUtils.loadAnimation(CommentsActivity.this, R.anim.animal_support);

        imgSlice.startAnimation(mUpAnimation);
        mUpAnimation.setAnimationListener(new AnimationListener() {

          @Override
          public void onAnimationStart(Animation animation) {

            // txtUpDisplay.setVisibility(View.VISIBLE);
          }

          @Override
          public void onAnimationRepeat(Animation animation) {

          }

          @Override
          public void onAnimationEnd(Animation animation) {

            // txtUpDisplay.setVisibility(View.GONE);
            new Handler().post(new Runnable() {
              @Override
              public void run() {
                pUpAnimationWindow.dismiss();
              }
            });
            imgSlice.clearAnimation();
          }
        });
        
        
      }
		});
		
		popupShare.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				//跟帖分享
				StatisticUtil.addRecord(CommentsActivity.this, StatisticRecordAction.action, "type="+StatisticPageType.share);
				isPopupOnclick = true;
				smile_pop.dismiss();
				try {
			
					if (isNetworkConnected(CommentsActivity.this)) {
				
						onShare(commentItem);
					} else {
						
						showMessage("此功能不可用");
					}
				} catch (Exception e) {
				}
			}
		});
	}
	
	protected void onShare(Comment commentItem) {
	
		String docContent = commentItem.getComment_contents();
		ArrayList<String> imageLists = new ArrayList<String>();
		if (imageUrl != null && !"".equals(imageUrl)) {
			imageLists.add(imageUrl);
		}
		
		ShareAlertBig alert = new ShareAlertBig(CommentsActivity.this,
				new WXHandler(this), shareUrl, titleStr, docContent,
				imageLists, documentId, StatisticUtil.StatisticPageType.article,ShareAlert.COMMENT_STATE);
		alert.show(CommentsActivity.this);
	}
	
	


	public boolean isNetworkConnected(Context context) {
		return NetworkState.isActiveNetworkConnected(context);
	}
	
	
	@Override
	protected void onDestroy() {
		newsCommentsList.clear();
		hotCommentsList.clear();
		super.onDestroy();
	}

	private void createDialog(String message) {
		loadingDialog = ProgressDialog.show(CommentsActivity.this, "", message,
				true, true, new OnCancelListener() {
					@Override
					public void onCancel(DialogInterface dialog) {
						dialog.dismiss();
					}
				});
	}

	private void dismissDialog() {
		if (loadingDialog != null)
			loadingDialog.dismiss();
	}
	
	/**
	 * 隐藏正在载入的图标
	 */
	private void hideLoadingBar(){
		if(loadingBar.getVisibility() == View.VISIBLE){
			loadingBar.setVisibility(View.INVISIBLE);
		}
	}

	@Override
	public void loadComplete(LoadContext<?, ?, CommentsData> context) {
		hideLoadingBar();
		ArrayList<Comment> list = context.getResult().getComments().getNewest();
		if (list == null) {
			list = new ArrayList<Comment>();
		}
		if (!CommentsActivity.this.isFinishing() && getFirstPageFlag()) {
			hotCommentsList = context.getResult().getComments().getHottest() == null ? hotCommentsList
					: context.getResult().getComments().getHottest();
			newsCommentsList = list;
			if (newsCommentsList.size() == SINGLE_PAGE_SIZE) {
				commentListView.addFooterView(loadingMore);
				loadingMore.setVisibility(View.INVISIBLE);
			}
			commentAdapter.setCommentsData(context.getResult());
			commentAdapter.setNewsComments(newsCommentsList);
			commentAdapter.setHotComments(hotCommentsList);
			commentListView.setAdapter(commentAdapter);
			pageNo++;
		} else if (!CommentsActivity.this.isFinishing() && !getFirstPageFlag()
				&& list.size() != 0) {
			loadingMore.setVisibility(View.GONE);
			newsCommentsList.addAll(list);
			commentAdapter.setNewsComments(newsCommentsList);
			commentAdapter.notifyDataSetChanged();
			pageNo++;
		} else if (!CommentsActivity.this.isFinishing() && !getFirstPageFlag()
				&& list.size() == 0) {
			loadingMore.setVisibility(View.GONE);
			commentListView.removeFooterView(loadingMore);
			commentAdapter.notifyDataSetChanged();
			showMessage("无更多评论");
			isBottomShowing = true;
		}
		listOnLoad = false;
	}

	@Override
	public void loadFail(LoadContext<?, ?, CommentsData> context) {
		hideLoadingBar();
		if (getFirstPageFlag()) {
			loadFail.setVisibility(View.VISIBLE);
			editBtn.setOnClickListener(new  OnClickListener() {
				
				@Override
				public void onClick(View v) {
					showMessage("暂时不能跟帖哦");
				}
			});
//			listOnLoad = true;
		} else {
			commentListView.removeFooterView(loadingMore);
			commentListView.scrollTo(0, 0);
			showMessage("载入失败，请重试");
		}
		listOnLoad = false;
	}

	@Override
	public void postExecut(LoadContext<?, ?, CommentsData> context) {
		//check the integrity of data
		if(null == context.getResult().getComments()){
			context.setResult(null);
			return;
		}
		context.getResult().setComments(changeCommentsOrder(context.getResult().getComments()));
	}
	
	private AllComments changeCommentsOrder(AllComments allcomments) {
	  if (null != allcomments.getHottest()) {
	    for (Comment comment : allcomments.getHottest()) {
	      if (null == comment || null == comment.getParent() || comment.getParent().size() <= 1) {
	        continue;
	      }
	      Collections.reverse(comment.getParent());
	    }
	  }
	  if (null != allcomments.getNewest()) {
	    for (Comment comment : allcomments.getNewest()) {
	      if (null == comment || null == comment.getParent() || comment.getParent().size() <= 1) {
	        continue;
	      }
	      Collections.reverse(comment.getParent());
	    } 
	  }
	  return allcomments;
	}
	
	
	@Override
	public void finish() {
		StatisticUtil.isBack = true ; 
		super.finish();
		overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
	}
	
	@Override
	public void onBackPressed() {
		finish();
	}

}