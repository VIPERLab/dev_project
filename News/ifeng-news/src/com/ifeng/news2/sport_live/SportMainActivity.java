package com.ifeng.news2.sport_live;

import com.ifeng.news2.util.IntentUtil;

import java.util.ArrayList;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.RelativeLayout;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.activity.AppBaseActivity;
import com.ifeng.news2.share.ShareAlertBig;
import com.ifeng.news2.share.WXHandler;
import com.ifeng.news2.sport_live.entity.MatchInfo;
import com.ifeng.news2.sport_live.entity.SportFactItem;
import com.ifeng.news2.sport_live.fragment.SportLiveCommentFragment;
import com.ifeng.news2.sport_live.fragment.SportLiveFactFragment;
import com.ifeng.news2.sport_live.util.SportRedirectUtil;
import com.ifeng.news2.sport_live.widget.PromptSportLiveBottom;
import com.ifeng.news2.sport_live.widget.PromptSportLiveBottom.BottomListener;
import com.ifeng.news2.sport_live.widget.PromptTalkView;
import com.ifeng.news2.sport_live.widget.SportLiveTitle;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.RestartManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticRecordAction;
import com.qad.app.BaseFragmentActivity;

/**
 * 测试直播页的视图的Activity，暂时将新闻主页的设置按钮作为入口
 * 
 * @author SunQuan
 * 
 */
