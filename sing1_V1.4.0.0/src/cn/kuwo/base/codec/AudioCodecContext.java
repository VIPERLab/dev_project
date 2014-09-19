package cn.kuwo.base.codec;

import android.content.Context;

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Vector;

import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.sing.context.DirContext;

public class AudioCodecContext {
	
	public static final int AUDIO_CODEC_NOT_FOUND = 0x1000001;	
	public static final int	AUDIO_CODEC_LOAD_FAIL = 0x1000002;
	
	public static final String SUPPORT_FORMAT_OPTION = "mp3|aac";//暂不支持线上AAC资源	
	private static Collection<AudioCodec> codecs;
	
	static {
	    codecs = new Vector<AudioCodec>();
	    codecs.add(new AudioCodec("mp3解码器",NativeMP3Decoder.class, NativeMP3Decoder.mp3_formats));
	    codecs.add(new AudioCodec("aac解码器",NativeAACDecoder.class, NativeAACDecoder.aac_formats));
	}	
	
	public static Collection<String> getSupportFormats() {
        
        Collection<String> formats = new ArrayList<String>();
        for (AudioCodec codec: codecs) {
            String[] cfs = codec.getSupportFormats();
            for (int i = 0; i < cfs.length; i++) {
                String format = cfs[i].toLowerCase();
                if (!formats.contains(format))
                    formats.add(format);
            }
        }
        return formats;     
    }
	
	public static int loadPlugInCodecs(Context context) {
	    final File codecDir = DirectoryManager.getDir(DirContext.CODEC);
	    File[] jarFiles = codecDir.listFiles(new FilenameFilter() {
            
            @Override
            public boolean accept(File dir, String filename) {
                if (filename.endsWith(".jar") || filename.endsWith(".zip") 
                        || filename.endsWith(".kwc")) {
                    return true;
                }
                return false;
            }
        });
	    
	    if (jarFiles == null || jarFiles.length == 0)
	        return 0;
	    int codecsNum = 0;
	    
	    for (int i = 0; i < jarFiles.length; i++) {
            File file = jarFiles[i];
            AudioCodec codec = loadAudioCodecFromJar(file, context);
            if (codec != null && !codecs.contains(codec)) {
                codecs.add(codec);
                codecsNum ++ ;
            }
        }
	    return codecsNum;
	}
	
	/**
	 * 从
	 * @param jarFile
	 * @return
	 */
	private static AudioCodec loadAudioCodecFromJar(File jarFile, Context context) {
	    return CodecPluginLoader.getCodecPluginLoader().loadPlugin(jarFile.getAbsolutePath(), context);
	}
	
	public static boolean supportOnlineFormat(String format) {
	    if (format == null || format.length() == 0)
            return false;
	    
	    String f = format.toLowerCase();
	    int index = SUPPORT_FORMAT_OPTION.indexOf(f);
	    return index != -1;
	}
	
	public static boolean supportFormat(String format) {
	    if (format == null || format.length() == 0)
            return false;
	    
	    boolean support = false;
        for (AudioCodec ac: codecs) {   
            String[] formats = ac.getSupportFormats();
            
            if (formats != null) {
                for (int i = 0; i < formats.length; i++) {
                    if (formats[i].equalsIgnoreCase(format)) {
                        support = true;
                        break; 
                    }
                }
            } 
            if (support) {
                break;
            }            
        }
        
        return support;
	}
		
	public static String guessAudioFormat(String path) {
		return null;
	}
	
	public static Decoder findCodecByFormat(String format) {
		if (format == null || format.length() == 0) {
			return null;
		}
		Decoder decoder = null;
		Class<? extends Decoder> codecClass = null;
		for (AudioCodec ac: codecs) {
		    boolean support = false;
            String[] formats = ac.getSupportFormats();
            
            if (formats != null) {
                for (int i = 0; i < formats.length; i++) {
                    if (formats[i].equalsIgnoreCase(format)) {
                        support = true;
                        break; 
                    }
                }
            } 
            if (support) {
                codecClass = ac.getCodecClass();
                break;
            }            
		}
		
		if (codecClass == null) {
			throw new IllegalArgumentException("unknown audio format " + format);
		}
		
		try {
			decoder = codecClass.newInstance();
		} catch (Exception e) {
			throw new RuntimeException("Decoder must have a default constructor");
		} 
		return decoder;
	}
}
