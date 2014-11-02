package com.qad.util;

import java.io.IOException;

public interface Sender {

	/**
	 * 
	 * @param url
	 * @param content
	 * @throws IOException
	 */
	void send(String url,String content) throws IOException;
	
	void send(String url) throws IOException;
}
