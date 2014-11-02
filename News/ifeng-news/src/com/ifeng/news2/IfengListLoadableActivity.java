package com.ifeng.news2;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.preference.PreferenceManager;
import android.text.TextUtils;

import com.ifeng.news2.activity.AppBaseActivity;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.RestartManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.StatisticUtil.StatisticRecordAction;
import com.ifeng.news2.util.WindowPrompt;
import com.qad.form.PageEntity;
import com.qad.loader.BeanLoader;
import com.qad.loader.ListLoadableActivity;
import com.qad.loader.LoadContext;
import com.qad.loader.StateAble;
import com.qad.system.PhoneManager;
import com.qad.util.WToast;
import com.umeng.analytics.MobclickAgent;

@SuppressWarnings("unchecked")
public abstract class IfengListLoadableActivity<T extends PageEntity> extends ListLoadableActivity<T> {
	
	private long startTime = 0;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);		
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
			} else if (AppBaseActivity.startSource == ConstantManager.IN_FROM_WIDGET) {
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
	protected void onPause() {
		super.onPause();
		if (Config.ADD_UMENG_STAT) {
			MobclickAgent.onPause(this);
		}
	}

	@Override
	public StateAble getStateAble() {
		return null;
	}

	@Override
	public BeanLoader getLoader() {
		return IfengNewsApp.getBeanLoader();
	}
	
	@Override
	public void loadFail(LoadContext<?, ?, T> context) {
		super.loadFail(context);
		
		WindowPrompt.getInstance(this).showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
	}
	
	protected void filterDuplicates(ArrayList<ListItem> resultItems, ArrayList<ListItem> totalItems) {
		List<String> documentIds = new ArrayList<String>();
		for (ListItem item : totalItems)
			documentIds.add(item.getDocumentId());

		int i = 0;
		while (true) {
			if (i >= resultItems.size())
				break;
			if (TextUtils.isEmpty(resultItems.get(i).getDocumentId())||documentIds.contains(resultItems.get(i).getDocumentId()))
				resultItems.remove(i);
			else
				i++;
		}
	}
	
	protected void filerInvalidItems(List<ListItem> items) {
		Iterator<ListItem> iterator = items.iterator();
		while (iterator.hasNext()) {
			if (TextUtils.isEmpty(iterator.next().getTitle())) {
				iterator.remove();
			}
		}
	}
	
	//下拉刷新
	protected void pullDownRefresh(String url,final boolean ignoreExpired,final PullDownRefreshListener listener) {
		if (!PhoneManager.getInstance(this).isConnectedNetwork())
			return;
		String param = ParamsManager.addParams(this, url + "&page=1");
		if (!ignoreExpired
				&& !IfengNewsApp.getMixedCacheManager().isExpired(param)) {
			return;
		}
		Handler handler = new Handler(Looper.getMainLooper());
		handler.postDelayed(new Runnable() {

			@Override
			public void run() {
				listener.startRefresh();
			}
		}, ignoreExpired ? Config.AUTO_PULL_TIME : Config.AUTO_PULL_TIME);
	}
	
	public interface PullDownRefreshListener{
		void startRefresh();
	}
}
