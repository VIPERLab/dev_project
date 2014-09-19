package cn.kuwo.sing.logic.service;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.zip.DataFormatException;
import java.util.zip.Inflater;

import org.apache.commons.io.IOUtils;
import org.xmlpull.v1.XmlPullParser;

import android.util.Xml;
import cn.kuwo.framework.context.AppContext;
import cn.kuwo.framework.crypt.Base64Coder;
import cn.kuwo.framework.crypt.KuwoDES;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.network.BaseProvider;
import cn.kuwo.framework.network.HttpProvider;
import cn.kuwo.sing.bean.Kge;
import cn.kuwo.sing.context.Constants;

public class DefaultService implements NetworkService {

	private final String TAG = "DefaultService";
//	private final String KWREQ_URL_PREFIX = "http://60.28.201.181/ksong.s?f=kuwo&q=";	// 酷我后台接口的url前缀
	private final String KWREQ_URL_PREFIX = "http://ksingserver.kuwo.cn/ksong.s?f=kuwo&q=";	// 酷我后台接口的url前缀
//	private final String KWREQ_URL_PREFIX = "http://mobi.kuwo.cn/mobi.s?f=kuwo&q=";	// 酷我后台接口的url前缀
	public final byte[] SECRET_KEY = "hdljdkwm".getBytes();							// des密钥
	public final int SECRET_KEY_LENGTH = SECRET_KEY.length;
	
	@Override
	public int getLastError() {
		return mError;
	}

	volatile int mError = BaseProvider.SUCCESS;

	public int setLastError(int err) {
		int ret = mError;
		this.mError = err;
		return ret;
	}
	
	public void clearLastError() {
		this.mError = BaseProvider.SUCCESS;
	}
	
	@Override
	public void cancel() {
		
	}
	
	public CharSequence getUrl(String type, Map<String, String> params) {
		String q = getCommonParams(type, params).toString(); 
		KuwoLog.d(TAG, "url request: " + q);
		
		// 加密请求参数
        byte[] paramsBytes = q.getBytes();
        byte[] bytes = KuwoDES.encrypt(paramsBytes, paramsBytes.length, SECRET_KEY, SECRET_KEY_LENGTH);
        String b64Params = new String(Base64Coder.encode(bytes, bytes.length)); 
        b64Params = URLEncoder.encode(b64Params);
		
	    String url = KWREQ_URL_PREFIX + b64Params;
	    KuwoLog.d(TAG, "URL: "+ url);
	    return url;
	}
	
	public String read(String url) throws IOException{
		return read(url, "UTF-8");
	}

	public String read(String url, String encoding) throws IOException{
		try {
			return IOUtils.toString(new URL(url), encoding);
		} catch (Exception e) {
			KuwoLog.printStackTrace(e);
			throw new IOException();
		}
	}
	
	public byte[] readBytes(String url) throws IOException, URISyntaxException {
		return IOUtils.toByteArray(new URI(url));
	}
	
	public String post(String url, String data) {
		HttpProvider provider = new HttpProvider();
		ByteArrayInputStream is = new ByteArrayInputStream(data.getBytes());
		return provider.upload(url, is);
	}
	
	protected CharSequence getCommonParams(String type, Map<String, String> params) {
	    StringBuffer sb = new StringBuffer();
        sb.append("user=").append(AppContext.DEVICE_ID);
        sb.append("&prod=").append(Constants.APP_NAME).append("_ar_").append(AppContext.VERSION_NAME);
        sb.append("&source=").append(AppContext.INSTALL_SOURCE);
        sb.append("&type=").append(type);
        
        if (params != null) {
	        for(Entry<String, String> item : params.entrySet()) {
	        	sb.append("&");
	        	sb.append(item.getKey());
	        	sb.append("=");
	        	sb.append(item.getValue());
	        }
        }
        
        return sb;
	}
	
	public HashMap<String, String> splitParams(String data){
		return splitParams(data, "&");
	}
    
	public HashMap<String, String> splitParams(String data, String str) {
		HashMap<String, String> params = new HashMap<String, String>();
		String[] first = data.split(str);
		for(int i = 0; i < first.length; i++){
    		if(first[i]!=""){
    			String[] second =first[i].split("=");
    			if(second[0]!="") 
    				if(second.length == 1){
    				    params.put(second[0], "");
   				    }else{
   					    params.put(second[0], second[1]);
   				    }
    		}
    	}
		return params;
	}
	
    
//	{"result":"ok","leftFlower":1}
//	{"result":"err","msg":"no login"}
    
    public HashMap<String, String> sepFlowerResult(String str){
    	HashMap<String, String> params = new HashMap<String, String>();
    	try {
	    	int begin = str.indexOf("{");
	    	int end = str.indexOf("}");
	    	String newstr = str.substring(begin+1, end);  //"result":"ok","leftFlower":1
	    	
	    	String[] a = newstr.split(",");   //"result":"ok"
	    	
	    	for(int i = 0; i < a.length; i++){
	    		String[] b = a[i].split(":");
	    		b[0] = b[0].substring(1, b[0].length()-1);
	    		if(b[1].startsWith("\"")){
	    			b[1] = b[1].substring(1, b[1].length()-1);
	    		}
	    		else{
	    			b[1] = b[1].substring(0, b[1].length());
	    		}
	    		params.put(b[0], b[1]);
	    	}
    	} catch (Exception e) {
    		KuwoLog.printStackTrace(e);
    	}
    	return params;
    }
    
    
    public byte[] unzip(byte[] bytes, int start, int unzipLength) {
        Inflater decompresser = new Inflater();
        decompresser.setInput(bytes, start, bytes.length - start);
//        KuwoLog.d(TAG, "length : " + bytes.length + " start : " + start);
        
        byte[] retBytes = new byte[unzipLength];
        int resultLength = 0;
        try {
			resultLength = decompresser.inflate(retBytes);
		} catch (DataFormatException e) {
			KuwoLog.printStackTrace(e);
			retBytes = null;
			setLastError(BaseProvider.FAIL_IO_ERROR);
			return null;
		}
		
		KuwoLog.d(TAG, "resultLength : " + resultLength);
        decompresser.end();
        
        return retBytes;
    }

}
