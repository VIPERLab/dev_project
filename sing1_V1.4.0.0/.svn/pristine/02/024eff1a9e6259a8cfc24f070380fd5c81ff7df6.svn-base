/**
 * Copyright (c) 2012 Eleven Inc. All Rights Reserved.
 */
package cn.kuwo.sing.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * @File MD5Encoder.java
 * 
 * @Author wangming1988
 * 
 * @Date Sep 10, 2012, 12:19:40 AM
 * 
 * @Version v0.1
 * 
 * @Description MD5 encode
 *
 */

public class MD5Encoder {
	public static String encode(String desStr){
		try {
			MessageDigest digest = MessageDigest.getInstance("MD5");
			byte[] result = digest.digest(desStr.getBytes());
			StringBuilder sb = new StringBuilder();
			for(int i= 0 ;i<result.length;i++){
				int number = result[i]&0xff;//add salt
				String str = Integer.toHexString(number);
				if(str.length()==1){
					sb.append("0");
					sb.append(str);
				}else{
					sb.append(str);
				}
			}
			return sb.toString();
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
			return "";
		}
	}
}
