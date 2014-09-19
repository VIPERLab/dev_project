package cn.kuwo.sing.logic.service;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;

import org.apache.http.util.ByteArrayBuffer;

import cn.kuwo.framework.log.KuwoLog;

public class CommonSocket {

	private static final String TAG = "CommonSocket";
	private Socket mSocket;
	private OutputStream os;
	private InputStream is;
	private RecieveRunnable mRecieveRunnable;
	private String mIp;
	private int mPort;
	
	public void connect(String ip, int port) {
		try {
			mSocket = new Socket(ip, port);  
			os = mSocket.getOutputStream();
			is = mSocket.getInputStream();
		} catch (Exception e) {
			onError(e);
			return;
		}
		
		this.mIp = ip;
		this.mPort = port;
		KuwoLog.d(TAG, "CONNECT IP:"+ip + "      Port:"+port);
		
		mRecieveRunnable = new RecieveRunnable();
		new Thread(mRecieveRunnable, "socket recieve").start();
	}
	
	protected void checkConnect() {
		if (!mSocket.isConnected()) {
			connect(mIp, mPort);
			KuwoLog.w(TAG, "Reconnect live socket");
		}
	}
	
	public void send(String str) {
		checkConnect();
		
		try {
			byte[] buffer = str.getBytes("GBK");
			os.write(buffer);
			os.flush();
		} catch (Exception e) {
			try {
				mSocket.close();
				connect(mIp, mPort);
			} catch (IOException e1) {
				e1.printStackTrace();
			}
			
			onError(e);
			
		}
	}
	
	public void close() {
		try {
			if (os!=null)
				os.close();
			if (is != null)
				is.close();
			if (mSocket != null)
				mSocket.close();
		} catch (Exception e) {
			onError(e);
		}
		if (mRecieveRunnable != null)
			mRecieveRunnable.stop();
	}
	
	// 
	public interface OnDataRecieveListener {
		void onDataRecieve(String data);
	}
	private OnDataRecieveListener mOnDataRecieveListener;
	public void setOnDataRecieveListener(OnDataRecieveListener l) {
		mOnDataRecieveListener = l;
	}
	protected void onDataRecieve(String data) {
		KuwoLog.v(TAG, data);
		
		if (mOnDataRecieveListener != null)
			mOnDataRecieveListener.onDataRecieve(data);
	}
	
	// 
	public interface OnErrorListener {
		void onError(Exception e);
	}
	private OnErrorListener mOnErrorListener;
	public void setOnErrorListener(OnErrorListener l) {
		mOnErrorListener = l;
	}
	protected void onError(Exception e) {
		KuwoLog.printStackTrace(e);
		
		if (mOnErrorListener != null)
			mOnErrorListener.onError(e);
	}
	
	private class RecieveRunnable implements Runnable {
		
		private boolean loop = true;
		
		public void stop() {
			loop = false;
		}
		
		@Override
		public void run() {
			KuwoLog.d(TAG, "RecieveRunnable is running");
			try {
				ByteArrayBuffer buffer = new ByteArrayBuffer(1000);
				while (loop) {
					byte data = (byte) is.read();
					KuwoLog.v(TAG, "recieve data :"+data );
					if (data == -1) {
						try {
							Thread.sleep(1000);
						} catch (InterruptedException e) {
							KuwoLog.printStackTrace(e);
						}
						continue;
					}
					
					buffer.append(data);
					
					if (data == '\r') {
						// \n
						data = (byte) is.read();
						buffer.append(data);
						
						String str = new String(buffer.toByteArray(), "GBK");
						buffer.clear();
						onDataRecieve(str);
					}
				}
				
			} catch (Exception e) {
				onError(e);
			}
		}
	};

}
