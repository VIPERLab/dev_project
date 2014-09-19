package cn.kuwo.sing.controller;

import android.view.View;
import android.widget.Button;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.ui.activities.BaseActivity;

/**
 * 修改资料页面控制层
 * 
 * @author wangming
 * 
 */
public class ModifyController extends BaseController {

	private final String TAG = "ModifyController";

	private BaseActivity mActivity;

	public ModifyController(BaseActivity activity) {

		KuwoLog.v(TAG, "ModifyController()");

		mActivity = activity;

		initView();
	}

	/**
	 * 初始化控件
	 * 
	 * @param activity
	 */
	private void initView() {

		Button modify_back_btn = (Button) mActivity
				.findViewById(R.id.modify_back_btn);
		modify_back_btn.setOnClickListener(mClickListener);

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
			case R.id.modify_back_btn: // 返回按钮
				mActivity.finish();
				break;
			}
		}
	};

}
