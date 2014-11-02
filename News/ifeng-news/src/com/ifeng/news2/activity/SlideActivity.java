package com.ifeng.news2.activity;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.method.ScrollingMovementMethod;
import android.text.style.StyleSpan;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.ViewSwitcher;
import com.ifeng.news2.Config;
import com.ifeng.news2.FunctionActivity;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.R.id;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.adapter.SlideAdapter;
import com.ifeng.news2.adapter.SlideAdapter.SlideHolder;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.CommentsData;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.bean.SlideBody;
import com.ifeng.news2.bean.SlideItem;
import com.ifeng.news2.db.CollectionDBManager;
import com.ifeng.news2.fragment.NewsMasterFragmentActivity;
import com.ifeng.news2.share.ShareAlertBig;
import com.ifeng.news2.share.WXHandler;
import com.ifeng.news2.util.CommentsManager;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.FunctionButtonWindow;
import com.ifeng.news2.util.WindowPrompt;
import com.ifeng.news2.util.FunctionButtonWindow.FunctionButtonInterface;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.PhotoModeUtil;
import com.ifeng.news2.util.PhotoModeUtil.PhotoMode;
import com.ifeng.news2.util.SoftKeyUtil;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticPageType;
import com.ifeng.news2.util.StatisticUtil.StatisticRecordAction;
import com.ifeng.news2.widget.IfengBottomTitleTabbar;
import com.ifeng.news2.widget.SlideView;
import com.ifeng.news2.widget.zoom.PhotoView;
import com.ifeng.share.util.NetworkState;
import com.qad.annotation.InjectExtras;
import com.qad.loader.ImageLoader;
import com.qad.loader.ImageLoader.ImageDisplayer;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.net.HttpGetListener;
import com.qad.render.RenderEngine;
import java.util.ArrayList;
import org.taptwo.android.widget.ViewFlow.ViewSwitchToListener;

