package com.ifeng.news2.util;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.SocketException;

import com.qad.net.HttpManager;

public class HttpUtil {

	public static String load(String Url) {
		InputStream in = null;
		BufferedReader reader = null;
		StringBuffer sb = new StringBuffer();
		try {
			in = HttpManager.getInputStream(Url.replace("&amp;", "&"));
			reader = new BufferedReader(new InputStreamReader(in));
			while (true) {
				String string = reader.readLine();
				if (string == null)
					break;
				sb.append(string);
			}
		} catch (SocketException e) {
			sb = new StringBuffer("");
		} catch (Exception e) {
			sb = new StringBuffer("");
		} finally {
			if (reader != null)
				try {
					reader.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			if (in != null)
				try {
					in.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
		}
		return sb.toString().equals("") ? null : sb.toString();
	}

	public static String loadCoverInfo(String Url) {
		InputStream in = null;
		BufferedReader reader = null;
		StringBuffer sb = new StringBuffer();
		try {
			in = HttpManager.getInputStream(Url.replace("&amp;", "&"));
			reader = new BufferedReader(new InputStreamReader(in));
			while (true) {
				String string = reader.readLine();
				if (string == null)
					break;
				sb.append(string);
			}
		} catch (Exception e) {
			return null;
		} finally {
			if (reader != null)
				try {
					reader.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			if (in != null)
				try {
					in.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
		}
		return sb.toString().equals("") ? null : sb.toString();
	}
	
	public static byte[] loadImage(String Url) {
		InputStream in = null;
		ByteArrayOutputStream os = null;
		byte[] result = null;
		try {
			os = new ByteArrayOutputStream();
			in = HttpManager.getInputStream(Url.replace("&amp;", "&"));
			byte[] buffer = new byte[1024];
			int count = -1;
			while ((count = in.read(buffer)) > 0) {
				os.write(buffer, 0, count);
			}
			os.flush();
			result = os.toByteArray();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (os != null)
				try {
					os.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			if (in != null)
				try {
					in.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
		}
		return result;
	}
}
