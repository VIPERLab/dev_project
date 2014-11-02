package com.ifeng.news2.activity;

import android.os.Bundle;
import android.preference.PreferenceManager;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.db.CollectionDBManager;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.RestartManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticRecordAction;
import com.ifeng.news2.util.WindowPrompt;
import com.qad.app.BaseFragmentActivity;
import com.umeng.analytics.MobclickAgent;

public class AppBaseActivity extends BaseFragmentActivity {

	/*
	 * 打开文章的来源，默认是app，可能的来源还有推送和分享。用于统计中启动IN的来源
	 */
	public static int startSource = ConstantManager.IN_FROM_APP; 
	private long startTime = 0;
	public CollectionDBManager collectionDBManager;
	protected WindowPrompt windowPrompt;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		collectionDBManager = new CollectionDBManager(this);
		windowPrompt = WindowPrompt.getInstance(this);
		startSource = ConstantManager.IN_FROM_APP; // 初始化赋值为默认App，在DetailActivity和SlideActivity中根据情况赋不同的值
	}

	@Override
	protected void onPause() {
		super.onPause();
		if (Config.ADD_UMENG_STAT) {
			MobclickAgent.onPause(this);
		}
	}

	@Override
	protected void onForegroundRunning() {
//		Log.e("Sdebug", "AppBaseActivity onForegroundRunning called");
		super.onForegroundRunning();
		boolean res = RestartManager.checkRestart(this, startTime, RestartManager.HOME);
		IfengNewsApp.shouldRestart = true;
		if (!res) { // 需要重启应用时不再统计应用从后台到前台的这次启动
			/*
			 * 需要判断将应用带到前台的来源，可能是：推送、分享和用户点击应用。目前推送只能推文章、分享只能分享文章和幻灯，未来若增加别的类型需要增加相应处理
			 */
			String startSourceString = "direct";
			if (startSource == ConstantManager.IN_FROM_OUTSIDE) {
				startSourceString = "outside";
			} else if (startSource == ConstantManager.IN_FROM_PUSH) {
				startSourceString = "push";
			} else if (startSource == ConstantManager.IN_FROM_WIDGET) {
				startSourceString = "desktop";
			}
			startSource = ConstantManager.IN_FROM_APP; // 复原来源设置
			// fix bug #18026 【统计】在应用内打开推送也会发送一个in统计信息
			if (StatisticUtil.isValidStart(this)  && IfengNewsApp.isEndStatisticSent) {
				StatisticUtil.addRecord(this, StatisticRecordAction.in, "type="+startSourceString);
			}
		}
		// 记录进入应用的时间，用于使用时长统计
		if (IfengNewsApp.isEndStatisticSent) {
			PreferenceManager.getDefaultSharedPreferences(this).edit().putLong("entryTime", System.currentTimeMillis()).commit();
			IfengNewsApp.isEndStatisticSent = false;
		}
//		StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.START,
//				new SimpleDateFormat("yyyy-MM-dd hh:mm").format(new Date()));
	}

	@Override
	protected void onBackgroundRunning() {
//		Log.e("Sdebug", "AppBaseActivity onBackgroundRunning called");
		super.onBackgroundRunning();
		startTime = System.currentTimeMillis();
		long currentTime = System.currentTimeMillis();
		long entryTime = PreferenceManager.getDefaultSharedPreferences(this).getLong("entryTime", 0);
		StatisticUtil.addRecord(this, StatisticRecordAction.end, "odur=" + (currentTime - entryTime)/1000);
		IfengNewsApp.isEndStatisticSent = true;
	}

	@Override
	protected void onResume() {
		RestartManager.checkRestart(this, startTime, RestartManager.LOCK);
		super.onResume();
		if (Config.ADD_UMENG_STAT) {
			MobclickAgent.onResume(this);
		}
		if(StatisticUtil.isBack){
			StatisticUtil.addRecord(this
					, StatisticUtil.StatisticRecordAction.page
					, "id="+StatisticUtil.doc_id+"$ref=back"+"$type=" + StatisticUtil.type);
			StatisticUtil.isBack = false;
		}
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
	}
}
