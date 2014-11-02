package com.qad.net;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import android.os.AsyncTask;
import com.qad.net.HttpManager;

/**
 * http的get请求类,无返回结果,在向服务器发送请求但是不获取数据的时候调用该类
 * 
 * @author Administrator
 * 
 */
public class HttpExecuter {

	private static HttpExecuter httpExecuter = null;

	private HttpExecuter() {
	}

	public synchronized static HttpExecuter create() {
		if (httpExecuter == null) {
			httpExecuter = new HttpExecuter();
		}
		return httpExecuter;
	}

	/**
	 * http的get请求，无返回结果
	 * 
	 * @param parameter
	 * @param callBack
	 */
	public void httpGet(String parameter, HttpGetListener callBack) {
		get(parameter, callBack);
	}

	/**
	 * http的get请求，无返回结果，无回调入口
	 * 
	 * @param parameter
	 */
	public void httpGet(String parameter) {
		get(parameter, null);
	}

	private void get(String parameter, HttpGetListener callBack) {
		if (callBack == null) {
			new HttpTask().execute(parameter);
		} else {
			new HttpTask(callBack).execute(parameter);
		}
	}

	static class HttpTask extends AsyncTask<String, Integer, Boolean> {
		private HttpGetListener callBack;

		public HttpTask(HttpGetListener callBack) {
			this.callBack = callBack;
		}

		public HttpTask() {
		}

		@Override
		protected void onPreExecute() {
			if (callBack != null) {
				callBack.preLoad();
			}
			super.onPreExecute();
		}

		@Override
		protected Boolean doInBackground(String... params) {
			boolean success = false;
			try {
				HttpResponse res = HttpManager.executeHttpGet(params[0]);
				if (res != null
						&& res.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
					success = true;
				}
			} catch (Exception e) {
				success = false;
			}
			return success;
		}

		@Override
		protected void onPostExecute(Boolean success) {
			if (success) {
				if (callBack != null)
					callBack.loadHttpSuccess();
			} else {
				if (callBack != null)
					callBack.loadHttpFail();
			}
			super.onPostExecute(success);
		}
	}

}
