package com.ifeng.news2.fragment;

import static com.ifeng.news2.fragment.HeadChannelFragment.EXTRA_CHANNEL;

import com.ifeng.news2.util.DeviceUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.Parcelable;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengListLoadableFragment;
import com.ifeng.news2.IfengLoadableFragment;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.activity.AppBaseActivity;
import com.ifeng.news2.activity.SplashActivity;
import com.ifeng.news2.activity.SubscriptionActivity;
import com.ifeng.news2.activity.WeatherActivity;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.plutus.android.PlutusAndroidManager;
import com.ifeng.news2.plutus.core.Constants;
import com.ifeng.news2.receiver.ScreenOffReceiver;
import com.ifeng.news2.util.AlarmSplashServiceManager;
import com.ifeng.news2.util.CheckNPCAndCPPCCUtil;
import com.ifeng.news2.util.CheckNPCAndCPPCCUtil.NPCAndCPPCCCheckCallback;
import com.ifeng.news2.util.ConfigManager;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.PhotoModeUtil;
import com.ifeng.news2.util.RestartManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticRecordAction;
import com.ifeng.news2.util.UpgradeProxy;
import com.ifeng.news2.widget.ChannelMenu;
import com.ifeng.news2.widget.ChannelMenu.OnChannelItemSelectedListener;
import com.ifeng.news2.widget.NewsMasterViewPager;
import com.ifeng.news2.widget.SlidingCenterView.OnScrolledListener;
import com.ifeng.news2.widget.SlidingMenu;
import com.ifeng.news2.widget.SlidingMenu.SlidingMenuAdapter;
import com.qad.app.BaseBroadcastReceiver;
import com.qad.app.BaseFragmentActivity;