public class SlideActivity extends FunctionActivity implements
		OnItemSelectedListener, OnClickListener, LoadListener<SlideBody>, FunctionButtonInterface
		, ViewSwitchToListener {

	public static final String EXTRA_SLIDES = "extra.com.ifeng.news.slides";
	public static final String EXTRA_POSITION = "extra.com.ifeng.news.position";
	public static final String EXTRA_DESCRIPTION = "extra.com.ifeng.news.description";
	public static final String EXTRA_URL = "extra.com.ifeng.news.url";
	public static final String ACTION_FROM_APP = "action.com.ifeng.news.from_app";
	public static final String ACTION_FROM_WEBVIEW = "action.com.ifeng.news.from_webview";

	SlideView slideView;
	EditText commentET;
	ImageView landscapeBack;
	View checkComment;

	View titleBar;
	View closeBtn;
	View submitBtn;
	View bottomBar2;
	View slideTitle;
	View slideBackTag;
	View detailCommentModule;

	ImageView moreButton;
	ImageView placeholder;
	ImageView backButton;
	ImageView commentButton;
	ImageView loading;
	
	TextView title;
	TextView pageTips;
	TextView positioned;
	TextView description;
	TextView commentsNum;
	
	ViewSwitcher landPortswitcher;
	IfengBottomTitleTabbar bottomBar;
	
	@InjectExtras(name = EXTRA_POSITION, optional = true)
	int position = 0;
	@InjectExtras(name = EXTRA_URL, optional = true)
	String slideUrl;
	private SlideItem item;
	private boolean collapse;
	private ImageLoader loader;
	private ProgressDialog loadingDialog;
	private CommentsManager commentsManager;
	private SlideAdapter adapter;
	private FunctionButtonWindow functionButtonWindow;
	private ArrayList<SlideItem> items;
	private boolean isFullScreen = false;
	
	String lastDocId = null;
	private PhotoView cView = null;
	
	private TextView landscapePageTips;
	private TextView landscapeTitle;
	private View landscapeSlideTitle;
	private TextView landscapeDescription;

	public static void startFromApp(Context context, int position) {
	    Intent intent = new Intent(context, SlideActivity.class);
		intent.putExtra(EXTRA_POSITION, position);
		intent.setAction(ACTION_FROM_APP);		
		context.startActivity(intent);
		((Activity) context).overridePendingTransition(R.anim.in_from_right,
				R.anim.out_to_left);
	}

	@Override
	protected void onSaveInstanceState(Bundle outState) {
		outState.putSerializable(EXTRA_SLIDES, items);
		outState.putInt(EXTRA_POSITION, position);		
		super.onSaveInstanceState(outState);
		Log.e("tag", " onSaveInstanceState  position = "+position);
	}
	
	@SuppressWarnings("unchecked")
	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
		if (savedInstanceState != null) {
			items = (ArrayList<SlideItem>) savedInstanceState
					.getSerializable(EXTRA_SLIDES);
			position = savedInstanceState.getInt(EXTRA_POSITION);
			Log.e("tag", " savedInstanceState  position = "+position);
			if(items!=null&&items.size()>0){
				item = items.get(position);
				loading.setVisibility(View.GONE);
			}
		}
		super.onRestoreInstanceState(savedInstanceState);
	}

	@SuppressWarnings("unchecked")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Log.d("render", "onCreate..");
		super.onCreate(savedInstanceState);
		setContentView(layout.slide);
		findViewById();
		adapter = new SlideAdapter(this);
		commentsManager = new CommentsManager();
		detailCommentModule
				.setBackgroundResource(R.drawable.comment_write_background);
		setButtonListener(true);
		slideView.setOnItemSelectedListener(this);
		slideView.setOnViewSwitchToListener(this);
		detailCommentModule.setVisibility(View.GONE);
		functionButtonWindow = new FunctionButtonWindow(this);
		functionButtonWindow.setFunctionButtonInterface(this);
		if (savedInstanceState != null) {
			items = (ArrayList<SlideItem>) savedInstanceState
					.getSerializable(EXTRA_SLIDES);
			position = savedInstanceState.getInt(EXTRA_POSITION);
			if(items!=null&&items.size()>0){
				item = items.get(position);
				loading.setVisibility(View.GONE);
			}
		} 
		// 如果有存储的状态savedInstanceState就不能再去取items了。e.g.在后台被kill之后不能再到IfengNewsApp中取items
		if ((items==null||items.size()==0)&&((ACTION_FROM_WEBVIEW.equals(getIntent().getAction())
				|| ConstantManager.ACTION_FROM_HEAD_IMAGE.equals(getIntent()
						.getAction())
				|| ConstantManager.ACTION_FROM_ARTICAL.equals(getIntent()
						.getAction())
				|| Intent.ACTION_VIEW.equals(getIntent().getAction())
				|| ConstantManager.ACTION_WIDGET.equals(getIntent().getAction())))) {
			if (Intent.ACTION_VIEW.equals(getIntent().getAction())) {
				IfengNewsApp.shouldRestart = false;
				if (!getIntent().hasExtra("isRelationClick")) { // fix bug #15936
					Uri uri = getIntent().getData();
					slideUrl = String.format(Config.DETAIL_URL,
							uri.getLastPathSegment());
				}
				// 从相关新闻跳入时 url 由 extra EXTRA_URL传入
//				position = 0;
				// 记录打开文章的来源，用于统计IN启动的来源
				startSource = ConstantManager.IN_FROM_OUTSIDE;
			}else if (getIntent().getAction().equals(ConstantManager.ACTION_WIDGET)){
				// 记录打开文章的来源，用于统计IN启动的来源
				startSource = ConstantManager.IN_FROM_WIDGET;
			}
			if (TextUtils.isEmpty(slideUrl))
				return;
			items = new ArrayList<SlideItem>();
			IfengNewsApp
					.getBeanLoader()
					.startLoading(
							new LoadContext<String, LoadListener<SlideBody>, SlideBody>(
									ParamsManager.addParams(slideUrl), this,
									SlideBody.class, Parsers
											.newSlideBodyParser(),
									LoadContext.FLAG_FILECACHE_FIRST));
			return;
		} else if (ACTION_FROM_APP.equals(getIntent().getAction())) {
			loading.setVisibility(View.GONE);
			items = ((IfengNewsApp) getApplication()).getSlideItems();
			position = (position < items.size() ? position : 0);
		}

		adapter.setItems(items);
		Log.e("tag", "position = "+position);
		slideView.setAdapter(adapter, position);
