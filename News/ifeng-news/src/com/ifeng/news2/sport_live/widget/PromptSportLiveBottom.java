package com.ifeng.news2.sport_live.widget;

import java.util.ArrayList;
import com.ifeng.news2.R;
import com.ifeng.news2.R.id;
import com.ifeng.news2.sport_live.PromptViewManager;
import com.ifeng.news2.util.FunctionButtonWindow;
import com.ifeng.news2.util.FunctionButtonWindow.FunctionButtonInterface;
import com.ifeng.news2.util.FunctionButtonWindow.SportLiveButtonInterface;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

/**
 * 直播页的底部导航栏
 * 
 * @author SunQuan
 * 
 */
public class PromptSportLiveBottom extends PromptBaseView implements
		FunctionButtonInterface, SportLiveButtonInterface {

	private ImageView back;
	private ImageView more;
	private ImageView placeholder;
	private ImageView writeComment;
	private TextView backPrompt;
	private TextView writeCommentPrompt;
	private TextView morePrompt;
	private ImageView firstDivider;
	private ImageView secondDivider;
	private ImageView thirdDivider;
	private Type currentState;
	private FunctionButtonWindow functionButtonWindow;
	private BottomListener bottomListener;

	public void setBottomListener(BottomListener bottomListener) {
		this.bottomListener = bottomListener;
	}

	public PromptSportLiveBottom(Context context, Bundle bundle) {
		super(context, bundle);
		currentState = Type.STATE_MAIN;
		setStyle();
	}

	public boolean isMainState() {
		if (currentState == Type.STATE_MAIN) {
			return true;
		}
		return false;
	}

	/**
	 * 切换底部导航栏的视图状态
	 * 
	 * @param context
	 */
	public void switchState() {
		if (currentState == Type.STATE_MAIN) {
			currentState = Type.STATE_SUB;
		} else {
			currentState = Type.STATE_MAIN;
		}
		setStyle();
	}

	/**
	 * 设置类型，根据不同的状态显示不同的样式
	 * 
	 * @param context
	 */
	private void setStyle() {
		Drawable drawable = null;
		back.setBackgroundResource(R.drawable.detail_title_bar_button);
		drawable = context.getResources().getDrawable(R.drawable.back);
		drawable.setBounds(0, 0, drawable.getMinimumWidth(),
				drawable.getMinimumHeight());
		backPrompt.setCompoundDrawables(drawable, null, null, null);
		backPrompt.setText(R.string.back);
		backPrompt.setTextAppearance(context, R.style.detail_title_bar_button);

		more.setBackgroundResource(R.drawable.detail_title_bar_button);
		
		if (currentState == Type.STATE_MAIN) {
			drawable = context.getResources().getDrawable(R.drawable.more);
			drawable.setBounds(0, 0, drawable.getMinimumWidth(),
					drawable.getMinimumHeight());
			morePrompt.setCompoundDrawables(drawable, null, null, null);
			morePrompt.setText(R.string.detail_title_bar_more);
			morePrompt.setTextAppearance(context, R.string.detail_title_bar_more);
		} else {
			drawable = context.getResources().getDrawable(R.drawable.share);
			drawable.setBounds(0, 0, drawable.getMinimumWidth(),
					drawable.getMinimumHeight());
			morePrompt.setCompoundDrawables(drawable, null, null, null);
			morePrompt.setText(R.string.detail_title_bar_share);
			morePrompt.setTextAppearance(context, R.string.detail_title_bar_share);
			
		}
		
		placeholder.setBackgroundResource(R.drawable.detail_title_bar_button);
		firstDivider.setBackgroundResource(R.drawable.detail_tabbar_cutoff);
		secondDivider.setBackgroundResource(R.drawable.detail_tabbar_cutoff);
		thirdDivider.setBackgroundResource(R.drawable.detail_tabbar_cutoff);

		getContainer().setBackgroundResource(R.drawable.detail_tabbar_background);

		if (currentState == Type.STATE_MAIN) {
			writeComment
					.setBackgroundResource(R.drawable.detail_title_bar_button);
			drawable = context.getResources().getDrawable(
					R.drawable.sport_live_chat_logo);
			drawable.setBounds(0, 0, drawable.getMinimumWidth(),
					drawable.getMinimumHeight());
			writeCommentPrompt.setCompoundDrawables(drawable, null, null, null);
			writeCommentPrompt.setText(R.string.sport_live_bar_communicate);
			writeCommentPrompt.setTextAppearance(context,
					R.style.detail_title_bar_button);
		} else {
			writeComment
					.setBackgroundResource(R.drawable.detail_title_bar_button);
			drawable = context.getResources().getDrawable(R.drawable.write_comment);
			drawable.setBounds(0, 0, drawable.getMinimumWidth(),
					drawable.getMinimumHeight());
			writeCommentPrompt.setCompoundDrawables(drawable, null, null, null);
			writeCommentPrompt.setText(R.string.sport_live_bar_chat);
			writeCommentPrompt.setTextAppearance(context,
					R.style.detail_title_bar_button);
		}
	}

	enum Type {
		// 直播第一个页面
		STATE_MAIN,
		// 直播第二个页面
		STATE_SUB
	}

	@Override
	public void onClick(View v) {
		int resId = v.getId();
		switch (resId) {
		case R.id.back:
			bottomListener.back();
			break;
		case R.id.more:
			if (currentState == Type.STATE_MAIN) {
				showMoreView();
			} else {
				showShareView();
			}
			
			break;
		case R.id.write_comment:
			if (currentState == Type.STATE_MAIN) {
				bottomListener.goToChatPage();
			} else {
				bundle.putString("talkContent", EMPTY_TEXT);
				bundle.putString("tonick", EMPTY_TEXT);
				PromptViewManager.getInstance()
						.changeView(PromptTalkView.class,bundle);
			}
			break;
		default:
			break;
		}
	}

	/**
	 * 显示更多的对话框
	 */
	private void showMoreView() {
		ArrayList<String> functionBut = new ArrayList<String>();
		if (currentState == Type.STATE_MAIN) {
			functionBut.add("战报");
			functionBut.add("数据");
			functionBut.add("分享");
		} else {
			functionBut.add("分享");
		}
		functionButtonWindow.showMoreFunctionButtons(more, functionBut,
				FunctionButtonWindow.TYPE_FUNCTION_BUTTON_WHITE);
	}

	@Override
	public void redirectToDataPage() {
		bottomListener.redirectToDataPage();
	}

	@Override
	public void redirectToReportPage() {
		bottomListener.redirectToReportPage();
	}

	@Override
	public void downloadPicture() {
		// do nothing
	}

	@Override
	public void showShareView() {
		bottomListener.showShareView();
	}

	@Override
	public void initCollectViewState() {
		// do nothing
	}

	@Override
	public boolean onCollect() {
		return false;
	}

	@Override
	public int getBottomTabbarHeight() {
		return getContainer().getHeight();
	}

	/**
	 * 底部导航按键的监听接口
	 * 
	 * @author Administrator
	 * 
	 */
	public interface BottomListener {
		/**
		 * 显示分享对话框
		 */
		void showShareView();

		/**
		 * 跳转到战报页
		 */
		void redirectToReportPage();

		/**
		 * 跳转到数据页
		 */
		void redirectToDataPage();

		/**
		 * 返回
		 */
		void back();

		/**
		 * 跳转到聊天页
		 */
		void goToChatPage();

	}

	@Override
	protected void onCreate() {
		functionButtonWindow = new FunctionButtonWindow(context);
		functionButtonWindow.setFunctionButtonInterface(this);
		functionButtonWindow.setSportLiveButtonInterface(this);
		setContainer(R.layout.bottom_title_tabbar);
		back = (ImageView)findViewById(id.back);
		backPrompt = (TextView)findViewById(id.back_prompt);
		firstDivider = (ImageView) findViewById(id.first_divider);
		secondDivider = (ImageView) findViewById(id.second_divider);
		thirdDivider = (ImageView) findViewById(id.third_divider);
		placeholder = (ImageView) findViewById(id.placeholder);
		writeComment = (ImageView) findViewById(id.write_comment);
		writeCommentPrompt = (TextView) findViewById(id.write_comment_prompt);
		more = (ImageView) findViewById(id.more);
		morePrompt = (TextView) findViewById(id.more_prompt);
	}

	@Override
	protected void setListener() {
		back.setOnClickListener(this);
		writeComment.setOnClickListener(this);
		more.setOnClickListener(this);
	}

}