public class NewsMasterFragmentActivity extends BaseFragmentActivity implements
		OnChannelItemSelectedListener {

	public static boolean isMargin = false;
	public static boolean isStatisticRecordTriggeredByOperation = false ;//是否由于点击item、下拉、上拉等操作触发保存过统计数据
	public static final String REF_CHANNEL = "refChannel" ; //统计字段，统计来自哪个频道
	private long startTime = 0;
	
	private int currentItem = 0;
	//记录开始时间
	private long recordEndTime = 0 ;
	//记录结束时间
	private long recordStartTime = 0 ;
	//前一个Fragment的position
	private static String preStatistic = "" ; 
	private BaseBroadcastReceiver screenOffReceiver;
	private static NewsMasterViewPager pager;
	private ChannelMenu menu;
	private static IfengFragmentStatePagerAdapter adapter;
	private boolean needScoll = false;
	private HashSet<String> channelFirstLoadFlags = new HashSet<String>();
	boolean firstRun = false;
	public static boolean isGoToSubscription;
	private boolean isUpdateLH = false;

	/**
	 * 标识应用是否运行，以便收到push消失时判断是否启动应用
	 */
	public static boolean isAppRunning = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Intent intent = getIntent();
		Uri uri = intent.getData();
		Config.SUBSCRIPTIONS.filterChannel();
        Config.SCREEN_WIDTH =  DeviceUtils.getWindowWidth(this);
		//正常打开客户端uri为空，在分享打开客户端时添加启动模式，防止打开客户端后启动多个NewsMasterFragmentActivity
		if(uri!=null&&(Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT|Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_CLEAR_TOP) != intent.getFlags()){
			intent.setFlags(Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT|Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(intent);
			finish();
		}else if(uri!=null&&(Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT|Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_CLEAR_TOP) == intent.getFlags()){
			needScoll = true;
			IfengNewsApp.shouldRestart = false;
		}
		super.onCreate(savedInstanceState);
		isAppRunning = true;
		
		// 预载焦点图广告
        StringBuilder adPositions = new StringBuilder();
        for (Channel ch : Config.CHANNELS) {
        	if (!TextUtils.isEmpty(ch.getAdSite())) {
        		adPositions.append(ch.getAdSite()).append(",");
        	}
        }
        HashMap<String, String> map2 = new HashMap<String, String>();
        map2.put(Constants.SELECT, Constants.SELE_ADPOSITIONS);
        map2.put(Constants.KEY_POSITION, adPositions.deleteCharAt(adPositions.length() - 1).toString());
        // 只是预载，不需要处理成功或失败消息，所以传入null作为listener
        PlutusAndroidManager.qureyAsync(map2, null);  
		
		setContentView(R.layout.slide_menu);
		mainView = LayoutInflater.from(this).inflate(R.layout.channel_main, null);
		leftView = LayoutInflater.from(this).inflate(R.layout.more, null);
		pager = (NewsMasterViewPager) mainView.findViewById(R.id.viewpager);
		pager.setOffscreenPageLimit(1);
		menu = (ChannelMenu) mainView.findViewById(R.id.channel_menu);
		mSlidingMenu = (SlidingMenu) findViewById(R.id.slidingMenu);
		mSlidingMenu.setAdapter(new SlidingMenuAdapter() {

			@Override
			public View getLeftView() {
				return leftView;
			}

			@Override
			public View getCenterView() {
				return mainView;
			}

			@Override
			public Drawable getShadowDrawable() {				
				return getResources().getDrawable(R.drawable.setting_left_shadow);
			}

			@Override
			public OnScrolledListener getOnScrolledListener() {
				return new OnScrolledListener() {
					
					@Override
					public void onViewSelected(int direction) {
						switch (direction) {
						case LEFT:
							ConstantManager.isSettingsShow = true ; 
							getSettingFragment().startSettingBtnAnim();
							if(TextUtils.isEmpty(preStatistic)){
								addRecord("ys"+"$ref="+Config.CHANNELS[0].getStatistic(), StatisticUtil.StatisticPageType.set);
							}else{
								addRecord("ys"+"$ref="+preStatistic, StatisticUtil.StatisticPageType.set);
							}
							
							break;
						case RIGHT:
							ConstantManager.isSettingsShow = false ; 
							if(TextUtils.isEmpty(preStatistic)){
								addRecord(Config.CHANNELS[0].getStatistic()+"$ref=ys",StatisticUtil.StatisticPageType.ch);
							}else{
								addRecord(preStatistic+"$ref=ys",StatisticUtil.StatisticPageType.ch);
							}
							
							break;
						default:
							break;
						}
					}
				};
			}
		});
		
		FragmentTransaction t = getSupportFragmentManager().beginTransaction();
		rightSideBarFragment = new SettingFragment();
		t.replace(R.id.rightside_frame, rightSideBarFragment);
		t.commit();
//		initFragmens();
		initSettingButton();
		initBroadcast();
		/*
		 * FragmentStatePagerAdapter 和前面的 FragmentPagerAdapter 一样，是继承子 PagerAdapter。
		 * 但是，和 FragmentPagerAdapter 不一样的是，正如其类名中的 'State' 所表明的含义一样，
		 * 该 PagerAdapter 的实现将只保留当前页面，当页面离开视线后，就会被消除，释放其资源；
		 * 而在页面需要显示时，生成新的页面(就像 ListView 的实现一样)。
		 * 这么实现的好处就是当拥有大量的页面时，不必在内存中占用大量的内存。
		 */
//		adapter = new IfengPagerAdapter(getSupportFragmentManager(), fragments);
		adapter = new IfengFragmentStatePagerAdapter(getSupportFragmentManager());
		pager.setAdapter(adapter);
		menu.setOnChannelItemSelectedListener(this);
		pager.setOnPageChangeListener(new OnPageChangeListener() {
			@Override
			public void onPageSelected(int position) {
				currentItem = position;
				if(!isGoToSubscription){
					if(position == 0) {
						NewsMasterViewPager.isLeftMargin = true;
					} else {
						NewsMasterViewPager.isLeftMargin = false;
					}					
					menu.moveToDest(position);
					adapter.onPageChanged(position);
					recordEndTime = System.currentTimeMillis();
					
					if(recordEndTime - recordStartTime >= 3000 && !isStatisticRecordTriggeredByOperation ){
						if(!preStatistic.equals(Config.CHANNELS[position].getStatistic())){
							if(TextUtils.isEmpty(preStatistic)){
								addRecord(Config.CHANNELS[0].getStatistic(),StatisticUtil.StatisticPageType.ch);
							}else{
								addRecord(preStatistic,StatisticUtil.StatisticPageType.ch);
							}
						}
					}
					
					preStatistic = Config.CHANNELS[position].getStatistic() ;
					//将点击后发送统计的flag重置
					recordStartTime = System.currentTimeMillis();
					isStatisticRecordTriggeredByOperation = false;
				}
			}

			@Override
			public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
				
			}

			@Override
			public void onPageScrollStateChanged(int state) {
//				if (arg0 == 0) {
//					preLoaded();
//				}
			}

			
		});
		

		/*
		 * @gm, this is to set displayWidth of Settings of BeanLoader, to
		 * estimate memory cache threshold
		 */
		DisplayMetrics display = ((IfengNewsApp) getApplication())
				.getDisplay(this);
		IfengNewsApp.getBeanLoader().getSettings()
				.setDisplayWidth(display.widthPixels);
		/* @gm, end */

		//头条频道会在page 1加载完成后自动刷新，这里标志其已经刷新过
		channelFirstLoadFlags.add(Config.CHANNELS[0].getStatistic());
		// if (PhoneManager.getInstance(this).isConnectedWifi()
		// && Config.ENALBE_PREFETCH) {
		// Handler handler = new Handler();
		// handler.postDelayed(new Runnable() {
		// @Override
		// public void run() {
		// doOfflineWork(false);
		// }
		// }, Config.START_OFFINE_TIME);
		// }
		if (!SplashActivity.isSplashActivityCalled) {
			// 当应用在后台被杀死后，用户尝试将应用带到前台时会走入这个分支，这时需要加入启动IN统计
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
		
		//监测升级
		checkUpgrade();
								
		//检查2G/3G无图模式
		PhotoModeUtil.checkNoPhotoMode(this);
		
		//检查两会频道开关，并且更新头部导航栏
		if(Config.isCheckNPCAndCPPCC) {
			checkNPCAndCPPC();
		}		
	}
	
	private void checkNPCAndCPPC() {
		CheckNPCAndCPPCCUtil.checkNPCAndCPPCCChannel(me, new NPCAndCPPCCCheckCallback() {
			
			@Override
			public void switchOpen() {
				//当前频道中没有两会频道
				
				if(!Config.SUBSCRIPTIONS.getChannels().containsKey("两會")) {
					Config.SUBSCRIPTIONS.getChannels().put("两會", CheckNPCAndCPPCCUtil.NPCAndCPPCCChannel);
					Config.SUBSCRIPTIONS.getDefaultOrderMenuItems().add(1, "两會");
					isUpdateLH = true;					
					notifyChannelChange();
				}
			}
			
			@Override
			public void switchClose() {
				//当前频道中包含两会频道
				if(Config.SUBSCRIPTIONS.getChannels().containsKey("两會")) {
					Config.SUBSCRIPTIONS.getChannels().remove("两會");
					Config.SUBSCRIPTIONS.getDefaultOrderMenuItems().remove("两會");
					isUpdateLH = true;					
					notifyChannelChange();
				}				
			}
		});
	}

	public void showLeftView(){		
		if(mSlidingMenu.isShowLeftView()) {
			mSlidingMenu.showLeftView();
			pager.setCurrentItem(currentItem);			
		} else {
			mSlidingMenu.showLeftView();
		}		
	}
	
	public SettingFragment getSettingFragment() {
		return rightSideBarFragment;
	}

	public void gotoWeather() {
		Intent weatherIntent = new Intent(NewsMasterFragmentActivity.this,
				WeatherActivity.class);
		startActivity(weatherIntent);
	}

	@Override
	public boolean dispatchKeyEvent(KeyEvent event) {
		if (firstRun) {
			firstRun = false;
			mainView.findViewById(R.id.tips_list).setVisibility(View.GONE);
			return true;
		}
		if (event.getKeyCode() == KeyEvent.KEYCODE_BACK
				&& event.getAction() != KeyEvent.ACTION_UP) {
			if (mSlidingMenu.isShowLeftView()) {
				mSlidingMenu.showLeftView();
				pager.setCurrentItem(currentItem);
				return true;
			} else {
				exit();
				return false;
			}			
		}
		if (event.getKeyCode() == KeyEvent.KEYCODE_MENU) {			
			showLeftView();
			return true;
		}		
		return super.dispatchKeyEvent(event);
	}
	
	@Override
	public boolean dispatchTouchEvent(MotionEvent ev) {
		if (firstRun) {
			firstRun = false;
			mainView.findViewById(R.id.tips_list).setVisibility(View.GONE);
			return true;
		}
		try {
			return super.dispatchTouchEvent(ev);
		} catch (Exception e) {
			return false;
		}
	}

	@Override
	protected void onForegroundRunning() {
		super.onForegroundRunning();
//		Log.e("Sdebug", "NewsMaster onForegroundRunning called");
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
			} else if (AppBaseActivity.startSource == ConstantManager.IN_FROM_WIDGET) {
				startSourceString = "desktop";
			}
			if (StatisticUtil.isValidStart(this)) {
				StatisticUtil.addRecord(this, StatisticUtil.StatisticRecordAction.in, "type="+startSourceString);
			}
			AppBaseActivity.startSource = ConstantManager.IN_FROM_APP; // 复原来源设置
			
			// 超时刷新列表
			if (!mSlidingMenu.isShowLeftView())
				adapter.onPageChanged(currentItem);
			
		}
