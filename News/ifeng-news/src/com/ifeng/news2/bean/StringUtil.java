package com.ifeng.news2.bean;

import com.ifeng.news2.util.IfengTextViewManager;

import android.text.TextUtils;

public class StringUtil {

	/**
	 * @param str  源字符串
	 * @param length 限制的长度
	 * @return 返回处理过的字符串
	 */
	public static String getStr(String str, int length) {
		if (TextUtils.isEmpty(str)) {
			str = "";
		}
		int titleLength = str.length();
		if (titleLength < length) {
			return str;
		}
		float count = 0;
		int i = 0;
		for (; i < titleLength; i++) {
			if (count >= length) 
				break;
			char temp = str.charAt(i);
			if (!IfengTextViewManager.isChineseCharacter(temp)){
				count += 0.5;
				continue;
			}			
			count ++;
		}		
		str = str.substring(0,i);
		return str;
	}
	
	public static boolean isAsciiAlpha(final char ch) {
		return (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z');
	}
	
	public static boolean isAsciiNumeric(final char ch) {
		return ch >= '0' && ch <= '9';
	}
}
