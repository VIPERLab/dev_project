package cn.kuwo.base.codec;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.ShortBuffer;

/**
 * AAC解码器
 * @author yangzc
 */
public class NativeAACDecoder implements Decoder{
	private static final String TAG = NativeAACDecoder.class.getSimpleName();

	//文件句柄
	private int handle = -1;
	private FloatBuffer floatBuffer;
	
	static {
		System.loadLibrary("kwaac");
	} 
		
	/**
	 * 加载文件
	 */
	public int load(String file) {
		handle = openFile(file);
		return handle;
	}
	
	/**
	 * 取得声道数
	 */
	public int getChannelNum() {
		if (handle != -1)
			return getChannelNum(handle);
		else {
			return 0;
		}
	}	
	
	
	/**
	 * 取得比特率
	 */
	public int getBitrate() {
		return getBitrate(handle);
	}

	/**
	 * 取得抽样率
	 */
	public int getSamplerate() {
		return getSamplerate(handle);
	}

	/**
	 * 取得总时长
	 */
	public int getDuration() {
		if (handle != -1) {
			return getDuration(handle);
		} else {
			return 0;
		}
	}

	/**
	 * 获得当前位置
	 */
	public int getCurrentPosition() {
		if (handle != -1) {
			return getCurrentPosition(handle);
		} else {
			return 0;
		}
	}
	
	/**
	 * 定位到
	 */
	public void seekTo(int msec) {
		if (handle != -1) {
			seekTo(handle, msec);
		}
	}

	/**
	 * 取得每帧的抽样率
	 */
	public int getSamplePerFrame() {
		return getSamplePerFrame(handle);
	}

	/**
	 * 释放资源
	 */
	public void release() {
		if (handle != -1) {
			closeFile(handle);
			handle = -1;
		}
	}

	/**
	 * 确定资源是否被释放
	 */
	public boolean isReleased() {
		return handle == -1;
	}

	public int downsampling(String outputFile) {
		if (handle != -1) {
			return downsampling(handle, outputFile);
		}
		return 0;
	}

	/**
	 * 取得文件句柄
	 * @return
	 */
	public int getHandle() {
		return handle;
	}

	public int readSamples(float[] samples) {
		if (floatBuffer == null || floatBuffer.capacity() != samples.length) {
			ByteBuffer byteBuffer = ByteBuffer.allocateDirect(samples.length * Float.SIZE / 8);
			byteBuffer.order(ByteOrder.nativeOrder());
			floatBuffer = byteBuffer.asFloatBuffer();
		}

		int readSamples = readSamples(handle, floatBuffer, samples.length);
		if (readSamples == 0) {
			closeFile(handle);
			return 0;
		}

		floatBuffer.position(0);
		floatBuffer.get(samples);

		return samples.length;
	}


	public int readSamples(short[] samples) {
		if (handle != -1) {
			int len = readSamples(handle, samples, samples.length);
			return len;
		} else {
			return 0;
		}
	}
	
	/**
	 * 是否播放完成
	 */
	public boolean isFinished() {
	    if (isReleased()) {
            return true;
        }
        
        if (isReadFinished(handle) == 1) {
            return true;
        }
        
        return getCurrentPosition()/1000 == getDuration();  
	}

	/**
	 * 取得文件格式
	 */
	static String[] aac_formats = {"aac", "m4a", "m4b", "mp4"};
    @Override
    public String[] getFormats() {       
        return aac_formats;
    }
    
    public static int getValidFramePosition(String file) {
        return native_get_valid_frame_position(file);
    }
	
	private static native int native_get_valid_frame_position(String file);
	private native int openFile(String file);
	private native int isReadFinished(int handle);
	private native int getChannelNum(int handle);
	private native int getBitrate(int handle);
	private native int getSamplerate(int handle);
	private native int getDuration(int handle);
	private native int getCurrentPosition(int handle);	
	private native int seekTo(int handle, int msec);
	private native int getSamplePerFrame(int handle);
	public native int readSamples(int handle, ShortBuffer buffer, int numSamples);
	public native int readSamples(int handle, short[] buffer, int numSamples);
	public native int readSamples(int handle, FloatBuffer buffer, int numSamples);
	private native void closeFile(int handle);
	private native int downsampling(int handle, String file);
}