//		StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.START,
//				new SimpleDateFormat("yyyy-MM-dd hh:mm").format(new Date()));
		IfengNewsApp.shouldRestart = true;
//		try {
//			dispatchPullDownRefresh(getCurrentNavigateFragment());
//		} catch (Exception e) {
//		}
		// 记录进入应用的时间，用于使用时长统计
		if (IfengNewsApp.isEndStatisticSent) {
			PreferenceManager.getDefaultSharedPreferences(this).edit().putLong("entryTime", System.currentTimeMillis()).commit();
			IfengNewsApp.isEndStatisticSent = false;
		}
	}

	@Override
	protected void onBackgroundRunning() {
//		Log.e("Sdebug", "NewsMaster onBackgroundRunning called");
		super.onBackgroundRunning();
		startTime = System.currentTimeMillis();
		long currentTime = System.currentTimeMillis();
		long entryTime = PreferenceManager.getDefaultSharedPreferences(this).getLong("entryTime", 0);
		StatisticUtil.addRecord(this, StatisticRecordAction.end, "odur=" + (currentTime - entryTime)/1000);
		IfengNewsApp.isEndStatisticSent = true;
		
		// 更新列表页访问时间，以满足刷新策略要求， bug fix #17994 【刷新】列表在后台没有超过10分钟刷新了。
		Channel currentChannel = Config.CHANNELS[currentItem];
		String channelName = currentChannel.getChannelName();
		if (getString(R.string.photo_program).equals(channelName)) {
			IfengNewsApp.getMixedCacheManager().updateSavedItemTime(Config.GALLERY_COLUMN_URL);
		}else {
//			Log.i("Sdebug", "update time for link: " + ParamsManager.addParams(this,
//					currentChannel.getChannelSmallUrl() + "&page=1"));
			IfengNewsApp.getMixedCacheManager().updateSavedItemTime(ParamsManager.addParams(this,
					currentChannel.getChannelSmallUrl() + "&page=1"));
		}
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		// 判断停留时间是否超过3秒，记录频道首页统计
		recordEndTime = System.currentTimeMillis();
	    if(!isStatisticRecordTriggeredByOperation){
	    	if(recordEndTime - recordStartTime >= 3000){
				addRecord(Config.CHANNELS[pager.getCurrentItem()].getStatistic(),StatisticUtil.StatisticPageType.ch);
	    	}
	    }
	}

	@Override
	protected void onResume() {
		super.onResume();
		/**
		 * 1.pager.setCurrentItem()方法在Oncreat()中调用的时候，channelmenu没有初始化视图，channelmenu的scoll效果无效，需要延时;
		 * 2。分享进入应用不应该重启应用
		 */
		if(needScoll){
			needScoll = false;
			Uri uri = getIntent().getData();
			if("list".equals(uri.getHost())&&"origin".equals(uri.getLastPathSegment())){
				for(int i=0; i<Config.CHANNELS.length; i++){
					if("exclusive".equals(Config.CHANNELS[i].getStatistic())){
						final int position = i;
						new Handler(getMainLooper()).postDelayed(new Runnable() {
							@Override
							public void run() {
							if(pager!=null)
								pager.setCurrentItem(position,true);
							}
						}, Config.FAKE_PULL_TIME);
						break;
					}
				}
			}
		}
		RestartManager.checkRestart(this, startTime, RestartManager.LOCK);
		recordStartTime = System.currentTimeMillis();
		if (IfengNewsApp.backFromPushOrWidget) {
			IfengNewsApp.backFromPushOrWidget = false;
			// 超时刷新列表
			if (!mSlidingMenu.isShowLeftView())
				adapter.onPageChanged(currentItem);
			
		}
//		stopRefresh();
	}
	
	public void onPageLoadComplete() {
		//检查是否显示引导页
		SharedPreferences pref = this.getSharedPreferences("FirstLogin", Context.MODE_PRIVATE);
		if (!pref.contains(Config.CURRENT_CONFIG_VERSION)
				|| (pref.getInt(Config.CURRENT_CONFIG_VERSION, 0) & 0x1) != 0x1) {
			this.getSharedPreferences("FirstLogin", Context.MODE_PRIVATE)
			.edit().putInt(Config.CURRENT_CONFIG_VERSION, pref.getInt(Config.CURRENT_CONFIG_VERSION, 0) | 0x1).commit(); 
			// 0x1: 列表, 0x2: 正文页
			firstRun = true;
			mainView.findViewById(R.id.tips_list).setVisibility(View.VISIBLE);
		}
	}

	/**
	 * 初始化广播，注册广播，在activity的onCreate方法中调用
	 */
	// TODO
	private void initBroadcast() {
		screenOffReceiver = new ScreenOffReceiver();
		registerManagedReceiver(screenOffReceiver);
//		PhoneManager.getInstance(this).registerSystemReceiver();
//		PhoneManager.getInstance(this).addOnNetWorkChangeListener(
//				ApnManager.getInstance(this));
	}

	/**
	 * 取消广播注册，在activity的onDestroy方法中调用
	 */
