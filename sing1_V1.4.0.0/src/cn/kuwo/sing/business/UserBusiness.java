package cn.kuwo.sing.business;

import java.io.IOException;
import android.content.Context;
import android.content.Intent;
import cn.kuwo.sing.logic.UserLogic;
import cn.kuwo.sing.ui.activities.ThirdPartyLoginActivity;

public class UserBusiness {
	private final String TAG = "UserBusiness";
	private Context mContext;
	
	public UserBusiness(Context context) {
		this.mContext = context;
	}
	
	/**
	 * 用户登录
	 * @param uname 用户名
     * @param pwd 密码
	 * @throws IOException 
	 */

	public void login( final String mUname, final String mPwd, final LisCallback lisCallback) throws IOException{
		
		new Thread() {
			public void run() {
				int result;
				try {
					UserLogic userlogic = new UserLogic();
					result = userlogic.login(mUname,mPwd);
					lisCallback.login(result);

				} catch (IOException e) {
					e.printStackTrace();
				}
			};
		}.start();

	}
	
	public interface LisCallback {
		public void login(int result);
	}
    
	/**
	 * 第三方登录
	 */
	public void loginThirdParty(String type) {
		Intent intent = new Intent(mContext, ThirdPartyLoginActivity.class);
		intent.putExtra("type", type);
		mContext.startActivity(intent);
	}
	
	public void entryGame(String title, String url) {
//		Intent intent = new Intent(mContext, CommonActivity.class);
//		intent.putExtra("title", title);
//		intent.putExtra("url", url);
//		mContext.startActivity(intent);
	}
	
}
