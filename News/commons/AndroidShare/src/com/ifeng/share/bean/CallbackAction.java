package com.ifeng.share.bean;

import android.content.Context;
import android.widget.Toast;
/**
 * 绑定回调
 * @author PJW
 *
 */
public class CallbackAction implements CallbackInterface{

	@Override
	public void bindSuccess(Context context) {
		// TODO Auto-generated method stub
		showMessage(context,"授权成功");
	}

	@Override
	public void bindFailure(Context context) {
		// TODO Auto-generated method stub
		showMessage(context,"授权失败");
	}

	@Override
	public void unbindSuccess(Context context) {
		// TODO Auto-generated method stub
		showMessage(context,"解绑定成功");
	}

	@Override
	public void unbindFailure(Context context) {
		// TODO Auto-generated method stub
		showMessage(context,"解绑定失败");
	}
	private void showMessage(Context context,String message){
		Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
	}
}
