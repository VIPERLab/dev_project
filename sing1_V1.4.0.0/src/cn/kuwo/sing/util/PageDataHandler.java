package cn.kuwo.sing.util;

import java.util.List;

import com.loopj.android.http.AsyncHttpResponseHandler;

import cn.kuwo.sing.bean.PageData;


public abstract class PageDataHandler<T> extends AsyncHttpResponseHandler{
	
	public abstract void onSuccess(List<T> data);
		
	
	public void onFailure( ){
		
	}
}