//		toggleCollapse();// ensure collapse
		//初始化幻灯片
		onSwitchTo(position);
	}
	//fix bug#19347 【幻灯】横屏时，幻灯页依然可以显示各功能项
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		Log.d("render", "onConfigurationChanged..");
		super.onConfigurationChanged(newConfig);
		if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
			titleBar.setVisibility(View.GONE);
		    landPortswitcher.setDisplayedChild(0);
		}else{
			if(!isFullScreen)
				titleBar.setVisibility(View.VISIBLE);
		    landPortswitcher.setDisplayedChild(1);
		}
	}
	public void findViewById(){
	  slideView = (SlideView)findViewById(id.slide);
	  detailCommentModule = findViewById(id.detail_comment_module3);
	  checkComment = findViewById(id.checkComment);
	  submitBtn = findViewById(id.detail_submit_comment_button);
	  commentET = (EditText)findViewById(id.detail_comment_editText);
	  closeBtn = findViewById(id.detail_close_commment_button);
	  landscapeBack = (ImageView)findViewById(id.landscape_back);
	  slideBackTag = findViewById(id.slide_back_tag);
	  placeholder = (ImageView)findViewById(id.placeholder);

	  titleBar = findViewById(id.titlebar);
	  bottomBar = (IfengBottomTitleTabbar)findViewById(id.bottombar);
	  bottomBar2 = findViewById(id.bottombar2);
	  moreButton = (ImageView)findViewById(id.more);
	  backButton = (ImageView)findViewById(id.back);
	  commentButton = (ImageView)findViewById(id.write_comment);
	  loading = (ImageView)findViewById(id.loading);
	  commentsNum = (TextView)findViewById(id.commentsNum);
	  positioned = (TextView)findViewById(id.position);
	  
	  landPortswitcher = (ViewSwitcher)findViewById(id.land_port_switcher);
	  //加载竖屏模式
	  landPortswitcher.setDisplayedChild(1);
	  pageTips = (TextView)findViewById(id.page_tips);
	  title = (TextView)findViewById(id.title);
	  slideTitle = findViewById(id.slide_title);
	  description = (TextView)findViewById(id.description);
	    
	  landscapePageTips = (TextView)findViewById(id.landscape_page_tips);
	  landscapeTitle = (TextView)findViewById(id.landscape_title);
	  landscapeSlideTitle = findViewById(id.landscape_slide_title);
	  landscapeDescription = (TextView)findViewById(id.landscape_description);

	  landscapeBack.setOnClickListener(this);
	  description.setMovementMethod(ScrollingMovementMethod.getInstance());   
	  landscapeDescription.setMovementMethod(ScrollingMovementMethod.getInstance());   
	  // 发帖框加入“文明上网，遵守“七条底线””
	  findViewById(R.id.policy_text).setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				updateEditCommentModule(false);
				
				Intent intent = new Intent();
				intent.setAction(Intent.ACTION_VIEW);
				intent.setData(Uri.parse("comifengnews2app://doc/68983945"));
//				intent.setClass(SlideActivity.this, AdDetailActivity.class);
//				intent.putExtra("URL", "http://i.ifeng.com/news/zhuanti/qd/zx/sharenews.f?vt=5&aid=68983945&mid=6qgxho");
				SlideActivity.this.startActivity(intent);
				//增加跳转动画
				overridePendingTransition(R.anim.in_from_right,
						R.anim.out_to_left);
			}
		});
	}
	
	@Override
	public void onBackPressed() {
		StatisticUtil.isBack = true ; 
		//fix bug 17579
		SoftKeyUtil.showSoftInput(getApplicationContext(), commentET, false);	
		
		if (getIntent() != null
				&& (getIntent().getBooleanExtra(
						IntentUtil.EXTRA_REDIRECT_HOME, false)||ConstantManager.isOutOfAppAction(getIntent().getAction()))){
			 if (!NewsMasterFragmentActivity.isAppRunning && DetailActivity.pageCount == 0) {
				// 列表没有运行且改幻灯不是由正文页跳入才跳转到列表页
				 IntentUtil.redirectHome(this);
			 }			
		}		
		finish();
		overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
	}
	

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.checkComment:
			onComment(false);
			break;
		case R.id.slide_title:
			//toggleCollapse();
			break;
		case R.id.landscape_slide_title:
          //toggleCollapse();
          break;
			//此处为下载功能
		case R.id.more:
			/*ArrayList<String> functionBut = new ArrayList<String>();
			functionBut.add("下载");
			// functionBut.add("收藏");
			functionBut.add("分享");
			functionButtonWindow.showMoreFunctionButtons(moreButton, functionBut,
					FunctionButtonWindow.TYPE_FUNCTION_BUTTON_BLACK);*/
			if (isNetworkConnected(this)) {
				downloadPicture();
			} else {
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
			}
			
			break;
			//此处为分享功能
		case R.id.write_comment:
			if (isNetworkConnected(this)) {
				showShareView();
			} else {
				showMessage(R.string.not_network_message);
			}
			break;
			//此处为跟帖功能
		case R.id.placeholder:
			if (isNetworkConnected(this)) {			
				updateEditCommentModule(true);
			} else {
				showMessage(R.string.not_network_message);
			}
			break;
		case R.id.back:
			onBackPressed();
			break;
		case R.id.landscape_back:
          onBackPressed();
          break;
		case R.id.detail_submit_comment_button:
			if (item != null) {
				sendComment();
			}
			break;
		case R.id.detail_close_commment_button:
			if (isNetworkConnected(this)) {
				updateEditCommentModule(false);
			} else {
				showMessage(R.string.not_network_message);
			}
			break;
		default:
			break;
		}
	}

	public void setButtonListener(boolean enableUitlBottons) {
		if (!enableUitlBottons) {
			return;
		}
		checkComment.setOnClickListener(this);
		slideTitle.setOnClickListener(this);
		moreButton.setOnClickListener(this);
		commentButton.setOnClickListener(this);
		backButton.setOnClickListener(this);
		submitBtn.setOnClickListener(this);
		closeBtn.setOnClickListener(this);
		landscapeBack.setOnClickListener(this);
		placeholder.setOnClickListener(this);
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
		slideView.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				updateEditCommentModule(false);
				return false;
			}
		});
	}

	protected void sendComment() {
		String quoteId = null;
		String commentContent = commentET.getText().toString().trim();
		if (TextUtils.isEmpty(commentContent)) {
			windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.toast_edit_empty_title, R.string.toast_edit_empty_content);
			return;
		}
		//回复功能统计
		StatisticUtil.addRecord(this, StatisticRecordAction.action, "type="+StatisticPageType.follow);
		updateEditCommentModule(false);
		String docName = item.getTitle();
		String url = item.getCommentsUrl();
		commentContent = commentContent.replaceAll("<", " ").replaceAll(">",
				" ");
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
		commentsManager.sendComments(quoteId, docName, url, commentContent, null, new HttpGetListener() {

					@Override
					public void loadHttpSuccess() {
						loadingDialog.dismiss();
						windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.toast_publish_success_title, R.string.toast_publish_success_content);
					}

					@Override
					public void loadHttpFail() {
						loadingDialog.dismiss();
						windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.toast_publish_fail_title, R.string.toast_publish_fail_content);
					}

					@Override
					public void preLoad() {
						loadingDialog = ProgressDialog.show(SlideActivity.this,
								"", "正在发布，请稍候", true, true,
								new OnCancelListener() {
									@Override
									public void onCancel(DialogInterface dialog) {
										dialog.dismiss();
									}
								});
					}
				});
		commentET.setText("");
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		return false;
	}

	@Override
	protected void onShare() {
		super.onShare();
		String shareUrl = item.getShareurl();
		 
		ArrayList<String> shareImage = new ArrayList<String>();
		String imgUrl = item.getImage();		
		//2G3G无图模式下并且文件不存在的话，将不分享图片
		if(PhotoModeUtil
				.getCurrentPhotoMode(this) == PhotoMode.VISIBLE_PATTERN) {
			shareImage.add(item.getImage());
		}
		else if (SlideAdapter.isImageExist(imgUrl)) {
			shareImage.add(item.getImage());
		}
		// share(SlideActivity.this, item.getTitle(), content, shareUrl,
		// shareImage);
		ShareAlertBig alert = new ShareAlertBig(SlideActivity.this,
				new WXHandler(this), shareUrl, getShareTitle(), getShareContent(),
				shareImage, item.getDocumentId(), StatisticUtil.StatisticPageType.pic);
		alert.show(SlideActivity.this);
	}
	
	/**
	 * 分享标题
	 * @return
	 */
	private String getShareTitle(){
		return item.getTitle() ;
	}

	/**
	 * 简介不为空，去简介作为分享内容，否则取标题
	 * 
	 * @return
	 */
	private String getShareContent() {
		String content = item.getDescription() ;
		if(!TextUtils.isEmpty(content))
			return content.length() > Config.SHARE_MAX_LENGTH ? content.substring(0, Config.SHARE_MAX_LENGTH)+"..." : content;
		return "";
	}

	@Override
	protected void onComment(boolean isShowSoftInput) {
		super.onComment(isShowSoftInput);
		if (item == null)
			return;
		
		String imgUrl = item.getImage();		
		
		if(PhotoModeUtil.getCurrentPhotoMode(this) != PhotoMode.VISIBLE_PATTERN
				|| !SlideAdapter.isImageExist(imgUrl)) {
			imgUrl = null;
		}
		comment(item.getCommentsUrl(), item.getCommentType(), item.getTitle(),
				item.getWwwurl(), item.getDocumentId(), true,imgUrl,item.getShareurl(),getIndex(item.getPosition()),ConstantManager.ACTION_FROM_SLIDE);
	}

	@Override
	public void toggleFullScreen() {
		if (detailCommentModule.getVisibility() == View.VISIBLE) {
			updateEditCommentModule(false);
			collapse = false;
			//toggleCollapse();
			return;
		} else {
			isFullScreen=!isFullScreen;
//			super.toggleFullScreen();
			Animation fadeOutAnimation = AnimationUtils.loadAnimation(this, R.anim.fade_out);
			Animation fadeInAnimation = AnimationUtils.loadAnimation(this, R.anim.fade_in);
			if (isFullScreen) {
				//全屏时  把当前item的DocumentId赋给lastDocId
				lastDocId = item.getDocumentId();
				collapse = false;
//				toggleCollapse();// ensure collapse
				bottomBar2.startAnimation(fadeInAnimation);
				bottomBar2.setVisibility(View.VISIBLE);
				
				landPortswitcher.startAnimation(fadeOutAnimation);
				landPortswitcher.setVisibility(View.GONE);	
				if(this.getResources().getConfiguration().orientation != Configuration.ORIENTATION_LANDSCAPE){
					titleBar.startAnimation(fadeOutAnimation);
				}			
				titleBar.setVisibility(View.GONE);
				
			} else {
				bottomBar2.startAnimation(fadeOutAnimation);
				bottomBar2.setVisibility(View.GONE);
				
				landPortswitcher.startAnimation(fadeInAnimation);
				landPortswitcher.setVisibility(View.VISIBLE);
				
				if(this.getResources().getConfiguration().orientation != Configuration.ORIENTATION_LANDSCAPE){
					titleBar.startAnimation(fadeInAnimation);
					titleBar.setVisibility(View.VISIBLE);
				}
			}
		}
	}

	private void prefetch() {
		if (NetworkState.isWifiNetworkConnected(this)
				&& Config.ENALBE_PREFETCH) {
			ImageView tempImageView = new ImageView(this);
			loader = IfengNewsApp.getImageLoader();
			ImageDisplayer noneDisplayer = new NoneImageDisplayer();
			if (items.size() == 0)
				return;// precheck
			int cursor = 0;
			while (true) {
				SlideItem item1 = items.get(cursor);
				SlideItem item2 = items.get(items.size() - cursor - 1);
				try {
					loader.startLoading(
							new LoadContext<String, ImageView, Bitmap>(item1
									.getImage(), tempImageView, Bitmap.class,
									LoadContext.FLAG_CACHE_FIRST, this),
							noneDisplayer);
					loader.startLoading(
							new LoadContext<String, ImageView, Bitmap>(item2
									.getImage(), tempImageView, Bitmap.class,
									LoadContext.FLAG_CACHE_FIRST, this),
							noneDisplayer);
				} catch (Exception e) {
					break;
				}
				if (cursor == position)
					break;
				cursor++;
			}
		}
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
//		IfengNewsApp.getResourceCacheManager().clearMemCache();
		if (!ACTION_FROM_APP.equals(getIntent().getAction())) {
			items.clear();
		}
//		if (android.os.Build.VERSION.SDK_INT < 11) {
            // HONEYCOMB之前Bitmap实际的Pixel Data是分配在Native Memory中。
            // 首先需要调用reclyce()来表明Bitmap的Pixel Data占用的内存可回收
            // call bitmap.recycle to make the memory available for GC
			for(int i = 0; i < slideView.getChildCount(); i++) {
				Object tag = slideView.getChildAt(i).getTag();
				if (null != tag && tag instanceof SlideHolder) {
					// recycle the image
//					Drawable oldDrawable = ((SlideHolder)tag).slideImage.getDrawable();
					((SlideHolder)tag).slideImage.setTag(R.drawable.default_slide, null);
//					((SlideHolder)tag).slideImage.setImageBitmap(null);
//        			if (null != oldDrawable && oldDrawable instanceof BitmapDrawable) {
//        				Bitmap oldBmp = ((BitmapDrawable)oldDrawable).getBitmap();
//        				if (null != oldBmp && !oldBmp.isRecycled()) {
//            				Log.w("Sdebug", "Slide recycle bitmap " + oldBmp.toString());
//            				oldBmp.recycle();
//            			}
//        			}
				}
				slideView.setTag(null);
			}
//		}
	}

	
	@Override
	public void onSwitchTo(int position) {
		// fix bug #19251 mi2在查看幻灯时，应用崩溃
		if (position < 0 || position >= items.size()) {
			return;
		}
		
		if (cView != null) {
		    cView.zoomToOriginalScale();
		}
		
		item = items.get(position);
		
		this.position = position;
		title.setText(item.getTitle());
		SpannableString msp = new SpannableString(item.getPosition());
		msp.setSpan(new StyleSpan(android.graphics.Typeface.BOLD), 0, 1,
				Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
		pageTips.setText(msp);
		description.setText(item.getDescription());
		if (ACTION_FROM_APP.equals(getIntent().getAction())) {
			commentsNum.setText(item.getComments());
		}
		positioned.setText(item.getPosition());
		description.scrollTo(0, 0);
		
		//横竖屏的description等信息同步更新
		landscapeTitle.setText(item.getTitle());
		landscapePageTips.setText(msp);
		landscapeDescription.setText(item.getDescription());
		landscapeDescription.scrollTo(0, 0);
		//		  if (isFullScreen()) {
		if (isFullScreen) {
			if(item.getDocumentId() != null && !item.getDocumentId().equals(lastDocId)){
				showMessage(item.getTitle());
			}
			lastDocId = item.getDocumentId();
		}
		
		RenderEngine.render(getWindow().getDecorView(), item);
	}

	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position,
	                           long id) {
		//fix bug#19161
		//onSwitchTo(position);
		item = items.get(position);
		cView = (PhotoView) view.findViewById(R.id.slide_image);
		slideStatistic();
	}

