package com.ifeng.plutus.core.utils;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class CoderUtil {

	/**
	 * Encode a key to a unique string, note that if key1.equals(key2) then
	 * encode(key1) should <B>ALWAYS</B> equals to encode(key2)  
	 * @param key The key to encode
	 * @return The encoded result
	 */
	public static String encode(String key) {
		String coded;
		try {
			MessageDigest md = MessageDigest.getInstance("MD5");
			md.update(key.getBytes());
			coded = toHexString(md.digest());
		} catch (NoSuchAlgorithmException e) {
			coded = key;
		}
		return coded;
	}

	private static String toHexString(byte[] digest) {
		StringBuffer sb = new StringBuffer();
		for (byte b : digest)
			sb.append(Integer.toHexString((int) (b & 0xff)));
		return sb.toString();
	}
}
