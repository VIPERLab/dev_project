package cn.kuwo.sing.controller;

import android.view.View;
import android.widget.Button;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.ui.activities.BaseActivity;

/**
 * 关于页面控制层
 */
public class AboutController extends BaseController {

	private final String TAG = "AboutController";

	private BaseActivity mActivity;

	public AboutController(BaseActivity activity) {

		KuwoLog.v(TAG, "AboutController()");

		mActivity = activity;

		initView();
	}

	/**
	 * 初始化控件
	 * 
	 * @param activity
	 */
	private void initView() {

		Button btnBack = (Button) mActivity.findViewById(R.id.about_back_btn);
		btnBack.setOnClickListener(mClickListener);
	}

	/*
	 * 点击事件
	 */
	private View.OnClickListener mClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			int id = v.getId();
			KuwoLog.v(TAG, "onClick " + id);

			switch (id) {
			case R.id.about_back_btn:// 返回按钮
				mActivity.finish();
				break;
			}
		}
	};

}
