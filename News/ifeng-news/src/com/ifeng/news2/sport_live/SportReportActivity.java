package com.ifeng.news2.sport_live;

import java.util.ArrayList;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.activity.AppBaseActivity;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.sport_live.entity.ReportBody;
import com.ifeng.news2.sport_live.entity.ReportInfo;
import com.ifeng.news2.util.ActivityStartManager;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.widget.IfengBottom;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;

/**
 * 体育直播战报页
 * 
 * @author SunQuan:
 * @version 创建时间：2013-7-25 下午2:58:06
 */

public class SportReportActivity extends AppBaseActivity implements
		LoadListener<ReportInfo>, OnItemClickListener {

	private ListView list;
	private ReportInfo reportInfo;
	private String url;
	private ArrayList<ReportBody> body = new ArrayList<ReportBody>();
	private ReportListAdapter adapter;
	private View loading;
	private View loadFail;
	private View emptyView;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.sport_live_report_page);
		url = getIntent().getStringExtra("URL");
		initView();
		loadData();
	}

	/**
	 * 获取数据
	 */
	private void loadData() {
		loadFail.setVisibility(View.GONE);
		loading.setVisibility(View.VISIBLE);
		String params = ParamsManager.addParams(url);
		IfengNewsApp.getBeanLoader().startLoading(
				new LoadContext<String, LoadListener<ReportInfo>, ReportInfo>(
						params, this, ReportInfo.class, Parsers
								.newReportInfoParser(),
						LoadContext.FLAG_HTTP_FIRST));
	}

	private void initView() {
		((IfengBottom) findViewById(R.id.ifeng_bottom)).onClickBack();
		list = (ListView) findViewById(R.id.report_list);
		list.setDividerHeight(0);
		adapter = new ReportListAdapter();
		adapter.setBody(body);
		list.setAdapter(adapter);
		list.setOnItemClickListener(this);
		emptyView = findViewById(R.id.empty);
		emptyView.setVisibility(View.GONE);
		loading = findViewById(R.id.loading);
		loadFail = findViewById(R.id.loading_fail);
		loadFail.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				loadData();
			}
		});
	}
	
	@Override
	public void onBackPressed() {	
		StatisticUtil.isBack = true ; 
		super.onBackPressed();
		overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
	}

	private class ReportListAdapter extends BaseAdapter {

		ArrayList<ReportBody> body;

		public void setBody(ArrayList<ReportBody> body) {
			this.body = body;
		}

		@Override
		public int getCount() {
			return body.size();
		}

		@Override
		public ReportBody getItem(int position) {
			return body.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			convertView = LayoutInflater.from(SportReportActivity.this)
					.inflate(R.layout.sport_live_report_list_item, null);
			((TextView) convertView.findViewById(R.id.report_item_info))
					.setText(getItem(position).getTitle());
			return convertView;
		}
	}

	@Override
	public void postExecut(LoadContext<?, ?, ReportInfo> context) {
	}

	@Override
	public void loadComplete(LoadContext<?, ?, ReportInfo> context) {
		loading.setVisibility(View.GONE);
		reportInfo = context.getResult();
		body = reportInfo.getBody();
		if (body != null && body.size() > 0) {
			adapter.setBody(body);
			adapter.notifyDataSetChanged();
		} else {
			//当没有数据的时候显示暂无内容视图
			emptyView.setVisibility(View.VISIBLE);
		}
	}
	
	@Override
	public void loadFail(LoadContext<?, ?, ReportInfo> context) {
		loading.setVisibility(View.GONE);
		loadFail.setVisibility(View.VISIBLE);
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		ReportBody body = adapter.getItem(position);
		if(body.getType().equals("slide")){
			Extension defaultExtension = new Extension();
			defaultExtension.setUrl(body.getUrl());
			defaultExtension.setType(body.getType());
			IntentUtil.startActivityByExtension(me, defaultExtension);
		}
		else if(body.getType().equals("doc")){
			ActivityStartManager
			.startDetailByAid(SportReportActivity.this, body.getUrl());
		}	
	}
	
}