//	private void recycleBroadcast() {
//		PhoneManager.getInstance(this).destroy();
//	}

	@Override
	protected void onDestroy() {
//		MBoxAgent.destroy();
//		recycleBroadcast();
		super.onDestroy();
	}

	public void checkUpgrade() {
		UpgradeProxy.createAutoUpgradeProxy().checkUpgrade(
				NewsMasterFragmentActivity.this);
	}

	private boolean isExit = false;

	private void exit() {
		if (!isExit) {
			isExit = true;
			showMessage("再按一次退出凤凰新闻");
			mHandler.sendEmptyMessageDelayed(0, 2000);
		} else {
			quitApp();
		}
	}

	@SuppressLint("HandlerLeak")
	private Handler mHandler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			super.handleMessage(msg);
			isExit = false;
		}
	};
	private View mainView;
	private View leftView;
	private SlidingMenu mSlidingMenu;
	private SettingFragment rightSideBarFragment;

	private void quitApp() {
//		StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.CLOSE,
//				new SimpleDateFormat("yyyy-MM-dd hh:mm").format(new Date()));
//		IfengNewsApp.getResourceCacheManager().clearMemCache();
//		if (loader != null) {
//			loader.stopOffineTask();
//		}
		AlarmSplashServiceManager.stopAlarm(NewsMasterFragmentActivity.this);
		exitApp();
	}
	
	@Override
	public void exitApp() {
	    isAppRunning = false;
	    super.exitApp();	    
	    finish();
	}

	private void initSettingButton() {
		//跳转到设置页
		mainView.findViewById(R.id.nav_settings_bt).setOnClickListener(
				new OnClickListener() {
					@Override
					public void onClick(View v) {
						showLeftView();
					}
				});	
		//跳转到频道订阅页
		mainView.findViewById(R.id.subscribe).setOnClickListener(new OnClickListener() {
			

			@Override
			public void onClick(View v) {
				isGoToSubscription = true;
				Intent intent = new Intent(me, SubscriptionActivity.class);
				//for 统计
				if(TextUtils.isEmpty(preStatistic)){
					intent.putExtra(REF_CHANNEL, Config.CHANNELS[0].getStatistic());
				}else{
					intent.putExtra(REF_CHANNEL, preStatistic);
				}
				startActivityForResult(intent, 200);
				overridePendingTransition(R.anim.slide_down, R.anim.slide_up_in);
			}
		});
	}

