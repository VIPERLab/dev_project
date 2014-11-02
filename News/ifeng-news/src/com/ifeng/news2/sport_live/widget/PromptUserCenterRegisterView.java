package com.ifeng.news2.sport_live.widget;

import com.ifeng.news2.R;
import com.ifeng.news2.sport_live.PromptViewManager;
import com.ifeng.news2.sport_live.entity.User;
import com.ifeng.news2.sport_live.entity.User.ActionType;
import com.ifeng.news2.sport_live.util.LoginAndRegistHelper;
import com.ifeng.news2.sport_live.util.SportLiveHttpListener;

import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

/**
 * 用户注册视图
 * 
 * @author SunQuan
 * 
 */
public class PromptUserCenterRegisterView extends PromptBaseView {

	private EditText userNameET;
	private EditText passWordET;
	private TextView message;
	private ImageView submit;


	public PromptUserCenterRegisterView(Context context, Bundle bundle) {
		super(context, bundle);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.sport_submit:
			regist();
			break;
		default:
			break;
		}
	}

	@Override
	protected void onCreate() {
		setContainer(R.layout.sport_live_usercenter_register);
		userNameET = (EditText) findViewById(R.id.userName_ET);
		passWordET = (EditText) findViewById(R.id.password_ET);
		submit = (ImageView) findViewById(R.id.sport_submit);
		message = (TextView) findViewById(R.id.messageTV);
		message.setVisibility(View.GONE);
	}

	@Override
	protected void setListener() {
		submit.setOnClickListener(this);
	}

	/**
	 * 检查输入的内容是否符合要求
	 * 
	 * @return
	 */
	private boolean checkInput() {
		boolean isValid = true;
		//检查输入的用户名或密码是否为空
		if (isEmptyInput(passWordET) || isEmptyInput(userNameET)) {
			message.setVisibility(View.VISIBLE);
			message.setText("用户名或密码不能为空");
			isValid = false;
		}
		//检查字数是否符合要求
		if (userNameET.getText().length() > 20
				|| userNameET.getText().length() < 2) {
			message.setVisibility(View.VISIBLE);
			message.setText("用户名不符合字数限制");
			isValid = false;
		}
		//检查是否有含有非法字符
		if(userNameET.getText().toString().replaceAll("[\u4e00-\u9fa5]*[a-z]*[A-Z]*\\d*-*_*\\s*", "").length()!=0){
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

	private void regist() {
		if (checkInput()) {
			User user = new User();
			user.setAction(ActionType.REGIST);
			user.setUsername(userNameET.getText().toString());
			user.setPassword(passWordET.getText().toString());
			LoginAndRegistHelper.create().execute(user,
					new SportLiveHttpListener<User>() {

						@Override
						public void success(User user) {
							dismissDialog();
							bundle.putString("MyUserName", user.getUsername());
							bundle.putString("MyPassWord", user.getPassword());
							message.setVisibility(View.VISIBLE);
							message.setText(user.getResultMessage());
							PromptViewManager.getInstance().changeView(
									PromptUserCenterLoginView.class,bundle);
						}

						@Override
						public void preLoad() {
							createDialog("注册中，请稍候", context);
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
