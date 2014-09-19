package cn.kuwo.sing.ui.activities;

import cn.kuwo.sing.R;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.controller.ShareController;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

public class ShareActivity extends BaseActivity {
	private final String TAG = "ShareActivity";
	private ShareController mShareController;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.share_layout);
		mShareController = new ShareController(this);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case Constants.SHARE_BOUND_REQUEST:
			if(data != null) {
				String resultFlag = data.getStringExtra("resultFlag");
				if(resultCode == Constants.SHARE_BOUND_SUCCESS_RESULT) {
					if(resultFlag.equals("weibo")) {
						mShareController.setWeiboChecked();
					}else if(resultFlag.equals("qq")) {
						mShareController.setQQChecked();
					}else if(resultFlag.equals("renren")) {
						mShareController.setRenrenChecked();
					}
				}else if(resultCode == Constants.LOGIN_FAIL_RESULT) {
					Toast.makeText(this, "绑定失败"+resultFlag, 0).show();
				}
			}
			break;
		default:
			break;
		}
	}
	
}
