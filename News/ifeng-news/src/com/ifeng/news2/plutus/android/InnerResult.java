package com.ifeng.news2.plutus.android;

import com.ifeng.news2.plutus.android.PlutusAndroidManager.PlutusAndroidListener;
import com.ifeng.news2.plutus.core.Constants.ERROR;

public class InnerResult<T> {
	
		private PlutusAndroidListener<T> listener = null;
		private ERROR error = null;
		private T result = null;
		
		public InnerResult() {
		}

		public void setResult(T result) {
			this.result = result;
		}
		
		public T getResult() {
			return result;
		}

		public ERROR getError() {
			return error;
		}

		public void setError(ERROR error) {
			this.error = error;
		}

		public PlutusAndroidListener<T> getListener() {
			return listener;
		}

		public void setListener(PlutusAndroidListener<T> listener) {
			this.listener = listener;
		}
}
