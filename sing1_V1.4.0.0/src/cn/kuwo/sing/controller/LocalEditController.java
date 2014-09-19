package cn.kuwo.sing.controller;

import java.io.IOException;
import java.util.Calendar;

import android.app.DatePickerDialog;
import android.app.Dialog;
import android.content.Context;
import android.os.AsyncTask;
import android.text.TextUtils;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Config;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.ui.activities.BaseActivity;

public class LocalEditController extends BaseController {
	private final String TAG = "LocalEditController";
	private BaseActivity mActivity;
	private final static int DATE_DIALOG = 0;
	private EditText et_local_username;
	private EditText et_local_home;
	private EditText et_local_live_place;
	private TextView tv_local_birthday;
	private Calendar c = null;
	private Button local_edit_back_btn;
	private Button local_edit_yes_btn;
	private int mYear, mMonth, mDay;

	public LocalEditController(BaseActivity activity) {
		KuwoLog.i(TAG, "LocalController");
		mActivity = activity;
		mYear = Calendar.getInstance().get(Calendar.YEAR);
		mMonth = Calendar.getInstance().get(Calendar.MONTH);
		mDay = Calendar.getInstance().get(Calendar.DAY_OF_MONTH);
		initView();
	}

	private void initView() {
		et_local_username = (EditText) mActivity
				.findViewById(R.id.et_local_username);
		et_local_username.setOnClickListener(mOnClickListener);
		et_local_home = (EditText) mActivity.findViewById(R.id.et_local_home);
		et_local_home.setOnClickListener(mOnClickListener);
		et_local_live_place = (EditText) mActivity
				.findViewById(R.id.et_local_live_place);
		et_local_live_place.setOnClickListener(mOnClickListener);
		tv_local_birthday = (TextView) mActivity
				.findViewById(R.id.tv_local_birthday);
		tv_local_birthday.setOnClickListener(mOnClickListener);
		if (Config.getPersistence().user != null) {
			et_local_username.setText(Config.getPersistence().user.nickname);
			et_local_home.setText(Config.getPersistence().user.birth_city);
			et_local_live_place
					.setText(Config.getPersistence().user.resident_city);
			tv_local_birthday.setText(Config.getPersistence().user.birthday);
		}

		local_edit_back_btn = (Button) mActivity
				.findViewById(R.id.local_edit_back_btn);
		local_edit_back_btn.setOnClickListener(mOnClickListener);
		local_edit_yes_btn = (Button) mActivity
				.findViewById(R.id.local_edit_yes_btn);
		local_edit_yes_btn.setOnClickListener(mOnClickListener);
	}

	/*
	 * 点击事件
	 */
	private View.OnClickListener mOnClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			int id = v.getId();
			KuwoLog.v(TAG, "onClick " + id);

			switch (id) {
			case R.id.tv_local_birthday:
				onCreateDialog(DATE_DIALOG).show();
				// 隐藏键盘
				InputMethodManager imm = (InputMethodManager) mActivity
						.getSystemService(Context.INPUT_METHOD_SERVICE);
				imm.hideSoftInputFromWindow(tv_local_birthday.getWindowToken(),
						0);
				break;
			case R.id.local_edit_back_btn:
				mActivity.setResult(Constants.LOCAL_EDITINFO_REQUEST);
				mActivity.finish();
				break;
			case R.id.local_edit_yes_btn:
				if (TextUtils.isEmpty(et_local_home.getText().toString())
						|| TextUtils.isEmpty(et_local_live_place.getText()
								.toString())) {
					Toast.makeText(mActivity, "相关信息不能为空", 0).show();
					break;
				}
				new EditDataAsyncTask().execute();
				break;
			}
		}
	};

	class EditDataAsyncTask extends AsyncTask<Void, Void, Boolean> {

		@Override
		protected void onPreExecute() {
			super.onPreExecute();
		}

		@Override
		protected Boolean doInBackground(Void... params) {
			UserLogic uselogic = new UserLogic();
			boolean result = false;
			try {
				result = uselogic.editMyData(et_local_username.getText() + "",
						et_local_home.getText() + "",
						et_local_live_place.getText() + "",
						tv_local_birthday.getText() + "");
			} catch (IOException e) {
				KuwoLog.printStackTrace(e);
			}
			return result;
		}

		@Override
		protected void onPostExecute(Boolean result) {

			if (result) {
				Toast.makeText(mActivity, "修改成功", 0).show();
				mActivity.setResult(Constants.RESULT_RELOAD_MY_HOME_BASEINFO);
				mActivity.finish();
			} else {
				Toast.makeText(mActivity, "修改失败", 0).show();
			}
			super.onPostExecute(result);
		}

	}

	protected Dialog onCreateDialog(int id) {
		Dialog dialog = null;
		switch (id) {
		case DATE_DIALOG:
			c = Calendar.getInstance();
			dialog = new DatePickerDialog(mActivity,
					new DatePickerDialog.OnDateSetListener() {

						@Override
						public void onDateSet(DatePicker view, int year,
								int monthOfYear, int dayOfMonth) {
							mYear = year;
							mMonth = monthOfYear;
							mDay = dayOfMonth;
							tv_local_birthday.setText(new StringBuilder()
									.append(mYear)
									.append("-")
									.append((mMonth + 1) < 10 ? "0" + (mMonth + 1) : (mMonth + 1))
									.append("-")
									.append((mDay < 10) ? "0" + mDay : mDay));
						}
					}, mYear, mMonth, mDay);
			break;

		default:
			break;
		}
		return dialog;
	}

}
