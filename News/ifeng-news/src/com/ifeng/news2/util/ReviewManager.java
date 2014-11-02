package com.ifeng.news2.util;

import java.io.UnsupportedEncodingException;





public class ReviewManager {
	public static String actionIntroduction(String intro,String comment,int topicCount,int count){
		int needLength = 0;
		if (null ==comment || comment.length()==0) 
			needLength = count*2 - topicCount;
		else 
			needLength = count*2 - comment.length() - topicCount;
		
		String temp=intro.trim();
		if(temp.length()>needLength){
			temp = temp.substring(0, needLength-2)+"…";
		}
		return toDBC(temp);
	}

	/** 
	* @Title: toDBC 
	* @Description: TODO(将半角字符装换成全角字符) 
	* @param @param input
	* @param @return    String
	* @return String    String 
	* @throws 
	*/
	public static String toDBC(String input) {
		char[] c = input.toCharArray();
		for (int i = 0; i < c.length; i++) {
			/*if (c[i] == 32) {
				c[i] = 12288;
				continue;
			}*/
			if (c[i] == 8220 || c[i] == 8221) {//中文“”
				c[i] = 34;
			}
			if (c[i] == 65306) {
				c[i] = 58;
			}
			if (c[i] > 32 && c[i] < 127)
				c[i] = (char) (c[i] + 65248);
		}
		return new String(c);
	}
	 
	public static int dip2px(float dipValue, float scale) {
		return (int) (dipValue * scale + 0.5f);
	}
	public static int sp2px(float spValue, float fontScale) {
		return (int) (spValue * fontScale + 0.5f);
	}
	/**  
	 * 判断是否是一个中文汉字  
	 *   
	 * @param c  
	 *            字符  
	 * @return true表示是中文汉字，false表示是英文字母  
	 * @throws UnsupportedEncodingException  
	 *             使用了JAVA不支持的编码格式  
	 */  
	public static boolean isChineseChar(char c){   
		// 如果字节数大于1，是汉字   
		// 以这种方式区别英文字母和中文汉字并不是十分严谨，但在这个题目中，这样判断已经足够了   
		try {
			return String.valueOf(c).getBytes("GBK").length > 1;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}   
	}   

	/**  
	 * 按字节截取字符串  
	 *   
	 * @param orignal  
	 *            原始字符串  
	 * @param count  
	 *            截取位数  
	 * @return 截取后的字符串  
	 * @throws UnsupportedEncodingException  
	 *             使用了JAVA不支持的编码格式  
	 */  
	public static String substring(String orignal, int count) {   
		// 原始字符不为null，也不是空字符串   
		if (null != orignal && !"".equals(orignal)) {   
			// 将原始字符串转换为GBK编码格式   
			try {
				orignal = new String(orignal.getBytes("GBK"), "GBK");
				if (count > 0 && count < orignal.getBytes("GBK").length) {   
					StringBuffer buff = new StringBuffer();   
					char c;   
					for (int i = 0; i < count; i++) {   
						// charAt(int index)也是按照字符来分解字符串的   
						c = orignal.charAt(i);   
						buff.append(c);   
						if (isChineseChar(c)) {   
							// 遇到中文汉字，截取字节总数减2
							count -= 2;   // 一般汉字在utf-8中为3个字节长度
						}   
					}   
					return buff.toString();   
				}   
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}   
			// 要截取的字节数大于0，且小于原始字符串的字节数   
		}   
		return orignal;   
	}

}
