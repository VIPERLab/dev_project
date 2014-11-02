package com.ifeng.news2.topic_module;

import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.util.RecordUtil;
import com.ifeng.news2.util.WindowPrompt;
import com.ifeng.news2.vote.VoteExecutor;
import com.ifeng.news2.vote.VoteModuleBuilder.VoteShareListener;
import com.ifeng.news2.vote.VoteShareUitl;
import com.ifeng.news2.vote.VoteExecutor.VoteListener;
import com.ifeng.news2.vote.VoteModuleBuilder.VoteItemClickListener;
import com.ifeng.news2.vote.VoteModuleBuilder;
import com.ifeng.news2.vote.entity.Data;
import com.ifeng.news2.vote.entity.VoteData;
import com.ifeng.news2.vote.entity.VoteItemInfo;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.util.WToast;
import android.content.Context;
import android.util.AttributeSet;
import static com.ifeng.news2.vote.VoteModuleBuilder.EMBEDDED_MODE;

/**
 * 投票模块
 * 
 * @author SunQuan:
 * @version 创建时间：2013-12-4 下午1:44:20 类说明
 */

public class VoteModule extends BaseModule implements VoteListener,
		VoteItemClickListener, VoteShareListener {

	private VoteModuleBuilder builder;
	private VoteExecutor voteExecutor;
	private WToast toast;
	private boolean isClick = false;
	private Data data;
	private VoteItemInfo highestVoteItem;
	private WindowPrompt windowPrompt;

	public VoteModule(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public VoteModule(Context context) {
		super(context);
	}

	@Override
	public void initView(Context context) {
		super.initView(context);
		toast = new WToast(context);
		voteExecutor = new VoteExecutor(context);
		// 设置投票执行的监听
		voteExecutor.addVoteListener(this);

		builder = VoteModuleBuilder.initialize(context, EMBEDDED_MODE);
		// 设置投票问题项点击事件的监听
		builder.setVoteItemClickListener(this);
		builder.setOnShareListener(this);
	}

	@Override
	public void buildModule() {
		super.buildModule();

		addView(getLeftTitleView(subject.getTitle()));
		// 加载投票数据
		loadVoteData();
	}

	/**
	 * 加载投票数据
	 */
	private void loadVoteData() {
		String voteId = subject.getPodItems().get(0).getId();
		String param = ParamsManager.addParams(context, String.format(Config.VOTE_GET_URL, voteId));
		startLoad(param);
	}

	/**
	 * 从网络获取投票数据
	 */
	private void startLoad(String param) {
		IfengNewsApp.getBeanLoader().startLoading(
				new LoadContext<String, LoadListener<VoteData>, VoteData>(
						param, new LoadListener<VoteData>() {

							@Override
							public void postExecut(
									LoadContext<?, ?, VoteData> context) {
								VoteData voteData = context.getResult();
								if (voteData != null) {
									// 失败
									if (voteData.getIfsuccess() != 1) {
										context.setResult(null);
										return;
									}
									data = voteData.getData();
									if (data != null) {
										highestVoteItem = VoteShareUitl
												.getHighestVoteItem(data
														.getIteminfo());
									} else {
										context.setResult(null);
									}
								}
							}

							@Override
							public void loadComplete(
									LoadContext<?, ?, VoteData> context) {
								addView(builder.bindData(data).build());
							}

							@Override
							public void loadFail(
									LoadContext<?, ?, VoteData> context) {
							}
						}, VoteData.class, Parsers.newVoteDataParser(), false,
						LoadContext.FLAG_HTTP_FIRST, true));
	}

	@Override
	public void netWorkFault() {
		isClick = false;
		if(windowPrompt == null) {
			windowPrompt = WindowPrompt.getInstance(context);
		}
		windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
	}

	@Override
	public void voteSuccess(String voteId) {
		isClick = false;
		toast.showMessage("投票成功");
		// 切换到结果页
		builder.displayResultModule(true);
		//更新最高投票项
		highestVoteItem = VoteShareUitl.getHighestVoteItem(data.getIteminfo());
		// 记录为已经投票
		RecordUtil.record(context, voteId, RecordUtil.VOTE);

	}

	@Override
	public void voteFail() {
		isClick = false;
		toast.showMessage("投票未成功，请重试");
	}

	@Override
	public void onVoteItemClick(int position, VoteItemInfo voteItemInfo) {
		if (!isClick) {
			isClick = true;
			voteExecutor.setVoteId(voteItemInfo.getVoteid())
					.setItemId(voteItemInfo.getId()).vote();
		}
	}

	@Override
	public void onShare() {
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
		// 分享投票
		VoteShareUitl.shareVoteItem(context, data.getTopic(), highestVoteItem,
				subject.getShareThumbnail(), type);
	}
}
