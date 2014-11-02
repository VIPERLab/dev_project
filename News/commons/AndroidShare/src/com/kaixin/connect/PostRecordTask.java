/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.kaixin.connect;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import com.kaixin.connect.exception.KaixinError;

public class PostRecordTask extends AsyncTask<Object, Void, Integer> {
	private static final String TAG = "PostRecordTask";
	private static final String RESTAPI_INTERFACE_POSTRECORD = "/records/add.json";
	private Handler handler;

	@SuppressWarnings("unchecked")
	protected Integer doInBackground(Object... params) {
		if (params == null || params.length == 0 || params.length != 5) {
			handler.sendEmptyMessage(Constant.RESULT_FAILED_ARG_ERR);
			return 0;
		}

		Kaixin kaixin = (Kaixin) params[0];
		handler = (Handler) params[1];
		String content = (String) params[2];
		InputStream in = (InputStream) params[3];
		Context context = (Context) params[4];

		try {
			// 写新记录
			Bundle bundle = new Bundle();
			bundle.putString("content", content);
			
			Map<String, Object> photoes = new HashMap<String, Object>();
			photoes.put("filename", in);
			
			String jsonResult = kaixin.uploadContent(context,
					RESTAPI_INTERFACE_POSTRECORD, bundle, photoes);

			if (jsonResult == null) {
				handler.sendEmptyMessage(Constant.RESULT_FAILED_NETWORK_ERR);
			} else {
				KaixinError kaixinError = Util.parseRequestError(jsonResult);
				if (kaixinError != null) {
					Message msg = Message.obtain();
					msg.what = Constant.RESULT_FAILED_REQUEST_ERR;
					msg.obj = kaixinError;
					handler.sendMessage(msg);
				} else {
					long rid = getRecordID(jsonResult);
					if (rid > 0) {
						handler
								.sendEmptyMessage(Constant.RESULT_POST_RECORD_OK);
					} else {
						handler
								.sendEmptyMessage(Constant.RESULT_POST_RECORD_FAILED);
					}
				}
			}
		} catch (MalformedURLException e1) {
			Log.e(TAG, "", e1);
			handler.sendEmptyMessage(Constant.RESULT_FAILED_MALFORMEDURL_ERR);
		} catch (IOException e1) {
			Log.e(TAG, "", e1);
			handler.sendEmptyMessage(Constant.RESULT_FAILED_NETWORK_ERR);
		} catch (Exception e1) {
			Log.e(TAG, "", e1);
			handler.sendEmptyMessage(Constant.RESULT_FAILED);
		}
		return 1;
	}

	private long getRecordID(String jsonResult) throws JSONException {
		JSONObject jsonObj = new JSONObject(jsonResult);
		if (jsonObj == null) {
			return 0;
		}

		long rid = jsonObj.optInt("rid");
		return rid;
	}

	protected void onPostExecute(Integer result) {
	}
}
