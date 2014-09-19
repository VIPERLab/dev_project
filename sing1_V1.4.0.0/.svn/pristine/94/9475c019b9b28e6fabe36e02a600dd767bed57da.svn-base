package cn.kuwo.base.codec;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.ShortBuffer;

public class NativeMP3Decoder implements Decoder {
    private static final String TAG = NativeMP3Decoder.class.getSimpleName();

    /** the handle to the native mp3 decoder **/
    private int handle = -1;

    /** the float floatBuffer used to read in the samples **/
    private FloatBuffer floatBuffer;

    /** the short floatBuffer **/
    // private ShortBuffer shortBuffer;

    static {
        System.loadLibrary("kwmp3");
        // System.loadLibrary("madb");
    }

    private native int openFile(String file);

    public int load(String file) {
        handle = openFile(file);
        return handle;
    }

    private native int getChannelNum(int handle);

    public int getChannelNum() {
        if (handle != -1)
            return getChannelNum(handle);
        else {
            return 0;
        }
    }

    private native int getBitrate(int handle);

    public int getBitrate() {
        return getBitrate(handle);
    }

    private native int getSamplerate(int handle);

    public int getSamplerate() {
        return getSamplerate(handle);
    }

    private native int getDuration(int handle);

    public int getDuration() {
        if (handle != -1) {
            return getDuration(handle);
        } else {
            return 0;
        }
    }

    private native int getCurrentPosition(int handle);
    private native int isReadFinished(int handle);
    public int getCurrentPosition() {
        if (handle != -1) {
            return getCurrentPosition(handle);
        } else {
            return 0;
        }
    }

    private native int seekTo(int handle, int msec);

    public void seekTo(int msec) {
        if (handle != -1) {
            seekTo(handle, msec);
        }
    }

    private native int getSamplePerFrame(int handle);

    public int getSamplePerFrame() {
        return getSamplePerFrame(handle);
    }

    /**
     * Reads in numSamples float PCM samples to the provided direct FloatBuffer using the handle retrievable via {@link
     * NativeMP3Decoder.getHandle()}. This is for people who know what they do. Returns the number of samples actually
     * read.
     * 
     * @param handle
     *            The handle
     * @param floatBuffer
     *            The direct FloatBuffer
     * @param numSamples
     *            The number of samples to read
     * @return The number of samples read.
     */
    public native int readSamples(int handle, FloatBuffer buffer, int numSamples);

    /**
     * Reads in numSamples 16-bit signed PCM samples to the provided direct FloatBuffer using the handle retrievable via
     * {@link NativeMP3Decoder.getHandle()}. This is for people who know what they do. Returns the number of samples
     * actually read.
     * 
     * @param handle
     *            The handle
     * @param floatBuffer
     *            The direct FloatBuffer
     * @param numSamples
     *            The number of samples to read
     * @return The number of samples read.
     */
    public native int readSamples(int handle, ShortBuffer buffer, int numSamples);

    public native int readSamples(int handle, short[] buffer, int numSamples);

    private native void closeFile(int handle);

    public void release() {
        if (handle != -1) {
            closeFile(handle);
            handle = -1;
        }
    }

    public boolean isReleased() {
        return handle == -1;
    }

    // private native int genFingerprint( int handle );

    // public int genFingerprint() {
    // return genFingerprint( handle );
    // }
    private native int downsampling(int handle, String file);

    public int downsampling(String outputWaveFile) {
        
        if (handle != -1) {
            return downsampling(handle, outputWaveFile);
        }
        return 0;
    }

    /**
     * @return The handle retrieved from the native side.
     */
    public int getHandle() {
        return handle;
    }

    /**
     * {@inheritDoc}
     */
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

    public boolean isFinished() {
        
        if (isReleased()) {
            return true;
        }
        
        if (isReadFinished(handle) == 1) {
            return true;
        }
        
        return getCurrentPosition()/1000 == getDuration();
    }

    static String[] mp3_formats = {"mp3"};
    @Override
    public String[] getFormats() {      
        return mp3_formats;
    }
    
    
}