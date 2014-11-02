package com.ifeng.news2.vote;

import android.content.Context;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.util.ParamsManager;
import com.ifeng.news2.vote.entity.VoteResult;
import com.ifeng.share.util.NetworkState;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;

/**
 * 投票的执行类
 * 
 * @author SunQuan:
 * @version 创建时间：2013-12-2 上午9:13:31 类说明
 */

public class VoteExecutor implements LoadListener<VoteResult> {

	private static final String OK = "ok";
	private VoteListener voteListener;
	private String voteId;
	private String itemId;
	private Context context;

	public VoteExecutor(Context context) {
		this.context = context;
	}

	/**
	 * 设置投票的id
	 * 
	 * @param voteId
	 * @return
	 */
	public VoteExecutor setVoteId(String voteId) {
		this.voteId = voteId;
		return this;
	}

	/**
	 * 设置投票单项的id
	 * 
	 * @param itemId
	 * @return
	 */
	public VoteExecutor setItemId(String itemId) {
		this.itemId = itemId;
		return this;
	}

	/**
	 * 未投票设置监听（可选）
	 * 
	 * @param voteListener
	 */
	public void addVoteListener(VoteListener voteListener) {
		this.voteListener = voteListener;
	}

	/**
	 * 投票 执行该方法之前必须先设置voteId和itemId
	 */
	public void vote() {
		if (voteId == null || itemId == null) {
			throw new IllegalStateException(
					"VoteId and itemId should not be null, please call setItemId and setVoteId first!");
		}

		vote(voteId, itemId);
	}
	
	/**
	 * 投票执行的url
	 * 
	 * @param voteId
	 * @param itemId
	 * @return
	 */
	private String getParams(String voteId, String itemId) {
		return ParamsManager.addParams(context, String.format(Config.VOTE_RESULT_URL, voteId,itemId));
	}
	
	/**
	 * 检查网络的有效性
	 * 
	 * @return
	 */
	private boolean isNetWorkValid() {
		if (!NetworkState.isActiveNetworkConnected(context)) {
			if (voteListener != null) {
				voteListener.netWorkFault();
			}
			return false;
		}
		return true;
	}
	
	/**
	 * 联网请求投票数据
	 * 
	 * @param params
	 */
	private void loadVoteData(String params) {
		IfengNewsApp.getBeanLoader().startLoading(
				new LoadContext<String, LoadListener<VoteResult>, VoteResult>(
						params, VoteExecutor.this, VoteResult.class, Parsers
								.newVoteResultParser(), false,
						LoadContext.FLAG_HTTP_FIRST, false));
	}


	private void vote(String voteId, String itemId) {
		// 如果没有网络，将不进行其他操作
		if(!isNetWorkValid()) {
			return;
		}
		//得到请求投票的url
		String params = getParams(voteId, itemId);
		
		loadVoteData(params);
		
	}
	
	
	@Override
	public void postExecut(LoadContext<?, ?, VoteResult> context) {
		// donothing
	}

	@Override
	public void loadComplete(LoadContext<?, ?, VoteResult> context) {
		VoteResult voteResult = context.getResult();
		if (voteResult.getIfsuccess() == 1 && voteResult.getMsg().equals(OK)) {
			if (voteListener != null) {
				voteListener.voteSuccess(voteId);
			}
		} else {
			if(voteListener != null) {
				voteListener.voteFail();
			}			
		}
	}

	@Override
	public void loadFail(LoadContext<?, ?, VoteResult> context) {
		if(voteListener != null) {
			voteListener.voteFail();
		}		
	}

	/**
	 * 投票监听
	 * 
	 * @author SunQuan
	 * 
	 */
	public interface VoteListener {
		/**
		 * 网络链接错误
		 */
		void netWorkFault();

		/**
		 * 投票成功
		 * 
		 * @param voteId 整个投票页的id
		 */
		void voteSuccess(String voteId);

		/**
		 * 投票失败
		 */
		void voteFail();
	}
}
