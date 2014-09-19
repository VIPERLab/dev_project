package cn.kuwo.sing.logic.service;

import java.io.IOException;
import java.net.URLEncoder;

import cn.kuwo.framework.crypt.Base64Coder;
import cn.kuwo.framework.crypt.KuwoDES;
import cn.kuwo.framework.log.KuwoLog;

public class ConfigureService extends DefaultService{
	
	private final String TAG = "ConfigureService";
	private final String KWREQ_URL_PREFIX = "http://changba.kuwo.cn/ksong.s?f=kuwo&q=";	// 酷我后台接口的url前缀
	
	public String getUrl() throws IOException{
		
//		String q = "user= 1234567890abcdef&prod=kwsing_ip_1.0.0.0&source=kwsing_ip_1.0.0.0_kw.ipa&type=getconfig";
//		// 加密请求参数
//        byte[] paramsBytes = q.getBytes();
//        byte[] bytes = KuwoDES.encrypt(paramsBytes, paramsBytes.length, SECRET_KEY, SECRET_KEY_LENGTH);
//        String b64Params = new String(Base64Coder.encode(bytes, bytes.length)); 
//        b64Params = URLEncoder.encode(b64Params);
		
        String url = getUrl("getconfig",null).toString();
	 
	    
	    
	    KuwoLog.i(TAG, "encrypt url: " + url);
	    
	    String str = read(url, "UTF-8");
	    
	    str = str+"23";
	    KuwoLog.i(TAG, "encrypt url: " + str);
	    
	    return str;
	}

}
