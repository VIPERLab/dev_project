package com.ifeng.news2.activity;

import com.ifeng.news2.R;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.widget.IfengBottom;
import com.ifeng.news2.widget.RelativeLayoutWithFlingDetector;
import com.ifeng.share.action.ShareAction;
import com.ifeng.share.action.ShareManager;
import com.ifeng.share.sina.WeiboHelper.BindListener;
import com.qad.util.OnFlingListener;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.CheckBox;

/**
 * 账号绑定页
 * 
 * @author SunQuan:
 * @version 创建时间：2013-11-19 上午11:28:31 类说明
 */

public class AccountBindActivity extends AppBaseActivity implements
		OnClickListener, OnFlingListener {

	private CheckBox switch_sina_bind;
	private CheckBox switch_tencent_bind;
	private CheckBox switch_qqzone_bind;
	private ShareAction shareAction;
	private IfengBottom bottom;
	private RelativeLayoutWithFlingDetector wrapper;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.account_bind);
		shareAction = new ShareAction(this);
		initView();
		beginStatistic();
	}
	private void beginStatistic() {
		// TODO Auto-generated method stub
		StatisticUtil.addRecord(this
				, StatisticUtil.StatisticRecordAction.page
				, "id=noid$ref=ys"+"$type=" + StatisticUtil.StatisticPageType.set);
	}

	/**
	 * 初始化视图以及一些状态信息
	 */
	private void initView() {
		wrapper = (RelativeLayoutWithFlingDetector) findViewById(R.id.account_bind_wrapper);
		wrapper.setOnFlingListener(this);
		bottom = (IfengBottom) findViewById(R.id.ifeng_bottom);
		bottom.getBackButton().setOnClickListener(this);
		switch_sina_bind = (CheckBox) findViewById(R.id.switch_sina_bind);
		switch_tencent_bind = (CheckBox) findViewById(R.id.switch_tencent_bind);
		switch_qqzone_bind = (CheckBox) findViewById(R.id.switch_qq_bind);

		switch_sina_bind.setOnClickListener(this);
		switch_tencent_bind.setOnClickListener(this);
		switch_qqzone_bind.setOnClickListener(this);

		initAccountState();

	}

	@Override
	public void onBackPressed() {
		StatisticUtil.isBack = true ; 
		finish();
		overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);
	}

	@Override
	protected void onResume() {
		super.onResume();
		initAccountState();
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		// 绑定新浪微博账号
		case R.id.switch_sina_bind:
			accountsOnClick(ShareManager.SINA, switch_sina_bind);
			break;
		// 绑定新浪微博账号
		case R.id.switch_tencent_bind:
			accountsOnClick(ShareManager.TENQT, switch_tencent_bind);
			break;
		// 绑定新浪微博账号
		case R.id.switch_qq_bind:
			accountsOnClick(ShareManager.TENQZ, switch_qqzone_bind);
			break;
		// 返回
		case R.id.back:
			onBackPressed();
			break;
		default:
			break;
		}
	}

	/**
	 * 初始化所有开关（绑定/未绑定）
	 */
	private void initAccountState() {
		setAccount(ShareManager.SINA, switch_sina_bind);
		setAccount(ShareManager.TENQT, switch_tencent_bind);
		setAccount(ShareManager.TENQZ, switch_qqzone_bind);
	}

	/**
	 * 开启/关闭绑定账号
	 * 
	 * @param accountType
	 * @param switcher
	 */
	private void accountsOnClick(String accountType, CheckBox switcher) {
		if (!switcher.isChecked()) {
			shareAction.unbind(accountType);
		} else {			
			shareAction.bind(accountType,new BindListener() {
				
				@Override
				public void success() {
					initAccountState();
				}
				
				@Override
				public void fail() {
					initAccountState();
				}
			});
		}
	}

	/**
	 * 设置绑定开关（开启/关闭）
	 * 
	 * @param accountType
	 * @param switcher
	 */
	private void setAccount(String accountType, CheckBox switcher) {
		if (shareAction.isAuthorize(accountType)) {
			switcher.setChecked(true);
		} else {
			switcher.setChecked(false);
		}
	}

	@Override
	public void onFling(int flingState) {
		if (flingState == FLING_RIGHT) {
			onBackPressed();
		}
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		shareAction.onAuthCallBack(ShareManager.SINA, requestCode, resultCode, data);
	}

}
