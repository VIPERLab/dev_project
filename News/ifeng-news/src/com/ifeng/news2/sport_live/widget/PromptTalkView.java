package com.ifeng.news2.sport_live.widget;

import java.util.Random;

import com.ifeng.news2.R;
import com.ifeng.news2.sport_live.PromptViewManager;
import com.ifeng.news2.sport_live.entity.Replyer;
import com.ifeng.news2.sport_live.entity.User;
import com.ifeng.news2.sport_live.util.SpeakHelper;
import com.ifeng.news2.sport_live.util.SportLiveHttpListener;
import com.ifeng.news2.util.InfoPreserver;

import android.content.Context;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

/**
 * 发言视图
 * 
 * @author SunQuan
 * 
 */
public class PromptTalkView extends PromptBaseView implements TextWatcher{

	private static final int MAX_WORD_NUM = 300;
	private View closeTalkView;
	private View submitTak;
	private EditText talkContent;
	private TextView centerMessage;
	private TextView userName;
	private TextView talkTotalk;
	private TextView withdraw;

	public PromptTalkView(Context context, Bundle bundle) {
		super(context, bundle);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.detail_close_commment_button:
			close();
			break;
		case R.id.detail_submit_comment_button:
			submit();
			break;
		case R.id.leave:
			leave();
			break;
		default:
			break;
		}
	}

	/**
	 * 退出登录
	 */
	private void leave() {		
		if(InfoPreserver.clearInfo(context,User.class)) {
			withdraw.setVisibility(View.GONE);
			MY_USER_NAME = EMPTY_TEXT;
			userName.setText(MY_USER_NAME);
		}		
	}

	/**
	 * 关闭发言
	 */
	private void close() {
		PromptViewManager.getInstance().changeView(PromptSportLiveBottom.class);
		talkContent.setText(EMPTY_TEXT);
		talkTotalk.setText(EMPTY_TEXT);
	}

	/**
	 * 发布留言
	 */
	private void submit() {
		if (checkInput()) {
			if (!InfoPreserver.hasSavedInfo(context,User.class) && TextUtils.isEmpty(MY_USER_NAME)) {
				if(bundle != null){
					bundle.putString("talkContent", talkContent.getText().toString());
				}				
				PromptViewManager.getInstance().changeView(
						PromptUserCenterView.class,bundle);
			} else {
				if (bundle != null) {
					speech(bundle);
				}
				PromptViewManager.getInstance().changeView(
						PromptSportLiveBottom.class);
				talkContent.setText(EMPTY_TEXT);
			}
		}
	}

	/**
	 * * @param mt 比赛id
	 * 
	 * @param uid
	 *            用户id
	 * @param nickname
	 *            用户名
	 * @param content
	 *            聊天内容
	 * @param touser
	 *            对某人聊天时某人的id
	 * @param tonick
	 *            对某人聊天时某人的name
	 * @param bundle
	 */
	private void speech(Bundle bundle) {
		String mt = bundle.getString("mt");
		String tonick = bundle.getString("tonick");
		String touser = bundle.getString("touser");
		String uid = 0+"";
		if(InfoPreserver.hasSavedInfo(context,User.class)){
			uid = new Random().nextInt(1000) + "";
		}
		String nickname = MY_USER_NAME;
		String content = talkContent.getText().toString();

		SpeakHelper.create()
				.setSpeakParams(mt, uid, nickname, content, touser, tonick)
				.speak(new SportLiveHttpListener<Replyer>() {

					@Override
					public void success(Replyer result) {
						dismissDialog();
						toast.showMessage(result.getMsg());
						talkTotalk.setText(EMPTY_TEXT);
					}

					@Override
					public void preLoad() {
						createDialog("正在发布，请稍候", context);
					}

					@Override
					public void fail(Replyer result) {
						dismissDialog();
						toast.showMessage(result.getMsg());
					}
				});

	}

	@Override
	protected void onCreate() {
		setContainer(R.layout.sport_live_talk);
		centerMessage = (TextView)findViewById(R.id.centerMessage);
		centerMessage.setText("发言");
		closeTalkView = findViewById(R.id.detail_close_commment_button);
		submitTak = findViewById(R.id.detail_submit_comment_button);
		talkContent = (EditText) findViewById(R.id.detail_comment_editText);
		userName = (TextView) findViewById(R.id.userName_TV);
		talkTotalk = (TextView) findViewById(R.id.talk_to_talk);
		withdraw = (TextView) findViewById(R.id.leave);
		showSoftInput(context, talkContent, true);
	}

	@Override
	protected void setListener() {
		submitTak.setOnClickListener(this);
		closeTalkView.setOnClickListener(this);
		withdraw.setOnClickListener(this);
		talkContent.addTextChangedListener(this);
	}

	/**
	 * 检查输入的内容是否符合要求
	 * 
	 * @return
	 */
	private boolean checkInput() {
		boolean isValid = true;
		if (isEmptyInput(talkContent)) {
			toast.showMessage("发言内容不能为空！");
			isValid = false;
		}
		return isValid;
	}

	@Override
	public void onResume() {
		showSoftInput(context, talkContent, false);
		showSoftInput(context, talkContent, true);
		if(bundle != null){
			String toTalker = bundle.getString("tonick");
			if(!TextUtils.isEmpty(toTalker)){
				talkTotalk.setText("对"+toTalker+"说");
			}
			String content = bundle.getString("talkContent");
			if(!TextUtils.isEmpty(content)){
				talkContent.setText(content);
			}
		}
		User user = InfoPreserver.getSavedInfo(context,User.class);
		// 判断用户是否登录或者免登陆发言
		if (user != null) {
			withdraw.setVisibility(View.VISIBLE);
			userName.setText(user.getUsername());
			MY_USER_NAME = user.getUsername();
		} else {
			if (!TextUtils.isEmpty(MY_USER_NAME)) {
				userName.setText(MY_USER_NAME);
			}
			withdraw.setVisibility(View.GONE);
		}
		
	}

	@Override
	public void onPause() {
		if (!InfoPreserver.hasSavedInfo(context,User.class)) {
			MY_USER_NAME = EMPTY_TEXT;
			userName.setText(MY_USER_NAME);
		}
		talkContent.setText(EMPTY_TEXT);
		talkTotalk.setText(EMPTY_TEXT);
		showSoftInput(context, talkContent, false);
	}

	@Override
	public void beforeTextChanged(CharSequence s, int start, int count,
			int after) {
		
	}

	@Override
	public void onTextChanged(CharSequence s, int start, int before, int count) {
		
	}

	@Override
	public void afterTextChanged(Editable s) {
		//如果字数超过300字，将无法输入
		if(s.length() > MAX_WORD_NUM){
			s.delete(MAX_WORD_NUM, s.length());
			toast.showMessage("字数超过限制");
		}
	}

}
