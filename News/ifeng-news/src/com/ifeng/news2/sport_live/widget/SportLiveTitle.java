package com.ifeng.news2.sport_live.widget;

import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.sport_live.entity.MatchBody;
import com.ifeng.news2.sport_live.entity.MatchInfo;
import com.ifeng.news2.sport_live.entity.SportFactItem;
import com.ifeng.news2.util.ParamsManager;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import android.content.Context;
import android.graphics.Bitmap;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

/**
 * 体育直播页顶部导航栏，有两种展现方式，一种是显示球队和比分等信息，可实时刷新，另一种是显示一行文字，不会刷新
 * 
 * @author SunQuan
 * 
 */
public class SportLiveTitle extends RelativeLayout implements
		LoadListener<MatchInfo> {

	private View sportLiveTitle;
	private TextView sportStep;
	private ImageView teamLogoLeft;
	private ImageView teamLogoRight;
	private TextView teamNameLeft;
	private TextView teamNameRight;
	private TextView sportPoint;
	private View matchMode1;
	private String status = MatchBody.MATCH_MODE_1;
	private TextView matchMode2;
	private MatchInfo matchInfo;
	private View timeBoard;

	public MatchInfo getMatchInfo() {
		return matchInfo;
	}

	public String getStatus() {
		return status;
	}

	public SportLiveTitle(Context context) {
		super(context);
		init(context);
	}

	public SportLiveTitle(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init(context);
	}

	public SportLiveTitle(Context context, AttributeSet attrs) {
		super(context, attrs);
		init(context);
	}

	/**
	 * 初始化控件
	 * 
	 * @param context
	 */
	private void init(Context context) {
		sportLiveTitle = LayoutInflater.from(context).inflate(
				R.layout.sport_live_title, this);
		matchMode1 = sportLiveTitle.findViewById(R.id.matchMode_one);
		matchMode2 = (TextView) sportLiveTitle.findViewById(R.id.matchMode_two);
		sportStep = (TextView) sportLiveTitle.findViewById(R.id.sport_step);
		timeBoard = sportLiveTitle.findViewById(R.id.sport_top);
		timeBoard.setVisibility(View.INVISIBLE);
		teamLogoLeft = (ImageView) sportLiveTitle
				.findViewById(R.id.teamLogoLeft);
		teamLogoRight = (ImageView) sportLiveTitle
				.findViewById(R.id.teamLogoRight);
		teamNameLeft = (TextView) sportLiveTitle
				.findViewById(R.id.teamNameLeft);
		teamNameRight = (TextView) sportLiveTitle
				.findViewById(R.id.teamNameRight);
		sportPoint = (TextView) sportLiveTitle.findViewById(R.id.sport_point);
	}

	/**
	 * 通过URL从网络获取数据，并展示
	 * 
	 * @param url
	 */
	public void displayDataByUrl(String url) {
		IfengNewsApp.getBeanLoader().startLoading(
				new LoadContext<String, LoadListener<MatchInfo>, MatchInfo>(
						ParamsManager.addParams(url), this, MatchInfo.class,
						Parsers.newMatchInfoParser(),
						LoadContext.FLAG_HTTP_ONLY, false));
	}

	/**
	 * 将比赛数据实体对象和图形绑定
	 * 
	 * @param matchInfo
	 */
	private void setMatchInfo(MatchInfo matchInfo) {
		this.matchInfo = matchInfo;
		MatchBody matchBody = matchInfo.getBody();
		String isOnetitle = matchBody.getIsOneTitle();
		if (MatchBody.MATCH_MODE_1.equals(isOnetitle)) {
			bindMatchBodyByMode1(matchBody);
			status = MatchBody.MATCH_MODE_1;
		} else if (MatchBody.MATCH_MODE_2.equals(isOnetitle)) {
			bindMatchBodyByMode2(matchBody);
			status = MatchBody.MATCH_MODE_2;
		}
	}

	/**
	 * 渲染第一种比赛模式的视图
	 * 
	 * @param matchBody
	 */
	private void bindMatchBodyByMode1(MatchBody matchBody) {
		matchMode1.setVisibility(View.VISIBLE);
		matchMode2.setVisibility(View.GONE);
		teamNameLeft.setText(matchBody.getAwayTeam());
		teamNameRight.setText(matchBody.getHomeTeam());
		IfengNewsApp.getImageLoader().startLoading(
				new LoadContext<String, ImageView, Bitmap>(matchBody
						.getAwayLogo(), teamLogoLeft, Bitmap.class,
						LoadContext.FLAG_HTTP_ONLY));
		IfengNewsApp.getImageLoader().startLoading(
				new LoadContext<String, ImageView, Bitmap>(matchBody
						.getHomeLogo(), teamLogoRight, Bitmap.class,
						LoadContext.FLAG_HTTP_ONLY));
	}

	/**
	 * 渲染第二种比赛模式的视图
	 * 
	 * @param matchBody
	 */
	private void bindMatchBodyByMode2(MatchBody matchBody) {
		matchMode1.setVisibility(View.GONE);
		matchMode2.setVisibility(View.VISIBLE);
		matchMode2.setText(matchBody.getOneTitle());
	}

	/**
	 * 更新比分和比赛时间
	 */
	public void notifyTitle(SportFactItem sportFactItem) {
		if (MatchBody.MATCH_MODE_1.equals(status)) {
			StringBuilder builder = new StringBuilder();
			builder.append(sportFactItem.getAwaycore()).append(":")
					.append(sportFactItem.getHomescore());
			sportPoint.setText(builder.toString());
			//如果没有获取到比赛时间，不显示时间底图
			if(!TextUtils.isEmpty(sportFactItem.getSection())){
				timeBoard.setVisibility(View.VISIBLE);
				sportStep.setText(sportFactItem.getSection());
			}
			
		}
	}

	@Override
	public void postExecut(LoadContext<?, ?, MatchInfo> context) {
		MatchBody body = context.getResult().getBody();
		//过滤返回的数据是否完整
		if(body==null||body.getAwayTeam()==null||body.getHomeTeam()==null){
			context.setResult(null);
		}
	}

	@Override
	public void loadComplete(LoadContext<?, ?, MatchInfo> context) {
		MatchInfo matchInfo = context.getResult();
		setMatchInfo(matchInfo);
	}

	@Override
	public void loadFail(LoadContext<?, ?, MatchInfo> context) {
		
	}

}