public class SportMainActivity extends BaseFragmentActivity implements
		BottomListener, OnPageChangeListener, OnTouchListener {

	private long startTime = 0;
	private RelativeLayout bottomContainer;
	private PromptSportLiveBottom sportLiveBottom;

	// 比赛id
	public String mt;
	public ViewPager pager;
	private SportLiveTitle titleView;
	private String thumbnail = null; //专题列表缩略图
	//定时刷新时间间隔
	public static final int REFRESH_TIME_INTERVAL = 15000;
	//fragment页数
	public static final int SPORT_PAGE_NUM = 2;
	private FragmentManager fragmentManager;
	public Handler handler = new Handler();
	private SportLiveAdapter pagerAdapter;
	private PromptViewManager promptViewManager;
	private Bundle bundle;
	private String action;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.sport_live_main);
		init();
		//获取intent数据
		getIntentData();
	}
	
	private void getIntentData() {
		// TODO Auto-generated method stub
		Intent intent = getIntent();
		thumbnail = intent.getStringExtra(ConstantManager.THUMBNAIL_URL);
	}
	
	
	@Override
	protected void onForegroundRunning() {
		super.onForegroundRunning();
		boolean res = RestartManager.checkRestart(this, startTime, RestartManager.HOME);
		if (!res) { // 需要重启应用时不再统计应用从后台到前台的这次启动
			/*
			 * 需要判断将应用带到前台的来源，可能是：推送、分享和用户点击应用。目前推送只能推文章、分享只能分享文章和幻灯，未来若增加别的类型需要增加相应处理
			 */
			String startSourceString = "direct";
			if (AppBaseActivity.startSource == ConstantManager.IN_FROM_OUTSIDE) {
				startSourceString = "outside";
			} else if (AppBaseActivity.startSource == ConstantManager.IN_FROM_PUSH) {
				startSourceString = "push";
			} else if (AppBaseActivity.startSource == ConstantManager.IN_FROM_WIDGET){
				startSourceString = "desktop";
			}
			if (StatisticUtil.isValidStart(this)) {
				StatisticUtil.addRecord(this, StatisticUtil.StatisticRecordAction.in, "type="+startSourceString);
			}
			AppBaseActivity.startSource = ConstantManager.IN_FROM_APP; // 复原来源设置
		}
		IfengNewsApp.shouldRestart = true;
		// 记录进入应用的时间，用于使用时长统计
		if (IfengNewsApp.isEndStatisticSent) {
			PreferenceManager.getDefaultSharedPreferences(this).edit().putLong("entryTime", System.currentTimeMillis()).commit();
			IfengNewsApp.isEndStatisticSent = false;
		}
	}

	@Override
	protected void onBackgroundRunning() {
		super.onBackgroundRunning();
		startTime = System.currentTimeMillis();
		long currentTime = System.currentTimeMillis();
		long entryTime = PreferenceManager.getDefaultSharedPreferences(this).getLong("entryTime", 0);
		StatisticUtil.addRecord(this, StatisticUtil.StatisticRecordAction.end, "odur=" + (currentTime - entryTime)/1000);
		IfengNewsApp.isEndStatisticSent = true;
	}
	
	@Override
	protected void onResume() {
		RestartManager.checkRestart(this, startTime, RestartManager.LOCK);
		super.onResume();
	}

	/**
	 * 初始化视图信息
	 */
	private void init() {	
		mt = getIntent().getStringExtra("MATCH_ID");
		action = getIntent().getAction();
		// 临时将其设置为5596，方便测试，mt实际会通过列表跳转传入
		//mt = "5596";
		titleView = (SportLiveTitle) findViewById(R.id.top);
		titleView.displayDataByUrl(Config.MATCH_INFO_URL + "&mt=" + mt);		
		bottomContainer = (RelativeLayout) findViewById(R.id.bottom);
		pager = (ViewPager) findViewById(R.id.content);
		promptViewManager = PromptViewManager.getInstance();
		promptViewManager.setContainer(bottomContainer);
		bundle = promptViewManager.getShareBundle();
		bundle.putString("mt", mt);
		promptViewManager.changeView(PromptSportLiveBottom.class,
				bundle);
		sportLiveBottom = ((PromptSportLiveBottom) promptViewManager.getCurrentView());
		sportLiveBottom.setBottomListener(this);
		fragmentManager = getSupportFragmentManager();
		pagerAdapter = new SportLiveAdapter(fragmentManager);
		pager.setAdapter(pagerAdapter);
		pager.setOnPageChangeListener(this);
		pager.setOnTouchListener(this);
		titleView.setOnTouchListener(this);
	}

	@Override
	public void onBackPressed() {
		if (!promptViewManager.backToOriginal()) {
			back();
		}
	}
	
	@Override
	protected void onDestroy() {
		promptViewManager.destroyPrompt();	
		super.onDestroy();
	}
	
	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			onBackPressed();
			return true;
		}
		return super.onKeyUp(keyCode, event);
	}

	@Override
	public void showShareView() {
		// 分享内容，比赛对阵信息和直播地址
		StringBuilder builder = new StringBuilder();
		builder.append(Config.SHARE_URL).append("?mt=").append(mt);
		// 统计时需要加入id和类型type，体育直播由于没有documentId所以直接从分享链接中解析mt参数作为id
		ShareAlertBig alert = new ShareAlertBig(me, new WXHandler(me),
				builder.toString(), getShareContent(), getShareContent(),getShareImage(), null, StatisticUtil.StatisticPageType.sportslive);
		alert.show(me);
	}
	
	/**
	 * 获得分享内容
	 * 
	 * @return 分享内容
	 */
	private String getShareContent(){
		StringBuilder builder = new StringBuilder();
		builder.append("凤凰新闻客户端体育直播 ");
		MatchInfo matchInfo = titleView.getMatchInfo();
		if (matchInfo != null) {
			builder.append(matchInfo.getBody().getAwayTeam()).append("-")
					.append(matchInfo.getBody().getHomeTeam()).append(" ");
		}
		return builder.toString();
	}
	
	/**
	 * 获取缩略图
	 * @return
	 */
	private ArrayList<String> getShareImage(){
		ArrayList<String> thumbnails = new ArrayList<String>();
		if(!TextUtils.isEmpty(thumbnail))
			thumbnails.add(thumbnail);
		return thumbnails;
	}
	
	

	@Override
	public void redirectToReportPage() {
		SportRedirectUtil.redirect(me, SportRedirectUtil.GOTO_REPORT_PAGE, mt);
	}

	@Override
	public void redirectToDataPage() {
		SportRedirectUtil.redirect(me, SportRedirectUtil.GOTO_DATA_PAGE, mt);
	}

	@Override
	public void goToChatPage() {
		pager.setCurrentItem(1, true);
	}

	@Override
	public void back() {
		if (sportLiveBottom.isMainState()) {
			StatisticUtil.isBack = true ; 
		    if (ConstantManager.ACTION_FROM_STORY.equals(action)) {
		      IntentUtil.redirectHome(this);
            } else {
              finish();
            }
		    overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
		} else {
			pager.setCurrentItem(0, true);
		}
	}

	@Override
	public void finish() {
		promptViewManager.destroyPrompt();	
		super.finish();
	}

	public class SportLiveAdapter extends FragmentStatePagerAdapter {

		public SportLiveAdapter(FragmentManager fm) {
			super(fm);
		}

		@Override
		public Fragment getItem(int position) {
			Fragment fragment = null;
			if (position == 0) {
				fragment = Fragment.instantiate(me,
						SportLiveFactFragment.class.getName());
			} else {
				fragment = Fragment.instantiate(me,
						SportLiveCommentFragment.class.getName());
			}
			return fragment;
		}

		@Override
		public int getCount() {
			return SPORT_PAGE_NUM;
		}
	}

	@Override
	public void onPageScrollStateChanged(int arg0) {

	}

	@Override
	public void onPageScrolled(int arg0, float arg1, int arg2) {
		
	}

	@Override
	public void onPageSelected(int arg0) {
		sportLiveBottom.switchState();
	}

	/**
	 * @param touser
	 *            对某人聊天时某人的id
	 * @param tonick
	 *            对某人聊天时某人的name
	 */
	public void speech(String tonick, String touser) {
		bundle.putString("tonick", tonick);
		bundle.putString("touser", touser);
		if (sportLiveBottom.isMainState()) {
			pager.setCurrentItem(1, true);
		}
		promptViewManager.changeView(PromptTalkView.class, bundle);
	}

	/**
	 * 更新比赛分数和比赛时间
	 */
	public void updateTitle(SportFactItem sportFactItem) {
		titleView.notifyTitle(sportFactItem);
	}

	/**
	 * 得到底部导航栏的高度
	 * 
	 * @return
	 */
	public int getBottomHeight() {
		return sportLiveBottom.getBottomTabbarHeight();
	}

	/**
	 * 得到顶部视图的高度
	 * 
	 * @return
	 */
	public int getTitleHeight() {
		return titleView.getHeight();
	}

	@Override
	public boolean onTouch(View v, MotionEvent event) {
		showBottomView();
		return false;
	}

	/**
	 * 收回其他视图，返回到底部视图
	 */
	public void showBottomView() {
		promptViewManager.changeView(PromptSportLiveBottom.class);

	}

	/**
	 * 跳转到毒舌页
	 */
	public void goToPoisonousWordPage() {
		SportRedirectUtil.redirect(me, SportRedirectUtil.GOTO_POISONOUS_PAGE,
				mt);
	}

}
