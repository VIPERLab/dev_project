package com.ifeng.news2.exception;

import java.io.IOException;
import java.net.HttpURLConnection;

public interface IHandleHttpData {
	
	public void handleHttpData(HttpURLConnection urlconn)throws IOException;
		
}
