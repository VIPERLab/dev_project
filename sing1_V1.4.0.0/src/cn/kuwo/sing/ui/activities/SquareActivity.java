/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.ui.activities;

import android.content.res.Resources;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.view.ViewPager;
import android.util.TypedValue;
import android.widget.Toast;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.App;
import cn.kuwo.sing.controller.SquareController;
import cn.kuwo.sing.ui.adapter.SquarePagerAdapter;
import cn.kuwo.sing.util.DensityUtils;
import cn.kuwo.sing.widget.PagerSlidingTabStrip;

import com.umeng.analytics.MobclickAgent;

import de.greenrobot.event.EventBus;

/**
 * @Package cn.kuwo.sing.ui.activities
 *
 * @Date 2012-10-31, 下午5:17:56, 2012
 *
 * @Author Administrator
 *
 */
@SuppressWarnings("unused")
public class SquareActivity extends FragmentActivity {
	private final String TAG = "SquareActivity";
	private SquareController mSquareController;
	private boolean flag = true;
	private PagerSlidingTabStrip mTabs;
	private ViewPager mViewPager;
	private EventBus mEventBus;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		App mApp = (App) getApplication();
		mApp.init();
		mEventBus = EventBus.getDefault();
		mEventBus.register(this);
		
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.square_activity);
		
		initView();
		//mSquareController = new SquareController(this, ImageLoader.getInstance());
	}

	private void initView() {
		Resources rs = this.getResources();
		//Tab
		mTabs = (PagerSlidingTabStrip)this.findViewById(R.id.pagerSlidingTabStrip);
		mTabs.setShouldExpand(true);
		final int tabTextSize = DensityUtils.dip2px(this, 14.6f);
		mTabs.setTextSize(tabTextSize);
		mTabs.setTypeface(Typeface.SANS_SERIF, Typeface.BOLD);
		mTabs.setIndicatorColorResource(R.color.background_slidetab);
		
		//ViewPager
		mViewPager = (ViewPager)this.findViewById(R.id.viewPager);
		final int viewPagerMarginPixels = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, rs.getDimension(R.dimen.viewpager_margin), rs.getDisplayMetrics());
		mViewPager.setPageMargin(viewPagerMarginPixels);
		String[] titles = {"热门作品", "K歌达人", "最新作品"};
		final SquarePagerAdapter pagerAdapter = new SquarePagerAdapter(getSupportFragmentManager(), titles, mViewPager);
		mViewPager.setOffscreenPageLimit(1);
		//mViewPager.setTransitionEffect(TransitionEffect.Standard);
		mViewPager.setAdapter(pagerAdapter);
		mTabs.setViewPager(mViewPager);
	}

	@Override
	protected void onPause() {
		super.onPause();
		MobclickAgent.onPause(this);
	}

	@Override
	protected void onStop() {
		super.onStop();
	}

	@Override
	protected void onDestroy() {
		mEventBus.unregister(this);
		super.onDestroy();
	}
	
	protected void onEvent(String event) {
	   if(event.equals("cn.kuow.sing.exit.commandFromKwPlayer")) {
		   KuwoLog.d(getClass().getSimpleName(), "EventBus onEvent('cn.kuow.sing.exit.commandFromKwPlayer')");
		   this.finish();
	   }
	}
	
	@Override
	protected void onResume() {
		KuwoLog.i(TAG, "onResume");
		MobclickAgent.onResume(this);
		if(AppContext.getNetworkSensor().isApnActive()&&flag){
			Toast.makeText(this, "您当前使用的是2G/3G网络！", 0).show();
			flag = false;
		}
		super.onResume();
	}
	
	@Override
	public void onBackPressed() {
		mSquareController.clearDisplayedImages();
		super.onBackPressed();
	}
}