//	private void initFragmens() {
//		for (Channel channel : Config.CHANNELS) {
//			Fragment fragment = null;
//			if (channel.getChannelName().equals("頭條")) {
//				// Statistics.addRecord(Statistics.RECORD_CHANNEL,
//				// Config.CHANNELS[0].getStatistic());
//				fragment = Fragment.instantiate(this,
//						HeadChannelFragment.class.getName());
//			} else if (channel.getChannelName().equals("图片")) {
//				fragment = Fragment.instantiate(this,
//						GalleryFragment.class.getName());
//			} else {
//				Bundle bundle = new Bundle();
//				bundle.putParcelable(ChannelFragment.EXTRA_CHANNEL, channel);
//				fragment = Fragment.instantiate(this,
//						ChannelFragment.class.getName(), bundle);
//			}
//			fragments.add(fragment);
//		}
//	}

	@SuppressWarnings("rawtypes")
	public void dispatchPullDownRefresh(Fragment fragment, int position) {
		boolean ignoreExpired = false;
		if (!channelFirstLoadFlags.contains(Config.CHANNELS[position].getStatistic())) {
			channelFirstLoadFlags.add(Config.CHANNELS[position].getStatistic());
			ignoreExpired = true;
		}
		if (fragment == null)
			return;
		if (fragment instanceof IfengListLoadableFragment) {
			((IfengListLoadableFragment) fragment).pullDownRefresh(ignoreExpired);
		} else if (fragment instanceof IfengLoadableFragment) {
			((IfengLoadableFragment) fragment).pullDownRefresh(ignoreExpired);
		}
	}
	
	
	private class IfengFragmentStatePagerAdapter extends FragmentStatePagerAdapter {
		

	    private FragmentTransaction mCurTransaction = null;
	    private ArrayList<Fragment.SavedState> mSavedState = new ArrayList<Fragment.SavedState>();
	    private ArrayList<Fragment> mFragments = new ArrayList<Fragment>();
		
		private final FragmentManager mfm;
		public IfengFragmentStatePagerAdapter(FragmentManager fm) {
			super(fm);
			mfm = fm;
		}
		@SuppressLint("Recycle")
		@Override
		public Fragment getItem(int position) {
			String channelName = Config.CHANNELS[position].getChannelName();
			Fragment fragment = null;
			Bundle bundle = new Bundle();
			bundle.putParcelable(EXTRA_CHANNEL, Config.CHANNELS[position]);
			if (getString(R.string.photo_program).equals(channelName)) {
				fragment = Fragment.instantiate(NewsMasterFragmentActivity.this,
						GalleryFragment.class.getName(),bundle);
			} 
			else if(getString(R.string.ifeng_program).equals(channelName)){
				fragment = Fragment.instantiate(NewsMasterFragmentActivity.this,
						VideoChannelFragment.class.getName(),bundle);
			} else {			
				fragment = Fragment.instantiate(NewsMasterFragmentActivity.this,
						HeadChannelFragment.class.getName(), bundle);
			}
			mfm.beginTransaction().add(fragment, channelName);
			return fragment;
		}
		
		@Override
	    public Object instantiateItem(ViewGroup container, int position) {
	        if (mFragments.size() > position) {
	            Fragment f = mFragments.get(position);
	            if (f != null) {
	                return f;
	            }
	        }
	        if (mCurTransaction == null) {
	            mCurTransaction = mfm.beginTransaction();
	        }
	        Fragment fragment = getItem(position);
	        if (mSavedState.size() > position) {
	            Fragment.SavedState fss = mSavedState.get(position);
	            if (fss != null) {
	                fragment.setInitialSavedState(fss);
	            }
	        }
	        while (mFragments.size() <= position) {
	            mFragments.add(null);
	        }
	        mFragments.set(position, fragment);
	        mCurTransaction.add(container.getId(), fragment);
	        return fragment;
	    }

	    @Override
	    public void destroyItem(ViewGroup container, int position, Object object) {
	        Fragment fragment = (Fragment)object;

	        if (mCurTransaction == null) {
	            mCurTransaction = mfm.beginTransaction();
	        }
	        while (mSavedState.size() <= position) {
	            mSavedState.add(null);
	        }
	        try {
	        	  mSavedState.set(position, mfm.saveFragmentInstanceState(fragment));
			} catch (Exception e) {
				mSavedState.set(position, null);
			}
	        while (mFragments.size() <= position) {
	        	mFragments.add(null);
	        }
	        mFragments.set(position, null);
	        mCurTransaction.remove(fragment);
	    }
	    
	    @Override
	    public void finishUpdate(ViewGroup container) {
	        if (mCurTransaction != null) {
	            mCurTransaction.commitAllowingStateLoss();
	            mCurTransaction = null;
	            mfm.executePendingTransactions();
	        }
	    }

	    @Override
	    public void setPrimaryItem(ViewGroup container, int position, Object object) {
	    }

		@Override
		public int getCount() {
			return Config.CHANNELS.length;
		}
		
		public void onPageChanged(int position) {
			String channelName = Config.CHANNELS[position].getChannelName();
			Fragment frgm = mfm.findFragmentByTag(channelName);
			dispatchPullDownRefresh(frgm, position);
		}
		
		@Override
		public int getItemPosition(Object object) {
			int index = mFragments.indexOf(object);
			if(index!=-1 && index<Config.CHANNELS.length ){
				if(Config.CHANNELS[index].getChannelName().equals(((Fragment)object).getTag())){
					return PagerAdapter.POSITION_UNCHANGED;
				}
			}
			return PagerAdapter.POSITION_NONE;
		}
		
	    @Override
	    public Parcelable saveState() {
	        Bundle state = null;
	        if (mSavedState.size() > 0) {
	            state = new Bundle();
	            Fragment.SavedState[] fss = new Fragment.SavedState[mSavedState.size()];
	            mSavedState.toArray(fss);
	            state.putParcelableArray("states", fss);
	        }
	        for (int i=0; i<mFragments.size(); i++) {
	            Fragment f = mFragments.get(i);
	            if (f != null) {
	                if (state == null) {
	                    state = new Bundle();
	                }
	                String key = "f" + i;
	                try {
	                	mfm.putFragment(state, key, f);
					} catch (Exception e) {
					} 
	            }
	        }
	        return state;
	    }

	    @Override
	    public void restoreState(Parcelable state, ClassLoader loader) {
	    	Log.d("sTag", isGoToSubscription+"");
	        if (!isGoToSubscription&&state != null) {
	            Bundle bundle = (Bundle)state;
	            bundle.setClassLoader(loader);
	            Parcelable[] fss = bundle.getParcelableArray("states");
	            mSavedState.clear();
	            mFragments.clear();
	            if (fss != null) {
	                for (int i=0; i<fss.length; i++) {
	                    mSavedState.add((Fragment.SavedState)fss[i]);
	                }
	            }
	            Iterable<String> keys = bundle.keySet();
	            for (String key: keys) {
	                if (key.startsWith("f")) {
	                    int index = Integer.parseInt(key.substring(1));
	                    Fragment f = mfm.getFragment(bundle, key);
	                    if (f != null) {
	                        while (mFragments.size() <= index) {
	                            mFragments.add(null);
	                        }
//	                        FragmentCompat.setMenuVisibility(f, false);
	                        mFragments.set(index, f);
	                    } else {
	                        Log.d("SDebug", "Bad fragment at key " + key);
	                    }
	                }
	            }
	        }
	        isGoToSubscription = false;
	    }
		
	}

	@Override
	public void onChannelItemClicked(View view, Channel channel, int position) {
		//获取前一个position
		if(channel!=null){
			preStatistic = channel.getStatistic();
		}else{
			preStatistic = Config.CHANNELS[pager.getCurrentItem()].getStatistic();
		}
		recordEndTime = System.currentTimeMillis();
		if(recordEndTime - recordStartTime >= 3000 && 
				TextUtils.isEmpty(preStatistic) && !isStatisticRecordTriggeredByOperation){
			addRecord(preStatistic,StatisticUtil.StatisticPageType.ch);
		}
		if(pager!=null){
			pager.setCurrentItem(position, false);
		}
		recordStartTime = System.currentTimeMillis();
	}

	/**aa
	 * 发送频道统计
	 * @param position
	 */
	private void addRecord(String statistic,Enum type){
//		StatisticUtil.addRecord(me, StatisticUtil.CHANNEL, Config.CHANNELS[position].getStatistic());
		StatisticUtil.addRecord(this
				, StatisticUtil.StatisticRecordAction.page
				, "id="+statistic+"$type=" + type);
		recordStartTime = System.currentTimeMillis();
	}
	
	private void notifyChannelChange() {
//		Config.CHANNELS = Config.SUBSCRIPTIONS.getchangedChannels();
		boolean dataChanged = false;
		Channel[] tempChannels = Config.SUBSCRIPTIONS.getchangedChannels();
		if(Config.CHANNELS.length == tempChannels.length){
			for(int i=0;i<Config.CHANNELS.length;i++){
				if(!Config.CHANNELS[i].getChannelName().equals(tempChannels[i].getChannelName())){
					dataChanged = true;
					break;
				}
			}
		}else{
			dataChanged = true;
		}
		if(dataChanged){
			Config.CHANNELS = Config.SUBSCRIPTIONS.getchangedChannels();
			adapter.notifyDataSetChanged();
			isStatisticRecordTriggeredByOperation = true;
			boolean channelExist = false;
			menu.invalidateViews(pager.getCurrentItem());
			for(int i=0; i<Config.CHANNELS.length; i++){
				if(Config.CHANNELS[i].getStatistic().equals(preStatistic)){
					channelExist = true;
					pager.setCurrentItem(i, false);
					break;
				}
			}
			if(!channelExist){
				isGoToSubscription = false;
				pager.setCurrentItem(0, false);
			}
			menu.moveToDestFast(pager.getCurrentItem());
			ConfigManager.saveChannelConfig(me, Config.SUBSCRIPTIONS);
		} 
		//如果两会频道没有订阅，但是两会频道已经下线的情况下，需要保存设置
		else if(isUpdateLH) {
			ConfigManager.saveChannelConfig(me, Config.SUBSCRIPTIONS);
			isUpdateLH = false;
		}
		isGoToSubscription = false;
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent arg2) {
		super.onActivityResult(requestCode, resultCode, arg2);
		if(resultCode == 200){
			notifyChannelChange();
		}
	}
	
}