//	private void toggleCollapse() {
//		collapse = !collapse;
//		if (collapse) {
//			description.setVisibility(View.GONE);
//		} else {		
//			description.setVisibility(View.VISIBLE);
//		}
//	}

	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		//fix bug 17579
		if (keyCode == KeyEvent.KEYCODE_BACK 
				&& detailCommentModule.getVisibility() == View.VISIBLE) {
			updateEditCommentModule(false);
			return true;
		}
		return super.onKeyUp(keyCode, event);
	}

	@Override
	public void onNothingSelected(AdapterView<?> parent) {
	}

	private void updateEditCommentModule(boolean isShow) {
		if (isShow) {
			bottomBar.setVisibility(View.GONE);
			description.setVisibility(View.GONE);
			slideTitle.setVisibility(View.GONE);
			detailCommentModule.setVisibility(View.VISIBLE);
		} else {
			detailCommentModule.setVisibility(View.GONE);
//			if (!isFullScreen()) {
			if (!isFullScreen) {
				bottomBar.setVisibility(View.VISIBLE);
				slideTitle.setVisibility(View.VISIBLE);
				//fix bug 18196【图集】在图集页发表评论后，简介不再显示，标题下移，如图
				description.setVisibility(View.VISIBLE);
			}
		}
		SoftKeyUtil.showSoftInput(getApplicationContext(), commentET, isShow);
	}

	@Override
	public void loadComplete(LoadContext<?, ?, SlideBody> arg0) {
		loading.setVisibility(View.GONE);
		SlideBody result = arg0.getResult();
		items = result.getSlides();
		String commentsUrl = result.getCommentsUrl();
		String shareUrl = result.getShareurl();
		 
		renderCommentsNum(commentsUrl);
		for (int i = 0; i < items.size(); i++) {
			SlideItem slideItem = items.get(i);
			slideItem.setDocumentId(result.getDocumentId());
			slideItem.setPosition(i + 1 + "/" + items.size());
			slideItem.setShareurl(shareUrl);
			slideItem.setCommentsUrl(commentsUrl);
		}
//		slideView.setOnItemSelectedListener(SlideActivity.this);
//		slideView.setOnViewSwitchToListener(this);
		if (items.size() == 0) {
			return;
		}
		position = position < items.size() ? position : 0;
		adapter.setItems(items);
		slideView.setAdapter(adapter, position);
		prefetch();
//		toggleCollapse();// ensure collapse
		//初始化幻灯片
		onSwitchTo(position);
	}
	
	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		if(item != null)
			StatisticUtil.doc_id = item.getDocumentId()+"_"+getIndex(item.getPosition());
		StatisticUtil.type = StatisticUtil.StatisticPageType.pic.toString() ; 
		super.onResume();
	}

	@Override
	public void loadFail(LoadContext<?, ?, SlideBody> arg0) {
		try {
			if (!NetworkState.isActiveNetworkConnected(this)) {
				showAlertDialog(SlideActivity.this);
			} else {
				showMessage("加载失败");
			}
		} catch (Exception e) {
		}
	}

	/**
	 * 图集统计
	 */
	private void slideStatistic() {
		StringBuilder enterTag = new StringBuilder();
		enterTag.append("id=").append(item.getDocumentId()).append("_").append(getIndex(item.getPosition())).append("$ref=");
		if (getIntent().getAction().equals(ACTION_FROM_WEBVIEW)) {
			if (!TextUtils.isEmpty(getIntent().getStringExtra(ConstantManager.EXTRA_GALAGERY))) {
				enterTag.append("topic_").append(getIntent().getStringExtra(ConstantManager.EXTRA_GALAGERY));
			} else if (((Channel) getIntent().getParcelableExtra(
					ConstantManager.EXTRA_CHANNEL)) != null) {
				enterTag.append(((Channel) getIntent().getParcelableExtra(
						ConstantManager.EXTRA_CHANNEL)).getStatistic());
			} else {
				enterTag.append("photo");
			}
		} else if (getIntent().getAction().equals(
				ConstantManager.ACTION_FROM_HEAD_IMAGE)) { // 从焦点图进入幻灯，来源是对应的频道
			if (((Channel) getIntent().getParcelableExtra(
					ConstantManager.EXTRA_CHANNEL)) != null) {
				enterTag.append(((Channel) getIntent().getParcelableExtra(
						ConstantManager.EXTRA_CHANNEL)).getStatistic());
			} else {
				enterTag.append("sy");
			}
			enterTag.append("$tag=t3");
		} else if (getIntent().getAction().equals(
				ConstantManager.ACTION_FROM_ARTICAL)) { // 从正文页打开图集的统计
			if (((Channel) getIntent().getParcelableExtra(
					ConstantManager.EXTRA_CHANNEL)) != null) {
				enterTag.append(((Channel) getIntent().getParcelableExtra(
						ConstantManager.EXTRA_CHANNEL)).getStatistic());
			} else {
				enterTag.append("photo");
			}
		} else if (Intent.ACTION_VIEW.equals(getIntent().getAction())) {
			// fix bug #19173 【统计】文章内超链只想幻灯时，幻灯的来源为outside
			if (getIntent().hasExtra("from_ifeng_news")) {
				enterTag.append("push");
			} else if (getIntent().hasExtra(ConstantManager.EXTRA_CHANNEL)) {
				enterTag.append(((Channel) getIntent().getParcelableExtra(
						ConstantManager.EXTRA_CHANNEL)).getStatistic());
			} else {
				// 从分享打开
				enterTag.append("outside");
			}
		} else if (getIntent().getAction().equals(ConstantManager.ACTION_WIDGET)){
			enterTag.append("desktop");
		} else {
			enterTag.append("photo");
		}
//		enterTag.append("$index_").append(getIndex(item.getPosition()));
//		StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.PICTURE,
//				item.getDocumentId(), enterTag.toString());
		enterTag.append("$type=").append(StatisticUtil.StatisticPageType.pic);
		StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page, enterTag.toString());
	}

	private void renderCommentsNum(String commentsUrl) {
		if (commentsUrl != null) {
			new CommentsManager().obtainComments(commentsUrl, 1,
					new LoadListener<CommentsData>() {

						@Override
						public void loadComplete(
								LoadContext<?, ?, CommentsData> arg0) {
							commentsNum.setText(String.valueOf(arg0.getResult().getCount()));
						}

						@Override
						public void loadFail(
								LoadContext<?, ?, CommentsData> arg0) {
						}

						@Override
						public void postExecut(
								LoadContext<?, ?, CommentsData> arg0) {
						}
					}, false);
		}
	}

	@Override
	public void postExecut(LoadContext<?, ?, SlideBody> arg0) {
		// TODO Auto-generated method stub

	}

	@Override
	public int getBottomTabbarHeight() {
		return bottomBar.getHeight();
	}
	
	@Override
	public boolean onCollect() {
		try {
			if (isCollected()) {
				cancleCollection(item.getDocumentId());
				windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_collection, R.string.toast_store_cancel_title, R.string.toast_store_cancel_content);
			} else {
				ListItem listItem = new ListItem();
				listItem.setId(item.getId());
				listItem.setThumbnail(item.getImage());
				listItem.setDocumentId(item.getDocumentId());
				listItem.setHasVideo("N");
				listItem.setTitle(item.getTitle());
				listItem.setStatus(true);
				listItem.setPosition(getItemPositon());
				listItem.setType(CollectionDBManager.TYPE_SLIDE);
				ArrayList<Extension> links = new ArrayList<Extension>();
				Extension extension = new Extension();
				extension.setType("slide");
				links.add(extension);
				listItem.setLinks(links);
				if (collect(listItem)) {
					windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_right, R.string.toast_store_success_title, R.string.toast_store_success_content);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return true;
	}

	public String getItemPositon() {
		if (null == item)
			return null;
		String itemPosition = item.getPosition();
		int temp = -1;
		if ((temp = itemPosition.indexOf("/")) < 0)
			return itemPosition;
		else
			return itemPosition.substring(0, temp);
	}

	@Override
	public void initCollectViewState() {
		if (null == item)
			return;
		functionButtonWindow.isCollected = collectionDBManager.isCollectioned(item.getDocumentId());
	}

	@Override
	public void downloadPicture() {
		if (item != null) {
			downLoadImage(item.getImage());
		} else {
			showMessage("下载失败");
		}
	}

	@Override
	public void showShareView() {
		if (item != null) {
			onShare();
		}

	}

	public void saveItemsEntity() {

	}

	public void deteleItemsEntity() {

	}
	
	private String getIndex(String originalIndex){
		int resultIndex = 0;
		String result = "";
		if(originalIndex.contains("/")){
			 result = originalIndex.substring(0, originalIndex.indexOf("/"));
			 resultIndex =  Integer.parseInt(result)-1;
		}		
		return String.valueOf(resultIndex);
	}


}
