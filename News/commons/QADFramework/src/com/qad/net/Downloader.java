package com.qad.net;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.http.HttpResponse;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import com.qad.lang.Files;
import com.qad.lang.Streams;

public class Downloader {

	/**
	 * 通知下载完成情况
	 * 
	 * @author 13leaf
	 * 
	 */
	public interface PublishCallBack {
		/**
		 * @param downSize
		 *            已下载字节大小
		 * @param fullSize
		 *            总下载字节大小
		 * @param percent
		 *            下载百分比。公式如下
		 *            Math.floor(downSize/fullSize*100)。注意不是百分比例,如返回50,则表示完成百分之50
		 * @return 返回false表示继续下载,若返回true将终止下载            
		 */
		boolean publish(long downSize, long fullSize, int percent);
		
		void complete();
		
		void fail();
	}

	public final static int DEFAULT_BLOCK_SIZE = 7*1024;

	protected static final int UPGRADE = 0;

	protected static final int COMPLETE = 1;

	protected static final int FAIL = 2;
	
	public static Handler handler = new Handler(Looper.getMainLooper()){
		public void handleMessage(android.os.Message msg) {
			if(msg.what==UPGRADE){
				PublishCallBack publisher = (PublishCallBack) msg.obj;
				Bundle bundle = msg.getData();
				publisher.publish(bundle.getLong("downSize"), bundle.getLong("fullSize"), bundle.getInt("percent"));
			}
			else if(msg.what==COMPLETE){
				PublishCallBack publisher = (PublishCallBack) msg.obj;
				publisher.complete();
			}
			else if(msg.what==FAIL){
				PublishCallBack publisher = (PublishCallBack) msg.obj;
				publisher.fail();
			}
		};
	};

	/**
	 * 下载器的完整版本。<strong>注意,断点续传需要服务器的range支持。目前客户端也并未真正实现range支持！！！请勿开启resume</strong>
	 * @param url 下载url地址
	 * @param targetPath 下载本地绝对路径
	 * @param blockSize 下载的缓冲区大小
	 * @param resume 是否开启断点续传模式。目前的skip实现事实上并不是range支持的,android上的Http连接似乎也是不支持skip的。
	 * @param publisher 下载器的回调通知接受者，如果不需要通知则传入null
	 * @throws IOException 当下载器发生http错误时，将会抛出异常
	 * @return 是否最终下载成功。如果在publisher中控制中断了任务，将返回false
	 */
	public static void downLoad(final String url, final String targetPath, final int blockSize,final boolean resume,
			final PublishCallBack publisher){
		new Thread(){
			public void run() {
				
				
				OutputStream targetOutputStream = null;
				BufferedInputStream is=null;
				
				try {
					File target = new File(targetPath);
					Files.createNewFile(target);//ensure file exists
					HttpResponse response = HttpManager.executeHttpGet(url);
					
					is=new BufferedInputStream(response.getEntity().getContent(), blockSize);
					if(resume){
						targetOutputStream=new FileOutputStream(target,true);
					}
					else {
						targetOutputStream=new FileOutputStream(target);
					}
					
					byte[] block = new byte[blockSize];
					long downSize = resume?target.length():0;
					long fullSize = response.getEntity().getContentLength();
					
					int count=-1;
					if(resume)
					{
						is.skip(downSize);
					}
					while ((count = is.read(block)) != -1) {
						// write block and publish task
						targetOutputStream.write(block, 0, count);
						downSize += count;
						if (publisher != null) {
							Message msg = new Message();
							msg.what = UPGRADE;
							msg.obj = publisher;
							Bundle bundle = new Bundle();
							bundle.putLong("downSize", downSize);
							bundle.putLong("fullSize", fullSize);
							bundle.putInt("percent", (int) (Math
									.floor(downSize / (double) fullSize * 100)));
							msg.setData(bundle);
							handler.sendMessage(msg);													
						}
					}
					if(publisher != null) {
						Message msg = new Message();
						msg.what = COMPLETE;
						msg.obj = publisher;
						handler.sendMessage(msg);		
					}

				} catch (IOException e) {
					if(publisher != null) {
						Message msg = new Message();
						msg.what = FAIL;
						msg.obj = publisher;
						handler.sendMessage(msg);		
					}
				} finally {
					Streams.safeClose(targetOutputStream);
					Streams.safeClose(is);
				}
		};}.start();
		
	}
	
	public static void downLoad(String url, String targetPath, int blockSize,
			PublishCallBack publisher) throws IOException {
		 downLoad(url, targetPath, blockSize, false, publisher);
	}
	
	public static void downLoad(String url, String targetPath)
			throws IOException {
		 downLoad(url, targetPath, DEFAULT_BLOCK_SIZE, null);
	}
}
