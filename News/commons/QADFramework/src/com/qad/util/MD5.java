package com.qad.util;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class MD5 {
	/**
	 * 16位MD5加密
	 * 
	 * @param plainText
	 * @return
	 */
	public static String md5s(String plainText) {
		String str = "";
		try {
			MessageDigest md = MessageDigest.getInstance("MD5");
			md.update(plainText.getBytes());
			byte b[] = md.digest();

			int i;

			StringBuffer buf = new StringBuffer("");
			for (int offset = 0; offset < b.length; offset++) {
				i = b[offset];
				if (i < 0) {
					i += 256;
				}
				if (i < 16) {
					buf.append("0");
				}
				buf.append(Integer.toHexString(i));
			}
			str = buf.toString().substring(8, 24);
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();

		}
		return str;
	}

	/*
	 * 返回32位大写的MD5码
	 */
	public static String getEncoderByMd5(String sessionid)
			throws NoSuchAlgorithmException, UnsupportedEncodingException {

		StringBuffer hexString = null;
		byte[] defaultBytes = sessionid.getBytes();
		try {
			MessageDigest algorithm = MessageDigest.getInstance("MD5");
			algorithm.reset();
			algorithm.update(defaultBytes);
			byte messageDigest[] = algorithm.digest();

			hexString = new StringBuffer();
			for (int i = 0; i < messageDigest.length; i++) {
				if (Integer.toHexString(0xFF & messageDigest[i]).length() == 1) {
					hexString.append(0);
				}
				hexString.append(Integer.toHexString(0xFF & messageDigest[i]));
			}
			messageDigest.toString();
			sessionid = hexString + "";
		} catch (NoSuchAlgorithmException nsae) {

		}
		System.out.println(hexString.toString().toUpperCase());
		return hexString.toString().toUpperCase();

	}

}
