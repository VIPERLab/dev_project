package com.ifeng.news2.sport_live.widget;

import com.ifeng.news2.R;
import com.ifeng.news2.sport_live.PromptViewManager;
import com.ifeng.news2.sport_live.entity.User;
import com.ifeng.news2.sport_live.entity.User.ActionType;
import com.ifeng.news2.sport_live.util.LoginAndRegistHelper;
import com.ifeng.news2.sport_live.util.SportLiveHttpListener;
import com.ifeng.news2.util.InfoPreserver;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

/**
 * 用户登录视图
 * 
 * @author SunQuan
 * 
 */
public class PromptUserCenterLoginView extends PromptBaseView {

	public PromptUserCenterLoginView(Context context, Bundle bundle) {
		super(context, bundle);
	}

	private EditText userNameET;
	private EditText passWordET;
	private ImageView submit;
	private TextView message;
	private TextView regist;
	private static final int MAX_LENGTH = 20;
	private static final int MIN_LENGTH = 2;

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.sport_submit:
			login();
			break;
		case R.id.regist_now:
			PromptViewManager.getInstance().changeView(
					PromptUserCenterRegisterView.class,bundle);
			break;
		default:
			break;
		}
	}

	@Override
	protected void onCreate() {
		setContainer(R.layout.sport_live_usercenter_login);
		userNameET = (EditText) findViewById(R.id.userName_ET);
		passWordET = (EditText) findViewById(R.id.password_ET);
		submit = (ImageView) findViewById(R.id.sport_submit);
		regist = (TextView) findViewById(R.id.regist_now);
		message = (TextView) findViewById(R.id.messageTV);
		message.setVisibility(View.GONE);
	}

	@Override
	protected void setListener() {
		submit.setOnClickListener(this);
		regist.setOnClickListener(this);
	}

	/**
	 * 校验输入的有效性
	 * 
	 * @return
	 */
	private boolean checkInput() {
		String userName = userNameET.getText().toString();
		String password = passWordET.getText().toString();
		boolean isValid = true;
		if (isEmptyInput(passWordET) || isEmptyInput(userNameET)) {
			message.setVisibility(View.VISIBLE);
			message.setText("用户名或密码不能为空");
			isValid = false;
		} else if (userName.length() > MAX_LENGTH
				|| password.length() < MIN_LENGTH) {
			message.setVisibility(View.VISIBLE);
			message.setText("用户名不符合字数限制");
			isValid = false;
		} else if (userName.contains("@")) {
			message.setVisibility(View.VISIBLE);
			message.setText("用户名包含非法字符");
			isValid = false;
		}
		return isValid;
	}

	@Override
	public void onResume() {
		showSoftInput(context, userNameET, false);
		showSoftInput(context, passWordET, false);
		showSoftInput(context, userNameET, true);
		if (!TextUtils.isEmpty(bundle.getString("MyUserName"))&&!TextUtils.isEmpty(bundle.getString("MyPassWord"))) {
			userNameET.setText(bundle.getString("MyUserName"));
			passWordET.setText(bundle.getString("MyPassWord"));
		} 		
	}

	@Override
	public void onPause() {
		showSoftInput(context, userNameET, false);
		showSoftInput(context, passWordET, false);
		userNameET.setText(EMPTY_TEXT);
		passWordET.setText(EMPTY_TEXT);
		message.setVisibility(View.GONE);
		message.setText(EMPTY_TEXT);
	}

	/**
	 * 用户登录
	 * 
	 * @param context
	 */
	private void login() {
		if (checkInput()) {
			User user = new User();
			user.setAction(ActionType.LOGIN);
			user.setUsername(userNameET.getText().toString());
			user.setPassword(passWordET.getText().toString());
			LoginAndRegistHelper.create().execute(user,
					new SportLiveHttpListener<User>() {

						@Override
						public void success(User user) {
							//保存用户信息
							if(InfoPreserver.saveInfo(context, user)) {
								dismissDialog();
								toast.showMessage("恭喜您，登录成功");
								message.setVisibility(View.VISIBLE);
								message.setText(user.getResultMessage());							
								PromptViewManager.getInstance().changeView(
										PromptTalkView.class,bundle);
							}										
						}

						@Override
						public void preLoad() {
							createDialog("登录中，请稍候", context);
						}

						@Override
						public void fail(User user) {
							dismissDialog();
							message.setVisibility(View.VISIBLE);
							message.setText(user.getResultMessage());
						}
					});

		}
	}

}
