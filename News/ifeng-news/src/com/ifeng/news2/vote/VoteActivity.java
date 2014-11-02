package com.ifeng.news2.vote;

import com.handmark.pulltorefresh.library.internal.IfengScrollView;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.activity.AppBaseActivity;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.RecordUtil;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.vote.VoteExecutor;
import com.ifeng.news2.vote.VoteExecutor.VoteListener;
import com.ifeng.news2.vote.VoteModuleBuilder.VoteItemClickListener;
import com.ifeng.news2.vote.VoteModuleBuilder;
import com.ifeng.news2.vote.entity.Data;
import com.ifeng.news2.vote.entity.VoteData;
import com.ifeng.news2.vote.entity.VoteItemInfo;
import com.ifeng.news2.widget.IfengBottomTitleTabbar;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.util.OnFlingListener;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import static com.ifeng.news2.vote.VoteModuleBuilder.SINGLE_PAGE_MODE;

/**
 * 投票单页
 * 
 * @author SunQuan:
 * @version 创建时间：2013-11-27 下午3:43:32 类说明
 */

public class VoteActivity extends AppBaseActivity implements OnFlingListener,
		LoadListener<VoteData>, VoteListener, VoteItemClickListener {

	private IfengScrollView voteDetail;
	private IfengBottomTitleTabbar ifengTabbar;
	private View loading;
	private View loadFail;
	private String param;
	private VoteModuleBuilder builder;
	private View voteContainer;
	private Data data;
	private String voteId;
	private VoteExecutor voteExecutor;
	private boolean isClick = false;
	private String preDocumentId = "";

	// 最高投票项
	private VoteItemInfo highestVoteItem;
	private String thumbnail;
	private Channel channel;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.vote_main);
		getIntentData();
		// 投票执行类
		voteExecutor = new VoteExecutor(VoteActivity.this);
		// 设置投票执行的监听
		voteExecutor.addVoteListener(this);
		// 投票模块构造器
		builder = VoteModuleBuilder.initialize(VoteActivity.this,SINGLE_PAGE_MODE);
		// 设置投票问题项点击事件的监听
		builder.setVoteItemClickListener(this);
		// 投票视图容器
		voteDetail = (IfengScrollView) findViewById(R.id.vote_detail);
		ifengTabbar = (IfengBottomTitleTabbar) findViewById(R.id.ifeng_bottom);
		loading = findViewById(R.id.loading);
		loadFail = findViewById(R.id.loading_fail);
		voteDetail.setOnFlingListener(this);
		loadFail.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				startLoad();
			}
		});
		voteId = getIntent().getStringExtra("id");
		channel = (Channel) getIntent().getExtras().get(ConstantManager.EXTRA_CHANNEL);
		thumbnail = getIntent().getStringExtra(ConstantManager.THUMBNAIL_URL);
		param = ParamsManager.addParams(this, String.format(Config.VOTE_GET_URL, voteId));
		//加载数据
		startLoad();
	}
	  private void getIntentData() {
			// TODO Auto-generated method stub
			preDocumentId = getIntent().getStringExtra(ConstantManager.EXTRA_CURRENT_DETAIL_DOCUMENTID);
	}

	/**
	 * 点击事件处理
	 * 
	 * @param view
	 */
	public void buttonOnClick(View view) {
		if (view == ifengTabbar.findViewById(R.id.back)) {
			// 关闭
			onBackPressed();
		} else if (view == ifengTabbar.findViewById(R.id.more)) {
			if (highestVoteItem == null) {
				return;
			}
			int type;
			//如果过期，则分享结果页
			if(data.isOverDue()) {
				type = VoteModuleBuilder.RESULT_PAGE;
			} 
			else {
				type = VoteModuleBuilder.QUESTION_PAGE;
			}
			VoteShareUitl.shareVoteItem(me, data.getTopic(), highestVoteItem, thumbnail,type);
		} else if(view == loadFail) {
			startLoad();
		}
	}

	@Override
	public void onBackPressed() {
		StatisticUtil.isBack = true ; 
		finish();
		overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
	}

	/**
	 * 从网络获取投票数据
	 */
	private void startLoad() {
		loadFail.setVisibility(View.GONE);
		loading.setVisibility(View.VISIBLE);
		IfengNewsApp.getBeanLoader().startLoading(
				new LoadContext<String, LoadListener<VoteData>, VoteData>(
						param, VoteActivity.this, VoteData.class, Parsers
								.newVoteDataParser(), false,
						LoadContext.FLAG_HTTP_FIRST, true));
	}

	@Override
	public void onFling(int flingState) {
		if (flingState == FLING_RIGHT) {
			onBackPressed();
		}
	}

	@Override
	public void postExecut(LoadContext<?, ?, VoteData> context) {
		VoteData voteData = context.getResult();
		if (voteData != null) {
			// 失败
			if (voteData.getIfsuccess() != 1) {
				context.setResult(null);
				return;
			}
			data = voteData.getData();
			if (data != null) {
				// 初始化最高投票项
				highestVoteItem = VoteShareUitl.getHighestVoteItem(data
						.getIteminfo());
			} else {
				context.setResult(null);
			}
		}
	}

	@Override
	public void loadComplete(LoadContext<?, ?, VoteData> context) {
		loading.setVisibility(View.GONE);
		voteContainer = builder.bindData(data).build();
		voteDetail.addView(voteContainer);
		beginStatistic(voteId);
	}

	private void beginStatistic(String documentId) {
		// TODO Auto-generated method stub
	  // 从推送进入文章的统计
	    if (ConstantManager.ACTION_PUSH.equals(getIntent().getAction())) {
	      // 文章打开统计
	      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	          "id=" + documentId + "$ref=push$type=" + StatisticUtil.StatisticPageType.other);

	      // 推送打开统计，推送打开需要去掉系统标识 imcp
	      String docId = documentId;
	      if (documentId.startsWith("imcp_")) {
	        docId = documentId.split("_")[1];
	      }
	      StatisticUtil.addRecord(getApplicationContext(),
	          StatisticUtil.StatisticRecordAction.openpush, "aid=" + docId + "$type=n");
	    }
	    // 从新闻列表进入文章的推送统计
	    else if (ConstantManager.ACTION_FROM_APP.equals(getIntent().getAction())
	        || ConstantManager.ACTION_FROM_SLIDE_URL.equals(getIntent().getAction())) {
	      if (channel != null) {
	        // 文章打开统计
	       if (!channel.equals(Channel.NULL)) {
	          StatisticUtil.addRecord(getApplicationContext(),
	              StatisticUtil.StatisticRecordAction.page,
	              "id=" + documentId + "$ref=" + channel.getStatistic() + "$type="
	                  + StatisticUtil.StatisticPageType.other);
	        } else {
	          // fix bug #18093 推送打开相关文章，来源为空。
	          StatisticUtil.addRecord(getApplicationContext(),
	              StatisticUtil.StatisticRecordAction.page, "id=" + documentId + "$ref=push$type="
	                  + StatisticUtil.StatisticPageType.other);
	        }
	      }
	      // 凤凰快讯进入文章统计
	    } else if (ConstantManager.ACTION_PUSH_LIST.equals(getIntent().getAction())) {
	      // 推送打开统计，推送打开需要去掉系统标识 imcp
	      // 文章打开
	      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	          "id=" + documentId + "$ref=pushlist$type=" + StatisticUtil.StatisticPageType.article);
	    }
	    // 头条焦点图进入文章的PA统计
	    else if (ConstantManager.ACTION_FROM_HEAD_IMAGE.equals(getIntent().getAction())) {
	      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	          "id=" + documentId + "$ref=sy$type=" + StatisticUtil.StatisticPageType.article+"$tag=t3");
	    } else if (Intent.ACTION_VIEW.equals(getIntent().getAction())) {
	      if (getIntent().hasExtra("from_ifeng_news")) {
	        // 推送文章内链
	        StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	            "id=" + documentId + "$ref="+preDocumentId+"$type=" + StatisticUtil.StatisticPageType.article);
	      } else if (getIntent().hasExtra(ConstantManager.EXTRA_CHANNEL)) {
	        // 普通文章内链
	        StatisticUtil.addRecord(
	            getApplicationContext(),
	            StatisticUtil.StatisticRecordAction.page,
	            "id="
	                + documentId
	                + "$ref="+preDocumentId+ "$type=" + StatisticUtil.StatisticPageType.other);
	      } else {
	        // 从分享渠道打开文章
	        StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	            "id=" + documentId + "$ref=outside$type=" + StatisticUtil.StatisticPageType.article);
	      }
	      // 从widget进入文章统计
	    } else if (ConstantManager.ACTION_WIDGET.equals(getIntent().getAction())) {
	      // 文章打开统计
	      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	          "id=" + documentId + "$ref=desktop$type=" + StatisticUtil.StatisticPageType.other);
	    } else {
	      // 默认算作从首页打开
	      StatisticUtil.addRecord(getApplicationContext(), StatisticUtil.StatisticRecordAction.page,
	          "id=" + documentId + "$ref=sy$type=" + StatisticUtil.StatisticPageType.other);
	    }
	}

	@Override
	public void loadFail(LoadContext<?, ?, VoteData> context) {
		loading.setVisibility(View.GONE);
		loadFail.setVisibility(View.VISIBLE);
	}

	@Override
	public void netWorkFault() {
		isClick = false;
		showMessage("当前无可用网络");
	}

	@Override
	public void voteSuccess(String voteId) {
		isClick = false;
		showMessage("投票成功");
		// 切换到结果页
		builder.displayResultModule(true);
		
		//更新最高投票项
		highestVoteItem = VoteShareUitl.getHighestVoteItem(data.getIteminfo());
		
		// 记录为已经投票
		RecordUtil.record(VoteActivity.this, data.getId(),RecordUtil.VOTE);

	}

	@Override
	public void voteFail() {
		showMessage("投票未成功，请重试");
		isClick = false;
	}

	@Override
	public void onVoteItemClick(int position, VoteItemInfo voteItemInfo) {
		if (isClick) {
			return;
		}
		isClick = true;
		voteExecutor.setVoteId(voteItemInfo.getVoteid())
				.setItemId(voteItemInfo.getId()).vote();
	}

}
