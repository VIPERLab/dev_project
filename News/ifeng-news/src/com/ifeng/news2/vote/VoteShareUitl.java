package com.ifeng.news2.vote;

import static com.ifeng.news2.vote.VoteModuleBuilder.QUESTION_PAGE;
import static com.ifeng.news2.vote.VoteModuleBuilder.RESULT_PAGE;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import android.content.Context;
import android.text.TextUtils;
import com.ifeng.news2.Config;
import com.ifeng.news2.share.ShareAlertBig;
import com.ifeng.news2.share.WXHandler;
import com.ifeng.news2.util.StatisticUtil.StatisticPageType;
import com.ifeng.news2.vote.entity.VoteItemInfo;

/**
 * 投票分享
 * 
 * @author SunQuan:
 * @version 创建时间：2013-12-3 下午1:42:41 类说明
 */

public final class VoteShareUitl {

	private VoteShareUitl() {
	}

	/**
	 * 分享标题
	 * 
	 * @return
	 */
	private static String getShareTitle(VoteItemInfo highestVoteItem) {
		return highestVoteItem.getNump() + "%的人选择\""
				+ highestVoteItem.getTitle() + "\"。 ";
	}

	/**
	 * 得到分享的内容
	 * 
	 * @return
	 */
	private static String getShareContent(String data) {
		return "凤凰民调:" + data;
	}

	/**
	 * 分享投票
	 * 
	 * @param context
	 * @param data
	 * @param highestVoteItem
	 */
	public static void shareVoteItem(Context context,String data,
			VoteItemInfo highestVoteItem, String thumbnail,int type) {
		ShareAlertBig alert = new ShareAlertBig(context,
				new WXHandler(context),
				getShareUrl(highestVoteItem.getVoteid(),type),
				getShareTitle(highestVoteItem), getShareContent(data),
				getShareImage(thumbnail), null, StatisticPageType.vote);
		alert.show(context);
	}

	/**
	 * 得到分享的url
	 * 
	 * @param voteId
	 * @return
	 */
	private static String getShareUrl(String voteId,int type) {
		String shareUrl = null;
		switch (type) {
		case QUESTION_PAGE:
			shareUrl = Config.VOTE_SHARE_URL;
			break;
		case RESULT_PAGE:
			shareUrl = Config.VOTE_SHARE_RESULT;
			break;
		default:
			shareUrl = Config.VOTE_SHARE_URL;
			break;
		}			
		return String.format(shareUrl, voteId);
	}

	/**
	 * 获取缩略图
	 * 
	 * @return
	 */
	private static ArrayList<String> getShareImage(String thumbnail) {
		ArrayList<String> thumbnails = new ArrayList<String>();
		if (!TextUtils.isEmpty(thumbnail))
			thumbnails.add(thumbnail);
		return thumbnails;
	}

	/**
	 * 根据所有的投票项得到最高投票项
	 * 
	 * @param voteItemInfos
	 * @return
	 */
	public static VoteItemInfo getHighestVoteItem(
			ArrayList<VoteItemInfo> voteItemInfos) {

		if (voteItemInfos == null || voteItemInfos.size() == 0) {
			return null;
		}

		VoteItemInfo highestVoteItem = null;
		// 创建一个临时的集合，用来排序
		ArrayList<VoteItemInfo> tempVoteItemInfos = new ArrayList<VoteItemInfo>();
		tempVoteItemInfos.addAll(voteItemInfos);

		// 对投票项进行从大到小的排序
		Collections.sort(tempVoteItemInfos, new Comparator<VoteItemInfo>() {

			@Override
			public int compare(VoteItemInfo ob1, VoteItemInfo ob2) {
				if (Integer.valueOf(ob1.getVotecount()) > Integer.valueOf(ob2
						.getVotecount())) {
					return -1;
				} else if (Integer.valueOf(ob1.getVotecount()) < Integer
						.valueOf(ob2.getVotecount())) {
					return 1;
				}
				return 0;
			}
		});
		highestVoteItem = tempVoteItemInfos.get(0);
		// 将临时集合销毁掉
		tempVoteItemInfos.clear();
		tempVoteItemInfos = null;
		return highestVoteItem;
	}

}
