package com.ifeng.news2.sport_live.widget;

import com.ifeng.news2.R;
import com.ifeng.news2.sport_live.PromptViewManager;

import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

/**
 * 用户中心视图
 * 
 * @author SunQuan
 * 
 */
public class PromptUserCenterView extends PromptBaseView {

	private TextView login;
	private TextView register;
	private EditText inputET;
	private ImageView submit;
	private static final int MAX_LENGTH = 30;

	public PromptUserCenterView(Context context,Bundle bundle) {
		super(context,bundle);
	}

	@Override
	protected void setListener() {
		login.setOnClickListener(this);
		register.setOnClickListener(this);
		submit.setOnClickListener(this);
	}

	@Override
	protected void onCreate() {
		setContainer(R.layout.sport_live_user_center);
		login = (TextView) findViewById(R.id.login);
		register = (TextView) findViewById(R.id.register);
		inputET = (EditText) findViewById(R.id.input_ET);
		submit = (ImageView) findViewById(R.id.sport_submit);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.login:
			PromptViewManager.getInstance().changeView(
					PromptUserCenterLoginView.class,bundle);
			break;
		case R.id.register:
			PromptViewManager.getInstance().changeView(
					PromptUserCenterRegisterView.class,bundle);
			break;
		case R.id.sport_submit:
			if (checkInput()) {
				MY_USER_NAME = inputET.getText().toString();				
				PromptViewManager.getInstance()
						.changeView(PromptTalkView.class,bundle);
			}
			break;
		default:
			break;
		}
	}

	/**
	 * 检查输入的内容是否符合要求
	 * 
	 * @return
	 */
	private boolean checkInput() {
		boolean isValid = true;
		if (isEmptyInput(inputET)) {
			toast.showMessage("昵称不能为空");
			isValid = false;
		}
		if (inputET.getText().length() > MAX_LENGTH) {
			toast.showMessage("昵称字数超过限制");
			isValid = false;
		}
		return isValid;
	}

	@Override
	public void onResume() {
		showSoftInput(context, inputET, false);
		showSoftInput(context, inputET, true);
	}

	@Override
	public void onPause() {
		showSoftInput(context, inputET, false);
		inputET.setText(EMPTY_TEXT);
	}

}
