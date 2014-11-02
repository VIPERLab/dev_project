package com.ifeng.news2.util;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import com.ifeng.news2.bean.Extension;

/**
 * @author liu_xiaoliang
 * 序列化 & 反序列化 工具
 */
public class SerializableUtil {
	
	public static byte[] serialize(ArrayList<Extension> links){ 
		byte[] bytes = null;
		ObjectOutputStream out = null;
		ByteArrayOutputStream mem_out = null;
		try { 
			mem_out = new ByteArrayOutputStream(); 
			out = new ObjectOutputStream(mem_out); 
			out.writeObject(links); 
			bytes =  mem_out.toByteArray(); 
		} catch (IOException e) { 
		} finally {
			try {
				if (null != mem_out) 
					mem_out.close(); 
				if (null != out) 
					out.close(); 
			} catch (Exception e) {
			}
		}
		return bytes; 
	} 

	@SuppressWarnings("unchecked")
	public static ArrayList<Extension> deserialize(byte[] bytes){ 
		ObjectInputStream in = null;
		ArrayList<Extension> links = null;
		ByteArrayInputStream mem_in = null;
		try { 
			mem_in = new ByteArrayInputStream(bytes); 
			in = new ObjectInputStream(mem_in); 
			links = (ArrayList<Extension>)in.readObject(); 
		} catch (Exception e) { 
		} finally {
			try {
				if (null != in) 
					in.close(); 
				if (null != mem_in) 
					mem_in.close(); 
			} catch (Exception e) {
			}
		}
		return links; 
	} 
} 


