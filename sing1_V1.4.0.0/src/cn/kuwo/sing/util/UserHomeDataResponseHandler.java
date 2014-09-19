/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.util;

import cn.kuwo.sing.bean.UserHomeData;

import com.loopj.android.http.AsyncHttpResponseHandler;

/**
 * @Package cn.kuwo.sing.util
 *
 * @Date 2013-12-25, 上午10:47:39
 *
 * @Author wangming
 *
 */
public abstract class UserHomeDataResponseHandler extends AsyncHttpResponseHandler {
	public abstract void onSuccess(UserHomeData data);
		
	
	public void onFailure(String errorStr){
		
	}
}
