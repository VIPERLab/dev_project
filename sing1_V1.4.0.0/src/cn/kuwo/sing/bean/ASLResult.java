package cn.kuwo.sing.bean;

public class ASLResult {
    /**
     * 防盗链地址，全网络路径
     */
	public String url;
	/**
	 * 资源格式，如mp3, aac, wma等
	 */
	public String format;
	
	/**
	 * 资源比特率，如128, 48等
	 */
	public int bitrate;
	
	/**
	 * 资源的SIG，一般为资源文件的MD5串，可用于断点续传的控制
	 */
	public String sig;
}
